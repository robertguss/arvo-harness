---
title: Tools
type: entity
tags: [tools, arvo, ore]
updated: 2026-07-29
sources:
  - CONTEXT.md
  - lib/arvo/tool.ex
  - lib/arvo/tools/
---

# Tools

A **tool** is a capability the model invokes through the harness (read file, run
shell). Distinct from a **slash command**, which the *user* invokes from the TUI
(`CONTEXT.md`).

## Arvo core tools

From `Arvo.Tool` / `Arvo.Tools.*` (product set grows with attention/panes):

| Module | Role |
| ------ | ---- |
| `Arvo.Tools.Read` | Read files |
| `Arvo.Tools.Write` | Write files |
| `Arvo.Tools.Edit` | Edit files |
| `Arvo.Tools.Bash` | Shell |
| `Arvo.Tools.Pane` | Herdr pane tools for long-running/interactive work |
| `Arvo.Tools.RecallEvidence` | Pull cold evidence slices under caps |

Tool results on the product path pass through [[entities/progressive-attention]]
projection (stub vs full-hot, cold store, warm update).

## Pane tools vs bash

Pane tools wrap [[entities/herdr-panes|Herdr]] for long-running or interactive
work. Choice vs ordinary `bash` is a product decision (no auto-classifier). Not
a sub-agent primitive. Outside Herdr: labeled blocking bash fallback.

## Plugins

Plugins add tools via [[entities/profiles-plugins]]. Example: FFF search tools
from [[entities/fff]].

## Ore

Core tools under `ore-core` `tools` module; plugins extend via plugin host /
catalog.
