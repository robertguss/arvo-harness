# Validation Report — 11-leftovers-research

- **Result:** Pass
- **Validator:** Independent Validation Agent (`research-validate`)
- **Date:** 2026-08-15
- **Artifact path:** [`docs/reports/11-leftovers-research-report.md`](../reports/11-leftovers-research-report.md)
- **Commissioning prompt:** [`docs/prompts/11-leftovers-research-prompt.md`](../prompts/11-leftovers-research-prompt.md)
- **Git commit reviewed:** Not inspected. This validation was commissioned with **do not run git**. Working-tree artifact; `research-program.toml` `leftovers.status` = `awaiting-validation`; `accepted_commit` empty.

## Checks Performed

| Check | Result |
| ----- | ------ |
| Required 19 report-contract headings present and filled | Pass (`## 1`–`## 19`) |
| Artifact metadata and actual research date | Pass (header + §1; research date 2026-08-15) |
| `REC-100`…`REC-199` only; no reuse of `REC-001`…`REC-011` as leftover numbers | Pass (`REC-100`…`REC-115`; runtime IDs cited as inherited only) |
| Each `REC` has claim + host (G-001 / G-002 / G-003 / none) + why Watch if none + later measure + keep/drop + why not a sixth headline | Pass |
| Standard recommendation template fields present | Pass (all 16 `REC`s) |
| Evidence Ledger completeness (Charter fields) | Pass (see observations) |
| leftover insight ≠ proven adaptation | Pass (ledger Limitations; Medium/Low on adaptation; §13) |
| No `SPK-###`; no Arvo command run as a test | Pass |
| No sixth test; G-004 / G-005 not designed | Pass |
| Most items still Watch; Refuse still refused | Pass (23/23 Watch; 23/23 Refuse; 2 Translate left Watch) |
| Every SORT Translate / Watch / Refuse cluster appears once in a shelf table | Pass (14 + 23 + 23; some Refuse titles abbreviated) |
| Intake not reopened | Pass (already-cited abstracts / README only) |
| Exa REST or documented skip/failure in Methodology | Pass (ordinary `type` `auto`, HTTP 200; no Agent / deep) |
| `RSK-010+` / `OQ-007+` | Pass (`RSK-010`…`RSK-018`; `OQ-007`…`OQ-012`) |
| Citation portability (no HANDOFF / prompt / chat as evidence) | Pass |
| Completion checklist truthfulness (last two items unchecked) | Pass |
| `leftovers.status` is not `accepted` | Pass (`awaiting-validation`) |
| No score-harness file written | Pass (`docs/reports/12-score-harness-research-report.md` absent) |
| Allowed file scope of the author session | Pass on tree inspection (git not run) |
| Identifier ranges and uniqueness | Pass |
| Placeholder remnants | Pass |
| Internal contradictions vs accepted Blueprint locks | Pass |
| Required tables (shelf outcomes; pattern cards; runtime inheritance; Evidence Ledger; Recommendation ledger; Source ledger) | Pass |
| Handoff Digest fields | Pass (all 11 contract fields) |
| `just check` | Pass (static: required tree + accepted-stage outputs; leftovers not accepted) |

All 19 required headings from
[`program/contracts/focused-research-report.md`](../../program/contracts/focused-research-report.md)
and the commissioning prompt’s Exact report structure are present and filled:

1. Artifact metadata and actual research date
2. Executive answer
3. Scope and exclusions
4. Inherited constraints
5. Methodology
6. Source quality and limitations
7. Evidence spikes
8. Comparative analysis
9. One coherent recommendation set
10. Evidence Ledger
11. Recommendation ledger
12. Risks
13. Weak evidence
14. Conflicting evidence
15. Assumptions
16. Open questions
17. Handoff Digest
18. Source ledger
19. Completion checklist

Header metadata is complete (type, program, stage, status `Draft — not accepted`,
version, created/research date, Charter + Blueprint accepting commits, runtime
accepting commit as *may cite*, ranges used, spikes unused, accepting commit
empty). Section 1 restates the primary question.

Track bar (Charter §10 leftovers / Blueprint §11 leftovers row):

- Pattern card = leftover insight + BEAM noun + why not a sixth headline.
- Five tests stay five. No G-006. `REC-113` is Required *method*, not a test.
- 11 hosted cards on G-001 / G-002 / G-003. Host **none** on REC-111…REC-115
  with Why Watch (or “not Watch — method / Rejected”).
