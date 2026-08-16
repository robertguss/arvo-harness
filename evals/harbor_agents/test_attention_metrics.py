"""Pure fixture tests for KTD-M1 ship scorers (no Harbor network)."""

from __future__ import annotations

from evals.harbor_agents.attention_metrics import (
    causal_stranding_pair,
    decision_report,
    denied_expand_operator,
    honesty_off,
    honesty_on,
    metrics_from_events,
    residual_metrics,
    ship_score,
    stranding_candidate,
    waste_ratio,
)


def test_honesty_off_treatment_plus_two_full_hot():
    events = [
        {"type": "session_treatment", "attention_mode": "off", "committed": "committed"},
        {
            "type": "full_hot",
            "size": 50_000,
            "reason_class": "opt_out",
            "attention_mode": "off",
            "committed": "committed",
        },
        {
            "type": "full_hot",
            "size": 50_000,
            "reason_class": "opt_out",
            "attention_mode": "off",
            "committed": "committed",
        },
    ]
    assert honesty_off(events, 2)
    assert not honesty_on(events, 2)
    m = metrics_from_events(events)
    assert m["full_hot"] == 2
    assert m["stub_in_hot"] == 0
    assert m["full_ingest_bytes"] == 100_000


def test_honesty_on_store_stub_reuse():
    events = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"},
        {"type": "store_cold", "id": "c1", "size": 20_000, "committed": "committed"},
        {
            "type": "full_hot",
            "id": "c1",
            "size": 20_000,
            "reason_class": "fidelity_retention",
            "committed": "committed",
        },
        {"type": "reuse_cold", "id": "c1", "size": 20_000, "committed": "committed"},
        {"type": "stub_in_hot", "id": "c1", "size": 20_000, "committed": "committed"},
    ]
    assert honesty_on(events, 2)
    m = metrics_from_events(events)
    assert m["stub_in_hot"] >= 1
    assert m["reuse_cold"] >= 1
    assert m["full_ingest_bytes"] == 20_000
    assert waste_ratio(m["full_ingest_bytes"], 100_000) < 1.0


def test_honesty_on_fails_empty_trail_with_tools():
    events = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"}
    ]
    assert not honesty_on(events, 1)


def test_stranding_candidate_task_fail_stub_no_expand():
    events = [{"type": "stub_in_hot", "id": "c9", "committed": "committed"}]
    assert stranding_candidate(
        events,
        task_ok=False,
        cold_id="c9",
        recovery_available=True,
        hides_required_fact=True,
    )
    events2 = events + [
        {
            "type": "expand",
            "id": "c9",
            "actor": "model",
            "committed": "committed",
        }
    ]
    assert not stranding_candidate(
        events2,
        task_ok=False,
        cold_id="c9",
        recovery_available=True,
        hides_required_fact=True,
    )


def test_ship_score_on_requires_stub_or_reuse():
    # Honest treatment + full_hot only (no stub) fails ship on-task signal
    events = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"},
        {"type": "full_hot", "size": 40_000, "committed": "committed"},
        {"type": "full_hot", "size": 40_000, "committed": "committed"},
    ]
    s = ship_score(events, task_ok=True, tool_results_n=2, expected_treatment="on")
    assert s["honesty_on"] is True
    assert s["pass"] is False
    assert "missing_stub_or_reuse" in s["reasons"]


def test_ship_score_on_control_waives_stub_requirement():
    # Control task: every output below stub threshold, so full_hot-only is honest
    events = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"},
        {"type": "full_hot", "size": 600, "reason_class": "small", "committed": "committed"},
        {"type": "full_hot", "size": 400, "reason_class": "small", "committed": "committed"},
    ]
    s = ship_score(
        events,
        task_ok=True,
        tool_results_n=2,
        expected_treatment="on",
        require_stub_reuse_on=False,
    )
    assert s["pass"] is True
    assert s["metrics"]["stub_in_hot"] == 0
    assert "missing_stub_or_reuse" not in s["reasons"]


def test_ship_score_on_happy():
    events = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"},
        {"type": "store_cold", "id": "c1", "size": 40_000, "committed": "committed"},
        {"type": "full_hot", "id": "c1", "size": 40_000, "committed": "committed"},
        {"type": "stub_in_hot", "id": "c1", "size": 200, "committed": "committed"},
    ]
    s = ship_score(
        events,
        task_ok=True,
        tool_results_n=2,
        expected_treatment="on",
        b_full_off=80_000,
    )
    assert s["pass"] is True
    assert s["waste_ratio"] is not None
    assert s["waste_ratio"] < 1.0


