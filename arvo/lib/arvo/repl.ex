defmodule Arvo.Repl do
  @moduledoc """
  Line-IO loop (SPEC §12 / §6 / §7): slash commands via TUI, chat via Agent + tools.
  """

  @doc """
  Read lines from `device` (default `:stdio`).
  Slash commands delegated to `Arvo.TUI.slash/2`. Non-slash lines run `Arvo.Agent`.
  """
  def run(device \\ :stdio) do
    cwd = Application.get_env(:arvo, :cwd) || Arvo.cwd()
    ensure_session(cwd)
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

  `prior_len` is the number of non-system messages supplied to `Arvo.Agent.run/3`
  (session history). Agent result messages are `[system | prior... | new...]`.
  """
  def persist_agent_result(%{messages: messages}, prior_len)
      when is_list(messages) and is_integer(prior_len) and prior_len >= 0 do
    # Drop system (index 0) + prior history; only write this run's assistant/tool rows.
    new_msgs = Enum.drop(messages, prior_len + 1)

    Enum.each(new_msgs, fn m ->
      role = m[:role] || m["role"]

      if role in ["assistant", "tool"] do
        _ = Arvo.Session.record_message(message_to_attrs(m))
      end
    end)

    length(new_msgs)
  end

  def persist_agent_result(_, _), do: 0

  @doc "Rebuild chat messages from open session history (tool fields preserved)."
  def session_messages do
    sess = Arvo.Session.get()
    Arvo.Session.Store.messages_from_history(sess.history || [])
  end

  @doc "Record usage from agent result into Session + TUI."
  def maybe_record_usage(%{usage: usage}) when is_map(usage) do
    input =
      usage["prompt_tokens"] || usage[:prompt_tokens] || usage["input_tokens"] ||
        usage[:input_tokens] || 0

    output =
      usage["completion_tokens"] || usage[:completion_tokens] || usage["output_tokens"] ||
        usage[:output_tokens] || 0

    if input + output > 0 do
      case Arvo.Session.record_usage(%{
             input_tokens: input,
             output_tokens: output
           }) do
        {:ok, tokens} ->
          turn = tokens.turn_input + tokens.turn_output
          _ = Arvo.TUI.put_tokens(turn, tokens.cumulative_total)
          {:ok, tokens}

        other ->
          other
      end
    else
      {:ok, :noop}
    end
  end

  def maybe_record_usage(_), do: {:ok, :noop}

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

      tools =
        case Arvo.Plugins.Registry.tools() do
          list when is_list(list) and list != [] -> list
          _ -> Arvo.Tool.core_tools()
        end

      history_msgs = session_messages()
      prior_len = length(history_msgs)

      context = %{
        messages: history_msgs,
        cwd: Application.get_env(:arvo, :cwd) || Arvo.cwd(),
        tools: tools,
        session_id: Map.get(Arvo.Session.get(), :id)
      }

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

      case Arvo.Agent.run(context, %{model: model}, event_fun) do
        {:ok, result} ->
          _ = persist_agent_result(result, prior_len)
          _ = maybe_record_usage(result)
          _ = Arvo.Session.maybe_auto_compact()
          IO.puts(device, "")

        {:error, reason} ->
          IO.puts(device, "error: #{format(reason)}")
      end
    end
  end

  defp message_to_attrs(m) do
    role = m[:role] || m["role"]
    content = m[:content] || m["content"] || ""

    attrs = %{
      "type" => "message",
      "role" => role,
      "content" => content
    }

    attrs =
      case m[:tool_call_id] || m["tool_call_id"] do
        nil ->
          attrs

        id ->
          Map.merge(attrs, %{
            "tool_call_id" => id,
            "name" => m[:name] || m["name"],
            "is_error" => m[:is_error] || m["is_error"] || false
          })
      end

    case m[:tool_calls] || m["tool_calls"] do
      nil -> attrs
      [] -> attrs
      tcs -> Map.put(attrs, "tool_calls", tcs)
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
