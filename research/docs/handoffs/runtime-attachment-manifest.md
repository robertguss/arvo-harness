# Attachment Manifest — runtime

## Installation record (this package)

- **Source:** written 2026-08-15 in the packaging session
- **Destination:** [`docs/prompts/10-runtime-research-prompt.md`](../prompts/10-runtime-research-prompt.md)
- **Index:** `research-program.toml` `runtime.status` → `prompt-ready`
- Do **not** execute the runtime report in the install session

## Required Full Artifacts

1. `docs/00-program-blueprint.md` — accepted governing plan (especially §5 tests, §7 locks, §11 runtime row)
2. `docs/01-research-charter.md` — accepted evidence and decision rules
3. `docs/prompts/10-runtime-research-prompt.md` — this stage’s commission
4. `program/contracts/focused-research-report.md` — required report sections
5. `program/contracts/focused-research-prompt.md` — prompt contract (already embodied)
6. `program/contracts/evidence-model.md` — ledger and claim classes
7. `program/contracts/evidence-spike.md` — inherit, then mint **none**
8. `program/templates/recommendation.md` — `REC` shape
9. `AGENTS.md` — no accept without human
10. `research-program.toml` — index only

## Required Skim

- Blueprint §7, §9, §11 (runtime row + why tracks cannot absorb each other), §13, §16–§22
- Charter §4–§12, §18 (source hierarchy, spikes none, REC extras, rubric, confidence, anti-patterns)
- [`docs/working/SORT.md`](../working/SORT.md) — **Graduate table G-001…G-003 only**, plus José / surfaces / isolation Translate clusters that are mechanisms of those three. Do not re-sort. Do not promote Watch.
- [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md) — locked top (two programs, José hypothesis, central insight) + **Grounding snapshot** (`## Grounding snapshot — local Arvo`). Do not rewrite the H- dump.
- [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md)
- [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md)
- [`program/contracts/validation.md`](../../program/contracts/validation.md)
- [`program/operator/approval-gates.md`](../../program/operator/approval-gates.md)

## Required Decision Records

- None.

## Required Handoff Digests

- None. No accepted focused reports yet. leftovers / score-harness are **not** prerequisites.

## Explicitly Excluded Artifacts

- Bookmark JSON, X INDEX, unread Articles — intake closed
- `docs/working/arxiv-home/ai-papers/*.pdf`
- Vault traces / 339 stubs
- Watch files (`ARXIV`, `LANGCHAIN`, `AUTORESEARCH`, `VAULT`, `X-BOOKMARKS`) — already sorted; do not re-open
- `docs/reports/11-leftovers-research-report.md` / `12-score-harness-research-report.md` — other sessions
- Placeholder specs / plans / reviews
- Chat history
- `../coding-agent-harness/ore` — ignore unless the owner says so
- `../coding-agent-harness/arvo` — **only** to check a fact already claimed; no boot, no smoke test

## Authority Notes

Accepted Blueprint §7 and accepted Charter outrank SORT and
DISCOVERY-NOTES. This manifest and root `HANDOFF.md` are maps, not
evidence. The runtime report is not accepted until a human says so
and the accepting commit is recorded.

Exa is a **retrieval tool** required by the operator for this stage.
Cite the primary pages Exa finds. Do not cite Exa itself as a
source tier.

## Expected Output

`docs/reports/10-runtime-research-report.md`

## Validation task (after the report is written)

Read: `README.md`, `AGENTS.md`, `research-program.toml`, accepted
Blueprint, accepted Charter, this manifest, the runtime prompt,
`program/contracts/focused-research-report.md`,
`program/contracts/validation.md`,
`program/templates/recommendation.md`, the filled
`docs/reports/10-runtime-research-report.md`.

Check: required report sections; metadata and research date;
`REC-001`…`REC-099` only; no silent ID reuse; each `REC` has claim +
host primitive (exactly one of G-001…G-003) + later measure +
keep/drop; Evidence Ledger completeness; tree-description ≠ function;
no `SPK-###`; no sixth test; G-004/G-005 not absorbed; intake not
reopened; Exa use or documented failure in Methodology; citation
portability; checklist truthfulness (last two items unchecked);
`runtime.status` not `accepted`; no leftovers/score-harness files
written.

Do not set `runtime` to `accepted`. Write
`docs/validations/10-runtime-research-validation.md`.

## Recommended commit (human)

Package (this session, if committed separately):

```text
docs: add runtime research prompt
```

Report (execution session, not accepted):

```text
docs: add runtime research report (not accepted)
```
