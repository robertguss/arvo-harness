# Validation Report — 12-score-harness-research

- **Result:** Pass
- **Validator:** Independent Validation Agent (`research-validate`)
- **Date:** 2026-08-15
- **Artifact path:** [`docs/reports/12-score-harness-research-report.md`](../reports/12-score-harness-research-report.md)
- **Commissioning prompt:** [`docs/prompts/12-score-harness-research-prompt.md`](../prompts/12-score-harness-research-prompt.md)
- **Git commit reviewed:** Not inspected. This validation was commissioned with **do not run git**. Working-tree artifact; `research-program.toml` `score-harness.status` = `awaiting-validation`; `accepted_commit` empty.

## Checks Performed

| Check | Result |
| ----- | ------ |
| Required 19 report-contract headings present and filled | Pass (`## 1`–`## 19`) |
| Artifact metadata and actual research date | Pass (header + §1; research date 2026-08-15) |
| `REC-200`…`REC-299` only; no reuse of `REC-001`…`REC-011` or `REC-100`…`REC-115` as this report’s numbers | Pass (`REC-200`…`REC-210`; runtime / leftovers IDs cited as inherited only) |
| Each scoring-method `REC` tags G-004 **or** G-005 (not both) + claim + later measure + keep/drop | Pass (`REC-200`–`REC-207`) |
| Watchlist leftover-disposition RECs may have host **none** | Pass (`REC-208`…`REC-210`) |
| Standard recommendation template fields present | Pass (all 11 `REC`s) |
| Charter catalog extras + score-harness extra on scoring-method `REC`s | Pass |
| Evidence Ledger completeness (Charter fields) | Pass (see observations) |
| method paper ≠ run; leftover ≠ proven adaptation | Pass (ledger footer; Medium/Low on holdout / proposer; §13) |
| G-004 and G-005 still split; cousin not merged | Pass (`REC-205`; §2 split table; §8.1) |
| Scorer-read-only, frozen-model, one-primary-before-run explicit | Pass (`REC-201`, `REC-202`) |
| G-005 three arms; local may lose; nested prompt is a drop | Pass (`REC-203`, `REC-206`; §8.5) |
| `OQ-011` / `REC-111` / `REC-112` dispositioned; GEPA/ACE still Watch above G-004 | Pass (`REC-208`, `REC-209`; `OQ-011` answered, not reminted) |
| No invented Harbor number as a run result | Pass |
| No `SPK-###`; no sixth test | Pass |
| Intake not reopened | Pass |
| Exa REST or documented skip/failure | Pass (ordinary `type` `auto`, HTTP 200; no Agent / deep) |
| `RSK-019+` / `OQ-013+` | Pass (`RSK-019`…`RSK-029`; `OQ-013`…`OQ-018`) |
| Citation portability (no HANDOFF / prompt / chat as evidence) | Pass |
| Completion checklist truthfulness (last two items unchecked) | Pass |
| `score-harness.status` is not `accepted` | Pass (`awaiting-validation`) |
| No synthesis file written | Pass (spec / plan / review skeletons still `Placeholder — not accepted`) |
| High confidence not used on “holdout would rise” | Pass |
| Identifier ranges and uniqueness | Pass |
| Placeholder remnants | Pass |
| Internal contradictions vs accepted Blueprint locks | Pass |
| Required tables (split G-004 vs G-005; judge fence; G-004 loop recipe; G-005 arms; runtime inheritance; leftovers disposition; Evidence Ledger; Recommendation ledger; Source ledger) | Pass (see observations on leftovers-disposition table shape) |
| Handoff Digest fields | Pass (all 11 contract fields) |
| Evidence Spikes: `None in this repo` then later measure | Pass (§7 and every `REC`) |
| `just check` | Pass (static: required tree + accepted-stage outputs; score-harness not accepted) |

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
and leftovers accepting commits as *must cite*, ranges used, spikes unused,
accepting commit empty). Section 1 restates the primary question.

Track bar (Charter §10 score-harness / Blueprint §11 score-harness row):

