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
  policy, return stub or full-hot content, and optionally invoke callbacks.

  Options / context map:
  - `:session_path` — required for cold/audit when enabled
  - `:retention`, `:budgets`, `:current_turn`
  - `:pinned?`
  - `:on_audit` — optional `(type, fields) -> any` (defaults to Audit.append)
  - `:on_warm` — optional `(warm_meta) -> any`
  - `:warm` — current warm map (for path reuse signals)
  """
  def project_tool_result(tool, args, text, is_error?, ctx \\ %{})
      when is_binary(tool) or is_atom(tool) do
    tool = to_string(tool)
    text = to_string(text)
    args = args || %{}
    ctx = ctx || %{}

    if not enabled?() or not is_binary(Map.get(ctx, :session_path)) do
      dual_view_event(tool, args, text, is_error?, nil, :full_hot, text)
      %{
        content: text,
        full_text: text,
        action: :full_hot,
        cold_id: nil,
        decision: %{action: :full_hot, size: byte_size(text), reason: :opt_out},
        retention: Map.get(ctx, :retention) || %{},
        budgets: Map.get(ctx, :budgets) || default_budgets(),
        dual_view: %{model: text, human: text}
      }
    else
      do_project(tool, args, text, is_error?, ctx)
    end
  end

  defp do_project(tool, args, text, is_error?, ctx) do
    session_path = Map.fetch!(ctx, :session_path)
    retention = Map.get(ctx, :retention) || %{}
    budgets = Map.get(ctx, :budgets) || default_budgets()
    current_turn = Map.get(ctx, :current_turn) || Map.get(retention, :current_turn) || 0
    path = path_from(tool, args)

    # Same-path re-invoke detection (AE7)
    existing = if is_binary(path), do: Cold.find_by_source_path(session_path, path), else: nil

    if is_map(existing) and tool == "read" and not is_error? do
      audit(session_path, ctx, :same_path_reinvoke, %{
        "path" => path,
        "cold_id" => existing["id"],
        "tool" => tool,
        "size" => existing["size"]
      })
    end

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

    # Prefer not double full-hot when cold already holds unchanged path
    decision =
      if is_map(existing) and tool == "read" and decision.action == :full_hot and
           Policy.same_path_preference(%{
             tool: tool,
             path: path,
             cold_id: existing["id"],
             path_changed?: false
           }) == :prefer_cold_stub do
        %{decision | action: :stub, fidelity_exception: false, reason: :same_path_reuse}
      else
        decision
      end

    {:ok, cold_entry} =
      Cold.store(session_path, text, %{
        tool: tool,
        kind: "tool_result",
        source_path: path,
        tool_call_id: Map.get(ctx, :tool_call_id),
        preview: decision.preview
      })

    cold_id = cold_entry["id"]

    audit(session_path, ctx, :store_cold, %{
      "id" => cold_id,
      "tool" => tool,
      "size" => decision.size,
      "path" => path
    })

    {content, action} =
      case decision.action do
        :stub ->
          audit(session_path, ctx, :stub_in_hot, %{
            "id" => cold_id,
            "tool" => tool,
            "size" => decision.size,
            "path" => path,
            "reason" => to_string(decision.reason)
          })

          {Policy.stub_content(Map.put(decision, :tool, tool), cold_id), :stub}

        :full_hot ->
          audit(session_path, ctx, :full_hot, %{
            "id" => cold_id,
            "tool" => tool,
            "size" => decision.size,
            "path" => path,
            "reason" => to_string(decision.reason)
          })

          if decision.fidelity_exception do
            audit(session_path, ctx, :fidelity_exception, %{
              "id" => cold_id,
              "tool" => tool,
              "size" => decision.size,
              "path" => path,
              "bytes" => decision.size
            })
          end

          {text, :full_hot}

        other ->
          {text, other}
      end

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

    warm_meta = %{
      tool: tool,
      args: args,
      is_error: is_error?,
      text: String.slice(text, 0, 400),
      path: path
    }

    case Map.get(ctx, :on_warm) do
      fun when is_function(fun, 1) -> fun.(warm_meta)
      _ -> :ok
    end

    dual = dual_view_event(tool, args, text, is_error?, cold_id, action, content)

    %{
      content: content,
      full_text: text,
      action: action,
      cold_id: cold_id,
      decision: decision,
      retention: new_retention,
      budgets: new_budgets,
      dual_view: dual
    }
  end

  @doc "Expand cold body into a bounded hot slice. Actor: :user | :model | :policy."
  def expand(session_path, cold_id, opts \\ []) when is_binary(session_path) and is_binary(cold_id) do
    actor = Keyword.get(opts, :actor, :user)
    cap = Keyword.get(opts, :cap_bytes, Policy.default_expand_cap_bytes())
    max_bytes = Keyword.get(opts, :max_bytes, cap)

    case Cold.fetch(session_path, cold_id) do
      {:error, :not_found} ->
        Audit.append(session_path, :denied_expand, %{
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
            Audit.append(session_path, :denied_expand, %{
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

            Audit.append(session_path, :expand, %{
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

  defp audit(session_path, ctx, type, fields) do
    case Map.get(ctx, :on_audit) do
      fun when is_function(fun, 2) -> fun.(type, fields)
      _ -> Audit.append(session_path, type, fields)
    end
  end

  defp dual_view_event(tool, args, full_text, is_error?, cold_id, action, model_content) do
    %{
      tool: tool,
      args: args,
      is_error: is_error?,
      cold_id: cold_id,
      action: action,
      model: model_content,
      human: full_text
    }
  end

  defp path_from(tool, args) when tool in ["read", "edit", "write"] do
    Map.get(args, "path") || Map.get(args, :path)
  end

  defp path_from(_, _), do: nil
end
