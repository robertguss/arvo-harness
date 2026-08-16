# Attachment Manifest — spec-revision

## Installation record (this package)

- **Source:** written 2026-08-15 in the spec-revision packaging session
- **Destination:** [`docs/prompts/15-specification-revision-prompt.md`](../prompts/15-specification-revision-prompt.md)
- **Index:** `research-program.toml` `spec-revision.status` → `prompt-ready`
- Do **not** execute the revision in the install session

## Required Full Artifacts

1. `docs/00-program-blueprint.md` — accepted governing plan (especially §5 five-test table, §6 non-goals, §7 locks, §11 spec-revision row, §15 same `REQ` namespace, §16 catalog-authority reading, §22 searcher ≠ identity)
2. `docs/01-research-charter.md` — accepted evidence and decision rules (especially §10 spine bar, §11 confidence, §17 handoff, §18 anti-patterns, §19 every `FND` dispositioned)
3. `docs/prompts/15-specification-revision-prompt.md` — this stage’s commission
4. `docs/specifications/01-definitive-specification.md` — **subject being corrected**. Human-accepted synthesis output `26bd0e4070ef822bdcd5c69d5f57a2a80131176f`. Status still **Proposed — pending adversarial review**. Not implementation authority. Carry it forward as a standalone whole
5. `docs/reviews/01-specification-adversarial-review.md` — **accepted findings to disposition** (`FND-001`…`FND-003`) at `e00ee9c5e79adffd93c13ce2a03b92517a6b8c26`. Proposed corrections, not commandments
6. `docs/reports/10-runtime-research-report.md` — accepted host nouns (`REC-001`…`REC-011`). Cite; do not redesign
7. `docs/reports/11-leftovers-research-report.md` — accepted cards (`REC-100`…`REC-115`). Cards stay cards; Watch stays Watch
8. `docs/reports/12-score-harness-research-report.md` — accepted scoring methods (`REC-200`…`REC-210`). `OQ-011` already closed. `REC-200`, §8.2 / `REC-201`, and `REC-203` are load-bearing for the three findings
9. `docs/specifications/02-definitive-specification-revised.md` — skeleton to replace (prompt heading list wins over placeholder numbers)
10. `docs/validations/13-definitive-specification-validation.md` — mechanical Pass of the proposed spec; map, not a disposition
11. `docs/validations/14-specification-adversarial-review-validation.md` — mechanical Pass of the review; map, not a disposition
12. `program/contracts/definitive-specification.md` — revised-specification rules (finding dispositions; standalone; honest implementation status)
13. `program/templates/requirement.md` — `REQ` shape
14. `AGENTS.md` — Exa REST; no accept without human
15. `research-program.toml` — index only

## Required Skim

- Blueprint §9 (focused), §16 (authority), §21 (completion)
- Charter §1 inherited constraints, §3–§12, §14–§15 (what synthesis and review were allowed to do)
- [`docs/prompts/13-chief-architect-synthesis-prompt.md`](../prompts/13-chief-architect-synthesis-prompt.md) — what synthesis was commissioned to do (map, not evidence)
- [`docs/prompts/14-specification-adversarial-review-prompt.md`](../prompts/14-specification-adversarial-review-prompt.md) — what review was commissioned to do (map, not evidence)
- [`docs/working/SORT.md`](../working/SORT.md) — **Graduate table only**. Framing that the five stay five. Do not re-sort. Do not walk Translate / Watch / Refuse as a second leftovers pass
- [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md) — locked top (two programs, José hypothesis, central insight, adaptation). Do not rewrite the H- dump. The **Next** line may be stale
- Runtime Handoff Digest (§17) — does **not** replace the full runtime report
- Leftovers Handoff Digest (§17) — does **not** replace the full leftovers report
- Score-harness Handoff Digest (§17) — does **not** replace the full score-harness report
- Score-harness §8.2 judge-tree table and `REC-200` / `REC-201` / `REC-203` keep/drop — load-bearing for `FND-001`…`FND-003`
- Proposed specification §5 row 4, §16 G-004 / G-005, `REQ-034`, `REQ-035`, `REQ-040`, `REQ-042`, §28 ledger
- [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md) — especially silent finding loss, silent recommendation loss, plan-as-backlog
- [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md)
- [`program/contracts/validation.md`](../../program/contracts/validation.md)
- [`program/contracts/identifiers.md`](../../program/contracts/identifiers.md)
- [`program/operator/approval-gates.md`](../../program/operator/approval-gates.md)

## Required Decision Records

- None.

## Required Handoff Digests

- Accepted runtime report §17 (Handoff Digest). The **full** runtime report is also attached.
- Accepted leftovers report §17 (Handoff Digest). The **full** leftovers report is also attached.
- Accepted score-harness report §17 (Handoff Digest). The **full** score-harness report is also attached.

This revision receives all three focused reports in full. Digests must not replace them.

## Explicitly Excluded Artifacts

