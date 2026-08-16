"""KTD-M1 ship metric scorers over attention audit events (pure, no I/O).

Mirrors `Arvo.Session.Audit` honesty / waste / stranding helpers so Harbor
verifiers and host fixture tests share one definition of ship-ready scoring.

All counters count **committed** events only (committed missing → treat as committed
for fixture convenience; explicit abandoned/failed excluded).
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping, Sequence
from typing import Any

Event = Mapping[str, Any]

# Align with Arvo.Session.Audit.projection_or_access?/1 — warm_update is trail-only.
PROJECTION_TYPES = frozenset(
    {
        "full_hot",
        "stub_in_hot",
        "store_cold",
        "reuse_cold",
        "fidelity_exception",
        "same_path_reinvoke",
        "attention_projection",
        "expand",
        "denied_expand",
    }
)

REASON_CLASSES = frozenset(
    {
        "opt_out",
        "small",
        "size",
        "pinned",
        "error",
        "fidelity_retention",
        "exception_budget",
        "same_path_reuse",
        "cold_store_failed",
        "not_found",
        "cap_exceeded",
        "denied",
        "capped",
        "policy",
        "unknown",
    }
)


def committed(event: Event) -> bool:
    c = event.get("committed")
    if c is None:
        return True
    return str(c) == "committed"


def normalize_mode(mode: Any) -> str | None:
    if mode is None:
        return None
    s = str(mode).strip().lower()
    if s in ("on", "1", "true", "yes"):
        return "on"
    if s in ("off", "0", "false", "no"):
        return "off"
    return s or None


def treatment_mode(events: Sequence[Event]) -> str | None:
    for e in events:
        if e.get("type") == "session_treatment":
            m = normalize_mode(e.get("attention_mode"))
            if m:
                return m
    for e in events:
        m = normalize_mode(e.get("attention_mode"))
        if m:
            return m
    return None


def projection_or_access(event: Event) -> bool:
    if not committed(event):
        return False
    return event.get("type") in PROJECTION_TYPES


def _int_field(event: Event, *keys: str) -> int:
    for key in keys:
        v = event.get(key)
        if isinstance(v, bool):
            continue
        if isinstance(v, (int, float)):
            return int(v)
        if isinstance(v, str) and v.isdigit():
            return int(v)
    return 0


def event_size(event: Event) -> int:
    """Generic size (legacy); prefer projected/full helpers for metrics."""
    return _int_field(event, "size", "bytes", "original_bytes", "projected_bytes")


def projected_event_size(event: Event) -> int:
    """B_stub: hot projected stub payload (not original cold body)."""
    return _int_field(event, "projected_bytes", "size", "bytes")


def full_ingest_event_size(event: Event) -> int:
    """B_full: original/size preferred over projected."""
    return _int_field(event, "original_bytes", "size", "bytes", "projected_bytes")


def cold_id_of(event: Event) -> str | None:
    for key in ("id", "cold_id"):
        v = event.get(key)
        if isinstance(v, str) and v:
            return v
    return None


def metrics_from_events(events: Sequence[Event]) -> dict[str, int]:
    """Aggregate ship counters (committed only)."""
    m = {
        "store_cold": 0,
        "reuse_cold": 0,
        "stub_in_hot": 0,
        "full_hot": 0,
        "full_ingest_bytes": 0,  # B_full
        "stub_bytes": 0,  # B_stub
        "fidelity_exception": 0,
        "warm_update": 0,
        "expand": 0,
        "denied_expand": 0,
        "same_path_reinvoke": 0,
        "session_treatment": 0,
        "attention_audit_error": 0,
        "n_reexpand": 0,  # U6 residual
        "b_reexpand": 0,
        "n_denied_operator": 0,
        "n_denied_model": 0,
    }
    expanded_cold: set[str] = set()

    for e in events:
        t = e.get("type")
        # Always count audit errors (even committed=failed) so ship_score fails.
        if t == "attention_audit_error":
            m["attention_audit_error"] += 1
            continue
        if not committed(e):
            continue
        size = event_size(e)

        if t == "session_treatment":
            m["session_treatment"] += 1
        elif t == "store_cold":
            if e.get("reused") is True:
                m["reuse_cold"] += 1
            else:
                m["store_cold"] += 1
        elif t == "reuse_cold":
            m["reuse_cold"] += 1
        elif t == "stub_in_hot":
            m["stub_in_hot"] += 1
            m["stub_bytes"] += projected_event_size(e)
        elif t == "full_hot":
            m["full_hot"] += 1
            m["full_ingest_bytes"] += full_ingest_event_size(e)
        elif t == "fidelity_exception":
            m["fidelity_exception"] += 1
        elif t == "warm_update":
            m["warm_update"] += 1
        elif t == "expand":
            m["expand"] += 1
            cid = cold_id_of(e)
            ret = _int_field(e, "returned_bytes", "projected_bytes", "size", "bytes")
            if cid and cid in expanded_cold:
                m["n_reexpand"] += 1
                m["b_reexpand"] += ret
            if cid:
                expanded_cold.add(cid)
        elif t == "denied_expand":
            m["denied_expand"] += 1
            actor = str(e.get("actor") or "").lower()
            if actor in ("user", "operator", "human"):
                m["n_denied_operator"] += 1
            elif actor == "model":
                m["n_denied_model"] += 1
        elif t == "same_path_reinvoke":
            m["same_path_reinvoke"] += 1

    return m


def honesty_on(events: Sequence[Event], tool_results_n: int) -> bool:
    """treatment=on AND ≥1 projection/access when tool_results_n > 0."""
    mode = treatment_mode(events)
    if mode != "on":
        return False
    if tool_results_n <= 0:
        return True
    return any(projection_or_access(e) for e in events)


def honesty_off(events: Sequence[Event], tool_results_n: int) -> bool:
    """treatment=off AND session_treatment present AND ≥1 full_hot when tools ran."""
    mode = treatment_mode(events)
    has_treatment = any(e.get("type") == "session_treatment" for e in events)
    if mode != "off":
        return False
    if not has_treatment:
        return False
    if tool_results_n <= 0:
        return True
    return any(
        committed(e) and e.get("type") in ("full_hot", "attention_projection")
        for e in events
    )


def waste_ratio(b_full_on: int, b_full_off: int) -> float:
    """waste_ratio = B_full_on / max(B_full_off, 1)."""
    return float(b_full_on) / float(max(int(b_full_off), 1))


def denied_expand_operator(
    events: Sequence[Event], cold_id: str | None = None
) -> bool:
    """Operator deny (actor=user|operator|human) — not stranding."""
    for e in events:
        if not committed(e) or e.get("type") != "denied_expand":
            continue
        if cold_id is not None and cold_id_of(e) != cold_id:
            continue
        actor = str(e.get("actor") or "").lower()
        if actor in ("user", "operator", "human"):
            return True
    return False


def stub_stranded_shape(
    events: Sequence[Event],
    *,
    task_ok: bool,
    cold_id: str | None,
    hides_required_fact: bool = True,
) -> bool:
    """Stranding trail shape without recovery_available gate (causal pair B)."""
    if task_ok:
        return False
    if not hides_required_fact:
        return False
    if not isinstance(cold_id, str) or not cold_id:
        return False
    if denied_expand_operator(events, cold_id):
        return False

    has_stub = any(
        committed(e)
        and e.get("type") == "stub_in_hot"
        and cold_id_of(e) == cold_id
        for e in events
    )
    if not has_stub:
        return False

    model_expand_ok = any(
        committed(e)
        and e.get("type") == "expand"
        and cold_id_of(e) == cold_id
        and str(e.get("actor") or "") == "model"
        for e in events
    )
    return not model_expand_ok


def stranding_candidate(
    events: Sequence[Event],
    *,
    task_ok: bool,
    cold_id: str | None,
    recovery_available: bool = True,
    hides_required_fact: bool = True,
) -> bool:
    """Ship stranding class (non-causal-complete); requires recovery available."""
    if not recovery_available:
        return False
    return stub_stranded_shape(
        events,
        task_ok=task_ok,
        cold_id=cold_id,
        hides_required_fact=hides_required_fact,
    )


def residual_metrics(events: Sequence[Event]) -> dict[str, Any]:
    """R15 residual-need signals (separate from attention quality)."""
    m = metrics_from_events(events)
    human = (
        "Residual-need (Keepers park/unpark input — not auto-unpark):\n"
        f"  N_reexpand={m['n_reexpand']} B_reexpand={m['b_reexpand']}\n"
        f"  N_expand={m['expand']} N_denied={m['denied_expand']} "
        f"(operator={m['n_denied_operator']} model={m['n_denied_model']})\n"
        "  Read with attention quality (task success, waste, non-stranding) separately.\n"
        "  Reopen Keepers only if residual pain remains after attention quality is known (R15)."
    )
    return {
        "n_reexpand": m["n_reexpand"],
        "b_reexpand": m["b_reexpand"],
        "n_expand": m["expand"],
        "n_denied": m["denied_expand"],
        "n_denied_operator": m["n_denied_operator"],
        "n_denied_model": m["n_denied_model"],
        "human_readable": human,
    }


def decision_report(
    events: Sequence[Event],
    *,
    task_ok: bool = True,
    tool_results_n: int = 0,
    cold_id: str | None = None,
    recovery_available: bool = True,
    hides_required_fact: bool = True,
    b_full_off: int | None = None,
) -> dict[str, Any]:
    """Decision-ready report: quality + residual sections (AE6)."""
    m = metrics_from_events(events)
    residual = residual_metrics(events)
    mode = treatment_mode(events)
    if mode == "on":
        honesty = honesty_on(events, tool_results_n)
    elif mode == "off":
        honesty = honesty_off(events, tool_results_n)
    else:
        honesty = False

    stranded = stranding_candidate(
        events,
        task_ok=task_ok,
        cold_id=cold_id,
        recovery_available=recovery_available,
        hides_required_fact=hides_required_fact,
    )
    waste = None
    if b_full_off is not None:
        waste = waste_ratio(m["full_ingest_bytes"], b_full_off)

    quality = {
        "task_ok": task_ok,
        "treatment": mode,
        "honesty": honesty,
        "waste_ratio": waste,
        "b_full": m["full_ingest_bytes"],
        "stub_reuse": m["stub_in_hot"] + m["reuse_cold"],
        "stranding_candidate": stranded,
        "attention_audit_error": m["attention_audit_error"],
    }
    return {
        "quality": quality,
        "residual": residual,
        "keepers_hint": (
            "Keep Keepers parked unless residual-need (re-expand pain / isolation) is "
            "human-reviewed. Attention quality alone must not unpark (R12/R15/AE6)."
        ),
    }


def causal_stranding_pair(
    events_a: Sequence[Event],
    events_b: Sequence[Event],
    *,
    cold_id: str | None,
    task_ok_a: bool = True,
    task_ok_b: bool = False,
    hides_required_fact: bool = True,
) -> bool:
    """True when recovery-enabled A succeeds and recovery-disabled B strands (AE7)."""
    a_stranded = stranding_candidate(
        events_a,
        task_ok=task_ok_a,
        cold_id=cold_id,
        recovery_available=True,
        hides_required_fact=hides_required_fact,
    )
    b_shape = stub_stranded_shape(
        events_b,
        task_ok=task_ok_b,
        cold_id=cold_id,
        hides_required_fact=hides_required_fact,
    )
    return bool(task_ok_a and not a_stranded and not task_ok_b and b_shape)


def load_events_jsonl(lines: Iterable[str]) -> list[dict[str, Any]]:
    """Parse JSONL audit lines; skip blank / invalid."""
    import json

    out: list[dict[str, Any]] = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(obj, dict):
            out.append(obj)
    return out


def ship_score(
    events: Sequence[Event],
    *,
    task_ok: bool,
    tool_results_n: int | None = None,
    expected_treatment: str | None = None,
    b_full_off: int | None = None,
    require_stub_reuse_on: bool = True,
) -> dict[str, Any]:
    """Ship-ready score bundle for one trial.

    Reward (pass) requires task_ok + treatment-aware honesty.
    When expected_treatment is on: also require stub or reuse signal, unless
    require_stub_reuse_on=False (control tasks whose tool outputs all sit
    below the stub threshold legitimately produce zero stubs).
    When expected_treatment is off: require zero stubs and ≥1 full_hot if tools ran.
    Optional b_full_off enables waste_ratio when paired off baseline known.
    """
    m = metrics_from_events(events)
    mode = treatment_mode(events)
    # Infer tool_results_n from projection events if not provided
    if tool_results_n is None:
        tool_results_n = (
            m["stub_in_hot"]
            + m["full_hot"]
            + m["fidelity_exception"]
            + m["reuse_cold"]
        )
        # session with tools but empty trail still needs honesty fail — caller
        # should pass tool_results_n > 0 when agent wrote sessions with tools.

    h_on = honesty_on(events, tool_results_n)
    h_off = honesty_off(events, tool_results_n)

    if expected_treatment is None:
        expected_treatment = mode

    honesty_ok = False
    if expected_treatment == "on":
        honesty_ok = h_on
    elif expected_treatment == "off":
        honesty_ok = h_off
    else:
        # Unknown expected: still require some honest trail for the recorded mode
        honesty_ok = h_on if mode == "on" else h_off if mode == "off" else False

    stub_reuse_signal = m["stub_in_hot"] + m["reuse_cold"]
    waste = None
    if b_full_off is not None:
        waste = waste_ratio(m["full_ingest_bytes"], b_full_off)

    reasons: list[str] = []
    if not task_ok:
        reasons.append("task_failed")
    if not honesty_ok:
        reasons.append("honesty_failed")
    if mode is None:
        reasons.append("no_treatment")
    if (
        require_stub_reuse_on
        and expected_treatment == "on"
        and honesty_ok
        and stub_reuse_signal < 1
    ):
        reasons.append("missing_stub_or_reuse")
        honesty_ok = False  # AE1 second-read signal required for on ship task
    if expected_treatment == "off" and honesty_ok and m["stub_in_hot"] > 0:
        reasons.append("unexpected_stub_on_off")
        honesty_ok = False
    if expected_treatment == "off" and tool_results_n > 0 and m["full_hot"] < 1:
        reasons.append("missing_full_hot_off")
        honesty_ok = False
    if m["attention_audit_error"] > 0 and mode == "on":
        reasons.append("attention_audit_error")
        honesty_ok = False

    # Ore / wrong adapter: no arvo treatment trail
    if mode is None and tool_results_n > 0:
        reasons.append("ore_or_missing_trail")

    pass_ship = bool(task_ok and honesty_ok)

    return {
        "task_ok": task_ok,
        "treatment": mode,
        "expected_treatment": expected_treatment,
        "honesty_on": h_on,
        "honesty_off": h_off,
        "honesty_ok": honesty_ok,
        "pass": pass_ship,
        "metrics": m,
        "stub_reuse_signal": stub_reuse_signal,
        "waste_ratio": waste,
        "b_full": m["full_ingest_bytes"],
        "tool_results_n": tool_results_n,
        "reasons": reasons,
    }
