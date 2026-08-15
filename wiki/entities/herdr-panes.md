---
title: Herdr and panes
type: entity
tags: [herdr, panes, arvo]
updated: 2026-07-29
sources:
  - CONCEPTS.md
  - docs/solutions/logic-errors/herdr-pane-registry-ownership-and-chrome-push.md
  - lib/arvo/herdr.ex
  - lib/arvo/tools/pane.ex
---

# Herdr and panes

## Split of concerns

| Concept | Owner |
| ------- | ----- |
| [[concepts/agent-tile\|Agent tile]] | Arvo (Focus transcript, tools, Esc, tree) |
| Workspace chrome | Herdr (or sibling terminal): tabs, splits, shells |
| Ephemeral work pane | Herdr sibling pane Arvo opens for long/interactive tool work |

Arvo is one tile, not an embedded multi-pane IDE.

## Ephemeral work pane

Not a sticky session shell. Finite jobs close after process exit and capture;
intentionally long-lived jobs may return running-state to the model while the
pane stays open. Esc and HEAD jump tear down Arvo-owned panes so processes do
not outlive abandoned conversation branches.

## Arvo-owned pane registry

Session-local map of pane ids Arvo opened for the current live session.
Registration is a precondition of running work in a split pane. Tear-down on
Esc, cancel, HEAD jump, resume, open_new. Tile live status is **pushed** from
Session to the agent tile (non-blocking), not pulled on every paint.

Code: `Arvo.Herdr`, `Arvo.Herdr.CLI` / `Adapter` / `Fake`, `Arvo.Tools.Pane`.

## Documented solution

[[sources/solution-herdr-panes]]: registry ownership and chrome push patterns.
