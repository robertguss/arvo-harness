# Specification Adversarial Review Prompt — arvo-beam-harness-research

- **Artifact ID:** PROMPT-spec-review
- **Program:** arvo-beam-harness-research
- **Stage:** spec-review — Specification Adversarial Review
- **Kind:** adversarial-review
- **Status:** Installed — ready for a fresh execution session
- **Required output:** `docs/reviews/01-specification-adversarial-review.md`
- **Finding range:** `FND-001`…`FND-199`
- **Depends on:** Accepted synthesis
  (`26bd0e4070ef822bdcd5c69d5f57a2a80131176f`); independent
  validation Pass
  (`docs/validations/13-definitive-specification-validation.md`).
  The specification is **proposed catalog**, not implementation
  authority.
- **Contract:** [`program/contracts/adversarial-review.md`](../../program/contracts/adversarial-review.md)
- **Finding shape:** [`program/templates/finding.md`](../../program/templates/finding.md)

> This file commissions the specification adversarial review. It is
> not the review. Do not write a revised specification or any
> implementation plan in the same session. Do not mark `spec-review`
> accepted.

## Role

Act as an adversarial reviewer. Attack; do not add features.
Review is a **separate discipline**. The author is not assumed to
have found the worst flaws. Mechanical validation already
**Passed**. You are not that validator. You attack substance:
thin, merged, over-confident, contradictory, non-total, unsafe
as a catalog, or likely to fail when a later sibling repo treats
this file as the agenda.

Talk to Robert in **plain language** when you finish. The review
itself must still use the required section names.

Reviews are **proposed corrections**, not commandments. Findings
do not become `REQ`s until a later revision stage dispositions
them.

## Mission

Answer:

> Where is the proposed spec thin, merged, or over-confident?

Produce [`docs/reviews/01-specification-adversarial-review.md`](../reviews/01-specification-adversarial-review.md)
as a complete standalone review.

This repo **still only catalogs ideas**. “Blocks implementation”
on a finding means **blocks the sibling repo from treating the
catalog as ready**, not “blocks Elixir in this tree.” There is
still no Elixir, Harbor run, Arvo smoke, or coding backlog
**here**.

Produce a **small number of strong findings**, not a quota. A
tight specification with few findings is a legal outcome.
Preference is not a defect. Attractive subsystems are not
findings.

When the file is filled, show Robert a short plain-language
summary. **Do not** accept the review. **Do not** start
spec-revision.

Status of the filled file: `Proposed — pending independent
validation`.

## Required inputs

Read in the order given in
[`docs/handoffs/spec-review-attachment-manifest.md`](../handoffs/spec-review-attachment-manifest.md).
Governing artifacts in full: accepted Blueprint and accepted
Charter. Then this prompt. Then the **proposed specification in
full**. Then **all three** accepted focused reports **in full**
(not only their Handoff Digests). Then the review skeleton you
will replace. Then the finding template and the review contract.

Charter §17: this review receives all three focused reports in
full.

## Required output path

`docs/reviews/01-specification-adversarial-review.md`

Replace the placeholder skeleton in that path. Do not create a
second filename and call the stage done. Do not write
`docs/specifications/02-*.md` or any plan.

## Authority and precedence

Order: [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).

For this stage, project-specific readings:

1. Accepted `DEC-###` (none exist).
2. Locked constraints in
   [`docs/00-program-blueprint.md`](../00-program-blueprint.md)
   §7, plus the §5 five-test table, §6 non-goals, §11
   **spec-review** row, §15 `FND-001`…`FND-199`, and §22
   searcher-is-not-identity.
3. Normative rules in
   [`docs/01-research-charter.md`](../01-research-charter.md),
   especially §15 review attacks, §10 spine bar for reviews,
   §11 confidence, and §18 anti-patterns.
4. **This prompt.**
5. There is **no** accepted revised specification. The file you
   attack
   ([`docs/specifications/01-definitive-specification.md`](../specifications/01-definitive-specification.md),
   human-accepted as synthesis output at
   `26bd0e4070ef822bdcd5c69d5f57a2a80131176f`) is **Proposed —
   pending adversarial review**. It is not implementation
   authority. A later revised specification becomes authority
   for **what the catalog claims**, still not for Elixir here.
6. Accepted reports as **evidence and recommendations**, not a
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
     G-005 methods; `OQ-011` already closed.
7. Independent validation
   ([`docs/validations/13-definitive-specification-validation.md`](../validations/13-definitive-specification-validation.md))
   is a **mechanical Pass**. Use it as a map of what was
   already checked. Its non-blocking observations are
   inspection points, not findings you must ratify.
