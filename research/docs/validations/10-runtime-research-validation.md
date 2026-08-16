# Validation Report — 10-runtime-research

- **Result:** Pass with mechanical corrections
- **Validator:** Independent Validation Agent (`research-validate`)
- **Date:** 2026-08-15
- **Artifact path:** [`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md)
- **Commissioning prompt:** [`docs/prompts/10-runtime-research-prompt.md`](../prompts/10-runtime-research-prompt.md)
- **Git commit reviewed:** Not inspected. This validation was commissioned with **do not run git**. Working-tree artifact; `research-program.toml` `runtime.status` = `awaiting-validation`; `accepted_commit` empty.

## Checks Performed

| Check | Result |
| ----- | ------ |
| Required 19 report-contract headings present and filled | Pass (`## 1`–`## 19`) |
| Artifact metadata and actual research date | Pass (header + §1; research date 2026-08-15) |
| `REC-001`…`REC-099` only; no silent ID reuse | Pass (`REC-001`…`REC-011`; no other report RECs) |
| Each `REC` has claim + host primitive (exactly one of G-001…G-003) + later measure + keep/drop | Pass |
| Standard recommendation template fields present | Pass (after mechanical Evidence Spikes restatements) |
| Evidence Ledger completeness (Charter fields) | Pass (see observations) |
| Tree-description ≠ function | Pass (checkout table + every Arvo-tree row) |
| No `SPK-###`; no Arvo command run as a test | Pass |
| No sixth test; G-004/G-005 not absorbed | Pass |
| Intake not reopened | Pass |
| Exa use or documented failure in Methodology | Pass (ordinary search/fetch ran; Agent/deep 401) |
| Citation portability | Pass |
| Completion checklist truthfulness (last two items unchecked) | Pass |
| `runtime.status` is not `accepted` | Pass (`awaiting-validation`) |
| No leftovers / score-harness report files written | Pass |
| Allowed file scope of the author session | Pass on tree inspection (git not run) |
| Identifier ranges and uniqueness | Pass |
| Placeholder remnants | Pass |
| Internal contradictions vs accepted Blueprint locks | Pass |
| Required tables (three tests; isolation ladder; checkout vs function; Evidence Ledger; Recommendation ledger; Source ledger) | Pass |
| Handoff Digest fields | Pass (all 11 contract fields) |
| `just check` | Pass (static: required tree + accepted-stage outputs; runtime not accepted) |

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
version, created/research date, Charter + Blueprint accepting commits, ranges
used, instrument SHA claimed, official-doc versions dated). Section 1 restates
the primary question and leaves accepting commit empty.

Track bar (Charter §10 / Blueprint §11 runtime row):

- G-001, G-002, and G-003 remain distinct. No G-006.
- Measure and keep/drop in the §2 table restate Blueprint §5 (SORT Graduate
  wording is used for some *claims* / host moves; the keep/drop and later
  measure lines are not replaced).
- Isolation ladder is process → Port → hidden `:peer` → Docker,
  thinnest-that-passes; Port-wrapped foreign harness is a drop (REC-006).
- Mix-in-VM and OTP relups are rejected as G-003 (REC-010, REC-011).
- At least one Required `REC` per test: REC-001 (G-001), REC-004 (G-002),
  REC-009 (G-003).
- High confidence is split from empirical pass (locks / dated document or
  source-line reads). Hypotheses stay Medium.
- G-004 / G-005 appear only as exclusions or “do not merge.”
- Methodology documents Exa MCP ordinary lookup and the 401 on Agent /
  deep-reasoning. No arXiv / bookmark harvest.
- Report states no `mix`, boot, task, or smoke test of Arvo.

Checklist: items 1–9 may be checked. **Human accepts report** and **Manifest
updated; accepting commit recorded** are unchecked. Required: there is no
accepting commit. The “plain-language summary shown to Robert” box is checked
as a session message; this validator did not see that message and does not
treat the checkbox as independent proof.

Non-blocking observations (not revision triggers):

