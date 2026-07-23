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
    tools_spec = Enum.map(tools, & &1.spec())

    case complete_fun.(messages, tools_spec, config) do
      {:error, reason} ->
        event_fun.({:agent_error, %{error: reason}})
        %{messages: messages, stop_reason: {:error, reason}, steering: steering, usage: usage}

      {:ok, assistant} ->
        content = Map.get(assistant, :content) || Map.get(assistant, "content") || ""
        tool_calls = Map.get(assistant, :tool_calls) || Map.get(assistant, "tool_calls") || []
        turn_usage = Map.get(assistant, :usage) || Map.get(assistant, "usage") || %{}
        usage = merge_usage(usage, turn_usage)

        if content != "" do
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
          {messages, steering} = drain_steering(messages, steering)

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

  defp empty_usage do
    %{"prompt_tokens" => 0, "completion_tokens" => 0, "total_tokens" => 0}
  end

  defp merge_usage(acc, add) when is_map(acc) and is_map(add) do
    p =
      (acc["prompt_tokens"] || acc[:prompt_tokens] || acc["input_tokens"] || acc[:input_tokens] || 0) +
        (add["prompt_tokens"] || add[:prompt_tokens] || add["input_tokens"] || add[:input_tokens] || 0)

    c =
      (acc["completion_tokens"] || acc[:completion_tokens] || acc["output_tokens"] ||
         acc[:output_tokens] || 0) +
        (add["completion_tokens"] || add[:completion_tokens] || add["output_tokens"] ||
           add[:output_tokens] || 0)

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

    Enum.map_reduce(tool_calls, [], fn call, acc ->
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

      event_fun.({:tool_call_end, %{id: id, name: name, is_error: is_error, text: text}})

      msg = %{
        role: "tool",
        tool_call_id: id,
        name: name,
        content: text,
        is_error: is_error
      }

      {msg, acc ++ [msg]}
    end)
    |> then(fn {tool_msgs, results} -> {tool_msgs, results} end)
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

    # Drop system-less edge: complete_turn sends full message list including system.
    case Arvo.Providers.Completion.complete_turn(messages, tools_spec,
           model: model,
           on_delta: on_delta
         ) do
      {:ok, assistant} ->
        {:ok,
         %{
           role: "assistant",
           content: assistant.content || "",
           tool_calls: assistant.tool_calls || [],
           usage: Map.get(assistant, :usage)
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
