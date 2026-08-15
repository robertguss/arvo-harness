---
title: "Herdr panes need registry-first ownership and Session→TUI push chrome"
date: 2026-07-28
category: logic-errors
module: "arvo Session / Tools.Pane / Herdr / TUI"
problem_type: logic_error
component: assistant
severity: high
symptoms:
  - "Split pane left open after Session.register_pane failed; Esc/HEAD never closed it"
  - "Resume rebinding left prior long_lived panes registered without abandon teardown"
  - "Empty Herdr process_info list treated as process exit; reaper closed mid-spawn"
  - "Pane teardown written as incomplete assistant messages entered model/jumpable history"
  - "TUI live-pane chrome refreshed via Session.owned_panes GenServer.call from cast handlers"
root_cause: logic_error
resolution_type: code_fix
tags:
  - herdr
  - pane
  - session
  - tui
  - genserver
  - ownership
  - teardown
  - process-info
related_components:
  - tooling
---

# Herdr panes need registry-first ownership and Session→TUI push chrome

## Problem

Shipping first-class Herdr **pane** tools required Arvo to own sibling terminal processes for Esc/HEAD teardown and tile chrome. Early paths split panes before registry ownership was guaranteed, treated ambiguous process-info as “exited,” wrote teardown into model-facing history, and risked reopening Session↔TUI reverse-call pressure when refreshing live chrome.

## Symptoms

- A successful `herdr pane split` with a failed `Session.register_pane` still ran or left the pane open; cancel/jump registry never saw the id.
- After `Session.resume/1`, panes from the previous live conversation could remain in `owned_panes` without an abandon teardown (unlike `open_new`).
- `Arvo.Herdr.process_exited?/1` returned true for `foreground_processes: []`, so finite wait / reaper could close during mid-spawn empty process lists.
- Teardown notes stored as incomplete `role: assistant` messages with non-empty content rehydrated into model history and looked jumpable as assistants.
- Paint/cast paths that `GenServer.call` Session for `owned_panes` from TUI (or cast handlers that immediately call back into Session) recreated the pressure class documented in the reverse-call deadlock learning.

## What Didn't Work

- **Swallowed register errors after split.** Continuing to `run` after `{:error, _}` (or an EXIT when Session is down) created unregistered orphans that product teardown cannot find.
- **Resume only rebinding history/tokens.** Clearing conversation HEAD without tearing down live Herdr ownership left processes and registry entries from the abandoned live session.
- **`Enum.all?([], …)` as process-exit.** Empty lists are true under `Enum.all?`, so “no processes yet” looked like “only shells / done.”
- **Incomplete assistant leaves for operator notes.** Non-empty incomplete assistants still rehydrate for humans/model paths; they are the wrong durability channel for teardown audit.
- **Pull chrome from TUI on every need.** Even a cast-first Session→TUI edge fails the invariant if the cast handler turns around and `call`s Session for the same list (and paint-time pull burns GenServer traffic).

## Solution

### 1. Registry-first after split

Only `run` after `register_pane` succeeds. On register failure or EXIT, close the pane immediately and return a tool error.

```elixir
# lib/arvo/tools/pane.ex — run_in_herdr/6 (pattern)
reg =
  try do
    Arvo.Session.register_pane(%{pane_id: pane_id, mode: mode, command: command, start_reaper: false})
  catch
    :exit, reason -> {:error, reason}
  end

case reg do
  :ok ->
    # run → finite or long_lived lifecycle
    ...

  {:error, reason} ->
    _ = Arvo.Herdr.close(pane_id)
    {:error, "pane register failed: #{inspect(reason)}"}
end
```

Long-lived reapers still start **after** running-state return (`ensure_pane_reaper/1`), not at register, so early shell-only process-info cannot close mid-start.

### 2. Tear down on resume (and open_new)

`handle_call({:resume, …})` runs `do_teardown_owned_panes(state, :resume)` before rebinding path/history, then forces `owned_panes: %{}`. Same abandon class as HEAD jump / `open_new`.

### 3. Empty process_info is not exited

```elixir
# lib/arvo/herdr.ex
def process_exited?(%{foreground_processes: []}), do: false

def process_exited?(%{foreground_processes: procs}) when is_list(procs) do
  Enum.all?(procs, fn p -> shell_name?(to_string(p["name"] || p[:name] || "")) end)
end
```

Finite wait still uses a short start grace before treating shell-only as exit when no non-shell was ever seen.

### 4. Teardown as non-message audit rows

Durable notes use `type: "pane_teardown"` with `content` for operators/history, **without advancing HEAD** and without `role: assistant`. Operator-visible TUI system lines still surface idle Esc / jump results. Logger keeps a structured line for grepping.

### 5. Session pushes live chrome with a cast payload

While holding Session, never `GenServer.call` TUI. For pane chrome, push the list:

```elixir
# lib/arvo/session.ex
defp notify_pane_chrome(state) do
  case Process.whereis(Arvo.TUI) do
    pid when is_pid(pid) ->
      GenServer.cast(pid, {:set_live_panes, owned_panes_list(state)})
    _ ->
      :ok
  end
end
```

```elixir
# lib/arvo/tui.ex
def handle_cast({:set_live_panes, panes}, state) when is_list(panes) do
  {:noreply, %{state | live_panes: panes}}
end
```

Render reads `state[:live_panes]` only (no paint-time Session pull). This extends the Session→TUI cast invariant from token paint (`put_tokens`) to live-pane chrome.

## Why This Works

- **Ownership is a precondition of work.** Esc/HEAD can only kill what the registry knows; split without register is an orphan by definition.
- **Session rebind is an abandon boundary.** Resume and open_new change which conversation is live; Herdr processes must not outlive that abandon.
- **Exit detection needs a real process set.** Empty ≠ shell-only; mid-spawn gaps are normal.
- **Audit ≠ assistant speech.** Model HEAD and jumpability stay coherent when teardown is not a message leaf.
- **One-way Session→TUI updates stay non-blocking.** Cast with payload avoids AB-BA with TUI→Session slash/Esc paths (same root class as the put_tokens fix).

## Prevention

- **Invariant:** After any `Herdr.split` that Arvo intends to own, either `register_pane` succeeds or the pane is closed before the tool returns.
- **Invariant:** Session `open_new` / `resume` / `jump_to` (non-noop) / `cancel_turn` / idle Esc always clear or close Arvo-owned panes.
- **Invariant:** Session must not `GenServer.call` TUI; TUI cast handlers for chrome must not `call` Session for the same data when Session can still be on the stack.
- **Tests:** register-failure closes + errors; resume tears down prior panes; jump leaves `type: "pane_teardown"` audit rows; idle live chrome after long_lived register.
- **Do not** use `Enum.all?` over possibly empty process lists as “exited” without an explicit empty clause.

## Related Issues

- [Session–TUI GenServer reverse-call AB-BA deadlock](./session-tui-genserver-reverse-call-deadlock.md) — cast invariant for Session→TUI; this doc applies it to pane chrome with payload push.
- [Session product-path trust-spine races](./session-product-path-trust-spine-races.md) — cancel / HEAD coherence; pane teardown hooks into the same cancel and jump paths.
- Plan: `docs/plans/2026-07-28-001-feat-herdr-pane-transparency-plan.md` (U1–U6); review fixes on PR #7.
