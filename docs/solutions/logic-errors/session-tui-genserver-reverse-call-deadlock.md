---
title: "Session–TUI GenServer reverse-call AB-BA deadlock freezes cancel and turns"
date: 2026-07-28
category: logic-errors
module: "arvo Session / TUI"
problem_type: logic_error
component: assistant
severity: high
symptoms:
  - "TUI `/inspect`/`/memory`/`/recall` GenServer.call into Session while Session.apply_turn_result GenServer.calls TUI.put_tokens"
  - "AB-BA deadlock freezes Esc cancel, Focus slash, and mid-turn product work until process kill"
  - "Looks like a UI hang with no stacktrace until mutual GenServer.call waits are inspected"
root_cause: thread_violation
resolution_type: code_fix
tags:
  - session
  - tui
  - genserver
  - deadlock
  - cancel
  - progressive-attention
  - put_tokens
---

# Session–TUI GenServer reverse-call AB-BA deadlock freezes cancel and turns

## Problem

Progressive attention added `/inspect` and `/recall` slash handlers that call into `Arvo.Session` from inside TUI’s `handle_call({:slash, ...})`. Turn completion still updated the Focus token line via `Arvo.TUI.put_tokens/3` while Session held its own GenServer. When `put_tokens` was a synchronous `GenServer.call`, the two mailboxes deadlocked: Session waited on TUI, TUI waited on Session. Esc cancel, token paint, and slash inspect all froze.

## Symptoms

- Esc mid-turn freezes Focus until the BEAM processes are killed.
- `/inspect` / `/recall` hang if issued as a turn finishes and Session calls into TUI for tokens.
- No crash log — both GenServers sit in mutual `call` waits.
- Earlier product-path comments already said “do not call TUI while holding Session” on resume; progressive-attention slash reopened the reverse edge (TUI → Session under TUI’s mailbox).

## What Didn't Work

- **Trust-spine idle gates alone.** Idle-only rebind and “don’t call TUI from resume” closed wrong-session writes but did not force Session → TUI token updates to be non-blocking.
- **Leaving `put_tokens` as `GenServer.call` for simplicity.** Token paint does not need a synchronous reply from Session’s perspective; `call` made every successful turn completion a potential deadlock partner for any TUI slash that calls Session.
- **One-sided documentation without changing the product API.** Comments on resume/`profile_name` were necessary but incomplete until the product path used cast.

## Solution

**Cast tokens from Session → TUI.** Keep an optional `handle_call` for tests that need a sync put; product and Session paths use cast only.

### Product API is cast

```elixir
# arvo/lib/arvo/tui.ex — put_tokens/3
def put_tokens(turn, cumulative, window \\ 500_000) do
  # Cast so Session never GenServer.calls TUI while holding Session (AB-BA with slash).
  GenServer.cast(__MODULE__, {:put_tokens, turn, cumulative, window})
end

def handle_cast({:put_tokens, turn, cum, window}, state) do
  {:noreply, %{state | tokens: %{turn: turn, cumulative: cum, window: window}}}
end
```

### Session still paints tokens on turn success — without blocking

`apply_turn_result/2` and `maybe_record_usage/1` still call `Arvo.TUI.put_tokens/3` after usage is recorded. Because that API is cast, Session finishes its mailbox work even if TUI is mid-slash waiting on Session.

### Reverse edge (slash → Session) stays as call

`/inspect` and `/recall` still `GenServer.call` Session while TUI holds its mailbox. That is safe **only if** Session never `call`s back into TUI on concurrent product paths. Resume already documents the complementary rule; `profile_name/0` avoids TUI under Session for the same reason.

### Invariant

1. **Never** `GenServer.call` into TUI from Session `handle_*` (or any path that runs while Session holds its mailbox).
2. **Never** `GenServer.call` into Session from TUI if Session might still `call` TUI on any concurrent product path.
3. Prefer: **UI update from Session = cast / send only.**

## Why This Works

1. **Cast breaks the wait cycle.** Session enqueues `{:put_tokens, ...}` and continues. TUI can finish its Session `call`, then process the cast.
2. **Token freshness is eventually consistent**, which is correct for a status line.
3. **Slash and Esc keep synchronous Session calls** for correct replies; those calls are safe once Session → TUI is non-blocking.
4. **Matches the trust-spine lesson** with a single product API change: idle-only rebind closed TOCTOU; cast `put_tokens` closed lock-order inversion.

## Prevention

| Guard | What it locks |
| --- | --- |
| `TUI.put_tokens/3` → `GenServer.cast` only | Session product path cannot block on TUI |
| Resume / `profile_name` comments | Documents “do not call TUI while holding Session” |
| Process rule: UI update from Session = cast/send | Future status/spinner/token APIs stay non-blocking |
| Code review greps (below) | Catch new Session→TUI `call` or new reverse edges |

Suggested review greps:

```bash
rg 'Arvo\.TUI\.' arvo/lib/arvo/session.ex
rg 'Arvo\.Session\.' arvo/lib/arvo/tui.ex
rg 'put_tokens' arvo/
```

Optional regression: concurrent `/inspect` (or Esc) during `turn_done` / usage record — both processes stay responsive.

## Related Issues

- Sibling trust-spine cluster: [session-product-path-trust-spine-races.md](session-product-path-trust-spine-races.md) — idle-only rebind, cancel fidelity, SSE, durable usage, handoff atomicity, Focus claim; anticipates reverse-call risk without locking cast-only `put_tokens`.
- PR #5 — progressive attention / inspect-recall surface that reintroduced TUI → Session under TUI’s mailbox.
- PR #3 — product-path trust spine where “no TUI call under Session” on resume was first documented.
