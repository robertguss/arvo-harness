---
title: Project overview
type: overview
tags: [overview, arvo]
updated: 2026-08-15
sources:
  - README.md
  - CONTEXT.md
  - CONCEPTS.md
  - evals/README.md
---

# Arvo — overview

Personal terminal **coding-agent harness** in Elixir/BEAM. Workshop tool: used
daily, tweaked constantly, built to learn harness engineering. Small core in the
spirit of pi / grok-build; extension through plugins bundled into **profiles**.

Ore, the Rust twin, lives in
[ore-harness](https://github.com/robertguss/ore-harness). Shared domain
concept: [[concepts/harness|harness]] (agent loop, tools, TUI, plugin host,
providers). Avoid calling Arvo "the harness" in shipped UX once v0.1 lands
(`CONTEXT.md`).

**Language choice:** Elixir/BEAM is intentional curriculum (OTP, live load for
profiles) — [[sources/adr-0001-elixir-beam|ADR 0001]].

## What Arvo optimizes for

From `README.md` / D1 path:

- Speed / minimal UX; Focus TUI (ghost strip + transcript + input + footer)
- Agent behavior: good prompts, tool contracts, self-repair via tool errors
- Hackable code — small enough to rewrite weekly

**Refusal list:** no permission popups, no shell-approval rails, no write
confirmations, no plan mode, no todo tool, no MCP in core. Esc is the brake;
containerization is isolation.

**Not Arvo's job:** project browser, agent roster, embedded shell, permanent
three-pane IDE — that is [[concepts/agent-tile|workspace chrome]] / Herdr.

## Trust spine (product chat)

Interactive product chat must go through [[entities/session|Session]]-owned
turns (`Session.start_turn`), not bare `Agent.run`. Key ideas:

- Append-only JSONL + explicit [[concepts/product-turn-head|HEAD]]
- Cancel-as-fork; handoff as work-delta packet to a new session
- Default: no silent auto-compact; prefer `/handoff` near limit

Documented race fixes: [[sources/solution-trust-spine]].

## Progressive attention

[[entities/progressive-attention|Progressive attention]] is harness-owned
management of model context: budgeted hot, structured warm work-delta,
addressable cold evidence, context firewall (stubs by default). Distinct from
a markdown knowledge base and from optional Keepers caches.

Eval path: [[entities/evals-harbor|Harbor evals]] + audit JSONL honesty metrics.

## Extension model

[[entities/profiles-plugins|Profiles + plugins]]: plugins ship tools, slash
commands, hooks, skills; exactly one workflow profile active atop always-on
`base`. Flagship search plugin story: [[entities/fff|FFF]].

## Process & docs

- Vocabulary: `CONTEXT.md` (names), `CONCEPTS.md` (process glossary)
- Learnings: `docs/solutions/`
- This wiki: compiled synthesis under `wiki/` per [[wiki/AGENTS|schema]]

## Repo map (short)

| Path | Role |
| ---- | ---- |
| `lib/arvo/` | Mix project core |
| `evals/` | Harbor attention suite |
| `docs/adr/` | Architecture decisions |
| `docs/solutions/` | Compounded bug/practice writeups |
| `wiki/` | This LLM wiki |

## Status snapshot

- D1 daily-driver path implemented (Focus, Session turns, streaming, HEAD,
  rewind/tree, handoff, thin profiles) per root `README.md`.
- Progressive attention + Harbor attention suite active in `evals/`.
- Keepers and some residual-need matrix rows remain decision-gated by eval
  evidence (see evals README) — do not unpark from wiki alone.