8. Framing evidence: Graduate table of
   [`docs/working/SORT.md`](../working/SORT.md); locked top of
   [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md).
   These do **not** outrank the Blueprint. Do not re-sort.
9. `research-program.toml` is an index only.
10. This prompt, the attachment manifest, and any handoff map
    are **maps**. Do not cite them as evidence in the review.
11. Chat history and model memory are not authority.

A later specification may not secretly amend Blueprint §7.
“In the Arvo tree” is a checkout description, not a finding
that a scorer or feature works. A Harbor method page is design
insight, not a result this lab has run.

## Locked context (do not re-litigate)

From the accepted Blueprint §7, the accepted Charter, and the
accepted specification. Detail stays there.

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

Score-harness already answered questions this review must
**not** reopen as if they were still open:

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

You **may** find that the specification failed to *preserve*
one of these locks. That is an attack. You may **not** argue
the lock itself should change.

## Stage boundary

### Included

- One adversarial review of the **proposed** specification.
- Attempt every required attack below. Record the attempt.
- Mint `FND-001`…`FND-199` only, and only for real defects.
- Concrete failure scenarios and required corrections.
- Proposed specification diffs inside findings (text, not a
  new spec file).
- An implementation-gate recommendation with the catalog
  reading of “implementation.”
- Whether a risk-triggered extra review round is warranted.
- Status: `Proposed — pending independent validation`.

### Excluded

- Coding, `mix` tasks, Harbor **runs**, boot/smoke of Arvo,
  PRs into `arvo/`.
- Minting `REQ`, `REC`, `DEC`, `SPK`, `PHASE`, `MS`, `EVD`,
  `RSK`, or `OQ`. Review mints **`FND` only**. A new risk
  belongs inside a finding, not as `RSK-031`.
- Writing a revised specification or any implementation plan.
- Inventing G-006. Merging two leftovers into a new headline.
  Promoting a Watch item so the review “has something to say.”
- “Clarifying” G-004 into online improvement, or G-005 into a
  nested planner, as a *recommendation*.
- Opening intake. Re-sorting SORT. Reading Watch dump files.
- Harvesting papers. A new literature pass is not a review.
- Adding MCP, Horde, Oban, libcluster, OTP relups, or LiveView
  as architecture, including as a “fix.”
- A parallel vocabulary (“agent OS,” “control plane”) as a
  proposed architecture.
- Treating Watch as a failure; raiding Watch to look busy.
- Treating “in the Arvo tree” as “works.”
- Inventing a Harbor number as if this lab ran one.
- Re-running mechanical validation as if it were this stage.
- Marking `spec-review` accepted.
- Touching `ore/` unless the owner says so.

## Primary research question

Where is the proposed spec thin, merged, or over-confident?

## Subsidiary questions

These are the Charter §15 / Blueprint §11 / specification §30
attacks. Attempt **all** of them.

1. **G-004 collapse.** Did the spec merge the fixed-set lab
   loop with “improves while you use it”? Did any sentence
   drop “fixed test set”? Did the cousin (`REC-205`) leak back
   in through Watch, a card, or a software-first heading?
2. **In the tree ⇒ works.** Did any `REQ` treat a checkout
   description, an Arvo path, or a missing
   `evals/arvo-attention-reread/` directory as a passing
   product or a score?
3. **Sixth test.** Did a leftover card, Translate cluster,
   layer watch, proposer slot, or scoring idea become G-006
   (including by renaming)?
4. **Port-as-native / Elixir-LangGraph.** Did adaptation
   become a shell or a photocopy? Did official-RLM-Port-on-
   hands (`REC-103`) get collapsed into Port-wrap-of-a-
   foreign-harness (`REC-006`)?
5. **Plan-as-backlog / this-spec-as-tickets-here.** Did
   `REQ-001`…`REQ-047` read as tickets in *this* repo
   (`RSK-030`)? Did any heading mint `PHASE` / `MS`? Did
   “implementation-ready” get the software-first contract
   reading instead of the catalog reading?
6. **Opened intake or daily-driver drift.** Did the spec
   scrape again, invent new arXiv IDs, or write as if Robert
   relies on Arvo?
7. **Judge eaten.** Can the harness edit the scorer, the
   holdout, leftover-test identity, or `program.md` under
   G-004? Is Harbor **shared** default treated as honest?
