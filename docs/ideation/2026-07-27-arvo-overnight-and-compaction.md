# Arvo: Overnight Product Charter, BEAM Bets, and Compaction

**Date:** 2026-07-27 (updated same day: TUI-first overnight list)  
**Status:** Working notes + **canonical overnight feature list** (§5). Not a requirements plan; beads not created yet.  
**Related:** `docs/ideation/2026-07-27-arvo-elixir-harness-ideation.html` (ranked ideation artifact)  
**Subject:** Arvo — the Elixir/BEAM coding-agent harness (`arvo/`), twin of Rust Ore.

This document captures the full thread so nothing is lost before brainstorming, bead creation, or overnight runs: grounding, ranked ideas, overnight ambition, sequencing, BEAM-native features, a hard filter against feature bloat, compaction/handoff discussion, and the **TUI-first overnight feature list**.

**Canonical build order for overnight:** §5 only. Earlier spine-only orderings in chat are superseded.

---

## 1. Context and constraints

### 1.1 What Arvo is

- Personal terminal coding-agent harness in Elixir/BEAM.
- Small core in the spirit of pi / grok-build; extended via plugins bundled into **Profiles**.
- Workshop tool: used daily, tweaked constantly, built to learn harness engineering.
- Twin experiment to **Ore** (Rust). Shared vocabulary in `CONTEXT.md` (Tool, Plugin, Profile, Provider, Skill, etc.).

### 1.2 Philosophy refusals (design constraints, not backlog)

- No permission popups  
- No shell-approval rails  
- No write confirmations  
- No plan mode  
- No todo tool  
- No MCP in core  
- **Esc is the brake**  
- Isolation story: process / cwd / containerization — not allowlists  

### 1.3 Architectural ADRs that still govern ideas

- **ADR-0001 (Elixir/BEAM for the harness):** BEAM is curriculum (OTP, live profile load, process-per-agent openness). Accepted costs: hand-rolled differential TUI, fatter distribution, TUI↔iex contention. Multi-agent must not be precluded.
- **ADR-0002 (core speaks req_llm types):** Own experimental seams only. Wrap tools (jido); consume req_llm types directly for providers. Harness provider layer = registry, model selection, OAuth — not a second full Provider behaviour.

### 1.4 Grounding snapshot (codebase as of ideation)

| Area | Current shape | Notable gaps |
|------|---------------|--------------|
| Agent | Pure `Arvo.Agent.run/3` (not a process); sequential tools; max_turns 25; policy outside loop | Product path may bypass Session Task |
| Session | JSONL under `~/.arvo/sessions/`; parent_id tree; resume-from-tip; compaction/usage/steering | Tip = last line; no public rewind/branch/HEAD; resume may omit tokens/profile honesty |
| Repl / TUI | Line `IO.gets` Repl + TUI GenServer `mode: :raw_v0` | Dual paths; Esc/steering second-class if chat is not Session-owned; no full differential renderer |
| Completion | Custom `Req.post` to xAI; often non-stream; req_llm dep present | ADR-0002 mid-migration; fake/post-hoc deltas risk |
| Plugins / Profiles | Set-diff switch; base always on; OTP children; fff flagship | Skills/hooks/commands under-wired; Profile not yet full product unit |
| Compaction | Token-threshold auto-compact; length-error → manual `/compact`; tree entry shape exists | Default summarizer crude (e.g. short role slices); no multi-ring; cold not productized as immortal attention model |
| Docs | Root README still “Pre-code”; SPEC.md referenced but missing | Docs lag a working tree |

### 1.5 External landscape (ideation research, compressed)

- Closest philosophy peer: **Pi** (tiny core, JSONL session trees, extensions, multi-mode).
- **Goose Recipes** ≈ named Profiles; **agentskills.io** progressive disclosure is cross-tool standard.
- Category crowded with TS/Go/Rust TUIs; scarce mindshare for *personal* BEAM harnesses that stay small.
- Durable edge is **OTP concurrency + named Profiles**, not Claude Code feature parity.
- Avoid: permission fatigue, MCP/core coupling, feature race with deep proprietary harnesses.

