# Validation Report — 14-specification-adversarial-review

- **Result:** Pass with mechanical corrections
- **Validator:** Independent Validation Agent (`research-validate`)
- **Date:** 2026-08-15
- **Artifact path:** [`docs/reviews/01-specification-adversarial-review.md`](../reviews/01-specification-adversarial-review.md)
- **Commissioning prompt:** [`docs/prompts/14-specification-adversarial-review-prompt.md`](../prompts/14-specification-adversarial-review-prompt.md)
- **Git commit reviewed:** Working-tree artifact. This validation was commissioned **not** to treat any commit as accepting. Inspected `git status --short` and `git diff --stat` for scope only. Did not `git add`, commit, or set `spec-review.status = "accepted"`. HEAD is `93b56d4a32a1b41b32057041e4b029ea0991b70f` (synthesis accepting-commit recording). Subject specification accepting commit remains `26bd0e4070ef822bdcd5c69d5f57a2a80131176f`. `research-program.toml` `spec-review.status` = `awaiting-validation`; no `accepted_commit` on that stage.

## Checks Performed

| Check | Result |
| ----- | ------ |
| All 7 numbered headings present and filled | Pass (`## 1`–`## 7`; subsections allowed) |
| Metadata and status `Proposed — pending independent validation` | Pass (header + §1 Review status; two-layered human-acceptance banner) |
| Attacks attempted table covers every required attack | Pass (13 rows; see below) |
| Findings use `FND-001`…`FND-199` only and are sequential | Pass (`FND-001`…`FND-003`; no reserved gaps; no `FND-200+`) |
| Every minted finding has the full finding template | Pass (17 fields × 3; see Identifier Audit) |
| “No defect” attacks do not mint decorative `FND`s | Pass (ten clean rows have `—`; only judge-eaten / thin / merged mint) |
| No feature ideation disguised as defects | Pass (see Scope Audit) |
| Five tests still five in every proposed diff; no G-006 | Pass |
| Proposed diffs do not merge G-004 with its cousin | Pass (`FND-001` Required Correction refuses the cousin) |
| Proposed diffs do not land the searcher as identity | Pass (no searcher-as-product text; §5 would-delete keeps `REQ-037` / `REQ-039`) |
| `OQ-011` remains closed; Watch shelves remain Watch unless a finding *shows* promotion | Pass (none showed promotion; `REQ-043` still closes `OQ-011`) |
| No `REQ` / `REC` / `RSK` / `OQ` / `EVD` / `SPK` / `PHASE` / `MS` minted | Pass (cited only) |
| No Harbor run; no Arvo command as a test | Pass (§2 “What was not read or run”) |
| Intake not reopened | Pass |
| Exa REST or documented skip | Pass (§2: **Exa did not run**; documented skip, not a pretend run; MCP not used) |
| Citation portability (no prompt / manifest / chat / handoff map as evidence) | Pass (see Citation Audit) |
| Gate is Open \| Conditional \| Blocked with the catalog-as-agenda reading | Pass (**Conditional**; one High; not Elixir-here) |
| Additional-round recommendation follows the risk-triggered policy (not automatic) | Pass (**No**; normal spec-revision) |
| Checklist truthfulness | Pass (see note) |
| `spec-review.status` is `awaiting-validation`, NOT `accepted` | Pass |
| No revised spec or plan file written | Pass (`02-*.md` and plan / plan-review skeletons still `Placeholder — not accepted`) |
| Identifier ranges: `FND-001`…`FND-003` sequential; no remint of taken IDs | Pass |
| Placeholders gone from the review | Pass (no `Skeleton only` / `Placeholder — not accepted`; the word “Placeholder” appears only as a *not-read* item) |
| Internal contradictions vs Blueprint locks | Pass (locks preserved; findings attack failed *preservation* of accepted bars, not the locks) |
| `just check` | Pass (`check: OK`; tree sanity only) |

All 7 required headings from
[`program/contracts/adversarial-review.md`](../../program/contracts/adversarial-review.md)
and the commissioning prompt’s Exact review structure are present
and filled:

1. Artifact Metadata
2. Review Scope and Method
3. Executive Assessment
4. Findings
5. Cross-Cutting Issues
6. Implementation Gate Recommendation
7. Whether an Additional Review Round Is Recommended

Then the Completion Checklist.

Header metadata is complete (type, program, status `Proposed —
pending independent validation`, human acceptance 2026-08-15,
version, created/updated 2026-08-15, subject path, subject accepting
commit `26bd0e4`, finding range `FND-001`…`FND-003` allocated
`FND-001`…`FND-199`). Section 1 restates reviewer role (adversarial;
not the synthesizer; not the mechanical validator), subject status
(`Proposed — pending adversarial review`; not implementation
authority), and the catalog reading of “blocks implementation.”

