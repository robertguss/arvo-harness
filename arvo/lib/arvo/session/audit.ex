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
  legacy lines). Residual re-expand join keys (`n_reexpand` / `b_reexpand`) are
  decision-ready (U6 / R15), not ship quality alone.
  """
  def metrics(session_path) when is_binary(session_path) do
    metrics_from_events(list(session_path))
  end

  def metrics_from_events(events) when is_list(events) do
    base =
      Enum.reduce(events, empty_metrics(), fn e, acc ->
        cond do
          # Always count audit errors so honesty gates see primary-write failures
          # even if a buggy writer marked committed=failed.
          e["type"] == "attention_audit_error" ->
            Map.update!(acc, :attention_audit_error, &(&1 + 1))

          committed?(e) ->
            reduce_metric(e, acc)

          true ->
            acc
        end
      end)

    residual = residual_join_metrics(events)
    base
    |> Map.merge(residual)
    |> Map.put(:n_denied_operator, residual.n_denied_operator)
    |> Map.put(:n_denied_model, residual.n_denied_model)
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
      # Decision-ready residual (U6 / R15)
      n_reexpand: 0,
      b_reexpand: 0,
      n_denied_operator: 0,
      n_denied_model: 0
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

  Operator `denied_expand` (`actor=user`) is **not** stranding — use
  `denied_expand_operator?/2`.
  """
  def stranding_candidate?(events, opts) when is_list(events) and is_list(opts) do
    recovery_available? = Keyword.get(opts, :recovery_available, true)

    # Ship class requires recovery available at decision time (Metric Spec).
    if recovery_available? do
      stub_stranded_shape?(events, opts)
    else
      false
    end
  end

  @doc """
  Trail shape of stranding without recovery_available gate: task fail + stub hides
  fact + no successful model expand (or last expand denied for model). Used for
  recovery-disabled causal pair (B) where recovery was intentionally off.
  """
  def stub_stranded_shape?(events, opts) when is_list(events) and is_list(opts) do
    task_ok? = Keyword.get(opts, :task_ok, true)
    cold_id = Keyword.get(opts, :cold_id)
    hides_fact? = Keyword.get(opts, :hides_required_fact, true)

    cond do
      task_ok? ->
        false

      not hides_fact? ->
        false

      not is_binary(cold_id) ->
        false

      # Operator deny is a correct deny, not stranding (Metric Spec).
      denied_expand_operator?(events, cold_id) ->
        false

      not Enum.any?(events, fn e ->
            e["type"] == "stub_in_hot" and committed?(e) and cold_id_match?(e, cold_id)
          end) ->
        false

      true ->
        model_expand_ok? =
          Enum.any?(events, fn e ->
            e["type"] == "expand" and committed?(e) and cold_id_match?(e, cold_id) and
              actor_of(e) == "model"
          end)

        last_denied_model? =
          case last_expand_class(events, cold_id) do
            {:denied, "model"} -> true
            {:denied, nil} -> true
            _ -> false
          end

        not model_expand_ok? or last_denied_model?
    end
  end

  @doc """
  Operator-visible denied/capped expand (`actor=user` or missing actor with
  explicit operator scenario). Not a stranding class.
  """
  def denied_expand_operator?(events, cold_id \\ nil) when is_list(events) do
    Enum.any?(events, fn e ->
      e["type"] == "denied_expand" and committed?(e) and
        (is_nil(cold_id) or cold_id_match?(e, cold_id)) and
        actor_of(e) in ["user", "operator", "human"]
    end)
  end

  @doc """
  Residual-need signals for Keepers park/unpark (R15). Separate from attention
  quality scores — never auto-unpark.
  """
  def residual_metrics(events) when is_list(events) do
    m = metrics_from_events(events)
    join = residual_join_metrics(events)

    %{
      n_reexpand: m.n_reexpand,
      b_reexpand: m.b_reexpand,
      n_expand: m.expand,
      n_denied: m.denied_expand,
      n_denied_operator: join.n_denied_operator,
      n_denied_model: join.n_denied_model,
      human_readable: residual_human_readable(m, join)
    }
  end

  def residual_metrics(session_path) when is_binary(session_path) do
    residual_metrics(list(session_path))
  end

  @doc """
  Decision-ready report: quality section + residual section (AE6).

  Options: `:task_ok`, `:tool_results_n`, `:cold_id`, `:recovery_available`,
  `:hides_required_fact`, `:b_full_off`.
  """
  def decision_report(events, opts \\ []) when is_list(events) and is_list(opts) do
    task_ok? = Keyword.get(opts, :task_ok, true)
    tool_n = Keyword.get(opts, :tool_results_n, 0)
    cold_id = Keyword.get(opts, :cold_id)
    recovery? = Keyword.get(opts, :recovery_available, true)
    hides? = Keyword.get(opts, :hides_required_fact, true)
    b_off = Keyword.get(opts, :b_full_off)

    m = metrics_from_events(events)
    residual = residual_metrics(events)
    mode = treatment_mode(events)

    honesty =
      case mode do
        "on" -> honesty_on?(events, tool_n)
        "off" -> honesty_off?(events, tool_n)
        _ -> false
      end

    stranded? =
      stranding_candidate?(events,
        task_ok: task_ok?,
        cold_id: cold_id,
        recovery_available: recovery?,
        hides_required_fact: hides?
      )

    waste =
      if is_integer(b_off) do
        waste_ratio(m.full_ingest_bytes, b_off)
      else
        nil
      end

    quality = %{
      task_ok: task_ok?,
      treatment: mode,
      honesty: honesty,
      waste_ratio: waste,
      b_full: m.full_ingest_bytes,
      stub_reuse: m.stub_in_hot + m.reuse_cold,
      stranding_candidate: stranded?,
      attention_audit_error: m.attention_audit_error
    }

    %{
      quality: quality,
      residual: residual,
      # Explicit: residual never auto-unparks Keepers
      keepers_hint:
        "Keep Keepers parked unless residual-need (re-expand pain / isolation) is " <>
          "human-reviewed. Attention quality alone must not unpark (R12/R15/AE6)."
    }
  end

  @doc """
  Causal stranding pair (decision-ready AE7): recovery-enabled trial A vs
  recovery-disabled/denied trial B. True only when A succeeds and B fails with
  stranding_candidate.
  """
  def causal_stranding_pair?(events_a, events_b, opts \\ [])
      when is_list(events_a) and is_list(events_b) and is_list(opts) do
    cold_id = Keyword.get(opts, :cold_id)
    hides? = Keyword.get(opts, :hides_required_fact, true)

    a_ok? = Keyword.get(opts, :task_ok_a, true)
    b_ok? = Keyword.get(opts, :task_ok_b, false)

    a_stranded? =
      stranding_candidate?(events_a,
        task_ok: a_ok?,
        cold_id: cold_id,
        recovery_available: true,
        hides_required_fact: hides?
      )

    # B: recovery intentionally off — use stranded shape, not ship recovery gate
    b_shape? =
      stub_stranded_shape?(events_b,
        task_ok: b_ok?,
        cold_id: cold_id,
        hides_required_fact: hides?
      )

    # Attribute causal stranding only when recovery path succeeds and denied path strands
    a_ok? and not a_stranded? and not b_ok? and b_shape?
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
        # B_stub = hot projected stub payload size, not original cold body.
        stub_sz = projected_event_size(e)

        acc
        |> Map.update!(:stub_in_hot, &(&1 + 1))
        |> Map.update!(:stub_bytes, &(&1 + stub_sz))

      "full_hot" ->
        # B_full = original / size (ingest into hot as full body).
        full_sz = full_ingest_event_size(e)

        acc
        |> Map.update!(:full_hot, &(&1 + 1))
        |> Map.update!(:full_ingest_bytes, &(&1 + full_sz))

      "attention_projection" ->
        # Alias for off-mode identity projection if used
        full_sz = full_ingest_event_size(e)

        acc
        |> Map.update!(:full_hot, &(&1 + 1))
        |> Map.update!(:full_ingest_bytes, &(&1 + full_sz))

      "fidelity_exception" ->
        full_sz = full_ingest_event_size(e)

        acc
        |> Map.update!(:fidelity_exception, &(&1 + 1))
        |> Map.update!(:fidelity_exception_bytes, &(&1 + full_sz))

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

      # Counted in metrics_from_events before reduce_metric; keep no-op.
      "attention_audit_error" ->
        acc

      _ ->
        acc
    end
  end

  # U6 residual join: N_reexpand / B_reexpand + deny actor split.
  defp residual_join_metrics(events) do
    expand_events = Enum.filter(events, &(&1["type"] == "expand" and committed?(&1)))

    {n, b, _seen} =
      Enum.reduce(expand_events, {0, 0, MapSet.new()}, fn e, {n, b, seen} ->
        id = e["id"] || e["cold_id"]

        cond do
          not is_binary(id) ->
            {n, b, seen}

          MapSet.member?(seen, id) ->
            # Re-expand: count + sum returned expand payload size
            {n + 1, b + expand_return_size(e), seen}

          true ->
            {n, b, MapSet.put(seen, id)}
        end
      end)

    denied = Enum.filter(events, &(&1["type"] == "denied_expand" and committed?(&1)))

    n_op =
      Enum.count(denied, fn e -> actor_of(e) in ["user", "operator", "human"] end)

    n_model =
      Enum.count(denied, fn e -> actor_of(e) == "model" end)

    %{
      n_reexpand: n,
      b_reexpand: b,
      n_denied_operator: n_op,
      n_denied_model: n_model
    }
  end

  defp expand_return_size(e) when is_map(e) do
    # Prefer returned slice size for residual cost
    size = e["returned_bytes"] || e["projected_bytes"] || e["size"] || e["bytes"] || 0
    if is_integer(size), do: size, else: 0
  end

  defp residual_human_readable(m, join) do
    [
      "Residual-need (Keepers park/unpark input — not auto-unpark):",
      "  N_reexpand=#{m.n_reexpand} B_reexpand=#{m.b_reexpand}",
      "  N_expand=#{m.expand} N_denied=#{m.denied_expand} " <>
        "(operator=#{join.n_denied_operator} model=#{join.n_denied_model})",
      "  Read with attention quality (task success, waste, non-stranding) separately.",
      "  Reopen Keepers only if residual pain remains after attention quality is known (R15)."
    ]
    |> Enum.join("\n")
  end

  defp cold_id_match?(e, cold_id) when is_binary(cold_id) do
    e["id"] == cold_id or e["cold_id"] == cold_id
  end

  defp actor_of(e) when is_map(e) do
    case e["actor"] do
      a when is_binary(a) -> String.downcase(a)
      a when is_atom(a) -> a |> Atom.to_string() |> String.downcase()
      _ -> nil
    end
  end

  defp last_expand_class(events, cold_id) when is_binary(cold_id) do
    events
    |> Enum.filter(fn e ->
      committed?(e) and cold_id_match?(e, cold_id) and
        e["type"] in ["expand", "denied_expand"]
    end)
    |> List.last()
    |> case do
      nil -> nil
      %{"type" => "expand"} = e -> {:expand, actor_of(e)}
      %{"type" => "denied_expand"} = e -> {:denied, actor_of(e)}
      _ -> nil
    end
  end

  # Hot stub payload bytes (projected_bytes preferred over original body size).
  defp projected_event_size(e) when is_map(e) do
    size = e["projected_bytes"] || e["size"] || e["bytes"] || 0
    if is_integer(size), do: size, else: 0
  end

  # Full-hot ingest bytes (original/size preferred over projected).
  defp full_ingest_event_size(e) when is_map(e) do
    size = e["original_bytes"] || e["size"] || e["bytes"] || e["projected_bytes"] || 0
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
        # warm_update is trail-only; not a projection/access honesty signal
      ]
  end

  @doc """
  Headless treatment=on honesty gate (KTD-H1 exit 6).

  Fails when:
  - audit file missing
  - any `attention_audit_error` present
  - `honesty_on?` fails for estimated tool_results_n (session tool messages)

  `tool_results_n` may be passed explicitly; otherwise counted from session tool rows.
  """
  def headless_on_evidence_ok?(session_path, tool_results_n \\ nil)
      when is_binary(session_path) do
    audit_path = path(session_path)

    cond do
      not File.regular?(audit_path) ->
        false

      true ->
        events = list(session_path)

        cond do
          Enum.any?(events, &(&1["type"] == "attention_audit_error")) ->
            false

          true ->
            n =
              if is_integer(tool_results_n) do
                tool_results_n
              else
                count_tool_result_messages(session_path)
              end

            honesty_on?(events, n)
        end
    end
  end

  @doc "Count tool-role messages in session JSONL (for headless honesty)."
  def count_tool_result_messages(session_path) when is_binary(session_path) do
    session_path
    |> Arvo.Session.Store.read_all()
    |> Enum.count(fn e ->
      e["type"] == "message" and
        (e["role"] == "tool" or (is_binary(e["tool_call_id"]) and e["tool_call_id"] != ""))
    end)
  rescue
    _ -> 0
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