---

## 2. Ideation axes and ranked survivors

### 2.1 Topic axes

1. Session continuity  
2. Profiles & plugins  
3. TUI & interaction  
4. Agent loop & concurrency  
5. Providers & completion  

### 2.2 Ranked survivors (from ce-ideate)

Full cards live in the HTML artifact. One-line index:

| # | Title | Axis | Notes |
|---|--------|------|--------|
| 1 | One turn owner: Esc is real on the product path | Agent loop | Session.start_turn only; killable input owner |
| 2 | Navigable workshop memory | Session continuity | HEAD, fork/rewind, cancel-as-fork, JSONL as SoR |
| 3 | Profile becomes the product | Profiles | Skills/slash/hooks + constitution + packages |
| 4 | Finish ADR-0002: real streaming completion | Providers | Delete hardcoded non-stream HTTP path |
| 5 | Event-first multi-surface | TUI | Versioned events; projectors; strip + NDJSON |
| 6 | Length-error → auto-compact policy turn | Providers/Session | One compact + one retry outside pure Agent |
| 7 | Parallel pure tools under Task.Supervisor | Agent loop | Concurrent Reads/search; Esc kills group |

**Top pick from ideation:** #1 — unlocks honesty of Esc, steering, and almost every later surface.

### 2.3 Important rejections / merges

- “Esc is fiction without streaming” overclaims coupling; streaming improves feel but cancel existence needs turn owner first.
- Worktree multi-agent grid deferred until turn spine + events exist.
- Ambient profile / same-cwd auto-resume weaker than navigable memory + profile product.
- Many frame clones merged into X2 (memory), X3 (profile), X4 (events).

---

## 3. Overnight ambition: not “one 20-minute PR”

### 3.1 Pushback that changed the framing

- Doing a single survivor (e.g. rewire Repl → Session) may only take ~20 minutes of agent work.
- Ambition should mean a **product milestone**, not one gap closed.
- Counter-pushback: **AI makes adding features too easy** — easy to build too much too fast. Ambition ≠ longer feature list.

### 3.2 Revised notion of ambition

**Ambition = depth on scarce seams + a TUI you love**, not surface feature count.

| Layer | Meaning |
|-------|---------|
| **TUI / delight** | Why you open Arvo tomorrow — input, chrome, stream feel, aesthetics |
| **Spine / trust** | Thin true loop (turn owner, stream, Esc) so delight isn’t a lie |
| **Session / attention** | HEAD, handoff (not silent compact), resume honesty — after love lands |
| **Deep BEAM** | Process-native power later; not the overnight center |
| **Power features** | Full profile product, multi-agent, NDJSON — after daily-driver love |

**Charter sentence (canonical):**

> Overnight we ship a TUI you’d choose again — on a true stream/cancel path. Trust enables love; love makes the daily driver. Power features wait until you’re delighted.

**Principle:**

> Arvo will probably never be a daily driver without solid UI/UX TUI. Correctness alone is not enough — you have to love using it.

### 3.3 Feature filter (anti-bloat)

Before a feature earns work, ask:

1. **User job** — Daily-driver failure vs demo feature?  
2. **BEAM differential** — Would Ore/Pi implement it the *same* way? Parity can ship; it is not the novel bet.  
3. **Deletes complexity** — Removes dual path, ceremony, or lie?  
4. **Compounding** — One seam makes later features free?  
5. **Anti-feature** — Can we *not* build it and stay on philosophy?

### 3.4 Explicit non-goals (feature theater)

- 75-provider marketplace polish  
- Plan mode, todo tool, MCP in core, permission modals  
- Racing Charm/OpenCode on cell-diff paint  
- Multi-agent chat democracy without isolation story  
- Magic profile inference from markers  
- “Smarter system prompt only” as a project  
- Vector DB / cross-project memory as day-one  
- SPEC archaeology as the main night’s work  

---

## 4. Product jobs (user-facing)

