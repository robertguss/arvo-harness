defmodule Arvo.Attention do
  @moduledoc """
  Progressive attention facade: project tool results for model hot context,
  store cold bodies, update warm, append audit.

  Session product path and Agent call into this. Pure policy lives in
  `Arvo.Attention.Policy`.
  """

  alias Arvo.Attention.Policy
  alias Arvo.Session.{Audit, Cold}

  @doc "Whether progressive attention is enabled (default true)."
  def enabled? do
    Application.get_env(:arvo, :progressive_attention, true) != false
  end

  @doc """
  Project a tool result for the model message list.

  When disabled, returns full text identity. When enabled: store cold, decide
  policy, return stub or full-hot content.

  Context keys:
  - `:session_path` — required for cold/audit when enabled
  - `:retention`, `:budgets`, `:current_turn`
  - `:pinned?`
  - `:on_audit` — optional `(events) -> any` where events is `[{type, fields}]`
  - `:path_index` — optional `%{source_path => cold_entry}` to avoid index scans
  """
  def project_tool_result(tool, args, text, is_error?, ctx \\ %{})
      when is_binary(tool) or is_atom(tool) do
    tool = to_string(tool)
    text = to_string(text)
    args = args || %{}
    ctx = ctx || %{}

    if not enabled?() or not is_binary(Map.get(ctx, :session_path)) do
      %{
        content: text,
        full_text: text,
        action: :full_hot,
        cold_id: nil,
        decision: %{action: :full_hot, size: byte_size(text), reason: :opt_out},
        retention: Map.get(ctx, :retention) || %{},
        budgets: Map.get(ctx, :budgets) || default_budgets(),
        path_index: Map.get(ctx, :path_index) || %{}
      }
    else
      do_project(tool, args, text, is_error?, ctx)
    end
  end

  defp do_project(tool, args, text, is_error?, ctx) do
    session_path = Map.fetch!(ctx, :session_path)
    retention = Map.get(ctx, :retention) || %{}
    budgets = Map.get(ctx, :budgets) || default_budgets()
    path_index = Map.get(ctx, :path_index) || %{}
    current_turn = Map.get(ctx, :current_turn) || Map.get(retention, :current_turn) || 0
    path = Policy.source_path(tool, args)

    existing = lookup_existing(path, path_index, session_path)
    path_changed? = path_changed?(path, text, existing, retention)
    reuse? = reuse_cold?(tool, is_error?, existing, path_changed?)

    decision =
      Policy.decide(%{
        tool: tool,
        args: args,
        text: text,
        is_error: is_error?,
        pinned?: Map.get(ctx, :pinned?) == true,
        retention: Map.put(retention, :current_turn, current_turn),
        budgets: budgets
      })

    decision =
      if reuse? and decision.action == :full_hot do
        %{decision | action: :stub, fidelity_exception: false, reason: :same_path_reuse}
      else
        decision
      end

    {cold_id, decision, path_index, store_events} =
      store_or_reuse(session_path, text, tool, path, decision, existing, reuse?, ctx)

    {content, action, action_events} =
      project_content(text, tool, decision, cold_id)

    events =
      maybe_reinvoke_event(tool, is_error?, existing, path, path_changed?) ++
        store_events ++ action_events

    flush_audit(session_path, ctx, events)

    new_retention =
      Policy.update_retention(retention, tool, path, Map.put(decision, :is_error, is_error?), current_turn)

    new_budgets =
      if decision.fidelity_exception and action == :full_hot do
        budgets
        |> Map.update(:exception_bytes, decision.size, &(&1 + decision.size))
        |> Map.update(:exception_count, 1, &(&1 + 1))
      else
        budgets
      end

    %{
      content: content,
      full_text: text,
      action: action,
      cold_id: cold_id,
      decision: decision,
      retention: new_retention,
      budgets: new_budgets,
      path_index: path_index
    }
  end

  @doc "Expand cold body into a bounded hot slice. Actor: :user | :model | :policy."
  def expand(session_path, cold_id, opts \\ []) when is_binary(session_path) and is_binary(cold_id) do
    actor = Keyword.get(opts, :actor, :user)
    cap = Keyword.get(opts, :cap_bytes, Policy.default_expand_cap_bytes())
    max_bytes = Keyword.get(opts, :max_bytes, cap)

    case Cold.fetch(session_path, cold_id) do
      {:error, :not_found} ->
        _ = Audit.append(session_path, :denied_expand, %{
          "id" => cold_id,
          "actor" => to_string(actor),
          "reason" => "not_found"
        })

        {:error, :not_found}

      {:ok, body} ->
        case Policy.expand_allowed?(%{
               body_bytes: byte_size(body),
               requested_bytes: min(byte_size(body), max_bytes),
               cap_bytes: cap
             }) do
          {:deny, reason} ->
            _ = Audit.append(session_path, :denied_expand, %{
              "id" => cold_id,
              "actor" => to_string(actor),
              "reason" => to_string(reason),
              "size" => byte_size(body),
              "cap" => cap
            })

            {:error, reason}

          {:ok, _} ->
            slice =
              if byte_size(body) <= max_bytes do
                body
              else
                binary_part(body, 0, max_bytes) <>
                  "\n[expanded #{max_bytes}/#{byte_size(body)} bytes; cold:#{cold_id}]"
              end

            _ = Audit.append(session_path, :expand, %{
              "id" => cold_id,
              "actor" => to_string(actor),
              "size" => byte_size(slice),
              "body_bytes" => byte_size(body)
            })

            {:ok, slice}
        end
    end
  end

  def default_budgets do
    %{
      exception_bytes: 0,
      exception_count: 0,
      max_exception_bytes: Policy.default_max_exception_bytes(),
      max_exception_count: Policy.default_max_exception_count()
    }
  end

  # --- internals ---

  defp lookup_existing(path, path_index, session_path) do
    cond do
      not is_binary(path) ->
        nil

      is_map(path_index) and Map.has_key?(path_index, path) ->
        path_index[path]

      true ->
        Cold.find_by_source_path(session_path, path)
    end
  end

  defp reuse_cold?(tool, is_error?, existing, path_changed?) do
    tool == "read" and not is_error? and is_map(existing) and
      Policy.same_path_preference(%{
        cold_id: existing["id"],
        path_changed?: path_changed?
      }) == :prefer_cold_stub
  end

  defp store_or_reuse(_session_path, _text, tool, path, decision, existing, true, ctx)
       when is_map(existing) do
    cold_id = existing["id"]
    path_index = Map.get(ctx, :path_index) || %{}
    path_index = if is_binary(path), do: Map.put(path_index, path, existing), else: path_index

    events = [
      {:store_cold,
       %{
         "id" => cold_id,
         "tool" => tool,
         "size" => decision.size,
         "path" => path,
         "reused" => true
       }}
    ]

    {cold_id, decision, path_index, events}
  end

  defp store_or_reuse(session_path, text, tool, path, decision, _existing, false, ctx) do
    path_index = Map.get(ctx, :path_index) || %{}

    case Cold.store(session_path, text, %{
           tool: tool,
           kind: "tool_result",
           source_path: path,
           tool_call_id: Map.get(ctx, :tool_call_id),
           preview: decision.preview
         }) do
      {:ok, entry} ->
        cold_id = entry["id"]

        path_index =
          if is_binary(path), do: Map.put(path_index, path, entry), else: path_index

        events = [
          {:store_cold, %{"id" => cold_id, "tool" => tool, "size" => decision.size, "path" => path}}
        ]

        {cold_id, decision, path_index, events}

      {:error, reason} ->
        # Fail open to full-hot so Session stays up; single store_cold audit
        events = [
          {:store_cold,
           %{
             "error" => inspect(reason),
             "tool" => tool,
             "size" => decision.size,
             "path" => path
           }}
        ]

        decision = %{decision | action: :full_hot, reason: :cold_store_failed, fidelity_exception: false}
        {nil, decision, path_index, events}
    end
  end

  defp project_content(text, tool, decision, cold_id) do
    base = %{"tool" => tool, "size" => decision.size, "path" => decision.path, "id" => cold_id}

    case {decision.action, cold_id} do
      {:stub, id} when is_binary(id) ->
        events = [
          {:stub_in_hot, Map.put(base, "reason", to_string(decision.reason))}
        ]

        {Policy.stub_content(Map.put(decision, :tool, tool), id), :stub, events}

      {:stub, _} ->
        {text, :full_hot, []}

      {:full_hot, _id} ->
        events = [
          {:full_hot, Map.put(base, "reason", to_string(decision.reason))}
        ]

        events =
          if decision.fidelity_exception do
            events ++ [{:fidelity_exception, base}]
          else
            events
          end

        {text, :full_hot, events}

      {other, _} ->
        {text, other, []}
    end
  end

  defp maybe_reinvoke_event(tool, is_error?, existing, path, path_changed?) do
    if is_map(existing) and tool == "read" and not is_error? do
      [
        {:same_path_reinvoke,
         %{
           "path" => path,
           "cold_id" => existing["id"],
           "tool" => tool,
           "size" => existing["size"],
           "path_changed" => path_changed?
         }}
      ]
    else
      []
    end
  end

  defp flush_audit(session_path, ctx, events) when is_list(events) do
    case Map.get(ctx, :on_audit) do
      fun when is_function(fun, 1) ->
        fun.(events)

      fun when is_function(fun, 2) ->
        Enum.each(events, fn {type, fields} -> fun.(type, fields) end)

      _ ->
        _ = Audit.append_many(session_path, events)
    end
  end

  defp path_changed?(path, text, existing, retention) do
    cond do
      not is_binary(path) -> true
      Policy.path_edited?(path, retention) -> true
      not is_map(existing) -> true
      is_integer(existing["size"]) and existing["size"] != byte_size(text) -> true
      true -> false
    end
  end
end
