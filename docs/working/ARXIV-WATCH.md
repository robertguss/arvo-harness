# arXiv watch — harness engineering & reinvented OTP

- **Status:** Working field guide. **Not** an accepted research report.
- **Updated:** 2026-08-14
- **Access date for all links:** 2026-08-14
- **Lens:** H-329 — circle what is already an `erl` man page; underline the leftover insight.
- **Depends on:** [`DISCOVERY-NOTES.md`](DISCOVERY-NOTES.md) (central insight, adaptation stance)

This is Front A intake. Not sorted. Not a backlog. X bookmarks are the next trail.

Reading method: **their noun → BEAM noun → leftover (underlined) → why look deeper.**

---

## 1. The field now has a name: harness engineering

A cluster of 2026 papers treat the *scaffold around the model* as the object of study, not the model.

| ID | Paper | Why it matters here |
|----|--------|---------------------|
| P-001 | [Building Effective AI Coding Agents for the Terminal](https://arxiv.org/abs/2603.05344) (Bui, OPENDEV) | Terminal-native compound system: dual-agent plan/execute, lazy tool discovery, adaptive compaction, event-driven reminders. Rust harness, same product shape as Arvo. |
| P-002 | [Inside the Scaffold](https://arxiv.org/abs/2604.03515) (Rombaut) | 13 open-source coding agents, 12 dimensions, **seven compaction strategies**, five loop primitives. The anatomy textbook. |
| P-003 | [Agentic Harness Engineering (AHE)](https://arxiv.org/abs/2604.25850) (Lin et al.) | Observability-driven *evolution* of the harness. Gains landed in tools/middleware/memory, **not** the system prompt. |
| P-004 | [Meta-Harness](https://arxiv.org/abs/2603.28052) (Lee et al.) | Outer loop searches over **harness code**. Filesystem of prior candidates + traces. Beats hand-engineered TerminalBench-2 baselines. |
| P-005 | [Natural-Language Agent Harnesses](https://arxiv.org/abs/2603.25723) (Pan et al.) | Harness policy as an editable document + a runtime that interprets it (handoffs, gates, artifacts). Lists 11 aspects of harness engineering. |
| P-006 | [Code as Agent Harness](https://arxiv.org/abs/2605.18747) (Ning et al.) | Survey: code is the *substrate* (interface, memory, tools, verification), not only the output. Open problems: shared state, regression-free harness change, eval beyond task_ok. |
| P-007 | [Dive into Claude Code](https://arxiv.org/abs/2604.14228) (Liu et al.) | Source-level map of a production TS harness. While-loop + 98% operational infrastructure. Five-layer compaction. Append-only JSONL. Subagent isolation. |
| P-008 | [The Last Harness You'll Ever Build](https://arxiv.org/html/2604.21003v2) | Automate harness engineering itself (meta-learning framing). Adjacent to P-003/P-004. |
| P-009 | [Coding Benchmarks Are Misaligned…](https://arxiv.org/pdf/2606.17799) | A coding agent is **not a model**; it is a system harness. Benchmarks that score only the end number hide which layer failed. |

**Circled (OTP we already have or should just use):** loop as receive; tools as messages; plan/execute as two processes; lazy tool schemas as progressive disclosure; observability as `:telemetry` + JSONL.

**Underlined leftovers:**

- Compaction is a *pipeline of cheap-then-dear strategies*, not one summarizer (P-007, P-002).
- Harness *structure* (tools, middleware, memory) transfers across models; prose strategy does not (P-003).
- Evolving the harness needs **falsifiable edit contracts** + drill-down traces, not more prompt soup (P-003, P-004).
- Policy-as-data (constitution / NLAH document) vs policy-as-code — both are legal adaptations (P-005).
- Eval must score *layers*, not only task_ok (P-009, P-006). Matches Arvo’s attention honesty metrics.

**Adaptation spark:** AHE/Meta-Harness want a revertible file per component. On BEAM that is a module + the code server. Their outer loop is `:code.load_binary` plus a child Session plus audit.

---

## 2. Context, compaction, memory — the leftover is *policy*

| ID | Paper | Leftover insight |
|----|--------|------------------|
| P-010 | [Recursive Language Models](https://arxiv.org/abs/2512.24601) (Zhang, Kraska, Khattab) | Prompt is **data in an environment**, not a growing string. Recursive `llm_query` over snippets. Beats compaction *and* CodeAct-with-subcalls *and* Claude Code on long-context tasks (their numbers). Official impl: Python REPL. |
| P-011 | [ACE — Agentic Context Engineering](https://arxiv.org/abs/2510.04618) (Zhang et al., ICLR 2026) | Context as an **evolving playbook**. Incremental updates, not rewrite-the-whole-prompt (avoids brevity bias and context collapse). Generator / reflector / curator. Works offline (system prompt) and online (agent memory). |
| P-012 | [GEPA](https://arxiv.org/abs/2507.19457) (Agrawal et al., ICLR 2026 oral) | Evolve prompts from **natural-language reflection on trajectories**. Pareto front of complementary lessons. Few rollouts beat GRPO/MIPROv2. Organism can be a constitution, not a math prompt. |
| P-013 | [Parallel Context Compaction](https://arxiv.org/html/2605.23296v1) | Compact *slices concurrently* instead of one synchronous summary. Operator control over volume. Written for a VM that can spawn workers. |
| P-014 | [LOCA-bench](https://arxiv.org/html/2602.07962v1) | Catalog of context-engineering *moves*: tool-result clearing, thinking-block clearing, compaction, context-awareness (how much window is left), file memory tool, **programmatic tool calling** (code consumes intermediates; model sees the residue). |
| P-015 | [Are We Ready For An Agent-Native Memory System?](https://arxiv.org/html/2606.24775v1) | Memory ≠ RAG ≠ context packing. Full lifecycle: store, retrieve, update, consolidate, evict. |
| P-016 | [Memory in the Age of AI Agents](https://arxiv.org/abs/2512.13564) | Survey + paper list. Map of STM/LTM, learned memory control, benchmarks (MemBench, MemoryAgentBench). |
| P-017 | [Solving Agent Memory and Cost…](https://arxiv.org/html/2607.21503v1) | Memory as a **lifecycle** (what to remember, extract, retain, compact, anticipate) not a store. Cites MemGPT, ACE, Dynamic Cheatsheet, Letta sleep-time agents. |
| P-018 | [Characterizing GitHub Copilot at Production Scale](https://arxiv.org/html/2608.00101v1) | Compaction in 7.8% of sessions but **44% of tokens**. Cache hit ~90% *within* a turn, ~55% across turns, **destroyed** by compact or model switch. Prefix stability is economics. |
| P-019 | [Self-Compacting Language Model Agents](https://arxiv.org/pdf/2606.23525) | Agents that compact themselves as they go. Adjacent to “frequent intentional compaction.” |
| P-020 | [Context Compaction Theory](https://arxiv.org/pdf/2608.01326) | Formal: when internal state exceeds the window, a compaction algorithm emits a new context. Worth a later read for vocabulary, not for a kernel. |
| P-021 | [End-to-End Context Compression / LCLM](https://arxiv.org/html/2606.09659v1) | Learned compressors + agent that **expands** a chunk on demand. Same shape as stub/recall, different substrate (latent tokens vs files). |

**Circled:** hot/warm/cold; ETS + files; recall; handoff; append-only log; `persistent_term` for a stable prefix.

**Underlined:**

- Context collapse from *iterative rewrite* (ACE). Handoff and incremental playbook rows exist to avoid this.
- Programmatic tool calling (P-014): the model writes a short program so intermediates never enter hot. That is RLM-adjacent and CodeAct-adjacent. On BEAM: run that program **on hands**, return the residue.
- Cache economics (P-018): plugin hot-swap and compact are **cache-break events**. Name them.
- Sleep-time / background memory (P-017, Letta): a sweeper process, not a turn.
- RLM vs progressive attention vs compact vs “just 1M context” are **competing answers** to the same pain. Do not merge by slogan.

**Claude Code five-layer pipeline (P-007) — steal the *menu*, not the TS:**

1. Budget-reduce oversized tool bodies (we already stub).
2. Snip old history (structural prune).
3. Microcompact (cache-aware, cheap).
4. Context collapse (very long histories).
5. Auto-compact / semantic summary (last resort, expensive).

Cheap layers first. That *is* H-301.

Append-only JSONL + compact *boundary* markers so resume can rebuild the live view without rewriting the past (P-007). Arvo already believes this (HEAD, cancel-as-fork, handoff).

---

## 3. Runtime, isolation, “agent OS” — the fake kernel cluster

| ID | Paper | They reinvented | Leftover |
|----|--------|-----------------|----------|
| P-022 | [Agent libOS](https://arxiv.org/html/2606.03895) | Process, mailbox, capabilities, children, checkpoints, tool table, skills, budgets | Naming is almost a gift. Policy: hierarchical budgets, JIT tools, human queues. |
| P-023 | [LLM-in-Sandbox](https://arxiv.org/html/2601.16206v1) | A computer the model may use, fenced | Put the *usable computer* in the sandbox to elicit agentic behavior. Hands node *is* that computer. |
| P-024 | Voyager ([arXiv:2305.16291](https://arxiv.org/abs/2305.16291)) | Skill library as **executable growing code** | Skills that the agent *writes* and we *load*. Code server. |
| P-025 | OpenHands / SWE-agent (cited across P-002, P-007) | Docker as the fence | Runtime is part of the agent. Isolation hierarchy, not allowlist-as-center. |
| P-026 | [SASE / Agentic Software Engineering](https://arxiv.org/html/2509.06216v3) | ACE (command env) vs AEE (execution env) | Humans orchestrate; agents execute; structured handoff packs. Sounds like brain tile vs hands node vs human mailbox. |

**Circled hard:** AgentProcess = GenServer. Queue = mailbox. Capability = pid + node. Checkpoint = JSONL. Child = supervisor. Sandbox = Port / hidden node / container.

**Underlined:** hierarchical budgets; JIT/generated tools (Voyager + libOS); human callback as a first-class queue; “runtime is part of the agent.”

---

## 4. How a production TS harness actually looks (P-007, deep)

Claude Code, from the source-level paper:

- Core loop is a while-true. **~1.6% of the codebase is “AI decision logic.”** The rest is operational infrastructure. That is the fake OS *and* the proof that the OS is the product.
- Single loop for TUI, headless, SDK, IDE — only the projector changes. (H-069 / H-168.)
- Reasoning stays in the model; the harness **executes**. Model never touches the filesystem except through a validated tool protocol.
- Context is the binding constraint. Five shapers **before every model call**.
- Sessions are **mostly append-only JSONL**. Compact writes a *boundary* with UUIDs; disk is not rewritten.
- Subagents re-enter the same loop with an isolated window and return a **summary only**. Sidechain transcripts stay off the parent.
- Concurrent-safe tools fan out; writes/bash serialize. Abort one bash kills sibling subprocesses.
- Extensibility is four mechanisms at different context costs: MCP, plugins, skills, hooks.
- OpenClaw contrast: same design questions, different deployment (gateway vs CLI) → different answers (perimeter vs per-action).

**What to steal:** pipeline-of-compactors; append-only + boundary; one loop many projectors; subagent = isolated child + summary return; abort groups.

**What not to steal:** seven permission modes, ML allow-classifier, MCP-in-core, plan/todo as identity. Those are their product; several are our hard-nos.

**BEAM-shaped reread:** “98% operational infrastructure” is what OTP was *for*. They built it in TypeScript because that is what they know.

---

## 5. Inside the Scaffold (P-002) — a menu, not a spec

From the abstract + HTML notes we already pulled:

- Control: fixed pipeline → ReAct → plan-execute → generate-test-repair → multi-attempt → MCTS.
- **11 of 13 agents compose multiple loop primitives.** There is no one loop.
- Tools: 0–37. Isolation and edit-format **converge** (external constraint). Compaction, state, routing **diverge** (open questions).
- Sub-agents often have **scaffold-enforced** tool permissions (explore = read; plan = no write). That is a constitution on a child, not a persona.
- Seven compaction strategies exist in the wild. We do not need an eighth religion; we need to know which leftover we are testing.

---

## 6. Self-improving harnesses (GEPA / ACE / AHE / Meta-Harness)

These four are one family:

| Paper | What evolves | How |
|-------|----------------|-----|
| GEPA | Prompts / textual parameters | Reflect on trajectories; Pareto merge |
| ACE | Playbook (prompt *or* memory) | Generate / reflect / curate; incremental |
| AHE | Harness **files** (tools, middleware, memory) | Observability + falsifiable edit contracts |
| Meta-Harness | Harness **code** | Agentic proposer over a filesystem of prior tries |

**Leftover they share:** the interesting object is not the next user token. It is the **organism** (constitution, playbook, tool set, compact policy).

**AHE’s empirical sting:** evolving the *system prompt* was the weak lever. Tools, middleware, and long-term memory moved Terminal-Bench. That matches “don’t become a prompt project.”

**Adaptation:** organism = modules + `persistent_term` constitution + ETS playbook. Mutation = load new beam / swap constitution. Rollout = child Session. Trace = JSONL + audit. This is the most BEAM-native paper family we have.

---

## 7. First cards to look at harder (not a build order)

Richer leftover, closer to our theses. Still not sorted for spikes.

1. **P-007 Claude Code anatomy** — production map of the fake OS; steal the compaction pipeline and append-only boundary.
2. **P-002 Scaffold taxonomy** — complete the seven compaction strategies and the 13-agent table from the PDF.
3. **P-010 RLM** — competing context theory; two adaptations (Python-on-hands vs ETS/Session REPL).
4. **P-011 ACE + P-012 GEPA** — playbook / constitution evolution; pair with Harbor attention later.
5. **P-003 AHE + P-004 Meta-Harness** — harness as the organism; code server as search operator.
6. **P-013 Parallel compact** — workers; almost written for us.
7. **P-014 LOCA + programmatic tool calling** — code consumes intermediates.
8. **P-022 libOS** — noun-for-noun OTP dictionary.
9. **P-018 Copilot cache economics** — name cache-break events.
10. **P-001 OPENDEV** — another terminal-native compound system (Rust, like Ore’s neighborhood).

---

## 8. Papers mentioned, not yet opened

Worth a later pass, not blocking:

- Dynamic Cheatsheet (Suzgun 2025) — self-updating playbook; ACE cousin.
- MemGPT / Letta docs — pager + sleep-time agents.
- PASTE (speculative tool execution) — cited in P-007.
- TraceLab / agentic workload characterization (`2606.30560`).
- VeRO eval harness (from earlier dump).
- Awesome list: [Code-as-Agent-Harness papers](https://github.com/YennNing/Awesome-Code-as-Agent-Harness-Papers).

---

## 9. Next trail

Robert’s **X bookmarks** — likely denser in *practitioner* harness tricks than arXiv. Same lens: circle the primitive, underline the leftover, ignore the TS/Python furniture.

Do not start that trail until asked in the next turn (this file is the arXiv pass).
