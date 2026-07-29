---
title: "Source: ADR 0001 Elixir/BEAM"
type: source
tags: [source, adr]
updated: 2026-07-29
sources:
  - docs/adr/0001-elixir-beam-for-the-harness.md
---

# Source: ADR 0001 — Elixir/BEAM for the harness

**Path:** `docs/adr/0001-elixir-beam-for-the-harness.md`

## Decision

Choose Elixir/BEAM for Arvo over Rust for the workshop harness: OTP supervision,
live module load/unload for Profile activation, process-per-agent future,
iex daily tweak loop.

## Rejected

Rust/ratatui stronger paper choice for v0.1 (industry TUI default, static
binary). Rejected because those axes matter less than OTP learning for this
workshop tool.

## Consequences

- Hand-rolled TUI accepted cost
- Spec must not preclude multi-agent later
- Ore remains parallel Rust experiment for the other axis

## Wiki pages updated

- [[overview]]
- [[entities/arvo]]
- [[entities/ore]]
- [[concepts/harness]]
