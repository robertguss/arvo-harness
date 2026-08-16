# Validation Report — 13-definitive-specification

- **Result:** Pass
- **Validator:** Independent Validation Agent (`research-validate`)
- **Date:** 2026-08-15
- **Artifact path:** [`docs/specifications/01-definitive-specification.md`](../specifications/01-definitive-specification.md)
- **Commissioning prompt:** [`docs/prompts/13-chief-architect-synthesis-prompt.md`](../prompts/13-chief-architect-synthesis-prompt.md)
- **Git commit reviewed:** Working-tree artifact. This validation was commissioned **not** to treat any commit as accepting. Inspected `git status` and `git diff --stat` for scope only. Did not `git add`, commit, or set `synthesis.status = "accepted"`. `research-program.toml` `synthesis.status` = `awaiting-validation`; no `accepted_commit` on that stage.

## Checks Performed

| Check | Result |
| ----- | ------ |
| All 30 numbered headings present and filled | Pass (`## 1`–`## 30`; catalog readings, not a product architecture) |
| Metadata and status `Proposed — pending adversarial review` | Pass (header + §1 + §2 close + §29) |
| `REQ-001`…`REQ-299` only | Pass (`REQ-001`…`REQ-047`; sequential; no `REQ-300+`) |
| Every `REQ` has template fields | Pass (47 × Priority, Applies to, Implementation phase, Source decisions, Verification, Risk linkage, Requirement, Rationale, Acceptance Evidence, Exceptions) |
| Implementation phase is `catalog only` or `later sibling repo` | Pass (no `PHASE-##`) |
| Every material `REC-001`…`REC-011`, `REC-100`…`REC-115`, `REC-200`…`REC-210` has exactly one disposition (38 rows) | Pass (§28; none silent; none reminted) |
| Report-class Rejected RECs Accepted *as rejections* (drop kept) | Pass (`REC-003`, `005`, `006`, `010`, `011`, `115`, `205`, `206`, `207`) |
| Watchlist RECs Accepted as Watch, Deferred, or Merged — not G-006 / Must features | Pass (`REC-111`/`208` Merged; `REC-112`/`209` Merged; `REC-114`, `REC-210` Accepted as Watch) |
| Five tests still five; no G-006 | Pass (`REQ-002`; five-test table; architecture layer table) |
| G-004 and G-005 still split; cousin not merged | Pass (`REQ-002`, `REQ-034`, `REQ-038`, `REQ-040`; `REC-205` drop kept) |
| Scorer-read-only, frozen-model, one-primary-before-run explicit | Pass (`REQ-035`, `REQ-036`; §16) |
| G-005 three arms; local may lose; nested prompt is a drop | Pass (`REQ-040`, `REQ-041`, `REQ-042`; `REC-206` drop kept) |
| `OQ-011` remains closed | Pass (§6, §25, `REQ-043`; not reminted) |
| GEPA/ACE still Watch above G-004 | Pass (`REQ-043`; Deferred Work; not G-006) |
| Layer scores still Watch; not G-006 | Pass (`REQ-044`; `REC-112`/`209`) |
| Searcher not identity | Pass (`REQ-037`, `REQ-039`; `REC-204`, `REC-207`) |
| Harbor separate-mode inherited, not invented as a run | Pass (`REQ-035`; §12; official default named **shared**) |
| No invented Harbor number | Pass (format inherited from `REC-202`; no lab job number) |
| `evals/arvo-attention-reread/` absence treated as checkout fact not a score | Pass (`REQ-006`; §11; `RSK-029`) |
| Software-first headings filled as catalog readings | Pass (§7–§19 refuse a product stack / APIs / SLOs / CI here) |
| No `SPK-###`; no `PHASE` / `MS` | Pass (header + `REQ-010`; informal “phase-2” owner text inherited, not `PHASE-##`) |
| Intake not reopened | Pass (`REQ-004`; methodology; no new arXiv harvest) |
| Exa REST or documented skip | Pass (§3: **Exa did not run**; documented skip) |
| New shared IDs start at `RSK-030` / `OQ-019` if minted | Pass (`RSK-030` only; no `OQ-019+`; no `EVD` minted) |
| Inherited `RSK-001`…`RSK-029` and `OQ-001`…`OQ-018` carried | Pass (§24–§25) |
| Citation portability (no HANDOFF / prompt / chat as evidence) | Pass (§3 item 8 names those as non-authority) |
| Checklist truthfulness (human-accept / validation / commit unchecked) | Pass |
| `synthesis.status` is not `accepted` | Pass (`awaiting-validation`) |
| No spec-review or plan file written | Pass (those skeletons still `Placeholder — not accepted`) |
| Identifier ranges and uniqueness | Pass (see Identifier Audit) |
| Placeholder remnants in the specification | Pass (none) |
| Internal contradictions vs accepted Blueprint locks | Pass (five-test table restated, not replaced) |
| `just check` | Pass (`check: OK`) |

