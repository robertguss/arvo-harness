---
title: Progressive attention
type: entity
tags: [arvo, attention, context]
updated: 2026-07-29
sources:
  - CONCEPTS.md
  - evals/README.md
  - lib/arvo/attention.ex
  - lib/arvo/attention/policy.ex
---

# Progressive attention

Harness-owned management of what the model sees each turn: budgeted **hot**
context, structured **warm** work-delta, and session-complete addressable
**cold** evidence.

Not a permanent mind and not a markdown knowledge base. “Learning” here means
reuse of cold evidence plus warm state. Distinct from Keepers (optional live
process cache over cold).

Code: `Arvo.Attention` (facade), `Arvo.Attention.Policy` (pure policy),
session warm/cold modules. Enable flags: Application env
`:progressive_attention`, else `ARVO_PROGRESSIVE_ATTENTION`, default **on**.

## Stack

| Layer | What | Notes |
| ----- | ---- | ----- |
| Hot | Budgeted messages model receives | Stubs by default for large tools |
| Warm | Structured workshop state (paths, exits, failures, goal) | From tool/session trace; handoff snapshots it |
| Cold | Full tool bodies under stable ids | Expand/recall under caps; session-scoped v1 |

See [[concepts/hot-warm-cold]].

## Context firewall

Product policy: large tool results enter hot as **stubs** by default; full
bodies land in cold. Enforced by harness, not model self-discipline. Fidelity
exceptions (small, error, pin, edit targets) keep coding usable.

## Dual view

Human transcript may stay rich while model hot stays progressive. Honesty =
label what the model saw (and attention evidence stream), not force identical
dumps. See [[concepts/dual-view]].

## Attention evidence stream

Session-scoped durable record of access decisions (store/reuse cold, stub vs
full-hot, fidelity exceptions, warm updates, expand/recall, denied expand).
Powers operator TUI visibility and Harbor-capable evals. Not bulk-injected into
hot as scripture.

Session is sole durable audit writer; Attention returns typed candidate events.

## Tools

- Core projection path on tool results inside product turns
- `Arvo.Tools.RecallEvidence` — expand/recall from cold

## Evals

[[entities/evals-harbor]] suite `arvo-attention-reread`: on vs off treatment,
honesty metrics, stub/reuse, hot waste ratio. Ore adapter misuse is honesty
fail (AE9).

## Keepers

Optional future live cache over cold. **Do not unpark from attention quality
alone** (R12/R15) — residual-need matrix is separate.
