defmodule Arvo.Providers.Completion do
  @moduledoc """
  Chat + streamed completion via xAI chat completions (ADR-0002 types surface).

  Product path uses SSE (`stream: true`) with incremental `on_delta` text chunks.
  Tool calls are assembled fully before return (no incremental tool-arg stream in D1).
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
      do_stream(prompt, model, bearer, on_delta, opts)
    end)
  end

  @doc """
  One agent-turn completion: messages + tool specs → assistant message with optional tool_calls.

  Streams text deltas via `on_delta`. Returns
  `{:ok, %{role, content, tool_calls, usage, streamed?}}` or `{:error, reason}`.
  """
  def complete_turn(messages, tools_spec, opts \\ []) when is_list(messages) do
    model = Keyword.get(opts, :model) || default_model()
    provider = Keyword.get(opts, :provider, "grok")
    on_delta = Keyword.get(opts, :on_delta, fn _ -> :ok end)

    # Injected stream bodies skip network/auth (unit tests)
    if Keyword.has_key?(opts, :stream_body) do
      chat_via_http(messages, tools_spec, model, "test-token", on_delta, opts)
    else
      Arvo.Auth.TokenManager.with_bearer(provider, fn bearer ->
        chat_via_http(messages, tools_spec, model, bearer, on_delta, opts)
      end)
    end
  end

  @doc """
  Parse OpenAI-compatible SSE chat stream body into content, tool_calls, usage.

  Calls `on_delta.(chunk)` for each non-empty text delta. Used by the live path
  and unit tests (no network).
  """
  def parse_sse_stream(body, on_delta \\ fn _ -> :ok end) when is_binary(body) do
    acc = feed_sse_chunk(empty_sse_acc(), body <> "\n", on_delta)

    if acc.events == 0 and acc.decode_fails > 0 do
      {:error, "corrupt SSE stream (no valid events)"}
    else
      {:ok, finalize_sse_acc(acc)}
    end
  end

  @doc false
  def length_error_signal?(reason) when is_binary(reason) do
    reason == Arvo.Session.Compaction.length_error_message() or
      length_error?(400, reason)
  end

  def length_error_signal?(_), do: false

  defp do_stream(prompt, model, bearer, on_delta, opts) do
    messages = [%{role: "user", content: prompt}]

    case chat_via_http(messages, [], model, bearer, on_delta, opts) do
      {:ok, %{content: text}} -> {:ok, text}
      {:error, _} = err -> err
    end
  end

  defp chat_via_http(messages, tools_spec, model, bearer, on_delta, opts) do
    model_id = strip_prefix(model)
    url = chat_completions_url(Keyword.get(opts, :provider, "grok"), opts)

    api_messages = Enum.map(messages, &normalize_message/1)

    body =
      %{
        "model" => model_id,
        "stream" => true,
        "stream_options" => %{"include_usage" => true},
        "messages" => api_messages
      }
      |> maybe_put_tools(tools_spec)

    # Test/inject seam: bypass network
    case Keyword.get(opts, :stream_body) do
      body_bin when is_binary(body_bin) ->
        parse_sse_stream(body_bin, on_delta)

      fun when is_function(fun, 0) ->
        parse_sse_stream(fun.(), on_delta)

      nil ->
        request_sse(url, bearer, body, on_delta, opts)
    end
  rescue
    e ->
      msg = Exception.message(e)
      if unauthorized?(msg), do: {:error, :unauthorized}, else: {:error, msg}
  end

  defp request_sse(url, bearer, body, on_delta, opts) do
    http_fun = Keyword.get(opts, :http_fun) || (&default_http_stream/4)

    case arity_http(http_fun, url, bearer, body, on_delta) do
      {:ok, %{status: 401}} ->
        {:error, :unauthorized}

      {:ok, %{status: status, body: resp}} when status >= 400 ->
        {:error, classify_http_error(status, resp)}

      # Incremental stream already invoked on_delta; return assembled message
      {:ok, %{status: status, parsed: parsed}} when status in 200..299 and is_map(parsed) ->
        {:ok, parsed}

      {:ok, %{status: status, body: resp}} when status in 200..299 ->
        cond do
          is_binary(resp) and String.contains?(resp, "data:") ->
            parse_sse_stream(resp, on_delta)

          is_map(resp) ->
            # Non-stream fallback (some mocks)
            parse_chat_response(resp, on_delta)

          is_binary(resp) ->
            case Jason.decode(resp) do
              {:ok, map} -> parse_chat_response(map, on_delta)
              _ -> parse_sse_stream(resp, on_delta)
            end

          true ->
            {:error, "invalid completion response"}
        end

      {:error, reason} ->
        if unauthorized?(reason), do: {:error, :unauthorized}, else: {:error, inspect(reason)}
    end
  end

  # Support both legacy 3-arity test injectors and 4-arity streaming default
  defp arity_http(fun, url, bearer, body, on_delta) do
    case :erlang.fun_info(fun, :arity) do
      {:arity, 4} -> fun.(url, bearer, body, on_delta)
      {:arity, 3} -> fun.(url, bearer, body)
      _ -> fun.(url, bearer, body)
    end
  end

  @doc false
  # Req 0.5+/0.6 options: connect timeout lives under :connect_options, not :connect_timeout.
  def stream_req_options(opts \\ []) do
    [
      receive_timeout: Keyword.get(opts, :receive_timeout, 120_000),
      connect_options: Keyword.get(opts, :connect_options, timeout: 30_000),
      decode_body: false
    ]
  end

  @doc false
  def default_http_stream(url, bearer, body, on_delta \\ fn _ -> :ok end) do
    case Req.post(
           url,
           [
             auth: {:bearer, bearer},
             json: body,
             into: fn
               {:data, chunk}, {req, resp} when is_binary(chunk) ->
                 acc = if is_map(resp.body), do: resp.body, else: empty_sse_acc()
                 acc = feed_sse_chunk(acc, chunk, on_delta)
                 {:cont, {req, %{resp | body: acc}}}

               _other, acc ->
                 {:cont, acc}
             end
           ] ++ stream_req_options()
         ) do
      {:ok, %Req.Response{status: status, body: acc}} when is_map(acc) ->
        parsed = finalize_sse_acc(acc)

        cond do
          status >= 400 ->
            # Keep a short error tail for classify_http_error callers
            {:ok, %{status: status, body: acc.error_tail || ""}}

          acc.events == 0 and acc.decode_fails > 0 ->
            {:error, "corrupt SSE stream (no valid events)"}

          parsed.content == "" and parsed.tool_calls == [] and acc.decode_fails > 0 ->
            {:error, "corrupt SSE stream (decode failures, empty assistant)"}

          true ->
            {:ok, %{status: status, parsed: parsed}}
        end

      {:ok, %Req.Response{status: status, body: resp_body}} ->
        text =
          cond do
            is_binary(resp_body) -> resp_body
            is_list(resp_body) -> IO.iodata_to_binary(resp_body)
            true -> inspect(resp_body)
          end

        {:ok, %{status: status, body: text}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp empty_sse_acc do
    %{
      line_buf: "",
      # Prepended then reversed (O(1) per token delta)
      content_parts: [],
      thinking_parts: [],
      tools: %{},
      usage: %{},
      decode_fails: 0,
      events: 0,
      # Only retained for HTTP error responses
      error_tail: ""
    }
  end

  defp finalize_sse_acc(acc) do
    thinking = acc.thinking_parts |> Enum.reverse() |> IO.iodata_to_binary()

    base = %{
      role: "assistant",
      content: acc.content_parts |> Enum.reverse() |> IO.iodata_to_binary(),
      tool_calls: finalize_tool_calls(acc.tools),
      usage: acc.usage,
      streamed?: true
    }

    if thinking == "" do
      base
    else
      Map.put(base, :thinking, thinking)
    end
  end

  defp feed_sse_chunk(acc, chunk, on_delta) do
    buf = acc.line_buf <> chunk
    lines = String.split(buf, "\n")
    {complete, rest} = Enum.split(lines, -1)
    # Keep a short tail for 4xx bodies (not full success stream)
    tail = binary_slice_tail(acc.error_tail <> chunk, 4000)

    Enum.reduce(complete, %{acc | line_buf: List.first(rest) || "", error_tail: tail}, fn line, a ->
      line = String.trim_trailing(line, "\r") |> String.trim()

      cond do
        line == "" ->
          a

        String.starts_with?(line, "data:") ->
          data = line |> String.trim_leading("data:") |> String.trim()

          if data == "[DONE]" do
            a
          else
            case Jason.decode(data) do
              {:ok, map} ->
                apply_sse_event(a, map, on_delta)

              _ ->
                %{a | decode_fails: a.decode_fails + 1}
            end
          end

        true ->
          a
      end
    end)
  end

  defp apply_sse_event(acc, event, on_delta) when is_map(event) do
    usage2 = Map.merge(acc.usage, event["usage"] || %{})
    choice = get_in(event, ["choices", Access.at(0)]) || %{}
    delta = choice["delta"] || %{}
    message = choice["message"] || %{}

    thinking_parts =
      case extract_thinking(delta) || extract_thinking(message) do
        t when is_binary(t) and t != "" ->
          emit_delta(on_delta, :thinking, t)
          [t | acc.thinking_parts]

        _ ->
          acc.thinking_parts
      end

    {parts, tools} =
      case delta["content"] do
        t when is_binary(t) and t != "" ->
          emit_delta(on_delta, :text, t)
          {[t | acc.content_parts], acc.tools}

        _ ->
          {acc.content_parts, acc.tools}
      end

    tools =
      case delta["tool_calls"] do
        list when is_list(list) -> merge_tool_deltas(tools, list)
        _ -> tools
      end

    {parts, tools} =
      case message["content"] do
        t when is_binary(t) and t != "" and parts == [] ->
          emit_delta(on_delta, :text, t)
          {[t | parts], tools}

        _ ->
          {parts, tools}
      end

    %{
      acc
      | content_parts: parts,
        thinking_parts: thinking_parts,
        tools: tools,
        usage: usage2,
        events: acc.events + 1
    }
  end

  # xAI / OpenAI-compatible reasoning fields (defensive multi-key).
  defp extract_thinking(map) when is_map(map) do
    cond do
      is_binary(map["reasoning_content"]) and map["reasoning_content"] != "" ->
        map["reasoning_content"]

      is_binary(map["reasoning"]) and map["reasoning"] != "" ->
        map["reasoning"]

      is_binary(map["thinking"]) and map["thinking"] != "" ->
        map["thinking"]

      is_map(map["reasoning"]) and is_binary(map["reasoning"]["content"]) ->
        map["reasoning"]["content"]

      true ->
        nil
    end
  end

  defp extract_thinking(_), do: nil

  # Tagged deltas: `{:text, t}` | `{:thinking, t}`. Callers may also accept bare binaries.
  defp emit_delta(on_delta, kind, text) when is_function(on_delta, 1) and is_binary(text) do
    on_delta.({kind, text})
  rescue
    FunctionClauseError ->
      if kind == :text, do: on_delta.(text), else: :ok
  end

  defp emit_delta(_, _, _), do: :ok

  defp binary_slice_tail(bin, max) when is_binary(bin) and is_integer(max) do
    if byte_size(bin) <= max, do: bin, else: binary_part(bin, byte_size(bin) - max, max)
  end

  defp chat_completions_url(provider, opts) do
    case Keyword.get(opts, :base_url) do
      url when is_binary(url) ->
        String.trim_trailing(url, "/") <> "/chat/completions"

      _ ->
        base =
          case Arvo.Providers.Registry.get(provider) do
            %{base_url: b} when is_binary(b) -> b
            _ -> "https://api.x.ai/v1"
          end

        String.trim_trailing(base, "/") <> "/chat/completions"
    end
  end

  defp merge_tool_deltas(acc, deltas) do
    Enum.reduce(deltas, acc, fn tc, map ->
      idx = tc["index"] || 0
      prev = Map.get(map, idx, %{"id" => nil, "name" => "", "arguments" => ""})
      fn_ = tc["function"] || %{}

      updated = %{
        "id" => tc["id"] || prev["id"],
        "name" => fn_["name"] || prev["name"] || "",
        "arguments" => (prev["arguments"] || "") <> (fn_["arguments"] || "")
      }

      Map.put(map, idx, updated)
    end)
  end

  defp finalize_tool_calls(acc) when map_size(acc) == 0, do: []

  defp finalize_tool_calls(acc) do
    acc
    |> Enum.sort_by(fn {idx, _} -> idx end)
    |> Enum.map(fn {_idx, tc} ->
      args = tc["arguments"] || "{}"

      args_map =
        cond do
          is_map(args) ->
            args

          is_binary(args) and args != "" ->
            case Jason.decode(args) do
              {:ok, m} when is_map(m) -> m
              _ -> %{}
            end

          true ->
            %{}
        end

      %{
        id: tc["id"] || "call_#{System.unique_integer([:positive])}",
        name: tc["name"],
        arguments: args_map
      }
    end)
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

  # Non-stream JSON response path (mocks / fallback)
  defp parse_chat_response(resp, on_delta) when is_map(resp) do
    choice = get_in(resp, ["choices", Access.at(0)]) || %{}
    message = choice["message"] || %{}
    content = message["content"] || ""

    if content != "" and is_function(on_delta, 1) do
      emit_delta(on_delta, :text, content)
    end

    tool_calls =
      (message["tool_calls"] || [])
      |> Enum.map(fn tc ->
        fn_ = tc["function"] || %{}
        args = fn_["arguments"] || "{}"

        args_map =
          cond do
            is_map(args) ->
              args

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
       usage: usage,
       streamed?: false
     }}
  end

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
