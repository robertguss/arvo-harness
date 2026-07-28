defmodule Arvo.Agent do
  @moduledoc """
  Pure agent loop (SPEC §4). Not a process — each turn is driven by the caller
  (typically a supervised Task under the session). Policy (retry, compaction,
  steering) lives outside this module.
  """

  @doc """
  Run the agent until the model stops calling tools or `max_turns` is hit.

  ## Context
  - `:messages` — chat messages (`%{role, content}` maps; optional tool fields)
  - `:cwd`, `:session_id`, `:config`
  - `:tools` — tool modules (default core four)
  - `:steering` — list of user strings queued mid-run (drained after each turn)

  ## Config
  - `:model` — req_llm model string
  - `:max_turns` — default 25
  - `:complete_fun` — injectable
    `(messages, tools_spec, config) -> {:ok, assistant_msg} | {:error, reason}`
    where assistant_msg is
    `%{role: "assistant", content: text, tool_calls: [%{id, name, arguments}]}`

  ## event_fun
  Called with each event. Must not raise.
  """
  def run(context, config, event_fun) when is_function(event_fun, 1) do
    tools = Map.get(context, :tools) || Arvo.Tool.core_tools()
    max_turns = Map.get(config, :max_turns) || 25
    complete_fun = Map.get(config, :complete_fun) || (&default_complete/3)

    system = build_system(context, tools)
    messages = [%{role: "system", content: system} | List.wrap(Map.get(context, :messages))]

    event_fun.({:agent_start, %{session_id: Map.get(context, :session_id)}})

    try do
      result =
        turn_loop(
          messages,
          tools,
          context,
          config,
          complete_fun,
          event_fun,
          0,
          max_turns,
          List.wrap(Map.get(context, :steering)),
          empty_usage()
        )

      event_fun.({:agent_end, %{result: result}})
      {:ok, result}
    rescue
      e ->
        event_fun.({:agent_error, %{error: Exception.message(e)}})
        {:error, Exception.message(e)}
    catch
      :exit, reason ->
        event_fun.({:agent_error, %{error: {:exit, reason}}})
        {:error, {:exit, reason}}
    end
  end

  defp turn_loop(messages, _tools, _ctx, _config, _complete_fun, _event_fun, turn, max_turns, steering, usage)
       when turn >= max_turns do
    %{messages: messages, stop_reason: :max_turns, steering: steering, usage: usage}
  end

  defp turn_loop(messages, tools, ctx, config, complete_fun, event_fun, turn, max_turns, steering, usage) do
    event_fun.({:turn_start, %{turn: turn}})
    # Thought chrome even when the model never streams reasoning tokens.
    event_fun.({:thinking_start, %{turn: turn}})
    tools_spec = Enum.map(tools, & &1.spec())

    # Wire streaming deltas into the event bus during complete (not post-hoc full body)
    streamed_count = :atomics.new(1, signed: false)
    thought_open = :atomics.new(1, signed: false)
    :atomics.put(thought_open, 1, 1)

    on_delta = fn
      {:thinking, chunk} when is_binary(chunk) and chunk != "" ->
        event_fun.({:thinking_delta, %{text: chunk}})
        :ok

      {:text, chunk} when is_binary(chunk) and chunk != "" ->
        close_thought_if_open(event_fun, thought_open)
        :atomics.add(streamed_count, 1, 1)
        event_fun.({:message_delta, %{text: chunk}})
        :ok

      chunk when is_binary(chunk) and chunk != "" ->
        close_thought_if_open(event_fun, thought_open)
        :atomics.add(streamed_count, 1, 1)
        event_fun.({:message_delta, %{text: chunk}})
        :ok

      _ ->
        :ok
    end

    config = Map.put(config, :on_delta, on_delta)

    case complete_fun.(messages, tools_spec, config) do
      {:error, reason} ->
        close_thought_if_open(event_fun, thought_open)
        event_fun.({:agent_error, %{error: reason}})
        %{messages: messages, stop_reason: {:error, reason}, steering: steering, usage: usage}

      {:ok, assistant} ->
        content = Map.get(assistant, :content) || Map.get(assistant, "content") || ""
        tool_calls = Map.get(assistant, :tool_calls) || Map.get(assistant, "tool_calls") || []
        turn_usage = Map.get(assistant, :usage) || Map.get(assistant, "usage") || %{}
        usage = merge_usage(usage, turn_usage)
        streamed? = Map.get(assistant, :streamed?) == true or :atomics.get(streamed_count, 1) > 0

        # Close thought before tools / post-hoc content if still open
        close_thought_if_open(event_fun, thought_open)

        # Only emit a post-hoc full-body delta when the complete_fun did not stream
        if content != "" and not streamed? do
          event_fun.({:message_delta, %{text: content}})
        end

        assistant_msg = %{
          role: "assistant",
          content: content,
          tool_calls: tool_calls
        }

        assistant_msg =
          if map_size(turn_usage) > 0 do
            Map.put(assistant_msg, :usage, turn_usage)
          else
            assistant_msg
          end

        messages = messages ++ [assistant_msg]

        if tool_calls == [] do
          event_fun.({:turn_end, %{turn: turn, tool_calls: 0}})
          %{messages: messages, stop_reason: :end_turn, steering: steering, usage: usage}
        else
          {tool_msgs, results} = run_tools_sequential(tool_calls, tools, ctx, event_fun)
          messages = messages ++ tool_msgs
          event_fun.({:turn_end, %{turn: turn, tool_calls: length(tool_calls), results: results}})
          # Drain initial context steering + any mid-turn Session.steer queue (product path R4)
          {messages, steering} = drain_steering(messages, steering ++ pull_session_steering())

          turn_loop(
            messages,
            tools,
            ctx,
            config,
            complete_fun,
            event_fun,
            turn + 1,
            max_turns,
            steering,
            usage
          )
        end
    end
  end

  defp close_thought_if_open(event_fun, thought_open) do
    if :atomics.exchange(thought_open, 1, 0) == 1 do
      event_fun.({:thinking_end, %{}})
    end

    :ok
  end

  defp empty_usage do
    %{"prompt_tokens" => 0, "completion_tokens" => 0, "total_tokens" => 0}
  end

  defp merge_usage(acc, add) when is_map(acc) and is_map(add) do
    a = Arvo.Session.Tokens.input_output(acc)
    b = Arvo.Session.Tokens.input_output(add)
    p = a.input_tokens + b.input_tokens
    c = a.output_tokens + b.output_tokens

    %{
      "prompt_tokens" => p,
      "completion_tokens" => c,
      "total_tokens" => p + c,
      "input_tokens" => p,
      "output_tokens" => c
    }
  end

  defp run_tools_sequential(tool_calls, tools, ctx, event_fun) do
    tool_by_name =
      Map.new(tools, fn mod ->
        {mod.spec().name, mod}
      end)

    tool_msgs =
      Enum.map(tool_calls, fn call ->
        id = Map.get(call, :id) || Map.get(call, "id") || "call_#{System.unique_integer([:positive])}"
        name = Map.get(call, :name) || Map.get(call, "name")
        args = normalize_args(Map.get(call, :arguments) || Map.get(call, "arguments") || %{})

        event_fun.({:tool_call_start, %{id: id, name: name, arguments: args}})

        {is_error, text} =
          case Map.get(tool_by_name, name) do
            nil ->
              {true,
               "Unknown tool: #{name}. Available: #{Enum.map_join(Map.keys(tool_by_name), ", ", & &1)}"}

            mod ->
              case Arvo.Tool.invoke(mod, args, tool_ctx(ctx)) do
                {:ok, out} -> {false, out}
                {:error, out} -> {true, out}
              end
          end

        projected = project_tool_result(ctx, name, args, text, is_error, id)
        model_content = Map.get(projected, :content) || text
        human_text = Map.get(projected, :full_text) || text

        event_fun.({
          :tool_call_end,
          %{
            id: id,
            name: name,
            is_error: is_error,
            text: human_text,
            model_text: model_content,
            cold_id: Map.get(projected, :cold_id),
            attention_action: Map.get(projected, :action) || :full_hot
          }
        })

        msg = %{
          role: "tool",
          tool_call_id: id,
          name: name,
          content: model_content,
          is_error: is_error
        }

        if cold_id = Map.get(projected, :cold_id) do
          Map.put(msg, :cold_id, cold_id)
        else
          msg
        end
      end)

    {tool_msgs, tool_msgs}
  end

  # Progressive attention: project tool bodies for model hot context (KTD1).
  # Injectable via context.project_tool_result/5 or identity when unset.
  defp project_tool_result(ctx, name, args, text, is_error, tool_call_id) do
    case Map.get(ctx, :project_tool_result) do
      fun when is_function(fun, 5) ->
        case fun.(name, args, text, is_error, %{tool_call_id: tool_call_id}) do
          %{} = projected -> projected
          content when is_binary(content) -> %{content: content, full_text: text, action: :full_hot}
          _ -> %{content: text, full_text: text, action: :full_hot}
        end

      _ ->
        %{content: text, full_text: text, action: :full_hot, cold_id: nil}
    end
  rescue
    e ->
      project_fail_open(text, Exception.message(e))
  catch
    :exit, reason ->
      project_fail_open(text, inspect(reason))
  end

  defp project_fail_open(text, reason) do
    require Logger
    Logger.warning("Arvo.Agent projection fail-open: #{reason}")

    %{
      content: text,
      full_text: text,
      action: :full_hot,
      cold_id: nil,
      project_error: reason
    }
  end

  defp normalize_args(args) when is_binary(args) do
    case Jason.decode(args) do
      {:ok, m} when is_map(m) -> m
      _ -> %{}
    end
  end

  defp normalize_args(args) when is_map(args), do: args
  defp normalize_args(_), do: %{}

  defp drain_steering(messages, []) do
    {messages, []}
  end

  defp drain_steering(messages, steering) do
    user_msgs = Enum.map(steering, fn text -> %{role: "user", content: text} end)
    {messages ++ user_msgs, []}
  end

  defp pull_session_steering do
    try do
      if Process.whereis(Arvo.Session) do
        Arvo.Session.take_steering()
      else
        []
      end
    rescue
      _ -> []
    catch
      _, _ -> []
    end
  end

  defp tool_ctx(ctx) do
    %{
      cwd: Map.get(ctx, :cwd) || Arvo.cwd(),
      session_id: Map.get(ctx, :session_id),
      config: Map.get(ctx, :config) || %{}
    }
  end

  defp build_system(context, tools) do
    Arvo.Prompt.assemble(
      cwd: Map.get(context, :cwd) || Arvo.cwd(),
      tools: tools,
      skills: Map.get(context, :skills) || []
    )
  end

  defp default_complete(messages, tools_spec, config) do
    model = Map.get(config, :model) || "xai:grok-4.5"
    on_delta = Map.get(config, :on_delta, fn _ -> :ok end)

    opts =
      [model: model, on_delta: on_delta]
      |> maybe_kw(config, :provider)
      |> maybe_kw(config, :stream_body)
      |> maybe_kw(config, :http_fun)
      |> maybe_kw(config, :base_url)

    # Drop system-less edge: complete_turn sends full message list including system.
    case Arvo.Providers.Completion.complete_turn(messages, tools_spec, opts) do
      {:ok, assistant} ->
        {:ok,
         %{
           role: "assistant",
           content: assistant.content || "",
           tool_calls: assistant.tool_calls || [],
           usage: Map.get(assistant, :usage),
           streamed?: Map.get(assistant, :streamed?, false)
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_kw(opts, config, key) do
    case Map.get(config, key) do
      nil -> opts
      val -> Keyword.put(opts, key, val)
    end
  end
end