- G-004 and G-005 stay two tests. No G-006. Cousin not merged (`REC-205`).
- Scorer / judge tree, holdout, and `program.md` are read-only (`REC-201`).
- Model frozen; one primary declared before the run (`REC-202`).
- G-005 is own Session + three arms; local may lose; nested prompt is a
  drop (`REC-203`, `REC-206`).
- Loop is not Arvo’s identity (`REC-204`, `REC-207`).
- Proposer slot named *above* G-004 and left Watch (`REC-208` / `OQ-011`).
  `REC-111` stays Watch. Layer watches stay Watch, not G-006 (`REC-209` /
  `REC-112`). Searcher-meta stays Watch (`REC-210`).
- High confidence is reserved for locks and dated page / source-text
  *wording*. “Holdout would rise” and “a proposer would help” stay Medium
  or Low.
- Methodology documents Exa REST ordinary lookup on four official-Harbor
  queries. No arXiv harvest. Already-cited GEPA / ACE abstracts re-opened.
- Report states no `SPK-###` and no Harbor run or Arvo command as a test.

Checklist: items 1–13 may be checked. **Human accepts report** and **Manifest
updated; accepting commit recorded** are unchecked. Required: there is no
accepting commit. The “plain-language summary shown to Robert” box is checked
as a session message; this validator did not see that message and does not
treat the checkbox as independent proof.

Non-blocking observations (not revision triggers):

1. **Leftovers-disposition table shape.** The prompt’s × list asks for
   `REC-111` (slot yes/no, still Watch) × `REC-112` (what a judge may watch,
   still Watch, not G-006) × `OQ-011` answer. Those three cells are answered
   in §2, §8.7, `REC-208`, `REC-209`, and the `OQ-011` disposition. There is
   no single three-column leftovers-disposition table. Validator did not
   invent one.
2. **Compound EVD classifications.** EVD-204 (`Official claim / verified
   fact about document`), EVD-210 (`Architectural judgment accepted with
   leftovers`), EVD-212 (`User decision / framing`), and EVD-219
   (`Architectural judgment (upstream)`) name more than one Charter §8
   class. Each row is otherwise complete and limited correctly. Validator
   did not reclassify.
3. **Compound evidence-quality / confidence lines** on several `REC`s
   (e.g. REC-200 `Strong as lock; Weak as empirical pass`). The bodies
   already split lock vs empirical pass. Validator did not invent a single
   grade.
4. **Ledger Downstream ↔ REC Evidence lists** are not 1:1. EVD-213 /
   EVD-215 / EVD-218 name REC-200 while that `REC` Evidence list cites
   earlier rows. Content is still supported. Validator did not rewrite
   evidence lists.
5. **EVD-205 page attribution.** “Separate will soon become the default”
   is official Harbor wording on the Regrade page (also cited as EVD-206 /
   `[^harbor-regrade]`). EVD-205 attributes that clause to Task Structure
   along with the shared-default / separate-mode / sidecar anti-cheat
   sentences that *are* on Task Structure. The claim is not invented.
   Validator did not move the citation.

## Mechanical Corrections

None. No trailing whitespace, heading-hierarchy breaks, or malformed fences
found. No mechanical metadata typos found. Every `REC` already restates
`None in this repo.` then the later measure under Evidence Spikes.

In-repo Markdown links from the report resolve
(`docs/00-program-blueprint.md`, `docs/01-research-charter.md`,
`docs/reports/10-runtime-research-report.md`,
`docs/reports/11-leftovers-research-report.md`,
`docs/working/SORT.md`, `docs/working/DISCOVERY-NOTES.md`,
`../coding-agent-harness/arvo/rel/RELEASE.md`,
`../coding-agent-harness/arvo/lib/arvo/application.ex`,
`../coding-agent-harness/arvo/lib/arvo/session/audit.ex`).

Opened the cited Harbor official pages and the already-cited GEPA / ACE
abstracts only to verify official wording already claimed. Opened the named
Arvo source files only to confirm claimed text and that `evals/` is absent.
Did not open bookmark JSON, PDFs, vault traces, or Watch dump files. Did
not boot Arvo. Did not run Harbor. Did not treat this as a new research
pass.

## Substantive Defects

None.

## Identifier Audit

