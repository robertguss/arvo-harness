---
title: Profiles and plugins
type: entity
tags: [plugin, profile, extension]
updated: 2026-07-29
sources:
  - CONTEXT.md
  - lib/arvo/profiles.ex
  - lib/arvo/plugin.ex
---

# Profiles and plugins

## Plugin

Unit of extension. A plugin can ship **tools**, **slash commands**, **hooks**,
and **skills**. Avoid: extension, addon (`CONTEXT.md`).

Arvo: `Arvo.Plugin`, `Arvo.Plugins.{Loader,Registry,Supervisor,Trust}`.
Ore: `ore_core::plugin` (`OrePlugin`, catalog, hooks, `HostIntent`).

## Profile

Named bundle of plugins activated together for a workflow (e.g. Python-dev,
Rust, data). **Exactly one** workflow profile active at a time, atop always-on
**base** profile. Rob’s coinage; reason the plugin seam exists.

- `/profile X` (idle-only) changes tools + skills + slash for the **next** turn
- Active plugins contribute tools + namespaced slash (`/plugin:cmd`)

## Skills

Packaged instructions (`SKILL.md`, agentskills.io). Progressive disclosure:
name + description + path listed to the model; full body read on demand — no
bulk SKILL inject.

Arvo: `Arvo.Skills`. Ore: `ore_core::skills`.

## Design note

Tool seam is wrapped (experiment surface). Provider wire is **not** double-wrapped
in Arvo — [[sources/adr-0002-req-llm]].

Flagship search plugin: [[entities/fff]].
