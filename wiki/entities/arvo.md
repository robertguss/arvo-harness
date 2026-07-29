---
title: Arvo
type: entity
tags: [arvo, elixir, product]
updated: 2026-07-29
sources:
  - README.md
  - CONTEXT.md
  - arvo/README.md
  - docs/adr/0001-elixir-beam-for-the-harness.md
  - docs/adr/0002-core-speaks-req-llm-types.md
---

# Arvo

Elixir/BEAM **coding-agent harness** product. Names the binary/command, user
global dir `~/.arvo/`, and project dir `.arvo/`.

Twin: [[entities/ore|Ore]] (Rust). Shared concept: [[concepts/harness|harness]].

## Where

| Item | Path |
| ---- | ---- |
| Mix project | `arvo/` |
| Core lib | `arvo/lib/arvo/` |
| Native FFF search (Arvo side) | `arvo/native/fff_search/`, `arvo/lib/fff/` |
| Prompts | `arvo/priv/prompts/` |
| Tests | `arvo/test/` |
| Release notes | `arvo/rel/RELEASE.md` |

## Run

```bash
cd arvo
export ARVO_CWD="$PWD"   # optional
bin/arvo                 # or: mix run --no-halt
mix test
```

Default interactive surface: **Focus** (raw Termite when TTY; line-mode
fallback). Repl is library/test fallback (`start_repl: true` if needed).

## Major modules (hubs)

| Module | Role |
| ------ | ---- |
| `Arvo.Session` | Product turn owner, JSONL, HEAD, cancel, handoff, usage |
| `Arvo.Agent` | Pure agent loop (not a process); driven by Session Task |
| `Arvo.Attention` | Progressive attention facade; Policy pure |
| `Arvo.TUI` / `Arvo.TUI.Focus` | Terminal UI / Focus surface |
| `Arvo.Tool` + `Arvo.Tools.*` | Core tools: read, write, edit, bash, pane, recall_evidence |
| `Arvo.Plugins.*` / `Arvo.Profiles` | Plugin load + profile activation |
| `Arvo.Providers.*` | Registry + completion over req_llm |
| `Arvo.Auth.*` | Device flow, token manager, store |
| `Arvo.Herdr` | Herdr CLI adapter for pane tools |
| `Arvo.Skills` | Progressive skill listing |

See: [[entities/session]], [[entities/focus-tui]], [[entities/progressive-attention]],
[[entities/profiles-plugins]], [[entities/tools]], [[entities/providers-auth]],
[[entities/herdr-panes]].

## Philosophy (product)

- Speed / minimal UX; agent tile not IDE chrome
- Esc cancels mid-turn; no permission popup stack in core
- Profiles over hard-coded mega-tool lists

## Architecture decisions

- [[sources/adr-0001-elixir-beam|ADR 0001]]: Elixir/BEAM for workshop + OTP + live profile load
- [[sources/adr-0002-req-llm|ADR 0002]]: core speaks `req_llm` types directly (no double provider abstraction)

## Product path invariants

1. Chat turns → `Session.start_turn` (not bare `Agent.run`)
2. Streaming SSE deltas; cancel mid-stream must not claim finished success
3. JSONL append-only; product history = root → HEAD
4. No silent auto-compact by default; `/handoff` preferred near limit
5. Same-cwd boot auto-resumes last non-empty session

Races and fixes: [[sources/solution-trust-spine]], [[sources/solution-deadlock]].

## Tests / evals

- Unit: `cd arvo && mix test`
- Attention: progressive attention + audit tests; Harbor suite in [[entities/evals-harbor]]