| Namespace | This report | Range / uniqueness | Notes |
| --------- | ----------- | ------------------ | ----- |
| REC | `REC-200`…`REC-210` | Score-harness `REC-200`…`REC-299` | Sequential; scoring-method RECs one host each (G-004 or G-005); Watchlist leftover-disposition RECs host **none**; runtime `REC-001`…`REC-011` and leftovers `REC-100`…`REC-115` cited, not reminted |
| RSK | `RSK-019`…`RSK-029` | Shared `RSK-001`…`RSK-999` | Continues after leftovers `RSK-010`…`RSK-018` |
| OQ | `OQ-013`…`OQ-018`; `OQ-011` dispositioned | Shared `OQ-001`…`OQ-999` | Continues after leftovers `OQ-007`…`OQ-012`; `OQ-011` answered in place, not reminted; `OQ-007` left leftovers-named |
| EVD | `EVD-200`…`EVD-219` | Optional per report | No collision with runtime `EVD-001`…`EVD-028` or leftovers `EVD-100`…`EVD-115` |
| DEC | none | — | Matches “none exist” |
| SPK | unused | Forbidden here | No `docs/evidence/SPK-*`; §7 is `None in this repo` |
| REQ / FND / PHASE / MS | none | Later spine | Correctly omitted |
| Intake IDs | `G-001`…`G-005` cited; `H-` / `P-` / `V-` / `XB-` / `LC-` cited | Not reused as `REC` numbers | Graduate labels stay intake IDs |

`decisions/` contains only `README.md`.
[`docs/reports/`](../reports/) has the accepted runtime report, accepted
leftovers report, this score-harness draft, and `README.md` — no later
`REC-300+`.

Scoring-method host tags (not both):

| REC | Host | Extra sentence |
| --- | ---- | -------------- |
| REC-200 | G-004 | Fixed-set lab loop; not the cousin |
| REC-201 | G-004 | Fixed-set lab loop; not the cousin |
| REC-202 | G-004 | Fixed-set lab loop; not the cousin; explicitly does not tag G-005 |
| REC-203 | G-005 | Specialists + three arms; local may lose |
| REC-204 | G-004 | Fixed-set lab loop; not the cousin |
| REC-205 | G-004 | Rejected cousin merge |
| REC-206 | G-005 | Nested prompt is a drop |
| REC-207 | G-004 | Rejected searcher-as-product |
| REC-208 | none | Watchlist; dispositions `REC-111` / `OQ-011` |
| REC-209 | none | Watchlist; dispositions `REC-112` |
| REC-210 | none | Watchlist; searcher-meta not silently lost |

## Citation Audit

Portable Markdown links, numbered footnotes, and a source ledger with URLs or
paths and access dates (2026-08-15). No ephemeral UI tokens.

Cited as evidence: accepted Blueprint and Charter; accepted runtime report;
accepted leftovers report; SORT Graduate G-004 / G-005 as framing;
DISCOVERY-NOTES locked top as framing; Harbor official docs (Motivation,
Task Structure, Evals, Regrade, Agents, Core Concepts); already-named GEPA
and ACE abstracts; dated Arvo source text at `84004e1`. Root `HANDOFF.md`,
the commissioning prompt, and the attachment manifest are **not** cited as
evidence (HANDOFF is named only as something not to cite). Exa is classified
as retrieval, not a source tier.

Spot-check of load-bearing official wording (pages opened 2026-08-15 by this
validator, not as a new harvest):

- Harbor Motivation: evaluating *and optimizing* agents; GEPA listed as an
  optimizer integration.
- Harbor Task Structure: `instruction.md` / `task.toml` / `environment/` /
  optional `solution/` / `tests/`; reward in `/logs/verifier/reward.txt` or
  `reward.json`; `reward.json` preferred then `reward.txt`; default verifier
  **shared**; separate mode for graders the agent must not see; sidecar
  anti-cheat (channel the agent container cannot write).
- Harbor Evals: `harbor run -p` / `-d` / `-m` / `-a`; job `result.json` plus
  per-trial `verifier/reward.txt`.
- Harbor Regrade: agent phase held fixed; source trials not modified;
  multi-step unsupported; separate mode recommended and “will soon become
  the default.”
