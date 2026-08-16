# Validation Report — 01-research-charter

- **Result:** Pass
- **Validator:** Independent Validation Agent (`research-validate`)
- **Date:** 2026-08-14
- **Artifact path:** [`docs/01-research-charter.md`](../01-research-charter.md)
- **Commissioning prompt:** [`docs/prompts/01-research-charter-prompt.md`](../prompts/01-research-charter-prompt.md)
- **Git commit reviewed:** Working-tree file (uncommitted). `main` HEAD is
  `5033626e9b1ddea66ba62b11bcdf1cad107c3e36`
  (`docs: install Charter stage package (prompt-ready)`). Discovery remains
  accepted at `0b49540cae7d2a30ad4b4b145999e27b82c50dad`.

## Checks Performed

| Check | Result |
| ----- | ------ |
| Required 19 contract sections present (`## 1`–`## 19`) and project-specialized | Pass |
| Artifact metadata complete | Pass |
| No `Status: Placeholder — not accepted` on the Charter itself | Pass (`Draft — not accepted`) |
| Status is not Accepted | Pass |
| Completion checklist truthfulness (last two items unchecked) | Pass |
| Identifier ranges: Charter mints none; later ranges match Blueprint | Pass |
| Citation portability | Pass |
| Evidence Ledger / REC disposition / report Handoff Digest | N/A (Charter, not a focused report) |
| No sixth headline test invented | Pass |
| `SPK-###` unused; spikes forbidden in this repo | Pass |
| “In the tree ≠ works” / checkout description ≠ function | Pass |
| Popularity is not proof | Pass |
| G-004 not merged with “improves while you use it” | Pass |
| Scope: no focused reports, no code, five tests still five | Pass |
| Authority: Blueprint locks not re-opened; chat not cited as authority | Pass |
| Manifest `charter.status` not `accepted` | Pass (left `prompt-ready`) |
| Allowed file scope of the author session | Pass |
| Placeholder remnants (`_To be filled_`, `{{PROJECT_NAME}}`) as unfinished prose | Pass (mentioned only as forbidden) |
| Internal contradictions vs accepted Blueprint | Pass |
| `just check` | Pass (`check: OK`) |

All 19 required sections from
[`program/contracts/research-charter.md`](../../program/contracts/research-charter.md)
are present as `## 1`–`## 19` and contain project-specific rules, not empty
stubs and not `_To be filled_`:

1. Artifact Metadata
2. Research Philosophy
3. Scope Discipline
4. Source Hierarchy
5. Citation Rules
6. Current-Information Rules
7. Evidence-Spike Protocol
8. Evidence Ledger Format
9. Recommendation Format
10. Evaluation Rubric
11. Confidence Model
12. Risk and Open-Question Format
13. Replication and Reconciliation Protocol
14. Synthesis Rules
15. Adversarial-Review Rules
16. Validation Rules
17. Handoff Rules
18. Anti-Patterns
19. Completion Standards

Header metadata is complete (type, program, status, version, dates, Blueprint
dependency with accepting commit). Section 1 names owner, repository, local
tree, instrument path, `ore/` ignore rule, focused rigor, replication off,
spikes unused, and no identifiers minted here.

Locked-context fidelity (commissioning prompt + Blueprint §7): personal lab;
catalog-only; five tests `G-001`…`G-005` only; three workstreams after Charter;
intake closed; no spikes / evals / Harbor / PRs here; Arvo is instrument not
daily driver; adaptation not photocopy / Port-as-native is a shell; G-004
fixed-set lab loop unmerged from its cousin; G-005 specialized helpers with
three arms and local-may-lose; focused rigor; “implementation plan” sequences
hypotheses; phase-2 Arvo smoke check *there*.

Checklist:

- Sections specialized, source/citation rules, and ledger/`REC` formats may be
  checked (they are filled).
- **Human accepts Charter** and **Manifest updated; accepting commit recorded**
  are unchecked. That is required: there is no accepting commit.

Non-blocking observation (not a revision trigger): §19 says this draft “meets
item 1 only after a human and a validator have done items 2–4.” Operational
status, the unchecked last two checklist boxes, and the following “Do not treat
this draft as accepted” already prevent premature acceptance. The validator did
not rewrite that sentence.

## Mechanical Corrections

None. No trailing whitespace, heading-hierarchy breaks, malformed fences, or
broken internal links found. No mechanical metadata typos that required an
edit. Twenty-three Markdown links resolve (in-repo paths exist; GitHub repo URL
matches `remote.origin.url`).

## Substantive Defects

None.

## Identifier Audit

