# Decision-ready Harbor matrix (U6)

Ship jobs remain the on/off reread pair. Decision-ready **adds residual reading**
and a **causal stranding pair** (fixture or live).

## Required ship jobs (quality)

```bash
export PYTHONPATH=$PWD${PYTHONPATH:+:$PYTHONPATH}
harbor run -c evals/jobs-config/arvo-attention-reread-on.json -y --ae XAI_API_KEY
harbor run -c evals/jobs-config/arvo-attention-reread-off.json -y --ae XAI_API_KEY
```

Record for each trial:

- `task_ok`, honesty, `b_full` / stub-reuse from verifier metrics
- audit: `N_reexpand`, `B_reexpand`, `denied_expand` actors

## Causal stranding pair (minimum 1; prefer ≥3 live seeds)

Same instruction / seed twice:

| Arm | Recovery | Expect |
| --- | -------- | ------ |
| A | model `RecallEvidence` available (default) | task_ok, not `stranding_candidate` |
| B | recovery disabled or forced deny | task fail + stub stranded shape |

Attribute causal stranding only when A succeeds and B fails with stranded
shape (`causal_stranding_pair`).

Fixture-only verification (no network):

```bash
python3 evals/harbor_agents/test_attention_metrics.py
cd arvo && mix test test/arvo/session_audit_test.exs
```

## Park / unpark (human)

See `evals/README.md` Decision-ready matrix. Residual never auto-unparks.
