defmodule Arvo.Attention do
  @moduledoc """
  Progressive attention facade: project tool results for model hot context,
  store cold bodies, update warm, return candidate audit events.

  Session is the sole durable audit writer (KTD-E1). This module returns
  typed `{type, fields}` candidates; product path commits them via Session.
  Pure policy lives in `Arvo.Attention.Policy`.
  """

  alias Arvo.Attention.Policy
  alias Arvo.Session.Cold

  @policy_version "1"

  @doc "Stable policy version string for treatment envelope (KTD-T1)."
  def policy_version, do: @policy_version

  @doc """
  Whether progressive attention is enabled (default true).

  Precedence (in-process control wins for tests / CLI configure_headless!):

  1. Application env `:progressive_attention` when set
  2. System env `ARVO_PROGRESSIVE_ATTENTION`
  3. Default `true`

  Harbor/CLI should set Application (via `--attention` / configure) before
  opening a session; ambient shell env alone must not override an explicit
  Application.put_env in tests.
  """
  def enabled? do
    case Application.get_env(:arvo, :progressive_attention) do
      false -> false
      v when v in [0, "0", "false", "off", :off] -> false
      true -> true
      v when v in [1, "1", "true", "on", :on] -> true
      nil -> system_attention_enabled_default()
      _other -> true
    end
  end

  defp system_attention_enabled_default do
    case System.get_env("ARVO_PROGRESSIVE_ATTENTION") do
      v when v in ["0", "false", "off", "OFF"] -> false
      v when v in ["1", "true", "on", "ON"] -> true
      _ -> true
    end
  end

  @doc """
  Normalize Application / system env into treatment mode string `"on"` | `"off"`.

  See `enabled?/0` for precedence (Application over ambient system env).
  """
  def treatment_mode_from_env do
    if enabled?(), do: "on", else: "off"
  end

  @doc """
  Project a tool result for the model message list.

  When treatment is off (or `enabled?` false): identity full-hot projection and
  candidate `full_hot` events with `reason_class=opt_out` when `session_path` is set.

  When on: store cold, decide policy, return stub or full-hot content plus events.

  Context keys:
  - `:session_path` — required for cold when enabled; required for audit candidates
  - `:retention`, `:budgets`, `:current_turn`
  - `:pinned?`
  - `:attention_mode` — `"on"` | `"off"` (session treatment; defaults from enabled?)
  - `:tool_call_id`, `:turn_id`
  - `:path_index` — optional `%{source_path => cold_entry}`
  - `:on_audit` — optional callback for tests; **does not** replace Session writer

  Return map always includes `:events` as `[{type, fields}]` candidates (may be empty).
  """
  def project_tool_result(tool, args, text, is_error?, ctx \\ %{})
      when is_binary(tool) or is_atom(tool) do
    tool = to_string(tool)
    text = to_string(text)
    args = args || %{}
    ctx = ctx || %{}
    session_path = Map.get(ctx, :session_path)
    # Session treatment is authoritative when provided (KTD-T1 metadata wins).
    mode =
      case Map.fetch(ctx, :attention_mode) do
        {:ok, m} -> normalize_mode(m)
        :error -> treatment_mode_from_env()
      end

    cond do
      not is_binary(session_path) ->
        identity_result(text, :no_session, [])

      mode == "off" ->
        opt_out_project(tool, text, ctx)

      true ->
        do_project(tool, args, text, is_error?, ctx)
    end
  end

  @doc """
  Expand cold body into a bounded hot slice.

  Returns `{:ok, text, events}` | `{:error, reason, events}`. Session persists events.
  Actor: :user | :model | :policy.
  """
  def expand(session_path, cold_id, opts \\ [])
      when is_binary(session_path) and is_binary(cold_id) do
    actor = Keyword.get(opts, :actor, :user)
    cap = Keyword.get(opts, :cap_bytes, Policy.default_expand_cap_bytes())
    max_bytes = Keyword.get(opts, :max_bytes, cap)
    tool_call_id = Keyword.get(opts, :tool_call_id)

    base_fields = fn extra ->
      %{"id" => cold_id, "actor" => to_string(actor)}
      |> Map.merge(extra)
      |> maybe_put_tool_call(tool_call_id)
    end

    case Cold.fetch_slice(session_path, cold_id, max_bytes) do
      {:error, :not_found} ->
        events = [
          {:denied_expand,
           base_fields.(%{
             "reason" => "not_found",
             "reason_class" => "not_found"
           })}
        ]

        {:error, :not_found, events}

      {:error, reason} ->
        events = [
          {:denied_expand,
           base_fields.(%{
             "reason" => to_string(reason),
             "reason_class" => Arvo.Session.Audit.normalize_reason_class(reason)
           })}
        ]

        {:error, reason, events}

      {:ok, slice, body_bytes} ->
        case Policy.expand_allowed?(%{
               body_bytes: body_bytes,
               requested_bytes: min(body_bytes, max_bytes),
               cap_bytes: cap
             }) do
          {:deny, reason} ->
            events = [
              {:denied_expand,
               base_fields.(%{
                 "reason" => to_string(reason),
                 "reason_class" => Arvo.Session.Audit.normalize_reason_class(reason),
                 "size" => body_bytes,
                 "cap" => cap
               })}
            ]

            {:error, reason, events}

          {:ok, _} ->
            out =
              if body_bytes <= max_bytes do
                slice
              else
                slice <> "\n[expanded #{byte_size(slice)}/#{body_bytes} bytes; cold:#{cold_id}]"
              end

            events = [
              {:expand,
               base_fields.(%{
                 "size" => byte_size(out),
                 "body_bytes" => body_bytes,
                 "reason_class" => "policy"
               })}
            ]

            {:ok, out, events}
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

  defp opt_out_project(tool, text, ctx) do
    size = byte_size(text)

    events = [
      {:full_hot,
       %{
         "tool" => tool,
         "size" => size,
         "original_bytes" => size,
         "projected_bytes" => size,
         "decision" => "full_hot",
         "reason" => "opt_out",
         "reason_class" => "opt_out",
         "path" => nil,
         "id" => nil
       }}
    ]

    events = maybe_deliver_on_audit(ctx, events)

    %{
      content: text,
      full_text: text,
      action: :full_hot,
      cold_id: nil,
      decision: %{action: :full_hot, size: size, reason: :opt_out},
      retention: Map.get(ctx, :retention) || %{},
      budgets: Map.get(ctx, :budgets) || default_budgets(),
      path_index: Map.get(ctx, :path_index) || %{},
      events: events
    }
  end

  defp identity_result(text, reason, events) do
    %{
      content: text,
      full_text: text,
      action: :full_hot,
      cold_id: nil,
      decision: %{action: :full_hot, size: byte_size(text), reason: reason},
      retention: %{},
      budgets: default_budgets(),
      path_index: %{},
      events: events
    }
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

    # Only demote large/fidelity full-hot re-reads; keep small/error/pin full-hot
    decision =
      if reuse? and decision.action == :full_hot and
           decision.reason in [:size, :fidelity_retention, :exception_budget, :same_path_reuse] do
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

    events = maybe_attach_tool_call(events, Map.get(ctx, :tool_call_id))
    events = maybe_deliver_on_audit(ctx, events)

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
      path_index: path_index,
      events: events
    }
  end

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
      {:reuse_cold,
       with_reason(
         %{
           "id" => cold_id,
           "tool" => tool,
           "size" => decision.size,
           "path" => path
         },
         :same_path_reuse
       )}
    ]

    {cold_id, decision, path_index, events}
  end

  defp store_or_reuse(session_path, text, tool, path, decision, _existing, false, ctx) do
    path_index = Map.get(ctx, :path_index) || %{}
    digest = body_digest(text)

    case Cold.store(session_path, text, %{
           tool: tool,
           kind: "tool_result",
           source_path: path,
           tool_call_id: Map.get(ctx, :tool_call_id),
           preview: decision.preview,
           digest: digest
         }) do
      {:ok, entry} ->
        cold_id = entry["id"]

        path_index =
          if is_binary(path), do: Map.put(path_index, path, entry), else: path_index

        events = [
          {:store_cold,
           %{
             "id" => cold_id,
             "tool" => tool,
             "size" => decision.size,
             "path" => path
           }}
        ]

        {cold_id, decision, path_index, events}

      {:error, reason} ->
        require Logger
        Logger.warning("Arvo.Attention cold store failed: #{inspect(reason)}")

        events = [
          {:store_cold,
           with_reason(
             %{
               "error" => inspect(reason),
               "tool" => tool,
               "size" => decision.size,
               "path" => path
             },
             :cold_store_failed
           )}
        ]

        decision = %{
          decision
          | action: :full_hot,
            reason: :cold_store_failed,
            fidelity_exception: false
        }

        {nil, decision, path_index, events}
    end
  end

  defp project_content(text, tool, decision, cold_id) do
    reason = decision.reason
    size = decision.size

    base =
      with_reason(
        %{
          "tool" => tool,
          "size" => size,
          "path" => decision.path,
          "id" => cold_id,
          "original_bytes" => size
        },
        reason
      )

    case {decision.action, cold_id} do
      {:stub, id} when is_binary(id) ->
        stub = Policy.stub_content(Map.put(decision, :tool, tool), id)

        events = [
          {:stub_in_hot,
           base
           |> Map.put("projected_bytes", byte_size(stub))
           |> Map.put("decision", "stub")}
        ]

        {stub, :stub, events}

      {:stub, _} ->
        {text, :full_hot, []}

      {:full_hot, _id} ->
        events = [
          {:full_hot,
           base
           |> Map.put("projected_bytes", size)
           |> Map.put("decision", "full_hot")}
        ]

        events =
          if decision.fidelity_exception do
            events ++ [{:fidelity_exception, Map.put(base, "decision", "full_hot")}]
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
         with_reason(
           %{
             "path" => path,
             "cold_id" => existing["id"],
             "id" => existing["id"],
             "tool" => tool,
             "size" => existing["size"],
             "path_changed" => path_changed?
           },
           :same_path_reuse
         )}
      ]
    else
      []
    end
  end

  # Optional test hook: deliver candidates without Session ownership.
  # Production Session ignores this and commits result.events itself.
  defp maybe_deliver_on_audit(ctx, events) when is_list(events) do
    case Map.get(ctx, :on_audit) do
      fun when is_function(fun, 1) ->
        fun.(events)
        events

      fun when is_function(fun, 2) ->
        Enum.each(events, fn {type, fields} -> fun.(type, fields) end)
        events

      _ ->
        events
    end
  end

  defp path_changed?(path, text, existing, retention) do
    cond do
      not is_binary(path) ->
        true

      Policy.path_edited?(path, retention) ->
        true

      not is_map(existing) ->
        true

      is_integer(existing["size"]) and existing["size"] != byte_size(text) ->
        true

      is_binary(existing["digest"]) and existing["digest"] != body_digest(text) ->
        true

      # Missing digest on older entries: treat equal size as unchanged only if size matches
      not is_binary(existing["digest"]) and is_integer(existing["size"]) and
          existing["size"] == byte_size(text) ->
        false

      true ->
        false
    end
  end

  defp body_digest(text) when is_binary(text) do
    :crypto.hash(:sha256, text) |> Base.encode16(case: :lower)
  end

  defp with_reason(fields, reason) do
    fields
    |> Map.put("reason", to_string(reason))
    |> Map.put("reason_class", Arvo.Session.Audit.normalize_reason_class(reason))
  end

  defp maybe_attach_tool_call(events, nil), do: events
  defp maybe_attach_tool_call(events, id) when is_binary(id) do
    Enum.map(events, fn {type, fields} ->
      {type, Map.put_new(fields, "tool_call_id", id)}
    end)
  end

  defp maybe_attach_tool_call(events, _), do: events

  defp maybe_put_tool_call(fields, nil), do: fields
  defp maybe_put_tool_call(fields, id) when is_binary(id), do: Map.put(fields, "tool_call_id", id)
  defp maybe_put_tool_call(fields, _), do: fields

  defp normalize_mode(mode) when mode in [false, 0, "0", "off", :off], do: "off"
  defp normalize_mode(mode) when mode in [true, 1, "1", "on", :on], do: "on"
  defp normalize_mode("off"), do: "off"
  defp normalize_mode(_), do: "on"
end
