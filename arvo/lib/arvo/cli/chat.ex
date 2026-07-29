defmodule Arvo.CLI.Chat do
  @moduledoc """
  Headless non-interactive product entry (KTD-H1).

  Usage:

      arvo-chat --cwd <dir> --prompt <file|string> \\
        [--attention on|off] [--max-turns N] [--timeout-sec S]

  Lifecycle: set treatment → open session (`session_treatment`) → `start_turn`
  (product projection path) → wait idle / timeout → exit with contract codes.

  Exit codes:
  - `0` turn completed; session + audit written
  - `1` invalid args / missing cwd
  - `2` provider / model failure
  - `3` tool abort / unrecoverable tool error
  - `4` max turns
  - `5` idle / wall timeout
  - `6` missing audit when treatment requires evidence
  """

  require Logger

  @default_timeout_sec 600
  @default_max_turns 25

  @doc """
  CLI entry. Parses argv, runs headless turn, optionally `System.halt/1`.

  Set `Application.put_env(:arvo, :cli_halt, false)` in tests to get the exit
  code as a return value instead of halting the VM.
  """
  def main(argv \\ nil) do
    argv = argv || argv_from_env() || System.argv()
    code = main_no_halt(argv)

    if Application.get_env(:arvo, :cli_halt, true) do
      System.halt(code)
    else
      code
    end
  end

  @doc "Parse + run without `System.halt/1`. Returns exit code integer."
  def main_no_halt(argv) when is_list(argv) do
    case parse_args(argv) do
      {:ok, opts} ->
        run(opts)

      {:error, "help"} ->
        usage()
        1

      {:error, msg} ->
        IO.puts(:stderr, "arvo-chat: #{msg}")
        usage()
        1
    end
  end

  @doc """
  Run headless product path from option map.

  Keys: `:cwd`, `:prompt` (required binaries), `:attention` (`"on"`|`"off"`|nil),
  `:max_turns`, `:timeout_sec`, optional `:complete_fun`, `:model`, `:event_fun`.
  """
  def run(opts) when is_map(opts) do
    cwd = Map.fetch!(opts, :cwd)
    prompt = Map.fetch!(opts, :prompt)

    with :ok <- ensure_cwd(cwd),
         :ok <- ensure_prompt(prompt) do
      do_run(opts, cwd, prompt)
    else
      {:error, :missing_cwd} ->
        IO.puts(:stderr, "arvo-chat: --cwd is required and must be an existing directory")
        1

      {:error, :missing_prompt} ->
        IO.puts(:stderr, "arvo-chat: --prompt is required (string or path to file)")
        1
    end
  end

  @doc "Parse argv into `{:ok, opts}` or `{:error, reason}`."
  def parse_args(argv) when is_list(argv) do
    {parsed, _rest, invalid} =
      OptionParser.parse(argv,
        strict: [
          cwd: :string,
          prompt: :string,
          attention: :string,
          max_turns: :integer,
          timeout_sec: :integer,
          help: :boolean
        ],
        aliases: [h: :help]
      )

    cond do
      invalid != [] ->
        {:error, "invalid option(s): #{inspect(invalid)}"}

      parsed[:help] ->
        # main_no_halt prints usage on error; avoid double-print here.
        {:error, "help"}

      true ->
        cwd = parsed[:cwd] || System.get_env("ARVO_CWD")
        prompt = parsed[:prompt] || System.get_env("ARVO_PROMPT")

        attention =
          case parsed[:attention] || System.get_env("ARVO_ATTENTION") ||
                 System.get_env("ARVO_PROGRESSIVE_ATTENTION") do
            nil -> nil
            v -> normalize_attention(v)
          end

        case attention do
          :invalid ->
            {:error, "--attention must be on|off (or 1|0)"}

          mode ->
            if is_nil(cwd) or cwd == "" do
              {:error, "missing --cwd (or ARVO_CWD)"}
            else
              if is_nil(prompt) or prompt == "" do
                {:error, "missing --prompt (or ARVO_PROMPT)"}
              else
                {:ok,
                 %{
                   cwd: Path.expand(cwd),
                   prompt: prompt,
                   attention: mode,
                   max_turns: parsed[:max_turns] || @default_max_turns,
                   timeout_sec: parsed[:timeout_sec] || @default_timeout_sec
                 }}
              end
            end
        end
    end
  end

  @doc """
  Decode argv written by the release `arvo-chat` wrapper (base64 lines file).

  Falls back to `System.argv()` when env unset.
  """
  def argv_from_env do
    case System.get_env("ARVO_CHAT_ARGS_B64_FILE") do
      path when is_binary(path) and path != "" ->
        if File.regular?(path) do
          path
          |> File.read!()
          |> String.split("\n", trim: true)
          |> Enum.map(fn line ->
            case Base.decode64(String.trim(line)) do
              {:ok, bin} -> bin
              :error -> line
            end
          end)
        else
          nil
        end

      _ ->
        case System.get_env("ARVO_CHAT_ARGS") do
          raw when is_binary(raw) and raw != "" ->
            # Space-separated fallback (simple Harbor cases without spaces in values)
            OptionParser.split(raw)

          _ ->
            nil
        end
    end
  end

  # --- internals ----------------------------------------------------------

  defp do_run(opts, cwd, prompt_arg) do
    configure_headless!(opts, cwd)

    prompt_text =
      cond do
        File.regular?(prompt_arg) -> File.read!(prompt_arg)
        File.regular?(Path.expand(prompt_arg, cwd)) -> File.read!(Path.expand(prompt_arg, cwd))
        true -> prompt_arg
      end

    case Arvo.Session.open_new(cwd) do
      {:ok, session_path} ->
        _ = Arvo.Session.record_message(%{role: "user", content: prompt_text})
        _ = Arvo.Session.maybe_auto_compact()

        context = Arvo.TurnContext.build(cwd: cwd)
        model = Map.get(opts, :model) || default_model()
        max_turns = Map.get(opts, :max_turns) || @default_max_turns
        timeout_sec = Map.get(opts, :timeout_sec) || @default_timeout_sec
        timeout_ms = max(timeout_sec, 1) * 1_000

        config = %{model: model, max_turns: max_turns}

        config =
          case Map.get(opts, :complete_fun) || Application.get_env(:arvo, :complete_fun) do
            fun when is_function(fun, 3) -> Map.put(config, :complete_fun, fun)
            _ -> config
          end

        event_fun =
          Map.get(opts, :event_fun) ||
            fn
              {:agent_error, %{error: e}} ->
                Logger.error("arvo-chat agent_error: #{inspect(e)}")
                :ok

              _ ->
                :ok
            end

        case Arvo.Session.start_turn(context, config, event_fun) do
          {:ok, _task} ->
            result = await_with_timeout(timeout_ms)
            classify_result(result, session_path, opts)

          {:error, :turn_in_progress} ->
            IO.puts(:stderr, "arvo-chat: turn already in progress")
            3

          {:error, reason} ->
            IO.puts(:stderr, "arvo-chat: start_turn failed: #{inspect(reason)}")
            2
        end

      {:error, reason} ->
        IO.puts(:stderr, "arvo-chat: open_new failed: #{inspect(reason)}")
        2
    end
  rescue
    e ->
      IO.puts(:stderr, "arvo-chat: #{Exception.message(e)}")
      2
  end

  defp configure_headless!(opts, cwd) do
    Application.put_env(:arvo, :headless, true)
    Application.put_env(:arvo, :start_focus, false)
    Application.put_env(:arvo, :start_repl, false)
    Application.put_env(:arvo, :auto_resume, false)
    Application.put_env(:arvo, :cwd, cwd)
    System.put_env("ARVO_CWD", cwd)
    System.put_env("ARVO_HEADLESS", "1")

    case Map.get(opts, :attention) do
      "off" ->
        Application.put_env(:arvo, :progressive_attention, false)
        System.put_env("ARVO_PROGRESSIVE_ATTENTION", "0")

      "on" ->
        Application.put_env(:arvo, :progressive_attention, true)
        System.put_env("ARVO_PROGRESSIVE_ATTENTION", "1")

      nil ->
        # Honor existing Application / System env (Harbor may set only env).
        case System.get_env("ARVO_PROGRESSIVE_ATTENTION") do
          v when v in ["0", "false", "off", "OFF"] ->
            Application.put_env(:arvo, :progressive_attention, false)

          v when v in ["1", "true", "on", "ON"] ->
            Application.put_env(:arvo, :progressive_attention, true)

          _ ->
            :ok
        end
    end

    :ok
  end

  defp await_with_timeout(timeout_ms) do
    Arvo.Session.await_turn(timeout_ms)
  catch
    :exit, {:timeout, _} ->
      _ = Arvo.Session.cancel_turn()
      {:error, :timeout}

    :exit, reason ->
      {:error, {:exit, reason}}
  end

  defp classify_result(result, session_path, opts) do
    attention = Map.get(opts, :attention) || Arvo.Attention.treatment_mode_from_env()

    case result do
      {:error, :timeout} ->
        5

      {:error, :cancelled} ->
        # cancel after timeout already returns 5; bare cancel → treat as tool/abort class
        3

      {:error, reason} ->
        classify_error(reason)

      {:ok, agent_result} when is_map(agent_result) ->
        case Map.get(agent_result, :stop_reason) do
          :max_turns ->
            4

          {:error, reason} ->
            classify_error(reason)

          :end_turn ->
            audit_exit(session_path, attention)

          other when other in [nil, :stop, :completed] ->
            audit_exit(session_path, attention)

          other ->
            # Unknown stop — still require audit honesty when treatment on
            Logger.warning("arvo-chat: unexpected stop_reason #{inspect(other)}")
            audit_exit(session_path, attention)
        end

      other ->
        IO.puts(:stderr, "arvo-chat: unexpected turn result: #{inspect(other)}")
        2
    end
  end

  defp classify_error(reason) do
    cond do
      tool_abort?(reason) -> 3
      true -> 2
    end
  end

  defp tool_abort?(reason) do
    case reason do
      :tool_abort -> true
      {:tool_abort, _} -> true
      %{type: :tool_abort} -> true
      s when is_binary(s) -> String.contains?(String.downcase(s), "tool abort")
      _ -> false
    end
  end

  defp audit_exit(session_path, attention) do
    mode = normalize_attention(attention) || "on"

    if mode == "off" do
      # Off path still emits session_treatment; missing file is soft (scorers check honesty_off).
      if audit_present?(session_path), do: 0, else: 0
    else
      if audit_evidence_ok?(session_path) do
        0
      else
        IO.puts(:stderr, "arvo-chat: missing audit evidence under treatment=on (#{session_path})")
        6
      end
    end
  end

  defp audit_present?(session_path) when is_binary(session_path) do
    path = Arvo.Session.Audit.path(session_path)
    File.regular?(path)
  end

  defp audit_present?(_), do: false

  defp audit_evidence_ok?(session_path) when is_binary(session_path) do
    path = Arvo.Session.Audit.path(session_path)

    if not File.regular?(path) do
      false
    else
      events = Arvo.Session.Audit.list(session_path)

      Enum.any?(events, fn e ->
        e["type"] == "session_treatment" and e["committed"] in ["committed", nil]
      end)
    end
  end

  defp audit_evidence_ok?(_), do: false

  defp ensure_cwd(cwd) when is_binary(cwd) do
    if File.dir?(cwd), do: :ok, else: {:error, :missing_cwd}
  end

  defp ensure_cwd(_), do: {:error, :missing_cwd}

  defp ensure_prompt(p) when is_binary(p) and p != "", do: :ok
  defp ensure_prompt(_), do: {:error, :missing_prompt}

  defp normalize_attention(nil), do: nil

  defp normalize_attention(v) when is_atom(v) do
    normalize_attention(Atom.to_string(v))
  end

  defp normalize_attention(v) when is_binary(v) do
    case String.downcase(String.trim(v)) do
      x when x in ["on", "1", "true", "yes"] -> "on"
      x when x in ["off", "0", "false", "no"] -> "off"
      _ -> :invalid
    end
  end

  defp normalize_attention(_), do: :invalid

  defp default_model do
    Application.get_env(:arvo, :default_model) ||
      get_in(Application.get_env(:arvo, :config) || %{}, [:default_model]) ||
      "xai:grok-4.5"
  end

  defp usage do
    IO.puts(:stderr, """
    Usage: arvo-chat --cwd <dir> --prompt <file|string> [options]

    Options:
      --cwd PATH           Task workspace (or ARVO_CWD)
      --prompt TEXT|FILE   User prompt string or path to file (or ARVO_PROMPT)
      --attention on|off   Progressive attention treatment (or ARVO_PROGRESSIVE_ATTENTION)
      --max-turns N        Agent tool loop cap (default #{@default_max_turns})
      --timeout-sec S      Wall clock timeout (default #{@default_timeout_sec})
      -h, --help           Show this help

    Exit codes: 0 ok, 1 args, 2 provider, 3 tool abort, 4 max turns, 5 timeout, 6 missing audit
    """)
  end
end
