# Focused Research Report — Score the harness

- **Artifact type:** Focused research report
- **Program:** arvo-beam-harness-research
- **Stage:** score-harness — Score the harness
- **Status:** Accepted
- **Version:** 1.0
- **Created:** 2026-08-15
- **Last updated:** 2026-08-15
- **Research date:** 2026-08-15
- **Depends on:** Accepted Research Charter
  ([`docs/01-research-charter.md`](../01-research-charter.md),
  accepting commit `081ad36932be7f3f0df062b592cc306c49f72af4`);
  accepted Program Blueprint
  ([`docs/00-program-blueprint.md`](../00-program-blueprint.md),
  accepting commit `0b49540cae7d2a30ad4b4b145999e27b82c50dad`)
- **Must cite:** Accepted runtime report
  ([`docs/reports/10-runtime-research-report.md`](10-runtime-research-report.md),
  accepting commit `636123f1a628803aa4ae2c44fc4659d167a80693`);
  accepted leftovers report
  ([`docs/reports/11-leftovers-research-report.md`](11-leftovers-research-report.md),
  accepting commit `9698362dbe5f90ff48e7aa1093d547d2e14d410a`)
- **Output path:** `docs/reports/12-score-harness-research-report.md`
- **Recommendation range used:** `REC-200`…`REC-210`
- **Risks minted:** `RSK-019`…`RSK-029`
- **Open questions minted:** `OQ-013`…`OQ-018`
- **Open questions dispositioned:** `OQ-011` (not reminted)
- **Evidence IDs:** `EVD-200`…`EVD-219`
- **Spikes:** none (`SPK-###` unused)
- **Instrument:** `../coding-agent-harness/arvo` at
  `84004e1fcae11bbf72656c58e7fa5ae4aa92838b` (re-observed 2026-08-15;
  same HEAD the runtime report dated). Function unproven. No boot.