All 30 required headings from
[`program/contracts/definitive-specification.md`](../../program/contracts/definitive-specification.md)
and the commissioning prompt’s Exact specification structure are present
and filled:

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

Then the Completion Checklist.

Header metadata is complete (type, program, status
`Proposed — pending adversarial review`, version, created/updated
2026-08-15, requirement range `REQ-001`…`REQ-047`, `RSK-030` minted,
no new `OQ`, no `DEC` / `SPK` / `PHASE` / `MS`). Section 1 restates
that `REQ`s are catalog claims, not tickets in this tree.

Track bar (Charter §10 synthesis / Blueprint §11 synthesis row / prompt
locked context):

- Five headline tests stay five. No G-006. Cards are not tests.
- Host nouns stay as runtime named them. Required drops stay dropped.
- G-004 remains a fixed-set lab loop. Judge tree / holdout /
  leftover-test identity / `program.md` read-only. Frozen model. One
  primary before the run.
- G-005 remains its own Session. Three arms. Local may lose. Nested
  prompt is a drop. Split from G-004 on purpose.
- Proposer slot named *above* G-004 and left Watch. `OQ-011` closed.
  `REC-111` stays Watch. Layer watches stay Watch. Searcher-meta stays
  Watch. Searcher is not Arvo’s identity.
- Harbor official default is **shared**; later repo should use
  **separate** mode. That is inherited method, not a run.
- Missing `evals/arvo-attention-reread/` at Arvo `84004e1` is a
  checkout fact.
- First later job includes the Arvo smoke check **there**.
- High confidence is reserved. “Holdout would rise” stays Medium or
  Low (`REQ-009`).
- Methodology documents an Exa skip. Intake was not reopened. No
  `SPK-###`. No Harbor run. No Arvo command as a test.

Checklist: synthesis process items may be checked. **Independent
validation passed**, **Human accepts specification**, and **Manifest
updated; accepting commit recorded** are unchecked. Required: there is
no accepting commit. **Plain-language summary shown to Robert** is
unchecked and annotated as a session message; this validator did not
see that message and does not treat the box as independent proof.

Required tables are present: five-test restatement; Recommendation
Disposition Ledger (38 rows); Traceability (every `REQ`); Risk register
(`RSK-001`…`RSK-030`); Open questions (`OQ-001`…`OQ-018`, `OQ-011`
closed); Deferred Work; Rejected Work.

Non-blocking observations (not revision triggers):

1. **Watchlist `REQ` priority.** `REQ-043`…`REQ-046` are Priority
   **Must**. The normative text is *MUST stay Watch*, not *MUST
   implement GEPA / layers / meta-search*. Deferred Work still names
   those items as Watch. Validator did not re-prioritize.
