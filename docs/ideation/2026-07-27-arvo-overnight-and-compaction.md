# Arvo: Overnight Product Charter, BEAM Bets, and Compaction

**Date:** 2026-07-27  
**Status:** Working notes from ideation + follow-on product discussion (not a requirements plan; not a bead backlog yet).  
**Related:** `docs/ideation/2026-07-27-arvo-elixir-harness-ideation.html` (ranked ideation artifact)  
**Subject:** Arvo — the Elixir/BEAM coding-agent harness (`arvo/`), twin of Rust Ore.

This document captures the full thread so nothing is lost before brainstorming, bead creation, or overnight runs: grounding, ranked ideas, overnight ambition, sequencing, BEAM-native features, a hard filter against feature bloat, and an extended treatment of **compaction**.

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

**Ambition = depth on scarce seams**, not surface feature count.

| Layer | Meaning |
|-------|---------|
| **Spine** | Product path is true (turn owner, stream, Esc/steer, HEAD, resume honesty, profile wire-up) |
| **Deep BEAM** | Things that are structurally better because OTP exists |
| **Compaction** | Attention product: immortal cold, structured warm, budgeted hot |

**Charter sentence (working):**

> Overnight we make Arvo’s *attention and process model* real: immortal session DAG, honest cancel, and multi-ring compaction under OTP — not more agent gimmicks.

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

### Job 2 — Don’t lose the workshop

| Feature | Why product-needed |
|---------|-------------------|
| Explicit HEAD on JSONL DAG | Tree exists; product pretends linear |
| `/rewind` / fork-at-tip | Bad turns shouldn’t force retype |
| Cancel-as-fork | Esc must not punish |
| Resume rehydrates tokens + model + profile | Lying resume is anti-product |
| Same-cwd continuity policy | `/resume` ceremony is discontinuity with extra steps |
| Auto-compact + one retry on length error | Long sessions are the product |

### Job 3 — Profile is the product unit

| Feature | Why product-needed |
|---------|-------------------|
| Progressive skills on the wire | Profile without skills is a tool bag |
| Namespaced plugin slash | User surface without core growth |
| Observe-only hooks on events | Side effects without permission rails / MCP |
| Profile constitution v0 | model, max_turns, compact knobs, skill set in one switch |
| At least one honest non-fff package | Proves packages aren’t vapor |

### Job 4 — Surfaces share one brain

| Feature | Why product-needed |
|---------|-------------------|
| Versioned event schema | Dual Repl IO + TUI mutation will rot |
| Headless NDJSON mode | Scripts, overnight agents, multi-attach |
| Ambient strip (model/profile/tokens/tool/status) | Minimal polish without multi-month painter |

### Job 5 — Docs match reality

| Feature | Why |
|---------|-----|
| README + short D1 note | Stop “Pre-code” lies; morning handoff |

---

## 5. Milestone sketch: “Arvo D1 — Workshop Continuity”

**Working name:** Arvo D1 — Workshop Continuity  

**Wake-up demo (definition of done for a human, not purity theater):**

1. `bin/arvo` in a repo → continues or clearly offers last session for that cwd  
2. Chat streams tokens; tools show live  
3. Mid-turn Esc kills the turn; Session lives; next message works  
4. Mid-turn steer lands on next model step  
5. After a bad path, `/rewind` (or equivalent) forks from an earlier node  
6. Long chat: length overflow auto-compacts once and retries (or compact is clearly better than today)  
7. `/profile …` changes **tools + skills + slash help**, not just tools  
8. Tests lock the **product path**, not only unit paths  

### 5.1 Track topology

```
          ┌─────────────────────────────┐
          │  CRITICAL PATH (serial)     │
          │  T0 Turn spine + product    │
          │     path + Esc + steering   │
          │     + streaming             │
          └──────────────┬──────────────┘
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
   Track S            Track P          Track E
   Session            Profile          Events
   memory +           product          + headless
   compaction         (parallel)       (parallel)
```

**Cut order if time runs short:** stretch packages / telemetry polish → parallel tools → strip chrome → same-cwd auto-resume (keep HEAD/rewind).  
**Never cut:** T0, streaming, HEAD/rewind or cancel-as-fork, skills+slash on profile switch, product-path Esc test, compaction honesty (at least length-error path + non-stupid summarizer).

