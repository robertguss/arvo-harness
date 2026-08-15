---
title:
  "Session product-path trust-spine races: mid-turn rebind, cancel, SSE, and
  handoff"
date: 2026-07-27
category: logic-errors
module: "arvo Session / product path"
problem_type: logic_error
component: assistant
severity: high
symptoms:
  - "`/resume` and `/rewind` mid-turn rebind wrote assistant rows onto the wrong
    session/HEAD because turn_task was not guarded"
  - "Live SSE used Req.post full-body buffering so on_delta fired only after
    download completed (not a true stream)"
  - "cancel_turn always wrote a cancel leaf even when the task had already
    finished, discarding a successful persist"
  - "await_turn default 60s vs HTTP 120s caused GenServer timeout before the
    request completed"
  - "start_turn success updated TUI tokens but not the durable usage ledger, so
    resume showed 0 cumulative"
root_cause: async_timing
resolution_type: code_fix
tags:
  - session
  - cancel
  - sse
  - handoff
  - focus
  - resume
---

# Session product-path trust-spine races: mid-turn rebind, cancel, SSE, and handoff

## Problem

PR #3 (`feat/arvo-d1-daily-driver`) owns Arvo’s product interactive turn spine:
Focus (or Repl) dispatches chat into `Arvo.Session.start_turn/3`, which
supervises an `Agent` Task, owns success persist and usage, and returns to idle.
Code review of that branch found a cluster of **trust-spine races**—not cosmetic
TUI issues, but places where mid-turn session rebinding, cancel, streaming, and
usage ledger behavior could corrupt HEAD, discard good work, or lie about token
state after resume.

The underlying pattern is the same everywhere: **product mutations that touch
session identity, HEAD, or durable ledger must be idle-only or atomic under the
Session GenServer**, cancel must prefer a finished success over a cancel leaf,
streaming must deliver deltas as bytes arrive, and the UI must claim busy
_before_ spawn so double-Enter steers instead of racing a second turn.

## Symptoms

1. **Mid-turn rebind / wrong-session write.** `/resume`, `/rewind`, and
   `open_new` could run while a turn Task was still alive. The GenServer rebound
   `path` / `last_id` / `history` under a live Task; when the Task completed,
   `apply_turn_result` appended assistant rows onto the newly bound session or
   the wrong HEAD. Same class of TOCTOU for multi-step handoff (create child →
   seed packet → parent marker → rebind) if `start_turn` interleaved between
   steps.

2. **SSE not incremental.** Live completions used a full-body HTTP collect path.
   `on_delta` only fired after the entire response was buffered, so Focus looked
   frozen until the model finished, then dumped text at once. Unit tests that
   fed a complete SSE body still “passed” while production felt non-streaming.

3. **Cancel clobbering success.** `cancel_turn` always treated the request as
   “kill + incomplete cancel leaf,” even when the Task had already finished and
   was about to (or already had) delivered a success result. Users Esc’d late
   and lost a valid assistant row, or got both a cancel leaf and confusion about
   whether the turn succeeded.

4. **`await_turn` timeout vs HTTP.** Default await sat below the HTTP
   `receive_timeout` (120s). Long single-complete calls caused GenServer call
   timeouts while the Task was still healthy—false failure, orphaned Task
   bookkeeping risk.

5. **Usage in TUI only.** Success path updated in-memory / TUI tokens but did
   not always append a durable `usage` JSONL entry. Resume rehydrated cumulative
   tokens as 0 even after expensive turns.

6. **Auto-resume restored profile _name_ only.** Same-cwd auto-resume rebound
   Session meta (`profile: "search"`) without re-running profile activation, so
   tools/skills from the named profile did not match what the meta claimed.

7. **Double-Enter race on Focus.** Enter submitted chat via fire-and-forget
   `Task.start` before any UI claim. A second Enter before `agent_start` /
   Session mutex could spawn a second product path or race recording; steering
   was the intended mid-turn behavior, but the busy gate was too late.

## What Didn't Work

- **Surface-only guards** (TUI slash checks without Session turn-busy) left
  library/Repl and concurrent GenServer callers free to rebind under a live
  Task. The mutex has to live where `turn_task` lives.