- 23 / 23 Watch stay Watch (REC-114). 23 / 23 Refuse stay refused (REC-115).
- Translate clusters are hypotheses / cards, not headlines. GEPA/ACE and traces
  stay Watch above / beside scoring (REC-111, REC-112). G-004 / G-005 are not
  designed.
- High confidence is reserved for locks and dated page *wording*. Adaptation
  hypotheses stay Medium or Low.
- Methodology documents Exa REST ordinary lookup on six already-cited queries.
  No arXiv harvest. No Watch-dump / PDF / bookmark reopen.
- Report states no `SPK-###` and no Arvo inspect or boot in this session.

Checklist: items 1–11 may be checked. **Human accepts report** and **Manifest
updated; accepting commit recorded** are unchecked. Required: there is no
accepting commit. The “plain-language summary shown to Robert” box is checked
as a session message; this validator did not see that message and does not
treat the checkbox as independent proof.

Non-blocking observations (not revision triggers):

1. **Compound EVD classifications.** EVD-102 (`Architectural judgment + user
   accept`), EVD-104 (`User decision / framing`), and EVD-114 (`User decision +
   dated OTP read`) name more than one Charter §8 class. Each row is otherwise
   complete and limited correctly. Validator did not reclassify.
2. **Refuse cluster titles are abbreviated** in the shelf table and REC-115
   (e.g. “Feature race”, “as architecture” without “the”, “as identity”
   without “daily-driver”). Every SORT cluster still appears once and is
   uniquely identifiable. Validator did not expand titles.
3. **Ledger Downstream ↔ REC Evidence lists** are not 1:1. EVD-112…EVD-115
   name REC-103 / REC-106 / REC-107 / REC-108 / REC-109 / REC-115 while those
   `REC` Evidence lists cite earlier rows. Content is still supported.
   Validator did not rewrite evidence lists.
4. **REC-110 Evidence quality** is `Weak-to-moderate` rather than a single
   template enum (`Strong` / `Moderate` / `Weak`). The body already treats
   replay as a thin Optional lab card. Validator did not invent a single
   grade.
5. **SORT “Worktree + node” parenthetical** says “next to G-005.” The report
   hosts REC-104 on G-002 (prefer G-001…G-003; do not design G-005). That is
   an allowed leftovers judgment, not a silent G-005 design.

## Mechanical Corrections

None. No trailing whitespace, heading-hierarchy breaks, or malformed fences
found. No mechanical metadata typos found. Every `REC` already restates
`None in this repo.` then the later measure under Evidence Spikes.

In-repo Markdown links from the report resolve
(`docs/00-program-blueprint.md`, `docs/01-research-charter.md`,
`docs/reports/10-runtime-research-report.md`, `docs/working/SORT.md`,
`docs/working/DISCOVERY-NOTES.md`).

Did not open bookmark JSON, PDFs, vault traces, or Watch dump files except
to confirm that already-cited arXiv / GitHub IDs in the leftovers ledger
already appear in DISCOVERY-NOTES / SORT / ARXIV-WATCH (closed intake). Did
not boot Arvo. Did not re-fetch primary URLs as a new research pass.

## Substantive Defects

None.

## Identifier Audit

| Namespace | This report | Range / uniqueness | Notes |
| --------- | ----------- | ------------------ | ----- |
| REC | `REC-100`…`REC-115` | Leftovers `REC-100`…`REC-199` | Sequential; one host field each; runtime `REC-001`…`REC-011` cited, not reminted |
| RSK | `RSK-010`…`RSK-018` | Shared `RSK-001`…`RSK-999` | Continues after runtime `RSK-001`…`RSK-009` |
| OQ | `OQ-007`…`OQ-012` | Shared `OQ-001`…`OQ-999` | Continues after runtime `OQ-001`…`OQ-006`; none blocking for catalog honesty |
| EVD | `EVD-100`…`EVD-115` | Optional per report | No collision with runtime `EVD-001`…`EVD-028`; runtime EVD-004 / EVD-007 cited only |
| DEC | none | — | Matches “none exist” |
| SPK | unused | Forbidden here | No `docs/evidence/SPK-*`; §7 is `None in this repo` |
| REQ / FND / PHASE / MS | none | Later spine | Correctly omitted |
| Intake IDs | `G-001`…`G-005` cited; `H-` / `P-` / `V-` / `XB-` / `LC-` cited | Not reused as `REC` numbers | Graduate labels stay intake IDs |

`decisions/` contains only `README.md`.
[`docs/reports/`](../reports/) has the accepted runtime report, this leftovers
draft, and `README.md` — no score-harness `REC-200+`.

