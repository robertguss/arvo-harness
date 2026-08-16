# Specification Revision Prompt — arvo-beam-harness-research

- **Artifact ID:** PROMPT-spec-revision
- **Program:** arvo-beam-harness-research
- **Stage:** spec-revision — Revised Definitive Specification
- **Kind:** artifact-revision
- **Status:** Installed — ready for a fresh execution session
- **Required output:** `docs/specifications/02-definitive-specification-revised.md`
- **Requirement range:** same `REQ` namespace as the proposed
  specification (`REQ-001`…`REQ-299`). Keep `REQ-001`…`REQ-047`
  where the subject is the same. New requirements only from
  unused `REQ-048`+.
- **Finding range to disposition:** `FND-001`…`FND-003` (allocated
  `FND-001`…`FND-199`; only three were minted). Do **not** remint
  `FND`s.
- **Depends on:** Accepted spec-review
  (`e00ee9c5e79adffd93c13ce2a03b92517a6b8c26`); independent
  validation Pass with mechanical corrections
  (`docs/validations/14-specification-adversarial-review-validation.md`).
  Subject specification
  (`docs/specifications/01-definitive-specification.md`) is
  human-accepted synthesis output at
  `26bd0e4070ef822bdcd5c69d5f57a2a80131176f` and is **not**
  implementation authority.
- **Contract:** [`program/contracts/definitive-specification.md`](../../program/contracts/definitive-specification.md)
  (revised-specification rules)
- **Requirement shape:** [`program/templates/requirement.md`](../../program/templates/requirement.md)

> This file commissions the revised specification. It is not the
> specification. Do not write an implementation plan, a plan
> review, or any Elixir in the same session. Do not mark
> `spec-revision` accepted.

## Role

Act as Revision Architect. Disposition every minted finding;
rewrite the catalog as a **coherent standalone whole**. Do not
re-derive the review. Do not add features. Prefer
simplification over new machinery.

Talk to Robert in **plain language** when you finish. The
revised specification itself must still use the required
section names.

Findings are **proposed corrections**, not commandments. They
become catalog claims only when this revision dispositions them
into surviving `REQ`s.

## Mission

Answer:

> What is the corrected specification?

Produce
[`docs/specifications/02-definitive-specification-revised.md`](../specifications/02-definitive-specification-revised.md)
as a complete standalone revised specification.

This repo **still only catalogs ideas**. After a valid
disposition of the High finding, this file becomes authority
for **what the catalog claims**, still not for Elixir, Harbor,
or PRs into Arvo **here**.

When the file is filled, show Robert a short plain-language
summary. **Do not** accept the revision. **Do not** start
implementation-plan.

Status of the filled file:

- **Status:** `Proposed — pending independent validation`
- **Implementation status:** `Accepted — implementation
  authority` (catalog-as-agenda reading) **only if** every
  Critical finding and every implementation-blocking hole is
  resolved or validly rejected **and** one leftover-test keep
  bar remains. Otherwise `Proposed — implementation blocked`
  with blockers explicit.

“Implementation authority” here means a later sibling repo may
treat this file as the agenda. It does **not** mean write
Elixir in this tree.

## Required inputs

Read in the order given in
[`docs/handoffs/spec-revision-attachment-manifest.md`](../handoffs/spec-revision-attachment-manifest.md).
Governing artifacts in full: accepted Blueprint and accepted
Charter. Then this prompt. Then the **proposed specification in
full** (the body you correct). Then the **accepted review in
full** (the three findings you disposition). Then **all three**
accepted focused reports **in full** (not only their Handoff
Digests). Then the revised-spec skeleton you will replace.

Charter §17 plus this program’s revision rule: inherit all
three focused reports in full. Digests must not replace them.

## Required output path

`docs/specifications/02-definitive-specification-revised.md`

Replace the placeholder skeleton in that path. Do not create a
second filename and call the stage done. Do not write any plan
or a second review.

The output must be **standalone**. A later operator must not
need `01-definitive-specification.md` to know what the catalog
claims. Carry the proposed specification forward and integrate
the accepted corrections. Do not ship a patch file.

## Authority and precedence

Order: [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).

For this stage, project-specific readings:

1. Accepted `DEC-###` (none exist).
2. Locked constraints in
   [`docs/00-program-blueprint.md`](../00-program-blueprint.md)
   §7, plus the §5 five-test table, §6 non-goals, §11
   **spec-revision** row, §15 same `REQ` namespace, §16
   catalog-authority reading, and §22 searcher-is-not-identity.
   Do **not** amend Blueprint §7.
3. Normative rules in
   [`docs/01-research-charter.md`](../01-research-charter.md),
   especially §10 spine bar, §11 confidence, §14–§15 (what
   synthesis and review were allowed to do), §17 handoff, §18
   anti-patterns, §19 (every `FND` has a disposition).