- **Buffered SSE with post-hoc parse** satisfied unit tests (`parse_sse_stream`
  on a full body) without proving incremental delivery. The production default
  HTTP function had to use Req’s `into:` callback and call `on_delta` per
  completed line as chunks arrived.
- **Unconditional cancel leaf** looked correct for “Esc means cancel” until the
  race where Task completion and Esc crossed. Preferring success when
  `Task.shutdown` returns `{:ok, result}` (or the Task is already dead with a
  drainable `{:turn_done, gen, result}`) is required for cancel fidelity.
- **Multi-call handoff from the surface** (`create` then `append` then `rebind`
  across separate GenServer calls) could not be made race-free with “please only
  handoff when idle” documentation alone. Idle check + full
  create/seed/marker/rebind must be one Session call.
- **Focus spawning first, claiming later** still allowed double-Enter between
  key handlers. UI claim must be synchronous (`try_begin_turn`) before
  `spawn_chat`.

## Solution

Center line: **Session is the product mutex**. Surfaces only dispatch; idle-only
mutations, cancel fidelity, real SSE, durable usage, atomic handoff, and Focus
claim sit on that spine. Fixes landed on `feat/arvo-d1-daily-driver` (PR #3)
after review; later cleanup unified the SSE pipeline, `Tokens.input_output/1`,
the handoff packet builder, and `Store.tip/1` over entry lists.

### 1. Idle-only guards on identity / HEAD mutations

`turn_busy?/1` is true when `state.turn_task` is a live Task
(`lib/arvo/session.ex` — `turn_busy?/1`). `open_new`, `resume`, and
`rewind` reject with `{:error, :turn_in_progress}` when busy. `rebind/1` and the
handoff call path use the same gate. Public `turn_in_progress?/0` exposes the
probe for TUI (e.g. idle-only profile switch). `start_turn` remains a second
mutex: if a Task is already alive, reply `{:error, :turn_in_progress}` without
spawning another.

### 2. Incremental SSE: Req `into:` + unified `feed_sse_chunk`

Product path sets `"stream" => true` and routes through `request_sse` →
`default_http_stream/4`. The default HTTP function streams body chunks into an
accumulator and feeds the same line parser used by tests
(`lib/arvo/providers/completion.ex` — `default_http_stream/4`,
`feed_sse_chunk/3`). `feed_sse_chunk` maintains a line buffer across TCP chunk
boundaries, parses complete `data:` lines, and invokes `on_delta` per non-empty
text delta. `parse_sse_stream/2` is the same pipeline over a full body for
inject/unit tests. Successful incremental responses return
`%{status, parsed: ...}` so `on_delta` is not double-fired on a second full
parse.

### 3. Cancel fidelity: only kill live work; keep finished success

`cancel_turn` prefers success persist when the Task is already dead (drain
pending `{:turn_done, gen, result}`) or when `Task.shutdown` returns
`{:ok, result}`. Only a still-live Task that is hard-killed gets a cancel leaf +
`cancelled_generation`. Generation tracking drops late success after a true
cancel. True cancel still writes an incomplete cancel leaf so HEAD stays
coherent.

### 4. `await_turn` default `:infinity`

HTTP receive timeout is 120s per complete; multi-tool loops need longer than any
short GenServer default. `await_turn/1` defaults to `:infinity` with a matching
GenServer call timeout.

### 5. Durable usage ledger via `maybe_append_usage_ledger` + `Tokens.input_output`

On successful turn completion, Session persists new assistant/tool rows,
normalizes provider usage keys, updates in-memory tokens, **and** appends a
usage ledger entry when input+output > 0. `Tokens.input_output/1` accepts both
`input_tokens`/`output_tokens` and provider `prompt_tokens`/`completion_tokens`.
Resume rebuilds tokens by scanning usage rows in history.

### 6. Auto-resume re-applies profile

`maybe_auto_resume` calls `Profiles.reapply/1` after a successful
`Session.resume` so meta.profile matches live tools/skills (not name-only).

### 7. Focus `try_begin_turn` claim before spawn; double Enter steers

TUI owns a local UI claim so busy state is set before the async product Task
starts. Focus: `try_begin_turn` success → `spawn_chat`; busy → `Session.steer`.
Session remains the real `start_turn` mutex. Product chat never calls bare
`Agent.run`.

### 8. Atomic `Session.handoff/1`

Surface handoff routes into a single GenServer call: idle check, create child,
seed packet, best-effort parent marker, allowlisted rebind. Surfaces must not
multi-step handoff across separate Session calls.

### 9. Product-path architecture locks (Focus + Repl)

`product_path_test` freezes the spine: both Repl and Focus source must use
`Session.start_turn` and must not call `Agent.run`. Runtime spine tests cover
Session-owned persist, Esc/cancel, cancel after tool start, agent exception
leaving Session idle, and mid-turn steering.

### Later simplify (same trust model)

- Unified SSE pipeline: live and test paths share `feed_sse_chunk` /
  `finalize_sse_acc`.
- `Tokens.input_output/1` as the one usage-key normalizer.
- Handoff packet builder centralized on `Arvo.Session.Handoff`.
- `Store.tip/1` accepts path or in-memory entries (resume avoids double disk
  read for tip).

## Why This Works

1. **Single owner of turn lifetime.** Session alone holds `turn_task`,
   generation, prior_len, and path. Identity mutations that change path/HEAD
   under a live Task are refused, so success persist always lands on the session
   that started the turn.

2. **Cancel is a state machine, not a side effect.** Dead Task + drained success
   → persist success; live Task + hard kill → cancel leaf + cancelled
   generation; late `turn_done` after cancel → no success persist. That removes
   the “Esc after finish deletes good work” class of bugs without weakening Esc
   mid-stream.

3. **Streaming credibility.** `on_delta` runs as SSE lines complete inside Req’s
   body callback. TUI can paint tokens while the model is still generating;
   tests reuse the same parser with `stream_body` inject.

4. **Durable accounting matches in-memory.** Usage rows are append-only JSONL;
   resume’s history scan rebuilds cumulative totals.

5. **Handoff atomicity.** One GenServer transaction under idle check means
   `start_turn` cannot start against a half-rebound Session.

6. **Focus claim + Session mutex are complementary.** UI claim stops
   double-spawn and steers; Session mutex stops concurrent `start_turn` even
   from non-Focus callers.

7. **Profile name is not activation.** Auto-resume reapply closes the gap
   between meta.profile and live plugin/skill set.

## Prevention

| Guard / test                                                                                            | What it locks                                          |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `product_path_test` source lock: Focus + Repl `start_turn`, refute `Agent.run`                          | Product surfaces cannot bypass Session ownership       |
| Spine: chat persist, Esc mid-turn no success content, cancel after tool start, exception → idle Session | Cancel fidelity + Session survival                     |
| Steering during turn                                                                                    | Mid-turn text is queue/steer, not second turn          |
| `session_store_test` cancel incomplete leaf                                                             | HEAD cancel leaf contract                              |
| `completion_test` SSE deltas + cancel during slow stream                                                | Real stream parse + no finished assistant after cancel |
| `resume_usage_test` durable usage rehydrate + auto-resume                                               | Ledger survives process death                          |
| `handoff_test` parent intact / child packet                                                             | Fail-closed parent, seeded child                       |
| Idle checks in Session: `open_new` / `resume` / `rewind` / `rebind` / `handoff` → turn-busy             | New “rebind-ish” APIs must add the same gate           |
| `TUI.try_begin_turn` + Focus busy → `Session.steer`                                                     | Double Enter must not spawn a second product turn      |
| `Profiles.reapply` after `maybe_auto_resume`                                                            | Meta.profile alone is insufficient                     |

**Process rule for future changes:** any API that changes Session `path`,
`last_id`, `history`, or profile activation is either (a) idle-only under
turn-busy, or (b) implemented as one Session `handle_call` that owns the full
critical section. Cancel handlers must prefer finished Task success over cancel
leaf. Streaming paths must share the incremental SSE feeder so tests cannot
greenwash buffered HTTP. Product chat surfaces must only enter the agent via
`Session.start_turn`.

## Related Issues

- PR #3: feat(arvo): D1 daily driver delight — review findings and fixes on
  `feat/arvo-d1-daily-driver`
- Plan context: `docs/plans/2026-07-27-001-feat-arvo-d1-daily-driver-plan.md`
  (R1–R4, R10–R17 trust/continuity requirements)