### Job 1 — Trust the brake and the loop

| Feature | Why product-needed |
|---------|-------------------|
| Single turn owner (`Session.start_turn` only) | Cancel/steer/tests match what users run |
| Real streaming (finish ADR-0002) | Ends frozen non-stream blob |
| Esc mid-stream + mid-tool | Philosophy is Esc-only |
| Mid-turn steering on product path | “Live” is otherwise fake |
| Sequential default tools; optional pure parallel | Latency without multi-agent theater |

### Job 2 — Love the surface (daily-driver gate)

| Feature | Why product-needed |
|---------|-------------------|
| Raw-mode TUI owns the terminal | Line `IO.gets` will never delight |
| Layout: transcript + input + status strip | App feel, not REPL toy |
| Live stream rendering | Dead wait = hate |
| Esc with instant chrome feedback | Philosophy + feel |
| Multiline input, history, paste that works | Daily typing comfort |
| Tool blocks readable / de-emphasized | Scrollback not trash |
| Intentional theme tokens | Looks finished |
| Slash palette from TUI | Discoverable power |

### Job 3 — Don’t lose the workshop

| Feature | Why product-needed |
|---------|-------------------|
| Explicit HEAD on JSONL DAG | Tree exists; product pretends linear |
| `/rewind` / fork-at-tip | Bad turns shouldn’t force retype |
| Cancel-as-fork | Esc must not punish |
| Resume rehydrates tokens + model + profile | Lying resume is anti-product |
| Same-cwd continuity policy | `/resume` ceremony is discontinuity with extra steps |
| **Handoff over silent compact** | Explicit new session + work-delta packet; no in-place rewrite |

### Job 4 — Profile is the product unit

| Feature | Why product-needed |
|---------|-------------------|
| Progressive skills on the wire | Profile without skills is a tool bag |
| Namespaced plugin slash | User surface without core growth |
| Observe-only hooks on events | Side effects without permission rails / MCP |
| Profile constitution v0 | model, max_turns, handoff threshold, skill set |
| At least one honest non-fff package | Proves packages aren’t vapor |

### Job 5 — Surfaces share one brain / docs

| Feature | Why |
|---------|-----|
| Versioned event schema | Dual Repl IO + TUI mutation will rot; feeds TUI |
| Headless NDJSON (stretch) | Scripts after interactive love lands |
| README + short D1 note | Stop “Pre-code” lies; morning handoff |

---

## 5. Canonical overnight feature list (TUI-first)

**Working name:** Arvo D1 — Daily Driver Delight  

**Supersedes:** earlier spine-first bead order (session/profile before TUI). Historical BEAM/compaction notes in §6–7 remain useful; **build order is this section.**

### 5.0 Layers

| Priority | Layer | Role |
|----------|--------|------|
| 1 | **TUI / delight** | Why you open Arvo |
| 2 | **Thin trust spine** | Stream + Session turn + Esc (delight isn’t a lie) |
| 3 | **Session / attention** | HEAD, handoff, resume — after love |
| 4 | **Profile power** | After daily-driver love |
| 5 | **Stretch** | Parallel tools, NDJSON, explore spawn, telemetry |

```
Thin T0 (stream + start_turn + Esc)
    → TUI shell (raw mode, layout, theme)
    → stream + tools + strip + input delight
    → polish pass
    → session / handoff / profile (only if TUI already feels good)
```

### 5.1 Delight checklist (definition of “solid TUI”)

**Input:** raw mode; multiline; history; paste doesn’t break; Esc cancels *now*; clear interrupt policy.  
**Chrome:** model · profile · tokens · status · active tool; live spinner/cursor; instant cancel feedback.  
**Transcript:** user/assistant/tool blocks glanceable; tools folded or de-emphasized; errors loud; soft wrap.  
**Speed:** key echo instant; real token stream; no full-clear jank; cold start not dreaded.  
**Identity:** one visual language; intentional colors; slash help teaches without a manual.  

**Out of love v1:** mouse-heavy UI, image previews, marketplace, plan mode panes, Claude-clone chrome.