2. **Watch clusters listed as a group.** Leftovers `REC-114` asked
   synthesis to keep the 23 SORT Watch clusters on Watch. §26 has one
   row (“All 23 SORT Watch clusters”) pointing at `REC-114` rather
   than reprinting the 23 names. The commissioning prompt allows
   “via `REC-114`.” No cluster is promoted. Validator did not invent
   a 23-row reprint.
3. **Optional cards sit in both Accepted and Deferred Work.**
   `REC-007`, `REC-104`, `REC-107`, `REC-110` are **Accepted** as May
   and also listed under §26. Prompt allows Accepted-as-optional.
   Dual listing is documentation, not a silent drop.
4. **Inherited `OQ` wording slightly shortened.** `OQ-003` and
   `OQ-017` drop parenthetical examples from the reports. IDs,
   blocking flags, and resolution paths are carried. Validator did
   not rewrite the table.
5. **Five-test restatement omits Blueprint “Operator care”.** Prompt
   required plain name, SORT, later measure, keep/drop, land in
   `arvo/?`. Those cells match Blueprint §5. Operator care was extra
   in the Blueprint table.
6. **Extra checklist item.** “Standalone as a catalog” is not in the
   commissioning checklist. It is checked and matches §1 / `REQ-001`.
   The three required-unchecked accept items remain unchecked.

## Mechanical Corrections

None. No trailing whitespace. One fenced block in §8, closed. Heading
hierarchy is `##` numbered sections with `###` / `####` subsections.
In-repo Markdown links from the specification resolve (13 internal
targets; 0 missing). No mechanical metadata typos found. Every `REQ`
already uses `catalog only` or `later sibling repo`.

Did not invent missing research, citations, findings, recommendations,
Harbor numbers, or architecture. Did not edit the specification. Did
not boot Arvo. Did not run Harbor. Did not write Elixir. Did not open
Watch dumps, bookmark JSON, or unread Articles. Did not print `.env`.
Did not treat this as a new research pass.

## Substantive Defects

None.

## Identifier Audit

| Namespace | This specification | Range / uniqueness | Notes |
| --------- | ------------------ | ------------------ | ----- |
| REQ | `REQ-001`…`REQ-047` | Synthesis `REQ-001`…`REQ-299` | Sequential; no reuse; intake `G-` / `H-` / `P-` / `V-` / `XB-` / `LC-` cited, not reminted as `REQ`s |
| REC | none minted | Inherited 38 material rows | Disposition ledger only; IDs not reminted |
| RSK | `RSK-030` minted; `RSK-001`…`RSK-029` carried | Shared `RSK-001`…`RSK-999` | Continues after score-harness `RSK-029` |
| OQ | none minted; `OQ-001`…`OQ-018` carried; `OQ-011` closed | Shared `OQ-001`…`OQ-999` | Not reminted; remaining inherited `OQ`s stay later-repo |
| EVD | none | Prefer not to mint | No collision with `EVD-001`…`028`, `100`…`115`, `200`…`219` |
| DEC | none | `decisions/` still README only | Matches “none exist” |
| SPK | unused | Forbidden here | No `docs/evidence/SPK-*` |
| FND / PHASE / MS | unused | Later spine | `REQ-010` forbids minting them here |
| G-006 | forbidden only | — | Named as a drop, not minted |

Disposition ledger (38 / 38; allowed values only):

| Band | Dispositions |
| ---- | ------------ |
| Runtime `REC-001`…`REC-011` | All **Accepted**. Rejected-class rows (`003`, `005`, `006`, `010`, `011`) Accepted *as rejections* with MUST NOT `REQ`s |
| Leftovers `REC-100`…`REC-110` | All **Accepted** (cards / optional cards). Not headlines |
| `REC-111` + `REC-208` | **Merged** into Watch `REQ-043` (prompt-legal pair) |
| `REC-112` + `REC-209` | **Merged** into Watch `REQ-044` (prompt-legal pair) |
| `REC-113`, `REC-114` | **Accepted** (method; Watch stays Watch) |
| `REC-115` | **Accepted** as Refuse kept |
| Score-harness `REC-200`…`REC-207` | All **Accepted**. Rejected-class `205`/`206`/`207` Accepted *as rejections* |
| `REC-210` | **Accepted** as Watch |