Attacks attempted (one row per required subsidiary question):

| Attack | Review result | Validator |
| ------ | ------------- | --------- |
| G-004 collapse | No defect | Pass — spec still refuses “improves while you use it” (`REQ-038`); leftover-verb hole is `FND-001`, not a cousin merge |
| In the tree ⇒ works | No defect | Pass — checkout ≠ score (`REQ-006`) not treated as a passing product |
| Sixth test | No defect | Pass — no G-006; diffs stay inside G-004 / G-005 |
| Port-as-native / Elixir-LangGraph | No defect | Pass — `REQ-016` (foreign-harness shell) and `REQ-025` (official RLM Port on hands) remain distinct |
| Plan-as-backlog / this-spec-as-tickets-here | No defect | Pass — `REQ-001` / `REQ-010` / `RSK-030`; no `PHASE` / `MS` |
| Opened intake or daily-driver drift | No defect | Pass |
| Judge eaten | Defect `FND-002` | Pass — real shorter fence vs score-harness §8.2 |
| Helper is a prompt | No defect | Pass — `REQ-041` still drops a nested prompt; three arms and local-may-lose remain |
| Searcher as Arvo’s identity | No defect | Pass |
| Invented Harbor number | No defect | Pass |
| Thin | Defect `FND-001`…`FND-003` | Pass — keep/drop and fence holes, not empty architecture |
| Merged | Defect `FND-001`, `FND-003` | Pass — Accepted `REC` nuance loss, not a Watch promotion |
| Over-confident | No defect | Pass — spec `REQ-009` and §19 still keep “holdout would rise” off High |

Quoted evidence for the three findings was checked against the
proposed specification (`26bd0e4`) and the accepted score-harness
report (`c15dd31`):

- **`FND-001`:** §5 row-4 try-column says leftover tests “must also
  **improve**.” §16 says leftover G-001…G-003 measures “must not
  **collapse**.” `REQ-034` keep names honesty collapse and omits
  leftover G-001…G-003. Score-harness §8.2 leftover-test row says
  “Must also improve / not collapse”; `REC-200` later measure is
  “must not collapse”; `REC-200` keep/drop is honesty collapse.
  Three catalog readings are real. Proposed fix keeps five tests
  and refuses the cousin.
- **`FND-002`:** §16 / `REQ-035` name a shorter explicit read-only
  set than score-harness §8.2’s **No** rows (`instruction.md`,
  frozen task list, `solution/solve.sh` omitted or undefined).
  Shared-mode hole and regrade-after-run are preserved. Proposed
  list does not add `environment/` or invent a Harbor number.
- **`FND-003`:** `REC-203` keep/drop drops a sequential V-002
  regression. `REQ-040` / `REQ-042` omit that drop. §16 names the
  split without a keep/drop. Proposed text is a slice, not a sixth
  test and not a second primary.

Gate reading matches the prompt table: one High finding →
**Conditional** (spec-revision must disposition before the catalog
is the sibling-repo agenda). Not Blocked: five tests and the
required fences remain usable *as names*. Not Open. Conditional is
explicitly “ready for spec-revision,” not “write Elixir.”

Additional-round **No** matches
[`program/contracts/adversarial-review.md`](../../program/contracts/adversarial-review.md)
risk-triggered policy: no new machinery, no Critical, one High
(reconciliation of already-accepted `REC-200` / `REC-201` /
`REC-203` bars), default next stage is spec-revision in a fresh
session. Not an automatic second pass.

Checklist truthfulness: process items may be checked. **Human
accepts review** is checked **and** the header / §1 say the human
accepted on 2026-08-15. That pair is **not** a defect. **Independent
validation passed** and **Manifest updated; accepting commit
recorded** remain unchecked. This validator leaves them unchecked
and does not record an accepting commit. The “plain-language
summary shown to Robert” box is checked as a session message; this
validator did not see that message and does not treat the checkbox
as independent proof. Human acceptance of the draft is recorded in
the artifact header.

## Mechanical Corrections

One trailing-whitespace strip in
[`docs/reviews/01-specification-adversarial-review.md`](../reviews/01-specification-adversarial-review.md)
`FND-002` Evidence (hard-break spaces after “undefined as objects:”).
No wording, finding, severity, gate, or citation change.

No heading-hierarchy breaks, malformed fences (none used), or
incorrect internal links found. Nineteen in-repo Markdown links
from the review resolve. No mechanical metadata typos found.

