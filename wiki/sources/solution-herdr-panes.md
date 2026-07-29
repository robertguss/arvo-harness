---
title: "Source: Herdr pane registry ownership"
type: source
tags: [source, solution, herdr]
updated: 2026-07-29
sources:
  - docs/solutions/logic-errors/herdr-pane-registry-ownership-and-chrome-push.md
---

# Source: Herdr pane registry ownership and chrome push

**Path:** `docs/solutions/logic-errors/herdr-pane-registry-ownership-and-chrome-push.md`

## Core claim

Arvo-owned pane registry is session-local; registration before pane work;
tear-down on Esc/cancel/HEAD jump/resume/open_new so Herdr processes do not
outlive abandoned branches. Tile live status **pushed** from Session
(non-blocking), not pulled every paint.

## Wiki pages updated

- [[entities/herdr-panes]]
- [[concepts/agent-tile]]
- [[entities/tools]]