### 5.2 Wake-up demo (night succeeds only if #7 is true)

1. Open `arvo` → looks *finished*, not a REPL toy  
2. Type and paste comfortably (multiline + history)  
3. Tokens stream live; tools don’t trash scrollback  
4. Esc → immediate calm idle; Session still up  
5. Status strip always tells truth  
6. Slash palette feels designed  
7. **You think: “I’ll use this again tonight”**  
8. (Bonus) Product-path tests lock stream/cancel, not only unit paths  

If #7 fails, the night failed — even if HEAD/rewind shipped.

### 5.3 Must ship (ordered)

#### Phase T0 — Thin trust (serial; unblocks delight)

1. **All chat via `Session.start_turn`** — Repl/TUI never bypass with bare `Agent.run`  
2. **Real streaming (ADR-0002)** — Registry-backed; kill hardcoded non-stream xAI blob  
3. **Esc cancels product-path turn** — Task dead, Session up; product test  
4. **Esc aborts mid-stream** — no fake complete assistant after cancel  
5. **Mid-turn steering** on product path (even if chrome is minimal at first)  

#### Phase U — TUI delight (bulk of the night)

6. **Raw-mode TUI owns the terminal** — product default is not line `IO.gets`  
7. **Layout v1** — transcript + input + status strip  
8. **Theme tokens** — bg/fg/accent/error/muted (intentional, not default soup)  
9. **Live stream rendering** into transcript (real deltas)  
10. **Tool presentation** — start/end, name, short result or fold; errors loud  
11. **Status strip** — model, profile, tokens/context, status, active tool  
12. **Multiline input + history** — at least one solid paste/history path  
13. **Slash palette from TUI** — `/help`, `/model`, `/profile`, core set; discoverable  
14. **Cancel chrome** — visible running → idle on Esc; no ambiguity  
15. **Performance pass** — region/differential updates; no full-clear spam  
16. **Polish pass** — empty state, spacing, contrast, follow-tail while streaming  

#### Phase S — Session truth (after U feels good)

17. **Explicit HEAD** on JSONL tree  
18. **`/rewind` / fork-at-tip** — append-only  
19. **Cancel-as-fork** — Esc leaves coherent history  
20. **Resume rehydrates tokens + model**  
21. **Resume rehydrates active profile** (set-diff reapply)  
22. **Same-cwd continuity** — one rule locked in tests (auto-resume *or* clear prompt)  

#### Phase A — Attention (no silent compact)

23. **`compaction: none` default** — no in-place history rewrite  
24. **On context limit / length-error: `/handoff`** — structured work-delta packet → **new** session; old intact  
25. **`/usage` honest** after resume / handoff  
26. **Handoff UX in TUI** — edit/confirm packet, not a homework string only  

#### Phase P — Profile (thin, after love)

27. **Skills on the wire** — name+desc progressive; no bulk inject  
28. **Namespaced plugin slash** from manifest  
29. **`/profile X` product test** — tools + skills + slash help all change  
30. **Constitution v0 (optional same night)** — model, max_turns, handoff threshold in TOML  

#### Phase X — Close

31. **README / short D1 note** matches shipped TUI + path  

### 5.4 Should ship (if green early)

32. Collapsible tools / pin last error  
33. `/theme` or config colors  
34. Steering visible as queued line mid-turn  
35. Observe-only hooks on turn/tool/cancel  
36. Event schema cleanup so TUI is pure projector (if not already done in U)  

### 5.5 Stretch only

37. Parallel pure tools (Read/search); Write/Bash serial; Esc kills group  
38. Headless NDJSON mode  
39. Readonly `explore` spawn (one child profile + schema return) — experiment, not center  
40. Deterministic handoff auto-fill from tool trace  
41. Second profile package beyond search/fff  
42. Telemetry (TTFT, cancel latency)  

### 5.6 Explicitly not tonight