Did not invent missing research, citations, findings,
recommendations, Harbor numbers, or architecture. Did not edit the
proposed specification. Did not edit accepted Blueprint, Charter,
or the three reports. Did not boot Arvo. Did not run Harbor. Did
not write Elixir. Did not open Watch dumps, bookmark JSON, or
unread Articles. Did not print `.env`. Did not treat this as a new
research pass or start spec-revision.

## Substantive Defects

None.

## Identifier Audit

| Namespace | This review | Range / uniqueness | Notes |
| --------- | ----------- | ------------------ | ----- |
| FND | `FND-001`…`FND-003` | Spec-review `FND-001`…`FND-199` | Sequential; no reserved gaps; no `FND-200+` (plan-review) |
| REQ | none minted | `REQ-001`…`REQ-047` taken | Cited as affected (`REQ-034`, `REQ-035`, `REQ-040`, `REQ-042`, plus related `REQ-002`, `REQ-006`, `REQ-016`, `REQ-025`, `REQ-037`, `REQ-039`, `REQ-041`, `REQ-043`…`REQ-046`) |
| REC | none minted | Taken bands cited | `REC-200`, `REC-201`, `REC-203` (and Watch / identity `REC-111` / `112` / `114` / `204` / `207` / `208` / `209` / `210`) cited, not reminted |
| RSK | none minted | `RSK-001`…`RSK-030` taken | `RSK-020`, `RSK-030` cited |
| OQ | none minted | `OQ-001`…`OQ-018` taken; `OQ-011` **closed** | `OQ-001`…`OQ-005`, `OQ-011`, `OQ-013`…`OQ-016` cited; none reopened as if unanswered |
| EVD | none minted | Prefer not to mint | No collision with `EVD-001`…`028`, `100`…`115`, `200`…`219` |
| DEC | none | `decisions/` still README only | Matches “none exist” |
| SPK | unused | Forbidden here | No `docs/evidence/SPK-*` |
| PHASE / MS | unused | Later plan | Affected phases = `none (no PHASE minted)` on every finding |
| G-006 | forbidden only | — | Named as a drop, not minted |
| Intake IDs | `G-001`…`G-005`, `V-002` cited | Not reused as `FND` / `REQ` | Graduate / dump labels stay intake IDs |

Finding template completeness (all required fields filled):

| Field | FND-001 | FND-002 | FND-003 |
| ----- | ------- | ------- | ------- |
| Severity | High | Medium | Medium |
| Confidence | High | High | High |
| Category | thin / contradiction / merged | judge eaten / thin | merged / thin |
| Affected sections | §5 row 4; §16; §22 `REQ-034` | §16; `REQ-035`; §11 noted honest | `REQ-040`/`042`; §16; §5 row 5 |
| Affected requirements | `REQ-034` primary | `REQ-035` primary | `REQ-040`, `REQ-042` |
| Affected phases | none (no PHASE minted) | none (no PHASE minted) | none (no PHASE minted) |
| Blocks implementation | Named later job (G-004 method) | Named later job (G-004 method) | Named later job (G-005 method) |
| Problem … Related Findings | filled | filled | filled |

Severity / confidence match the program readings: High finding = a
named keep/drop is not a single rule; High confidence quotes dated
document text. Alternatives Considered each include “not a defect /
preference” and reject it with an operator-cannot-apply-one-rule
reason. Decorative findings were not minted for the ten clean
attacks.

## Citation Audit

Portable Markdown links to governing artifacts and reports, plus
short accepting-commit hashes. No ephemeral UI tokens. No
numbered-footnote official-URL harvest (none required: Exa skipped;
Harbor / leftover claims travel via the accepted reports).

Cited as evidence: proposed specification (`26bd0e4`); accepted
Blueprint (`0b49540`); accepted Charter (`081ad36`); accepted
runtime report (`636123f`); accepted leftovers report (`9698362`);
accepted score-harness report (`c15dd31`). SORT Graduate G-005 is
named as **framing, not a lock** in `FND-003`. Independent
validation 13 is used as a **map of inspection points**, not as a
finding to ratify.

**Not** cited as evidence: the spec-review commissioning prompt,
[`docs/handoffs/spec-review-attachment-manifest.md`](../handoffs/spec-review-attachment-manifest.md),
chat, or any handoff map. §2 lists chat / model memory / root
handoff maps under “What was not read or run (as evidence).” The
synthesis commission is skimmed “as a map… Not cited as evidence.”

Exa is classified as a documented skip, not a source tier.

## Scope Audit

The artifact is an adversarial review of a **proposed catalog**. It
does not implement tests, boot Arvo, run Harbor, mint forbidden
namespaces, open intake, invent G-006, merge G-004 with “improves
while you use it,” or land the searcher as Arvo’s identity.