8. **Helper is a prompt.** Is G-005 a nested persona with a
   process id taped on? Are the three arms actually required?
   May local lose?
9. **Searcher as Arvo’s identity.** Did the loop land as the
   product? Is copy-the-loop refused and copy-a-winning-file
   still the later gate?
10. **Invented Harbor number.** Did the spec treat a method
    page, a `reward.txt` format, or a missing evals path as a
    result this lab produced?

Also ask, because Blueprint §11 names them:

11. **Thin.** Can a later sibling-repo operator run the agenda
    without inventing a host noun, a fence, or a keep/drop?
    Are software-first headings honest catalog readings, or
    empty in a way that invites a later agent to invent a
    product architecture?
12. **Merged.** Did synthesis silently drop a material `REC`
    nuance when it Accepted, Accepted-as-rejection, or Merged
    a row? Especially `REC-111`+`REC-208` and
    `REC-112`+`REC-209`.
13. **Over-confident.** Did any “would work” / “holdout would
    rise” / leftover-sings-on-BEAM claim rise to High?
    Reports said those stay Medium or Low.

## Inheritance contract

Inherit the accepted Charter in full, especially:

- Review rules (§15): separate discipline; small number of
  strong findings; required attacks; no feature ideation;
  `FND-001`…`FND-199` only; findings are proposed
  corrections.
- Spine bar (§10): findings attack G-004/cousin merge, “in
  the tree ⇒ works,” Port-as-native, plan-as-backlog, and
  opened intake. Reviews do not add attractive subsystems.
- Confidence model (§11): High is rare. Do not raise a
  finding’s confidence to High on a taste judgment.
- Source hierarchy and citation rules (§4–§5).
- Current-information rules (§6). Do not refresh closed
  intake. Re-open an already-cited official page only if a
  load-bearing sentence in the *specification’s use of it*
  is thin; date it.
- Spike rule (§7): **none here**.
- Anti-patterns (§18).

Inherit Blueprint §5 (five tests), §6 (non-goals), §7
(locks), §11 spec-review row, §15 `FND` range, §21
completion readings, §22 handoff expectation.

Inherit the proposed specification in full, including §22
`REQ`s, §23 traceability, §24–§27 registers, §28 disposition
ledger (38 rows), and §30’s own attack list.

Inherit **full** accepted reports, not only digests. Digests
must not replace source files. Reports §13–§14 (weak and
conflicting evidence) are load-bearing for the
over-confidence attack.

## Required finding identifiers

Use `FND-001`…`FND-199` only. Never reuse. Number sequentially
from `FND-001` with no reserved gaps. Do not mint `FND-200+`
(those belong to plan-review).

Every finding uses [`program/templates/finding.md`](../../program/templates/finding.md)
and fills **all** of:

- Severity, Confidence, Category, Affected sections,
  Affected requirements, Affected phases, Blocks
  implementation
- Problem, Evidence, Failure Scenario, Impact, Root Cause,
  Required Correction, Proposed Specification Diff,
  Acceptance Evidence, Alternatives Considered, Residual
  Risk, Related Findings

Read those fields this way:

| Field | This program |
| ----- | ------------ |
| Severity | Contract table. Critical = catalog cannot be used as the sibling-repo agenda. High = a named host, fence, or keep/drop is invalid. Medium = must be fixed before the *affected catalog claim* is treated as settled. Low = should be corrected in revision; does not block early catalog use. |
| Confidence | Charter §11. High only for a lock violation you can point at, or a dated primary contradiction. Taste is Low. |
| Category | Name the attack (G-004 collapse, tree-as-works, sixth test, Port-as-native, plan-as-backlog, opened intake, judge eaten, helper-is-a-prompt, searcher-as-identity, invented Harbor number, thin, merged, over-confident, contradiction). |
| Affected phases | Write `none (no PHASE minted)` unless you are pointing at informal “phase-2” prose. Do **not** mint `PHASE-##`. |
| Blocks implementation | Entire catalog-as-agenda / Named later job (e.g. G-004 method) / No. Never “blocks Elixir in this tree.” |
| Proposed Specification Diff | The text change a later revision should consider. Not a new file. |
| Alternatives Considered | Include “not a defect / preference.” If that alternative wins, **do not mint the finding**. |

Do **not** remint `REQ-001`…`REQ-047`. Cite them as affected.
Do **not** remint any `REC`, `RSK`, `OQ`, or `EVD`.

IDs already taken (do not reuse):