1. **EVD-026 classification** is `Framing evidence`. That phrase is a Charter
   §4 *source role* for SORT, not a claim class from Charter §8. The row is
   otherwise complete (dated document comparison; High as *wording*). Validator
   did not reclassify (that would be a judgment).
2. **RSK-002…RSK-009** omit a labeled **Description** field. Charter §12 lists
   Description; RSK-001 has it. Titles plus Likelihood / Impact / Mitigation /
   Owner / Trigger still name the risk. Validator did not invent descriptions.
3. **Ledger ↔ REC Evidence lists** are not 1:1. The clearest mismatch:
   REC-007 lists EVD-008 (relups) while EVD-024 (`:peer` / Docker `exec`)
   already names REC-007 downstream. Other lists omit or extra-cite a row
   whose Downstream column names a neighbor `REC`. Content of the RECs is
   still supported by correctly classed rows. Validator did not rewrite
   evidence lists.
4. Shared **`RSK-001`…`RSK-009`** and **`OQ-001`…`OQ-006`** are now minted.
   leftovers and score-harness must continue from the unused bottom
   (`RSK-010+`, `OQ-007+`).

## Mechanical Corrections

Applied to [`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md)
only. No research, citations, findings, or recommendations invented.

1. **Evidence Spikes later-measure restatement.** Charter §9 and the
   commissioning prompt require `None in this repo.` *then* the later measure.
   REC-001, REC-002, REC-004, and REC-009 already did this. Copied a short
   pointer from each REC’s existing Later measure field into Evidence Spikes
   for REC-003, REC-005, REC-006, REC-007, REC-008, REC-010, REC-011.
2. **Source ledger.** Added the already-footnoted OTP Processes page
   (`[^otp-proc]`, https://www.erlang.org/doc/system/ref_man_processes.html,
   accessed 2026-08-15, tier 1). It was cited in the G-002 ladder and missing
   from §18.

No trailing whitespace, heading-hierarchy breaks, or malformed fences found.
In-repo Markdown links from the report resolve (`docs/00-program-blueprint.md`,
`docs/01-research-charter.md`, `docs/working/SORT.md`,
`docs/working/DISCOVERY-NOTES.md`). Relative Arvo paths from
`docs/reports/` (`../../../coding-agent-harness/arvo/…`) point at the sibling
instrument tree and the cited files exist.

Spot-check of load-bearing checkout claims (read-only; no boot, no `mix`):
`application.ex` children + Focus `Task.start` + halt-on-quit comment;
`focus.ex` default `System.stop/1`; `bin/arvo` → `mix run --no-halt`;
`mix.exs` cookie `"arvo_headless"`; loader `mix compile` + `Code.append_path`;
FFF `otp_app: :arvo`; `Session.get` from `tui.ex`; no `Node` / `:peer` /
`net_kernel` in `lib/`; no `arvo attach` symbol; deadlock-doc path from the
2026-08-14 snapshot is absent. Matches the report’s tree-description rows.

José tweets cited as official claims exist and match the quoted wording
(status `2088186994849468659`, `2088208133487264078`, 14 Aug 2026).

## Substantive Defects

None.

## Identifier Audit

| Namespace | This report | Range / uniqueness | Notes |
| --------- | ----------- | ------------------ | ----- |
| REC | `REC-001`…`REC-011` | Runtime `REC-001`…`REC-099` | Sequential; one host primitive each; no cross-test merge |
| RSK | `RSK-001`…`RSK-009` | Shared `RSK-001`…`RSK-999` | First mint in the program (`decisions/` empty) |
| OQ | `OQ-001`…`OQ-006` | Shared `OQ-001`…`OQ-999` | First mint; none blocking for *catalog* honesty |
| EVD | `EVD-001`…`EVD-028` | Optional per report | No other report EVDs exist |
| DEC | none | — | Matches “none exist” |
| SPK | unused | Forbidden here | No `docs/evidence/SPK-*`; §7 is `None in this repo` |
| REQ / FND / PHASE / MS | none | Later spine | Correctly omitted |
| Intake IDs | `G-001`…`G-003` cited; `H-` / `P-` / `XB-` cited | Not reused as `REC` numbers | Graduate labels stay intake IDs |

`decisions/` contains only `README.md`.
[`docs/reports/`](../reports/) has this report and `README.md` only — no
leftovers or score-harness `REC-100+` / `REC-200+`.

## Citation Audit

Portable Markdown links, numbered footnotes, and a source ledger with URLs or
paths and access dates (2026-08-15). No ephemeral UI tokens.

Cited as evidence: accepted Blueprint and Charter; SORT / DISCOVERY-NOTES as
framing; OTP 29.0.5 and Elixir 1.20.3 / Livebook 0.19.9 official pages; José
tweet URLs; dated Arvo paths. Root `HANDOFF.md`, the commissioning prompt, and
the attachment manifest are **not** cited as evidence (HANDOFF is named only as
something not to cite). Exa is classified as retrieval, not a source tier
(EVD-028 → Methodology).

Arvo-tree ledger rows are **verified facts about source / git / this
checkout**, with Limitations that function is unproven. José tweets are
official claims, not measurements. Popularity / star counts are not used.

## Scope Audit

The artifact is a catalog of three host primitives. It does not implement
them, boot Arvo, mint `SPK-###`, open intake, invent G-006, or design G-004 /
G-005.

- [`docs/reports/11-leftovers-research-report.md`](../reports/11-leftovers-research-report.md)
  and [`docs/reports/12-score-harness-research-report.md`](../reports/12-score-harness-research-report.md)
  do **not** exist.
- [`docs/evidence/`](../evidence/) and [`decisions/`](../../decisions/) still
  contain only README files.
- Accepted Blueprint and Charter headers still show `Status: Accepted` and
  the same accepting commits; this validator did not edit them.
- Watch items (WASM / Luerl, vendor boxes, FLAME) stay Watch. Translate
  clusters are treated as mechanisms of the three tests, not new headlines.
- Authority: Blueprint §7 inherited, not re-litigated. “In the tree” is
  repeatedly a checkout description.

Author-session allowed paths (commissioning prompt) vs tree:

| Path | Present / state | Allowed? |
| ---- | --------------- | -------- |
| `docs/reports/10-runtime-research-report.md` | Filled draft | Yes — required output |
| `docs/working/DISCOVERY-NOTES.md` | Pointer line to the draft report | Yes — optional extra |
| `research-program.toml` | `runtime.status = "awaiting-validation"`; `accepted_commit = ""` | Yes — must not set `accepted` |
| `docs/validations/10-runtime-research-validation.md` | This file | Yes — independent validator only |
| leftovers / score-harness reports | Absent | Yes |
| Accepted Blueprint / Charter | Unchanged by this validator | Must not edit |

## Git Diff Audit

Not performed. Commissioning instruction: **do not run git.** Did not commit.
Did not `git add`. Did not set `runtime.status = "accepted"`.

Scope conclusion is from tree inspection and the paths above, not from a diff.

## Required Next Action

Validation **passes with mechanical corrections**. Leave
`runtime.status = "awaiting-validation"` until the human accepts and records
the accepting commit. Do **not** mark the stage `accepted`. Do **not** start
leftovers or score-harness *in this validation session*. Those tracks may run
in parallel after Charter acceptance; they may **cite** this report only once
it is accepted.

Human (Robert):

1. Review the filled runtime report (mechanical Evidence Spikes / source-ledger
   nits already applied).
2. Commit if accepted as a non-accepting snapshot, or as the accepting commit.
   Suggested message (from the attachment manifest):

   ```text
   docs: add runtime research report (not accepted)
   ```

3. Only the accepting commit may set `runtime.status = "accepted"` and record
   `accepted_commit`.
4. After acceptance, leftovers (`REC-100`…`REC-199`) and score-harness
   (`REC-200`…`REC-299`) remain legal Group A work in **separate** fresh
   sessions. Continue shared IDs from `RSK-010` and `OQ-007`.