Findings are proposed corrections. They do not become `REQ`s here.
Proposed specification diffs live inside findings, not in a new
spec file.

Inspection points the review left as “no defect” were spot-checked
against the specification and leftovers report; none is a missed
lock violation:

- `REQ-043`…`REQ-046` Priority Must is the Watch-shelf constraint.
- 23 Watch clusters grouped via `REC-114` are not promoted.
- `REQ-043` keeps `organism ≠ searcher ≠ judge` and closes
  `OQ-011`. `REQ-044` refuses a keep unless the layer was the
  declared primary. Force-verify / onboard unnamed is leftover
  *policy* compression (`REC-112`), not a promotion.
- Software-first §7–§19 remain catalog refusals, not invented
  product architecture.

Preference-not-finding is labeled (`REQ-037`/`REQ-039` twins; do
not delete Watch `REQ`s). No MCP / Horde / Oban / libcluster /
relup / LiveView architecture is proposed.

Author-session allowed paths (commissioning prompt) vs tree:

| Path | Present / state | Allowed? |
| ---- | --------------- | -------- |
| `docs/reviews/01-specification-adversarial-review.md` | Filled review; status Proposed — pending independent validation | Yes — required output |
| `research-program.toml` | `spec-review.status = "awaiting-validation"`; prompt path `14-…`; no `accepted_commit` | Yes — must not set `accepted` |
| `docs/validations/14-specification-adversarial-review-validation.md` | This file | Yes — independent validator only |
| `docs/specifications/01-definitive-specification.md` | Unchanged by this validator; still Proposed catalog | Must not edit |
| `docs/specifications/02-definitive-specification-revised.md` | Still `Placeholder — not accepted` | Must not start spec-revision |
| `docs/plans/01-implementation-plan.md`, `02-…`, `docs/reviews/02-…` | Still placeholders | Must not fill |
| Accepted Blueprint / Charter / three reports | Unchanged by this validator | Must not edit |
| SORT substance | Not rewritten | Must not re-sort |

Working-tree extras **outside** this validation write (spec-review
install package, not later-spine artifacts): untracked
`docs/prompts/14-specification-adversarial-review-prompt.md`,
`docs/handoffs/spec-review-attachment-manifest.md`,
`docs/handoffs/spec-review-launch-message.md`; deleted skeleton
`docs/prompts/NN-specification-adversarial-review-prompt.md`. Those
are packaging files. They are not a revised spec or plan.

`just check` (`scripts/check_program.py`): required files and dirs
present; accepted stages’ outputs exist and are not placeholders;
spec-review is not `accepted`, so the script does not treat this
draft as an accepted output. Result: `check: OK`.

## Git Diff Audit

Inspected `git status --short` and `git diff --stat` only. Did not
commit. Did not `git add`. Did not set `spec-review.status =
"accepted"`. Did not record `accepted_commit`.

Tracked spec-review-scope diffs:

| Path | Diff | In scope? |
| ---- | ---- | --------- |
| `docs/reviews/01-specification-adversarial-review.md` | Placeholder replaced (~679 lines); this validator stripped one trailing-space hard break | Yes — required review |
| `research-program.toml` | `spec-review.status` `planned` → `awaiting-validation`; prompt path `NN-` → `14-` | Yes — allowed; not `accepted` |
| `docs/prompts/NN-specification-adversarial-review-prompt.md` | Deleted skeleton | Packaging; not a revised spec |

No diff against accepted Blueprint, Charter, the proposed
specification, runtime / leftovers / score-harness reports, SORT
substance, or later-spine placeholders.

## Required Next Action

Validation **passes with mechanical corrections**. Leave
`spec-review.status = "awaiting-validation"` until the human
records the accepting commit. Do **not** mark the stage
`accepted`. Do **not** start spec-revision in this validation
session. Spec-revision remains legal only after acceptance, in a
**separate** fresh session.

The human already accepted this review draft on 2026-08-15. That
acceptance is not the accepting commit.

Human (Robert):

1. Commit the filled review (and, if desired, this validation file
   and the spec-review install package). Suggested message:

   ```text
   docs: add specification adversarial review
   ```

2. Only the accepting commit may set `spec-review.status =
   "accepted"` and record `accepted_commit`. Do not treat this
   validation file as that recording.

3. After the accepting commit is recorded, spec-revision is the
   next legal stage, in a **fresh** session. Do not write
   `docs/specifications/02-definitive-specification-revised.md`
   now. Disposition `FND-001`…`FND-003` there. Continue shared IDs
   from `RSK-031` and `OQ-019` if later stages mint any.
   `FND-001`…`FND-003` are taken. `FND-200+` remains plan-review.
