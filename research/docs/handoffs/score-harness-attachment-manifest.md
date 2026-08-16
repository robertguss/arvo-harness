# Attachment Manifest — score-harness

## Installation record (this package)

- **Source:** written 2026-08-15 in the score-harness packaging session
- **Destination:** [`docs/prompts/12-score-harness-research-prompt.md`](../prompts/12-score-harness-research-prompt.md)
- **Index:** `research-program.toml` `score-harness.status` → `prompt-ready`
- Do **not** execute the score-harness report in the install session

## Required Full Artifacts

1. `docs/00-program-blueprint.md` — accepted governing plan (especially §5 tests 4–5, §7 items 15–16, §11 score-harness row)
2. `docs/01-research-charter.md` — accepted evidence and decision rules (score-harness extras: §9 tag G-004 or G-005; §10 split / judge / frozen / one primary / three arms)
3. `docs/prompts/12-score-harness-research-prompt.md` — this stage’s commission
4. `docs/reports/10-runtime-research-report.md` — accepted host nouns (`REC-001`…`REC-011`). Cite; do not redesign. Especially `REC-003`, `REC-006`
5. `docs/reports/11-leftovers-research-report.md` — accepted cards. `REC-111` / `REC-112` / `OQ-011` are this stage’s leftovers inheritance
6. `program/contracts/focused-research-report.md` — required report sections
7. `program/contracts/focused-research-prompt.md` — prompt contract (already embodied)
8. `program/contracts/evidence-model.md` — ledger and claim classes
9. `program/contracts/evidence-spike.md` — inherit, then mint **none**
10. `program/templates/recommendation.md` — `REC` shape
11. `AGENTS.md` — Exa REST; no accept without human
12. `research-program.toml` — index only

## Required Skim

- Blueprint §6–§7, §9, §11 (why tracks cannot absorb each other), §15 (ID ranges), §22 (searcher is not Arvo’s identity)
- Charter §4–§12, §18
- [`docs/working/SORT.md`](../working/SORT.md) — **Graduate G-004 and G-005 only**. Framing line that the five stay five. Do not re-sort. Do not walk Translate / Watch / Refuse as a second leftovers pass
- [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md) — locked top (two programs, José hypothesis, central insight, adaptation). Do not rewrite the H- dump
- Runtime Handoff Digest (§17) plus §2 table and §9 `REC`s that a later loop may score
- Leftovers Handoff Digest (§17) plus `REC-111`, `REC-112`, `OQ-011` in full
- [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md)
- [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md)
- [`program/contracts/validation.md`](../../program/contracts/validation.md)
- [`program/operator/approval-gates.md`](../../program/operator/approval-gates.md)

## Required Decision Records

- None.

## Required Handoff Digests

- Accepted runtime report §17 (Handoff Digest). The **full** runtime report is also attached because a later loop may score those hosts; the digest must not replace it.
- Accepted leftovers report §17 (Handoff Digest). The **full** leftovers report is also attached because `REC-111` / `REC-112` / `OQ-011` are load-bearing; the digest must not replace it.

## Explicitly Excluded Artifacts

- Bookmark JSON, X INDEX, unread Articles — intake closed
- `docs/working/arxiv-home/ai-papers/*.pdf` — do not open
- Vault traces / 339 stubs
- Watch files (`ARXIV`, `LANGCHAIN`, `AUTORESEARCH`, `VAULT`, `X-BOOKMARKS`) — already sorted into SORT; do not re-open the raw dumps
- Placeholder specs / plans / reviews
- Chat history
- `../coding-agent-harness/ore` — ignore unless the owner says so
- `../coding-agent-harness/arvo` — **only** to check a fact already claimed (for example an evals path); no boot, no Harbor run

## Authority Notes

Accepted Blueprint §7 and accepted Charter outrank SORT and
DISCOVERY-NOTES. Accepted runtime and leftovers are evidence and
recommendation, not locks that amend §7. This manifest and root
`HANDOFF.md` are maps, not evidence. The score-harness report is not
accepted until a human says so and the accepting commit is recorded.

Exa is REST retrieval ([`AGENTS.md`](../../AGENTS.md)). Cite primary
pages. Do not cite Exa as a source tier. Do not harvest new papers.

Shared IDs already taken: `REC-001`…`REC-011`, `REC-100`…`REC-115`,
`RSK-001`…`RSK-018`, `OQ-001`…`OQ-012`, `EVD-001`…`EVD-028`,
`EVD-100`…`EVD-115`. Score-harness uses `REC-200`…`REC-299`,
`RSK-019+`, `OQ-013+`, and (if allocated) `EVD-200+`. Disposition
`OQ-011`; do not remint it.

## Expected Output

`docs/reports/12-score-harness-research-report.md`

## Validation task (after the report is written)

Read: `README.md`, `AGENTS.md`, `research-program.toml`, accepted
Blueprint, accepted Charter, accepted runtime report, accepted
leftovers report, this manifest, the score-harness prompt,
`program/contracts/focused-research-report.md`,
`program/contracts/validation.md`,
`program/templates/recommendation.md`, the filled
`docs/reports/12-score-harness-research-report.md`.

Check: required report sections; metadata and research date;
`REC-200`…`REC-299` only; no reuse of `REC-001`…`REC-011` or
`REC-100`…`REC-115`; each scoring-method `REC` tags G-004 **or**
G-005 (not both) + claim + later measure + keep/drop; G-004 and
G-005 still split; cousin not merged; scorer-read-only and frozen-
model and one-primary-before-run explicit; G-005 three arms; local
may lose; nested prompt is a drop; `OQ-011` / `REC-111` / `REC-112`
dispositioned; GEPA/ACE still Watch above G-004; no invented Harbor
number as a run result; Evidence Ledger completeness; method paper ≠
run; leftover ≠ proven adaptation; no `SPK-###`; no sixth test;
intake not reopened; Exa REST or documented skip/failure;
`RSK-019+` / `OQ-013+`; citation portability; checklist
truthfulness (last two items unchecked); `score-harness.status` not
`accepted`; no synthesis file written.

Do not set `score-harness` to `accepted`. Write
`docs/validations/12-score-harness-research-validation.md`.

## Recommended commit (human)

Package (this session, if committed separately):

```text
docs: add score-harness research prompt
```

Report (execution session, not accepted):

```text
docs: add score-harness research report (not accepted)
```
