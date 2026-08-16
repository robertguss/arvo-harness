# Attachment Manifest — synthesis

## Installation record (this package)

- **Source:** written 2026-08-15 in the synthesis packaging session
- **Destination:** [`docs/prompts/13-chief-architect-synthesis-prompt.md`](../prompts/13-chief-architect-synthesis-prompt.md)
- **Index:** `research-program.toml` `synthesis.status` → `prompt-ready`
- Do **not** execute the specification in the install session

## Required Full Artifacts

1. `docs/00-program-blueprint.md` — accepted governing plan (especially §5 five-test table, §6 non-goals, §7 locks, §11 synthesis row, §22 searcher ≠ identity)
2. `docs/01-research-charter.md` — accepted evidence and decision rules (especially §10 spine bar, §14 synthesis rules, §18 anti-patterns)
3. `docs/prompts/13-chief-architect-synthesis-prompt.md` — this stage’s commission
4. `docs/reports/10-runtime-research-report.md` — accepted host nouns (`REC-001`…`REC-011`). Cite; do not redesign
5. `docs/reports/11-leftovers-research-report.md` — accepted cards (`REC-100`…`REC-115`). Cards stay cards; Watch stays Watch
6. `docs/reports/12-score-harness-research-report.md` — accepted scoring methods (`REC-200`…`REC-210`). `OQ-011` already closed
7. `docs/specifications/01-definitive-specification.md` — skeleton to replace (keep the 30 headings)
8. `program/contracts/synthesis.md` — synthesis behavior
9. `program/contracts/definitive-specification.md` — required spec sections
10. `program/templates/requirement.md` — `REQ` shape
11. `program/contracts/evidence-model.md` — claim classes (no new focused-report ledger required)
12. `program/contracts/evidence-spike.md` — inherit, then mint **none**
13. `AGENTS.md` — Exa REST; no accept without human
14. `research-program.toml` — index only

## Required Skim

- Blueprint §9 (focused), §15 (ID ranges), §16 (authority), §21 (completion)
- Charter §1 inherited constraints, §3–§12, §17 handoff (synthesis gets all three reports in full)
- [`docs/working/SORT.md`](../working/SORT.md) — **Graduate table only**. Framing that the five stay five. Do not re-sort. Do not walk Translate / Watch / Refuse as a second leftovers pass
- [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md) — locked top (two programs, José hypothesis, central insight, adaptation). Do not rewrite the H- dump
- Runtime Handoff Digest (§17) — does **not** replace the full runtime report
- Leftovers Handoff Digest (§17) — does **not** replace the full leftovers report
- Score-harness Handoff Digest (§17) — does **not** replace the full score-harness report
- [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md) — especially silent recommendation loss
- [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md)
- [`program/contracts/validation.md`](../../program/contracts/validation.md)
- [`program/operator/approval-gates.md`](../../program/operator/approval-gates.md)
- [`program/contracts/identifiers.md`](../../program/contracts/identifiers.md)

## Required Decision Records

- None.

## Required Handoff Digests

- Accepted runtime report §17 (Handoff Digest). The **full** runtime report is also attached.
- Accepted leftovers report §17 (Handoff Digest). The **full** leftovers report is also attached.
- Accepted score-harness report §17 (Handoff Digest). The **full** score-harness report is also attached.

Charter §17: synthesis receives all three focused reports in full. Digests must not replace them.

## Explicitly Excluded Artifacts

- Bookmark JSON, X INDEX, unread Articles — intake closed
- `docs/working/arxiv-home/ai-papers/*.pdf` — do not open
- Vault traces / 339 stubs
- Watch files (`ARXIV`, `LANGCHAIN`, `AUTORESEARCH`, `VAULT`, `X-BOOKMARKS`) — already sorted; do not re-open the raw dumps
- Placeholder plans / reviews (`docs/plans/*`, `docs/reviews/*`, `docs/specifications/02-*.md`)
- Chat history
- `../coding-agent-harness/ore` — ignore unless the owner says so
- `../coding-agent-harness/arvo` — **only** to check a fact already claimed; no boot, no Harbor run

## Authority Notes

Accepted Blueprint §7 and accepted Charter outrank SORT and
DISCOVERY-NOTES. Accepted reports are evidence and recommendation,
not locks that amend §7. This manifest and root `HANDOFF.md` are
maps, not evidence. The specification is not accepted until a human
says so and the accepting commit is recorded.

Exa is REST retrieval ([`AGENTS.md`](../../AGENTS.md)). Cite primary
pages. Do not cite Exa as a source tier. Do not harvest new papers.
Official pages already cited in the three reports are enough unless
a load-bearing sentence is thin.

Shared IDs already taken: `REC-001`…`REC-011`, `REC-100`…`REC-115`,
`REC-200`…`REC-210`, `RSK-001`…`RSK-029`, `OQ-001`…`OQ-018`
(`OQ-011` closed), `EVD-001`…`EVD-028`, `EVD-100`…`EVD-115`,
`EVD-200`…`EVD-219`. Synthesis uses `REQ-001`…`REQ-299`, and (if
needed) `RSK-030+` / `OQ-019+`. Disposition every material `REC`;
do not remint them. Mint no `SPK`, `PHASE`, `MS`, `FND`, or `DEC`.

## Expected Output

`docs/specifications/01-definitive-specification.md`

## Validation task (after the specification is written)

Read: `README.md`, `AGENTS.md`, `research-program.toml`, accepted
Blueprint, accepted Charter, accepted runtime report, accepted
leftovers report, accepted score-harness report, this manifest,
the synthesis prompt,
`program/contracts/synthesis.md`,
`program/contracts/definitive-specification.md`,
`program/contracts/validation.md`,
`program/templates/requirement.md`, the filled
`docs/specifications/01-definitive-specification.md`.

Check: all 30 numbered headings present and filled; metadata and
status `Proposed — pending adversarial review`; `REQ-001`…`REQ-299`
only; every material `REC-001`…`REC-011`, `REC-100`…`REC-115`,
`REC-200`…`REC-210` has exactly one disposition; no silent drop;
five tests still five; no G-006; G-004 and G-005 still split;
cousin not merged; scorer-read-only and frozen-model and
one-primary-before-run explicit; G-005 three arms; local may lose;
nested prompt is a drop; `OQ-011` remains closed; GEPA/ACE still
Watch above G-004; layer scores still Watch; searcher not identity;
Harbor separate-mode inherited, not invented as a run; no invented
Harbor number; `evals/arvo-attention-reread/` absence treated as
checkout fact not a score; software-first headings filled as
catalog readings (not an invented product architecture); no
`SPK-###`; no `PHASE` / `MS`; intake not reopened; Exa REST or
documented skip; new shared IDs start at `RSK-030` / `OQ-019` if
minted; citation portability (no HANDOFF / prompt / chat as
evidence); checklist truthfulness (human-accept / validation /
commit items unchecked); `synthesis.status` not `accepted`; no
spec-review or plan file written.

Do not set `synthesis` to `accepted`. Write
`docs/validations/13-definitive-specification-validation.md`.

## Recommended commit (human)

Package (this session, if committed separately):

```text
docs: install synthesis stage package (prompt-ready)
```

Specification (execution session, not accepted):

```text
docs: add definitive specification (not accepted)
```
