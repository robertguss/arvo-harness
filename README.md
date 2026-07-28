# Arvo

A personal terminal coding-agent harness in Elixir/BEAM. Small core in the
spirit of [pi](https://github.com/badlogic/pi-mono) and grok-build, extended
through plugins bundled into **Profiles**.

This is a workshop tool — used daily, tweaked constantly, built to learn harness
engineering. Rob architects and experiments; AI writes the code.

## Philosophy

- **Speed / minimal UX** — fast enough to feel native; nothing on screen that
  didn't earn its place.
- **TUI feel** — Focus mode (prototype D): ghost strip + transcript + input +
  footer as one Herdr tile.
- **Agent behavior** — good prompt, good tool contracts, self-repair through
  tool errors.
- **Hackable code** — small enough to rewrite weekly.

**Refusal list**: no permission popups, no shell-approval rails, no write
confirmations, no plan mode, no todo tool, no MCP in core. Esc is the brake;
containerization is the isolation story.

**Not Arvo's job**: project browser, agent roster, embedded shell, permanent
three-pane IDE — Herdr / sibling terminal already do that. Arvo is the agent
tile.

## D1 daily driver (shipped path)

### Run

```bash
cd arvo
export ARVO_CWD="$PWD"   # optional; defaults to launch dir via bin/arvo
bin/arvo                 # or: mix run --no-halt
```

Default interactive surface is **Focus** (raw Termite when TTY; line-mode
fallback otherwise). Repl is library/test fallback only (`start_repl: true` if
you need it).

### Keys / slash

| Input               | Effect                                                       |
| ------------------- | ------------------------------------------------------------ |
| Enter               | Send chat (or submit slash)                                  |
| Esc                 | Cancel in-flight turn Task (Session stays up)                |
| `/help`             | Commands                                                     |
| `/model [spec]`     | Show/set model                                               |
| `/profile [name]`   | Switch workflow profile (idle-only)                          |
| `/resume [n\|path]` | List/resume sessions                                         |
| `/rewind [n]`       | Move HEAD back n steps; next message forks                   |
| `/handoff`          | New session seeded with work-delta packet; parent log intact |
| `/compact`          | Power tool (not silent auto)                                 |
| `/login`            | Device-flow OAuth                                            |
| `/quit`             | Exit                                                         |

### Trust spine

- Every product chat turn goes through `Session.start_turn` (not bare
  `Agent.run`).
- Completion streams SSE text deltas; cancel mid-stream leaves no finished
  assistant claim.
- JSONL is append-only with explicit **HEAD** (`head_move`); product history is
  root→HEAD only.
- Default: **no silent auto-compact**. Near limit / length error → prefer
  `/handoff`.
- Same-cwd boot **auto-resumes** last non-empty session (skips empty shells).
- Single OS process writer per session file.

### Profiles / skills

- Progressive skills: name + description + path (no bulk SKILL body inject).
- Active plugins contribute tools + namespaced slash (`/plugin:cmd`).
- `/profile X` changes tools + skills + slash for the **next** turn.

### Wake-up demo checklist

1. `bin/arvo` opens Focus (or line mode in non-TTY).
2. Chat streams; tools fold in transcript; Esc cancels mid-turn.
3. Kill process, relaunch same cwd → prior session + tokens resume.
4. `/rewind 1` then new message → fork; abandoned tip still on disk.
5. `/handoff` → new session packet-sized; parent JSONL intact.
6. `/profile` with a skill/plugin profile → help lists commands; next turn
   tools/skills match.

### Tests

```bash
cd arvo && mix test
```

## Repo guide

| Path                                                                                                                       | What                          |
| -------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| [SPEC.md](SPEC.md)                                                                                                         | Locked v0.1 specification     |
| [CONTEXT.md](CONTEXT.md)                                                                                                   | Normative vocabulary          |
| [docs/adr/](docs/adr/)                                                                                                     | Architecture decision records |
| [docs/plans/2026-07-27-001-feat-arvo-d1-daily-driver-plan.md](docs/plans/2026-07-27-001-feat-arvo-d1-daily-driver-plan.md) | D1 plan                       |
| [arvo/](arvo/)                                                                                                             | Elixir mix project            |

## Status

D1 daily-driver path implemented on `feat/arvo-d1-daily-driver`: Focus default,
Session-owned turns, streaming, HEAD/rewind, handoff, thin profiles.