### 5.2 Illustrative bead DAG (for later `bd` creation — not created yet)

#### Phase T0 — Critical path (serial)

1. Product chat only via `Session.start_turn`  
2. Esc cancels product-path turn Task; Session survives (product/integration test)  
3. Steering on product path mid-turn  
4. Finish ADR-0002: req_llm streaming + Registry base_url/auth  
5. Esc aborts stream promptly; no false complete assistant row  
6. Turn pipeline locked by tests (tests are the contract)

#### Phase S — Workshop memory + compaction spine

7. Explicit HEAD in session meta / store API  
8. `/rewind` / fork-at-tip (append-only)  
9. Cancel-as-fork: cancel leaf + coherent HEAD  
10. Resume rehydrates cumulative tokens from JSONL (or ledger)  
11. Resume rehydrates model + active profile (set-diff reapply)  
12. Same-cwd boot continuity policy (single rule locked in tests)  
13. Length-error → one compact → one auto-retry  
14. `/usage` and token chrome honest after resume  
15. Replace crude default summarizer with structural prune + minimal warm digest (see §7)

#### Phase P — Profile is the product

16. Wire skills into Agent context (progressive: name+desc)  
17. Skill body only on demand (no bulk inject)  
18. Namespaced plugin slash from manifest commands  
19. Observe-only hooks on turn/tool/cancel events  
20. Profile constitution v0: model, max_turns, compact knobs in TOML  
21. Ship profile package(s) that exercise constitution  
22. Product test: `/profile X` changes tools + skills + slash help  

#### Phase E — Multi-surface thin

23. Versioned event schema from Session/Agent only  
24. Repl printer as pure fold of events  
25. Ambient strip fields  
26. Headless NDJSON mode  
27. Same turn → same event sequence for Repl + NDJSON  

#### Phase X — BEAM payoff + honesty

28. Parallel pure tools under Task.Supervisor; Esc kills group  
29. README + short D1 note match shipped behavior  

#### Optional stretch

30. Profile package share/export  
31. Model summarizer for length-error backup only  
32. `/branch` list variations  
33. Telemetry sink for compact/cancel latency  
34. Keeper process for huge tool bodies (see §6–7)

### 5.3 Freezes for overnight agents

1. **HEAD format:** append-only JSONL; HEAD in meta; never rewrite history.  
2. **Streaming:** xAI first; Registry-backed; real stream; tool calls still work.  
3. **Constitution scope:** model, max_turns, compact threshold/reserve, skills allowlist — no themes/keybinds yet.  
4. **TUI:** strip + events only; no cell-diff painter night.  
5. **Ore parity:** don’t port Ore for its own sake; Arvo-native OTP bets can lead.  
6. **Philosophy refusals:** non-negotiable.

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

- No permission popups, shell approval, write confirm, plan mode, todo tool, MCP in core  
- Esc is the only brake  
- Hooks observe-only  
- Profile is the unit; plugins never own the agent loop  
- Own experimental seams only (ADR-0002)  
- Prefer failing **product** tests over new abstractions  
- Prefer **deleting dual paths** over adding flags  
- Compaction never means “delete cold history”  
- Do not invent Claude Code feature parity for its own sake  

---

## 10. What is *not* decided yet

Capture so future sessions don’t re-litigate silently:

- [ ] Final night goal name (e.g. “Arvo D1 — Workshop Continuity” vs compaction-primary charter)  
- [ ] Same-cwd policy: auto-resume vs prompt-once  
- [ ] Deep bet priority: multi-ring compaction vs profile-as-tree vs both thin  
- [ ] Warm-first strategy: confirm deterministic work-delta default  
- [ ] Whether Keepers are in first overnight or D1.5  
- [ ] Whether model `recall` tool is ever allowed  
- [ ] How much README/SPEC work is in-scope vs post-ship  
- [ ] Parallelism level of overnight agents (serial beads vs multi-track after T0)  

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
- **Follow-on discussion:** overnight ambition recalibration; anti-bloat filter; BEAM-native features; extended compaction design.  
- **This file:** full capture of that discussion for continuity across sessions/agents.

---

*End of capture. Prefer updating this document (or superseding with a dated v2) rather than scattering notes across chat logs.*
