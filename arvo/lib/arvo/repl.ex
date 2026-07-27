defmodule Arvo.Repl do
  @moduledoc """
  Line-IO loop (SPEC §12 / §6 / §7): slash commands via TUI, chat via Session turns.

  Product chat always goes through `Session.start_turn` (never bare `Agent.run`).
  """

  @doc """
  Read lines from `device` (default `:stdio`).
  Slash commands delegated to `Arvo.TUI.slash/2`. Non-slash lines run a Session turn.
  """
  def run(device \\ :stdio) do
    cwd = Application.get_env(:arvo, :cwd) || Arvo.cwd()
    # Do not open_new here: an empty boot session becomes /resume 1 and steals
    # the previous chat. Session is created lazily on first chat (run_chat/2).
    IO.puts(device, "arvo 0.1 — cwd=#{cwd} (type /help, chat, or quit)")
    loop(device)
  end

  @doc false
  def handle_line(line) when is_binary(line) do
    trimmed = String.trim(line)

    cond do
      trimmed in ["quit", "exit"] ->
        :quit

      trimmed == "" ->
        :continue

      true ->
        case Arvo.TUI.Commands.parse(trimmed) do
          {:command, "quit", _} -> :quit
          {:command, cmd, args} -> {:slash, cmd, args}
          {:text, text} -> {:chat, text}
        end
    end
  end

  @doc """
  Persist only **new** assistant/tool messages from an agent result.

  Delegates to Session (product-owned persist path). Kept for test compatibility.
  """
  def persist_agent_result(result, prior_len) do
    Arvo.Session.persist_agent_result(result, prior_len)
  end

  @doc "Rebuild chat messages from open session history (tool fields preserved)."
  def session_messages do
    sess = Arvo.Session.get()
    Arvo.Session.Store.messages_from_history(sess.history || [])
  end

  @doc "Record usage from agent result into Session + TUI."
  def maybe_record_usage(result), do: Arvo.Session.maybe_record_usage(result)

  defp loop(device) do
    case IO.gets(device, "> ") do
      :eof ->
        IO.puts(device, "bye")
        System.stop(0)

      {:error, _} ->
        System.stop(1)

      line when is_binary(line) ->
        case handle_line(line) do
          :quit ->
            IO.puts(device, "bye")
            System.stop(0)

          :continue ->
            loop(device)

          {:slash, cmd, args} ->
            run_slash(device, cmd, args)
            loop(device)

          {:chat, text} ->
            run_chat(device, text)
            loop(device)
        end
    end
  end

  defp run_slash(device, cmd, args) do
    case Arvo.TUI.slash(cmd, args) do
      {:ok, :quit, msg} ->
        IO.puts(device, msg)
        System.stop(0)

      {:ok, _status, msg} when is_binary(msg) ->
        IO.puts(device, msg)

      other ->
        IO.puts(device, format(other))
    end
  end

  defp run_chat(device, text) do
    if Application.get_env(:arvo, :echo_only, false) do
      IO.puts(device, text)
    else
      ensure_session(Application.get_env(:arvo, :cwd) || Arvo.cwd())
      _ = Arvo.Session.record_message(%{role: "user", content: text})
      _ = Arvo.Session.maybe_auto_compact()

      context = Arvo.TurnContext.build()
      model = Arvo.TUI.model()

      event_fun = fn event ->
        _ = Arvo.TUI.handle_event(event)

        case event do
          {:message_delta, %{text: t}} when is_binary(t) ->
            IO.write(device, t)

          {:tool_call_start, %{name: n}} ->
            IO.puts(device, "\n[tool #{n}]")

          {:tool_call_end, %{name: n, is_error: err}} ->
            tag = if err, do: "error", else: "ok"
            IO.puts(device, "[/#{n} #{tag}]")

          {:agent_error, %{error: e}} ->
            IO.puts(device, "\nerror: #{format(e)}")

          _ ->
            :ok
        end
      end

      case Arvo.Session.start_turn(context, %{model: model}, event_fun) do
        {:ok, _task} ->
          case Arvo.Session.await_turn() do
            {:ok, _result} ->
              IO.puts(device, "")

            {:error, :cancelled} ->
              IO.puts(device, "\n(cancelled)")

            {:error, reason} ->
              IO.puts(device, "error: #{format(reason)}")

            other ->
              IO.puts(device, "error: #{format(other)}")
          end

        {:error, :turn_in_progress} ->
          IO.puts(device, "error: turn already in progress")
      end
    end
  end

  defp ensure_session(cwd) do
    case Arvo.Session.get() do
      %{path: path} when is_binary(path) ->
        :ok

      _ ->
        _ = Arvo.Session.open_new(cwd)
        :ok
    end
  end

  defp format(r) when is_binary(r), do: r
  defp format(r), do: inspect(r)
end
