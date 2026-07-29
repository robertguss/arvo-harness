---
title: Ore
type: entity
tags: [ore, rust, product]
updated: 2026-07-29
sources:
  - CONTEXT.md
  - ore/README.md
  - ore/crates/ore-core/src/lib.rs
---

# Ore

Rust **coding-agent harness** product (parallel experiment to [[entities/arvo|Arvo]]).
Names monorepo tree `ore/`, binary `ore`, dirs `~/.ore/` and `.ore/`.

Spec pointer: `SPEC-ore.md` (referenced from `ore/README.md`).

## Workspace layout

```
ore/
├── Cargo.toml              # workspace
├── justfile
├── rust-toolchain.toml
└── crates/
    ├── ore/                # binary package
    ├── ore-core/           # loop, tools, sessions, config, provider, plugin host
    ├── ore-tui/            # thin ratatui layer
    └── ore-plugin-fff/     # flagship InProcess search plugin
```

## Install / dev

```bash
# install
cargo install --path ore/crates/ore --locked --force
# or
cd ore && just install

cd ore
just build | test | ci | tui | login | stream 'Say hi'
```

## ore-core modules (hubs)

From `ore-core` lib: `agent`, `auth`, `compact`, `config`, `paths`, `plugin`,
`policy`, `profile`, `prompt`, `provider`, `session`, `skills`, `slash`, `tools`.

Plugin crates register via catalog in the `ore` binary (`OrePlugin`, hooks,
slash, tools). Flagship: [[entities/fff|FFF]] (`ore-plugin-fff`).

## Twin relationship

| Axis | Arvo | Ore |
| ---- | ---- | ---- |
| Language | Elixir/BEAM | Rust |
| TUI | Termite / hand-rolled Focus | ratatui (`ore-tui`) |
| Daily driver emphasis (repo README) | D1 Focus + Session trust spine | installable binary + fff plugin |
| Progressive attention evals | Primary Harbor attention product path | Ore jobs are **not** attention wins (AE9) |

Shared vocabulary in `CONTEXT.md`: Tool, Plugin, Profile, Provider, Skill,
Harness.

## Evals

Coding / fff-search Harbor tasks use `evals/harbor_agents/ore_agent.py` and host
`ore` binary upload. See [[entities/evals-harbor]].
