# Program Blueprint — arvo-beam-harness-research

- **Artifact type:** Program Blueprint
- **Program:** arvo-beam-harness-research
- **Status:** Accepted by human — awaiting accepting commit
- **Version:** 1.0
- **Created:** 2026-08-14
- **Last updated:** 2026-08-14
- **Rigor tier:** focused (approved with this Blueprint)

> This file is the governing plan for *this* repository. It does not conduct
> the focused research. Robert accepted this draft on 2026-08-14. The
> discovery stage is not `accepted` in `research-program.toml` until the
> accepting commit is recorded.
>
> Framing sources (not higher than this file once accepted):
> [`docs/working/SORT.md`](working/SORT.md),
> [`docs/working/DISCOVERY-NOTES.md`](working/DISCOVERY-NOTES.md).
> Contract: [`program/contracts/program-blueprint.md`](../program/contracts/program-blueprint.md).

## 1. Artifact Metadata

| Field      | Value                                                          |
| ---------- | -------------------------------------------------------------- |
| Program ID | arvo-beam-harness-research                                     |
| Owner      | Robert Guss                                                    |
| Repository | [robertguss/arvo-beam-harness-research](https://github.com/robertguss/arvo-beam-harness-research) |
| Local tree | this checkout                                                  |
| Instrument | local Arvo checkout at `../coding-agent-harness/arvo`          |
| Sister tree| `../coding-agent-harness/ore` — ignore unless the owner says so |

## 2. Product or Project Vision

This program is a **personal lab**, not a race and not a startup pitch.

Most new work on coding-agent harnesses is written in TypeScript and Python.
Those papers and products keep specifying the same nouns the BEAM already has
(processes, mailboxes, supervisors, reloadable code, sandboxes, attachable
clients) and then **build a fake operating system** to host the leftover idea
(the policy, the metric, the loop).

José Valim’s bet is that **the runtime is the framework**:

1. Swap plugins without dropping agent state.
2. The window is a client of a living agent, not the agent.
3. Brains (model + session + secrets) and hands (tools + sandbox) sit in
   different places, the way Livebook already splits notebook from runtime.

This repository’s job is to **see and name** those reinvented pieces, keep the
*new* leftover, and write a catalog another repo can try on a real BEAM. It
does not implement the experiments.

Arvo (the Elixir harness in `../coding-agent-harness/arvo`) is the
**instrument in the tree**: a product-shaped codebase that already placed this
bet and today spends only a thin slice of OTP (one Session, tools in-process,
Mix-compile plugins, quit-window kills the VM, file-search native code on the
brain). That gap is the object of study. Arvo is **not** a daily driver, and
“in the code” is not “works.”

## 3. Problem Statement

There are two problems, and they must stay distinct.

**Problem A — the runtime gap.** Arvo’s tree does not yet use the runtime the
way the bet requires. Closing the window still looks like it should kill the
agent. Tools still sit where the keys are. Loading a plugin still looks like
compiling inside the live app. Until those three primitives are named as
tests, every paper leftover has nowhere honest to live.

**Problem B — leftover ideas without a host.** The intake dump (papers,
bookmarks, prior vault notes) is full of policies and loops (how to compact,
how to score a trajectory, how to grow a prompt, how to give a helper its own
job). Those ideas are not extra headline products. They are guests. They need
the primitives in Problem A, and they need a way to be kept or dropped later
without turning this repo into a coding backlog.

This program exists so a later sibling repository can run five already-named
tests without inventing the agenda, and so most other ideas can stay on a
Watch shelf instead of becoming features.

## 4. Intended Users and Stakeholders

| Who | Role |
| --- | ---- |
| Robert Guss | Owner and only operator of *this* program. Reads, accepts, commits. |
| Later experiment operator | Whoever stands up the sibling experiment repo (may be the same person). Consumes the catalog. Not a user of this repo’s “product.” |
| Session agents | Research / validation / review agents commissioned one stage at a time. |

Not users of this program:

- People running Arvo in production (there is no such deployment in scope).
- “Arvo users” as a market.
- José Valim, Elixir community, or paper authors as stakeholders to satisfy.

## 5. Goals

1. **Keep this repo a catalog.** Output of the program: named tests, pattern
   cards, ranked hypotheses, what we would measure, keep/drop rules. Not a
   working harness.
2. **Keep intake closed.** Do not dump more papers, bookmarks, or vault
   traces. The dump in [`docs/working/DISCOVERY-NOTES.md`](working/DISCOVERY-NOTES.md)
   and the sort in [`docs/working/SORT.md`](working/SORT.md) are enough.
3. **Name five headline tests** (SORT IDs `G-001`…`G-005`). Do not add a
   sixth. Do not drop one. Details live in the Graduate table of
   [`docs/working/SORT.md`](working/SORT.md).

| # | Plain name | SORT | What we would try later | Measure (later repo) | Keep / drop | Copy into `arvo/`? | Operator care |
| - | ---------- | ---- | ----------------------- | -------------------- | ----------- | ------------------ | ------------- |
| 1 | Close the window, agent stays | G-001 | Quit the TUI; the agent process is still there; a new window reconnects. Not “reload the chat file after a crash.” | Kill the window / SIGTERM the tile. Session pid lives. JSONL still grows. A new client attaches and continues. Honesty on the continued session, same frozen model, does not get worse. | Keep if attach is not just disk resume. Drop if we only wrapped auto-resume in boot scripts. | Likely yes later | Keep |
| 2 | Tools live somewhere else | G-002 | Hands cannot see API keys. Kill hands; chat lives. Same coding task still works. Thinnest setup that passes. | Same task; only the topology changes. Hands cannot read keys. Kill hands mid-tool; Session + JSONL live. No orphan `bash -c`. Hidden BEAM and a container are different threats — score them separately. | Keep the *thinnest* layer that passes isolation + survival + task. Drop a layer that only adds latency. Drop if “hands” is a Port wrapping a foreign harness. | Lab first | Cares most |
| 3 | Swap a plugin without restarting | G-003 | New plugin code; current turn finishes on old code; next turn sees new tools; no Mix compile inside the live app. | Session mailbox intact. In-flight turn stays on old modules. Next turn sees the new manifest. Name the prefix-cache break. | Keep if Mix leaves the product VM and the swap is real. Drop if this is `Code.append_path` plus hope, or if cache-break cost eats the win. | Likely yes later | Very interested |
| 4 | Overnight loop on a fixed test | G-004 | Same model. Edit only named harness files. Scorer is off-limits. Keep or undo. Leftover tests must also improve. | `results.tsv`: keep / discard / crash. One primary number per run (task success *or* honesty — pick before the run). Holdout required. Side stats (tokens, time) cannot keep. Tiny gain + ugly complexity = discard. | Keep the *loop* if holdout rises without touching the scorer, without “more tokens / more time” as the win, and without honesty collapse. Drop if it only games three tasks. | **No.** Loop stays in the experiment repo. A winning file may be copied later. | Huge as *method* |
| 5 | Specialized helpers | G-005 | Own session, not a nested prompt. Scout ≠ critic ≠ planner. Arms: no helper / parent-model helper / smaller-or-local helper. Local is allowed to lose. | Same tasks, three arms. Score task success, parent waste, dollars, wall time. Scout cannot write or see keys. | Keep a specialist if it wins success, waste, or cost without adding a second brain for org-chart reasons. Drop if the child is a nested prompt with a process id taped on. | Lab first | Keep + model test |

4. **Run three workstreams** after the Charter (research reports only — no
   code):

   | Workstream | Tests | Question |
   | ---------- | ----- | -------- |
   | Runtime | G-001, G-002, G-003 | What are the three primitives, and what would later prove we have them? |
   | Leftovers | none of the five as headlines | Which paper ideas sit on those primitives, and which stay on Watch? |
   | Score the harness | G-004, G-005 | How would the later repo keep or drop a change without fooling itself? |

5. **Leave most ideas on Watch.** That is success, not a backlog failure.
   Translate clusters in [`docs/working/SORT.md`](working/SORT.md) are
   hypotheses for the leftovers track, not extra headline tests.

6. **Hand a stranger the agenda.** After Charter + three reports + the
   template spine, Robert can open a new sibling repo and know what to try
   first without re-deriving the five tests.

## 6. Non-Goals

This repository will not:

- Write Elixir, spikes, evals, Harbor runs, or PRs into Arvo.
- Treat Arvo as a known-good daily tool, or treat “in the tree” as “works.”
- Use `arvo/` as the experiment lab. The lab is a later sibling repo (name
  TBD). Copying a *result* into `arvo/` is a later, separate gate.
- Re-open intake (more papers, bookmark JSON, unread X Articles, vault
  `trace.jsonl`, 339 paper stubs).
- Become LangChain-on-BEAM, Elixir-LangGraph, or a photocopy of a paper.
- Wrap a foreign harness in a Port and call that native.
- Train or fine-tune model weights.
- Touch `ore/` unless the owner says so.
- Merge G-004 (overnight loop on a **fixed** test set) with the bigger cousin
  “the harness gets better while you use it.”
- Add a sixth headline test or drop one of the five.
- Treat plan / todo / permission-popup chrome as product identity (the lab
  may still *study* a planner as a child session under G-005).
- Put MCP, Horde, Oban, libcluster, OTP relups, or Phoenix LiveView at the
  center of the architecture.
- Write a coding backlog. The template’s “implementation plan” here means
  ranked hypotheses + measure + keep/drop, not tickets.

## 7. Locked Constraints

Locked in framing on 2026-08-14
([`docs/working/SORT.md`](working/SORT.md) Graduate table and Framing section;
[`docs/working/DISCOVERY-NOTES.md`](working/DISCOVERY-NOTES.md) status table).
Do not re-litigate in later stages. Amend only through
[`program/reference/amendment-protocol.md`](../program/reference/amendment-protocol.md).

1. **Personal lab.** Not a race, not a pitch.
2. **Two programs.** This repo writes ideas and a catalog. A later sibling
   repo (name TBD) runs experiments. “Implementation plan” in *this* template
   means ranked hypotheses + what we would measure + keep/drop. It does not
   mean write Elixir here.
3. **No spikes, evals, or PRs into Arvo in this repo.**
4. **Arvo is not the operator’s daily driver.** He does not use it. He is not
   sure the features in the tree work. “Put it in `arvo/`” means “maybe copy
   into that unfinished tree later.”
5. **Local instrument path:** `../coding-agent-harness/arvo`. Ignore `ore/`
   unless the owner says so.
6. **The runtime is the framework:** (1) swap plugins without dropping state,
   (2) window is a client of a living agent, (3) brains vs hands like
   Livebook.
7. **Thin OTP slice is the gap:** one Session, tools in-process, Mix-compile
   plugins, quit window kills the VM, file-search native code on the brain.
8. **Central insight:** TypeScript/Python papers specify OTP, then fake an OS.
   Adaptation = stop simulating the runtime; use it. Circle nouns that are
   already Erlang; keep the *new* leftover (policy, metric, loop).
9. **Adaptation, not refusal, not photocopy.** Wrapping a foreign harness in a
   Port and calling it native is a shell.
10. **Intake is closed.**
11. **Success bar for this phase:** a catalog (five tests + pattern cards),
    not a working harness.
12. **Rigor: focused.** On the five tests, when later scored: same model,
    leftover test slice, scorer is read-only, one main score.
13. **Three workstreams** as in §5. They are not extra headline tests.
14. **Phase-2 repo:** new sibling when we run the first test. Not this repo.
    Not `arvo/` as the lab. Standing it up includes a **smoke check that Arvo
    boots and can finish a simple task**. That smoke check is not a stage in
    *this* repo.
15. **G-004 stays a lab loop on a fixed test set.** Do not merge it with
    “improves while you use it.”
16. **G-005 helpers are specialized** (scout / critic / planner). Test **same
    model as parent** vs **smaller/cheaper, ideally local**. Local is allowed
    to lose.

## 8. Success Criteria

This *program* (phase 1) succeeds when:

1. This Blueprint is accepted and the Research Charter exists and is accepted.
2. The five tests remain named, each with a later measure and a keep/drop
   rule (table in §5; detail in [`docs/working/SORT.md`](working/SORT.md)).
3. Three focused reports exist (runtime, leftovers, score-the-harness) and
   have been validated and accepted.
4. Most intake items remain on Watch. The leftovers report says so on purpose.
5. The revised specification and the “implementation plan” sequence
   *hypotheses*, not production PRs.
6. Robert can start a phase-2 sibling repo from this catalog without
   inventing the agenda. First job in that repo includes the Arvo smoke check.
7. This repo still contains no experiment code, no Harbor runs, and no PRs
   into Arvo.

This program does **not** succeed by shipping a harness.

## 9. Rigor Tier

- **Selected:** focused
- **Rationale:** One operator. Personal lab. Work is reversible (Git notes
  and a later experiment repo; nothing here mutates a tool anyone depends
  on). The technical substrate (OTP, Arvo’s tree, Harbor-style scoring) is
  familiar enough that we do not need a wide research graph. Intake is
  already huge; more tracks would be theater. The library’s “focused” shape
  (few tracks, moderate ledgers, spikes only for material uncertainty, one
  synthesis, one spec review, one plan review) matches.
- **Thin-standard overlay (later experiments only):** when a phase-2 run
  *scores* one of the five tests, freeze the model, hold out a slice, keep
  the scorer read-only, and declare one primary number before the run. That
  overlay does not raise *this* repo to standard, and it does not authorize
  spikes here.
- **Approval:** Approved with this Blueprint (Robert, 2026-08-14). Framing
  already chose focused ([`docs/working/SORT.md`](working/SORT.md) Framing).
  Manifest `accepted_commit` still empty until the human commits.

See [`program/reference/rigor-tiers.md`](../program/reference/rigor-tiers.md).

## 10. Research Graph

Template spine stays. Three focused tracks sit **after Charter, before
synthesis**. They do not run in the discovery session that writes this file.

| Stage ID | Name | Kind | Depends on | Output | Parallel group |
| -------- | ---- | ---- | ---------- | ------ | -------------- |
| discovery | Project Discovery | discovery | — | this file | — |
| charter | Research Charter | research-charter | discovery | `docs/01-research-charter.md` | — |
| runtime | Runtime primitives | independent | charter | `docs/reports/10-runtime-research-report.md` | A |
| leftovers | Paper leftovers | independent | charter | `docs/reports/11-leftovers-research-report.md` | A |
| score-harness | Score the harness | independent | charter | `docs/reports/12-score-harness-research-report.md` | A |
| synthesis | Definitive Specification Synthesis | chief-architect-synthesis | charter, runtime, leftovers, score-harness | `docs/specifications/01-definitive-specification.md` | — |
| spec-review | Specification Adversarial Review | adversarial-review | synthesis | `docs/reviews/01-specification-adversarial-review.md` | — |
| spec-revision | Revised Definitive Specification | artifact-revision | spec-review | `docs/specifications/02-definitive-specification-revised.md` | — |
| implementation-plan | Implementation Plan | implementation-plan | spec-revision | `docs/plans/01-implementation-plan.md` | — |
| plan-review | Implementation Plan Adversarial Review | adversarial-review | implementation-plan | `docs/reviews/02-implementation-plan-adversarial-review.md` | — |
| plan-revision | Final Revised Implementation Plan | artifact-revision | plan-review | `docs/plans/02-implementation-plan-revised.md` | — |

Prompt paths are just-in-time from `program/templates/`. Do not write the
three reports, the Charter, or the spine artifacts in the discovery session.

Corresponding `[[stages]]` entries live in `research-program.toml` as
`planned`. Nothing is accepted by writing this file.

## 11. Stage Descriptions and Dependencies

### Why these three tracks, and why they cannot absorb each other

| Track | Why it exists | Why another cannot absorb it | Decision it informs | Consumed by |
| ----- | ------------- | ---------------------------- | ------------------- | ----------- |
| runtime | José’s three sentences are the host. Without named primitives, leftovers have nowhere to sit and scoring has nothing honest to mutate. | Leftovers is “what idea rides on the host.” Score is “how we keep or drop a change.” Neither defines window-vs-brain, hands, or plugin swap. | What G-001…G-003 *are*, how we would know we have them, what “copy into `arvo/` later” would mean. | leftovers (as host nouns), score-harness (as things a loop may edit), synthesis |
| leftovers | The dump’s value is pattern cards, not five more headlines. | Runtime must not grow a sixth test by absorbing paper ideas. Score must not become a paper club. | Which Translate clusters become cards; which Watch items stay Watch; which Refuse items stay refused. | synthesis (catalog body) |
| score-harness | The later repo needs a method that cannot eat the judge. | Runtime is topology. Leftovers is insight. Neither is the keep/reset loop or the helper-arm design. | How G-004 and G-005 will be scored; how they stay unmerged from “improves while you use it.” | synthesis; later sibling repo |

### Omitted library tracks

From [`program/reference/research-stage-library.md`](../program/reference/research-stage-library.md).
One line each.

| Library track | Why skipped as its own stage |
| ------------- | ---------------------------- |
| Domain and problem | Framing is locked in §2–§3. No extra domain study. |
| User and workflow | One operator; no product UX research. Window-as-client is runtime, not a user study. |
| Ecosystem, tooling, dependency | Elixir/OTP/Arvo/Harbor are known enough. Volatility is not the risk. |
| Architecture and system design | Absorbed by runtime (host) and leftovers (guests). A fourth “architecture” track would duplicate. |
| Security and threat model | G-002 *is* the threat we care about (keys, kill-hands). Not a general security program. |
| Data and integration | No external system of record. JSONL + Git are enough to name. |
| Testing and verification | Absorbed by score-harness. No separate methods track. |
| Operations, deployment, reliability | Daemon/attach is G-001’s product shape, not an ops program. |
| AI-native repository and agent workflow | This template already is that workflow. |
| Performance and scalability | Cache-break and latency are named measures on G-003, not a scale program. |
| Migration and compatibility | No users or APIs to migrate. |
| Legal, regulatory, privacy, compliance | Personal lab; no regulated data program. |
| Financial, cost, feasibility | G-005 may count dollars as a score. No ROI track. |
| Market and competitive | Explicit non-goal. Personal lab, not positioning. |
| Scientific or empirical validation | Phase-2, not this repo. Score-harness only *designs* the later test. |
| Risk and failure-mode | Risks travel inside the three reports (`RSK-###`). No standalone risk stage. |

### discovery

| Field | Value |
| ----- | ----- |
| Kind | discovery (spine) |
| Primary question | What is this lab, what will it not do, and what graph does that imply? |
| Scope | Fill this Blueprint from agreed framing. |
| Non-goals | Charter, reports, code, more intake, accepting the stage. |
| Prerequisites | `just init` (done). Framing in SORT + DISCOVERY-NOTES. |
| Output | `docs/00-program-blueprint.md` |
| Identifiers | none allocated here |
| Spikes | none |
| Replication | not applicable |
| Parallel group | none |
| Downstream | charter |
| Completion | All 22 sections filled; human accepts; accepting commit recorded. **Not complete when this draft is written.** |

### charter

| Field | Value |
| ----- | ----- |
| Kind | research-charter (spine) |
| Primary question | What evidence and decision rules do later stages inherit? |
| Scope | Specialize [`program/contracts/research-charter.md`](../program/contracts/research-charter.md) for a catalog-only, focused lab. State that spikes live in phase-2, that “in the Arvo tree” is not evidence of function, and that popularity is not proof. |
| Non-goals | Re-opening framing; writing the three reports; changing the five tests. |
| Prerequisites | Accepted Blueprint. |
| Output | `docs/01-research-charter.md` |
| Identifiers | none |
| Spikes | none in this repo |
| Replication | off |
| Parallel group | none |
| Downstream | runtime, leftovers, score-harness, and (explicitly) synthesis |
| Completion | Contract sections filled; independent validation; human accept + commit. Fresh session. |

### runtime

| Field | Value |
| ----- | ----- |
| Kind | independent |
| Primary question | What exactly are G-001, G-002, and G-003 on a real BEAM, and what would a later repo measure to keep or drop each one? |
| Scope | Window vs brain; hands somewhere else (thinnest isolation ladder); plugin swap without Mix in the live app and without OTP relups. Describe what the Arvo *tree* appears to contain (grounding snapshot in DISCOVERY-NOTES; local tree only to check a fact already claimed). Write recommendations `REC-001`…`REC-099`. |
| Non-goals | Coding; Arvo smoke test; Harbor; landing in `arvo/`; inventing G-006; absorbing leftovers or the overnight loop. |
| Prerequisites | Accepted Charter. Inputs: this Blueprint §5 and §7; SORT Graduate rows G-001…G-003 and José clusters; DISCOVERY-NOTES hypothesis + grounding snapshot. |
| Output | `docs/reports/10-runtime-research-report.md` |
| Identifiers | `REC-001`…`REC-099`; may mint `RSK` / `OQ` from the shared pools |
| Spikes | **None in this repo.** Phase-2 may measure. |
| Replication | not permitted by default |
| Parallel group | A |
| Downstream | synthesis (must read). leftovers and score-harness may *cite* this report if it is already accepted; they must not wait for it (they do not depend on it). |
| Completion | Focused-report contract met; three tests still distinct; measure + keep/drop restated, not replaced; independent validation; human accept + commit. |

### leftovers

| Field | Value |
| ----- | ----- |
| Kind | independent |
| Primary question | Which intake ideas become pattern cards hosted on the runtime primitives, and which stay Watch or Refuse? |
| Scope | SORT Translate / Watch / Refuse shelves. Pattern card = leftover insight + the BEAM noun it sits on + why it is not a sixth headline. Prefer cards that need G-001…G-003 as host. `REC-100`…`REC-199`. |
| Non-goals | New intake; promoting a Watch item to a headline test; building Elixir-LangGraph; treating Refuse rows as research centers. |
| Prerequisites | Accepted Charter. Inputs: this Blueprint; SORT Translate/Watch/Refuse; DISCOVERY-NOTES central insight. Does **not** require the runtime report. |
| Output | `docs/reports/11-leftovers-research-report.md` |
| Identifiers | `REC-100`…`REC-199`; shared `RSK` / `OQ` |
| Spikes | none in this repo |
| Replication | not permitted by default |
| Parallel group | A |
| Downstream | synthesis |
| Completion | Focused-report contract met; most items still Watch; no sixth headline; independent validation; human accept + commit. |

### score-harness

| Field | Value |
| ----- | ----- |
| Kind | independent |
| Primary question | How should the later repo run G-004 and G-005 so the harness cannot edit the judge, and so the two tests stay unmerged? |
| Scope | Overnight keep/reset on a **fixed** test set (writable named harness files; human owns `program.md`; judge tree read-only). Specialized helpers as their own Session (scout / critic / planner) with three arms: no helper / parent-model / smaller-or-local. One primary score per run tag. `REC-200`…`REC-299`. |
| Non-goals | Merging G-004 with “improves while you use it”; running the loop; landing the searcher as Arvo’s identity; treating a nested prompt as a child session; requiring the parent model to run locally. |
| Prerequisites | Accepted Charter. Inputs: this Blueprint §5 and §7 items 15–16; SORT G-004, G-005. |
| Output | `docs/reports/12-score-harness-research-report.md` |
| Identifiers | `REC-200`…`REC-299`; shared `RSK` / `OQ` |
| Spikes | none in this repo |
| Replication | not permitted by default |
| Parallel group | A |
| Downstream | synthesis; first consumer outside this repo is the sibling experiment repo |
| Completion | Focused-report contract met; G-004 and G-005 still split; scorer-read-only and frozen-model rules explicit; independent validation; human accept + commit. |

### Fixed spine (after the three reports)

| Stage | Primary question | Scope / non-goals | Output | IDs | Spikes / replication | Downstream | Completion |
| ----- | ---------------- | ----------------- | ------ | --- | -------------------- | ---------- | ---------- |
| synthesis | What single catalog-shaped specification do the three reports support? | Combine accepted reports + Charter. Do not invent a sixth test. Do not write Elixir. | `docs/specifications/01-definitive-specification.md` | `REQ-001`…`REQ-299` | none / off | spec-review | Synthesis contract; every material `REC` dispositioned; human accept + commit. |
| spec-review | Where is the proposed spec thin, merged, or over-confident? | Adversarial only. No new research program. Watch for G-004/G-005 collapse and “in the tree ⇒ works.” | `docs/reviews/01-specification-adversarial-review.md` | `FND-001`…`FND-199` | none / off | spec-revision | Review contract; human accept + commit. |
| spec-revision | What is the corrected specification? | Disposition every `FND-001`…`FND-199`. No silent ID reuse. | `docs/specifications/02-definitive-specification-revised.md` | same `REQ` namespace | none / off | implementation-plan | Revision contract; human accept + commit. **This file becomes implementation authority** — meaning authority for *what the catalog says*, not for coding in this repo. |
| implementation-plan | In what order should hypotheses be tried later? | Phases and milestones of *experiments in the sibling repo*. First milestone includes Arvo smoke check. Stop before a coding-agent ticket pile. | `docs/plans/01-implementation-plan.md` | `PHASE-01`…; `MS-001`… | name phase-2 spikes only; do not run them | plan-review | Plan contract, interpreted as hypothesis sequence. |
| plan-review | Does the sequence smuggle implementation into this repo, merge G-004 with its cousin, or skip the smoke check? | Adversarial. | `docs/reviews/02-implementation-plan-adversarial-review.md` | `FND-200`…`FND-399` | none / off | plan-revision | Review contract. |
| plan-revision | What is the final sequence the sibling repo should follow? | Disposition every plan finding. | `docs/plans/02-implementation-plan-revised.md` | same `PHASE` / `MS` | none / off | program closure; sibling repo | Human accept + commit. Delivery authority **subordinate** to the revised spec, and **does not** authorize Elixir in *this* repo. |

All spine stages: fresh session; no parallel group; Charter + this Blueprint as governing inputs.

## 12. Parallelism

Default is sequential.

**Group A** (runtime, leftovers, score-harness) may run in parallel after the
Charter is accepted. They do not need one another’s findings. Independent
prompts may be packaged together after Charter acceptance; they still run in
**separate fresh sessions**.

The spine stays sequential: discovery → charter → (group A) → synthesis →
spec-review → spec-revision → implementation-plan → plan-review →
plan-revision.

Do not start group A in the session that writes this Blueprint.

## 13. Optional Replication Points

Replication is **off by default**. Focused tier. One operator. The load-bearing
claims are tests for a later repo, not findings that must be re-derived by a
second agent in this one.

A later amendment may turn on a single replication if a report’s load-bearing
claim is contested and cannot wait for phase-2. Reconciliation would then be
required. That is not planned.

## 14. Artifact Inventory

| Path | Role |
| ---- | ---- |
| `docs/00-program-blueprint.md` | This plan. Governing after acceptance. |
| `docs/01-research-charter.md` | Methodology. Placeholder until its own stage. |
| `docs/reports/10-runtime-research-report.md` | Create at runtime stage. Do not create now. |
| `docs/reports/11-leftovers-research-report.md` | Create at leftovers stage. |
| `docs/reports/12-score-harness-research-report.md` | Create at score-harness stage. |
| `docs/specifications/01-definitive-specification.md` | Synthesis output. |
| `docs/specifications/02-definitive-specification-revised.md` | Implementation authority (catalog). |
| `docs/plans/01-implementation-plan.md` | Draft hypothesis sequence. |
| `docs/plans/02-implementation-plan-revised.md` | Delivery sequence for the sibling repo. |
| `docs/reviews/01-specification-adversarial-review.md` | Spec findings `FND-001`…`FND-199`. |
| `docs/reviews/02-implementation-plan-adversarial-review.md` | Plan findings `FND-200`…`FND-399`. |
| `docs/prompts/` | Just-in-time prompts. Spine skeletons exist. |
| `docs/handoffs/` | Attachment manifests per stage. |
| `docs/validations/` | Independent validation reports. |
| `docs/evidence/` | `SPK-###` — expected empty in this repo. |
| `decisions/` | `DEC-###` when a later decision supersedes this file. |
| `research-program.toml` | Operational index only. |
| `docs/working/SORT.md` | Framing evidence: five tests, shelves. Not governing after Blueprint acceptance. |
| `docs/working/DISCOVERY-NOTES.md` | Framing evidence and preserved dump. Do not rewrite the dump. |
| `docs/working/*-WATCH.md` | Closed intake. Do not re-sort. |
| `../coding-agent-harness/arvo` | Instrument. Read-only from this program. Not an output. |

Repository layout: root `README.md` and
[`program/operator/bootstrap.md`](../program/operator/bootstrap.md).

## 15. Identifier Allocations

| Namespace | Range | Notes |
| --------- | ----- | ----- |
| DEC | DEC-001..DEC-999 | Decision records. None minted by this draft. |
| REC (runtime) | REC-001..REC-099 | Runtime report only. |
| REC (leftovers) | REC-100..REC-199 | Leftovers report only. |
| REC (score-harness) | REC-200..REC-299 | Score-harness report only. |
| REQ | REQ-001..REQ-299 | Specification. |
| FND (spec) | FND-001..FND-199 | Specification review. |
| FND (plan) | FND-200..FND-399 | Plan review. |
| RSK | RSK-001..RSK-999 | Shared; mint in the stage that finds the risk. |
| OQ | OQ-001..OQ-999 | Shared. |
| SPK | SPK-001..SPK-999 | Reserved. **Do not use in this repo.** Phase-2 may keep its own ledger. |
| PHASE | PHASE-01..PHASE-99 | Hypothesis phases in the implementation plan. |
| MS | MS-001..MS-999 | Milestones of those phases. |

Graduate labels `G-001`…`G-005` and dump labels `H-###` / `P-###` / `V-###` /
`XB-###` / `LC-###` are **intake IDs**. They are not `REC`/`REQ`. Later stages
cite them; they do not reuse those strings as `REC` numbers.

Never reuse an ID. Disposition upstream IDs explicitly.

## 16. Authority and Precedence

Default order:
[`program/contracts/authority-and-precedence.md`](../program/contracts/authority-and-precedence.md).

Project-specific rules:

1. After acceptance, **this Blueprint’s locked constraints (§7) outrank**
   working notes. SORT and DISCOVERY-NOTES remain citable *evidence of
   framing*, not a second plan.
2. Chat history, model memory, and root `HANDOFF.md` are **not** sources to
   cite in later artifacts.
3. `research-program.toml` is an index. It cannot add a sixth test or accept
   a stage by itself.
4. “In the Arvo tree” is a description of a checkout, not a finding that a
   feature works.
5. Research reports recommend. They do not secretly amend §7.
6. The revised specification is authority for **what the catalog claims**.
   The revised plan is authority for **in what order the sibling repo should
   try hypotheses**. Neither authorizes implementation inside this
   repository.

## 17. Human Approval Gates

Follow [`program/operator/approval-gates.md`](../program/operator/approval-gates.md).

Gates that matter immediately:

1. Human accepts this Blueprint (not done in the writing session).
2. Human accepts the Charter (later fresh session).
3. Human launches each focused stage (prompts just-in-time).
4. Human accepts each focused report before synthesis.
5. Human accepts revised spec, then final plan.

Git is the record. Agents do not commit unless the human asks. Agents never
mark a stage `accepted` without the human’s accepting commit.

## 18. Fresh-Session Policy

Every substantive stage runs in a **fresh session** with a self-contained
attachment manifest under `docs/handoffs/`.

Allowed in a non-fresh session: prepare prompts, manifests, mechanical fixes,
and `just check`.

Forbidden in one context: discovery-plus-Charter, Charter-plus-a-report, or
any two focused reports.

Group A may be *packaged* together after Charter acceptance. Each still
launches in its own session.

## 19. Validation and Commit Gates

Independent validation before acceptance
([`program/contracts/validation.md`](../program/contracts/validation.md);
skill `research-validate`). Validators fix mechanical issues only. They do
not invent research.

Suggested commit after the human is happy with this draft (human runs git):

```text
docs: fill Program Blueprint from agreed sort (not accepted)
```

Accepting commit (later, different commit) is the only thing that may set
`discovery.status = "accepted"` and fill `accepted_commit`.

## 20. Amendment Protocol

[`program/reference/amendment-protocol.md`](../program/reference/amendment-protocol.md).

Material here includes: adding or dropping a headline test; merging G-004
with “improves while you use it”; opening intake; authorizing code in this
repo; using `arvo/` as the lab; changing rigor off focused; adding a library
track that this file omitted.

Non-material: tightening a just-in-time prompt without changing objective,
scope, dependencies, output path, or identifier range.

## 21. Completion Criteria

Program-level bar:
[`program/operator/completion-criteria.md`](../program/operator/completion-criteria.md),
with these readings:

- “Implementation may begin” means **the sibling experiment repo may be
  stood up**, starting with the Arvo smoke check. It does **not** mean open
  a coding-agent backlog in this repo.
- Every `REC` from the three reports has a disposition in the spec or plan.
- Every `FND` has a disposition.
- `SPK` remains unused here.
- Working tree clean on the accepting commits.
- Five tests still five.

## 22. Implementation Handoff Expectation

The final revised plan is delivery authority **subordinate** to the revised
specification.

Handoff target is **not** this repository’s working tree. It is a **later
sibling repository** (name TBD) that:

1. Smoke-checks that Arvo boots and can finish a simple task (do not do that
   check in this program’s research sessions).
2. Runs G-001…G-005 in the order the final plan names.
3. May copy a *winning* constitution, module, or topology into `arvo/` only
   as a separate product gate. The searcher (G-004) does not become Arvo’s
   identity.
4. Keeps the Harbor (or equivalent) verifier read-only.

This program stops at that handoff note. It does not decompose the plan into
hundreds of coding-agent tasks.

## Completion Checklist

- [x] Discovery framing approved by human
- [x] All required sections filled (not placeholder prose)
- [x] Research tracks justified; omitted tracks justified
- [x] Identifier ranges allocated
- [x] Rigor tier approved
- [x] Human accepts Blueprint
- [ ] Manifest updated; accepting commit recorded