- `REQ-001`…`REQ-047`
- `REC-001`…`REC-011`, `REC-100`…`REC-115`, `REC-200`…`REC-210`
- `RSK-001`…`RSK-030`
- `OQ-001`…`OQ-018` (`OQ-011` **closed**)
- `EVD-001`…`EVD-028`, `EVD-100`…`EVD-115`, `EVD-200`…`EVD-219`

## Exact review structure

Keep these headings, in this order (skeleton
[`docs/reviews/01-specification-adversarial-review.md`](../reviews/01-specification-adversarial-review.md)):

1. Artifact Metadata
2. Review Scope and Method
3. Executive Assessment
4. Findings
5. Cross-Cutting Issues
6. Implementation Gate Recommendation
7. Whether an Additional Review Round Is Recommended

Then the Completion Checklist from the skeleton, specialized
as in this prompt.

You may add subsections under a numbered heading.

### Section 1 — Artifact Metadata

Program, subject path, subject accepting commit (`26bd0e4`),
subject status (`Proposed — pending adversarial review`; not
implementation authority), review status (`Proposed —
pending independent validation`), finding range used, date,
reviewer role (adversarial; not the synthesizer; not the
validator).

### Section 2 — Review Scope and Method

What you read (full vs skim). What you did not read (Watch
dumps, unread Articles, Arvo boot). Exa: REST skip or dated
refresh, never MCP.

Include an **Attacks attempted** table with one row per
subsidiary question above:

| Attack | Result | Finding or “no defect” |
| ------ | ------ | ---------------------- |
| G-004 collapse | Defect / No defect | `FND-###` or — |

“No defect” is a legal result. Do not mint a decorative
finding to fill the cell.

### Section 3 — Executive Assessment

Plain, short. Is the catalog coherent enough to revise? What
is the worst failure mode if a later repo treated this file
as the agenda tomorrow? Do **not** dump every finding.

### Section 4 — Findings

Zero or more `FND-###` sections. Strong ones only.

### Section 5 — Cross-Cutting Issues

Contradictions across prose, `REQ`s, tables, disposition
ledger, and the three reports. Workflows end to end
(catalog operator vs sibling-repo operator; G-004
keep/discard/crash; G-005 three-arm sweep). Failure,
cancellation, rollback, cleanup of a later trial — only as
catalog completeness, not as an ops program. Attempt to
delete unnecessary machinery: say what you would delete and
whether that is a finding or a preference.

### Section 6 — Implementation Gate Recommendation

- **Gate:** Open | Conditional | Blocked
- **Rationale:**

Read the gate as **catalog-as-agenda**, not Elixir-here:

| Gate | When |
| ---- | ---- |
| Open | No Critical or High findings. Low findings may wait. A later revision can be thin. |
| Conditional | One or more High findings. Spec-revision must disposition them before the catalog is ready as the sibling-repo agenda. |
| Blocked | One or more Critical findings, or a contradiction that makes the five tests or a required fence unusable. |

This stage does **not** open a coding gate in this tree.
Even **Open** still means “ready for spec-revision,” not
“write Elixir.”

### Section 7 — Additional review round

Inherit the contract’s risk-triggered policy. Not automatic.
Recommend another spec-review round only if this review
itself introduces major new machinery (it must not), or if
you found restructuring so large that a second pass after
revision is safer. A normal spec-revision is the default
next stage. Do not start an endless loop.

## Specific inspection points (not pre-minted findings)

Inspect these. Mint a finding **only** if you judge a real
defect. Independent validation already listed several as
non-blocking observations. You may upgrade, downgrade, or
leave them as “no defect.”

1. **Watchlist `REQ` priority.** `REQ-043`…`REQ-046` are
   Priority **Must**. The normative text is *MUST stay
   Watch*, not *MUST implement GEPA / layers / meta-search*.
   Is that honest, or does Must-on-a-Watch-shelf launder a
   feature into the agenda?
2. **Twenty-three Watch clusters as a group.** §26 has one
   row pointing at `REC-114` rather than reprinting 23
   names. Silent drop, or legal grouping?
3. **Optional cards dual-listed.** `REC-007`, `REC-104`,
   `REC-107`, `REC-110` are Accepted as May and also listed
   under Deferred Work. Contradiction, or Allowed-as-optional?
4. **Shortened inherited `OQ`s.** `OQ-003` and `OQ-017`
   drop parenthetical examples from the reports. Material
   loss, or harmless compression?
