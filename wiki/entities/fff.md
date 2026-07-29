---
title: FFF search plugin
type: entity
tags: [fff, plugin, search, ore, arvo]
updated: 2026-07-29
sources:
  - ore/README.md
  - ore/crates/ore-plugin-fff/
  - arvo/lib/fff/
  - evals/README.md
---

# FFF (fuzzy file find / search)

Flagship **search** capability for the harness twins.

## Ore

- Crate: `ore/crates/ore-plugin-fff/`
- InProcess plugin using native **fff-search** engine
- Registered through Ore plugin catalog / `OrePlugin` host

## Arvo

- Elixir bindings / plugin surface under `arvo/lib/fff/`
- Native: `arvo/native/fff_search/` (Rustler / precompiled `.so` under `priv/`)
- Shipped plugin example under `arvo/plugins/fff/`

## Evals

Harbor Ore suites exercise fff behaviors (locate, gitignore, prefer-plugin,
fuzzy path) via `evals/harbor_agents/ore_agent.py` and jobs under
`evals/jobs-config/ore-fff-*.json`. See [[entities/evals-harbor]].

## Relation

Extension vehicle: [[entities/profiles-plugins]]. Product: [[entities/ore]],
[[entities/arvo]].
