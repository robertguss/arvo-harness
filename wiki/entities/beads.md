---
title: Beads (bd)
type: entity
tags: [beads, process, tracking]
updated: 2026-07-29
sources:
  - AGENTS.md
  - CLAUDE.md
---

# Beads (bd)

Durable issue tracker for this repo. CLI: `bd`.

## Architecture (one line)

Issues live in a **local Dolt DB** (`.beads/dolt/`). Cross-machine sync uses
`bd dolt push/pull` under git remote `refs/dolt/data` — separate from
`refs/heads/*`. `.beads/issues.jsonl` is a **passive export**, not the wire
protocol.

Docs: [SYNC_CONCEPTS.md](https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md).

## Agent rules (repo)

- Use `bd` for **all** task tracking — not TodoWrite / markdown TODO lists
- `bd remember` for persistent knowledge — not MEMORY.md files
- Profile **minimal/conservative**: do not commit, push, or dolt sync unless
  human asks

## Quick commands

```bash
bd ready
bd show <id>
bd update <id> --claim
bd close <id>
bd prime
bd dolt push   # only when authorized
```

## Relation to wiki

Wiki is compounding **knowledge**. Beads is compounding **work**. File beads for
implementation follow-ups found during lint; do not use beads as a second wiki
index.