Shelf table vs SORT (cluster appears once):

| Shelf | SORT clusters | Report rows | Outcome claimed |
| ----- | ------------- | ----------- | --------------- |
| Translate | 14 | 14 | 11 hosted cards; 2 Watch (REC-111, REC-112); 1 method (REC-113) |
| Watch | 23 | 23 | Stay Watch (REC-114) |
| Refuse | 23 | 23 | Stay Refuse (REC-115); three rows cite runtime REC-005 / REC-006 / REC-011 |

## Citation Audit

Portable Markdown links, numbered footnotes, and a source ledger with URLs or
paths and access dates (2026-08-15). No ephemeral UI tokens.

Cited as evidence: accepted Blueprint and Charter; accepted runtime report;
SORT / DISCOVERY-NOTES as framing; already-named paper abstracts (RLM, GEPA,
ACE, Voyager, parallel compact); official RLM GitHub README; José tweet URLs;
Livebook runtime page via accepted runtime. Root `HANDOFF.md`, the
commissioning prompt, and the attachment manifest are **not** cited as
evidence (HANDOFF is named only as something not to cite). Exa is classified
as retrieval, not a source tier (EVD-111 → Methodology).

Paper rows are **official claims about those documents**, with Limitations
that leftover ≠ proven adaptation and that PDFs were not opened. Popularity /
star counts are explicitly not used. No Arvo-tree row claims function.

## Scope Audit

The artifact is a catalog of pattern cards and Watch / Refuse dispositions.
It does not implement cards, boot Arvo, mint `SPK-###`, open intake, invent
G-006, or design G-004 / G-005.

- [`docs/reports/12-score-harness-research-report.md`](../reports/12-score-harness-research-report.md)
  does **not** exist. Manifest `score-harness.status` remains `planned`.
- [`docs/evidence/`](../evidence/) and [`decisions/`](../../decisions/) still
  contain only README files.
- Accepted Blueprint and Charter headers still show `Status: Accepted` and
  the same accepting commits; this validator did not edit them.
- Accepted runtime report still shows `Status: Accepted` at
  `636123f1a628803aa4ae2c44fc4659d167a80693`; this validator did not edit it.
- Watch items stay Watch. Refuse stays refused. Translate leftovers sit on
  inherited host nouns or honest host **none**.
- Authority: Blueprint §7 inherited, not re-litigated. Runtime Required drops
  (shared cookie, Port-wrap of a foreign harness, Mix-in-VM, relups,
  auto-resume-as-G-001) are cited, not contradicted. Port of the *official
  RLM env* is distinguished from Port of a foreign *harness* in §14 / EVD-113.

Author-session allowed paths (commissioning prompt) vs tree:

| Path | Present / state | Allowed? |
| ---- | --------------- | -------- |
| `docs/reports/11-leftovers-research-report.md` | Filled draft | Yes — required output |
| `docs/working/DISCOVERY-NOTES.md` | Pointer line to the draft report | Yes — optional extra |
| `research-program.toml` | `leftovers.status = "awaiting-validation"`; `accepted_commit = ""` | Yes — must not set `accepted` |
| `docs/validations/11-leftovers-research-validation.md` | This file | Yes — independent validator only |
| score-harness report | Absent | Yes |
| Accepted Blueprint / Charter / runtime report | Unchanged by this validator | Must not edit |
| SORT substance | Clusters unchanged on inspection | Must not re-sort |

## Git Diff Audit

Not performed. Commissioning instruction: **do not run git.** Did not commit.
Did not `git add`. Did not set `leftovers.status = "accepted"`.

Scope conclusion is from tree inspection and the paths above, not from a diff.

## Required Next Action

Validation **passes**. Leave
`leftovers.status = "awaiting-validation"` until the human accepts and records
the accepting commit. Do **not** mark the stage `accepted`. Do **not** start
score-harness *in this validation session*. Score-harness remains legal Group A
work in a **separate** fresh session; it may **cite** this report only once
this report is accepted.

Human (Robert):

1. Review the filled leftovers report.
2. Commit if accepted as a non-accepting snapshot, or as the accepting commit.
   Suggested message (from the attachment manifest):

   ```text
   docs: add leftovers research report (not accepted)
   ```

3. Only the accepting commit may set `leftovers.status = "accepted"` and record
   `accepted_commit`.
4. After acceptance, score-harness (`REC-200`…`REC-299`) remains legal Group A
   work in a **fresh** session. Continue shared IDs from `RSK-019` and
   `OQ-013`.
