defmodule Arvo.Herdr.CLI do
  @moduledoc """
  Production Herdr adapter: shells out to the `herdr` binary and parses JSON
  (or plain text for `pane read`).
  """

  @behaviour Arvo.Herdr.Adapter

  @impl true
  def available? do
    System.get_env("HERDR_ENV") == "1" and is_binary(System.find_executable("herdr"))
  end

  @impl true
  def split(opts) when is_list(opts) do
    direction =
      case Keyword.get(opts, :direction, :right) do
        :down -> "down"
        "down" -> "down"
        _ -> "right"
      end

    args =
      ["pane", "split", "--current", "--direction", direction]
      |> maybe_flag(Keyword.get(opts, :no_focus, true), ["--no-focus"])
      |> maybe_opt("--ratio", Keyword.get(opts, :ratio))
      |> maybe_opt("--cwd", Keyword.get(opts, :cwd))

    case cmd(args) do
      {:ok, data} ->
        case dig_pane_id(data) do
          id when is_binary(id) and id != "" -> {:ok, id}
          _ -> {:error, "herdr split: no pane_id in response: #{inspect(data)}"}
        end

      {:error, _} = err ->
        err
    end
  end

  @doc """
  Argv for `herdr pane run`. Exposed for tests.

  Herdr joins remaining args with spaces before send-text. The command must
  therefore be a single trailing argv — never `bash`, `-c`, and the script as
  separate tokens (that yields `bash -c python3 -m …` and only runs `python3`).
  The target pane already has an interactive shell.
  """
  def run_argv(pane_id, command)
      when is_binary(pane_id) and is_binary(command) do
    ["pane", "run", pane_id, command]
  end

  @impl true
  def run(pane_id, command) when is_binary(pane_id) and is_binary(command) do
    case cmd(run_argv(pane_id, command)) do
      {:ok, _} -> :ok
      {:error, _} = err -> err
    end
  end

  @impl true
  def read(pane_id, opts) when is_binary(pane_id) and is_list(opts) do
    # Herdr wants positional pane id before options.
    args =
      ["pane", "read", pane_id]
      |> maybe_opt("--lines", Keyword.get(opts, :lines))
      |> maybe_opt("--source", source_arg(Keyword.get(opts, :source)))

    case System.cmd("herdr", args, stderr_to_stdout: true, env: Arvo.Isolation.cmd_env()) do
      {out, 0} ->
        out = String.trim_trailing(out)

        case Jason.decode(out) do
          {:ok, data} ->
            text =
              get_in(data, ["result", "text"]) ||
                get_in(data, ["result", "read", "text"]) ||
                get_in(data, ["result", "pane", "text"]) ||
                out

            {:ok, to_string(text)}

          {:error, _} ->
            {:ok, out}
        end

      {out, code} ->
        {:error, "herdr pane read exited #{code}: #{String.trim(out)}"}
    end
  rescue
    e -> {:error, "herdr pane read failed: #{Exception.message(e)}"}
  end

  @doc """
  Argv for `herdr wait output`. Exposed for tests.

  Herdr 0.7+ uses top-level `wait output` (not `pane wait-output`).
  `--regex` is a flag that treats `--match` as a Rust regex.
  """
  def wait_output_argv(pane_id, opts)
      when is_binary(pane_id) and is_list(opts) do
    match = Keyword.get(opts, :match)
    regex = Keyword.get(opts, :regex)
    base = ["wait", "output", pane_id]

    args =
      cond do
        is_binary(match) and match != "" ->
          base ++ ["--match", match]

        is_binary(regex) and regex != "" ->
          base ++ ["--match", regex, "--regex"]

        true ->
          base
      end

    args
    |> maybe_opt("--timeout", Keyword.get(opts, :timeout))
    |> maybe_opt("--lines", Keyword.get(opts, :lines))
    |> maybe_opt("--source", source_arg(Keyword.get(opts, :source)))
  end

  @impl true
  def wait_output(pane_id, opts) when is_binary(pane_id) and is_list(opts) do
    case cmd(wait_output_argv(pane_id, opts)) do
      {:ok, data} ->
        {:ok,
         %{
           matched_line: get_in(data, ["result", "matched_line"]),
           text: get_in(data, ["result", "read", "text"]) || get_in(data, ["result", "text"]),
           raw: data
         }}

      {:error, _} = err ->
        err
    end
  end

  @impl true
  def close(pane_id) when is_binary(pane_id) do
    case cmd(["pane", "close", pane_id]) do
      {:ok, _} -> :ok
      {:error, _} = err -> err
    end
  end

  @impl true
  def process_info(pane_id) when is_binary(pane_id) do
    case cmd(["pane", "process-info", "--pane", pane_id]) do
      {:ok, data} ->
        info = get_in(data, ["result", "process_info"]) || %{}

        {:ok,
         %{
           pane_id: info["pane_id"] || pane_id,
           shell_pid: info["shell_pid"],
           foreground_processes: info["foreground_processes"] || [],
           raw: data
         }}

      {:error, _} = err ->
        err
    end
  end

  defp cmd(args) do
    case System.cmd("herdr", args, stderr_to_stdout: true, env: Arvo.Isolation.cmd_env()) do
      {out, 0} ->
        parse_json_ok(out)

      {out, code} ->
        msg =
          case Jason.decode(String.trim(out)) do
            {:ok, %{"error" => %{"message" => m}}} when is_binary(m) -> m
            {:ok, %{"error" => e}} -> inspect(e)
            _ -> String.trim(out)
          end

        {:error, "herdr #{Enum.join(args, " ")} exited #{code}: #{msg}"}
    end
  rescue
    e -> {:error, "herdr #{Enum.join(args, " ")} failed: #{Exception.message(e)}"}
  end

  defp parse_json_ok(out) do
    trimmed = String.trim(out)

    case Jason.decode(trimmed) do
      {:ok, %{"error" => err}} ->
        msg =
          case err do
            %{"message" => m} when is_binary(m) -> m
            other -> inspect(other)
          end

        {:error, msg}

      {:ok, data} ->
        {:ok, data}

      {:error, _} ->
        # Some commands may return empty success bodies.
        if trimmed == "" do
          {:ok, %{}}
        else
          {:ok, %{"raw" => trimmed}}
        end
    end
  end

  defp dig_pane_id(data) when is_map(data) do
    get_in(data, ["result", "pane", "pane_id"]) ||
      get_in(data, ["result", "pane_id"]) ||
      get_in(data, ["pane_id"])
  end

  defp dig_pane_id(_), do: nil

  defp maybe_flag(args, true, flags), do: args ++ flags
  defp maybe_flag(args, _, _), do: args

  defp maybe_opt(args, _flag, nil), do: args
  defp maybe_opt(args, _flag, ""), do: args

  defp maybe_opt(args, flag, value)
       when is_binary(value) or is_integer(value) or is_float(value) do
    args ++ [flag, to_string(value)]
  end

  defp maybe_opt(args, _, _), do: args

  defp source_arg(nil), do: nil
  defp source_arg(:recent), do: "recent"
  defp source_arg(:visible), do: "visible"
  defp source_arg(:"recent-unwrapped"), do: "recent-unwrapped"
  defp source_arg(:detection), do: "detection"
  defp source_arg(s) when is_binary(s), do: s
  defp source_arg(_), do: nil
end