No **Rejected** (synthesizer-overturn), **Not applicable**, **Deferred**,
or **Superseded** rows. No silent drop.

`REQ` → host / shelf mapping used for the lock checks:

| REQ | Role |
| --- | ---- |
| REQ-001…010 | Catalog invariants (two programs; five stay five; no runs here; intake closed; smoke-check **there**; no `PHASE`/`MS`) |
| REQ-011…013 | G-001 host + auto-resume drop |
| REQ-014…018 | G-002 host + cookie / Port-wrap drops + optional Docker |
| REQ-019…021 | G-003 host + Mix-in-VM / relup drops |
| REQ-022…032 | Eleven hosted leftover cards (not tests) |
| REQ-033 | Adaptation method |
| REQ-034…039 | G-004 method + judge fence + freeze/primary + not identity + cousin MUST NOT |
| REQ-040…042 | G-005 method + nested-prompt MUST NOT + local may lose |
| REQ-043…047 | Watch / Refuse shelves |

## Citation Audit

Portable Markdown links, numbered footnotes, and a BOM with versions
or access dates. No ephemeral UI tokens.

Cited as evidence: accepted Blueprint (`0b49540cae7d2a30ad4b4b145999e27b82c50dad`);
accepted Charter (`081ad36932be7f3f0df062b592cc306c49f72af4`); accepted
runtime report (`636123f1a628803aa4ae2c44fc4659d167a80693`); accepted
leftovers report (`9698362dbe5f90ff48e7aa1093d547d2e14d410a`); accepted
score-harness report (`c15dd31c44c197340d2b339657eb7f072f066d44`);
SORT Graduate table as framing; DISCOVERY-NOTES locked top as framing;
already-named José tweets and Harbor official pages (Motivation, Task
Structure, Regrade) dated 2026-08-15 **via the accepted reports**.
OTP / Elixir / Livebook / Arvo `84004e1` versions are inherited from
those reports, not re-harvested.

Root `HANDOFF.md`, the commissioning prompt, the attachment manifest,
and chat are **not** cited as evidence. §3 item 8 names them as
non-authority. Exa is classified as a skip, not a source tier.

Harbor method pages are treated as **design insight**, not as a result
this lab ran. Default verifier is recorded as **shared**; separate
mode is a later-repo SHOULD (`REQ-035` / `REC-201`).
`reward.txt` 1/0 and named `task_ok` are inherited legal *formats*
from `REC-202`, not a number this lab produced. Popularity / star
counts are forbidden (`REQ-009`). Missing
`evals/arvo-attention-reread/` is a checkout fact (`REQ-006`,
`RSK-029`).

This validator did not re-open official Harbor pages or Arvo source.
Load-bearing Harbor and checkout sentences were checked against the
**accepted** score-harness and runtime reports, which already carry
those dated reads.

## Scope Audit

The artifact is a catalog-shaped specification. It does not implement
tests, boot Arvo, run Harbor, mint `SPK-###` / `PHASE-##` / `MS-###` /
`FND-###` / `DEC-###`, open intake, invent G-006, merge the cousin
into G-004, or land the searcher as Arvo’s identity.

- [`docs/specifications/02-definitive-specification-revised.md`](../specifications/02-definitive-specification-revised.md),
  [`docs/reviews/01-specification-adversarial-review.md`](../reviews/01-specification-adversarial-review.md),
  [`docs/plans/01-implementation-plan.md`](../plans/01-implementation-plan.md),
  and the other plan / review skeletons remain
  `Placeholder — not accepted`. Spec-review and planning were not
  started.
- [`docs/evidence/`](../evidence/) and [`decisions/`](../../decisions/)
  still contain only README files.
- Accepted Blueprint and Charter headers still show `Status: Accepted`
  and the same accepting commits; this validator did not edit them.