- Bookmark JSON, X INDEX, unread Articles — intake closed
- `docs/working/arxiv-home/ai-papers/*.pdf` — do not open
- Vault traces / 339 stubs
- Watch files (`ARXIV`, `LANGCHAIN`, `AUTORESEARCH`, `VAULT`, `X-BOOKMARKS`) — already sorted; do not re-open the raw dumps
- Placeholder plans / later reviews (`docs/plans/*`, `docs/reviews/02-*.md`)
- Chat history
- Root `HANDOFF.md` — do not recreate
- `/tmp/arvo-beam-harness-research-handoff.md` and other session maps — not evidence
- `../coding-agent-harness/ore` — ignore unless the owner says so
- `../coding-agent-harness/arvo` — **only** to check a fact already claimed; no boot, no Harbor run

## Authority Notes

Accepted Blueprint §7 and accepted Charter outrank SORT,
DISCOVERY-NOTES, the proposed specification, and the review.
The proposed specification is the **body being corrected**, not
a lock that amends §7. The accepted review is proposed
corrections. Accepted reports are evidence and recommendation.
This manifest and this stage’s launch message are maps, not
evidence. The revised specification is not accepted until a
human says so and the accepting commit is recorded.

Exa is REST retrieval ([`AGENTS.md`](../../AGENTS.md)). Cite
primary pages. Do not cite Exa as a source tier. Do not harvest
new papers. Default: Exa does not need to run.

Disposition `FND-001`…`FND-003` only. Do not remint them. Do
not mint new `FND`s. Keep `REQ-001`…`REQ-047` where the subject
is the same. New `REQ`s only from `REQ-048`+. IDs already
taken: `REQ-001`…`REQ-047`, `REC-001`…`REC-011`,
`REC-100`…`REC-115`, `REC-200`…`REC-210`, `RSK-001`…`RSK-030`,
`OQ-001`…`OQ-018` (`OQ-011` closed), `EVD-001`…`EVD-028`,
`EVD-100`…`EVD-115`, `EVD-200`…`EVD-219`, `FND-001`…`FND-003`.
Mint no `SPK`, `PHASE`, `MS`, `DEC`, `REC`, or `FND`.

Do not amend Blueprint §7. Annotating the specification’s
five-test restatement is required for `FND-001`.

## Expected Output

`docs/specifications/02-definitive-specification-revised.md`

## Validation task (after the revised specification is written)

Read: `README.md`, `AGENTS.md`, `research-program.toml`, accepted
Blueprint, accepted Charter, the proposed specification, the
accepted review, accepted runtime report, accepted leftovers
report, accepted score-harness report, this manifest, the
spec-revision prompt,
`program/contracts/definitive-specification.md`,
`program/contracts/validation.md`,
`program/templates/requirement.md`, the filled
`docs/specifications/02-definitive-specification-revised.md`.

Check: all 34 numbered headings present and filled; metadata
and status `Proposed — pending independent validation`;
Implementation status is exactly `Accepted — implementation
authority` **or** `Proposed — implementation blocked` with
blockers explicit (catalog-as-agenda reading, not Elixir-here);
Finding Disposition Ledger has one row each for `FND-001`,
`FND-002`, `FND-003` and no silent drop; no “Deferred to a
bounded evidence spike”; accepted corrections integrated in
prose / tables / `REQ`s not only the ledger; one G-004
leftover-test keep bar (try ≠ keep; leftover G-001…G-003 must
not collapse on the keep rule); judge-tree diff list includes
`instruction.md`, frozen task list, Oracle `solution/`,
leftover-test identity as named G-001…G-003 suite; writable
set still four named harness files; G-005 V-002 split is a
keep/drop in `REQ-040` / `REQ-042`; `REQ-001`…`REQ-047`
retained where the subject is the same; new IDs only
`REQ-048`+ / `RSK-031+` / `OQ-019+`; 38 `REC` rows still
present and none reminted; five tests still five; no G-006;
G-004 and G-005 still split; cousin not merged; scorer
read-only; frozen model; one primary before the run; G-005
three arms; local may lose; nested prompt is a drop; `OQ-011`
remains closed; Watch shelves remain Watch; searcher not
identity; Harbor separate-mode inherited, not invented as a
run; no invented Harbor number; software-first headings filled
as catalog readings; no `SPK-###`; no `PHASE` / `MS`; intake
not reopened; Exa REST or documented skip; citation portability
(no prompt / manifest / chat / handoff map as evidence);
checklist truthfulness (human-accept / validation / commit
items unchecked); `spec-revision.status` not `accepted`; no
implementation-plan or plan-review file written; Blueprint §7
not edited.

If `FND-001` is Rejected, confirm the file still states
**one** leftover-test keep bar; otherwise Implementation
status must be blocked.

Do not set `spec-revision` to `accepted`. Write
`docs/validations/15-definitive-specification-revised-validation.md`.

## Recommended commit (human)

Package (this session, if committed separately):

```text
docs: install spec-revision stage package (prompt-ready)
```

Revised specification (execution session, not accepted):

```text
docs: add revised definitive specification
```

After human accept + validation (human records the accepting
commit):

```text
docs: publish revised definitive specification
```