| Park | Why |
|------|-----|
| Orchestrator-as-default / multi-implementer | Unproven; pair-agent + love first |
| In-place LLM compaction | Distrusted; handoff instead |
| Worktrees / spawn depth > 1 | Complexity before delight proven |
| Claude-clone chrome, MCP, plan mode, todo | Philosophy / bloat |
| Keepers / full multi-ring compact product | After handoff + love |
| Provider marketplace | Not the bet |

### 5.7 Cut order if slow

**Cut first:** stretch (37–42) → constitution (30) → same-cwd auto-resume (22) → full handoff polish (26) → rewind (18) if HEAD+cancel-as-fork exist.  

**Never cut:** T0 (1–5), raw-mode TUI + layout + theme (6–8), live stream + strip + Esc chrome (9–11, 14), multiline/slash (12–13), polish pass (16), wake-up demo #7.

### 5.8 Freezes for overnight agents

1. **Delight gate:** if TUI isn’t lovable, do not burn the night on profile/multi-agent.  
2. **Streaming:** xAI first; Registry-backed; real stream; tool calls still work.  
3. **Turn path:** product interactive path = Session-owned Task only.  
4. **JSONL:** append-only; HEAD in meta when Phase S starts; never rewrite history.  
5. **Attention:** no in-place compact; handoff = explicit packet + new session.  
6. **TUI stack:** choose path most likely to ship beautiful defaults overnight (hand-roll on events *or* thin Elixir TUI dep); event model still feeds the view.  
7. **Philosophy refusals:** non-negotiable.  
8. **Single writer:** no parallel implement agents.  
9. **Ore parity:** don’t port for its own sake.  

### 5.9 Stack note (decide before sleep / first agent)

| Path | Pros | Cons |
|------|------|------|
| Hand-roll on events (ADR-0001) | Fits architecture | Easy to ship “meh” if under-scoped |
| Thin TUI library | Faster “app” feel | Dep weight; live-reload tradeoffs |

Overnight rule: **optimize for love by morning**, not purity. Curriculum can still own the event model underneath.

### 5.10 Historical note

An earlier D1 sketch prioritized session/profile/compaction rings before TUI. That ordering is **rejected for overnight**: a correct loop you don’t love won’t become a daily driver. §6–7 still document BEAM bets and compaction theory for later.

---

## 6. BEAM-native / novel directions (beyond generic agent features)

These are **Arvo identity** bets — structurally better because OTP exists. Prefer depth here over commodity surface features.

### 6.1 Memory as processes (Keepers)

- **Hot:** what the model sees this turn (budgeted).  
- **Warm:** structured work-state / digests in the session tree.  
- **Cold:** full tool results and old turns — JSONL immortal; optional **supervised Keeper** processes for large bodies, addressable later.  

Model or policy can **recall** cold slices without keeping everything in the prompt.

**Why BEAM:** isolation, restart, mailbox/query, crash of Keeper ≠ death of Session.

**Bloat check:** Yes if it becomes a second agent framework. No if Keepers are dumb addressable stores + one recall path under Session policy.

**Order:** HEAD + immortal cold + warm schema **before** Keepers.

### 6.2 Profile = supervision tree

On profile switch, set-diff tools **and** start/stop an OTP subtree (indexer, watcher, etc.). Crash isolation already half-exists via `Plugins.Supervisor` + manifest children.

**Product feel:** switching profile changes the *machine*, not only the tool menu.

**Bloat check:** One real child per flagship profile first; not arbitrary long-running multi-agent day one.

### 6.3 Multi-client, one Session process

TUI, line Repl, NDJSON attach, later iex — same Session GenServer, one HEAD, one turn_task, one Esc domain.

**Why BEAM:** GenServer + monitors; not Node worker split.

### 6.4 Soft real-time preemption

Turn group = linked processes (stream reader, tool tasks, compact task). Esc = group shutdown + first-class cancel node in the tree.

Deepens the turn spine; not a separate product category.

### 6.5 Live reload as workshop curriculum

Hot-swap skills / profile TOML / (careful) trusted plugin code without killing the session. Opt-in slash; trust boundary intact.

