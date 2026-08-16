# Autoresearch → harness hill-climb

- **Status:** Working notes. Not an accepted report.
- **Updated:** 2026-08-14
- **Source:** [karpathy/autoresearch](https://github.com/karpathy/autoresearch) (accessed 2026-08-14)
- **Generalized (not models):** [Shopify Engineering, Apr 2026](https://shopify.engineering/autoresearch) — CI/build/Liquid; [`pi-autoresearch`](https://github.com/davebcn87/pi-autoresearch)
- **Karpathy on the meta:** [tweet](https://x.com/karpathy/status/2029701092347630069) — the real benchmark is *“what is the research org agent code that produces improvements the fastest?”*
- **Lens:** adapt the loop to **tune a harness, not a model**.
- **Sits next to:** [`LANGCHAIN-WATCH.md`](LANGCHAIN-WATCH.md) (traces → Harbor → patch), [`ARXIV-WATCH.md`](ARXIV-WATCH.md) AHE / Meta-Harness / GEPA.

---

## What Karpathy actually built

Three files. That is the whole invention.

| File | Who edits | Role |
|------|-----------|------|
| `prepare.py` | **Nobody** (agent forbidden) | Data, tokenizer, **evaluation**. Ground truth. |
| `train.py` | **Agent only** | The organism. Architecture, optimizer, loop. |
| `program.md` | **Human only** | The research-org constitution. Scope, keep/discard, never-stop. |

Loop (from `program.md`):

1. Hypothesis → hack `train.py` → commit.
2. Fixed **5-minute** train (`uv run train.py`).
3. One metric: `val_bpb` (lower better).
4. Better → keep commit (advance the branch).
5. Equal/worse/crash → `git reset`.
6. Log `results.tsv` (untracked): commit, metric, memory, `keep|discard|crash`, description.
7. **Never stop** to ask the human. They might be asleep. ~100 tries / night.

Constraints that make it science instead of vibes:

- **One file** in scope (diffs reviewable).
- **Fixed wall-clock budget** so runs are comparable even if the agent changes model size.
- **Agent cannot touch the evaluator** (or it Goodharts the test).
- **Simplicity criterion:** tiny gain + ugly complexity = discard; delete code + same score = keep.
- Human programs the *org* (`program.md`), not the experiment.

Karpathy’s aside: he iterated more on the **meta-setup** (agent flows) than on nanochat. The meta-benchmark is the research-org code.

---

## The adaptation: same loop, different organism

```text
Karpathy                         Harness autoresearch
─────────────────────────────    ────────────────────────────────
train.py                         harness code (prompt, tools, middleware,
                                 constitution, compact policy, …)
prepare.py / evaluate_bpb        Harbor task(s) + verifier (read-only)
5-min train                      fixed eval budget (N Harbor tasks / timeout)
val_bpb (lower)                  Harbor score / honesty / waste (higher or lower,
                                 but ONE primary + maybe a simplicity tie-break)
program.md                       program.md (human-owned)
results.tsv                      results.tsv
git keep / reset                 git keep / reset
```

**Do not train weights.** The model is frozen (Trivedy’s TB2 move). The agent may only change the harness. The evaluator must live **outside** the writable tree — same as `prepare.py`.

That is AHE + Meta-Harness + Trivedy’s trace loop, with Karpathy’s **discipline**:

- one writable surface
- one clock
- one number
- keep or revert
- human edits the constitution of the *search*, not each trial

---

## Circled vs underlined

**Circled (OTP / we already have nouns):**

- Overnight loop of child experiments = cheap processes / child Sessions.
- `git reset` = supervisor restart + discard mailbox.
- `results.tsv` = JSONL / audit.
- `program.md` = `persistent_term` constitution.
- Parallel GPUs in forks = parallel eval nodes.

**Underlined (the leftover — this is why we write it down):**

- **Split the organism from the judge.** If the agent can edit the Harbor verifier, the score will go up and the agent will not have gotten better. This is the whole trick.
- **Fixed budget** so “bigger / slower / more tokens” is not a free win.
- **Simplicity as a keep-rule**, not a vibe. Compact policy that adds 200 lines for +0.3% is a discard.
- **Human writes `program.md`,** the search policy. That *is* GEPA’s outer organism, but tiny.
- **Never-stop + asleep human** — Ralph-adjacent, but the unit is an *experiment*, not a coding turn.
- Meta-question: evolve `program.md` itself (carefully, on a slower clock) = Karpathy’s “research org code.”

---

## A sketched `program.md` for harness hill-climb (thesis, not a spec)

Writable: named harness files only (e.g. constitution, tool list, middleware/hooks, compact strategy module).

Read-only: Harbor tasks, Dockerfiles, verifiers, scoring scripts, model id.

Each trial:

1. State hypothesis in one line.
2. Change **one** concern if possible (Karpathy allows the whole `train.py`; we may want *narrower* than that so we can attribute).
3. Commit.
4. Run fixed Harbor slice (same tasks, same model, same timeout).
5. Record primary metric + token/time side stats.
6. Keep iff primary improved **and** no crash **and** simplicity not wrecked.
7. Else reset.
8. Do not ask to stop.

Primary metric candidates (pick **one** per run tag):

- Terminal-Bench / Harbor `task_ok` (Trivedy-shaped).
- Arvo attention honesty + stub/reuse (we already have the trail).
- A tiny private workshop task set (faster clock than TB2).

Side stats never decide keep/discard alone (or the agent will Goodhart them): tokens, latency, crash rate.

---

## How this braids with what we already dumped

| Idea | Role in this loop |
|------|-------------------|
| Trivedy / Deep Agents | Same-model, harness-only hill. Trace mining proposes the *next* `train.py` edit. |
| AHE / Meta-Harness | Outer loop over harness files. Autoresearch is the *dumb, reliable* inner loop they forgot to make tiny. |
| GEPA / ACE | Smarter proposers (reflect, Pareto). Can sit *above* keep/reset. Don’t replace the judge. |
| Harbor | `prepare.py`. Already in `coding-agent-harness/evals/`. |
| RLM | Optional proposer over traces (Trivedy said this). Not the metric. |
| José / code server | Mutation operator: load new beam / swap constitution. `git` is the poor man’s two-version module. |
| Fake-OS insight | Do not let the loop grow LangGraph. The loop is git + a number + a fence around the judge. |

Failure modes to write on the card:

- Agent edits the eval (forbidden).
- Agent adds “just more tokens / more time” (fixed budget).
- Overnight overfitting to 3 Harbor tasks (need a holdout slice, even tiny).
- `program.md` that is a novel (keep it short; Karpathy’s is the baseline).

---

## Article inbox

| Date | Article | One-line leftover |
|------|---------|-------------------|
| 2026-04-15 | [Autoresearch isn’t just for training models](https://shopify.engineering/autoresearch) (David Cortés / Shopify; Tobi on Liquid) | The loop is for **any metric**, not just `val_bpb`. Shopify already generalized past model training. Our move is the next specialization: the metric is a **frozen-model Harbor score**, the writable file is the **harness**. |

### Note — Shopify Engineering, 15 Apr 2026

[shopify.engineering/autoresearch](https://shopify.engineering/autoresearch)

David Cortés (Polaris) + Tobi Lütke. They took Karpathy’s loop off the GPU and pointed it at **engineering toil**: CI time, build time, Liquid parse+render, Playwright, even a [pnpm PR](https://github.com/pnpm/pnpm/pull/11073). Open-sourced as [`davebcn87/pi-autoresearch`](https://github.com/davebcn87/pi-autoresearch) (a [Pi](https://github.com/badlogic/pi-mono) extension — same Pi that is Arvo’s philosophy cousin).

**What they did**

1. Pick a metric (Polaris build started at 19.1s).
2. Measure baseline.
3. Each iteration: write a hypothesis, try it. Faster → keep. Crash or slower → discard.
4. `NEVER STOP LOOPING` until human/context dies.
5. Human throws away the *ugly* keeps (delete half the tree) and retains the real ones (skip wasted IIFE/types pipeline; TS transform 580 files → 105). **65% faster build** after that filter.
6. Tobi: 32 commits in a day (multi-metric, consistent runner, auto-commits). Then ran `/autoresearch` on **Liquid**: 53% faster parse+render, 61% fewer allocations — “probably somewhat overfit, but amazing ideas.”

**Why one-shot failed:** “Improve Polaris build time / MAKE NO MISTAKES” found tricks, didn’t even build. The loop works because it has a **number**, a **keep rule**, and permission to try crazy things *then revert*. 1% steps compound; no sprint would fund “three months to cut build 30%.” Agents don’t get bored.

**They already say it’s Ralph-shaped, more specialized.** Same family as Trivedy’s pre-completion hook.

**Leftovers for us**

- Shopify proved “not just models.” We don’t need to re-argue that. The open slot is **harness-as-`train.py`**.
- **Human still curates keeps.** Autoresearch will ship hacks. The simplicity criterion (Karpathy) and “throw away the ugly” (Cortés) are the same gate. For a harness: a keep that breaks honesty or deletes a tool to win Harbor is a hack.
- **Overfit is admitted** (Tobi on Liquid). Need a holdout Harbor slice, same as we already flagged.
- **Pi extension** is interesting socially (Arvo’s peer harness grew the UI for the loop) and not load-bearing for BEAM. Don’t port the extension; steal the table-of-iterations + never-stop.
- Internal `#autoresearch-wins` = a lab log. Our `results.tsv` / JSONL is that channel.
- Multi-metric (Tobi) vs Karpathy’s one number: tempting, dangerous. Prefer one primary + side stats that cannot keep.

**Circled:** keep/reset, overnight, metric.  
**Underlined:** generalize the *organism*; humans trash hack-keeps; toil nobody would sprint is the right workload — harness hill-climb is exactly that kind of toil.