- Accepted runtime / leftovers / score-harness reports still show
  `Status: Accepted` at the commits named in Authority; this validator
  did not edit them.
- Runtime Required drops (auto-resume, shared cookie, Port-wrap,
  Mix-in-VM, relups) are inherited as forbidden keeps.
- `REC-111` / `REC-208` stay Watch above G-004. `OQ-011` is closed:
  yes, a proposer slot is named; it stays Watch.
- `REC-112` / `REC-209` stay Watch, not G-006.
- Authority: Blueprint §7 and Charter §14 inherited, not re-litigated.

Author-session allowed paths (commissioning prompt) vs tree:

| Path | Present / state | Allowed? |
| ---- | --------------- | -------- |
| `docs/specifications/01-definitive-specification.md` | Filled proposed spec | Yes — required output |
| `docs/working/DISCOVERY-NOTES.md` | Pointer line + “Next” update; dump not rewritten | Yes — optional extra |
| `research-program.toml` | `synthesis.status = "awaiting-validation"`; prompt path `13-…`; no `accepted` | Yes — must not set `accepted` |
| `docs/validations/13-definitive-specification-validation.md` | This file | Yes — independent validator only |
| Spec-review / revised spec / plans / reviews | Still placeholders | Yes — must not fill |
| Accepted Blueprint / Charter / three reports | Unchanged by this validator | Must not edit |
| SORT substance | Not in the synthesis diff | Must not re-sort |

Working-tree extras **outside** this validation write (packaging /
handoff maps, not filled later-spine artifacts): untracked
`docs/prompts/13-chief-architect-synthesis-prompt.md`,
`docs/handoffs/synthesis-attachment-manifest.md`,
`docs/handoffs/synthesis-launch-message.md`, root `HANDOFF.md`;
deleted skeleton `docs/prompts/NN-chief-architect-synthesis-prompt.md`.
Those are install-package files. They are not a spec-review, revised
spec, or plan.

`just check` (`scripts/check_program.py`): required files and dirs
present; accepted stages’ outputs exist and are not placeholders;
synthesis is not `accepted`, so the script does not treat this draft
as an accepted output. Result: `check: OK`.

## Git Diff Audit

Inspected `git status --short` and `git diff --stat` only. Did not
commit. Did not `git add`. Did not set `synthesis.status = "accepted"`.

Tracked synthesis-scope diffs:

| Path | Diff | In scope? |
| ---- | ---- | --------- |
| `docs/specifications/01-definitive-specification.md` | Placeholder replaced (~2300 lines) | Yes — required |
| `docs/working/DISCOVERY-NOTES.md` | +1 pointer; “Next” line updated | Yes — allowed extra |
| `research-program.toml` | `synthesis.status` `planned` → `awaiting-validation`; prompt path `NN-` → `13-` | Yes — allowed; not `accepted` |

No diff against accepted Blueprint, Charter, runtime / leftovers /
score-harness reports, SORT substance, or later-spine placeholders.

## Required Next Action

Validation **passes**. Leave
`synthesis.status = "awaiting-validation"` until the human accepts
and records the accepting commit. Do **not** mark the stage
`accepted`. Do **not** start spec-review *in this validation
session*. Spec-review remains legal only after acceptance, in a
**separate** fresh session.

Human (Robert):

1. Review the filled proposed specification.
2. Commit if accepted as a non-accepting snapshot, or as the accepting
   commit. Suggested message (from the attachment manifest):

   ```text
   docs: add definitive specification (not accepted)
   ```

3. Only the accepting commit may set `synthesis.status = "accepted"`
   and record `accepted_commit`.
4. After acceptance, spec-review remains legal Group-spine work in a
   **fresh** session. Do not write the review, a revised spec, or a
   plan now. Continue shared IDs from `RSK-031` and `OQ-019` if later
   stages mint any. `REQ-001`…`REQ-047` are taken.