### 6.6 Telemetry-native harness engineering

`:telemetry` for TTFT, tool wall time, compact savings, cancel latency, profile switch time. Consumer: status/verbose or `~/.arvo/metrics/`. Workshop learning loop.

### 6.7 Structural parallel tools (not multi-agent theater)

Concurrent pure tools under Task.Supervisor; impure serial; Esc kills group. Smaller true BEAM win than “subagents UI.”

### 6.8 Not BEAM-novel (avoid as ambition)

Permission modals, plan mode, MCP-in-core, provider zoo, theme marketplace, cloning Claude Code subagent UX without OTP topology.

### 6.9 Progressive context as shared vocabulary

**Skills** and **cold memory** share one product idea: metadata always present, full body on demand. Worth naming once (“progressive context”) so skill wiring and compaction/recall don’t diverge.

---

## 7. Compaction (full capture)

Compaction is a **first-class product**, not “a slash command and a summarizer.”

### 7.1 Current state (problem statement)

What exists (shape may evolve; treat as intent of current tree):

- Auto-compact on cumulative token threshold  
- Length error → **manual** `/compact`, often “no automatic retry”  
- Default summarizer can be **crude** (e.g. short role slices) — lossy and unintelligent  
- Compaction can create a **tree entry** (e.g. `first_kept_entry_id`) — good bone  
- Architecture intent: **policy outside pure `Agent.run`** — correct  

**Gap:** the *hook* exists; the *attention model* (rings, strategies, honesty, interaction with HEAD/cancel/resume) does not.

### 7.2 What commodity compaction is (and why it’s weak for a workshop)

Typical harness: summarize older messages → drop them from the prompt → hope.

Fails for a workshop because:

- Tool evidence the next turn needs disappears  
- Resume + compact + cancel interact badly  
- User can’t see what was sacrificed  
- “Summarize everything” is expensive and still wrong  

### 7.3 Product thesis

**Compaction is attention management over an immortal log — not history deletion.**

JSONL (and Keepers, if present) **never die**. Compaction only changes:

1. What enters the **model context** this turn (hot)  
2. What **HEAD’s view** of history is (via compact nodes / first_kept pointers)  
3. What the **user can navigate** (rewind still sees cold truth)

Compatible with philosophy (no silent lying) and BEAM (cold fidelity on disk / in processes).

### 7.4 Multi-ring model

```
┌─────────────────────────────────────────────┐
│ COLD  — full JSONL (+ optional Keeper)      │  never auto-deleted
│         raw tool bodies, full assistant text│
├─────────────────────────────────────────────┤
│ WARM  — structured work-state               │  cheap to inject
│         files touched, decisions, errors,   │
│         open questions, last test outcome   │
├─────────────────────────────────────────────┤
│ HOT   — prompt window                       │  strict token budget
│         recent turns + warm digest + skills │
└─────────────────────────────────────────────┘
```

| Ring | Contents | How it updates |
|------|----------|----------------|
| **Hot** | Last N turns + warm digest + skill names | Every turn; hard budget |
| **Warm** | **Work-delta LOD**, not novel prose | On compact / every K turns / on length error |
| **Cold** | Immortal append-only tree | Always; rewind/fork/cancel-as-fork live here |

### 7.5 Work-delta LOD (preferred warm default)

Do **not** default to “LLM, summarize the chat.”

Maintain structured warm state closer to “what changed in the workshop”:

- Paths read/written  
- Commands run + exit codes  
- Failing test names  
- Short user constraints said in natural language  
- Current goal sentence (one line)  

**Why:** testable, cheap, less slop, aligns with coding-agent reality (repo + tools), BEAM-friendly as ETS/GenServer fields rebuilt from cold.

### 7.6 Triggers (single policy owner)

| Trigger | Behavior | Notes |
|---------|----------|--------|
| **Token threshold** | Refresh warm; shrink hot | Existing auto-compact path |
| **Length error from provider** | Compact once → **one** retry of same user turn | Replace homework-only message |
| **User `/compact [focus]`** | Intentional bias of warm digest | Steering, not only recovery |
| **Profile switch** | Optional re-budget via constitution knobs | Different windows per profile |
| **Cancel** | Don’t compact mid-panic; write cancel node; leave warm intact | Avoid thrash |

