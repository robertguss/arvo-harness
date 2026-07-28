# Elixir/BEAM for the harness

The harness is a personal workshop tool where learning harness engineering is
co-equal with daily usability. We chose Elixir/BEAM over Rust: OTP supervision
and live-system design is the curriculum Rob wants, runtime module load/unload
is the natural fit for Profile activation, process-per-agent keeps future
multi-agent work open, and the iex loop suits a tool tweaked daily.

## Considered Options

Rust was the stronger paper choice for v0.1 — ratatui is the industry-default
TUI stack (grok-build and Codex CLI both build on it), and cargo ships one
static binary. Rejected because it optimizes the axes that matter least for a
workshop tool: we accept a hand-rolled differential terminal renderer (cribbing
pi's MIT ~12k-line design and grok-build's cell-diff flush), a fatter
distribution story, and TUI-vs-iex terminal contention as the price of the OTP
learning payoff.

## Consequences

- TUI is hand-rolled from day one; its internal design is a separate wayfinder
  effort after the v0.1 spec locks. The spec pins only the TUI↔core boundary.
- The v0.1 spec must not preclude multi-agent (process-per-agent) later.
- Decision record: wayfinder ticket
  [Pick the language](../../wayfinder/tickets/06-pick-the-language.md).
