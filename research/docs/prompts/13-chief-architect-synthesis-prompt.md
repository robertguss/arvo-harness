# Chief Architect Synthesis Prompt — Definitive Specification

- **Artifact ID:** PROMPT-synthesis
- **Program:** arvo-beam-harness-research
- **Stage:** synthesis — Definitive Specification Synthesis
- **Kind:** chief-architect-synthesis
- **Status:** Installed — ready for a fresh execution session
- **Required output:** `docs/specifications/01-definitive-specification.md`
- **Requirement range:** `REQ-001`…`REQ-299`
- **Risk range:** shared `RSK-030`…`RSK-999` (mint from the unused
  bottom only if synthesis finds a *new* catalog risk;
  `RSK-001`…`RSK-029` are already minted)
- **Open-question range:** shared `OQ-019`…`OQ-999` (`OQ-001`…`OQ-018`
  already minted; **`OQ-011` is closed** — do not remint or reopen it)
- **Depends on:** Accepted Charter
  (`081ad36932be7f3f0df062b592cc306c49f72af4`); accepted runtime
  (`636123f1a628803aa4ae2c44fc4659d167a80693`); accepted leftovers
  (`9698362dbe5f90ff48e7aa1093d547d2e14d410a`); accepted
  score-harness (`c15dd31c44c197340d2b339657eb7f072f066d44`)
- **Contract:** [`program/contracts/synthesis.md`](../../program/contracts/synthesis.md)
- **Specification contract:** [`program/contracts/definitive-specification.md`](../../program/contracts/definitive-specification.md)
- **Requirement shape:** [`program/templates/requirement.md`](../../program/templates/requirement.md)

> This file commissions the proposed specification. It is not the
> specification. Do not write spec-review, a revised spec, or any
> implementation plan in the same session. Do not mark `synthesis`
> accepted.

## Role

Act as Chief Architect. Synthesis is **decision-making**, not
summarization. Combine the accepted Charter and the three accepted
reports into **one** catalog-shaped specification. Resist a sixth
headline, an online improver, a nested planner, Elixir in this tree,
and any parallel vocabulary (“agent OS,” “control plane”) sold as
architecture.

Talk to Robert in **plain language** when you finish. The specification
itself must still use the contract’s section names.

## Mission

Answer:

> What single catalog-shaped specification do the three accepted
> reports support?

Produce [`docs/specifications/01-definitive-specification.md`](../specifications/01-definitive-specification.md)
as a complete standalone proposed specification.

This repo **still only catalogs ideas**. Convert catalog claims to
`REQ-001`…`REQ-299`. Those requirements say **what the catalog
claims**, not tickets in this repo. Do not write Elixir. Do not run
Harbor. Do not boot Arvo. Do not mint `SPK-###`. Do not invent G-006.
Do not mint `PHASE-##` or `MS-###` (those belong to the later
implementation-plan stage).

When the file is filled, show Robert a short plain-language summary.
**Do not** accept the specification. **Do not** start spec-review.

Status of the filled file: `Proposed — pending adversarial review`.

## Required inputs

Read in the order given in
[`docs/handoffs/synthesis-attachment-manifest.md`](../handoffs/synthesis-attachment-manifest.md)
and the root [`HANDOFF.md`](../../HANDOFF.md). Governing artifacts in
full: accepted Blueprint and accepted Charter. Then this prompt. Then
**all three** accepted reports **in full** (not only their Handoff
Digests). Then the specification skeleton you will replace.

## Required output path

`docs/specifications/01-definitive-specification.md`

Replace the placeholder skeleton in that path. Do not create a second
filename and call the stage done. Do not write
`docs/specifications/02-*.md`, any plan, or any review.

## Authority and precedence

Order: [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).

For this stage, project-specific readings:

1. Accepted `DEC-###` (none exist).
2. Locked constraints in
   [`docs/00-program-blueprint.md`](../00-program-blueprint.md) §7,
   plus the §5 five-test table, §6 non-goals, §11 synthesis row, and
   §22 searcher-is-not-identity.
3. Normative rules in
   [`docs/01-research-charter.md`](../01-research-charter.md),
   especially §14 synthesis rules and §10 spine bar.
4. **This prompt.**
5. There is **no** current accepted specification. You are writing
   the first proposed one.
