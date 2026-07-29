---
title: "Source: session trust-spine races"
type: source
tags: [source, solution, session]
updated: 2026-07-29
sources:
  - docs/solutions/logic-errors/session-product-path-trust-spine-races.md
---

# Source: Session product-path trust-spine races

**Path:** `docs/solutions/logic-errors/session-product-path-trust-spine-races.md`  
**Type:** logic_error / high — `arvo Session / product path`

## Problem cluster (PR #3 D1)

1. Mid-turn `/resume` `/rewind` rebind wrote rows on wrong session/HEAD (no
   turn_task guard).
2. Live SSE used full-body buffered POST so deltas fired only after download.
3. `cancel_turn` always wrote cancel leaf even after successful finish.
4. `await_turn` 60s vs HTTP 120s → GenServer timeout.
5. start_turn updated TUI tokens but not durable usage ledger.

## Root cause class

Async timing / missing turn-busy guards / incomplete persist paths.

## Wiki pages updated

- [[entities/session]]
- [[concepts/product-turn-head]]
- [[entities/focus-tui]]
- [[entities/arvo]]
