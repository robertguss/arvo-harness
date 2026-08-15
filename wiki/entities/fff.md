---
title: FFF search plugin
type: entity
tags: [fff, plugin, search, arvo]
updated: 2026-08-15
sources:
  - lib/fff/
  - evals/README.md
---

# FFF (fuzzy file find / search)

Flagship **search** capability.

## Arvo

- Elixir bindings / plugin surface under `lib/fff/`
- Native: `native/fff_search/` (Rustler / precompiled `.so` under `priv/`)
- Shipped plugin example under `plugins/fff/`

Ore's `ore-plugin-fff` crate lives in
[ore-harness](https://github.com/robertguss/ore-harness).

## Relation

Extension vehicle: [[entities/profiles-plugins]]. Product: [[entities/arvo]].
