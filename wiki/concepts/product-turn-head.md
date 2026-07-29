---
title: Product turn, HEAD, cancel, handoff
type: concept
tags: [session, head, turn]
updated: 2026-07-29
sources:
  - CONCEPTS.md
  - README.md
---

# Product turn, HEAD, cancel, handoff

Normative glossary: `CONCEPTS.md`. Owner entity: [[entities/session]].

## Product turn

One supervised Task lifecycle: start → model/tool loop → result → persist
assistant/tool rows → usage ledger → idle (or cancel leaf). Surfaces dispatch
start/cancel/steer; they do not own persist or Agent lifetime.

## HEAD

Explicit attention pointer on the session JSONL tree (`head_move` records), not
merely the last file line. Product context and next parent_id walk **root →
HEAD**. Abandoned forks stay on disk, off the hot path.

Primary nav: tree navigator / `Session.jump_to/1`. `/rewind` is thin alias over
the same head-move path.

## Cancel-as-fork

Esc mid-turn kills in-flight work and appends an **incomplete** assistant leaf
so HEAD stays coherent, without claiming finished success. Prefer preserving an
already-finished success over writing a cancel leaf when the Task completed
first.

## Handoff

Creates a **new** session seeded only by a structured work-delta packet; parent
JSONL intact. Must run as one idle-only Session transaction (no race with live
turn).

## Turn-busy

Session’s live-Task predicate: refuse identity/HEAD rewrites (resume, rewind,
jump_to, open_new, rebind, handoff) while a product turn runs.

## Related

[[entities/focus-tui]], [[sources/solution-trust-spine]],
[[concepts/hot-warm-cold]] (warm packet on handoff).