- Harbor Agents: external `BaseAgent` vs installed `BaseInstalledAgent`
  (headless in the container).
- GEPA abs v2 (2026-02-14): sample trajectories, natural-language
  reflection, prompt updates, Pareto front.
- ACE abs v3 (2026-03-29): generate / reflect / curate playbook; brevity
  bias and context collapse; offline *and* online adaptation.

Paper rows are **official claims about those documents**, with Limitations
that leftover ≠ proven adaptation and that paper numbers are *their*
results. Popularity / star counts are explicitly not used. No Arvo-tree row
claims function. Missing `evals/` is recorded as absence, not as a Harbor
number this lab ran.

## Scope Audit

The artifact names two scoring methods. It does not implement them, boot
Arvo, run Harbor, mint `SPK-###`, open intake, invent G-006, merge the
cousin into G-004, or land the searcher as Arvo’s identity.

- [`docs/specifications/01-definitive-specification.md`](../specifications/01-definitive-specification.md)
  and the revised-spec / plan / review skeletons remain
  `Placeholder — not accepted`. Synthesis was not started.
- [`docs/evidence/`](../evidence/) and [`decisions/`](../../decisions/) still
  contain only README files.
- Accepted Blueprint and Charter headers still show `Status: Accepted` and
  the same accepting commits; this validator did not edit them.
- Accepted runtime report still shows `Status: Accepted` at
  `636123f1a628803aa4ae2c44fc4659d167a80693`; this validator did not edit it.
- Accepted leftovers report still shows `Status: Accepted` at
  `9698362dbe5f90ff48e7aa1093d547d2e14d410a`; this validator did not edit it.
- Runtime Required drops (auto-resume, shared cookie, Port-wrap, Mix-in-VM,
  relups) are inherited as forbidden keeps, not contradicted.
- `REC-111` / `REC-112` stay Watch. `OQ-011` is answered: yes, a proposer
  slot above G-004 is named; it stays Watch.
- Authority: Blueprint §7.15–§7.16 and §22 inherited, not re-litigated.

Author-session allowed paths (commissioning prompt) vs tree:

| Path | Present / state | Allowed? |
| ---- | --------------- | -------- |
| `docs/reports/12-score-harness-research-report.md` | Filled draft | Yes — required output |
| `docs/working/DISCOVERY-NOTES.md` | Pointer line to the draft report | Yes — optional extra |
| `research-program.toml` | `score-harness.status = "awaiting-validation"`; `accepted_commit = ""` | Yes — must not set `accepted` |
| `docs/validations/12-score-harness-research-validation.md` | This file | Yes — independent validator only |
| Synthesis / spec / plan / review | Still placeholders | Yes — must not fill |
| Accepted Blueprint / Charter / runtime / leftovers | Unchanged by this validator | Must not edit |
| SORT substance | G-004 / G-005 rows unchanged on inspection | Must not re-sort |

`just check` rules from `scripts/check_program.py` applied by tree
inspection (this session has no shell): required files and dirs present;
accepted stages’ outputs exist and are not placeholders; score-harness is
not `accepted`, so the script would not treat this draft as an accepted
output. Expected result: `check: OK`.

## Git Diff Audit

Not performed. Commissioning instruction: **do not run git.** Did not commit.
Did not `git add`. Did not set `score-harness.status = "accepted"`.

Scope conclusion is from tree inspection and the paths above, not from a diff.

## Required Next Action

Validation **passes**. Leave
`score-harness.status = "awaiting-validation"` until the human accepts and
records the accepting commit. Do **not** mark the stage `accepted`. Do
**not** start synthesis *in this validation session*. Synthesis remains
legal only after acceptance, in a **separate** fresh session; it may
**cite** this report only once this report is accepted.

Human (Robert):

1. Review the filled score-harness report.
2. Commit if accepted as a non-accepting snapshot, or as the accepting commit.
   Suggested message (from the attachment manifest):

   ```text
   docs: add score-harness research report (not accepted)
   ```

3. Only the accepting commit may set `score-harness.status = "accepted"` and
   record `accepted_commit`.
4. After acceptance, synthesis remains legal Group-spine work in a **fresh**
   session. Continue shared IDs from `RSK-030` and `OQ-019`.
