# Specification Adversarial Review — arvo-beam-harness-research

- **Artifact type:** Adversarial review
- **Program:** arvo-beam-harness-research
- **Status:** Proposed — pending independent validation
- **Human acceptance:** Accepted by human 2026-08-15 — awaiting accepting commit
- **Version:** 0.1
- **Created:** 2026-08-15
- **Last updated:** 2026-08-15
- **Subject:** [`docs/specifications/01-definitive-specification.md`](../specifications/01-definitive-specification.md)
- **Subject accepting commit:** `26bd0e4070ef822bdcd5c69d5f57a2a80131176f`
- **Accepting commit:** *(empty — awaiting recording commit)*
- **Finding range:** `FND-001`…`FND-003` (allocated `FND-001`…`FND-199`)
- **Depends on:** Proposed definitive specification (not implementation authority)

> This file is the proposed specification review. Findings are
> proposed corrections, not commandments. They do not become `REQ`s
> until a later revision stage dispositions them. Robert accepted this
> draft on 2026-08-15. Independent validation passed. Spec-review is
> not `accepted` in `research-program.toml` until the accepting
> commit is recorded.

## 1. Artifact Metadata

| Field | Value |
| ----- | ----- |
| Program ID | arvo-beam-harness-research |
| Artifact | Specification adversarial review |
| Owner | Robert Guss |
| Reviewer role | Adversarial reviewer. Not the synthesizer. Not the mechanical validator. |
| Subject | [`docs/specifications/01-definitive-specification.md`](../specifications/01-definitive-specification.md) |
| Subject status | Proposed — pending adversarial review. Not implementation authority. |
| Subject accepting commit | `26bd0e4070ef822bdcd5c69d5f57a2a80131176f` (human-accepted as synthesis output on 2026-08-15) |
| Human acceptance | Accepted by human 2026-08-15 — awaiting accepting commit |
| Review accepting commit | *(empty — awaiting recording commit)* |
| Review status | Proposed — pending independent validation |
| Finding range used | `FND-001`…`FND-003` |
| Date | 2026-08-15 |
| Contract | [`program/contracts/adversarial-review.md`](../../program/contracts/adversarial-review.md) |
| Finding shape | [`program/templates/finding.md`](../../program/templates/finding.md) |

This repository still only catalogs ideas. “Blocks implementation”
on a finding means **blocks the sibling repo from treating the
catalog as ready**, not “blocks Elixir in this tree.”

## 2. Review Scope and Method

### What was read in full

- Accepted Program Blueprint
  ([`docs/00-program-blueprint.md`](../00-program-blueprint.md),
  `0b49540cae7d2a30ad4b4b145999e27b82c50dad`), especially §5, §6,
  §7, §11 spec-review row, §15 `FND` range, §21, §22.
- Accepted Research Charter
  ([`docs/01-research-charter.md`](../01-research-charter.md),
  `081ad36932be7f3f0df062b592cc306c49f72af4`), especially §1, §4–§12,
  §14–§15, §17–§18.
