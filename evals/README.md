# Harbor evals (Ore + Arvo attention)

Two product paths:

| Suite | Agent adapter | Artifact |
| ----- | ------------- | -------- |
| Ore coding / fff-search | `evals/harbor_agents/ore_agent.py` | Host `ore` binary upload |
| **Arvo progressive attention** | `evals/harbor_agents/arvo_agent.py` | **Mix release tarball** (ERTS), not Ore packaging |

Ore-only jobs are **not** attention wins (AE9). Attention ship scores read
`$HOME/.arvo/sessions/**/*.audit.jsonl` from the Arvo product trail.

## Suites

### Arvo progressive attention (`suite = arvo-attention`) — ship-ready U4

| Task | Capability | Primary reward |
| ---- | ---------- | -------------- |
| `arvo-attention-reread` | Large re-read + rename edit under attention **on** vs **off** | `task_ok` + treatment-aware **honesty** + on: stub/reuse signal; off: full_hot identity |

**Ship metrics (KTD-M1)** from committed audit events:

| Metric | Pass rule |
| ------ | --------- |
| Honesty on | `treatment=on` + ≥1 projection when tools ran |
| Honesty off | `treatment=off` + `session_treatment` + ≥1 `full_hot` when tools ran |
| Task success | `big_module.ex` has `defmodule BigFixed do` + `PAYLOAD_TOKEN_7f3a9c` |
| Stub/reuse (on) | `N_stub + N_reuse ≥ 1` |
| Hot waste (paired) | `waste_ratio = B_full_on / max(B_full_off, 1) < 1.0` (compare on/off job metrics JSON) |

**Unit baselines (no Harbor network):**

```bash
# Elixir trail + progressive scenario
cd arvo && mix test test/arvo/progressive_attention_eval_test.exs test/arvo/session_audit_test.exs

# Python pure scorers (fixtures)
export PYTHONPATH=$PWD${PYTHONPATH:+:$PYTHONPATH}
python3 -m pytest evals/harbor_agents/test_attention_metrics.py -q
```

**Release + live Harbor:**

```bash
# 1) Build arch-matching Mix release (KTD-D1)
cd arvo && MIX_ENV=prod mix release arvo
# tarball: arvo/_build/prod/arvo-*.tar.gz  (or set ARVO_RELEASE)

# 2) Oracle (task edit only; no attention honesty)
export PYTHONPATH=$PWD${PYTHONPATH:+:$PYTHONPATH}
harbor run -c evals/jobs-config/arvo-attention-reread-oracle.json -y

# 3) Attention on / off (needs XAI_API_KEY)
harbor run -c evals/jobs-config/arvo-attention-reread-on.json -y --ae XAI_API_KEY
harbor run -c evals/jobs-config/arvo-attention-reread-off.json -y --ae XAI_API_KEY
```

Compare `/logs/verifier/attention-metrics.json` (or job artifacts) for `b_full`
on vs off after both trials. Failures with tools but no treatment/projection
events are honesty fails (AE9)—including Ore adapter misuse.

Docs: `arvo/rel/RELEASE.md` (install layout, exit codes, audit glob).

### Decision-ready matrix (U6 / R15–R16 / AE6–AE7)

Ship quality and residual-need are **separate sections**. Attention quality alone
must **not** unpark Keepers (R12/R15).

| Matrix row | What it shows | How to run / score |
| ---------- | ------------- | ------------------ |
| Re-read waste | on vs off `B_full` / stub-reuse | ship jobs `arvo-attention-reread-on` + `-off` |
| Expand / deny honesty | `expand` vs `denied_expand`; operator deny ≠ stranding | ExUnit + pure scorers; trail `actor=user` vs `model` |
| Multi-step coding path | task_ok under attention on product path | same reread/edit task (or future multi-step task) |
| Stranding class (ship) | stub + no model recovery + task fail | fixtures / `stranding_candidate` |
| Causal stranding pair | recovery-on succeeds; recovery-off fails with stranded shape | pure `causal_stranding_pair` (min 1 pair; prefer ≥3 live) |
| Residual-need | `N_reexpand`, `B_reexpand`, deny actor split | `residual_metrics` / `decision_report` |

**Unit residual / decision report (no Harbor):**

```bash
cd arvo && mix test test/arvo/session_audit_test.exs
export PYTHONPATH=$PWD${PYTHONPATH:+:$PYTHONPATH}
python3 evals/harbor_agents/test_attention_metrics.py
```

**Human park/unpark packet (AE6) — read in this order:**

1. **Quality** (from ship scores): task success on/off, honesty, waste_ratio, non-stranding.
2. **Residual** (from `residual_metrics` / audit metrics): `N_reexpand`, `B_reexpand`, operator vs model denies.
3. **Decision:** keep Keepers **parked** unless residual pain remains after attention quality is known (or an explicit BEAM-depth milestone)—never reopen because quality alone failed.

Pure helpers:

- Elixir: `Arvo.Session.Audit.residual_metrics/1`, `decision_report/2`, `causal_stranding_pair?/3`, `denied_expand_operator?/2`
- Python: `evals.harbor_agents.attention_metrics` same names

### Generic coding (Ore)

