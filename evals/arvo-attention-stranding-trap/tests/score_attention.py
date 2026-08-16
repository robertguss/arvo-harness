#!/usr/bin/env python3
"""Harbor verifier scorer: task success + KTD-M1 honesty from Arvo audit trail.

Stranding-trap variant: the approved module name sits ~6.6 KB deep in an
~11 KB deterministic bash report. Non-read tool results get no fidelity
exception, so under attention-on the report always stubs (400-byte preview
hides the fact) and success requires expand/recall recovery. Reward stays
task+honesty only (no expand requirement in reward); expand counts land in
metrics/evidence for the R-005 comparison. Metric definitions match the other
suite scorers so ratios compare.

Reads newest `$HOME/.arvo/sessions/**/*.audit.jsonl` and workspace markers.
Writes evidence + metrics under /logs/verifier, copies the scored audit JSONL
there for per-event forensics, and prints a JSON summary on stdout.

Exit 0 always (Harbor infra); reward is written to reward.txt by caller or here.
"""

from __future__ import annotations

import json
import os
import shutil
import sys
from pathlib import Path

# Same directory as this script (task tests/ in sandbox)
sys.path.insert(0, str(Path(__file__).resolve().parent))
from attention_metrics import (  # noqa: E402
    load_events_jsonl,
    metrics_from_events,
    ship_score,
)

APPROVED = "SensorRelay"  # rot13 of FrafbeErynl in build_report.sh
PLACEHOLDER = "SensorDraft"


def newest_audit(home: Path) -> Path | None:
    root = home / ".arvo" / "sessions"
    if not root.is_dir():
        return None
    audits = sorted(root.rglob("*.audit.jsonl"), key=lambda p: p.stat().st_mtime)
    return audits[-1] if audits else None


def count_session_tool_activity(home: Path) -> int:
    """Heuristic tool_results_n: session JSONL lines mentioning tool_calls."""
    root = home / ".arvo" / "sessions"
    if not root.is_dir():
        return 0
    n = 0
    for p in root.rglob("*.jsonl"):
        if p.name.endswith(".audit.jsonl"):
            continue
        try:
            text = p.read_text(errors="replace")
        except OSError:
            continue
        n += text.count("tool_calls") + text.count('"role":"tool"') + text.count(
            '"role": "tool"'
        )
    return n


def task_success(app: Path) -> tuple[bool, str]:
    hub = app / "sensor_hub.ex"
    if not hub.is_file():
        return False, "sensor_hub.ex missing"
    text = hub.read_text(errors="replace")
    if f"defmodule {APPROVED} do" not in text:
        return False, "sensor_hub.ex not renamed to approved module name"
    if f"defmodule {PLACEHOLDER} do" in text:
        return False, "sensor_hub.ex still defines the placeholder module"
    if "PAYLOAD_TOKEN_b3d7f1" not in text:
        return False, "sensor_hub.ex damaged (marker gone)"
    script = app / "build_report.sh"
    if not script.is_file():
        return False, "build_report.sh missing"
    if "FrafbeErynl" not in script.read_text(errors="replace"):
        return False, "build_report.sh tampered (encoded name gone)"
    return True, "module renamed to approved name; report script intact"


def main() -> int:
    home = Path(os.environ.get("HOME", "/home/agent"))
    app = Path("/app")
    logs = Path("/logs/verifier")
    logs.mkdir(parents=True, exist_ok=True)

    expected = os.environ.get("ARVO_EXPECT_TREATMENT") or os.environ.get(
        "ARVO_PROGRESSIVE_ATTENTION"
    )
    # Normalize expected treatment from env
    if expected is not None:
        e = str(expected).strip().lower()
        if e in ("1", "on", "true", "yes"):
            expected = "on"
        elif e in ("0", "off", "false", "no"):
            expected = "off"
        else:
            expected = e if e in ("on", "off") else None

    # Prefer treatment recorded by agent setup file if present
    treat_file = Path("/logs/agent/attention-treatment.txt")
    if expected is None and treat_file.is_file():
        expected = treat_file.read_text().strip().lower() or None

    ok, task_reason = task_success(app)
    audit_path = newest_audit(home)
    events: list = []
    if audit_path and audit_path.is_file():
        events = load_events_jsonl(audit_path.read_text().splitlines())

    # Per-event forensics outlive the container (R-002 outlier lesson)
    if audit_path is not None:
        try:
            shutil.copy2(audit_path, logs / audit_path.name)
        except OSError as exc:
            (logs / "audit-copy-error.txt").write_text(f"{exc}\n")

    tool_n = count_session_tool_activity(home)
    # If audit has projections, prefer that as lower bound for tool_results_n
    m = metrics_from_events(events)
    proj_n = m["stub_in_hot"] + m["full_hot"] + m["reuse_cold"]
    tool_results_n = max(tool_n, proj_n, 1 if events else 0)

    # Oracle path: no arvo sessions → task-only reward (attention honesty N/A)
    oracle_mode = audit_path is None and tool_n == 0

    if oracle_mode:
        score = {
            "task_ok": ok,
            "treatment": None,
            "expected_treatment": expected,
            "honesty_ok": True,
            "pass": ok,
            "metrics": m,
            "oracle_mode": True,
            "reasons": [] if ok else ["task_failed"],
            "audit_path": None,
            "tool_results_n": 0,
        }
    else:
        # Agent path: AE9 treatment-aware honesty required
        # If tools ran but we have zero session files, still fail honesty
        if tool_results_n == 0 and not events:
            tool_results_n = 1  # agent claimed to run; trail missing → fail honesty
        score = ship_score(
            events,
            task_ok=ok,
            tool_results_n=tool_results_n,
            expected_treatment=expected,
        )
        score["oracle_mode"] = False
        score["audit_path"] = str(audit_path) if audit_path else None
        score["task_reason"] = task_reason

    # Evidence
    evidence_lines = [
        f"verdict={'pass' if score['pass'] else 'fail'}",
        f"task_ok={int(ok)}",
        f"task_reason={task_reason}",
        f"oracle_mode={int(score.get('oracle_mode', False))}",
        f"treatment={score.get('treatment')}",
        f"expected_treatment={score.get('expected_treatment')}",
        f"honesty_ok={int(bool(score.get('honesty_ok')))}",
        f"honesty_on={int(bool(score.get('honesty_on', False)))}",
        f"honesty_off={int(bool(score.get('honesty_off', False)))}",
        f"audit_path={score.get('audit_path')}",
        f"tool_results_n={score.get('tool_results_n')}",
        f"b_full={score.get('b_full', m['full_ingest_bytes'])}",
        f"n_stub={m['stub_in_hot']}",
        f"n_full={m['full_hot']}",
        f"n_reuse={m['reuse_cold']}",
        f"n_reinvoke={m['same_path_reinvoke']}",
        f"n_store={m['store_cold']}",
        f"n_expand={m['expand']}",
        f"n_denied={m['denied_expand']}",
        f"stub_reuse_signal={score.get('stub_reuse_signal', m['stub_in_hot'] + m['reuse_cold'])}",
        f"reasons={','.join(score.get('reasons') or []) or 'none'}",
    ]
    (logs / "evidence.txt").write_text("\n".join(evidence_lines) + "\n")
    (logs / "attention-metrics.json").write_text(
        json.dumps(score, indent=2, default=str) + "\n"
    )
    (logs / "reward.txt").write_text("1\n" if score["pass"] else "0\n")

    print(json.dumps({"pass": score["pass"], "task_ok": ok, "reasons": score.get("reasons")}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
