---
title: Session (Arvo product path)
type: entity
tags: [arvo, session, trust-spine]
updated: 2026-07-29
sources:
  - CONCEPTS.md
  - README.md
  - docs/solutions/logic-errors/session-product-path-trust-spine-races.md
  - lib/arvo/session.ex
---

# Session

Singleton GenServer that owns open session identity, append-only history, the
supervised product turn Task, cancel generation, and durable usage.

**Product interactive chat enters the agent only through Session-owned turns.**
Bare `Arvo.Agent.run` stays library/test territory.

Code: `lib/arvo/session.ex` (+ `session/` store, tokens, warm, cold,
compaction, handoff, audit).

## Owns

- Session file / JSONL tree
- [[concepts/product-turn-head|HEAD]] (`head_move` records)
- Product turn Task lifecycle (start → loop → persist → usage → idle)
- Cancel leaf policy ([[concepts/product-turn-head|cancel-as-fork]])
- Handoff transaction (new session + work-delta seed)
- Durable usage ledger
- Attention audit commit (Session sole durable audit writer — KTD-E1)

## Surfaces must not own

- Persist of assistant/tool rows
- Agent Task lifetime
- Identity/HEAD rewrites while turn-busy (resume, rewind, jump_to, open_new,
  rebind, handoff refused under live Task)

## Related UI

- [[entities/focus-tui|Focus]]: claims busy before spawn; steering while busy
- Tree navigator (`/tree`): jump HEAD to message node via `Session.jump_to/1`
- Deadlock class: Session must not wait on UI while UI waits on Session —
  [[sources/solution-deadlock]]

## Submodules (pointers)

| Module | Role |
| ------ | ---- |
| `Arvo.Session.Store` | Persistence |
| `Arvo.Session.Tokens` | Usage |
| `Arvo.Session.Warm` | Warm work-delta |
| `Arvo.Session.Cold` | Cold evidence bodies |
| `Arvo.Session.Handoff` | Handoff packet / rebind |
| `Arvo.Session.Compaction` | Compact power tool path |
| `Arvo.Session.Audit` | Audit trail helpers |

Progressive path: [[entities/progressive-attention]].

## Documented failure modes

[[sources/solution-trust-spine]]: mid-turn rebind races, fake SSE buffering,
cancel-after-success leaf, await_turn vs HTTP timeout, usage ledger gaps.
