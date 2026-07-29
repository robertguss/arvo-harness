---
title: Agent tile vs workspace chrome
type: concept
tags: [product, herdr, ux]
updated: 2026-07-29
sources:
  - CONCEPTS.md
  - README.md
---

# Agent tile vs workspace chrome

## Agent tile

Arvo’s product surface: conversation/agent window — Focus transcript, tools,
Esc, tree. Arvo is **one tile**, not an embedded multi-pane IDE.

## Workspace chrome

Tabs, splits, and sibling terminals owned by **Herdr** (or a sibling terminal
outside Herdr). Long-running interactive process UI lives here, not inside the
agent tile.

## Boundary

- Project browser, agent roster, permanent three-pane IDE → **not** Arvo’s job
- Ephemeral work panes Arvo opens → still chrome-side, tracked in Arvo’s pane
  registry → [[entities/herdr-panes]]

Related: [[entities/focus-tui]], [[entities/arvo]].