| Task                   | Capability                               | Beads                      |
| ---------------------- | ---------------------------------------- | -------------------------- |
| `ore-fix-failing-test` | Repair buggy Rust so `cargo test` passes | `coding-agent-harness-ffy` |

### fff search (`suite = fff-search`)

Measures flagship **search profile** + `fff_search` plugin quality and agent
use.

| Task                       | Capability                                                       | Primary reward                                                 | Beads     |
| -------------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------- | --------- |
| `ore-fff-locate-then-edit` | Find unique token in multi-module crate, fix nearby bug          | `cargo test` green + API intact; logs `fff_search` hits        | `ffy.1.2` |
| `ore-fff-prefer-plugin`    | Tool-choice doctrine: locate token → `answer.txt`                | Correct path **and** `fff_search` if agent sessions exist      | `ffy.1.3` |
| `ore-fff-fuzzy-path`       | Typo-resistant fuzzy path (`shcema_loader` → `schema_loader.rs`) | Correct path **and** `fff_search` if sessions exist            | `ffy.1.4` |
| `ore-fff-gitignore`        | Skip `target/`, `node_modules/`, gitignored `vendor/`            | Source path only; reject noise paths; `fff_search` if sessions | `ffy.1.4` |

**Engine unit baselines** (no Harbor): `cargo test -p ore-plugin-fff` — nested
content, path hit, limit, multi-word, skip dirs, sandbox, scoped path, fuzzy
path typo. Integration smoke:
`cargo test -p ore-plugin-fff --test harbor_fixture_smoke`.

**Engine:** native `fff-search` 0.9.6 (shipped with `cg8`). Frecency/ranking is
**not** a separate Harbor task: the plugin does not expose rank/frecency signals
beyond hit order, so agent-level scoring would be noisy; unit + fuzzy/ignore
cover measurable quality.

Epic: `coding-agent-harness-ffy.1`.

### Job configs

Reusable Harbor job JSON under `evals/jobs-config/`:

```bash
export PYTHONPATH=$PWD${PYTHONPATH:+:$PYTHONPATH}

# Ore fff
harbor run -c evals/jobs-config/ore-fff-fuzzy-path-oracle.json -y
harbor run -c evals/jobs-config/ore-fff-gitignore-oracle.json -y

# Arvo attention ship-ready
harbor run -c evals/jobs-config/arvo-attention-reread-oracle.json -y
harbor run -c evals/jobs-config/arvo-attention-reread-on.json -y --ae XAI_API_KEY
harbor run -c evals/jobs-config/arvo-attention-reread-off.json -y --ae XAI_API_KEY
```

## Prerequisites

```bash
# Ore path: host binary uploaded into the sandbox
cargo install --path ore/crates/ore --locked --force

# Arvo path: Mix release tarball (includes ERTS)
cd arvo && MIX_ENV=prod mix release arvo

# Harbor + credentials for live agent trials
# XAI_API_KEY (Arvo; also Ore if not using ~/.ore/auth.json)
```

## Run patterns

```bash
# Unit engine bar (fast, no Docker)
cd ore && cargo test -p ore-plugin-fff
cd arvo && mix test test/arvo/progressive_attention_eval_test.exs

# Oracle (expected reward 1)
harbor run -p evals/ore-fff-locate-then-edit -a oracle
harbor run -p evals/arvo-attention-reread -a oracle

# Live Ore agent
harbor run -p evals/ore-fff-locate-then-edit -a ore \
  --agent-import-path evals.harbor_agents.ore_agent:OreAgent --ae XAI_API_KEY

# Live Arvo agent (attention on)
harbor run -p evals/arvo-attention-reread \
  -a evals.harbor_agents.arvo_agent:ArvoAgent \
  --ae XAI_API_KEY
# kwargs: attention=on|off via jobs-config or agent kwargs
```

Exact Harbor flags may vary by Harbor version; see prior job logs under
`evals/jobs/`.

## Design notes

### Arvo attention

- Adapter role matches Ore (setup / env / timeout / logs) but packaging is
  **release tarball** → `/opt/arvo` + `arvo-chat` on PATH (`HOME=/home/agent`).
- Treatment set **before** session open: `ARVO_PROGRESSIVE_ATTENTION` +
  `--attention on|off`.
- Scorers are pure over audit events (`evals/harbor_agents/attention_metrics.py`);
  task verifier embeds a copy under `tests/` for sandbox isolation.
- Residual Keepers metrics (`N_reexpand`, `B_reexpand`, deny actor split) are
  decision-ready (U6); see Decision-ready matrix above — not ship auto-unpark.

### Ore fff

- Project fixtures set `.ore/config.toml` → `profile = "search"` so boot
  auto-activates `fff`.
- Default profiles (`search.toml`) are seeded by `ore` via
  `ensure_default_profiles`.
- Prefer-plugin verifier: if no session JSONL tool activity (oracle), only
  `answer.txt` is checked; if the agent ran tools, `fff_search` must appear in
  session `tool_calls`.
- Locate-then-edit does **not** hard-require `fff_search` (end-to-end repair is
  primary); usage is recorded in `/logs/verifier/fff-usage.txt`.
