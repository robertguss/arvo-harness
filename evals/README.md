# Harbor evals (Arvo attention)

Arvo progressive-attention Harbor suite. Adapter:
`evals/harbor_agents/arvo_agent.py`. Artifact: **Mix release tarball** (ERTS).

Attention ship scores read `$HOME/.arvo/sessions/**/*.audit.jsonl` from the
Arvo product trail.

## Suite

### Progressive attention (`suite = arvo-attention`) — ship-ready U4

| Task | Capability | Primary reward |
| ---- | ---------- | -------------- |
| `arvo-attention-reread` | Large re-read + rename edit under attention **on** vs **off** | `task_ok` + treatment-aware **honesty** + on: stub/reuse signal; off: full_hot identity |
| `arvo-attention-small-control` | Tiny files + quick rename edit; every output below the stub threshold (does attention tax simple work?) | `task_ok` + treatment-aware **honesty** with `require_stub_reuse_on=False` (zero stubs is the honest outcome) |
| `arvo-attention-needle-junk` | One small relevant file among three ~95 KB archives the agent must read (does the firewall select, not just compress?) | `task_ok` (ParserFixed rename + archives intact) + treatment-aware **honesty**, default stub/reuse gate; `max_turns` 40 both arms |
| `arvo-attention-multifile` | Rename across three ~12 KB cross-referencing files with a mandated full re-read before each edit (does the cold shelf get reused instead of re-read?) | `task_ok` (unit_rate rename in all three files) + treatment-aware **honesty**; reuse_cold counts toward the stub/reuse gate |

**Ship metrics (KTD-M1)** from committed audit events:

| Metric | Pass rule |
| ------ | --------- |
| Honesty on | `treatment=on` + ≥1 projection when tools ran |
| Honesty off | `treatment=off` + `session_treatment` + ≥1 `full_hot` when tools ran |
| Task success | `big_module.ex` has `defmodule BigFixed do` + `PAYLOAD_TOKEN_7f3a9c` |
| Stub/reuse (on) | `N_stub + N_reuse ≥ 1` |
| Hot waste (paired) | `waste_ratio = B_full_on / max(B_full_off, 1) < 1.0` (compare on/off job metrics JSON) |

Task success and stub/reuse rows above are reread-specific. The control task
verifies `small_module.ex` has `defmodule SmallFixed do` + `PAYLOAD_TOKEN_2b8e4d`
and waives the stub/reuse requirement (`require_stub_reuse_on=False`): its
outputs all sit below the stub threshold, and its waste_ratio should read
~1.0, not < 1.0.

Needle-junk verifies `parser_rules.ex` has `defmodule ParserFixed do` +
`PAYLOAD_TOKEN_9d4e2f` and that the three archives keep their declarations and
markers. Distractor sizing matters: first reads ride the 80 KB
fidelity-exception budget into hot context and read chunks cap at 50 KB, so
junk must be sized ~95 KB per file for its chunks to overflow the budget and
stub (rationale in `evals/arvo-attention-needle-junk/tools/gen_workspace.py`).
Its verifier also copies the scored `*.audit.jsonl` into `/logs/verifier/`
for per-event forensics.

**Unit baselines (no Harbor network):**

```bash
mix test test/arvo/progressive_attention_eval_test.exs test/arvo/session_audit_test.exs

export PYTHONPATH=$PWD${PYTHONPATH:+:$PYTHONPATH}
python3 -m pytest evals/harbor_agents/test_attention_metrics.py -q
```

**Release + live Harbor:**

```bash
# 1) Build arch-matching Mix release (KTD-D1)
MIX_ENV=prod mix release arvo
# tarball: _build/prod/arvo-*.tar.gz  (or set ARVO_RELEASE)
# Arch-matching means the TASK IMAGE (Linux), not the host. On macOS build in
# a container (verified 2026-08-15):
#   mkdir -p _build/linux-release
#   docker run --rm -v "$PWD":/src:ro -v "$PWD/_build/linux-release":/out \
#     -v "$PWD/rel/docker-build-release.sh":/build.sh:ro \
#     hexpm/elixir:1.20.2-erlang-29.0.3-ubuntu-noble-20260610 bash /build.sh
#   export ARVO_RELEASE=$PWD/_build/linux-release/arvo-0.1.0.tar.gz

# 2) Oracle (task edit only; no attention honesty)
export PYTHONPATH=$PWD${PYTHONPATH:+:$PYTHONPATH}
# pipx-installed harbor IGNORES PYTHONPATH (its shim runs `python -E`).
# One-time fix per install:
#   echo "$PWD" > ~/.local/pipx/venvs/harbor/lib/python*/site-packages/arvo-evals.pth
harbor run -c evals/jobs-config/arvo-attention-reread-oracle.json -y

# 3) Attention on / off — XAI_API_KEY, or Grok OAuth (subscription)
harbor run -c evals/jobs-config/arvo-attention-reread-on.json -y --ae XAI_API_KEY
harbor run -c evals/jobs-config/arvo-attention-reread-off.json -y --ae XAI_API_KEY
# OAuth path (no API key): refresh + write an access-token-only store copy,
# then point the adapter at it. The container gets a ~6h access card, never
# the refresh token.
#   mix run --no-start evals/refresh_eval_auth.exs
#   ARVO_AUTH_FILE=/tmp/arvo-eval-auth.json harbor run \
#     -c evals/jobs-config/arvo-attention-reread-on.json -y
```

Compare `/logs/verifier/attention-metrics.json` (or job artifacts) for `b_full`
on vs off after both trials. Failures with tools but no treatment/projection
events are honesty fails (AE9).

Docs: `rel/RELEASE.md` (install layout, exit codes, audit glob).

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
mix test test/arvo/session_audit_test.exs
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

## Prerequisites

```bash
MIX_ENV=prod mix release arvo
# XAI_API_KEY or Grok OAuth store copy (ARVO_AUTH_FILE) for live agent trials
```

## Run patterns

```bash
mix test test/arvo/progressive_attention_eval_test.exs

harbor run -p evals/arvo-attention-reread -a oracle

harbor run -p evals/arvo-attention-reread \
  -a evals.harbor_agents.arvo_agent:ArvoAgent \
  --ae XAI_API_KEY
# kwargs: attention=on|off via jobs-config or agent kwargs
```

Exact Harbor flags may vary by Harbor version; see prior job logs under
`evals/jobs/`.

## Design notes

- Packaging is **release tarball** → `/opt/arvo` + `arvo-chat` on PATH
  (`HOME=/home/agent`).
- Treatment set **before** session open: `ARVO_PROGRESSIVE_ATTENTION` +
  `--attention on|off`.
- Scorers are pure over audit events (`evals/harbor_agents/attention_metrics.py`);
  task verifier embeds a copy under `tests/` for sandbox isolation.
- Residual Keepers metrics (`N_reexpand`, `B_reexpand`, deny actor split) are
  decision-ready (U6) — not ship auto-unpark.