6. Accepted reports as **evidence and recommendations**, not a second
   Blueprint. They do not secretly amend §7.
   - Runtime
     ([`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md),
     `636123f1a628803aa4ae2c44fc4659d167a80693`): host nouns
     G-001…G-003 and required drops.
   - Leftovers
     ([`docs/reports/11-leftovers-research-report.md`](../reports/11-leftovers-research-report.md),
     `9698362dbe5f90ff48e7aa1093d547d2e14d410a`): pattern cards;
     Watch stays Watch; Refuse stays refused.
   - Score-harness
     ([`docs/reports/12-score-harness-research-report.md`](../reports/12-score-harness-research-report.md),
     `c15dd31c44c197340d2b339657eb7f072f066d44`): G-004 / G-005
     scoring methods; `OQ-011` already answered.
7. Framing evidence:
   [`docs/working/SORT.md`](../working/SORT.md) Graduate table (do
   not re-sort); locked top of
   [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md).
   These do **not** outrank the Blueprint.
8. `research-program.toml` is an index only.
9. Root `HANDOFF.md`, this prompt, and the attachment manifest are
   **maps**. Do not cite them as evidence in the specification.
10. Chat history and model memory are not authority.

A later specification may not secretly amend Blueprint §7. “In the
Arvo tree” is a checkout description, not a finding that a scorer or
feature works. A Harbor method page is design insight, not a result
this lab has run.

## Locked context (do not re-litigate)

From the accepted Blueprint §7 and the accepted Charter. Detail stays
there.

1. Personal lab. Catalog only in this repo.
2. Five headline tests `G-001`…`G-005`. No sixth. Drop none.
3. Intake is closed. Do not dump more papers. Do not re-sort.
4. No spikes, evals, Harbor runs, smoke tests, or PRs into Arvo
   **here**.
5. Arvo is the instrument in `../coding-agent-harness/arvo`, not a
   daily driver. “In the tree” ≠ “works.”
6. Adaptation, not photocopy, not “refuse every rewrite.” A
   Port-wrapped foreign harness is a shell.
7. Central insight: TypeScript/Python papers specify OTP, then fake
   an OS. Circle the Erlang noun; keep the *new* leftover.
8. **G-004 is a lab loop on a fixed test set.** Frozen model. Scorer
   / judge tree read-only. One primary number declared **before** the
   run. Writable: named harness files. Human owns `program.md`.
   **Not** “improves while you use it.”
9. **G-005 helpers are specialized** (scout / critic / planner) as
   their **own Session**. Three arms: none / parent-model /
   smaller-or-local. Local may lose. A nested prompt with a pid taped
   on is a drop.
10. The G-004 loop does **not** become Arvo’s identity. A winning
    file may later be copied. The loop stays in the sibling repo.
11. Rigor is **focused**. Replication off. `SPK-###` unused here.
12. Phase-2’s first job includes an Arvo smoke check — **there**, not
    here.
13. Most intake stays on Watch on purpose. Cards are not tests.

Score-harness already answered questions synthesis must **not**
reopen:

- **`OQ-011`:** yes, a proposer slot exists *above* G-004
  (`REC-208`). Leftovers **`REC-111`** (GEPA/ACE) stays Watch. Not
  an online improver. Not G-006.
- **`REC-112` / `REC-209`:** a later judge may *watch* honesty,
  stub/reuse, isolation, kill-Focus-lives. Stay Watch. Not G-006.
  No invented Harbor number.
- G-004 and G-005 stay split. Cousin rejected (`REC-205`). Nested
  prompt rejected (`REC-206`). Searcher is not Arvo’s identity
  (`REC-204`, `REC-207`).
- Harbor official docs (2026-08-15): default verifier is **shared**;
  later repo should use **separate** mode (`REC-201`).
- Checkout fact, not a score: `evals/arvo-attention-reread/` is
  **absent** at Arvo `84004e1` (`EVD-214` in the score-harness
  report).

## Stage boundary

### Included

- One catalog-shaped specification from the **three accepted
  reports** + Charter + Blueprint locks.
- Disposition **every** material `REC` listed below. Silent drop is
  a defect.
- Convert accepted catalog claims into `REQ-001`…`REQ-299`.
- Normalize terminology to the five tests and the three host
  primitives.
- High-level first implementation strategy: sibling-repo first
  measurements, starting with the Arvo smoke check **there**. Do
  not mint `PHASE` / `MS`.
- Inherit remaining `RSK-001`…`RSK-029` and `OQ-001`…`OQ-018`
  (`OQ-011` closed). Carry them into the spec’s risk register and
  open-question list, or explicitly mark them inherited-and-still-
  open / closed. Do not remint them.
- Status: `Proposed — pending adversarial review`.

### Excluded

- Coding, `mix` tasks, Harbor **runs**, boot/smoke of Arvo, PRs
  into `arvo/`.
- Minting `SPK-###`, `PHASE-##`, `MS-###`, `FND-###`, or `DEC-###`.
- Writing spec-review, a revised spec, or any implementation plan.
- Inventing G-006. Merging two leftovers into a new headline.
- “Clarifying” G-004 into online improvement, or G-005 into a
  nested planner.
- Promoting GEPA/ACE or layer scores off Watch.
- Opening intake. Re-sorting SORT. Reading Watch dump files.
- Building Elixir-LangGraph, photocopying a paper, Port-as-native.
- MCP, Horde, Oban, libcluster, OTP relups, or LiveView as
  architecture.
- A parallel vocabulary (“agent OS,” “control plane”) as
  architecture.
- Treating Watch as a failure; raiding Watch to look busy.
- Treating “in the Arvo tree” as “works.”
- Inventing a Harbor number as if this lab ran one.
- Marking `synthesis` accepted.
- Touching `ore/` unless the owner says so.

## Primary research question

What single catalog-shaped specification do the three accepted
reports support?

## Subsidiary questions

1. **Catalog shape.** What does this specification *claim* (five
   tests, three hosts, cards, scoring methods, Watch/Refuse), and
   what must it refuse to become (a coding spec for this repo)?
2. **Host nouns.** How do accepted `REC-001`…`REC-011` become
   requirements without renaming G-001…G-003 or weakening the
   required drops (auto-resume, shared cookie, Port-wrap, Mix-in-VM,
   relups)?
3. **Cards.** How do `REC-100`…`REC-110` sit on those hosts as
   cards, not tests? How do `REC-113`…`REC-115` stay method / Watch
   / Refuse?
4. **Scoring.** How do `REC-200`…`REC-207` become the G-004 / G-005
   method without merging the cousin or landing the searcher?
5. **Watch above / beside.** How do `REC-111` / `REC-208` and
   `REC-112` / `REC-209` / `REC-210` stay Watch in the spec?
6. **First later job.** What is the sibling repo’s first
   measurement sequence at *high level*, starting with the Arvo
   smoke check **there**?
7. **Conflicts already resolved.** Ratify the report resolutions
   listed under Locked context. Do not reopen them.

## Inheritance contract

Inherit the accepted Charter in full, especially:

- Synthesis rules (§14): decision-making; every `REC` one
  disposition; no G-006; no Elixir here; preserve §7; normalize
  terms; `REQ`s are catalog claims; first strategy is sibling
  measurements; status `Proposed — pending adversarial review`.
- Spine bar (§10): every material `REC` dispositioned; the spec is
  a catalog, not a coding spec for this repo.
- Source hierarchy and citation rules (§4–§5).
- Current-information rules (§6). Do not refresh closed intake.
  Re-open an already-cited official page only if a load-bearing
  sentence is thin; date it.
- Spike rule (§7): **none here**.
- Confidence model (§11): High is rare. “Would raise holdout”
  stays Medium or Low.
- Anti-patterns (§18).

Inherit Blueprint §5 (five tests + three workstreams), §6
(non-goals), §7 (locks), §11 synthesis row, §15 ID ranges, §21
completion readings, §22 handoff expectation.

Inherit **full** accepted reports, not only digests. Digests must
not replace source files.

## Material `REC`s that must each receive one disposition

Use exactly one of: **Accepted**, **Accepted with modification**,
**Merged**, **Deferred**, **Rejected**, **Superseded**, **Not
applicable**. Record every row in the specification’s
Recommendation Disposition Ledger.

Do **not** remint these IDs. Do **not** silently drop a row.

### Runtime (`REC-001`…`REC-011`)

| REC | Title (cite, do not remint) | Report class |
| --- | --------------------------- | ------------ |
| REC-001 | Name G-001 as attach to a living Session | Required |
| REC-002 | Permanent Session, temporary attach, no halt-on-quit | Default |
| REC-003 | Reject JSONL auto-resume as G-001 | Rejected |
| REC-004 | Thinnest isolation ladder that later passes | Required |
| REC-005 | Reject a shared cookie as a fence | Rejected |
| REC-006 | Reject Port-wrapping a foreign harness as G-002 hands | Rejected |
| REC-007 | Docker node is an optional thicker G-002 rung | Optional |
| REC-008 | Native code and bash live on hands, never on the brain | Default |
| REC-009 | `load_binary` + two versions + `soft_purge`; Mix out; no relups | Required |
| REC-010 | Reject Mix-in-VM and `append_path`-plus-hope as G-003 | Rejected |
| REC-011 | Reject OTP relups as the plugin story | Rejected |

### Leftovers (`REC-100`…`REC-115`)

| REC | Title | Report class |
| --- | ----- | ------------ |
| REC-100 | Surfaces are clients of a living Session | Default |
| REC-101 | Attention as topology, not only a prompt policy | Default |
| REC-102 | Overflow menu: handoff first, workers optional | Default |
| REC-103 | RLM / CodeAct sit on hands, never on Session | Default |
| REC-104 | Worktree is the filesystem fence next to G-002 | Optional |
| REC-105 | ACI is the Hands message language | Default |
| REC-106 | Capability is the pid you were sent | Default |
| REC-107 | One brain, many hands is multiplicity of G-002 | Optional |
| REC-108 | Voyager skills are G-003 payloads that run on hands | Default |
| REC-109 | Prefix cache is a named G-003 cost | Default |
| REC-110 | Replay is a lab method on G-001, not a product | Optional |
| REC-111 | GEPA / ACE stay Watch above G-004 | Watchlist |
| REC-112 | Traces as ore stay Watch beside scoring | Watchlist |
| REC-113 | Adaptation method is the catalog unit, not a test | Required |
| REC-114 | Every Watch cluster stays Watch | Watchlist |
| REC-115 | Every Refuse cluster stays refused | Rejected |

### Score-harness (`REC-200`…`REC-210`)

| REC | Title | Report class |
| --- | ----- | ------------ |
| REC-200 | G-004 is the fixed-set keep/reset loop | Required |
| REC-201 | Judge tree, holdout, and `program.md` are read-only | Required |
| REC-202 | Freeze the model; declare one primary before the run | Required |
| REC-203 | G-005 is an own-Session specialist with three arms | Required |
| REC-204 | The G-004 loop is not Arvo’s identity | Required |
| REC-205 | Reject merging G-004 with “improves while you use it” | Rejected |
| REC-206 | Reject a nested prompt as a G-005 child | Rejected |
| REC-207 | Reject the searcher as product identity | Rejected |
| REC-208 | Name a proposer slot above G-004; leftovers stay Watch | Watchlist |
| REC-209 | A later judge may watch layers; they stay Watch, not G-006 | Watchlist |
| REC-210 | Searcher-meta stays Watch; `program.md` on a slower clock | Watchlist |

### Disposition guidance (judgment, not a second Blueprint)

- A report **Required** keep-shaped `REC` should normally become
  **Accepted** and one or more Must `REQ`s.
- A report **Rejected** shell should normally become **Accepted**
  *as a rejection* (the drop is kept) and a MUST NOT `REQ`. Do
  **not** mark those rows `Rejected` by the synthesizer unless you
  are overturning the report — and overturning a Required drop
  needs an explicit, cited reason that still preserves Blueprint
  §7.
- **Watchlist** rows should normally become **Accepted** as Watch
  (or **Deferred**) and land in Deferred Work, not as Must
  features and not as G-006.
- **Optional** rows may be **Accepted** as optional, **Deferred**,
  or **Merged** into a host `REQ`. Say which.
- **Merged** is legal when two `REC`s state the same catalog claim
  (for example `REC-111` + `REC-208`, or `REC-112` + `REC-209`).
  Both IDs still appear in the ledger. Neither disappears.
- **Accepted with modification** needs the modification in the
  Notes column and in the surviving `REQ`.
- Do not use **Not applicable** to hide a row you did not want to
  handle.

## Required requirement identifiers

Use `REQ-001`…`REQ-299` only. Never reuse. Suggested shape (you
may regroup; every Accepted claim must still map):

- Catalog invariants: two programs; five tests; no G-006; this
  repo does not run experiments; intake closed.
- G-001 host + required drop (auto-resume).
- G-002 host + required drops (cookie, Port-wrap) + thinnest
  ladder.
- G-003 host + required drops (Mix-in-VM, relups).
- Hosted leftover cards (not tests).
- G-004 method + judge fence + frozen model + one primary + loop
  is not identity + cousin MUST NOT.
- G-005 method + three arms + nested-prompt MUST NOT.
- Watch / Refuse / adaptation-method claims that must stay named
  so they are not silently lost.

Every `REQ` uses
[`program/templates/requirement.md`](../../program/templates/requirement.md).

- **Implementation phase:** write `later sibling repo` or `catalog
  only`. Do **not** mint `PHASE-##`.
- **Source decisions:** cite the `REC-###` (and `DEC` if any).
- **Applies to:** sibling-repo test, catalog card, Watch shelf, or
  catalog invariant — never “merge into `arvo/` this week.”
- Verification is a later measure or an inspection of the catalog,
  not a command you run here.

Intake IDs `G-` / `H-` / `P-` / `V-` / `XB-` / `LC-` are
citations. Do not reuse those strings as `REQ` numbers.

## Required risk and open-question ranges

Do not remint `RSK-001`…`RSK-029` or `OQ-001`…`OQ-018`. Carry
them forward.

- **`OQ-011` is closed** (proposer slot *above* G-004 = yes,
  Watch). Record that closure. Do not reopen.
- Remaining inherited `OQ`s do **not** block catalog honesty
  (the reports say so). Keep them as later-repo questions unless
  you have a new reason one now blocks the *catalog*.
- Mint `RSK-030+` / `OQ-019+` only for something synthesis newly
  finds. Check `decisions/` (empty of `DEC`s) first.

Format: Charter §12. Risks that matter on sight: G-004 collapse;
sixth test; in-the-tree ⇒ works; Port-as-native; judge eaten;
plan-as-backlog; Watch promoted; searcher as identity.

## Exact specification structure

Keep these headings, in this order (skeleton
[`docs/specifications/01-definitive-specification.md`](../specifications/01-definitive-specification.md)
plus [`program/contracts/definitive-specification.md`](../../program/contracts/definitive-specification.md)):

1. Artifact Metadata
2. Executive Decision Summary
3. Authority and Intended Use
4. Problem and Product Definition
5. Goals and Non-Goals
6. Locked Decisions and Invariants
7. Final Technology Stack
8. System Context
9. Architecture
10. Components and Boundaries
11. Data Model
12. Interfaces and Integrations
13. User Workflows
14. Security and Privacy
15. Reliability and Operations
16. Testing and Verification
17. CI and Release
18. Migration (if applicable)
19. Performance Expectations
20. Internal Contracts
21. Dependency Bill of Materials
22. Normative Requirements
23. Traceability
24. Risk Register
25. Open Questions
26. Deferred Work
27. Rejected Work
28. Recommendation Disposition Ledger
29. Definition of Done
30. Handoff to Adversarial Review

Then the Completion Checklist from the skeleton.

Do **not** replace this spine with a focused-report 19-section
shape. You may add subsections under a numbered heading.

### How to read software-first headings as a catalog

The contract is software-first. This program is **not**. Fill every
heading honestly. Do not invent a product architecture to look
complete.

| Heading | Catalog reading |
| ------- | ---------------- |
| Final Technology Stack | This repo has no stack. Name the instrument (Arvo checkout + dated OTP / Elixir / Harbor docs from the reports) and that the **sibling repo** is the lab. Do not pick a production framework. |
| System Context | Two programs + instrument path + later sibling lab. `ore/` ignored unless the owner says so. |
| Architecture | Five tests + three host primitives + leftover cards + two scoring methods. No parallel vocabulary as architecture. |
| Components and Boundaries | The five tests and their fences, not an Elixir module list. |
| Data Model | Catalog nouns already named: Session JSONL, `results.tsv`, git, `program.md`, Harbor reward files as *later format*. |
| Interfaces | Harbor (or equivalent) as later method; official “separate” verifier. Not APIs this repo ships. |
| User Workflows | Operator of the catalog, then operator of the sibling repo. Not a product UX program. |
| Security and Privacy | G-002 fence (keys, kill-hands, no shared cookie). Not a compliance program. |
| Reliability and Operations | G-001 attach / quit-window. Not an ops program. |
| Testing and Verification | G-004 and G-005 methods. Scorer read-only. Frozen model. One primary before the run. |
| CI and Release | Not applicable in this repo. Say so. Sibling repo later. |
| Migration | Copying a *winning file* into `arvo/` is a later product gate, not a migration of users. |
| Performance | Named later measures (prefix-cache break, isolation latency). Not SLOs. |
| Internal Contracts | Catalog invariants (five stay five; judge fence; Watch stays Watch). |
| BOM | Dated official pages and instrument versions already cited. Do not add fashion. |

## Required tables

- **Five-test restatement:** the Blueprint §5 table, restated not
  replaced (plain name, SORT, later measure, keep/drop, land in
  `arvo/`?).
- **Recommendation Disposition Ledger:** every `REC-001`…`REC-011`,
  `REC-100`…`REC-115`, `REC-200`…`REC-210` — ID, disposition, notes,
  surviving `REQ`(s) or “none (Watch / drop kept)”.
- **Traceability:** every `REQ` → sources (`REC` / lock) → later
  home (sibling-repo test / catalog card / Watch / invariant).
- **Risk register:** inherited `RSK-001`…`RSK-029` plus any new
  `RSK-030+`.
- **Open questions:** inherited `OQ-001`…`OQ-018` with `OQ-011`
  marked closed; any new `OQ-019+`.
- **Deferred Work:** Watchlist claims (`REC-111`/`208`,
  `REC-112`/`209`, `REC-210`, leftover Watch clusters via
  `REC-114`, optional cards you deferred).
- **Rejected Work:** required drops and Refuse (`REC-003`,
  `REC-005`, `REC-006`, `REC-010`, `REC-011`, `REC-115`,
  `REC-205`, `REC-206`, `REC-207`, and any others you reject).

## Methodology

1. Read every required full artifact completely before writing.
2. Work the **locked** five tests. Do not invent a sixth.
3. Disposition every material `REC` before you finish the `REQ`
   list. If a claim has no row, you are not done.
4. Prefer restating Blueprint / report measure and keep/drop over
   rewriting them. Sharpen fences; do not replace claims.
5. **Exa via REST** only if a load-bearing sentence in an
   *already-cited* official page is thin
   ([`AGENTS.md`](../../AGENTS.md) Exa section). Load
   `EXA_API_KEY` from gitignored `.env`. Never print the key.
   - Ordinary lookup: `POST https://api.exa.ai/search` `type`
     `auto` or `fast`, then open the official URL.
   - **Does not merit Exa:** new arXiv harvest, star counts, “what
     else is hot,” unread Articles, Watch dumps, paper shopping.
   - Official pages already cited in the three reports are enough
     for synthesis unless wording is thin.
   - If the key is missing or the call fails, say so in Authority
     / Intended Use (or a short methodology subsection) and
     continue from the accepted reports. Do not pretend Exa ran.
     Do not use Exa MCP.
6. Record uncertainty. Name later measures. Do not run them.
7. Leave no foundational *catalog* decision to the implementer
   unless you explicitly defer it as Watch or as a named `OQ`
   that does not block catalog honesty.

## Evidence and citation rules

Inherit Charter §4–§6.

- Portable Markdown links, footnotes, or a source ledger with
  URLs and access dates. No ephemeral UI tokens.
- Cite Blueprint, Charter, the three accepted reports (with
  accepting commits), SORT Graduate rows, DISCOVERY-NOTES locked
  top, and already-named official URLs. Do **not** cite HANDOFF,
  this prompt, chat, or the manifest as evidence.
- Harbor method page = design insight, not a run this lab
  performed.
- Popularity / star counts are not proof.
- High confidence: user decision, or a dated primary read.
  Hypotheses about holdout rising stay Medium or Low.
- You do **not** need a focused-report Evidence Ledger. The
  disposition ledger + traceability + citations carry the
  evidence. Mint new `EVD-###` only if you allocate one; then
  start after `EVD-219`. Prefer not to.

## Evidence-spike policy

**None in this repo.** Inherit Charter §7 and
[`program/contracts/evidence-spike.md`](../../program/contracts/evidence-spike.md)
only as the protocol phase-2 may use later.

If you are tempted to run Harbor, boot Arvo, or write Elixir to
“see whether the catalog is right,” **stop**. Write the later
measure.

## Comparison and scoring requirements

- Five tests stay five. A leftover card is not a test. A layer
  score is not G-006. A proposer is not G-004.
- G-004 and G-005 stay **split**. Say so on purpose.
- Scorer / judge tree is read-only. Model is frozen for a scoring
  run. One primary declared **before** the run. Holdout required.
  Side stats cannot keep.
- G-005 has three arms. Local / smaller is allowed to lose.
- A nested prompt is not a child Session.
- Do not invent a primary Harbor number.
- “Copy the loop into `arvo/`” is refused. A winning *file* may
  later be copied.
- Do not raid leftover Watch cards to look busy.
- Official RLM env / bash on hands is a tool; Port-wrap of a
  *foreign harness* is a shell (`REC-006` vs `REC-103`).

## Anti-patterns

Inherit [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md)
and Charter §18. Especially here:

- Silent recommendation loss
- Chat-history authority; citing HANDOFF as evidence
- Inventing G-006; leftover card as a test; layer scores as G-006
- Merging G-004 with “improves while you use it”
- Nested prompt as G-005
- Promoting GEPA/ACE off Watch; designing an online improver
- Landing the searcher as Arvo’s identity
- Treating “in the tree” as “works”
- Opening intake / re-sorting / Exa-as-arXiv-dump
- Treating Watch as a failure
- Coding / Harbor run / smoke test
- Plan-as-backlog; minting `PHASE` / `MS` here
- Parallel vocabulary as architecture
- Starting spec-review in this session
- Marking the stage accepted
- Evidence-free confidence; High on a hypothesis
- Identifier reuse (`REC-001`…`REC-011`, `REC-100`…`REC-115`,
  `REC-200`…`REC-210`, `RSK-001`…`RSK-029`, `OQ-001`…`OQ-018`,
  `EVD-001`…`EVD-028`, `EVD-100`…`EVD-115`, `EVD-200`…`EVD-219`
  are taken)

## Completion checklist

- [ ] Specification exists at
      `docs/specifications/01-definitive-specification.md`
- [ ] All 30 numbered headings present and filled (catalog
      readings, not invented product architecture)
- [ ] Status: `Proposed — pending adversarial review`
- [ ] Every material `REC` dispositioned (38 rows; none silent)
- [ ] `REQ-001`…`REQ-299` only; template fields filled
- [ ] Five tests still five; no G-006; cards are not tests
- [ ] G-004 and G-005 stay split; cousin not merged
- [ ] Scorer / judge tree read-only; frozen model; one primary
      before the run
- [ ] G-005 has three arms; local may lose; nested prompt is a
      drop
- [ ] `OQ-011` / `REC-111` / `REC-208` stay Watch above G-004
- [ ] `REC-112` / `REC-209` stay Watch; not G-006
- [ ] Searcher is not Arvo’s identity
- [ ] First later job includes Arvo smoke check **there**
- [ ] No `SPK-###`; no `PHASE` / `MS`; no Harbor run; no Arvo
      command run as a test
- [ ] Exa used via REST only as allowed, or skip documented
- [ ] Intake not reopened
- [ ] Shared new IDs start at `RSK-030` / `OQ-019` if minted
- [ ] Plain-language summary shown to Robert
- [ ] Human accepts specification — **leave unchecked**
- [ ] Independent validation passed — **leave unchecked**
- [ ] Manifest updated; accepting commit recorded — **leave
      unchecked**

## Allowed file scope

**Must write**

- `docs/specifications/01-definitive-specification.md`

**Allowed extras**

- `docs/working/DISCOVERY-NOTES.md` — one pointer line at the top
- `research-program.toml` — `last_updated_date` and
  `synthesis.status` to `awaiting-validation` if you finish the
  file. Do **not** set `accepted`.
- `docs/validations/13-definitive-specification-validation.md`
  only if an *independent* validator writes it
- `docs/handoffs/synthesis-attachment-manifest.md` if you tighten
  the list you actually used

**Do not edit**

- Accepted Blueprint (except a mechanical link fix)
- Accepted Charter
- Accepted runtime, leftovers, or score-harness reports
- SORT substance
- spec-review, revision, plan, or review placeholders
  (`docs/specifications/02-*.md`, `docs/plans/*`,
  `docs/reviews/*`)

## Final response requirements

Plain language to Robert. Do not dump section numbers. Say:

1. The proposed specification is filled (path).
2. This repo still only catalogs ideas. You did not write Elixir
   or run Harbor.
3. Every inherited recommendation has a disposition. Five tests
   are still five.
4. G-004 is still a fixed-set lab loop. G-005 is still its own
   Session. The cousin is not merged.
5. You have **not** accepted the specification.
6. Next after he accepts: spec-review in a fresh session. Do not
   write it now.

## Output behavior

Modify only the allowed paths above. Do not modify governing
artifacts or begin downstream stages.