5. **Operator care omitted.** Blueprint §5 table has an
   “Operator care” column. The spec restatement omits it.
   The synthesis prompt asked for plain name, SORT, later
   measure, keep/drop, land in `arvo/?` — not that extra
   column. Defect, or in-scope restatement?
6. **Human-acceptance banner.** Header says a human accepted
   the draft on 2026-08-15 **and** status remains Proposed
   and not implementation authority. Confusing enough to
   trigger `RSK-030`, or correctly two-layered?
7. **Software-first headings §7–§19.** Honest “not a product
   stack / no CI here / no SLOs,” or thin in a way that a
   later agent will invent architecture? The contract says
   a spec must be “implementation-ready”; this program
   reads that as **catalog-ready**. Attack the wrong
   reading, not the lock.
8. **Merged Watch pairs.** Did merging `REC-111`+`REC-208`
   into `REQ-043`, and `REC-112`+`REC-209` into `REQ-044`,
   drop a nuance the reports still need (organism ≠
   searcher ≠ judge; watches cannot keep unless declared
   primary)?
9. **Confidence laundering.** Reports: every “would work” /
   “holdout would rise” / leftover-sings claim is Medium or
   Low. Spec `REQ-009` says High is rare. Did any other
   `REQ` or prose sentence treat a hypothesis as settled?
10. **Official RLM Port vs foreign-harness shell.**
    `REQ-025` vs `REQ-016`. Still distinct?
11. **Judge fence totality.** `REQ-035` / §16: Harbor
    `tests/`, `task.toml` `[verifier]`, holdout,
    leftover-test identity, `program.md` read-only. Writable
    only named harness files. Any hole?
12. **G-005 testability.** Can a later operator tell a child
    Session from a nested prompt using only the spec
    (`REQ-040`, `REQ-041`, §16)? Parent must not import the
    child transcript; child cannot `start_turn` on the
    parent. Enough, or theater?
13. **First later sequence.** §16 names smoke-check **there**,
    then G-001…G-005 in an order a later plan will name.
    Informal “phase-2” prose is inherited. Did it mint a
    `PHASE` or smuggle a backlog?
14. **Disposition completeness.** 38 material `REC`s. None
    silent. Report-class Rejected rows Accepted *as
    rejections*. Overturning a Required drop would be a
    synthesis defect — attack that if you see it.

## Methodology

1. Read every required full artifact completely before
   writing.
2. Work the **locked** five tests. Do not invent a sixth,
   including as a proposed fix.
3. Attempt every required attack. Fill the Attacks attempted
   table before you finish Findings.
4. Trace workflows end to end. Check failure, cancellation,
   rollback, and cleanup of a *later* G-004 / G-005 trial as
   catalog completeness.
5. Check consistency across prose, `REQ`s, tables, examples,
   disposition ledger, and the three reports.
6. Attempt to delete unnecessary machinery. If deletion is
   preference, do not mint.
7. **Exa via REST** only if a load-bearing sentence in an
   *already-cited* official page is thin in the
   specification’s use of it
   ([`AGENTS.md`](../../AGENTS.md) Exa section). Load
   `EXA_API_KEY` from gitignored `.env`. Never print the
   key.
   - Ordinary lookup: `POST https://api.exa.ai/search`
     `type` `auto` or `fast`, then open the official URL.
   - **Does not merit Exa:** new arXiv harvest, star counts,
     “what else is hot,” unread Articles, Watch dumps,
     paper shopping, a second research program.
   - Official pages already cited in the three reports and
     the specification are enough unless wording is thin.
   - If the key is missing or the call fails, say so in
     Review Scope and Method and continue from the accepted
     artifacts. Do not pretend Exa ran. Do not use Exa MCP.
   - Default expectation: **Exa does not need to run.**
     Document the skip.
8. Record uncertainty. Do not run later measures.
9. Prefer a small number of strong findings.

## Evidence and citation rules

Inherit Charter §4–§6.

- Portable Markdown links, footnotes, or a short source
  ledger with URLs and access dates. No ephemeral UI tokens.
- Cite the proposed specification (with `26bd0e4`), accepted
  Blueprint (`0b49540`), accepted Charter (`081ad36`), the
  three accepted reports (with accepting commits), and
  already-named official URLs **via those artifacts**.
- Do **not** cite this prompt, the attachment manifest,
  chat, or any handoff map as evidence.
- Harbor method page = design insight, not a run this lab
  performed.
- Popularity / star counts are not proof.
- High confidence on a finding: lock violation you can
  quote, or a dated primary contradiction. Hypotheses stay
  Medium or Low.