- The proposed specification in full (`26bd0e4`).
- Accepted runtime report
  ([`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md),
  `636123f1a628803aa4ae2c44fc4659d167a80693`).
- Accepted leftovers report
  ([`docs/reports/11-leftovers-research-report.md`](../reports/11-leftovers-research-report.md),
  `9698362dbe5f90ff48e7aa1093d547d2e14d410a`).
- Accepted score-harness report
  ([`docs/reports/12-score-harness-research-report.md`](../reports/12-score-harness-research-report.md),
  `c15dd31c44c197340d2b339657eb7f072f066d44`).
- Independent validation
  ([`docs/validations/13-definitive-specification-validation.md`](../validations/13-definitive-specification-validation.md))
  as a map of mechanical checks. Its non-blocking observations were
  inspection points, not findings to ratify.
- Review contract and finding template.

### What was skimmed

- Blueprint §9, §16, §21.
- Charter inherited constraints and synthesis rules already named
  above.
- Synthesis commission
  ([`docs/prompts/13-chief-architect-synthesis-prompt.md`](../prompts/13-chief-architect-synthesis-prompt.md))
  as a map of what synthesis was allowed to do. Not cited as
  evidence.
- [`docs/working/SORT.md`](../working/SORT.md) Graduate table only.
  Did not re-sort. Did not walk Translate / Watch / Refuse as a
  second leftovers pass.
- Locked top of
  [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md)
  (two programs, José hypothesis, central insight, adaptation). Did
  not rewrite the dump.
- Runtime, leftovers, and score-harness §17 Handoff Digests. Digests
  did not replace the full reports. Report §13–§14 (weak and
  conflicting evidence) were read in full for the over-confidence
  attack.
- [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md),
  [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md),
  [`program/contracts/validation.md`](../../program/contracts/validation.md),
  [`program/contracts/definitive-specification.md`](../../program/contracts/definitive-specification.md),
  [`program/operator/approval-gates.md`](../../program/operator/approval-gates.md),
  [`program/contracts/identifiers.md`](../../program/contracts/identifiers.md).

### What was not read or run

- Watch dump files (`ARXIV`, `LANGCHAIN`, `AUTORESEARCH`, `VAULT`,
  `X-BOOKMARKS`).
- Bookmark JSON, unread Articles, vault traces, 339 stubs,
  `docs/working/arxiv-home/ai-papers/*.pdf`.
- Placeholder plans and later-spine reviews.
- Chat history, model memory, root handoff maps (as evidence).
- `../coding-agent-harness/ore`.
- Arvo was **not** booted. Harbor was **not** run. No Arvo command
  was run as a test. No Elixir was written. Intake was not reopened.

### Exa

**Exa did not run.** Documented skip, not a pretend run. Official
pages already cited in the three accepted reports and the
specification were enough. No load-bearing sentence in the
specification’s *use* of those pages was thin enough to merit a
refresh. No new papers were harvested. Exa MCP was not used.

### Attacks attempted

| Attack | Result | Finding or “no defect” |
| ------ | ------ | ---------------------- |
| G-004 collapse | No defect | — |
| In the tree ⇒ works | No defect | — |
| Sixth test | No defect | — |
| Port-as-native / Elixir-LangGraph | No defect | — |
| Plan-as-backlog / this-spec-as-tickets-here | No defect | — |
| Opened intake or daily-driver drift | No defect | — |
| Judge eaten | Defect | `FND-002` |
| Helper is a prompt | No defect | — |
| Searcher as Arvo’s identity | No defect | — |
| Invented Harbor number | No defect | — |
| Thin | Defect | `FND-001`, `FND-002`, `FND-003` |
| Merged | Defect | `FND-001`, `FND-003` |
| Over-confident | No defect | — |

“No defect” is a legal result. Decorative `FND`s were not minted
for clean attack rows.

### Inspection points (not pre-minted)

Judged after reading the specification against the three reports:

| Point | Judgment |
| ----- | -------- |
| Watchlist `REQ` priority (`REQ-043`…`REQ-046` are Must; text is *MUST stay Watch*) | No defect. Applies-to is the Watch shelf; implementation phase is `catalog only`; Exceptions refuse a keep without a later measure. Must is the shelf constraint, not “MUST implement GEPA.” |
| Twenty-three Watch clusters as a group via `REC-114` | No defect. Legal grouping. No cluster is promoted. |
| Optional cards dual-listed as Accepted-as-May and Deferred | No defect. Allowed-as-optional, not a silent drop. |
| Shortened inherited `OQ-003` / `OQ-017` | No defect. Harmless compression. IDs, blocking flags, and resolution paths survive. |
| Operator-care column omitted from the five-test restatement | No defect. In-scope restatement of the required cells. |
| Human-acceptance banner plus Proposed / not-authority | No defect. Correctly two-layered (synthesis output accepted; catalog not implementation authority). |
| Software-first headings §7–§19 | No defect as a class. They refuse a product stack, APIs, SLOs, and CI here. The G-004 totality hole lives in §16 / `REQ-034`–`REQ-035`, not in empty architecture. |
| Merged Watch pairs `REC-111`+`REC-208` / `REC-112`+`REC-209` | Named nuances survive (`organism ≠ searcher ≠ judge`; watches cannot keep unless declared primary). `OQ-011` stays closed. Force-verify / onboard stay unnamed as leftover *policies* — compression, not promotion. |
| Confidence laundering | No defect. `REQ-009` holds. No High-confidence “would work” / “holdout would rise” / leftover-sings sentence in §22. |
| Official RLM Port vs foreign-harness shell | No defect. `REQ-025` and `REQ-016` stay distinct. |
| Judge fence totality | Defect. See `FND-002`. |
| G-005 testability (child Session vs nested prompt) | No defect on the isolation checks. Parent-must-not-import-transcript and child-cannot-`start_turn` are enough to tell a Session from a taped-on prompt. The dropped sequential split is `FND-003`, not theater. |
| First later sequence | No defect. Informal “phase-2” prose. No `PHASE` / `MS` minted. |
| Disposition completeness | 38 / 38 material `REC`s have a row. Required drops stay dropped. The incomplete inheritances are `FND-001` (G-004 keep/drop not reconciled) and `FND-003` (`REC-203` sequential bar). |

## 3. Executive Assessment

The catalog is coherent enough to revise. Five tests stay five.
G-004 is still a fixed-set lab loop. G-005 is still its own
Session with three arms. Watch stays Watch. Required drops stay
dropped. Checkout text is not scored as function. No Harbor
number is invented. Intake stays closed. Those locks were
preserved.

The worst failure mode, if a later sibling repo treated this file
as the agenda tomorrow, is **not** “Elixir in this tree” and not
“G-004 becomes an online improver.” It is this: an operator
following `REQ-034` as the G-004 keep rule can keep a run whose
leftover G-001…G-003 measures fell, because the restated Blueprint
table, §16, and `REQ-034` name three different leftover-test bars.
The same operator, following §16’s shorter read-only list as the
judge-tree diff, can miss an `instruction.md` or Oracle edit that
the accepted score-harness fence already called a judge-tree
object.

That is a G-004 method hole, not a collapsed catalog. G-001, G-002,
G-003, and G-005 remain usable as named tests. Spec-revision must
make one keep/drop and one fence before the catalog is ready as
the sibling-repo agenda.

## 4. Findings

### FND-001 — G-004 leftover-test keep/drop is three rules, not one

- **Severity:** High
- **Confidence:** High
- **Category:** thin / contradiction / merged
- **Affected sections:** proposed specification §5 five-test
  restatement (row 4); §16 G-004 method; §22 `REQ-034`
- **Affected requirements:** `REQ-034` (primary); `REQ-035`
  leftover-test identity (related); `REQ-002` only insofar as the
  five tests must remain separately keepable
- **Affected phases:** none (no PHASE minted)
- **Blocks implementation:** Named later job (G-004 method)

#### Problem

The proposed catalog does not state one leftover-test bar for a
G-004 keep. A later operator cannot keep or drop a tagged run
without inventing which sentence is the keep rule.

#### Evidence

Three normative readings sit in the same proposed specification
(`26bd0e4`):

1. Five-test restatement, row 4, “What we would try later”:
   “Leftover tests must also **improve**.” That cell restates
   accepted Blueprint §5 (`0b49540`).
2. §16 G-004 method: “Leftover G-001…G-003 measures must not
   **collapse**.” That sentence restates accepted score-harness
   `REC-200` later measure (`c15dd31`).
3. `REQ-034` keep sentence: keep the loop if holdout rises without
   verifier edits, without tokens/time as the win, and without
   **honesty collapse**. Leftover G-001 liveness, G-002 isolation,
   and G-003 swap are **absent** from the keep sentence.

The accepted score-harness report is not cleaner as a single
quoted line. Its §8.2 leftover-test-identity row says “Must also
improve / not collapse,” while `REC-200` says “must not collapse.”
Synthesis Accepted `REC-200` into `REQ-034` and restated Blueprint
§5, then left both verbs and the honesty-only keep sentence in
force. Reports §13 already require leftover-sings / holdout-would-
rise claims to stay Medium or Low; they do not authorize three
keep gates.

Blueprint §5’s own keep/drop cell already uses honesty collapse,
not “must also improve.” The try-column and the keep-column were
already in tension. The specification’s job was to make **one**
catalog claim. It copied the tension into §5, sharpened it one way
in §16, and dropped leftover G-001…G-003 from the normative keep
in `REQ-034`.

#### Failure Scenario

The sibling repo runs a tagged G-004 loop. Holdout on the declared
primary rises. Honesty is flat. G-002 leftover isolation falls
(hands can now read a key, or kill-hands no longer leaves Session).
The operator who follows `REQ-034` records **keep**. The operator
who follows §16 records **discard** (collapse). The operator who
follows the §5 try-column records **discard** unless every leftover
measure also rose. Three operators, three outcomes, one catalog.

#### Impact

G-004’s keep/drop is not usable as a single rule. That is a named
keep/drop made invalid. The rest of the five tests remain named.
A later plan cannot sequence an honest G-004 run until revision
picks one bar.

#### Root Cause

Synthesis restated Blueprint §5 and Accepted `REC-200` without
reconciling the leftover-test verb into `REQ-034`. Report-class
nuance (`must not collapse`) and Blueprint try-column wording
(`must also improve`) were both preserved as if they were the
same claim.

#### Required Correction

Make `REQ-034` the single keep rule. Put leftover G-001…G-003
measures on that rule as **must not collapse** (the score-harness
`REC-200` bar, which matches Blueprint’s keep/drop cell and does
not invent a required rise). Annotate the §5 restatement so
“must also improve” is the *try*, not a second keep gate. Make
§16 use the same sentence as `REQ-034`. Do not add a sixth test.
Do not merge G-004 with “improves while you use it.” Do not
amend Blueprint §7.

#### Proposed Specification Diff

In `REQ-034` Requirement, replace the keep sentence with:

> Keep the *loop* if holdout rises without verifier edits, without
> “more tokens / more time” as the win, without honesty collapse,
> and without leftover G-001 liveness, G-002 isolation, or G-003
> swap measures collapsing. Drop if it only Goodharts three tasks.

In §16, replace “Leftover G-001…G-003 measures must not collapse”
with the same sentence (or a pointer to `REQ-034`).

Under the §5 row-4 try-column, add one note, not a sixth column:

> “Leftover tests must also improve” is the try. The keep rule is
> `REQ-034`: leftover G-001…G-003 measures must not collapse.
> A required rise of every leftover measure is not a keep gate.

#### Acceptance Evidence

`REQ-034`, §16, and the §5 note name one leftover-test bar. A
later operator can keep or discard a G-004 tag without inventing
a verb. Five tests still five. Cousin still rejected.

#### Alternatives Considered

- **Not a defect / preference.** Lost. An operator cannot apply
  two verbs and a missing clause as one keep. That is not taste.
- Use Blueprint try-column “must also improve” as the keep.
  Rejected. Blueprint’s own keep/drop cell does not require a
  rise. A required rise of every leftover measure would make
  almost every G-004 keep illegal and would replace the
  score-harness bar.
- Leave the tension for the later plan. Rejected. Keep/drop is a
  catalog claim. The plan sequences tests; it must not invent the
  bar.

#### Residual Risk

A later plan might still treat “improve” as a stretch goal and
quietly raise it to a keep. The §5 note is the mitigation.
Phase-2 still has to name the leftover measures operationally
(`OQ-001`…`OQ-005` remain open). That is later measurement, not
a second keep rule.

#### Related Findings

`FND-002` (the same G-004 method’s fence list is short). Do not
merge the findings: a revision may accept the keep-rule fix and
reject the fence expansion, or the reverse.

### FND-002 — G-004 judge-tree read-only list is shorter than the accepted fence

- **Severity:** Medium
- **Confidence:** High
- **Category:** judge eaten / thin
- **Affected sections:** proposed specification §16 G-004 method;
  §22 `REQ-035`; §11 (audit JSONL / missing `evals/` already
  honest)
- **Affected requirements:** `REQ-035` (primary); `REQ-034` (fixed
  test set depends on a frozen task list); `REQ-006` (checkout ≠
  score) only as a non-regression
- **Affected phases:** none (no PHASE minted)
- **Blocks implementation:** Named later job (G-004 method)

#### Problem

`REQ-035` and §16 name a shorter read-only set than the accepted
score-harness judge tree. A later operator who diffs only the
listed objects can miss writes the accepted fence already treated
as eating the judge or unfreezing the test set.

#### Evidence

Accepted score-harness §8.2 (`c15dd31`) lists the judge tree the
organism may not edit, including:

- Harbor `tests/` and `task.toml` `[verifier]`
- `instruction.md` and the frozen task list (no during a tagged
  run)
- holdout
- `solution/solve.sh` (Oracle; no as a mutation target)
- `program.md`
- leftover-test identity, defined as G-001 liveness, G-002
  isolation, G-003 swap — **no renaming or dropping mid-run**
- audit JSONL append-only

`REQ-035` says the organism MUST NOT edit “the scorer, the
holdout, leftover-test identity, or `program.md`.” Writable files
MUST be only: constitution, compact-strategy module, tool list,
observe-only hooks.

§16’s explicit read-only list is: Harbor `tests/`, `task.toml`
`[verifier]`, holdout, leftover-test identity, `program.md`.

Missing from that explicit list, and undefined as objects:
`instruction.md`, the frozen task list, Harbor `solution/`
(Oracle), leftover-test identity as a *named* G-001/G-002/G-003
suite that cannot be renamed or dropped mid-run.

The writable-only-four sentence still *implicitly* excludes
`instruction.md`. The defect is not that the spec authorizes those
writes. The defect is that the verification procedure named in
`REQ-035` (“diff judge tree and `program.md`”) will follow §16’s
shorter list unless revision names the omitted objects.

Shared-mode Harbor is still named as a hole. Regrade-after-run is
still distinct from mid-search grader edit. Those pieces of
`REC-201` were preserved.

#### Failure Scenario

A G-004 organism rewrites `instruction.md` so the train tasks are
easier, or deletes a leftover G-002 isolation check from the
leftover-test list after seeing a bad column. `tests/` and
`program.md` are unchanged. The operator diffs the §16 list,
records no judge write, and keeps the tag. The fixed test set
moved. The leftover-test identity moved. That is eating the judge
by moving the exam.

#### Impact

The G-004 fence is incomplete as a catalog procedure. It is not
an invitation to shared-mode honesty, and it is not an invented
Harbor number. A later repo can still run, but it can certify a
keep the accepted fence would have crashed.

#### Root Cause

Synthesis Accepted `REC-201` into a compressed `REQ-035` body and
copied a subset of the §8.2 table into §16. The omitted rows were
treated as implied by “writable MUST be only four,” which does
not tell the later diff what to look at.

#### Required Correction

Expand `REQ-035` / §16 so the read-only list matches the accepted
judge tree: `tests/`, `task.toml` `[verifier]`, `instruction.md`,
frozen task list, holdout, `solution/` (Oracle), leftover-test
identity, `program.md`. Define leftover-test identity as the named
G-001 liveness / G-002 isolation / G-003 swap measures; they MUST
NOT be renamed or dropped mid-run. Keep writable files as the same
four. Keep shared-mode as not an honest judge. Do not invent a
Harbor number. Do not add environment/ or other Harbor objects the
accepted report did not name.

#### Proposed Specification Diff

In `REQ-035` Requirement, after the current MUST NOT sentence,
add:

> The judge tree the later repo MUST diff before vs after every
> trial is: Harbor `tests/`, `task.toml` `[verifier]`,
> `instruction.md`, the frozen task list, the holdout,
> `solution/solve.sh` (Oracle; not a mutation target), leftover-test
> identity, and `program.md`. Leftover-test identity means the named
> G-001 liveness, G-002 isolation, and G-003 swap measures. Those
> measures MUST NOT be renamed or dropped during a tagged run. Any
> write to the judge tree → crash / discard, not keep.

Mirror that list in §16’s Read-only bullet. Leave the Writable
bullet unchanged.

#### Acceptance Evidence

§16 and `REQ-035` list the same objects as score-harness §8.2’s
No rows that bind the organism. A judge-tree diff that only
follows the specification would catch an `instruction.md` or
leftover-suite edit. Writable set still four files. No new
primary. No G-006.

#### Alternatives Considered

- **Not a defect / preference.** Lost. “Writable MUST be only
  four” is a constraint, not a diff checklist. The later measure
  in `REC-201` is the diff. A short list makes that measure lie.
- Treat Harbor `environment/` as read-only too. Rejected. The
  accepted report did not name it as a judge-tree object. Adding
  it here would be feature ideation.
- Require a Harbor number to prove the hole. Rejected. No run in
  this repo. The defect is catalog incompleteness against an
  accepted fence.

#### Residual Risk

Harbor flags dated 2026-08-15 can move. `OQ-014` (holdout shape)
and `OQ-013` (reward field) stay later-repo. An organism can still
eat a judge through a channel nobody listed. Separate-mode (or
equivalent) remains the SHOULD fence. This finding does not close
`RSK-020`; it makes the catalog’s listed objects match the
accepted fence.

#### Related Findings

`FND-001`. Same method, different hole (keep verb vs fence list).

### FND-003 — G-005 keep/drop dropped the sequential vs parallelizable split

- **Severity:** Medium
- **Confidence:** High
- **Category:** merged / thin
- **Affected sections:** proposed specification §22 `REQ-040`,
  `REQ-042`; §16 G-005 method (split named, drop rule absent); §5
  row 5 (Blueprint restatement)
- **Affected requirements:** `REQ-040`, `REQ-042`
- **Affected phases:** none (no PHASE minted)
- **Blocks implementation:** Named later job (G-005 method)

#### Problem

`REC-203` was Accepted into `REQ-040` and `REQ-042`, but the
keep/drop those `REQ`s state omits the sequential vs
parallelizable split. A later operator can keep a specialist that
helps only parallelizable work and regresses sequential tasks.

#### Evidence

Accepted score-harness `REC-203` (`c15dd31`) later measure: “Split
sequential vs parallelizable tasks (V-002).” Keep / drop: “Drop if
the child is a nested prompt with a pid taped on, or if sequential
tasks regress like V-002.”

SORT Graduate G-005 (framing, not a lock that outranks the
Blueprint) already had the same split and the same drop.

`REQ-040` requires three arms, own Session, no transcript import,
no child `start_turn`, scout isolation, one specialist family per
tag. It does not require the sequential / parallelizable split and
does not drop a sequential regression.

`REQ-042` requires declaring one of success / waste / dollars /
wall time as keep-deciding, and allows local/smaller to lose. No
sequential bar.

§16 G-005 method does say “Split sequential vs parallelizable
tasks.” That is a method bullet without a keep/drop. The
Blueprint-restated §5 row 5 matches Blueprint §5 (no V-002 drop).
Reports were allowed to sharpen fences. Synthesis Accepted
`REC-203` and left that sharpening in prose.

`REQ-041` still drops a nested prompt. Helper-is-a-prompt is not
the defect. The three arms are still required. Local may still
lose.

#### Failure Scenario

Phase-2 runs the three-arm G-005 sweep. The planner child helps
parallel explore and hurts a single-file sequential edit (the
V-002 shape). Declared keep-deciding score is parent waste, which
improved on the mixed set. The operator following `REQ-042`
records **keep**. The accepted `REC-203` bar would have
**dropped** the specialist as a blanket keep.

#### Impact

G-005’s keep/drop is incomplete. It does not collapse G-005 into
G-004, and it does not turn a nested prompt into a Session. A
later repo can still run the three arms. It can keep the wrong
specialist.

#### Root Cause

Silent recommendation-nuance loss on an Accepted `REC`. The
Blueprint table was restated faithfully; the Accepted score-harness
keep/drop was not lifted into the `REQ`.

#### Required Correction

Add the sequential vs parallelizable split to `REQ-040` or
`REQ-042` as a keep/drop, not only as a §16 bullet. Drop a
specialist that wins only on parallelizable tasks and regresses
sequential ones. One specialist family per tag remains. Do not
blend scout / critic / planner into a committee. Do not merge
G-005 with G-004.

#### Proposed Specification Diff

In `REQ-040` Requirement, after “One specialist family per run
tag,” add:

> The later repo MUST split sequential vs parallelizable tasks
> (V-002). A specialist that helps only parallelizable work and
> regresses sequential tasks MUST NOT be recorded as a blanket
> keep.

In `REQ-042` keep sentence, add the same drop next to the
org-chart drop. Leave §16’s split bullet; make it point at the
`REQ`.

#### Acceptance Evidence

`REQ-040` / `REQ-042` state the V-002 split and the sequential-
regression drop. A later three-arm sweep cannot keep a planner
that only wins the parallel slice. Nested-prompt drop unchanged.
Three arms unchanged. Local may still lose.

#### Alternatives Considered

- **Not a defect / preference.** Lost. This is an Accepted
  `REC-203` keep/drop, not a taste for more metrics.
- Leave the split in §16 only. Rejected. §22 is what the catalog
  claims. A method bullet without a keep/drop is how the nuance
  dies.
- Make sequential success a second G-005 primary. Rejected. That
  would be a second keep-deciding score, against `REQ-042`. The
  split is a *slice*, not a sixth test and not a second primary.

#### Residual Risk

`OQ-015` (which specialist first) and `OQ-016` (parent-waste
definition) stay later-repo. An operator can still mix sequential
and parallelizable tasks in one average and hide the regression.
The `REQ` should say the slices are reported separately. That is
included in “split,” not a new scoreboard.

#### Related Findings

None that share a cause. Do not treat this as a sixth test or as
helper-is-a-prompt.

## 5. Cross-Cutting Issues

### Contradictions

The only catalog-level contradiction that makes a named keep/drop
unusable is `FND-001` (improve vs not-collapse vs honesty-only).
`FND-002` is an incomplete fence list, not a yes/no contradiction
with `REQ-016` / `REQ-025` or with checkout-vs-function.

Prose, `REQ`s, tables, and the §28 disposition ledger otherwise
agree: five tests; G-004 ≠ cousin; G-005 ≠ nested prompt; searcher
≠ identity; Watch ≠ G-006; `OQ-011` closed; Required runtime drops
Accepted as rejections.

### Workflows end to end

| Workflow | Catalog completeness |
| -------- | -------------------- |
| Catalog operator (Robert) | §13 is enough: accept / send back / later spec-review. Not a ticket pile here (`REQ-001`, `REQ-010`, `RSK-030`). |
| Sibling-repo operator | Smoke-check **there**, then G-001…G-005 in the order a later plan names. First job is not a `PHASE`. |
| G-004 keep / discard / crash | Named. `git` keep/reset named. Crash → reset is inferable. Not an ops program. The missing piece is which leftover bar decides keep (`FND-001`) and which objects the post-trial diff covers (`FND-002`). |
| G-005 three-arm sweep | Required. Local may lose. Isolation checks are testable from the spec. The missing piece is the V-002 slice (`FND-003`). |
| Later trial failure / cancel / rollback | Child Session per trial; ephemeral workdir then keep or `git` reset. Enough for a catalog. Naming kill-the-child-on-crash as a recipe would be preference, not a finding. |

### What this review would delete (preference, not findings)

- `REQ-037` and `REQ-039` are twins (loop is not identity / do not
  land the searcher). A revision may fold them. Not a defect:
  they inherit `REC-204` and `REC-207`.
- Software-first headings that only refuse a product stack are
  required catalog readings. Do not delete them to look lean.
- Do not delete Watch `REQ-043`…`REQ-046`. Naming the shelf is
  how `REC-111` / `REC-112` / `REC-210` / `REC-114` stay honest.

No attractive subsystem is proposed. No MCP, Horde, Oban,
libcluster, OTP relup, or LiveView architecture. No G-006.

## 6. Implementation Gate Recommendation

- **Gate:** Conditional
- **Rationale:** One High finding (`FND-001`). Two Medium findings
  (`FND-002`, `FND-003`). No Critical finding. No contradiction
  that makes the five tests or a required fence *unusable as
  names* — G-004 and G-005 still exist and stay split — but
  G-004’s keep/drop is not a single rule, so the catalog is not
  ready as the sibling-repo agenda until spec-revision
  dispositions `FND-001`. `FND-002` and `FND-003` must be
  dispositioned in the same revision so the G-004 fence and the
  G-005 keep/drop are the accepted reports’ bars, not a later
  operator’s invention.

This stage does **not** open a coding gate in this tree.
Conditional means “ready for spec-revision,” not “write Elixir.”
Even a later Open would still mean the sibling repo may be stood
up after the revised catalog, starting with the Arvo smoke check
**there**.

## 7. Whether an Additional Review Round Is Recommended

**No.** Risk-triggered extra rounds are not automatic. This review
introduces no new machinery. The required revision is
reconciliation of already-accepted bars (`REC-200`, `REC-201`,
`REC-203`) into the `REQ`s that Accepted them, plus one footnote
on the five-test restatement. That is a normal spec-revision, not
a restructuring that needs a second spec-review pass before
revision.

Default next stage after human acceptance of this review:
spec-revision in a **fresh** session. Do not start it here.

## Completion Checklist

- [x] Review exists at
      `docs/reviews/01-specification-adversarial-review.md`
- [x] All 7 numbered headings present and filled
- [x] Status: `Proposed — pending independent validation`
- [x] Attacks attempted table covers every required attack
- [x] Findings use `FND-001`…`FND-199` only; sequential; all
      template fields filled
- [x] Concrete failure scenarios and required corrections
- [x] No feature ideation disguised as defects
- [x] Five tests still five in every proposed diff; no G-006
- [x] Proposed diffs do not merge G-004 with its cousin
- [x] Proposed diffs do not land the searcher as identity
- [x] `OQ-011` remains closed; Watch shelves remain Watch
      unless a finding *shows* the spec promoted them (none did)
- [x] No `REQ` / `REC` / `RSK` / `OQ` / `EVD` / `SPK` /
      `PHASE` / `MS` minted
- [x] No Harbor run; no Arvo command run as a test
- [x] Exa used via REST only as allowed, or skip documented
- [x] Intake not reopened
- [x] Plain-language summary shown to Robert *(session message,
      not this file)*
- [x] Human accepts review
- [x] Independent validation passed
- [ ] Manifest updated; accepting commit recorded
