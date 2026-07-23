defmodule Arvo.Providers.Completion do
  @moduledoc """
  Chat + streamed completion via req_llm / api.x.ai (core speaks req_llm types — ADR-0002).
  """

  @doc """
  Stream a completion for `prompt`. Returns `{:ok, full_text}` or `{:error, reason}`.
  Length/context errors surface `Arvo.Session.Compaction.length_error_message/0`.
  """
  def stream_text(prompt, opts \\ []) when is_binary(prompt) do
    model = Keyword.get(opts, :model) || default_model()
    on_delta = Keyword.get(opts, :on_delta, fn _ -> :ok end)
    provider = Keyword.get(opts, :provider, "grok")

    Arvo.Auth.TokenManager.with_bearer(provider, fn bearer ->
      do_stream(prompt, model, bearer, on_delta)
    end)
  end

  @doc """
  One agent-turn completion: messages + tool specs → assistant message with optional tool_calls.

  Returns `{:ok, %{role, content, tool_calls, usage}}` or `{:error, reason}`.
  """
  def complete_turn(messages, tools_spec, opts \\ []) when is_list(messages) do
    model = Keyword.get(opts, :model) || default_model()
    provider = Keyword.get(opts, :provider, "grok")
    on_delta = Keyword.get(opts, :on_delta, fn _ -> :ok end)

    Arvo.Auth.TokenManager.with_bearer(provider, fn bearer ->
      chat_via_http(messages, tools_spec, model, bearer, on_delta)
    end)
  end

  defp do_stream(prompt, model, bearer, on_delta) do
    messages = [%{role: "user", content: prompt}]

    case chat_via_http(messages, [], model, bearer, on_delta) do
      {:ok, %{content: text}} -> {:ok, text}
      {:error, _} = err -> err
    end
  end

  defp chat_via_http(messages, tools_spec, model, bearer, on_delta) do
    model_id = strip_prefix(model)
    url = "https://api.x.ai/v1/chat/completions"

    api_messages = Enum.map(messages, &normalize_message/1)

    body =
      %{
        "model" => model_id,
        "stream" => false,
        "messages" => api_messages
      }
      |> maybe_put_tools(tools_spec)

    case Req.post(url,
           auth: {:bearer, bearer},
           json: body,
           receive_timeout: 120_000
         ) do
      {:ok, %Req.Response{status: 401}} ->
        {:error, :unauthorized}

      {:ok, %Req.Response{status: status, body: resp}} when status >= 400 ->
        {:error, classify_http_error(status, resp)}

      {:ok, %Req.Response{status: status, body: resp}} when status in 200..299 ->
        parse_chat_response(resp, on_delta)

      {:error, reason} ->
        if unauthorized?(reason), do: {:error, :unauthorized}, else: {:error, inspect(reason)}
    end
  rescue
    e ->
      msg = Exception.message(e)
      if unauthorized?(msg), do: {:error, :unauthorized}, else: {:error, msg}
  end

  defp maybe_put_tools(body, []), do: body
  defp maybe_put_tools(body, nil), do: body

  defp maybe_put_tools(body, tools_spec) when is_list(tools_spec) do
    tools =
      Enum.map(tools_spec, fn spec ->
        name = spec[:name] || spec["name"]
        desc = spec[:description] || spec["description"]
        params = spec[:parameters] || spec["parameters"] || %{}

        %{
          "type" => "function",
          "function" => %{
            "name" => name,
            "description" => desc,
            "parameters" => params
          }
        }
      end)

    body
    |> Map.put("tools", tools)
    |> Map.put("tool_choice", "auto")
  end

  defp normalize_message(m) do
    role = to_string(m[:role] || m["role"] || "user")
    content = m[:content] || m["content"] || ""

    base = %{"role" => role, "content" => content}

    base =
      case m[:tool_calls] || m["tool_calls"] do
        nil -> base
        [] -> base
        tcs -> Map.put(base, "tool_calls", Enum.map(tcs, &normalize_tool_call/1))
      end

    case m[:tool_call_id] || m["tool_call_id"] do
      nil -> base
      id -> Map.put(base, "tool_call_id", id)
    end
  end

  defp normalize_tool_call(tc) do
    id = tc[:id] || tc["id"]
    name = tc[:name] || tc["name"]
    args = tc[:arguments] || tc["arguments"] || %{}

    args_json = if is_binary(args), do: args, else: Jason.encode!(args)

    %{
      "id" => id,
      "type" => "function",
      "function" => %{"name" => name, "arguments" => args_json}
    }
  end

  defp parse_chat_response(resp, on_delta) when is_map(resp) do
    choice = get_in(resp, ["choices", Access.at(0)]) || %{}
    message = choice["message"] || %{}
    content = message["content"] || ""

    if content != "" and is_function(on_delta, 1) do
      on_delta.(content)
    end

    tool_calls =
      (message["tool_calls"] || [])
      |> Enum.map(fn tc ->
        fn_ = tc["function"] || %{}
        args = fn_["arguments"] || "{}"

        args_map =
          cond do
            is_map(args) -> args
            is_binary(args) ->
              case Jason.decode(args) do
                {:ok, m} -> m
                _ -> %{}
              end

            true ->
              %{}
          end

        %{
          id: tc["id"],
          name: fn_["name"],
          arguments: args_map
        }
      end)

    usage = resp["usage"] || %{}

    {:ok,
     %{
       role: "assistant",
       content: content,
       tool_calls: tool_calls,
       usage: usage
     }}
  end

  defp parse_chat_response(resp, on_delta) when is_binary(resp) do
    case Jason.decode(resp) do
      {:ok, map} -> parse_chat_response(map, on_delta)
      _ -> {:error, "invalid completion response"}
    end
  end

  defp parse_chat_response(_, _), do: {:error, "invalid completion response"}

  defp classify_http_error(status, body) do
    text =
      cond do
        is_map(body) -> Jason.encode!(body)
        is_binary(body) -> body
        true -> inspect(body)
      end

    if length_error?(status, text) do
      Arvo.Session.Compaction.length_error_message()
    else
      "completion HTTP #{status}: #{String.slice(text, 0, 300)}"
    end
  end

  defp length_error?(status, text) do
    down = String.downcase(to_string(text))

    status == 400 and
      (String.contains?(down, "context length") or
         String.contains?(down, "maximum context") or
         String.contains?(down, "too many tokens") or
         String.contains?(down, "token limit") or
         String.contains?(down, "\"length\"") or
         String.contains?(down, "context_length") or
         String.contains?(down, "max_tokens"))
  end

  defp strip_prefix("xai:" <> rest), do: rest
  defp strip_prefix(model), do: model

  defp default_model do
    cfg = Application.get_env(:arvo, :config) || %{}
    Map.get(cfg, :default_model) || "xai:grok-4.5"
  end

  defp unauthorized?(reason) do
    s = if is_binary(reason), do: reason, else: inspect(reason)
    String.contains?(s, "401") or String.contains?(String.downcase(s), "unauthorized")
  end
end
