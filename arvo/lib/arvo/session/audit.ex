defmodule Arvo.Session.Audit do
  @moduledoc """
  Append-only progressive-attention audit trail beside the open session.

  Events for Rob, tests, and evals — not bulk-injected into model context.

  Envelope (KTD-E1): every attention-related line carries schema_version, event_id,
  type, at, session_id, sequence, attention_mode, policy_version, committed, and
  type-specific payload fields. Session is the sole durable writer; Attention
  returns candidate `{type, fields}` tuples.
  """

  @schema_version 1

  @reason_classes ~w(
    opt_out small size pinned error fidelity_retention exception_budget
    same_path_reuse cold_store_failed not_found cap_exceeded denied capped
    policy unknown treatment_off no_session
  )

  @doc "Audit JSONL path for a session file."
  def path(session_path) when is_binary(session_path) do
    Path.rootname(session_path) <> ".audit.jsonl"
  end

  def schema_version, do: @schema_version

  @doc """
  Append one audit event. `type` is an atom or string.
  Optional `envelope_ctx` supplies session identity / treatment / sequence_start.
  """
  def append(session_path, type, fields \\ %{}, envelope_ctx \\ %{})
      when is_binary(session_path) and is_map(fields) and is_map(envelope_ctx) do
    case append_many(session_path, [{type, fields}], envelope_ctx) do
      {:ok, [event]} -> {:ok, event}
      {:ok, []} -> {:error, :empty}
      {:error, _} = err -> err
    end
  end

  @doc """
  Append several events in one file write (preserves order).

  `envelope_ctx` keys (all optional for legacy callers):
  - `:session_id` / `"session_id"`
  - `:sequence` / `"sequence"` — last used sequence; next event gets +1
  - `:attention_mode`, `:policy_version`, `:turn_id`, `:tool_call_id`
  - `:committed` default `"committed"`
  """
  def append_many(session_path, events, envelope_ctx \\ %{})
      when is_binary(session_path) and is_list(events) and is_map(envelope_ctx) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()
    seq0 = envelope_get(envelope_ctx, :sequence) || 0
    seq0 = if is_integer(seq0), do: seq0, else: 0

    {written, _next_seq} =
      Enum.map_reduce(events, seq0, fn item, seq ->
        {type, fields} = normalize_event_item(item)
        seq = seq + 1
        event = wrap_event(type, fields, envelope_ctx, seq, now)
        {event, seq}
      end)

    if written == [] do
      {:ok, []}
    else
      body = Enum.map_join(written, "", & (Jason.encode!(&1) <> "\n"))
      File.write!(path(session_path), body, [:append])
      {:ok, written}
    end
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc "Wrap a candidate event with the durable envelope (no I/O)."
  def wrap_event(type, fields, envelope_ctx, sequence, at \\ nil)
      when is_map(fields) and is_map(envelope_ctx) and is_integer(sequence) do
    now = at || (DateTime.utc_now() |> DateTime.to_iso8601())
    fields = Arvo.Session.Store.stringify_keys(fields)

    reason_raw = fields["reason"] || fields["reason_class"]
    reason_class = normalize_reason_class(reason_raw)

    base = %{
      "schema_version" => @schema_version,
      "event_id" => new_event_id(),
      "type" => to_string(type),
      "at" => Map.get(fields, "at") || now,
      "session_id" => envelope_get(envelope_ctx, :session_id),
      "sequence" => sequence,
      "attention_mode" => normalize_mode(envelope_get(envelope_ctx, :attention_mode)),
      "policy_version" =>
        to_string(
          envelope_get(envelope_ctx, :policy_version) ||
            fields["policy_version"] ||
            "1"
        ),
      "committed" =>
        to_string(
          envelope_get(envelope_ctx, :committed) ||
            fields["committed"] ||
            "committed"
        )
    }

    optional =
      %{}
      |> maybe_put("turn_id", envelope_get(envelope_ctx, :turn_id) || fields["turn_id"])
      |> maybe_put(
        "tool_call_id",
        envelope_get(envelope_ctx, :tool_call_id) || fields["tool_call_id"]
      )

    fields =
      fields
      |> Map.drop(["type", "at", "schema_version", "event_id", "sequence", "session_id"])
      |> then(fn f ->
        if reason_class, do: Map.put(f, "reason_class", reason_class), else: f
      end)

    base
    |> Map.merge(optional)
    |> Map.merge(fields)
  end

  @doc "Map free-form / atom reasons into the locked reason_class enum."
  def normalize_reason_class(nil), do: nil

  def normalize_reason_class(reason) do
    s =
      reason
      |> to_string()
      |> String.trim()
      |> String.downcase()
      |> String.replace("-", "_")

    mapped =
      case s do
        "over_cap" -> "cap_exceeded"
        "treatment_off" -> "opt_out"
        "optout" -> "opt_out"
        other -> other
      end

    if mapped in @reason_classes, do: mapped, else: "unknown"
  end

  @doc "Read all audit events for a session."
  def list(session_path) when is_binary(session_path) do
    Arvo.Session.Store.read_all(path(session_path))
  end

  @doc """
  Aggregate counters from audit events for tests/evals.

  Counts **committed** events only (`committed` missing treated as committed for
  legacy lines). Residual re-expand join keys are placeholders until U6.
  """
  def metrics(session_path) when is_binary(session_path) do
    metrics_from_events(list(session_path))
  end

  def metrics_from_events(events) when is_list(events) do
    base =
      Enum.reduce(events, empty_metrics(), fn e, acc ->
        if committed?(e) do
          reduce_metric(e, acc)
        else
          acc
        end
      end)

    # Residual placeholders (U6 join may refine); zero-cost stubs for ship formulas
    Map.merge(base, reexpand_placeholders(events))
  end

  def empty_metrics do
    %{
      store_cold: 0,
      reuse_cold: 0,
      stub_in_hot: 0,
      full_hot: 0,
      full_ingest_bytes: 0,
      stub_bytes: 0,
      fidelity_exception: 0,
      fidelity_exception_bytes: 0,
      warm_update: 0,
      expand: 0,
      same_path_reinvoke: 0,
      denied_expand: 0,
      session_treatment: 0,
      attention_audit_error: 0,
      # Residual U6 symbols (placeholders; reexpand_placeholders may fill)
      n_reexpand: 0,
      b_reexpand: 0
    }
  end

  # --- Honesty / ship metric helpers (pure over event lists; KTD-M1 fixtures) ---

  @doc """
  Honesty on: treatment=on AND ≥1 projection/access event when tool_results_n > 0.
  """
  def honesty_on?(events, tool_results_n) when is_list(events) and is_integer(tool_results_n) do
    mode = treatment_mode(events)

    cond do
      mode != "on" ->
        false

      tool_results_n <= 0 ->
        true

      true ->
        Enum.any?(events, &projection_or_access?/1)
    end
  end

  @doc """
  Honesty off: treatment=off AND session_treatment present AND ≥1 full_hot/projection
  when tool_results_n > 0.
  """
  def honesty_off?(events, tool_results_n) when is_list(events) and is_integer(tool_results_n) do
    mode = treatment_mode(events)
    has_treatment? = Enum.any?(events, &(&1["type"] == "session_treatment"))

    cond do
      mode != "off" ->
        false

      not has_treatment? ->
        false

      tool_results_n <= 0 ->
        true

      true ->
        Enum.any?(events, fn e ->
          e["type"] in ["full_hot", "attention_projection"] and committed?(e)
        end)
    end
  end

  @doc "waste_ratio = B_full_on / max(B_full_off, 1)."
  def waste_ratio(b_full_on, b_full_off)
      when is_integer(b_full_on) and is_integer(b_full_off) do
    b_full_on / max(b_full_off, 1)
  end

  @doc """
  Stranding candidate (ship class, non-causal-complete):

  task_ok == false AND stub hides required fact AND recovery available
  AND no successful model expand for that cold_id.
  """
  def stranding_candidate?(events, opts) when is_list(events) and is_list(opts) do
    task_ok? = Keyword.get(opts, :task_ok, true)
    cold_id = Keyword.get(opts, :cold_id)
    recovery_available? = Keyword.get(opts, :recovery_available, true)
    hides_fact? = Keyword.get(opts, :hides_required_fact, true)

    cond do
      task_ok? ->
        false

      not recovery_available? ->
        false

      not hides_fact? ->
        false

      not is_binary(cold_id) ->
        false

      not Enum.any?(events, fn e ->
            e["type"] == "stub_in_hot" and committed?(e) and
              (e["id"] == cold_id or e["cold_id"] == cold_id)
          end) ->
        false

      true ->
        model_expand_ok? =
          Enum.any?(events, fn e ->
            e["type"] == "expand" and committed?(e) and
              (e["id"] == cold_id or e["cold_id"] == cold_id) and
              to_string(e["actor"] || "") == "model"
          end)

        not model_expand_ok?
    end
  end

  def treatment_mode(events) when is_list(events) do
    case Enum.find(events, &(&1["type"] == "session_treatment")) do
      %{"attention_mode" => mode} when is_binary(mode) -> normalize_mode(mode)
      _ ->
        case Enum.find(events, &is_binary(&1["attention_mode"])) do
          %{"attention_mode" => mode} -> normalize_mode(mode)
          _ -> nil
        end
    end
  end

  # --- internals ---

  defp reduce_metric(e, acc) do
    type = e["type"]
    size = event_size(e)

    case type do
      "store_cold" ->
        if e["reused"] == true do
          Map.update(acc, :reuse_cold, 1, &(&1 + 1))
        else
          Map.update!(acc, :store_cold, &(&1 + 1))
        end

      "reuse_cold" ->
        Map.update(acc, :reuse_cold, 1, &(&1 + 1))

      "stub_in_hot" ->
        acc
        |> Map.update!(:stub_in_hot, &(&1 + 1))
        |> Map.update!(:stub_bytes, &(&1 + size))

      "full_hot" ->
        acc
        |> Map.update!(:full_hot, &(&1 + 1))
        |> Map.update!(:full_ingest_bytes, &(&1 + size))

      "attention_projection" ->
        # Alias for off-mode identity projection if used
        acc
        |> Map.update!(:full_hot, &(&1 + 1))
        |> Map.update!(:full_ingest_bytes, &(&1 + size))

      "fidelity_exception" ->
        acc
        |> Map.update!(:fidelity_exception, &(&1 + 1))
        |> Map.update!(:fidelity_exception_bytes, &(&1 + size))

      "warm_update" ->
        Map.update!(acc, :warm_update, &(&1 + 1))

      "expand" ->
        Map.update!(acc, :expand, &(&1 + 1))

      "same_path_reinvoke" ->
        Map.update!(acc, :same_path_reinvoke, &(&1 + 1))

      "denied_expand" ->
        Map.update!(acc, :denied_expand, &(&1 + 1))

      "session_treatment" ->
        Map.update!(acc, :session_treatment, &(&1 + 1))

      "attention_audit_error" ->
        Map.update!(acc, :attention_audit_error, &(&1 + 1))

      _ ->
        acc
    end
  end

  defp reexpand_placeholders(events) do
    # Simple same-cold expand join (U6 may refine). Placeholder keys always present.
    expand_events = Enum.filter(events, &(&1["type"] == "expand" and committed?(&1)))

    {n, b, _seen} =
      Enum.reduce(expand_events, {0, 0, MapSet.new()}, fn e, {n, b, seen} ->
        id = e["id"] || e["cold_id"]

        cond do
          not is_binary(id) ->
            {n, b, seen}

          MapSet.member?(seen, id) ->
            {n + 1, b + event_size(e), seen}

          true ->
            {n, b, MapSet.put(seen, id)}
        end
      end)

    %{n_reexpand: n, b_reexpand: b}
  end

  defp event_size(nil), do: 0

  defp event_size(e) when is_map(e) do
    size = e["size"] || e["bytes"] || e["projected_bytes"] || e["original_bytes"] || 0
    if is_integer(size), do: size, else: 0
  end

  defp committed?(e) when is_map(e) do
    case e["committed"] do
      nil -> true
      "committed" -> true
      :committed -> true
      _ -> false
    end
  end

  defp projection_or_access?(e) do
    committed?(e) and
      e["type"] in [
        "store_cold",
        "reuse_cold",
        "stub_in_hot",
        "full_hot",
        "fidelity_exception",
        "expand",
        "denied_expand",
        "same_path_reinvoke",
        "attention_projection"
      ]
  end

  defp normalize_event_item({type, fields}) when is_map(fields), do: {type, fields}
  defp normalize_event_item(%{"type" => type} = fields), do: {type, fields}
  defp normalize_event_item(%{type: type} = fields), do: {type, Map.delete(fields, :type)}

  defp envelope_get(ctx, key) when is_atom(key) do
    Map.get(ctx, key) || Map.get(ctx, Atom.to_string(key))
  end

  defp normalize_mode(mode) when mode in [false, 0, "0", "off", :off], do: "off"
  defp normalize_mode(mode) when mode in [true, 1, "1", "on", :on], do: "on"
  defp normalize_mode(mode) when is_binary(mode), do: if(mode == "off", do: "off", else: "on")
  defp normalize_mode(_), do: "on"

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)

  defp new_event_id do
    Base.encode16(:crypto.strong_rand_bytes(16), case: :lower)
  end
end
