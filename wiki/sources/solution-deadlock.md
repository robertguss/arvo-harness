---
title: "Source: Session-TUI reverse-call deadlock"
type: source
tags: [source, solution, tui]
updated: 2026-07-29
sources:
  - docs/solutions/logic-errors/session-tui-genserver-reverse-call-deadlock.md
---

# Source: Session ↔ TUI GenServer reverse-call deadlock

**Path:** `docs/solutions/logic-errors/session-tui-genserver-reverse-call-deadlock.md`

## Core claim

Session-driven status paint into Focus must **not** wait on the UI process while
the UI can wait on Session. That reverse-call wait is a **deadlock class**, not
a cosmetic freeze (`CONCEPTS.md` Focus claim / dual-path notes).

## Wiki pages updated

- [[entities/focus-tui]]
- [[entities/session]]
- [[concepts/agent-tile]]
