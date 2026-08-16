# LangChain / Trivedy watch

- **Status:** Working notes. Not an accepted report.
- **Updated:** 2026-08-14
- **Lens:** circle OTP they reinvented; underline leftover insight.
- **Person:** [Vivek Trivedy](https://x.com/Vtrivedy10) (`@Vtrivedy10`) — applied research lead, LangChain Labs.
- **Related:** [`ARXIV-WATCH.md`](ARXIV-WATCH.md), [`DISCOVERY-NOTES.md`](DISCOVERY-NOTES.md), [`AUTORESEARCH-WATCH.md`](AUTORESEARCH-WATCH.md)

X **bookmarks** are still private to Robert’s account. This file is the LangChain/Trivedy trail only.

---

## Who he is (why he is on the wall)

He is one of the people treating **harness engineering as a discipline**, not a blog slogan. He writes the definitions, runs the Terminal-Bench loops, ships the eval skill, and talks about traces as ore.

Talk worth watching: [Improving Agents is a Data Mining Problem](https://www.youtube.com/watch?v=CvRngaQZQ3Y) (AI Engineer, 2026). Site: [vtrivedy.com](https://www.vtrivedy.com/).

Primary artifacts:

| Piece | URL |
|-------|-----|
| Deep Agents (the harness) | https://github.com/langchain-ai/deepagents |
| Anatomy of an Agent Harness | https://www.langchain.com/blog/the-anatomy-of-an-agent-harness |
| Improving Deep Agents with harness engineering | https://www.langchain.com/blog/improving-deep-agents-with-harness-engineering |
| Towards Automating Eval Engineering | https://www.langchain.com/blog/towards-automating-eval-engineering |
| How we build evals for Deep Agents | https://www.langchain.com/blog/how-we-build-evals-for-deep-agents |
| Tuning Deep Agents to different models | https://www.langchain.com/blog/tuning-deep-agents-different-models |
| Eval / other skills | https://github.com/langchain-ai/langchain-skills |
| Harbor (their eval runner too) | already in Arvo’s `evals/` |

---

## His definition (steal the sentence)

> **Agent = Model + Harness.** If you’re not the model, you’re the harness.

A harness is every piece of code, config, and execution logic that is not the weights: prompts, tools, skills, MCP, filesystem, sandbox, browser, orchestration, hooks/middleware.

That is José from the other side. José: the runtime *is* the framework. Viv: the framework around the model *is* the product. We want both sentences.

---

## Deep Agents — what they actually bundled

Opinionated harness on **LangGraph**. Inspired by Claude Code; “identify what makes it general-purpose and push that further.”

Ships:

- Sub-agents with **isolated context**
- Pluggable **filesystem** (local / sandbox / remote)
- Context management: summarize threads, **offload tool outputs to disk**
- Shell in a sandbox of choice
- Persistent memory (pluggable store)
- Human-in-the-loop tool approval
- Skills (progressive load)
- Bring-your-own tools or MCP
- CLI coding agent (`deepagents-cli` / Deep Agents Code)

Security line (good): **trust the LLM; enforce at the tool/sandbox.** Same as Arvo’s “fence is a location, not an allowlist.”

Stack confession: LangGraph = graph runtime, `create_agent` = thin harness, Deep Agents = fat harness. **LangGraph checkpointing is the fake `gen_statem` + journal.** Circled.

---

## Anatomy leftovers (from the blog)

Working backwards from “what we want the agent to do”:

| Want | Their harness move | Circled / underlined |
|------|--------------------|----------------------|
| Durable storage, offload, multi-agent collab | **Filesystem as the primitive** | Circled: files + JSONL + cold. Underlined: FS as *collaboration surface* / shared ledger |
| Don’t pre-design every tool | **Bash + code exec** (“give the model a computer”) | Circled: Port/hands. Underlined: code-as-general-tool (CodeAct / programmatic calling) |
| Safe, scalable act/observe | **Sandboxes + default tooling** (runtimes, git, tests, browser) | Circled: node/container. Underlined: *onboard* the env (tools already installed) |
| Remember / past cutoff | Files (`AGENTS.md`) + web/MCP | Circled: cold files. Underlined: memory = continual learning via files, not a vector religion |
| Don’t rot | Compact, tool-output offload, skills progressive disclosure | Already our rings. Underlined: skills exist *to protect the window* |
| Long horizon | Git + Ralph loop + plan file + verify hooks | Underlined: Ralph (hook intercepts exit, reinjects goal, fresh window, state on disk) |
| Models trained *in* a harness | Co-training overfits tool shapes (`apply_patch`) | Underlined: **no universal harness**; tailor per model (he said this again Aug 2026) |

Open problems he names (lab candy):

- Hundreds of agents on one codebase
- Agents that **read their own traces and patch the harness**
- **JIT** tool/context assembly instead of a preloaded bag

---

## The Terminal-Bench loop (the money post)

[Improving Deep Agents with harness engineering](https://www.langchain.com/blog/improving-deep-agents-with-harness-engineering) (17 Feb 2026):

- **Same model** (`gpt-5.2-codex`), only harness.
- **52.8 → 66.5** on Terminal Bench 2.0 (Top 30 → Top 5 at the time). Harbor + Daytona sandboxes. Traces in LangSmith. They published a [trace dataset](https://smith.langchain.com/public/29393299-8f31-48bb-a949-5a1f5968a744/d).

Knobs they allowed themselves: **system prompt, tools, middleware** (hooks around model/tool calls). Not the kitchen sink.

What actually moved the score:

1. **Build–verify loop.** Models write, reread, declare victory. They don’t naturally test. Prompt a plan→build→verify→fix, plus `PreCompletionChecklistMiddleware` (Ralph-shaped: intercept exit, force a verify pass).
2. **Onboard the environment.** `LocalContextMiddleware` injects cwd map + installed tools. Time-budget warnings. “Teach them their work will be scored by tests.”
3. **Doom-loop detector.** `LoopDetectionMiddleware`: N edits to the same file → “reconsider.” Short-term patch for today’s myopia.
4. **Reasoning sandwich.** `xhigh` plan, `high` implement, `xhigh` verify. All-`xhigh` *lost* to timeouts (53.9 vs 63.6 then 66.5).
5. **Trace Analyzer skill.** Fetch traces → **parallel** error-analysis agents → synthesize harness patches. Boosting on mistakes. Human optional in the last step.

Takeaways he lists (almost all leftovers, not OTP):

- Context engineering *on behalf of* the agent (onboard them).
- Force self-verify.
- Traces are the feedback signal (tooling and reasoning fail *together*).
- Guardrail today’s dumb patterns; expect them to dissolve.
- **Tailor the harness to the model.** Claude on a Codex-tuned harness underperformed until they looped again.

This is AHE/Meta-Harness in practitioner clothes. Harbor is already how Arvo scores attention. The missing piece in *this* program is treating **traces → harness patch** as a first-class later experiment — on BEAM that is JSONL/audit → child Sessions proposing module/constitution swaps.

---

## Eval engineering (why he is extra useful)

He treats evals as **training data for agents**, and continual learning as **data mining**:

```text
mine traces → identify a failure → build an eval → improve the agent → rerun
```

[Eval Engineering Skill](https://www.langchain.com/blog/towards-automating-eval-engineering) (22 Jul 2026, still pushing it mid-Aug):

- Inspect repo (prompts, tools, skills, hooks).
- Mine traces for real contracts.
- **Interview the human** — one-shot evals are worse.
- Emit **Harbor tasks** (`instruction.md` + Dockerfile env + verifier). Same shape as `coding-agent-harness/evals/`.
- Iterate by reading *both* agent trajectory and verifier trajectory (reward hacks: overcite, fake actions, leaked answers).

Aug 2026 X: skills are default specialization; the hard part is **eval’ing and maintaining them**; Context Hub for skill lifecycle; still no universal model *or* harness (“Intelligence Allocation”).

RLM: they support it as **middleware**, not the default harness. Sydney Runkle wrote the Deep Agents RLM note. Viv: most users don’t need RLM decomposition; keep a thin extensible base.

Browser as a **verification tool** in self-improve loops (Stagehand), not as identity.

---

## Pattern cards (quick)

- **LC-001** Filesystem is the collab bus. Not only cold storage.
- **LC-002** Middleware = deterministic context injection (pre-complete check, env onboard, loop detect). Not a second brain.
- **LC-003** Ralph / pre-completion hook = “you may not halt until verify.” Fresh window + disk state.
- **LC-004** No universal harness. Per-model profiles (they are shipping this).
- **LC-005** Evals are mined, then become the hill. Harbor is the format we already speak.
- **LC-006** Agents that patch their own harness from traces = GEPA/AHE + our code server.
- **LC-007** HITL approval is their product default; our daily driver refuses it. Lab may still *study* the hook shape.
- **LC-008** LangGraph as the OS is the thing we do not want to port. Steal the *loop of improvement*, not the graph library.
- **LC-009** “Give the model a computer” = hands node + bash + default toolchain. Philosophy we already have; they operationalized the *onboarding*.
- **LC-010** Parallel trace-analyzers are cheap processes. Circled.

---

## How this sits next to our theses

He is not a BEAM person. He is the clearest **TS/Python harness lab** doing the work we said papers are specifying. Deep Agents *is* a fake OS (graph, checkpoints, middleware, HITL, MCP). The leftovers are sharp: eval-as-mining, onboard-the-env, force-verify, per-model harness, traces-to-patch.

Do **not** become LangChain-on-BEAM. Do **watch** him the way we watch José: one is the runtime gospel, one is the harness-eval gospel.

---

## X bookmarks (still blocked)

I cannot read Robert’s private bookmark collection.

Ways to dump them into this repo (pick one later):

1. X → Bookmarks → share/export a list of URLs (or a screenshot pass).
2. Paste a batch of links in chat.
3. Name accounts you bookmark heavily and I’ll pull *their* public timelines with the same lens.

Until then, public trails already on the wall: `@Vtrivedy10`, `@sydneyrunkle`, `@langchain`, `@harborframework`, José, and whatever you drop next.
