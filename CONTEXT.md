# Coding Agent Harness

A personal terminal coding-agent harness — a workshop tool Rob uses daily and tweaks constantly to learn harness engineering. Small core in the spirit of pi and grok-build, extended through plugins.

## Language

**Arvo**:
The Elixir harness product. Names the binary/command, the user-global dotdir (`~/.arvo/`), and the per-project dir (`.arvo/`).
_Avoid_: "the harness" in user-facing surfaces once v0.1 ships; do not use for the Rust twin

**Ore**:
The Rust harness product (parallel experiment to Arvo). Names the monorepo sibling tree (`ore/`), binary/command, user-global dotdir (`~/.ore/`), and per-project dir (`.ore/`).
_Avoid_: "the Rust harness" in user-facing surfaces once v0.1 ships; do not use for the Elixir twin

**Harness**:
The machinery either product builds: agent loop, tool dispatch, TUI, plugin host, provider adapters. Shared domain concept across Arvo and Ore.
_Avoid_: CLI wrapper, framework

**Tool**:
A capability the model can invoke through the harness (read a file, run a shell command).
_Avoid_: function, command

**Slash command**:
A command the *user* invokes from the TUI. Distinct from a Tool, which the *model* invokes.

**Plugin**:
The unit of extension. A plugin can ship tools, slash commands, hooks, and skills.
_Avoid_: extension, addon

**Profile**:
A named bundle of plugins activated together for a specific workflow — e.g. a Python-dev profile, a Rust profile, a data profile. Exactly one is active at a time, atop the always-on `base` profile. Rob's coinage; the reason the plugin seam exists.
_Avoid_: preset, mode, workspace

**Base profile**:
The reserved profile that is always active regardless of the workflow profile; home for plugins wanted everywhere.

**Provider**:
An adapter to a model backend. v0.1 ships one (xAI/grok subscription); Codex and local OSS models arrive later through the same seam.
_Avoid_: backend, model

**Skill**:
Packaged instructions (SKILL.md, agentskills.io standard) shipped by a plugin or placed by the user; listed to the model by name and description, read in full on demand.
_Avoid_: prompt, snippet