- You do **not** need a focused-report Evidence Ledger.
  Findings carry their own Evidence field. Mint no `EVD`.

## Evidence-spike policy

**None in this repo.** If you are tempted to run Harbor,
boot Arvo, or write Elixir to “see whether the finding is
right,” **stop**. Write the later measure inside the
finding’s Acceptance Evidence / Residual Risk.

## Comparison and scoring requirements

- Five tests stay five. A leftover card is not a test. A
  layer score is not G-006. A proposer is not G-004.
- G-004 and G-005 stay **split**. A finding that “fixes”
  them by merging them is a defect in the *review*.
- Scorer / judge tree is read-only. Model is frozen for a
  scoring run. One primary declared **before** the run.
  Holdout required. Side stats cannot keep.
- G-005 has three arms. Local / smaller is allowed to lose.
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

- Review as feature ideation
- Mechanical review application (you are not minting
  findings so a later revision has rows)
- Endless review loops
- Silent recommendation loss (attack it in the spec; do not
  commit it in the review)
- Chat-history authority; citing this prompt as evidence
- Inventing G-006; leftover card as a test; layer scores as
  G-006
- Merging G-004 with “improves while you use it”
- Nested prompt as G-005
- Promoting GEPA/ACE off Watch
- Landing the searcher as Arvo’s identity
- Treating “in the tree” as “works”
- Opening intake / re-sorting / Exa-as-arXiv-dump
- Treating Watch as a failure
- Coding / Harbor run / smoke test
- Plan-as-backlog; minting `PHASE` / `MS` here
- Parallel vocabulary as architecture
- Starting spec-revision in this session
- Marking the stage accepted
- Evidence-free confidence; High on a hypothesis
- Identifier reuse (ranges listed above)
- Preference as defect

## Completion checklist

- [ ] Review exists at
      `docs/reviews/01-specification-adversarial-review.md`
- [ ] All 7 numbered headings present and filled
- [ ] Status: `Proposed — pending independent validation`
- [ ] Attacks attempted table covers every required attack
- [ ] Findings use `FND-001`…`FND-199` only; sequential; all
      template fields filled
- [ ] Concrete failure scenarios and required corrections
- [ ] No feature ideation disguised as defects
- [ ] Five tests still five in every proposed diff; no G-006
- [ ] Proposed diffs do not merge G-004 with its cousin
- [ ] Proposed diffs do not land the searcher as identity
- [ ] `OQ-011` remains closed; Watch shelves remain Watch
      unless a finding *shows* the spec promoted them
- [ ] No `REQ` / `REC` / `RSK` / `OQ` / `EVD` / `SPK` /
      `PHASE` / `MS` minted
- [ ] No Harbor run; no Arvo command run as a test
- [ ] Exa used via REST only as allowed, or skip documented
- [ ] Intake not reopened
- [ ] Plain-language summary shown to Robert
- [ ] Human accepts review — **leave unchecked**
- [ ] Independent validation passed — **leave unchecked**
- [ ] Manifest updated; accepting commit recorded — **leave
      unchecked**

## Allowed file scope

**Must write**

- `docs/reviews/01-specification-adversarial-review.md`

**Allowed extras**

- `research-program.toml` — `last_updated_date` and
  `spec-review.status` to `awaiting-validation` if you
  finish the file. Do **not** set `accepted`.
- `docs/validations/14-specification-adversarial-review-validation.md`
  only if an *independent* validator writes it
- `docs/handoffs/spec-review-attachment-manifest.md` if you
  tighten the list you actually used

**Do not edit**

- Accepted Blueprint (except a mechanical link fix)
- Accepted Charter
- The proposed specification
  (`docs/specifications/01-definitive-specification.md`)
- Accepted runtime, leftovers, or score-harness reports
- SORT substance
- spec-revision, plan, or plan-review placeholders
  (`docs/specifications/02-*.md`, `docs/plans/*`,
  `docs/reviews/02-*.md`)

## Final response requirements

Plain language to Robert. Do not dump section numbers. Say:

1. The review is filled (path). How many findings, and the
   worst severity.
2. The implementation gate (Open / Conditional / Blocked)
   and what that means: catalog-as-agenda, not Elixir here.
3. Whether G-004 stayed a fixed-set loop and G-005 stayed
   its own Session in the spec you attacked.
4. You have **not** accepted the review.
5. Next after he accepts: spec-revision in a fresh session.
   Do not write it now.

## Output behavior

Modify only the allowed paths above. Do not modify governing
artifacts or begin downstream stages.
