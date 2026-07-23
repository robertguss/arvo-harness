# Arvo

A personal terminal coding-agent harness in Elixir/BEAM. Small core in the spirit of [pi](https://github.com/badlogic/pi-mono) and grok-build, extended through plugins bundled into **Profiles**.

This is a workshop tool — used daily, tweaked constantly, built to learn harness engineering. Rob architects and experiments; AI writes the code.

## Philosophy

- **Speed / minimal UX** — fast enough to feel native; nothing on screen that didn't earn its place.
- **TUI feel** — a polished terminal UI from day one, not a REPL.
- **Agent behavior** — good prompt, good tool contracts, self-repair through tool errors.
- **Hackable code** — small enough to rewrite weekly.

**Refusal list**: no permission popups, no shell-approval rails, no write confirmations, no plan mode, no todo tool, no MCP in core. Esc is the brake; containerization is the isolation story.

## Repo guide

| Path | What |
|---|---|
| [SPEC.md](SPEC.md) | Locked v0.1 specification |
| [CONTEXT.md](CONTEXT.md) | Normative vocabulary (Arvo, Tool, Plugin, Profile, Provider, Skill…) |
| [docs/adr/](docs/adr/) | Architecture decision records |
| [wayfinder/](wayfinder/) | The design process: research notes and the tickets that decided the spec |

## Status

Pre-code. The spec is locked; implementation is next.