- **Official docs dated:** Harbor pages on
  [harborframework.com](https://www.harborframework.com/docs) opened
  2026-08-15; GEPA abs v2 and ACE abs v3 re-opened 2026-08-15.
- **Accepting commit:** `c15dd31c44c197340d2b339657eb7f072f066d44`

> This file names how a later sibling repo would run G-004 and G-005
> so the harness cannot edit the judge, and so the two tests stay
> unmerged. It does not run Harbor, boot Arvo, invent a Harbor number,
> mint G-006, or land the searcher as Arvo’s identity. Robert accepted
> this draft on 2026-08-15. Score-harness is `accepted` in
> `research-program.toml` at the commit above.

## 1. Artifact metadata and actual research date

| Field | Value |
| ----- | ----- |
| Program ID | arvo-beam-harness-research |
| Stage | `score-harness` |
| Kind | independent focused research (group A) |
| Primary question | How should the later repo run G-004 and G-005 so the harness cannot edit the judge, and so the two tests stay unmerged? |
| Actual research date | 2026-08-15 |
| Author role | Skeptical methods designer for a later experiment repo |
| Rigor | focused (Blueprint §9) |
| Replication | off |
| DEC minted | none |
| Accepting commit | `c15dd31c44c197340d2b339657eb7f072f066d44` |

## 2. Executive answer

The later repo runs **two** scoring methods, not one. This repo still
only catalogs ideas. Nothing here is a Harbor result this lab ran.

1. **G-004 — overnight keep/reset on a fixed test set.** Same frozen
   model. Each trial is a child Session (or child node). Mutation is
   `git` and, if useful, `:code.load_binary`. The loop may edit only
   named harness files (constitution, compact-strategy module, tool
   list, observe-only hooks). The human owns `program.md`. The judge
   tree, the holdout, and leftover tests are read-only. Record
   `results.tsv`: keep / discard / crash. Declare **one** primary
   *before* the run (Harbor task success *or* attention honesty — not
   both as keepers). Side stats (tokens, time, extra layer watches)
   cannot keep. Holdout required. Tiny gain + ugly complexity =
   discard. **This is the fixed-set lab loop, not “improves while you
   use it.”** Keep the *loop* if holdout rises without touching the
   scorer, without “more tokens / more time” as the win, and without
   honesty collapse. Drop if it only games three tasks. The searcher
   stays in the sibling repo. A winning *file* may later be copied
   into `arvo/`. The loop is not Arvo’s identity.

2. **G-005 — specialized helper as its own Session.** Scout ≠ critic ≠
   planner. Specialization is the child’s constitution + tool set +
   model id, not a persona in the parent prompt. Parent does not
   import the child transcript. Child cannot `start_turn` on the
   parent. Scout cannot write or see keys. Same tasks, **three arms**:
   no helper / helper = parent-model / helper = smaller-or-local.
   Score task success, parent waste, dollars, wall time. Declare
   which of those four is keep-deciding **before** the run. Local /
   smaller is allowed to lose — that is a result. Keep a specialist if
   it wins the declared score without adding a second brain for
   org-chart reasons. Drop if the child is a nested prompt with a
   process id taped on.

Harbor (or equivalent) is the later *format*, not a number we have.
Official Harbor docs (2026-08-15) put the grade in `tests/` plus a
reward file, and warn that the **default** verifier shares the agent
container.[^harbor-tasks] The later repo must use a **separate**
verifier environment (Harbor’s own recommended fence) so the organism
cannot rewrite `tests/`. Harbor’s landing page lists GEPA as an
*optimizer* integration, not as the verifier.[^harbor-docs] That
split is the official analog of leftovers `REC-111`: a proposer may
sit **above** G-004 and stay Watch. It is not G-004. It is not G-006.

| # | Plain name | SORT | Claim | Writable / isolation | Forbidden | Primary / scores | Holdout or arms | Keep / drop | Land in `arvo/`? |
| - | ---------- | ---- | ----- | -------------------- | --------- | ---------------- | --------------- | ----------- | ---------------- |
| 4 | Overnight loop on a fixed test | G-004 | Frozen model + read-only judge; keep/reset on named harness files can raise a pre-declared primary on a **holdout** | Child Session or node. `git` / optional `load_binary`. Writable: constitution, compact-strategy, tool list, observe-only hooks | Judge tree, holdout, `program.md`, leftover-test identity. Cousin “improves while you use it.” Searcher-as-product | One primary declared before the run: Harbor `task_ok` *or* attention honesty. Side stats cannot keep | Holdout required. Leftover tests (G-001…G-003 honesty / isolation / liveness) must not collapse | Keep the *loop* if holdout rises without verifier edits, without tokens/time as the win, without honesty collapse. Drop if it only Goodharts three tasks | **No.** Loop stays in the sibling repo. A winning file may be copied later |
| 5 | Specialized helpers | G-005 | Own Session, not a nested prompt. Isolation + the right specialist can cut parent waste or cost without dropping success. Local may lose | Child Session or hands node + optional worktree. Child constitution + tools + model id. Parent does not import the transcript | Nested prompt + taped-on pid. Child `start_turn` on parent. Scout writes or sees keys. Org-chart second brain (V-003). Requiring the parent to run locally | Task success, parent waste, dollars, wall time. One of the four is keep-deciding, declared before the run | Three arms: none / parent-model / smaller-or-local. Split sequential vs parallelizable (V-002) | Keep if the declared score wins without an org-chart brain. Keep local/smaller only if quality holds or a known quality drop is worth the cost. Drop a taped-on prompt | Lab first. Plan/todo chrome stays refused |

This table restates Blueprint §5 tests 4–5 and SORT Graduate G-004 /
G-005. It does not replace them. The two rows stay two.

`OQ-011` answer: **yes**, this report names a proposer slot *above*
G-004 (`REC-208`). Leftovers `REC-111` stays Watch. `REC-112` stays
Watch beside scoring (`REC-209`). No sixth test.

## 3. Scope and exclusions

### Included

- Name G-004 (overnight keep/reset on a **fixed** test set).
- Name G-005 (specialized helper as its own Session; three arms).
- Write the judge fence: what the harness may edit, what is read-only.
- Restate later measure and keep/drop. Do not replace the Blueprint /
  SORT table with a new headline.
- Compare: fixed-set loop vs “improves while you use it”; own Session
  vs nested prompt; one primary vs a layer-scoreboard-as-test;
  proposer-above vs proposer-as-G-004.
- Disposition leftovers `OQ-011`, `REC-111`, `REC-112`.
- Inherit accepted runtime `REC-001`…`REC-011` as hosts a later loop
  may score. Do not rename them.
- Mint `REC-200`…`REC-210`, `RSK-019`…`RSK-029`, `OQ-013`…`OQ-018`.
- Use Exa REST for current Harbor official docs and already-cited
  GEPA / ACE abstracts. Classify the primary pages.

### Excluded

- Coding, `mix` tasks, Harbor **runs**, boot or smoke of Arvo, PRs
  into `arvo/`.
- Minting `SPK-###`.
- Writing leftovers, runtime, synthesis, specs, plans, or reviews.
- Inventing G-006. Promoting a leftover card or Watch cluster to a
  headline. Redesigning G-001…G-003.
- Merging G-004 with “improves while you use it.” Designing an online
  improver. Landing the searcher as Arvo’s identity.
- Treating a nested prompt as a child Session.
- Requiring the parent model to run locally.
- Opening intake. Re-sorting SORT. Reading Watch dump files.
- Building Elixir-LangGraph, photocopying a paper, Port-as-native.
- MCP, Horde, Oban, libcluster, OTP relups, or LiveView as
  architecture.
- Treating Watch as a failure; raiding leftover cards to look busy.
- Inventing a Harbor number as if this lab ran one.
- Marking `score-harness` accepted.

## 4. Inherited constraints

From accepted Blueprint §7 and accepted Charter §1. Detail stays
there. Do not re-litigate.

1. Personal lab, not a race.
2. Two programs. This repo writes the catalog. A later sibling repo
   runs tests.
3. No spikes, evals, Harbor runs, smoke tests, or PRs into Arvo
   **here**.
4. Arvo is the instrument, not a daily driver. “In the tree” ≠
   “works.”
5. Local path: `../coding-agent-harness/arvo`. Ignore `ore/` unless
   the owner says so.
6. The runtime is the framework: swap plugins without dropping state;
   the window is a client of a living agent; brains and hands sit in
   different places.
7. The gap is Arvo’s thin OTP slice: one Session, tools in-process,
   Mix-compile plugins, quit-window kills the VM, file-search native
   code on the brain.
8. Adaptation, not photocopy, not “refuse every rewrite.” A
   Port-wrapped foreign harness is a shell.
9. Intake is closed.
10. Success bar: catalog, not a working harness.
11. Rigor: focused. Replication off. No `SPK-###` here.
12. This track owns only G-004 and G-005. Do not absorb runtime’s
    three tests or leftover cards.
13. Five tests stay five. No G-006.
14. G-004 is a lab loop on a **fixed** test set. Do not merge it with
    “improves while you use it.”
15. G-005 helpers are specialized (scout / critic / planner). Arms:
    none / parent-model / smaller-or-local. Local may lose.
16. Phase-2’s first job includes an Arvo smoke check — **there**.

Accepted runtime host nouns stay named (`REC-001`…`REC-011`).
Especially: JSONL auto-resume is not G-001 (`REC-003`); Port-wrap of
a foreign harness is not hands (`REC-006`).

Accepted leftovers: GEPA/ACE stay Watch above G-004 (`REC-111`).
Traces-as-ore / layer scores stay Watch beside scoring (`REC-112`).
Do not design an online improver. Do not make layer scores G-006.

Graduate labels `G-001`…`G-005` and dump labels `H-` / `P-` / `V-` /
`XB-` / `LC-` are **intake IDs**. Cite them. They are not `REC`
numbers.

## 5. Methodology

1. Read the accepted Blueprint and accepted Charter in full, then the
   score-harness commissioning prompt, then the accepted runtime
   report, then the accepted leftovers report, then the
   focused-report, evidence-model, recommendation, and evidence-spike
   contracts. Skim SORT Graduate **G-004 and G-005 only**, the locked
   top of DISCOVERY-NOTES (two programs, José hypothesis, central
   insight, adaptation), runtime §17 digest plus §2 / §9, leftovers
   §17 digest plus `REC-111` / `REC-112` / `OQ-011`, authority,
   anti-patterns, validation, and approval-gates. Did **not** re-sort.
   Did **not** open Watch files, bookmark JSON, PDFs, or vault traces.

2. Worked the **locked** two tests. Did not invent a third scoring
   headline. Preferred restating Blueprint / SORT measure and
   keep/drop over rewriting them.

3. **Exa via REST only** (`AGENTS.md`). Loaded `EXA_API_KEY` from
   gitignored `.env`. Did **not** print the key. Did **not** use Exa
   MCP. Did **not** harvest new papers.
   - Ordinary lookup: `POST https://api.exa.ai/search`, `type`
     `auto`, 2026-08-15, HTTP 200, for four official-Harbor queries
     (Harbor docs, Harbor task/verifier wording, `site:harborframework.com`,
     Harbor GitHub README).
   - Did **not** run Exa `type` `deep` / `deep-reasoning` or
     `POST https://api.exa.ai/agent/runs`. Ordinary lookup named the
     official URLs.
   - Exa is retrieval. Each load-bearing primary URL was opened
     independently and classified as an official claim or a verified
     fact *about that document*.
   - Already-cited GEPA and ACE abstracts were re-opened on the
     primary arXiv pages (not via a new harvest).

4. Local Arvo tree was opened **only** to verify facts the notes
   already claimed (Harbor packaging, headless path, `evals/` suite,
   audit score names). Date + commit recorded. Did **not** boot Arvo.
   Did **not** run Harbor. Did **not** run a Mix task as a test.
   Checkout descriptions are not function.

5. Compared: G-004 vs cousin; G-005 vs nested prompt; one primary vs
   layer-score-as-test; proposer-above vs proposer-as-G-004. One
   `REC` per decision area. Scoring-method `REC`s tag G-004 **or**
   G-005, not both. Named later measures. Did not run them. Did not
   mint `SPK-###`.

6. High confidence only for user decisions and dated primary reads of
   a document or source line. “This loop would raise holdout” stays
   Medium or Low. Popularity and star counts are not used.

## 6. Source quality and limitations

| Source class | Quality here | Limitation |
| ------------ | ------------ | ---------- |
| Accepted Blueprint + Charter | User decision (High as *lock*) | Locks the two tests and the fences; does not prove a loop works |
| Accepted runtime report | Evidence + recommendation (host nouns) | Function of Arvo still unproven; this track may not rename hosts |
| Accepted leftovers report | Evidence + recommendation (cards; `REC-111` / `REC-112` / `OQ-011`) | Cards are not tests; leftover ≠ proven adaptation |
| SORT Graduate G-004 / G-005 | Framing evidence | Not governing after Blueprint; not a passing run |
| DISCOVERY-NOTES locked top + already-cited Harbor-path claims | Framing; checkout pointers | Dump is not a BEAM result; claimed `evals/` path is **absent** at this HEAD |
| Harbor official docs (harborframework.com) | Tier 1 method source | Official *format* and flags. Not a result this lab ran. Flags can move |
| Harbor “GEPA for optimizing agents” on the docs landing page | Official claim about Harbor’s product surface | Optimizer ≠ verifier. Not a license to merge the cousin into G-004 |
| GEPA / ACE abstracts | Tier 2 insight / official claim of the paper | Paper numbers are *their* results, not ours |
| Arvo `rel/RELEASE.md`, `application.ex`, `audit.ex`, missing `evals/` | Verified fact about source text at `84004e1` | Function unproven. Missing suite ≠ “we already have a Harbor number” |
| Exa REST search | Retrieval tool | Not a source tier; not a verified fact |

No tier-3 measurements exist in this program. This report produced
none. A Harbor method page is design insight, not a BEAM result.

## 7. Evidence spikes

**None in this repo.**

Phase-2 (sibling experiment repo) would measure, and must not
back-fill `SPK-###` here:

| Tempted command (do **not** run here) | Host | What it would answer |
| ------------------------------------- | ---- | -------------------- |
| `harbor run -p <fixed-set> -a <arvo-agent> -m <frozen-id>` with `tests/` on a separate verifier | G-004 | Does keep/reset raise the pre-declared primary on holdout? |
| Diff the judge tree (`tests/`, `task.toml` `[verifier]`) before vs after a trial | G-004 | Did the organism eat the judge? |
| Same frozen model; train slice vs held-out slice; record `results.tsv` | G-004 | Holdout vs Goodhart-three-tasks |
| Tiny constitution tweak that adds a large module tree | G-004 | Simplicity discard |
| Three-arm G-005 sweep on the same tasks | G-005 | Does a specialist win success, waste, or cost? May local lose? |
| Child that is only a parent-prompt persona plus a pid | G-005 | Nested-prompt drop |
| Scout child tries to read `XAI_API_KEY` or write the repo | G-005 | Scout isolation |
| Sequential task (V-002 shape) with a planner child | G-005 | Org-chart / sequential regression |
| Optional proposer suggesting a constitution edit *after* a recorded trial, judge still read-only | none (above G-004) | Proposer leftover; not G-004 itself |
| Layer watches (honesty, stub/reuse, isolation, kill-Focus-lives) logged beside one primary | none (beside scoring) | REC-112 watches; not G-006 |

## 8. Comparative analysis

### 8.1 G-004 versus the cousin

G-004 is a **lab loop on a fixed test set**. The model is frozen. The
task list is frozen before the run. The judge is off-limits. A trial
edits named harness files, scores, then keeps or resets.

“Improves while you use it” is a different cousin. It is online. The
task stream is not fixed. Memory, playbook, or constitution can drift
across real work. ACE’s official abstract names that surface
explicitly: contexts evolve **offline** (system prompts) *and*
**online** (agent memory), and warns that iterative rewrite collapses
detail.[^ace] Harbor’s own docs landing page lists GEPA as a
framework for *optimizing* agents.[^harbor-docs] Those sentences are
why a proposer slot can exist **above** a judge. They are not a
license to merge the cousin into G-004.

| | G-004 (this test) | Cousin (not this test) |
| - | ----------------- | ---------------------- |
| Task set | Fixed before the run | Live / drifting |
| Model | Frozen | Often free to change |
| Judge | Read-only | Tempted to move with the organism |
| `program.md` | Human, slower clock | Tempted to self-rewrite |
| Keep rule | Holdout on the declared primary | “Felt better today” |
| Identity | Sibling-repo searcher | Product that learns in use |

Blueprint §7.15 forbids the merge. `REC-205` rejects it. Charter
reviewers are instructed to attack the collapse.

### 8.2 Judge fence

Karpathy’s fence, already in SORT: the agent must not edit the judge.
Harbor official docs give the later repo a concrete tree for that
fence.

A Harbor task is a directory: `instruction.md`, `task.toml`,
`environment/`, optional `solution/`, and `tests/` (must contain
`test.sh` / `test.bat`). The test script must write
`/logs/verifier/reward.txt` or `reward.json`. Harbor copies `tests/`
into the verifier working directory at runtime (shared mode) or
**builds the verifier image from `tests/`** (separate mode).[^harbor-tasks]
A job writes `result.json` plus a `verifier/` directory
(`reward.txt`, stdout/stderr).[^harbor-evals] Regrade re-runs only
the verifier against recorded agent artifacts; the agent phase is
held fixed.[^harbor-regrade]

**Default Harbor verifier mode is `shared`** — the grader sees the
same container the agent just used. Official Task Structure docs
add **separate** mode for proprietary grading code the agent must
not see.[^harbor-tasks] Official Regrade docs recommend separate
mode as the way to author tasks and say it “will soon become the
default.”[^harbor-regrade] Sidecar anti-cheat text is explicit:
evidence from a channel the agent’s container cannot write is the
trustworthy channel.

For this catalog, the later repo treats the following as the
**judge tree** and keeps it read-only to the organism:

| Object | Role | Harness may edit? |
| ------ | ---- | ----------------- |
| Harbor `tests/` (`test.sh`, grader code, tests Dockerfile) | Verifier | **No** |
| `task.toml` `[verifier]` and `[verifier.environment]` | Verifier config | **No** (human / lab) |
| `instruction.md` and the frozen task list | Fixed set | **No** during a tagged run |
| Holdout slice (tasks or audit cases withheld before the run) | Holdout | **No** |
| `solution/solve.sh` (Oracle) | Sanity of the *task*, not a keep | **No** as a mutation target |
| `program.md` | Searcher meta | **No.** Human owns it. Slower clock (`REC-210`) |
| Leftover-test identity (G-001 liveness, G-002 isolation, G-003 swap) | Must also improve / not collapse | **No** renaming or dropping mid-run |
| Constitution / compact-strategy module / tool list / observe-only hooks | Named organism files | **Yes** (G-004 writable set) |
| Child Session workdir for a trial | Ephemeral | Yes, then keep or `git` reset |
| Audit JSONL produced by a trial | Trace | Append-only; the organism does not rewrite history |
| Layer watches (honesty, stub/reuse, isolation, kill-Focus-lives) | Side stats (`REC-209`) | Logged; cannot keep unless that layer *was* the declared primary |

The later repo should run G-004 trials with Harbor
`verifier.environment_mode = "separate"` (or an equivalent OS fence
that the agent process cannot write). Shared-mode Harbor is a
known hole (`RSK-020`). Regrade is allowed *after* a run to fix a
broken grader; changing the grader mid-search is eating the judge.

### 8.3 G-004 loop recipe

This is the fixed-set lab loop, not “improves while you use it.”

| Piece | Recipe |
| ----- | ------ |
| Frozen model | One model id, recorded in the run tag, unchanged for every trial in that tag |
| Child Session | Each trial is a child Session or child node. Not a mutation of the operator’s daily Session (there isn’t one) |
| Mutation | `git` commit or reset of named files. Optional `:code.load_binary` of a compact-strategy / hook module (inherits runtime `REC-009`: Mix out; no `on_load` on the brain) |
| Writable files | Constitution, compact-strategy module, tool list, observe-only hooks |
| `results.tsv` | One row per trial: `keep` / `discard` / `crash` plus the declared primary and side stats |
| One primary per run tag | Harbor `task_ok` (reward 1/0 or the named float) *or* attention honesty. Pick before trial 1. Do not switch after seeing numbers |
| Holdout | A slice withheld before trial 1. Keep is illegal on the train slice alone |
| Simplicity discard | Tiny gain + ugly complexity = discard. Human still throws away hack-keeps |
| Leftover tests | G-001 / G-002 / G-003 measures from the accepted runtime report must not collapse. They are not a sixth primary |
| Land in `arvo/` | **No** for the loop. A winning file is a later product gate |

Blueprint §5 already wrote this table in shorter form. This recipe
sharpens the fence. It does not replace the claim.

### 8.4 G-005 versus a nested prompt

G-005’s leftover is **isolation + specialization**, not “add another
voice.” SORT already named the drop: a nested prompt with a process
id taped on. Refuse already named the other drop: multi-agent chat
democracy / org chart (V-003).

| | Own Session (keep-shaped) | Nested prompt (drop) |
| - | ------------------------- | -------------------- |
| Process | Child Session or hands node | Same Session, extra system text |
| Constitution | Child’s own | Parent’s, with a persona paragraph |
| Tools | Child’s set (scout: no write, no keys) | Parent’s tools, maybe “please don’t” |
| Transcript | Parent does **not** import it | Parent sees everything |
| `start_turn` | Child cannot start a turn on the parent | There is only one turn owner |
| Model | Parent-model arm *or* smaller/local arm | Almost always the parent model |
| Why it exists | Specialist work the parent should not do | Org chart, “agents collaborating” |

A pid without those isolation rules is theater. `REC-206` rejects it.

### 8.5 G-005 arms

Same tasks. Frozen *parent* model. Three arms. Local / smaller may
lose.

| Arm | Helper | What changes | Isolation rules | Scores |
| --- | ------ | ------------ | --------------- | ------ |
| none | No child | Baseline parent Session | n/a | Task success, parent waste, dollars, wall time |
| parent-model | Scout / critic / planner as its own Session, **same** model id as parent | Extra Session + specialist constitution / tools | Parent does not import transcript; child cannot `start_turn` on parent; scout cannot write or see keys | Same four. Extra dollars and wall time are expected; they cannot hide a success drop unless that trade was declared |
| smaller-or-local | Same specialist shape, cheaper / local model | Model id on the child only | Same isolation. Parent does **not** have to run locally | Same four. A quality drop with a cost win is a result, not an automatic keep |

Pick **one** specialist family per run tag (scout *or* critic *or*
planner). Do not blend them into a committee in the first try.
Split sequential vs parallelizable tasks (V-002): a planner that
helps a parallel explore and hurts a single-file sequential edit is
not a blanket keep.

Declare before the run which of the four scores is keep-deciding.
The other three are side stats.

### 8.6 One primary versus layer-score-as-test

Leftovers `REC-112` left “score layers; traces are ore” on Watch.
SORT named honesty, stub/reuse, isolation, kill-Focus-lives as
layers next to Harbor `task_ok`.

Those layers are **watches**, not G-006 (`REC-209`). Official Harbor
`reward.json` may carry several numeric metrics.[^harbor-tasks] That
does not make each metric a keep. Side stats (tokens, time, extra
JSON fields, audit `waste_ratio`, `stub_reuse`) cannot keep.

The Arvo tree at `84004e1` already *names* `task_ok`, `honesty`,
`waste_ratio`, `stub_reuse`, and `stranding_candidate` on an audit
decision report.[^arvo-audit] That is checkout text. It is not a
Harbor number this lab ran. The claimed suite path
`evals/arvo-attention-reread/` is **not present** at this HEAD
(`EVD-214`). Phase-2 may rebuild an honesty scoreboard from audit
JSONL. It may not pretend the missing suite already scored a keep.

`OQ-007` (density on audit JSONL) stays unanswered here. Density is
not a G-004 primary.

### 8.7 Proposer above G-004 versus proposer as G-004

`OQ-011` asked whether this report names a proposer slot above
G-004.

**Yes.** `REC-208` names the slot and leaves it Watch.

| | G-004 keep/reset | Proposer slot (Watch, above) |
| - | ---------------- | ---------------------------- |
| Who mutates | The loop, by `git` of named files | An optional searcher that *suggests* a mutation |
| When | Each trial | After a recorded trial, if ever |
| What it may touch | Writable named harness files | The same writable set only |
| What it must not touch | Judge, holdout, `program.md` | Judge, holdout, `program.md` |
| GEPA / ACE | Not the loop | Possible later bodies of the slot. Stay Watch (`REC-111`) |
| Online cousin | Forbidden | Forbidden. Offline / batch on a fixed set only |
| Keep rule | Holdout on the declared primary | Only if it *helped* that G-004 holdout without eating the judge |

GEPA’s official abstract: sample trajectories, reflect in natural
language, propose prompt updates, keep a Pareto front.[^gepa] ACE’s
official abstract: generate / reflect / curate a playbook; brevity
bias and context collapse.[^ace] AHE sting (SORT): evolving the
system prompt was a weak lever. Those sentences justify **Watch**,
not a sixth test and not an online improver.

Bilevel / AutoHarness / Hermes mutate the *searcher* (`program.md`).
That is one more clock above the proposer (`REC-210`). Human owns
it.

Leftovers disposition (required; cards stay cards):

| Leftover | This report’s answer | Still |
| -------- | -------------------- | ----- |
| `REC-111` GEPA / ACE as proposers | **Yes**, a proposer slot exists *above* G-004 (`REC-208`). It is not G-004 and not an online improver | Watch |
| `REC-112` traces as ore / layer scores | A later judge may *watch* honesty, stub/reuse, isolation, kill-Focus-lives (`REC-209`). Not a keep unless that layer was the declared primary. Not G-006 | Watch |
| `OQ-011` proposer slot above G-004? | **Yes.** Named in `REC-208`. Not reminted | Watch (slot named; leftover not promoted) |

### 8.8 Runtime inheritance

A later G-004 loop may **score** the accepted hosts. It must not
rename them. It must not treat a Required runtime drop as a keep.

| Inherited `REC` | Host | How a later loop may use it | Forbidden use |
| --------------- | ---- | --------------------------- | ------------- |
| REC-001 | G-001 | Leftover test: quit tile; Session + JSONL live; new client continues | Scoring disk resume as attach |
| REC-002 | G-001 | Host recipe the loop must not undo (permanent Session, no halt-on-quit) | Mutating Focus back into `:halt` and calling it a keep |
| REC-003 | G-001 | Required drop | JSONL auto-resume as G-001 primary or leftover pass |
| REC-004 | G-002 | Leftover test: thinnest isolation that still passes | Docker-first because papers do |
| REC-005 | G-002 | Required drop | Shared cookie as a fence the loop “improved” |
| REC-006 | G-002 | Required drop | Port-wrap of a foreign harness as hands |
| REC-007 | G-002 | Optional thicker rung | Promoting Docker to a sixth test |
| REC-008 | G-002 | NIF / bash stay on hands | Loading a NIF onto the brain as a G-004 mutation |
| REC-009 | G-003 | Leftover test + legal mutation tool (`load_binary`, two versions, `soft_purge`) | Mix-in-VM “swap” as a keep |
| REC-010 | G-003 | Required drop | `Code.append_path` plus hope |
| REC-011 | G-003 | Required drop | Relups as the plugin story |

G-005 may place a child on a hands node (REC-004) and may add a
worktree (leftovers `REC-104`) without making worktree a headline.

### 8.9 Searcher meta and why five stay five

G-004 is the tiny loop. Bilevel / AutoHarness / Hermes-style kits
mutate the searcher. SORT already parked them on Watch. This report
does not raid that shelf. `program.md` stays on a slower clock than
the constitution.

Five tests stay five. A leftover card is not a test. A layer score
is not G-006. A proposer slot is not G-006. Runtime’s three hosts
are things a loop may score, not this track’s to redesign.

### 8.10 Checkout versus a Harbor number

DISCOVERY-NOTES claimed a Harbor suite at
`evals/arvo-attention-reread/` and a Mix release tarball as the
Harbor artifact. At `84004e1` (2026-08-15 look):

- `evals/` is **absent**. The attention-reread suite is not there.
- `rel/RELEASE.md` does describe a Mix release tarball for Harbor
  upload and a headless `arvo-chat` entry.[^arvo-release]
- `ARVO_HEADLESS` / `ARVO_MODE=chat|headless` skip Focus and
  auto-resume.[^arvo-app]
- `Session.Audit.decision_report/2` names `task_ok`, `honesty`,
  `waste_ratio`, `stub_reuse`.[^arvo-audit]

Those are dated source-text facts. They do not mean a scorer works.
They do not authorize inventing a Harbor number. Phase-2 still
starts with an Arvo smoke check **there**.

## 9. One coherent recommendation set

### REC-200 — G-004 is the fixed-set keep/reset loop

- **Classification:** Required
- **Applies to:** Sibling-repo test G-004; catalog scoring method
- **Confidence:** High (lock); Medium / Low (holdout would rise)
- **Decision urgency:** Required now
- **Evidence quality:** Strong as lock; Weak as empirical pass
- **Related decisions:** None

#### Recommendation

Keep G-004 as its own headline: an overnight keep/reset loop on a
**fixed** test set, frozen model, child Session (or child node),
mutation via `git` and optional `:code.load_binary`. This is the
fixed-set lab loop, not “improves while you use it.”

#### Claim

With a frozen model and a read-only Harbor (or equivalent) verifier,
editing only named harness files can raise a pre-declared primary
metric on a holdout slice.

#### Host primitive

G-004

#### Why Watch

Not Watch — this is headline test G-004.

#### Later measure

`results.tsv`: keep / discard / crash. One primary per run tag
(Harbor `task_ok` *or* attention honesty), declared before trial 1.
Holdout required. Side stats cannot keep. Leftover G-001…G-003
measures must not collapse. Do not run it here.

#### Keep / drop

Keep the *loop* if holdout rises without verifier edits, without
“more tokens / more time” as the win, and without honesty collapse.
Human still throws away hack-keeps. Drop if it only Goodharts three
tasks.

#### Score-harness extra

**G-004.** Fixed-set lab loop. Not “improves while you use it.”

#### Requirements and Constraints

- Inherit Blueprint §5 row 4 and §7.15.
- Writable set and judge fence as `REC-201`.
- Frozen model + one primary as `REC-202`.
- Loop is not Arvo’s identity (`REC-204`).

#### Rationale

Blueprint and SORT already named this test. The catalog is dishonest
without the recipe sitting next to the host nouns a loop may score.

#### Evidence

EVD-200, EVD-201, EVD-202, EVD-203, EVD-204, EVD-217.

#### Evidence Spikes

None in this repo. Later measure: the `harbor run` / `results.tsv` /
holdout sequence in §7.

#### Tradeoffs

A tiny fixed set is cheap and easy to Goodhart. A large set is
honest and expensive. Holdout is the tax.

#### Failure Modes

Cousin merge (`REC-205`). Judge eaten (`REC-201`). Tokens/time sold
as the win. Missing suite path treated as a number we already have
(`EVD-214`).

#### Alternatives Considered

- Merge G-004 with online improvement — rejected (`REC-205`).
- Skip G-004 because Harbor official docs mention GEPA — rejected;
  that is the proposer slot, not the loop.

#### Downstream Implications

Synthesis must keep G-004 split from G-005 and from the cousin.
Phase-2 may run this only after the Arvo smoke check *there*.

#### Revisit Triggers

Owner amends G-004 (material). Harbor reward format changes so
`task_ok` is no longer expressible.

---

### REC-201 — Judge tree, holdout, and `program.md` are read-only

- **Classification:** Required
- **Applies to:** Sibling-repo test G-004; judge fence
- **Confidence:** High (lock + dated Harbor wording)
- **Decision urgency:** Required now
- **Evidence quality:** Strong as lock and official method page;
  Weak as “separate mode will hold in our lab”
- **Related decisions:** None

#### Recommendation

The organism may not edit the scorer, the holdout, leftover-test
identity, or `program.md`. Prefer Harbor **separate** verifier mode
(or an equivalent fence). Shared-mode Harbor is not an honest G-004
judge.

#### Claim

A keep is meaningless if the harness can rewrite `tests/`, peek at
the holdout, or retune `program.md` mid-search.

#### Host primitive

G-004

#### Why Watch

Not Watch — required fence for G-004.

#### Later measure

Diff the judge tree and `program.md` before vs after every trial.
Any write → crash / discard, not keep. Confirm
`verifier.environment_mode = "separate"` (or equivalent) on the run
tag. Do not run it here.

#### Keep / drop

Drop any trial that touched the judge, the holdout, or `program.md`.
Drop a run that used shared-mode verification as if it were sealed.

#### Score-harness extra

**G-004.** Fixed-set lab loop. Not “improves while you use it.”

#### Requirements and Constraints

- Writable: constitution, compact-strategy module, tool list,
  observe-only hooks only.
- Human owns `program.md` (`REC-210`).
- Regrade may fix a grader *after* a run; it may not silently become
  a mid-search mutation.

#### Rationale

SORT already stated the Karpathy fence. Harbor official docs name
`tests/`, the reward file, shared vs separate verifier, and
anti-cheat for sidecar evidence.[^harbor-tasks] Separate mode exists
because the default is not a fence.

#### Evidence

EVD-200, EVD-202, EVD-204, EVD-205, EVD-206.

#### Evidence Spikes

None in this repo. Later measure: the judge-tree diff in §7.

#### Tradeoffs

Separate verifier costs a second image and artifact plumbing.
Shared mode is easier and eats the judge.

#### Failure Modes

Organism patches `test.sh`. Holdout leaks into the train prompt.
Lab “fixes” the grader after seeing a bad number and records a keep.

#### Alternatives Considered

- Trust shared-mode Harbor plus a prompt that says “don’t look” —
  rejected.
- Custom in-process Elixir judge inside the Session VM — rejected;
  that is easier to eat, not harder.

#### Downstream Implications

Phase-2 task authoring starts in separate-verifier mode.
Synthesis must not weaken this fence.

#### Revisit Triggers

Harbor makes separate mode the actual default and shared mode
disappears; or Harbor removes separate mode.

---

### REC-202 — Freeze the model; declare one primary before the run

- **Classification:** Required
- **Applies to:** Sibling-repo scoring run under G-004
- **Confidence:** High (lock)
- **Decision urgency:** Required now
- **Evidence quality:** Strong as lock
- **Related decisions:** None

#### Recommendation

For a tagged G-004 run: freeze the model id. Declare **one** primary
number before trial 1. Legal primaries: Harbor task success
(`reward.txt` 1/0 or the named `task_ok` float) *or* attention
honesty. Side stats cannot keep.

#### Claim

A keep that chose its metric after seeing the spreadsheet is not a
keep.

#### Host primitive

G-004

#### Why Watch

Not Watch — required scoring rule for G-004.

#### Later measure

The run tag records model id, primary name, holdout id, and
writable-file allowlist *before* trial 1. After the run, verify
those four fields did not change. Do not run it here.

#### Keep / drop

If the primary was switched, or the model id moved, the tag is
invalid. Tiny gain + ugly complexity = discard even if the primary
ticked up.

#### Score-harness extra

**G-004.** Fixed-set lab loop. Not “improves while you use it.”

#### Requirements and Constraints

- G-005 declares its own keep-deciding score among its four
  (`REC-203`). Do not tag both tests on this `REC`.
- Layer watches stay watches (`REC-209`).
- Do not invent a Harbor number in this catalog.

#### Rationale

Blueprint §5, Charter §10, and SORT G-004 already require one
primary and a frozen model. Harbor `reward.json` can carry many
floats; that is a temptation, not a keep rule.

#### Evidence

EVD-200, EVD-201, EVD-202, EVD-203, EVD-204.

#### Evidence Spikes

None in this repo. Later measure: the pre-declared run-tag check.

#### Tradeoffs

Picking honesty as primary can hide a task-success drop, and the
reverse. That is why the pick is *before* the run, not after.

#### Failure Modes

“We improved tokens.” “We improved a layer we liked.” Switching
primary at trial 12.

#### Alternatives Considered

- Composite score as the primary — rejected for the first runs;
  composites hide Goodhart. A later amendment may add one.
- Always use Harbor reward 1/0 — allowed as *a* pick, not the only
  legal pick. Honesty remains the other legal primary.

#### Downstream Implications

Phase-2 writes the primary on the run tag first. Synthesis must not
turn side stats into keepers.

#### Revisit Triggers

Owner amends the legal-primary list.

---

### REC-203 — G-005 is an own-Session specialist with three arms

- **Classification:** Required
- **Applies to:** Sibling-repo test G-005
- **Confidence:** High (lock); Medium / Low (a specialist would win)
- **Decision urgency:** Required now
- **Evidence quality:** Strong as lock; Weak as empirical pass
- **Related decisions:** None

#### Recommendation

Keep G-005 as its own headline. A specialized helper (scout / critic
/ planner) is its **own Session** (or hands node), not a nested
prompt. Run three arms on the same tasks: none / parent-model /
smaller-or-local. Local may lose.

#### Claim

Isolation plus the right specialist can cut parent waste or cost
without dropping task success. A taped-on prompt is not that claim.

#### Host primitive

G-005

#### Why Watch

Not Watch — this is headline test G-005.

#### Later measure

Same tasks, three arms. Score task success, parent waste, dollars,
wall time. Declare which of the four is keep-deciding before the
run. Scout cannot write or see keys. Parent does not import the
child transcript. Child cannot `start_turn` on the parent. Split
sequential vs parallelizable tasks (V-002). Do not run it here.

#### Keep / drop

Keep a specialist if it wins the declared score without adding a
second brain for org-chart reasons (V-003). Keep local/smaller only
if quality holds or a known quality drop is worth the cost. Drop if
the child is a nested prompt with a pid taped on, or if sequential
tasks regress like V-002.

#### Score-harness extra

**G-005.** Specialists: scout / critic / planner (one family per
run tag). Arms: none / parent-model / smaller-or-local. Local may
lose.

#### Requirements and Constraints

- Specialization = child constitution + tool set + model id.
- Parent model need not run locally.
- Plan/todo chrome stays refused (Blueprint non-goal; leftovers
  Refuse). Lab may still study planner-as-child.
- Do not merge with G-004.

#### Rationale

Blueprint §5 row 5, §7.16, and SORT G-005 already wrote the arms.
This `REC` is the catalog-honest scoring rule the sibling cannot
skip.

#### Evidence

EVD-200, EVD-201, EVD-202, EVD-203, EVD-211.

#### Evidence Spikes

None in this repo. Later measure: the three-arm sweep in §7.

#### Tradeoffs

Three arms cost three times the dollars. Skipping the none arm
makes every helper look useful.

#### Failure Modes

Nested prompt (`REC-206`). Committee of specialists on day one.
Requiring local parent. Counting extra wall time as a keep.

#### Alternatives Considered

- Two arms (skip none) — rejected; no baseline.
- Force local parent — rejected (Blueprint non-goal).
- Treat G-005 as a G-004 mutation of the tool list — rejected;
  isolation is the leftover.

#### Downstream Implications

Synthesis keeps G-005 split. Phase-2 may start with scout (narrowest
tool set) after the smoke check.

#### Revisit Triggers

Owner amends G-005.

---

### REC-204 — The G-004 loop is not Arvo’s identity

- **Classification:** Required
- **Applies to:** Catalog honesty; later product gate
- **Confidence:** High (lock)
- **Decision urgency:** Required now
- **Evidence quality:** Strong as lock
- **Related decisions:** None

#### Recommendation

The searcher lives in the sibling experiment repo. Do not copy the
loop into `arvo/` as the product. A winning *file* (constitution,
module) may later be copied as a separate gate.

#### Claim

G-004 is how the later repo stays a lab. It is not what Arvo *is*.

#### Host primitive

G-004

#### Why Watch

Not Watch — required placement rule.

#### Later measure

Phase-2 directory layout: loop, `results.tsv`, `program.md`, and
judge tree live outside `arvo/`. A keep copies a file, not the
searcher. Do not run it here.

#### Keep / drop

Drop a design whose README says Arvo *is* the overnight loop.

#### Score-harness extra

**G-004.** Fixed-set lab loop. Not “improves while you use it.”

#### Requirements and Constraints

- Blueprint §22 item 3.
- `REC-207` is the Rejected twin (searcher-as-product).

#### Rationale

Operator care on G-004 was “huge as *method*.” Landing the searcher
would make Arvo an online improver in all but name.

#### Evidence

EVD-200, EVD-201, EVD-212.

#### Evidence Spikes

None in this repo. Later measure: the directory-layout check.

#### Tradeoffs

A loop inside `arvo/` would be closer to the files it edits. It
would also become the product.

#### Failure Modes

`arvo/` grows a `searcher/` app. Cousin merge by directory.

#### Alternatives Considered

- Loop as an Arvo profile — rejected; profile is G-003 payload
  hosting, not a searcher identity.

#### Downstream Implications

Implementation plan’s first milestone is still the Arvo smoke
check, not “install the searcher.”

#### Revisit Triggers

Owner amends Blueprint §22.

---

### REC-205 — Reject merging G-004 with “improves while you use it”

- **Classification:** Rejected
- **Applies to:** Catalog honesty for G-004
- **Confidence:** High (lock)
- **Decision urgency:** Required now
- **Evidence quality:** Strong as lock
- **Related decisions:** None

#### Recommendation

Do not merge G-004 with the cousin “the harness gets better while
you use it.” Online ACE-style memory, live playbook rewrite, and
“self-improving while coding” are not this test.

#### Claim

A drifting task stream plus a writable judge is a different
experiment. Calling it G-004 is a catalog lie.

#### Host primitive

G-004

#### Why Watch

Not Watch — Rejected merge.

#### Later measure

If a design has no frozen task list, or mutates constitution from
live user sessions without a holdout, record **drop** as G-004.

#### Keep / drop

Drop that design as a G-004 keep. The cousin may remain a Watch
sentence (`REC-208` still is not the cousin).

#### Score-harness extra

**G-004.** Fixed-set lab loop. Not “improves while you use it.”

#### Requirements and Constraints

- ACE “self-improving” / online memory wording stays a warning, not
  a keep (`REC-111`, `REC-208`).
- Charter §15 attack 1.

#### Rationale

Blueprint §6 and §7.15. Charter anti-pattern table. Leftovers
already refused to design the cousin.

#### Evidence

EVD-200, EVD-201, EVD-208, EVD-209, EVD-210.

#### Evidence Spikes

None in this repo. Later measure: frozen-set check on the run tag.

#### Tradeoffs

The cousin is the more romantic paper. It is also the one that
eats the judge.

#### Failure Modes

GEPA integration on Harbor’s landing page used as proof we should
optimize online. ACE leaderboard cited as a G-004 keep.

#### Alternatives Considered

- Soften G-004 to “usually fixed” — rejected; amendment required.

#### Downstream Implications

Reviews must attempt the collapse attack. Synthesis that “clarifies”
G-004 into online improvement has failed (Charter §14).

#### Revisit Triggers

Owner amends §7.15 (material).

---

### REC-206 — Reject a nested prompt as a G-005 child

- **Classification:** Rejected
- **Applies to:** Catalog honesty for G-005
- **Confidence:** High (lock)
- **Decision urgency:** Required now
- **Evidence quality:** Strong as lock
- **Related decisions:** None

#### Recommendation

A nested prompt with a process id taped on is not G-005. Drop it.

#### Claim

G-005’s leftover is an isolated specialist Session. A persona
paragraph is prompt theater (Refuse).

#### Host primitive

G-005

#### Why Watch

Not Watch — Rejected shell.

#### Later measure

If the parent imported the child transcript, or the child can
`start_turn` on the parent, or the child has no own constitution /
tool set / model id, record **drop**.

#### Keep / drop

Drop that design as a G-005 keep.

#### Score-harness extra

**G-005.** Specialists: scout / critic / planner. Arms: none /
parent-model / smaller-or-local. Local may lose. A nested prompt
is a drop.

#### Requirements and Constraints

- Scout cannot write or see keys.
- V-003 org-chart second brain is also a drop.

#### Rationale

Blueprint §5 keep/drop for test 5. Charter §15 attack 8. Charter
anti-pattern “Nested prompt as G-005.”

#### Evidence

EVD-200, EVD-201, EVD-202.

#### Evidence Spikes

None in this repo. Later measure: the isolation checks in §7.

#### Tradeoffs

A nested prompt is cheaper to demo. It does not test the leftover.

#### Failure Modes

“We spawned a Task and prepended ‘you are a critic’.”

#### Alternatives Considered

- Allow nested prompt as the none-arm control — unnecessary; the
  none arm is already “no helper.”

#### Downstream Implications

Synthesis must not define G-005 as a planner persona.

#### Revisit Triggers

Owner amends G-005.

---

### REC-207 — Reject the searcher as product identity

- **Classification:** Rejected
- **Applies to:** Later product gate; `arvo/` landing
- **Confidence:** High (lock)
- **Decision urgency:** Required now
- **Evidence quality:** Strong as lock
- **Related decisions:** None

#### Recommendation

Do not ship the G-004 searcher as what Arvo is. Reject
searcher-as-product-identity.

#### Claim

Copying a winning file is a product gate. Copying the loop is
changing the product into the cousin.

#### Host primitive

G-004

#### Why Watch

Not Watch — Rejected landing.

#### Later measure

A PR into `arvo/` whose subject is the searcher / keep-reset loop
is a drop at the product gate. A PR that copies a constitution
file after a G-004 keep may still be discussed later.

#### Keep / drop

Drop searcher-as-Arvo.

#### Score-harness extra

**G-004.** Fixed-set lab loop. Not “improves while you use it.”

#### Requirements and Constraints

- Twin of `REC-204`.
- Phase-2 lab is the sibling repo, not `arvo/`.

#### Rationale

Blueprint §11 score-harness non-goals; §22 item 3.

#### Evidence

EVD-200, EVD-212.

#### Evidence Spikes

None in this repo. Later measure: the landing-PR subject check.

#### Tradeoffs

Same as `REC-204`.

#### Failure Modes

“Arvo now hill-climbs itself overnight” as a README headline.

#### Alternatives Considered

- Searcher as an optional lab profile inside `arvo/` — still
  rejected as identity; the loop stays next door.

#### Downstream Implications

Plan review must attack this landing.

#### Revisit Triggers

Owner amends §22.

---

### REC-208 — Name a proposer slot above G-004; leftovers stay Watch

- **Classification:** Watchlist
- **Applies to:** Watch shelf above G-004; dispositions `REC-111`
  and `OQ-011`
- **Confidence:** Medium (slot is named); Low (a proposer would help)
- **Decision urgency:** May defer
- **Evidence quality:** Moderate for the papers and Harbor’s
  optimizer-vs-eval split; Weak for BEAM
- **Related decisions:** None

#### Recommendation

**Yes — this report names a proposer slot above G-004.** The slot
is optional. It stays Watch. It is not G-004. It is not G-006. It
is not “improves while you use it.” GEPA / ACE / Meta-Harness stay
Watch as possible later bodies of that slot (`REC-111`). Do not
design an online improver.

#### Claim

Organism ≠ searcher ≠ judge. After a recorded G-004 trial, an
optional proposer may *suggest* a mutation of the writable named
files. It may not touch the judge, the holdout, or `program.md`.

#### Host primitive

none

#### Why Watch

Host is none. The leftover is real (GEPA reflects on trajectories;
ACE curates a playbook and warns about collapse). AHE sting: the
system-prompt lever was weak. Harbor lists GEPA as an *optimizer*
integration, not as the verifier.[^harbor-docs] That is a slot
above a judge, not a keep.

#### Later measure

Only after G-004’s own recipe exists: frozen model, separate
verifier, holdout, one primary. Compare keep/reset-only vs
keep/reset + proposer suggestions on the same fixed set. Do not
run it here. Do not invent a Harbor number.

#### Keep / drop

Stay Watch. A later keep would be “proposer helped G-004’s holdout
without eating the judge.” Until that measure, GEPA/ACE remain
Watch.

#### Why this is not a sixth headline

A proposer is not a José primitive and not a scoring method. Promoting
it is G-006 and collapses the cousin into a card-as-test
(`RSK-023`).

#### Requirements and Constraints

- Do not merge into G-004 (`REC-205`).
- ACE collapse warning remains a leftover for overflow
  (leftovers `REC-102`); the ACE *loop* stays Watch.
- `program.md` is still slower than this slot (`REC-210`).

#### Rationale

`OQ-011` asked. Leftovers `REC-111` required this track to answer
without designing the test. Naming the slot prevents silent loss.
Leaving it Watch prevents a sixth test.

#### Evidence

EVD-207, EVD-208, EVD-209, EVD-210, EVD-200.

#### Evidence Spikes

None in this repo. Later measure: keep/reset vs keep/reset +
proposer, same frozen set.

#### Tradeoffs

Naming a slot looks like a sixth test if you squint. Not naming it
loses `REC-111`.

#### Failure Modes

“GEPA on BEAM” as G-006. Online ACE playbook sold as G-004.
Harbor’s GEPA integration treated as a result we ran.

#### Alternatives Considered

- Answer `OQ-011` “no slot” — rejected; the leftover is real and
  Harbor already splits optimizer from verifier.
- Required card that designs GEPA — rejected; that is an online
  improver / sixth test.

#### Downstream Implications

`OQ-011` is dispositioned: **yes, a slot is named; it stays
Watch.** Synthesis must not promote `REC-111`.

#### Revisit Triggers

A phase-2 measure on the slot; owner amends G-004 (material).

---

### REC-209 — A later judge may watch layers; they stay Watch, not G-006

- **Classification:** Watchlist
- **Applies to:** Watch shelf beside scoring; dispositions `REC-112`
- **Confidence:** Medium
- **Decision urgency:** May defer
- **Evidence quality:** Moderate as leftover; Weak as a number we
  have
- **Related decisions:** None

#### Recommendation

A later judge may *watch* honesty, stub/reuse, isolation, and
kill-Focus-lives beside the one declared primary. Those watches
stay Watch. They are not G-006. They cannot keep unless that layer
*was* the declared primary (`REC-202`). Do not invent a Harbor
number. Do not define density (`OQ-007`) as a score here.

#### Claim

The leftover is *what* to look at on a trace. The host is the later
judge, not a new headline.

#### Host primitive

none

#### Why Watch

Score-harness owns the methods. A scoreboard is not a José
primitive. Leftovers `REC-112` already parked this.

#### Later measure

Log the watches on every G-004 / G-005 trial. Keep/drop still uses
the pre-declared primary (G-004) or the pre-declared arm score
(G-005). Isolation and kill-Focus-lives remain leftover tests of
G-002 / G-001, not a new test. Do not run it here.

#### Keep / drop

Stay Watch as layers. Do not keep a layer because a paper liked it.
If honesty was the G-004 primary, use `REC-202`’s keep/drop, not
this card.

#### Why this is not a sixth headline

A watch is a column. A test is a claim.

#### Requirements and Constraints

- No invented Harbor number.
- Missing `evals/arvo-attention-reread/` (`EVD-214`) is not a
  scoreboard we already ran.
- Force-verify / onboard-the-env stay leftover policies, not
  architecture.

#### Rationale

`REC-112` required this track to name what a judge may watch
without promoting layers. Audit source text already names several
of the columns.[^arvo-audit] Naming is not measuring.

#### Evidence

EVD-210, EVD-214, EVD-216, EVD-200.

#### Evidence Spikes

None in this repo. Later measure: log the watches; do not keep on
them unless declared.

#### Tradeoffs

Layers are attractive and will try to become headlines.

#### Failure Modes

G-006 “honesty suite.” Judge eaten so the watches look good.
Citing `stub_reuse` from `audit.ex` as if this lab scored a keep.

#### Alternatives Considered

- Make honesty a required second primary — rejected; one primary.
- Rejected shelf — rejected; silent loss of `REC-112`.

#### Downstream Implications

Synthesis must not mint G-006 from these watches.

#### Revisit Triggers

Owner adds a legal primary; `evals/` suite returns in-tree (still
not a function proof).

---

### REC-210 — Searcher-meta stays Watch; `program.md` on a slower clock

- **Classification:** Watchlist
- **Applies to:** Watch shelf above the proposer; Bilevel /
  AutoHarness / Hermes
- **Confidence:** Medium (placement); Low (those kits would help)
- **Decision urgency:** May defer
- **Evidence quality:** Weak as adaptation; Moderate as “do not
  silently lose the shelf”
- **Related decisions:** None

#### Recommendation

Leave Bilevel / AutoHarness / Hermes-style “mutate the searcher”
on Watch. Human owns `program.md`. It moves slower than the G-004
writable set and slower than the optional proposer slot.

#### Claim

G-004 mutates the organism. A meta-searcher mutates the searcher.
Those are different clocks. Collapsing them eats the judge’s
owner.

#### Host primitive

none

#### Why Watch

SORT already parked this cluster. Raiding it would look busy
(Charter §10). No BEAM-shaped keep is named.

#### Later measure

None until G-004’s tiny loop has a holdout result. Then, if ever:
change `program.md` on a slower tag, freeze it for the inner loop,
and score the inner holdout. Do not run it here.

#### Keep / drop

Stay Watch. A later keep would require the inner G-004 holdout to
rise after a *human-approved* `program.md` change.

#### Why this is not a sixth headline

Meta-search is not a José primitive and not G-004.

#### Requirements and Constraints

- Do not let the organism edit `program.md` (`REC-201`).
- Do not raid other leftover Watch cards.

#### Rationale

SORT Watch row “Bilevel / AutoHarness / Hermes meta.” Prompted
here only so it is not silently lost.

#### Evidence

EVD-202, EVD-200, EVD-210.

#### Evidence Spikes

None in this repo. Later measure: slower-clock `program.md` tag.

#### Tradeoffs

Holding the meta shelf feels incomplete. Completeness is not the
bar.

#### Failure Modes

Thompson-sampling the searcher while the judge is shared-mode.
`program.md` rewritten every trial.

#### Alternatives Considered

- Rejected shelf — rejected; silent loss.
- Required inner-loop feature — rejected; sixth-test smell.

#### Downstream Implications

Synthesis leaves this Watch. Phase-2 does not start here.

#### Revisit Triggers

A human promotes the cluster; G-004 holdout exists and is boring
enough to ask why.

## 10. Evidence Ledger

| ID | Claim | Classification | Source or spike | Tier | Date | Access | Confidence | Limitations | Contradictory evidence | Downstream | Revalidation trigger |
| -- | ----- | -------------- | --------------- | ---- | ---- | ------ | ---------- | ----------- | ---------------------- | ---------- | -------------------- |
| EVD-200 | Five tests, G-004 fixed-set, G-005 specialists, no spikes, searcher ≠ Arvo identity are accepted user decisions | User decision | [Blueprint](../00-program-blueprint.md) §5, §6, §7.15–16, §11 score-harness, §22; [Charter](../01-research-charter.md) §1, §9–§11, §18 | 1 (lock) | 2026-08-14 / 15 | 2026-08-15 | High | Not evidence the tests pass | None | REC-200–210 | Amendment of Blueprint §7 |
| EVD-201 | Blueprint §5 rows 4–5 state measure, keep/drop, and “loop does not land in `arvo/`” | Verified fact about document | [Blueprint](../00-program-blueprint.md) §5 | 1 (lock) | 2026-08-14 | 2026-08-15 | High as *wording* | Not a passing run | None | REC-200, REC-203, REC-204 | Amendment of §5 |
| EVD-202 | SORT G-004 / G-005 claim, writable set, three arms, nested-prompt drop match the Blueprint table | Verified fact about document | [SORT.md](../working/SORT.md) Graduate G-004, G-005 | 4 (framing) | 2026-08-14 | 2026-08-15 | High as *wording* | Not governing after Blueprint | None | REC-200–206, REC-210 | Re-sort (forbidden unless amended) |
| EVD-203 | Charter score-harness bar: split, judge read-only, frozen model, one primary, three arms, local may lose, nested prompt ≠ child | User decision | [Charter](../01-research-charter.md) §9 extra, §10 bar | 1 (lock) | 2026-08-15 | 2026-08-15 | High | Not a measurement | None | REC-200–206 | Charter amendment |
| EVD-204 | Harbor task = instruction + environment + tests; `tests/test.sh` must write `reward.txt` or `reward.json`; `harbor run -p` / `-d` / `-m` / `-a` | Official claim / verified fact about document | [Task Structure](https://www.harborframework.com/docs/tasks); [Evals](https://www.harborframework.com/docs/run-jobs/run-evals) | 1 | page as of 2026-08-15 | 2026-08-15 | High as *wording* | Not a run we performed; flags can move | None | REC-200, REC-201, REC-202 | Harbor docs change |
| EVD-205 | Default verifier is **shared** with the agent container; separate mode exists for graders the agent must not see; sidecar anti-cheat named | Official claim | [Task Structure](https://www.harborframework.com/docs/tasks) verifier environment | 1 | page as of 2026-08-15 | 2026-08-15 | High as *wording* | We did not run either mode | Shared default vs our required fence | REC-201, RSK-020 | Harbor default flip |
| EVD-206 | Regrade holds the agent phase fixed and recomputes only the verifier on recorded artifacts; source trials are not modified; separate mode is recommended and “will soon become the default” | Official claim | [Regrade](https://www.harborframework.com/docs/run-jobs/regrade) | 1 | page as of 2026-08-15 | 2026-08-15 | High as *wording* | Not a regrade we ran; multi-step unsupported; “soon” is vendor trajectory | Mid-search grader edits vs after-the-fact regrade | REC-201 | Regrade semantics change |
| EVD-207 | Harbor describes itself as evaluating *and optimizing* agents; lists GEPA as an optimizer integration | Official claim | [Motivation](https://www.harborframework.com/docs) | 1 | page as of 2026-08-15 | 2026-08-15 | High as *wording* | Optimizer ≠ result we ran; must not merge the cousin | GEPA-as-G-004 temptation | REC-208, REC-205 | Landing-page rewrite |
| EVD-208 | GEPA samples trajectories, reflects in natural language, proposes prompt updates, keeps a Pareto front | Official claim (paper abstract) | [arXiv:2507.19457](https://arxiv.org/abs/2507.19457) v2 abs | 2 | v2 2026-02-14 (submitted 2025-07-25) | 2026-08-15 | High as *wording* | Their GRPO comparison is *their* result | AHE sting: prompt lever weak (SORT) | REC-208, REC-111 | New GEPA version |
| EVD-209 | ACE treats contexts as evolving playbooks (generate / reflect / curate) and names brevity bias and context collapse; offline *and* online adaptation | Official claim (paper abstract) | [arXiv:2510.04618](https://arxiv.org/abs/2510.04618) v3 abs | 2 | v3 2026-03-29 (submitted 2025-10-06) | 2026-08-15 | High as *wording* | “Self-improving” must not merge with G-004 | Online ACE vs fixed-set G-004 | REC-205, REC-208 | New ACE version |
| EVD-210 | Leftovers left GEPA/ACE Watch above G-004 (`REC-111`), traces Watch beside scoring (`REC-112`), and asked `OQ-011` | Architectural judgment accepted with leftovers | [leftovers report](11-leftovers-research-report.md) `9698362` | 1 (accepted report) | 2026-08-15 | 2026-08-15 | High as *inheritance* | Leftover ≠ proven adaptation | None | REC-208, REC-209, OQ-011 | Leftovers amendment |
| EVD-211 | Runtime named G-001…G-003 and Required drops REC-003, REC-005, REC-006, REC-010, REC-011 | Architectural judgment accepted with runtime | [runtime report](10-runtime-research-report.md) `636123f` | 1 (accepted report) | 2026-08-15 | 2026-08-15 | High as *inheritance* | Function unproven | None | REC-200, REC-203, §8.8 | Runtime amendment |
| EVD-212 | Two programs; catalog here; experiments later; adaptation not photocopy; Port-wrap is a shell | User decision / framing | [DISCOVERY-NOTES](../working/DISCOVERY-NOTES.md) locked top; Blueprint §7.2, §7.8–9 | 1 (lock) / 4 (notes) | 2026-08-14 | 2026-08-15 | High as *stance* | Not a measurement | None | REC-204, REC-207 | Amendment of two-program split |
| EVD-213 | `rel/RELEASE.md` tells Harbor sandboxes not to compile Elixir; ship a Mix release tarball; `arvo-chat` is the headless entry | Verified fact about source | [`rel/RELEASE.md`](../../../coding-agent-harness/arvo/rel/RELEASE.md) @ `84004e1` | 1 instrument text | 2026-07-29 commit; read 2026-08-15 | 2026-08-15 | High as *text* | Function unproven; not a Harbor run | None | REC-200, OQ-017 | File change |
| EVD-214 | `evals/` and `evals/arvo-attention-reread/` are **absent** at this HEAD | Verified fact about this checkout | `find` / listing of `../coding-agent-harness/arvo` @ `84004e1` | 1 instrument text | 2026-08-15 | 2026-08-15 | High | Absence ≠ “never existed”; not a function proof | DISCOVERY-NOTES still names that path | REC-209, RSK-029 | Tree grows an `evals/` dir |
| EVD-215 | Headless path: `ARVO_HEADLESS` / `ARVO_MODE=chat\|headless` skips Focus and auto-resume; comments name Harbor / `arvo-chat` | Verified fact about source | [`application.ex`](../../../coding-agent-harness/arvo/lib/arvo/application.ex) @ `84004e1` | 1 instrument text | 2026-08-15 | 2026-08-15 | High as *text* | Function unproven | Runtime REC-003: auto-resume is not G-001 | REC-200, OQ-017 | File change |
| EVD-216 | `Session.Audit.decision_report/2` names `task_ok`, `honesty`, `waste_ratio`, `stub_reuse`, `stranding_candidate` | Verified fact about source | [`audit.ex`](../../../coding-agent-harness/arvo/lib/arvo/session/audit.ex) @ `84004e1` | 1 instrument text | 2026-08-15 | 2026-08-15 | High as *text* | Function unproven; not a Harbor number | Missing `evals/` suite | REC-209 | File change |
| EVD-217 | A Harbor job writes `result.json` and per-trial `verifier/reward.txt` (plus stdout/stderr); `harbor view jobs` inspects | Official claim | [Evals](https://www.harborframework.com/docs/run-jobs/run-evals) | 1 | page as of 2026-08-15 | 2026-08-15 | High as *wording* | Not a job we ran | None | REC-200, REC-202 | Job layout change |
| EVD-218 | Harbor agents are external (`BaseAgent`) or installed (`BaseInstalledAgent` headless in the container); `harbor run -m` selects a model | Official claim | [Agents](https://www.harborframework.com/docs/agents) | 1 | page as of 2026-08-15 | 2026-08-15 | High as *wording* | Not an adapter we wrote | Installed vs external (OQ-017) | REC-200, OQ-017 | Agent API change |
| EVD-219 | Runtime assumed Harbor attention honesty as the honesty scoreboard for G-001/G-002 and left scorer design to this track | Architectural judgment (upstream) | Runtime report §15 assumption 4; H-167 | 4 (framing) / accepted report | 2026-08-15 | 2026-08-15 | Medium | The named suite path is absent (`EVD-214`) | Missing `evals/` | REC-202, REC-209 | Honesty scoreboard rebuilt |

**Method paper ≠ run result. Tree-description ≠ function. Leftover ≠
proven adaptation.** No ledger row is a Harbor number this lab
produced. This session did not boot Arvo and did not run Harbor.

## 11. Recommendation ledger

| ID | Title | Host | Classification | Confidence | Later measure |
| -- | ----- | ---- | -------------- | ---------- | ------------- |
| REC-200 | G-004 fixed-set keep/reset | G-004 | Required | High lock / Low–Medium pass | `results.tsv` + holdout + leftover tests hold |
| REC-201 | Judge / holdout / `program.md` fence | G-004 | Required | High | Judge-tree diff; separate verifier |
| REC-202 | Frozen model + one primary before the run | G-004 | Required | High | Run tag frozen before trial 1 |
| REC-203 | G-005 own Session + three arms | G-005 | Required | High lock / Low–Medium pass | Three-arm sweep; local may lose |
| REC-204 | Loop is not Arvo’s identity | G-004 | Required | High | Loop lives in the sibling repo |
| REC-205 | Reject cousin merge | G-004 | Rejected | High | Drifting / online design → drop as G-004 |
| REC-206 | Reject nested-prompt child | G-005 | Rejected | High | Transcript import / shared turn → drop |
| REC-207 | Reject searcher-as-product | G-004 | Rejected | High | Searcher PR into `arvo/` → drop |
| REC-208 | Proposer slot above G-004; stay Watch | none | Watchlist | Medium / Low | Only after G-004 exists; still Watch |
| REC-209 | Layer watches; stay Watch; not G-006 | none | Watchlist | Medium | Log watches; cannot keep unless declared |
| REC-210 | Searcher-meta Watch; `program.md` slower | none | Watchlist | Medium / Low | None until inner holdout exists |

Inherited, not reminted: `REC-001`…`REC-011`, `REC-100`…`REC-115`.
Dispositioned, not reminted: `REC-111`, `REC-112`, `OQ-011`.

## 12. Risks

### RSK-019 — G-004 collapses into “improves while you use it”

- **Description:** The fixed-set loop is rewritten as online
  self-improvement.
- **Likelihood:** High
- **Impact:** High
- **Mitigation:** REC-205, REC-200; Charter §15 attack 1
- **Owner:** score-harness; later reviews
- **Trigger:** A spec sentence that drops “fixed test set”

### RSK-020 — Judge eaten

- **Description:** The organism edits `tests/`, `task.toml`
  `[verifier]`, the holdout, or `program.md`. Shared-mode Harbor
  makes this the default.
- **Likelihood:** High if shared mode is used; Medium otherwise
- **Impact:** High
- **Mitigation:** REC-201; separate verifier; judge-tree diff
- **Owner:** phase-2 G-004
- **Trigger:** Shared-mode task, or a keep after a grader edit

### RSK-021 — Nested prompt sold as G-005

- **Description:** A persona plus a pid is recorded as a child
  Session.
- **Likelihood:** High
- **Impact:** High
- **Mitigation:** REC-206, REC-203
- **Owner:** phase-2 G-005
- **Trigger:** Parent prompt contains the specialist; no child
  constitution

### RSK-022 — Layer scores become G-006

- **Description:** Honesty / isolation / stub suite is promoted to
  a sixth headline.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** REC-209; five tests stay five
- **Owner:** synthesis / reviews
- **Trigger:** A `G-006` or “honesty suite” REQ

### RSK-023 — GEPA / ACE become an online improver

- **Description:** The named proposer slot is implemented as live
  memory rewrite and sold as G-004.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** REC-208 stays Watch; REC-205; REC-111 unchanged
- **Owner:** synthesis; phase-2
- **Trigger:** “ACE online playbook” in a G-004 design

### RSK-024 — Running the loop in this repo

- **Description:** A later session runs Harbor or boots Arvo here
  and writes a number into the catalog.
- **Likelihood:** Low
- **Impact:** High
- **Mitigation:** Charter §3 / §7; this report mints no `SPK`
- **Owner:** human + later stages
- **Trigger:** `harbor run` or `bin/arvo` in this tree

### RSK-025 — Searcher lands as Arvo’s identity

- **Description:** The keep/reset loop is copied into `arvo/` as
  the product.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** REC-204, REC-207; Blueprint §22
- **Owner:** later product gate
- **Trigger:** `searcher/` under `arvo/`

### RSK-026 — Parent required to run locally

- **Description:** G-005 is skipped or warped because the parent
  model is not local.
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** REC-203; local is a helper option only
- **Owner:** phase-2 G-005
- **Trigger:** Design that forbids a remote parent

### RSK-027 — Invented Harbor number treated as a result

- **Description:** A paper number, a missing suite path, or a
  made-up `task_ok` is written as if this lab ran it.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Ledger class rules; REC-209; EVD-214
- **Owner:** this report; reviews
- **Trigger:** A keep that cites a number with no phase-2 job dir

### RSK-028 — Installed-agent image still contains Mix / keys

- **Description:** Harbor installed-agent packaging (`RELEASE.md`)
  is treated as isolation. Keys still sit where tools run.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Inherit REC-004 / REC-008; G-002 leftover tests
  still apply
- **Owner:** phase-2
- **Trigger:** First Harbor adapter ships tools in-process

### RSK-029 — Missing `evals/` path treated as a live scoreboard

- **Description:** DISCOVERY-NOTES still names
  `evals/arvo-attention-reread/`. The directory is gone at
  `84004e1`. Someone scores as if it ran.
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** EVD-214; REC-209
- **Owner:** phase-2 honesty scoreboard
- **Trigger:** A citation of that path as a result

Inherited, not reminted: `RSK-001`…`RSK-018`.

## 13. Weak evidence

- Every “holdout would rise” sentence. No run. Medium or Low.
- GEPA’s few-rollouts / large-gain claim and ACE’s leaderboard
  numbers — *their* results. Not ours. Not a G-004 keep.
- AHE sting (evolving the system prompt was a weak lever) is a
  SORT framing note, not a measurement we repeated.
- Arvo audit column names (`honesty`, `stub_reuse`) are source
  text. They do not score a session.
- Harbor “will soon become the default” for separate verifier is
  vendor trajectory, not a guarantee.
- DISCOVERY-NOTES Harbor-suite path is stale relative to this
  HEAD.
- Runtime assumption that Harbor attention honesty *is* the
  scoreboard (EVD-219) is now weaker: the suite directory is
  missing.
- `OQ-016` parent-waste definition is not operationalized.
- Popularity of Harbor, GEPA, or ACE is unused and is not
  evidence.

## 14. Conflicting evidence

| Tension | Disposition |
| ------- | ----------- |
| Harbor landing page: evaluate *and optimize* (GEPA) vs G-004 fixed-set | Optimizer is the Watch slot above the judge (`REC-208`), not G-004 (`REC-205`) |
| ACE “self-improving” / online memory vs G-004 | Collapse warning inherited; loop stays Watch; cousin rejected |
| GEPA paper gains vs AHE “prompt was the weak lever” | Stay Watch; paper number cannot keep a proposer |
| Harbor default **shared** verifier vs Karpathy fence | Required separate mode (`REC-201`); shared is a known hole (`RSK-020`) |
| DISCOVERY-NOTES `evals/arvo-attention-reread/` vs absent directory | Checkout wins (`EVD-214`). Notes are framing, not a suite |
| Harbor `reward.json` multi-metric vs one primary | Extra fields are watches (`REC-202`, `REC-209`) |
| Installed-agent headless path vs G-002 hands somewhere else | Packaging ≠ isolation (`RSK-028`); inherit REC-004 |
| Regrade (change the grader) vs judge fence | After-the-fact regrade is lab hygiene; mid-search grader edit is eating the judge |

## 15. Assumptions

1. Harbor (or an equivalent task + verifier + reward file) remains
   the later format. Flags dated 2026-08-15 may move.
2. The legal G-004 primaries stay “Harbor task success *or*
   attention honesty” until a human amends them.
3. Attention honesty, if used, can later be computed from audit
   JSONL even though `evals/arvo-attention-reread/` is absent now.
4. Runtime hosts `REC-001`…`REC-011` remain the things a loop may
   score. This report does not redesign them.
5. Leftovers `REC-111` / `REC-112` remain Watch until a human
   promotes them. Naming a slot is not promotion.
6. Phase-2 still starts with an Arvo smoke check *there*.
7. `OQ-007` density is not required for an honest G-004 primary.
8. The operator still does not use Arvo as a daily driver.

## 16. Open questions

### OQ-011 — Does score-harness name a proposer slot above G-004?

- **Blocking?** No for the catalog (now answered)
- **Owner:** score-harness (this report)
- **Resolution path:** **Yes.** `REC-208` names an optional Watch
  slot above G-004. `REC-111` stays Watch. Not reminted.
- **Deadline:** This report’s acceptance (disposition is in this
  file either way)

### OQ-013 — Which Harbor reward field is the G-004 primary when both `reward.txt` and `reward.json` exist?

- **Blocking?** No
- **Owner:** phase-2
- **Resolution path:** Declare on the run tag. Official docs read
  `reward.json` first and fall back to `reward.txt`.[^harbor-tasks]
  Do not invent a number here.
- **Deadline:** First G-004 run tag

### OQ-014 — Is the G-004 holdout a Harbor dataset split or a withheld local task slice?

- **Blocking?** No for the catalog; yes before a G-004 keep
- **Owner:** phase-2
- **Resolution path:** Either is legal if withheld *before* trial
  1 and the organism cannot see it
- **Deadline:** First G-004 keep

### OQ-015 — Which G-005 specialist should the first three-arm sweep use?

- **Blocking?** No
- **Owner:** phase-2 / later plan
- **Resolution path:** Scout is the narrowest tool set (no write,
  no keys). Not decided here.
- **Deadline:** First G-005 run

### OQ-016 — What is an operational definition of “parent waste”?

- **Blocking?** No for the catalog
- **Owner:** phase-2
- **Resolution path:** Pick one of tokens / turns / tool calls on
  the parent Session and freeze it on the run tag. Audit
  `waste_ratio` is checkout text, not the definition.
- **Deadline:** First G-005 run tag

### OQ-017 — Does the later repo attach Arvo as a Harbor installed agent (`arvo-chat` in the container) or as an external agent?

- **Blocking?** No for the catalog
- **Owner:** phase-2
- **Resolution path:** `RELEASE.md` describes installed / headless
  packaging. Isolation still follows G-002. Do not run it here.
- **Deadline:** First Harbor adapter

### OQ-018 — After `evals/arvo-attention-reread/` disappeared, what is the first honesty scoreboard?

- **Blocking?** No for the catalog
- **Owner:** phase-2
- **Resolution path:** Rebuild from audit JSONL, or pick Harbor
  `task_ok` as the first G-004 primary and watch honesty
- **Deadline:** First run that names honesty as primary

Inherited, not reminted: `OQ-001`…`OQ-010`, `OQ-012`. `OQ-007`
(density) stays leftovers-named; this report does not invent a
Harbor number for it.

## 17. Handoff Digest

- **Decisions supported:** Blueprint §5 tests 4–5, §7.15–16, §11
  score-harness row, §22 searcher ≠ identity; Charter score-harness
  extras and bar; accepted runtime hosts `REC-001`…`REC-011`;
  accepted leftovers `REC-111` / `REC-112`.
- **Recommendations accepted by the report:** REC-200…REC-204 as
  Required scoring rules; REC-205…REC-207 as Rejected shells;
  REC-208…REC-210 as Watchlist. `OQ-011` answered **yes, a Watch
  slot above G-004**.
- **Recommendations challenged:** None of runtime’s Required
  drops. Challenges: cousin merge, nested-prompt child,
  searcher-as-product, layer-score-as-G-006, GEPA/ACE-as-test,
  invented Harbor numbers, shared-mode judge.
- **Evidence strength:** Strong on locks and dated Harbor /
  abstract / source-text reads. Weak/Medium on every “would raise
  holdout” claim.
- **Weak and conflicting evidence:** §13–§14.
- **Assumptions:** §15.
- **Risks:** RSK-019…RSK-029. Inherited RSK-001…RSK-018 still
  apply to hosts and leftovers.
- **Open questions:** OQ-011 dispositioned. OQ-013…OQ-018 named.
  None block *catalog* honesty. Inherited OQ-001…OQ-010, OQ-012
  still apply.
- **Required downstream decisions:** Human accept + commit of this
  report before synthesis may treat it as accepted. Synthesis is a
  **separate** fresh session. Do not write it now. Phase-2 still
  starts with an Arvo smoke check *there*.
- **Relevant identifiers:** `REC-200`…`REC-210`; inherited
  `REC-001`…`REC-011`, `REC-100`…`REC-115`; `RSK-019`…`RSK-029`;
  `OQ-011` (dispositioned), `OQ-013`…`OQ-018`; `EVD-200`…`EVD-219`;
  intake G-004, G-005.
- **Full-report sections that must be read before deciding:** §2
  (split table), §8 (cousin, fence, arms, proposer), §9 (every
  `REC`), §10 (method paper ≠ run), §14 (conflicts).

A Handoff Digest must not replace this file.

## 18. Source ledger

| Source | URL or path | Accessed | Tier |
| ------ | ----------- | -------- | ---- |
| Program Blueprint | [`docs/00-program-blueprint.md`](../00-program-blueprint.md) | 2026-08-15 | lock |
| Research Charter | [`docs/01-research-charter.md`](../01-research-charter.md) | 2026-08-15 | lock |
| Accepted runtime report | [`docs/reports/10-runtime-research-report.md`](10-runtime-research-report.md) | 2026-08-15 | accepted report |
| Accepted leftovers report | [`docs/reports/11-leftovers-research-report.md`](11-leftovers-research-report.md) | 2026-08-15 | accepted report |
| SORT Graduate G-004 / G-005 | [`docs/working/SORT.md`](../working/SORT.md) | 2026-08-15 | framing |
| DISCOVERY-NOTES (locked top + already-cited Harbor-path claims) | [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md) | 2026-08-15 | framing |
| Harbor Motivation | https://www.harborframework.com/docs | 2026-08-15 | 1 |
| Harbor Core Concepts | https://www.harborframework.com/docs/core-concepts | 2026-08-15 | 1 |
| Harbor Task Structure | https://www.harborframework.com/docs/tasks | 2026-08-15 | 1 |
| Harbor Evals | https://www.harborframework.com/docs/run-jobs/run-evals | 2026-08-15 | 1 |
| Harbor Regrade | https://www.harborframework.com/docs/run-jobs/regrade | 2026-08-15 | 1 |
| Harbor Agents | https://www.harborframework.com/docs/agents | 2026-08-15 | 1 |
| GEPA abs | https://arxiv.org/abs/2507.19457 | 2026-08-15 | 2 |
| ACE abs | https://arxiv.org/abs/2510.04618 | 2026-08-15 | 2 |
| Arvo checkout | `../coding-agent-harness/arvo` @ `84004e1fcae11bbf72656c58e7fa5ae4aa92838b` | 2026-08-15 | 1 instrument text |
| Evidence model / REC template / spike contract | `program/contracts/*`, `program/templates/recommendation.md` | 2026-08-15 | methodology |
| Exa REST (retrieval only) | `POST https://api.exa.ai/search` | 2026-08-15 | not a cited tier |

Do not cite chat, root HANDOFF, or attachment manifests as evidence.

## 19. Completion checklist

- [x] Report exists at `docs/reports/12-score-harness-research-report.md`
- [x] All report-contract headings present and filled
- [x] Five tests still five; no G-006; leftover cards are not tests
- [x] G-004 and G-005 stay split; cousin not merged
- [x] Scorer / judge tree read-only; model frozen; one primary before
      the run
- [x] G-005 has three arms; local may lose; nested prompt is a drop
- [x] Each scoring-method `REC` tags G-004 or G-005, not both, plus
      claim, later measure, keep/drop
- [x] `OQ-011` / `REC-111` / `REC-112` dispositioned; GEPA/ACE still
      Watch above G-004
- [x] Evidence Ledger: method paper ≠ run; leftover ≠ proven adaptation
- [x] No `SPK-###`; no Harbor run; no Arvo command run as a test
- [x] Exa used via REST only as allowed, or failure documented
- [x] Intake not reopened
- [x] Shared IDs start at `RSK-019` / `OQ-013`; `REC-200`…`REC-299` only
- [x] Plain-language summary shown to Robert *(in the session message, not this file)*
- [x] Human accepts report
- [x] Manifest updated; accepting commit recorded

[^harbor-docs]: Harbor, *Motivation*, https://www.harborframework.com/docs — accessed 2026-08-15.
[^harbor-tasks]: Harbor, *Task Structure*, https://www.harborframework.com/docs/tasks — accessed 2026-08-15.
[^harbor-evals]: Harbor, *Evals*, https://www.harborframework.com/docs/run-jobs/run-evals — accessed 2026-08-15.
[^harbor-regrade]: Harbor, *Regrade*, https://www.harborframework.com/docs/run-jobs/regrade — accessed 2026-08-15.
[^harbor-agents]: Harbor, *Agents*, https://www.harborframework.com/docs/agents — accessed 2026-08-15.
[^harbor-concepts]: Harbor, *Core Concepts*, https://www.harborframework.com/docs/core-concepts — accessed 2026-08-15.
[^gepa]: Agrawal et al., *GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning*, arXiv:2507.19457v2, https://arxiv.org/abs/2507.19457 — accessed 2026-08-15.
[^ace]: Zhang et al., *Agentic Context Engineering*, arXiv:2510.04618v3, https://arxiv.org/abs/2510.04618 — accessed 2026-08-15.
[^arvo-release]: `../coding-agent-harness/arvo/rel/RELEASE.md` at `84004e1`, 2026-08-15.
[^arvo-app]: `../coding-agent-harness/arvo/lib/arvo/application.ex` at `84004e1`, 2026-08-15.
[^arvo-audit]: `../coding-agent-harness/arvo/lib/arvo/session/audit.ex` `decision_report/2` at `84004e1`, 2026-08-15.