def test_ship_score_off_happy():
    events = [
        {"type": "session_treatment", "attention_mode": "off", "committed": "committed"},
        {
            "type": "full_hot",
            "size": 40_000,
            "reason_class": "opt_out",
            "committed": "committed",
        },
        {
            "type": "full_hot",
            "size": 40_000,
            "reason_class": "opt_out",
            "committed": "committed",
        },
    ]
    s = ship_score(events, task_ok=True, tool_results_n=2, expected_treatment="off")
    assert s["pass"] is True
    assert s["metrics"]["stub_in_hot"] == 0


def test_ore_or_missing_trail_fails():
    # Tool results claimed but zero treatment/projection → AE9 fail
    events: list = []
    s = ship_score(events, task_ok=True, tool_results_n=2, expected_treatment="on")
    assert s["pass"] is False
    assert not s["honesty_ok"]


def test_attention_audit_error_counted_when_committed_failed():
    events = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"},
        {
            "type": "attention_audit_error",
            "primary_write": "failed",
            "committed": "failed",
        },
    ]
    m = metrics_from_events(events)
    assert m["attention_audit_error"] == 1
    s = ship_score(events, task_ok=True, tool_results_n=0, expected_treatment="on")
    assert s["pass"] is False
    assert "attention_audit_error" in s["reasons"]


def test_stub_bytes_prefer_projected_bytes():
    events = [
        {
            "type": "stub_in_hot",
            "id": "c1",
            "size": 50_000,
            "original_bytes": 50_000,
            "projected_bytes": 200,
            "committed": "committed",
        }
    ]
    m = metrics_from_events(events)
    assert m["stub_bytes"] == 200
    assert m["stub_in_hot"] == 1


def test_warm_update_not_projection_honesty():
    events = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"},
        {"type": "warm_update", "committed": "committed"},
    ]
    assert not honesty_on(events, 1)


def test_reexpand_and_residual_metrics():
    events = [
        {"type": "expand", "id": "c1", "size": 100, "committed": "committed"},
        {
            "type": "expand",
            "id": "c1",
            "size": 50,
            "returned_bytes": 40,
            "committed": "committed",
        },
        {"type": "expand", "id": "c2", "size": 10, "committed": "committed"},
        {
            "type": "denied_expand",
            "id": "c3",
            "actor": "user",
            "committed": "committed",
        },
        {
            "type": "denied_expand",
            "id": "c4",
            "actor": "model",
            "committed": "committed",
        },
    ]
    m = metrics_from_events(events)
    assert m["n_reexpand"] == 1
    assert m["b_reexpand"] == 40
    assert m["n_denied_operator"] == 1
    assert m["n_denied_model"] == 1
    r = residual_metrics(events)
    assert r["n_reexpand"] == 1
    assert "not auto-unpark" in r["human_readable"]


def test_operator_deny_not_stranding():
    events = [
        {"type": "stub_in_hot", "id": "c9", "committed": "committed"},
        {
            "type": "denied_expand",
            "id": "c9",
            "actor": "user",
            "committed": "committed",
        },
    ]
    assert denied_expand_operator(events, "c9")
    assert not stranding_candidate(
        events,
        task_ok=False,
        cold_id="c9",
        recovery_available=True,
        hides_required_fact=True,
    )


def test_causal_stranding_pair_and_decision_report():
    events_a = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"},
        {"type": "stub_in_hot", "id": "c1", "committed": "committed"},
        {
            "type": "expand",
            "id": "c1",
            "actor": "model",
            "size": 80,
            "committed": "committed",
        },
    ]
    events_b = [
        {"type": "session_treatment", "attention_mode": "on", "committed": "committed"},
        {"type": "stub_in_hot", "id": "c1", "committed": "committed"},
    ]
    assert causal_stranding_pair(
        events_a, events_b, cold_id="c1", task_ok_a=True, task_ok_b=False
    )
    rep = decision_report(
        events_a, task_ok=True, tool_results_n=1, cold_id="c1", b_full_off=1000
    )
    assert "quality" in rep and "residual" in rep
    assert "Keepers" in rep["keepers_hint"]
    assert rep["quality"]["stranding_candidate"] is False


def _run_all() -> None:
    """Run test_* functions without pytest (stdlib only)."""
    import traceback

    tests = [
        (name, obj)
        for name, obj in sorted(globals().items())
        if name.startswith("test_") and callable(obj)
    ]
    failed = 0
    for name, fn in tests:
        try:
            fn()
            print(f"ok  {name}")
        except Exception as exc:  # noqa: BLE001 — surface all test failures
            failed += 1
            print(f"FAIL {name}: {exc}")
            traceback.print_exc()
    print(f"{len(tests) - failed}/{len(tests)} passed")
    if failed:
        raise SystemExit(1)


if __name__ == "__main__":
    _run_all()