All triggers live **outside** pure Agent.

### 7.7 Strategies (small menu, not a zoo)

1. **Structural prune (default, cheap)**  
   Drop intermediate tool noise from hot; keep last successful edit paths + last errors. No LLM required.

2. **Work-delta refresh (default for threshold)**  
   Deterministic (or small-model) extraction into warm schema. Cheap, testable.

3. **Narrative summary (opt-in / length-error backup)**  
   LLM summary of older turns only when structural + delta aren’t enough. Strict prompt + token cap; prefer cheaper model when multi-model exists.

4. **Recall expand (user or later model-driven)**  
   Pull cold segments back into hot by id/path — inverse of compact. Makes rings honest.

**Avoid:** free-for-all “model calls compact tool” recursion. **Policy owns compact; model may request recall later.**

### 7.8 Compaction × session tree (must design together)

- Compact creates a **tree node**, not a rewrite of the past.  
- Warm snapshot / first_kept points into cold.  
- **Rewind before compact** still works (cold immortal).  
- **Rewind after compact** moves HEAD; hot rebuilt from cold+warm at that node.  
- **Cancel-as-fork** never depends on compact success.  

**Build order:**

1. HEAD / immortal cold / append-only rules  
2. Warm schema (versioned)  
3. Smarter triggers (threshold + length-error retry)  
4. Strategies (structural → work-delta → narrative backup)  
5. Recall  
6. Optional Keepers for huge tool bodies  
7. Telemetry on savings / strategy used  

### 7.9 Compaction UX (minimal, truthful)

Users need one honest signal, not a dashboard:

- After compact: e.g. `compacted: hot 12k→4k · warm updated · cold intact`  
- `/usage` shows enough to trust (at least cum + last compact savings; ideally hot/warm/cold)  
- `/compact focus: keep the failing auth test` biases warm  
- **Never pretend cold was deleted**  

On-brand with speed / minimal UX / no lying chrome.

### 7.10 Quality bars by depth

**D1 (finish the job that already exists):**

- Length-error → one auto compact + one retry  
- Replace crude slicer with structural prune + minimal warm digest  
- Honest token rehydrate after resume  
- Compact node navigable with HEAD  
- Esc can cancel an in-flight compact worker  

**D1.5 / BEAM-deep (novel bet):**

- Versioned warm work-delta schema with tests  
- Cold immortal + optional Keeper for large tool bodies  
- Recall by entry id / path  
- Compact worker under supervisor  
- Telemetry: tokens before/after, strategy used  

**Not yet:**

- Memory committee multi-agent  
- Vector DB  
- Automatic cross-project memory  
- Silent background compaction that rewrites user-visible history  

### 7.11 Tradeoffs still open (for brainstorm later)

1. **Warm state: deterministic work-delta vs LLM narrative first?**  
   Working preference: deterministic for threshold; LLM only on length-error or focused `/compact`.

2. **Keepers now vs cold-only JSONL?**  
   Working preference: cold JSONL enough for D1; Keepers after warm schema proves value.

3. **Model-driven recall tool vs policy + user `/recall` first?**  
   Working preference: policy + user first; model tool later behind a profile if ever.

4. **Shared “progressive context” vocabulary with skills?**  
   Working preference: yes — one mental model for skills and cold memory.

5. **Same-cwd policy when interacting with compact + resume?**  
   Still open: auto-resume last tip vs prompt once and remember — agents need one rule.

6. **Is multi-ring compaction the #1 deep overnight bet, or profile-as-supervision-tree, or both thin?**  
   Still open.

### 7.12 Compaction acceptance ideas (for future tests)