4. **This prompt.**
5. There is **no** current accepted revised specification. The
   file you correct
   ([`docs/specifications/01-definitive-specification.md`](../specifications/01-definitive-specification.md),
   `26bd0e4070ef822bdcd5c69d5f57a2a80131176f`) is **Proposed —
   pending adversarial review** and is not implementation
   authority. After human accept + commit of *your* file, that
   file becomes authority for **what the catalog claims**,
   still not for Elixir here.
6. Accepted review
   ([`docs/reviews/01-specification-adversarial-review.md`](../reviews/01-specification-adversarial-review.md),
   `e00ee9c5e79adffd93c13ce2a03b92517a6b8c26`) is **proposed
   corrections**, not a second Blueprint. Disposition every
   minted `FND`. Prefer the finding’s Proposed Specification
   Diff when you Accept. Do not remint the `FND`s.
7. Accepted reports as **evidence and recommendations**, not a
   second Blueprint. They do not secretly amend §7.
   - Runtime
     ([`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md),
     `636123f1a628803aa4ae2c44fc4659d167a80693`): host nouns.
   - Leftovers
     ([`docs/reports/11-leftovers-research-report.md`](../reports/11-leftovers-research-report.md),
     `9698362dbe5f90ff48e7aa1093d547d2e14d410a`): cards;
     Watch stays Watch.
   - Score-harness
     ([`docs/reports/12-score-harness-research-report.md`](../reports/12-score-harness-research-report.md),
     `c15dd31c44c197340d2b339657eb7f072f066d44`): G-004 /
     G-005 methods; `OQ-011` already closed. `FND-001`…
     `FND-003` cite `REC-200`, `REC-201` §8.2, and `REC-203`.
8. Independent validations
   ([`docs/validations/13-definitive-specification-validation.md`](../validations/13-definitive-specification-validation.md),
   [`docs/validations/14-specification-adversarial-review-validation.md`](../validations/14-specification-adversarial-review-validation.md))
   are **mechanical Passes**. Use them as maps of what was
   already checked. They are not findings and not dispositions.
9. Framing evidence: Graduate table of
   [`docs/working/SORT.md`](../working/SORT.md); locked top of
   [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md).
   These do **not** outrank the Blueprint. Do not re-sort.
   DISCOVERY-NOTES **Next** line may be stale; do not treat it
   as the stage pointer.
10. `research-program.toml` is an index only.
11. This prompt, the attachment manifest, and any handoff map
    are **maps**. Do not cite them as evidence in the revised
    specification.
12. Chat history and model memory are not authority.

A later specification may not secretly amend Blueprint §7.
“In the Arvo tree” is a checkout description, not a finding
that a scorer or feature works. A Harbor method page is design
insight, not a result this lab has run.

## Locked context (do not re-litigate)

From the accepted Blueprint §7, the accepted Charter, and the
proposed specification. Detail stays there.

1. Personal lab. Catalog only in this repo.
2. Five headline tests `G-001`…`G-005`. No sixth. Drop none.
3. Intake is closed. Do not dump more papers. Do not re-sort.
4. No spikes, evals, Harbor runs, smoke tests, or PRs into Arvo
   **here**.
5. Arvo is the instrument in `../coding-agent-harness/arvo`, not
   a daily driver. “In the tree” ≠ “works.”
6. Adaptation, not photocopy, not “refuse every rewrite.” A
   Port-wrapped foreign harness is a shell.
7. Central insight: TypeScript/Python papers specify OTP, then
   fake an OS. Circle the Erlang noun; keep the *new* leftover.
8. **G-004 is a lab loop on a fixed test set.** Frozen model.
   Scorer / judge tree read-only. One primary number declared
   **before** the run. Writable: named harness files. Human
   owns `program.md`. **Not** “improves while you use it.”
9. **G-005 helpers are specialized** (scout / critic / planner)
   as their **own Session**. Three arms: none / parent-model /
   smaller-or-local. Local may lose. A nested prompt with a pid
   taped on is a drop.
10. The G-004 loop does **not** become Arvo’s identity. A
    winning file may later be copied. The loop stays in the
    sibling repo.
11. Rigor is **focused**. Replication off. `SPK-###` unused
    here.
12. Phase-2’s first job includes an Arvo smoke check — **there**,
    not here.
13. Most intake stays on Watch on purpose. Cards are not tests.

Score-harness and the accepted review already answered
questions this revision must **not** reopen as if they were
still open:

- **`OQ-011`:** yes, a proposer slot exists *above* G-004
  (`REC-208`). Leftovers **`REC-111`** (GEPA/ACE) stays Watch.
  Not an online improver. Not G-006.
- **`REC-112` / `REC-209`:** a later judge may *watch* honesty,
  stub/reuse, isolation, kill-Focus-lives. Stay Watch. Not
  G-006. No invented Harbor number.
- G-004 and G-005 stay split. Cousin rejected (`REC-205`).
  Nested prompt rejected (`REC-206`). Searcher is not Arvo’s
  identity (`REC-204`, `REC-207`).
- Harbor official docs (2026-08-15, via the accepted
  score-harness report): default verifier is **shared**; later
  repo should use **separate** mode (`REC-201`). That is
  inherited method, not a run this lab performed.
- Checkout fact, not a score: `evals/arvo-attention-reread/` is
  **absent** at Arvo `84004e1` (`EVD-214` in the score-harness
  report).
- Review gate: **Conditional** (one High: `FND-001`). No extra
  spec-review round. Normal revision is the next stage.

You **may** find that a proposed-spec sentence failed to
*preserve* one of these locks. Correct that as part of
disposing the matching `FND` if the review already named it.
You may **not** argue the lock itself should change. You may
**not** mint a new `FND`.

## Stage boundary

### Included

- One standalone revised specification.
- Disposition **every** minted `FND-001`…`FND-003` with exactly
  one allowed disposition. Silent drop is a defect.
- Integrate accepted corrections throughout the affected
  sections (not only the `REQ` body).
- Carry forward the proposed specification’s catalog: five
  tests, three hosts, leftover cards, Watch / Refuse, 38 `REC`
  dispositions, inherited `RSK-001`…`RSK-030`, inherited
  `OQ-001`…`OQ-018` (`OQ-011` closed).
- Retain stable `REQ-001`…`REQ-047` where the subject remains
  the same. Amend `REQ-034`, `REQ-035`, `REQ-040`, `REQ-042`
  in place when you Accept those findings.
- New `REQ`s only from `REQ-048`+, and only if a finding cannot
  be expressed by amending an existing `REQ`. Prefer amend.
- Honest two-layer status (artifact pending validation;
  implementation status catalog-authority or blocked).
- Status: `Proposed — pending independent validation`.

### Excluded

- Coding, `mix` tasks, Harbor **runs**, boot/smoke of Arvo,
  PRs into `arvo/`.
- Minting `FND`, `REC`, `DEC`, `SPK`, `PHASE`, `MS`.
- Reminting `REQ-001`…`REQ-047`, `FND-001`…`FND-003`, or any
  taken `RSK` / `OQ` / `EVD` / `REC`.
- Writing an implementation plan, a plan review, or a second
  spec-review.
- Inventing G-006. Merging two leftovers into a new headline.
  Promoting a Watch item.
- “Clarifying” G-004 into online improvement, or G-005 into a
  nested planner.
- Opening intake. Re-sorting SORT. Reading Watch dump files.
- Adding MCP, Horde, Oban, libcluster, OTP relups, or LiveView
  as architecture, including as a “fix.”
- A parallel vocabulary (“agent OS,” “control plane”) as
  architecture.
- Treating Watch as a failure; raiding Watch to look busy.
- Treating “in the Arvo tree” as “works.”
- Inventing a Harbor number as if this lab ran one.
- Amending Blueprint §7 or rewriting the Blueprint §5 table
  *in the Blueprint file*. Annotating the **specification’s**
  §5 restatement is required for `FND-001`.
- Folding `REQ-037` / `REQ-039` unless you judge it
  simplification with no subject change. The review named that
  fold as **preference**, not a finding. Default: keep both.
- Marking `spec-revision` accepted.
- Touching `ore/` unless the owner says so.

## Primary research question

What is the corrected specification?

## Subsidiary questions

1. **One G-004 leftover-test keep bar (`FND-001`).** After
   revision, can a later operator keep or discard a tagged run
   without choosing among improve / not-collapse / honesty-only?
2. **Complete G-004 judge-tree diff (`FND-002`).** Does the
   named read-only list match score-harness §8.2’s No rows that
   bind the organism, including `instruction.md`, the frozen
   task list, Oracle `solution/`, and leftover-test identity as
   a named G-001/G-002/G-003 suite?
3. **G-005 sequential split in the `REQ` (`FND-003`).** Is the
   V-002 sequential vs parallelizable split a keep/drop in
   `REQ-040` / `REQ-042`, not only a §16 bullet?
4. **Standalone catalog.** Did every other proposed-spec claim
   survive (hosts, cards, Watch, Refuse, fences that were not
   findings)?
5. **Five still five.** Did any correction invent G-006, merge
   G-004 with its cousin, or land the searcher as identity?

## Inheritance contract

Inherit the accepted Charter in full, especially:

- Completion (§19): every minted `FND` has a disposition;
  every `REC` still has a disposition; `SPK` unused; five
  tests still five.
- Spine bar (§10): the spec remains a catalog, not a coding
  spec for this repo.
- Source hierarchy and citation rules (§4–§5).
- Current-information rules (§6). Do not refresh closed
  intake. Re-open an already-cited official page only if a
  load-bearing sentence in the *revision’s use of it* is thin;
  date it.
- Spike rule (§7): **none here**. “Deferred to a bounded
  evidence spike” is not a legal disposition in this repo.
- Confidence model (§11): High is rare. Do not raise a
  leftover-sings / holdout-would-rise claim to High.
- Anti-patterns (§18).

Inherit Blueprint §5 (five tests), §6 (non-goals), §7
(locks), §11 spec-revision row, §15 `REQ` range, §16
catalog-authority reading, §21 completion readings, §22
handoff expectation.

Inherit the **proposed specification in full**, including
§22 `REQ-001`…`REQ-047`, §23 traceability, §24–§27 registers,
and §28’s 38-row Recommendation Disposition Ledger.

Inherit the **accepted review in full**, including the
Attacks attempted table (ten “no defect” rows stay no defect
unless a finding already named them), the Conditional gate,
and “no extra review round.”

Inherit **full** accepted reports, not only digests. Digests
must not replace source files. Score-harness §8.2 and
`REC-200` / `REC-201` / `REC-203` are load-bearing for the
three findings.

## Finding dispositions

Every minted `FND-###` receives **exactly one** of:

| Disposition | When to use |
| ----------- | ----------- |
| Accepted | Integrate the finding’s required correction. Prefer the Proposed Specification Diff. |
| Accepted with modification | Same hole closed; wording differs. State the modification. Still meet the finding’s Acceptance Evidence. |
| Rejected | Cited reason that still preserves Blueprint §7 **and** still leaves the catalog usable. For `FND-001`, rejection is legal only if you still produce **one** leftover-test keep bar. |
| Deferred to a bounded evidence spike | **Not available in this repo.** Do not use. |
| Not applicable | Another accepted correction already removes the cause. Name that correction. Do not use this to hide a row. |

No finding may disappear silently. Findings remain
traceability items; they do not automatically become new
`REQ` numbers.

### Minted findings (do not re-derive)

Full text lives in the accepted review. Proposed diffs are
quoted here so this prompt is self-contained. Apply them
against the proposed specification at `26bd0e4`.

#### `FND-001` — High — G-004 leftover-test keep/drop is three rules

Three sentences currently in force:

1. Proposed spec five-test restatement, row 4 try-column:
   “Leftover tests must also **improve**” (Blueprint §5 try).
2. Proposed spec §16: “Leftover G-001…G-003 measures must not
   **collapse**” (`REC-200` later measure).
3. `REQ-034` keep sentence: holdout rises, no verifier edits,
   no tokens/time win, no **honesty collapse**. Leftover
   G-001…G-003 are **absent** from that keep sentence.

**Required correction (review):** make `REQ-034` the single
keep rule. Put leftover G-001…G-003 on that rule as **must
not collapse**. Annotate the spec’s §5 restatement so “must
also improve” is the *try*, not a second keep gate. Make §16
use the same sentence as `REQ-034`. Do not add a sixth test.
Do not merge G-004 with its cousin. Do not amend Blueprint §7.

**Proposed diff (review):**

In `REQ-034` Requirement, replace the keep sentence with:

> Keep the *loop* if holdout rises without verifier edits,
> without “more tokens / more time” as the win, without
> honesty collapse, and without leftover G-001 liveness,
> G-002 isolation, or G-003 swap measures collapsing. Drop
> if it only Goodharts three tasks.

In §16, replace “Leftover G-001…G-003 measures must not
collapse” with the same sentence (or a pointer to `REQ-034`).

Under the §5 row-4 try-column, add one note, not a sixth
column:

> “Leftover tests must also improve” is the try. The keep
> rule is `REQ-034`: leftover G-001…G-003 measures must not
> collapse. A required rise of every leftover measure is not
> a keep gate.

Expected disposition: **Accepted** (or Accepted with
modification that still names one bar). This is the High
finding that made the gate Conditional. Leaving three verbs
in force leaves Implementation status blocked.

Do **not** promote the try-column “must also improve” to the
keep rule. Blueprint’s own keep/drop cell does not require a
rise. A required rise of every leftover measure would replace
the score-harness bar.

#### `FND-002` — Medium — G-004 judge-tree read-only list is short

Proposed `REQ-035` / §16 omit objects score-harness §8.2
already treated as No: `instruction.md`, the frozen task
list, `solution/solve.sh` (Oracle), leftover-test identity as
a *named* G-001/G-002/G-003 suite that cannot be renamed or
dropped mid-run.

The defect is the **diff checklist**, not an authorization to
write those files. Writable set stays the same four:
constitution, compact-strategy module, tool list, observe-only
hooks. Do not add Harbor `environment/` or other objects the
accepted report did not name as judge-tree.

**Proposed diff (review):**

In `REQ-035` Requirement, after the current MUST NOT
sentence, add:

> The judge tree the later repo MUST diff before vs after
> every trial is: Harbor `tests/`, `task.toml` `[verifier]`,
> `instruction.md`, the frozen task list, the holdout,
> `solution/solve.sh` (Oracle; not a mutation target),
> leftover-test identity, and `program.md`. Leftover-test
> identity means the named G-001 liveness, G-002 isolation,
> and G-003 swap measures. Those measures MUST NOT be
> renamed or dropped during a tagged run. Any write to the
> judge tree → crash / discard, not keep.

Mirror that list in §16’s Read-only bullet. Leave the
Writable bullet unchanged.

Expected disposition: **Accepted**. Independent of `FND-001`
(do not merge the findings). Shared-mode remains a named
hole. Regrade-after-run remains distinct from mid-search
grader edit. No invented Harbor number.

#### `FND-003` — Medium — G-005 dropped the sequential vs parallelizable split

`REC-203` was Accepted into `REQ-040` / `REQ-042`, but the
keep/drop omitted: split sequential vs parallelizable tasks
(V-002); drop if sequential tasks regress. §16 already names
the split as a method bullet without a keep/drop.

**Proposed diff (review):**

In `REQ-040` Requirement, after “One specialist family per
run tag,” add:

> The later repo MUST split sequential vs parallelizable
> tasks (V-002). A specialist that helps only parallelizable
> work and regresses sequential tasks MUST NOT be recorded
> as a blanket keep.

In `REQ-042` keep sentence, add the same drop next to the
org-chart drop. Leave §16’s split bullet; make it point at
the `REQ`.

Expected disposition: **Accepted**. Do not make sequential
success a second G-005 primary. Do not blend scout / critic /
planner into a committee. Do not merge G-005 with G-004.
Nested-prompt drop (`REQ-041`), three arms, and local-may-lose
stay.

### Reconciliation of overlapping diffs

`FND-001` and `FND-002` both edit §16 G-004. Apply both:
keep sentence + pointer to `REQ-034`, **and** the expanded
read-only list. They do not compete.

`FND-003` edits §16 G-005 only to point at the `REQ`. Leave
the G-004 bullets alone.

If you Accept with modification, the Integrated Correction
Ledger must say what changed from the proposed diff.

## Required requirement identifiers

Use `REQ-001`…`REQ-299` only. Never reuse an ID for a
different subject.

- **Keep** `REQ-001`…`REQ-047` for the same subjects.
- **Amend in place** the four `REQ`s the findings name
  (`REQ-034`, `REQ-035`, `REQ-040`, `REQ-042`) when Accepted.
- Update those `REQ`s’ Verification / Rationale / Acceptance
  Evidence / Source decisions so they cite the `FND` as well
  as the original `REC`.
- **New** `REQ-048`+ only if a finding cannot live in an
  existing `REQ`. Default: none.
- Implementation phase remains `later sibling repo` or
  `catalog only`. Do **not** mint `PHASE-##`.
- Do not remint any `REC`, `RSK`, `OQ`, `EVD`, or `FND`.

IDs already taken (do not reuse):

- `REQ-001`…`REQ-047`
- `REC-001`…`REC-011`, `REC-100`…`REC-115`, `REC-200`…`REC-210`
- `RSK-001`…`RSK-030`
- `OQ-001`…`OQ-018` (`OQ-011` **closed**)
- `EVD-001`…`EVD-028`, `EVD-100`…`EVD-115`, `EVD-200`…`EVD-219`
- `FND-001`…`FND-003`

If you mint a new catalog risk or open question, start at
`RSK-031` / `OQ-019`. Prefer not to. Carry `RSK-030` forward.
If Implementation status becomes catalog authority, update
`RSK-030` mitigation so it still refuses Elixir / tickets
**in this tree** (two-layer status is the mitigation, not
“now we code here”).

Intake IDs `G-` / `H-` / `P-` / `V-` / `XB-` / `LC-` are
citations. Do not reuse those strings as `REQ` numbers.

## Exact revised-specification structure

Replace the placeholder. Keep these headings, **in this
order**. You may add subsections under a numbered heading.
Do **not** replace this spine with a focused-report
19-section shape.

1. Artifact Metadata
2. Revision Summary
3. Finding Disposition Ledger
4. Integrated Correction Ledger
5. Preserved Strengths
6. Executive Decision Summary
7. Authority and Intended Use
8. Problem and Product Definition
9. Goals and Non-Goals
10. Locked Decisions and Invariants
11. Final Technology Stack
12. System Context
13. Architecture
14. Components and Boundaries
15. Data Model
16. Interfaces and Integrations
17. User Workflows
18. Security and Privacy
19. Reliability and Operations
20. Testing and Verification
21. CI and Release
22. Migration (if applicable)
23. Performance Expectations
24. Internal Contracts
25. Dependency Bill of Materials
26. Normative Requirements
27. Traceability
28. Risk Register
29. Open Questions
30. Deferred Work
31. Rejected Work
32. Recommendation Disposition Ledger
33. Definition of Done
34. Updated Implementation Handoff

Then the Completion Checklist from this prompt.

The placeholder file’s heading numbers differ. **This list
wins.** The output is a new standalone file, not a patch on
the skeleton numbers.

### How to fill the revision-specific sections

#### §1 Artifact Metadata

Program, owner, artifact = Revised definitive specification,
subject path + `26bd0e4`, review path + `e00ee9c`, Status
`Proposed — pending independent validation`, Implementation
status per the rule above, requirement range used, findings
dispositioned (`FND-001`…`FND-003`), date, reviser role
(Revision Architect; not the synthesizer; not the reviewer;
not the validator). Two-layer banner: a later human accept
makes this catalog authority; this session does not.

#### §2 Revision Summary

Short. What changed (one leftover-test keep bar; expanded
judge-tree diff list; V-002 split lifted into G-005 `REQ`s)
and what did not (five tests, hosts, Watch, required drops).
Do not dump every `REQ`.

#### §3 Finding Disposition Ledger

One row per minted finding:

| FND | Severity | Disposition | Notes | Surviving REQ(s) |
| --- | -------- | ----------- | ----- | ---------------- |

Three rows. None silent.

#### §4 Integrated Correction Ledger

Where the accepted (or modified) corrections landed: section
+ `REQ` + one-line change. Include the §5 try-vs-keep note
and the §16 mirrors. If you Rejected or marked Not
applicable, say why no section changed.

#### §5 Preserved Strengths

Name what the review already said was intact and that you
kept: five tests; G-004 still a fixed-set loop; G-005 still
its own Session with three arms; Watch stays Watch; required
drops stay dropped; checkout ≠ function; no invented Harbor
number; `OQ-011` closed; 38 `REC` rows; software-first
headings remain catalog readings.

#### §6–§32

Carry the proposed specification’s corresponding sections
forward (its §2–§28). Integrate corrections. Remove
superseded leftover-test verbs so `REQ-034`, the testing
section, and the §5 note do not contradict. Keep the
Recommendation Disposition Ledger at 38 rows; update Notes /
surviving `REQ`s if an amended `REQ` now also cites a `FND`.
Do not silently drop a `REC`.

#### §33 Definition of Done

This *revised* specification is done as a revision artifact
when: every minted `FND` is dispositioned; accepted
corrections are integrated; the file is standalone; five
tests still five; Status is `Proposed — pending independent
validation`; Implementation status is honest; independent
validation and human accept are **not** claimed here.

#### §34 Updated Implementation Handoff

Next legal substantive stage, **after** human acceptance and
commit of this file, is implementation-plan in a **fresh**
session. That plan sequences hypotheses for the sibling repo.
First later job remains the Arvo smoke check **there**. This
file, once accepted, is authority for what the catalog
claims. It does not authorize Elixir here. Do not start that
plan in this session.

Review recommended **no** extra spec-review round. Do not
commission one.

### How to read software-first headings as a catalog

Same readings as synthesis. Fill every heading honestly. Do
not invent a product architecture to look complete.

| Heading | Catalog reading |
| ------- | ---------------- |
| Final Technology Stack | This repo has no stack. Name the instrument (Arvo checkout + dated OTP / Elixir / Harbor docs from the reports) and that the **sibling repo** is the lab. |
| System Context | Two programs + instrument path + later sibling lab. `ore/` ignored unless the owner says so. |
| Architecture | Five tests + three host primitives + leftover cards + two scoring methods. No parallel vocabulary as architecture. |
| Components and Boundaries | The five tests and their fences, not an Elixir module list. |
| Data Model | Catalog nouns already named: Session JSONL, `results.tsv`, git, `program.md`, Harbor reward files as *later format*. |
| Interfaces | Harbor (or equivalent) as later method; official “separate” verifier. Not APIs this repo ships. |
| User Workflows | Operator of the catalog, then operator of the sibling repo. Not a product UX program. |
| Security and Privacy | G-002 fence (keys, kill-hands, no shared cookie). Not a compliance program. |
| Reliability and Operations | G-001 attach / quit-window. Not an ops program. |
| Testing and Verification | G-004 and G-005 methods. One leftover-test keep bar. Judge-tree diff list complete. Frozen model. One primary before the run. G-005 V-002 split in the `REQ`. |
| CI and Release | Not applicable in this repo. Say so. Sibling repo later. |
| Migration | Copying a *winning file* into `arvo/` is a later product gate, not a migration of users. |
| Performance | Named later measures (prefix-cache break, isolation latency). Not SLOs. |
| Internal Contracts | Catalog invariants (five stay five; judge fence; Watch stays Watch; one G-004 leftover keep bar). |
| BOM | Dated official pages and instrument versions already cited. Do not add fashion. |

## Required tables

- **Finding Disposition Ledger** (three rows).
- **Integrated Correction Ledger.**
- **Five-test restatement** with the `FND-001` try-vs-keep
  note on row 4. Do not add a sixth column. Do not add a
  sixth row.
- **Recommendation Disposition Ledger:** every
  `REC-001`…`REC-011`, `REC-100`…`REC-115`,
  `REC-200`…`REC-210` — still 38 rows, none silent.
- **Traceability:** every `REQ` → sources (`REC` / lock /
  `FND` if amended) → later home.
- **Risk register:** inherited `RSK-001`…`RSK-030` plus any
  new `RSK-031+`.
- **Open questions:** inherited `OQ-001`…`OQ-018` with
  `OQ-011` marked closed; any new `OQ-019+`.
- **Deferred Work** and **Rejected Work** carried forward.

## Methodology

1. Read every required full artifact completely before
   writing.
2. Disposition `FND-001`…`FND-003` in the ledger **before**
   you finish the `REQ` list.
3. Start from the proposed specification. Integrate. Do not
   invent a second catalog.
4. Reconcile overlapping §16 edits. Remove contradictory
   leftover-test verbs.
5. Prefer the review’s proposed diffs. Sharpen fences; do
   not replace claims the review left intact.
6. **Exa via REST** only if a load-bearing sentence in an
   *already-cited* official page is thin in the revision’s
   use of it ([`AGENTS.md`](../../AGENTS.md) Exa section).
   Load `EXA_API_KEY` from gitignored `.env`. Never print
   the key.
   - Ordinary lookup: `POST https://api.exa.ai/search`
     `type` `auto` or `fast`, then open the official URL.
   - **Does not merit Exa:** new arXiv harvest, star counts,
     “what else is hot,” unread Articles, Watch dumps,
     paper shopping, a second research program.
   - Official pages already cited in the three reports, the
     proposed specification, and the review are enough
     unless wording is thin.
   - If the key is missing or the call fails, say so in
     Authority / Intended Use (or a short methodology
     subsection) and continue from the accepted artifacts.
     Do not pretend Exa ran. Do not use Exa MCP.
   - Default expectation: **Exa does not need to run.**
     Document the skip.
7. Record uncertainty. Do not run later measures.
8. Leave no foundational *catalog* decision to the
   implementer unless it is already Watch or a named `OQ`
   that does not block catalog honesty.

## Evidence and citation rules

Inherit Charter §4–§6.

- Portable Markdown links, footnotes, or a short source
  ledger with URLs and access dates. No ephemeral UI tokens.
- Cite the proposed specification (with `26bd0e4`), accepted
  review (with `e00ee9c`), accepted Blueprint (`0b49540`),
  accepted Charter (`081ad36`), the three accepted reports
  (with accepting commits), and already-named official URLs
  **via those artifacts**.
- Do **not** cite this prompt, the attachment manifest,
  chat, or any handoff map as evidence.
- Harbor method page = design insight, not a run this lab
  performed.
- Popularity / star counts are not proof.
- High confidence: lock, dated primary, or an accepted
  finding you are integrating. Hypotheses about holdout
  rising stay Medium or Low.
- You do **not** need a focused-report Evidence Ledger.
  The Finding Disposition Ledger + Integrated Correction
  Ledger + Recommendation Disposition Ledger +
  traceability carry the evidence. Mint new `EVD-###` only
  if you allocate one; then start after `EVD-219`. Prefer
  not to.

## Evidence-spike policy

**None in this repo.** If you are tempted to run Harbor,
boot Arvo, or write Elixir to “see whether the correction is
right,” **stop**. Write the later measure. Do not dispose a
finding as “Deferred to a bounded evidence spike.”

## Comparison and scoring requirements

- Five tests stay five. A leftover card is not a test. A
  layer score is not G-006. A proposer is not G-004.
- G-004 and G-005 stay **split**. Say so on purpose.
- One leftover-test keep bar. Try ≠ keep.
- Scorer / judge tree is read-only. The named diff list
  matches score-harness §8.2’s organism-No rows. Model is
  frozen for a scoring run. One primary declared **before**
  the run. Holdout required. Side stats cannot keep.
- G-005 has three arms. Local / smaller is allowed to lose.
- Sequential vs parallelizable is a slice and a drop, not a
  second primary and not G-006.
- A nested prompt is not a child Session.
- Do not invent a primary Harbor number.
- “Copy the loop into `arvo/`” is refused. A winning *file*
  may later be copied.
- Do not raid leftover Watch cards to look busy.
- Official RLM env / bash on hands is a tool; Port-wrap of a
  *foreign harness* is a shell (`REC-006` vs `REC-103`).

## Anti-patterns

Inherit [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md)
and Charter §18. Especially here:

- Silent finding loss
- Silent recommendation loss (the 38 `REC` rows must survive)
- Chat-history authority; citing this prompt as evidence
- Inventing G-006; leftover card as a test; layer scores as
  G-006
- Merging G-004 with “improves while you use it”
- Promoting the try-column “must also improve” to a keep
- Nested prompt as G-005
- Promoting GEPA/ACE off Watch
- Landing the searcher as Arvo’s identity
- Treating “in the tree” as “works”
- Opening intake / re-sorting / Exa-as-arXiv-dump
- Treating Watch as a failure
- Coding / Harbor run / smoke test
- Plan-as-backlog; minting `PHASE` / `MS` here
- Parallel vocabulary as architecture
- Starting implementation-plan in this session
- Marking the stage accepted
- Evidence-free confidence; High on a hypothesis
- Identifier reuse (ranges listed above)
- Feature ideation disguised as a correction
- Amending Blueprint §7
- Adding Harbor objects the accepted fence did not name
- Using “Deferred to a bounded evidence spike”

## Completion checklist

- [ ] Revised specification exists at
      `docs/specifications/02-definitive-specification-revised.md`
- [ ] All 34 numbered headings present and filled (catalog
      readings, not invented product architecture)
- [ ] Status: `Proposed — pending independent validation`
- [ ] Implementation status honest (`Accepted —
      implementation authority` **or** `Proposed —
      implementation blocked`) with the catalog reading
- [ ] Every minted `FND-001`…`FND-003` dispositioned; none
      silent
- [ ] Accepted corrections integrated in prose, tables, and
      `REQ`s (not only the ledger)
- [ ] One G-004 leftover-test keep bar; try ≠ keep
- [ ] Judge-tree diff list includes `instruction.md`, frozen
      task list, Oracle `solution/`, leftover-test identity
      as named G-001…G-003 suite
- [ ] G-005 V-002 split is a keep/drop in `REQ-040` /
      `REQ-042`
- [ ] `REQ-001`…`REQ-047` retained where the subject is the
      same; new IDs only `REQ-048`+
- [ ] 38 `REC` rows still present; none reminted
- [ ] Five tests still five; no G-006; cards are not tests
- [ ] G-004 and G-005 stay split; cousin not merged
- [ ] Scorer / judge tree read-only; frozen model; one
      primary before the run
- [ ] G-005 has three arms; local may lose; nested prompt is
      a drop
- [ ] `OQ-011` / `REC-111` / `REC-208` stay Watch above
      G-004
- [ ] `REC-112` / `REC-209` stay Watch; not G-006
- [ ] Searcher is not Arvo’s identity
- [ ] First later job includes Arvo smoke check **there**
- [ ] No `SPK-###`; no `PHASE` / `MS`; no Harbor run; no
      Arvo command run as a test
- [ ] Exa used via REST only as allowed, or skip documented
- [ ] Intake not reopened
- [ ] Shared new IDs start at `RSK-031` / `OQ-019` /
      `REQ-048` if minted
- [ ] Plain-language summary shown to Robert
- [ ] Human accepts revised specification — **leave
      unchecked**
- [ ] Independent validation passed — **leave unchecked**
- [ ] Manifest updated; accepting commit recorded — **leave
      unchecked**

## Allowed file scope

**Must write**

- `docs/specifications/02-definitive-specification-revised.md`

**Allowed extras**

- `docs/working/DISCOVERY-NOTES.md` — one pointer line at the
  top (spec-review accepted at `e00ee9c`; this stage is
  spec-revision). Do **not** rewrite the H- dump.
- `research-program.toml` — `last_updated_date` and
  `spec-revision.status` to `awaiting-validation` if you
  finish the file. Do **not** set `accepted`.
- `docs/validations/15-definitive-specification-revised-validation.md`
  only if an *independent* validator writes it
- `docs/handoffs/spec-revision-attachment-manifest.md` if you
  tighten the list you actually used

**Do not edit**

- Accepted Blueprint (except a mechanical link fix)
- Accepted Charter
- The proposed specification
  (`docs/specifications/01-definitive-specification.md`)
- The accepted review
  (`docs/reviews/01-specification-adversarial-review.md`)
- Accepted runtime, leftovers, or score-harness reports
- SORT substance
- implementation-plan, plan-review, or plan-revision
  placeholders (`docs/plans/*`, `docs/reviews/02-*.md`)

## Final response requirements

Plain language to Robert. Do not dump section numbers. Say:

1. The revised specification is filled (path).
2. This repo still only catalogs ideas. You did not write
   Elixir or run Harbor.
3. Every minted finding has a disposition. Say Accepted /
   modified / rejected for `FND-001`, `FND-002`, `FND-003`
   in one line each.
4. There is now one G-004 leftover-test keep bar. G-004 is
   still a fixed-set lab loop. G-005 is still its own
   Session. The cousin is not merged.
5. Implementation status (catalog-authority or blocked) and
   what that means: sibling-repo agenda, not Elixir here.
6. You have **not** accepted the revision.
7. Next after he accepts: implementation-plan in a fresh
   session. Do not write it now.

## Output behavior

Modify only the allowed paths above. Do not modify governing
artifacts or begin downstream stages.