| Namespace | Charter statement | Blueprint / manifest | Notes |
| --------- | ----------------- | -------------------- | ----- |
| (minted here) | none | Charter stage allocates none | No `DEC` / `REC` / `RSK` / `OQ` / `SPK` / `EVD` minted |
| REC | 001–099 runtime; 100–199 leftovers; 200–299 score-harness | same; stage `recommendation_range` matches | Range lock only |
| REQ | REQ-001..REQ-299 at synthesis | same | Reserved |
| FND | 001–199 spec; 200–399 plan | global `FND-001..FND-999`; stage ranges match the split | Unused 400–999 is idle |
| RSK / OQ | 001–999 shared; minted by the finding stage | same | None minted |
| SPK | unused in this repo; do not back-fill from phase-2 | reserved; **do not use here** | Consistent |
| EVD | optional per report; no cross-report reuse | not a Blueprint allocation | Not minted |
| PHASE / MS | not allocated here | plan stage | Correctly omitted |

Intake labels `G-001`…`G-005` and dump `H-` / `P-` / `V-` / `XB-` / `LC-` are
declared as intake IDs, not `REC`/`REQ`. No ID reuse. No `DEC` minted, matching
the attachment manifest.

## Citation Audit

Citations are portable Markdown links to in-repo paths (accepted Blueprint,
`docs/working/SORT.md`, `docs/working/DISCOVERY-NOTES.md`,
`program/contracts/*`, `program/templates/*`, `program/reference/*`,
`program/operator/*`) plus the GitHub repo URL.

No ephemeral UI citation tokens. Root `HANDOFF.md` is named only as something
**not** to cite as authority, which the commissioning prompt allows.

Evidence Ledger is specified for later reports; the Charter itself is not
required to carry one.

## Scope Audit

The file is methodology. It tells later `runtime` / `leftovers` /
`score-harness` sessions how to classify claims (especially tree-description vs
function, paper leftover vs proven adaptation). It does not write those
reports, change the five tests, re-sort intake, or run Arvo.

- [`docs/reports/`](../reports/) still contains only `README.md`.
- [`docs/evidence/`](../evidence/) and [`decisions/`](../../decisions/) still
  contain only README files (`SPK` / `DEC` unused).
- Five headline tests remain five. G-006 appears only as a forbidden invention.
- G-004 remains a lab loop on a **fixed** test set, repeatedly split from
  “improves while you use it.”
- Source hierarchy keeps the five default tiers and adds the required program
  notes (José tweets = official claims; grounding snapshot / `arvo/` source =
  checkout description; Harbor-style papers inform design, not results run
  here). Popularity / star counts are tier 5 and insufficient for a load-bearing
  `REC`.
- Spike rule: do not mint `SPK-###` here; name what phase-2 would measure.
- Authority follows
  [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).
  Accepted Blueprint §7 is inherited, not re-litigated. Chat, model memory,
  `HANDOFF.md`, manifests, and `research-program.toml` are not citable
  authority.

## Git Diff Audit

Inspected `git status` and `git diff --stat` only. Did not commit. Did not
`git add`.

Author-session scope vs
[`docs/prompts/01-research-charter-prompt.md`](../prompts/01-research-charter-prompt.md)
allowed extras:

| Path | Change | Allowed? |
| ---- | ------ | -------- |
| `docs/01-research-charter.md` | Skeleton replaced (631-line fill) | Yes — required output |
| `docs/working/DISCOVERY-NOTES.md` | One pointer line at the top (“Charter … filled, not accepted”) | Yes — optional extra |
| `research-program.toml` | Unchanged; `charter.status = "prompt-ready"`; `accepted_commit = ""` | Yes — must not set `accepted` |
| `docs/00-program-blueprint.md` | Unchanged | Yes |
| `docs/working/SORT.md` | Unchanged | Yes |
| `docs/reports/*` | Unchanged (README only) | Yes |
| `docs/handoffs/charter-attachment-manifest.md` | Unchanged | Yes (tighten optional) |

Untracked PDFs under `docs/working/arxiv-home/ai-papers/` are the pre-existing
laptop stash indexed earlier (`043a770`). They are not Charter-session outputs.

Validator did **not** set `charter.status = "accepted"`.

## Required Next Action

Validation **passes**. Leave `charter.status = "prompt-ready"` until the human
accepts and records the accepting commit. Do **not** start a focused research
report in this session.

Human (Robert):

1. Review the filled Charter.
2. Commit if accepted as a non-accepting snapshot, or as the accepting commit.
   Suggested message (from the commissioning prompt):

   ```text
   docs: fill Research Charter from accepted Blueprint (not accepted)
   ```

3. Only the accepting commit may set `charter.status = "accepted"` and record
   `accepted_commit`.
4. After acceptance, the next legal work is to **package** Group A
   (`runtime`, `leftovers`, `score-harness`) for **separate** fresh sessions.
   Do not write those reports here.