- Length overflow: one compact entry appears; same user intent retries once; second length error does not loop forever.  
- After compact, cold JSONL still contains pre-compact entries; rewind can land before compact node.  
- Structural prune never requires network.  
- Work-delta warm schema validates (required fields present).  
- Resume after compact: cumulative tokens and hot budget are coherent (not zeroed lies).  
- Esc during compact: Session alive; no half-applied warm corruption (or warm update is atomic).  
- `/compact focus:…` changes warm contents in a testable way.  

---

## 8. How layers compose (map)

| Ideation survivor | Overnight / depth role |
|-------------------|------------------------|
| #1 One turn owner | T0 core |
| #2 Navigable memory | Phase S full (not one bead) |
| #3 Profile product | Phase P full |
| #4 Streaming | T0 (elevated; not optional for feel) |
| #5 Event-first | Thin Phase E (not zero-paint thesis paper) |
| #6 Auto-compact | Phase S + entire §7 depth roadmap |
| #7 Parallel tools | Phase X; BEAM payoff after spine |

| BEAM-native idea | Depends on | Novelty |
|------------------|------------|---------|
| Multi-ring compaction | HEAD + cold immortal | High product + medium BEAM |
| Keepers | Rings + event attach | High BEAM |
| Profile as supervision tree | Profile consumers | High BEAM |
| Multi-client Session | Event schema | High BEAM |
| Preemptive Esc group | Turn owner + streaming | Medium (deepens spine) |
| Live reload | Trust model | Medium curriculum |
| Telemetry | Any deep work | Medium workshop |
| Parallel pure tools | Turn owner | Medium BEAM |

---

## 9. Principles for overnight runners (when beads exist)

- Follow **§5** build order (TUI-first)  
- No permission popups, shell approval, write confirm, plan mode, todo tool, MCP in core  
- Esc is the only brake — and chrome must show it  
- **Delight gate:** lovable TUI before power features  
- Hooks observe-only  
- Profile is the unit; plugins never own the agent loop  
- Own experimental seams only (ADR-0002)  
- Prefer failing **product** tests over new abstractions  
- Prefer **deleting dual paths** over adding flags  
- No silent in-place compact; handoff is explicit  
- Do not invent Claude Code feature parity for its own sake  

---

## 10. What is *not* decided yet

Capture so future sessions don’t re-litigate silently:

- [x] Overnight center: **TUI delight + thin trust** (§5), not multi-agent / compact-first  
- [ ] TUI stack: hand-roll vs thin library (§5.9)  
- [ ] Same-cwd policy: auto-resume vs prompt-once  
- [ ] Deep bet later: multi-ring vs handoff-only vs profile-as-tree  
- [ ] Warm/handoff packet: deterministic work-delta default (lean yes)  
- [ ] Keepers: not overnight  
- [ ] Model `recall` / explore spawn: stretch only  
- [ ] How much README/SPEC work is in-scope vs post-ship  
- [ ] Parallelism of overnight agents after T0+U  

---

## 11. Suggested next steps (when ready — not done in this capture)

1. Resolve open decisions in §10 (short conversation).  
2. Run **`ce-brainstorm`** with a single seed (D1 + compaction thesis), producing requirements under `docs/plans/`.  
3. Create **`bd`** goal + dependent beads from §5.2 / §7.10 with acceptance one-liners.  
4. Overnight runner: `bd ready` → claim → implement → close.  
5. Optional: fold durable decisions into ADRs (especially multi-ring compaction + HEAD).  

---

## 12. Provenance

- **Ideation run:** ce-ideate focus `arvo the elixir harness` (2026-07-27), artifact `docs/ideation/2026-07-27-arvo-elixir-harness-ideation.html`, scratch run id `438bc25c`.  
- **Follow-on discussion:** overnight ambition; anti-bloat; BEAM-native features; compaction vs handoff; adversarial multi-agent; **TUI-first daily-driver reframing.**  
- **§5:** canonical overnight feature list (TUI-first D1), merged 2026-07-27.  
- **This file:** full capture for continuity across sessions/agents.

---

*End of capture. Prefer updating this document (or superseding with a dated v2) rather than scattering notes across chat logs.*
