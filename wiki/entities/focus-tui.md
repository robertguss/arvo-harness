---
title: Focus TUI
type: entity
tags: [arvo, tui, focus]
updated: 2026-07-29
sources:
  - README.md
  - CONCEPTS.md
  - lib/arvo/tui.ex
  - lib/arvo/tui/focus.ex
---

# Focus TUI

Arvo’s default interactive surface: Focus mode (prototype D) — ghost strip +
transcript + input + footer as one [[concepts/agent-tile|agent tile]].

Code: `Arvo.TUI`, `Arvo.TUI.Focus`, render/markdown/commands/slash_menu/theme.

## Behavior

| Input | Effect |
| ----- | ------ |
| Enter | Send chat / submit slash |
| Esc | Cancel in-flight turn Task (Session stays up) |
| `/help` | Commands |
| `/model` | Show/set model |
| `/profile` | Switch workflow profile (idle-only) |
| `/resume` | List/resume sessions |
| `/rewind` | Move HEAD back n steps (thin alias over head_move) |
| `/tree` | Tree navigator; jump HEAD to message node |
| `/handoff` | New session with work-delta packet |
| `/compact` | Power tool (not silent auto) |
| `/login` | Device-flow OAuth |
| `/quit` | Exit |

Raw Termite when TTY; line-mode fallback otherwise. Repl is not the product
default.

## Focus claim

Synchronous UI busy claim before fire-and-forget product chat spawn. Blocks
double-Enter; mid-busy input becomes **steering**. Complements Session’s real
`start_turn` mutex — does not replace it.

## Reverse-call deadlock

Session-driven status paint into Focus must not wait on the UI process while the
UI can wait on Session. Documented: [[sources/solution-deadlock]].

## Relation

- Turn dispatch → [[entities/session]]
- Agent tile vs chrome → [[concepts/agent-tile]]
- Herdr sibling panes → [[entities/herdr-panes]]
