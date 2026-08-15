---
title: Evals and Harbor
type: entity
tags: [evals, harbor, attention]
updated: 2026-08-15
sources:
  - evals/README.md
  - evals/harbor_agents/
  - evals/jobs-config/
---

# Evals and Harbor

Harbor suite for Arvo progressive-attention ship metrics.

Tree: `evals/` — task suite, `harbor_agents/`, `jobs-config/`, `jobs/` artifacts.

| Suite | Agent adapter | Artifact |
| ----- | ------------- | -------- |
| Arvo progressive attention | `evals/harbor_agents/arvo_agent.py` | Mix release tarball (ERTS) |

Attention ship scores read `$HOME/.arvo/sessions/**/*.audit.jsonl` from the
Arvo product trail.

## Arvo attention suite (ship-ready U4)

Task `arvo-attention-reread`: large re-read + rename edit under attention **on**
vs **off**.

Primary reward mix: `task_ok` + treatment-aware **honesty** + on: stub/reuse;
off: full_hot identity. Hot waste: paired `B_full` on/off ratio `< 1.0`.

Unit baselines (no Harbor network):

```bash
mix test test/arvo/progressive_attention_eval_test.exs test/arvo/session_audit_test.exs
export PYTHONPATH=$PWD${PYTHONPATH:+:$PYTHONPATH}
python3 -m pytest evals/harbor_agents/test_attention_metrics.py -q
```

Live Harbor needs prod release + `XAI_API_KEY`; configs in
`evals/jobs-config/arvo-attention-reread-*.json`.

## Decision matrix notes

Ship quality and residual-need are **separate**. Attention quality alone must
not unpark Keepers (R12/R15). Residual metrics: reexpand counts, deny actor
split, causal stranding pairs.

## Related

[[entities/progressive-attention]], [[entities/fff]], [[entities/arvo]].
