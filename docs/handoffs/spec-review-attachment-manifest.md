# Attachment Manifest — spec-review

## Installation record (this package)

- **Source:** written 2026-08-15 in the spec-review packaging session
- **Destination:** [`docs/prompts/14-specification-adversarial-review-prompt.md`](../prompts/14-specification-adversarial-review-prompt.md)
- **Index:** `research-program.toml` `spec-review.status` → `prompt-ready`
- Do **not** execute the review in the install session

## Required Full Artifacts

1. `docs/00-program-blueprint.md` — accepted governing plan (especially §5 five-test table, §6 non-goals, §7 locks, §11 spec-review row, §15 `FND-001`…`FND-199`, §22 searcher ≠ identity)
2. `docs/01-research-charter.md` — accepted evidence and decision rules (especially §10 spine bar, §15 required attacks, §11 confidence, §17 handoff, §18 anti-patterns)
3. `docs/prompts/14-specification-adversarial-review-prompt.md` — this stage’s commission
4. `docs/specifications/01-definitive-specification.md` — **subject**. Human-accepted synthesis output `26bd0e4070ef822bdcd5c69d5f57a2a80131176f`. Status still **Proposed — pending adversarial review**. Not implementation authority
5. `docs/reports/10-runtime-research-report.md` — accepted host nouns (`REC-001`…`REC-011`). Cite; do not redesign
6. `docs/reports/11-leftovers-research-report.md` — accepted cards (`REC-100`…`REC-115`). Cards stay cards; Watch stays Watch
7. `docs/reports/12-score-harness-research-report.md` — accepted scoring methods (`REC-200`…`REC-210`). `OQ-011` already closed
8. `docs/reviews/01-specification-adversarial-review.md` — skeleton to replace (keep the 7 headings)
9. `docs/validations/13-definitive-specification-validation.md` — mechanical Pass; inspection points, not findings to ratify
10. `program/contracts/adversarial-review.md` — review behavior
11. `program/templates/finding.md` — `FND` shape
12. `AGENTS.md` — Exa REST; no accept without human
13. `research-program.toml` — index only

## Required Skim

- Blueprint §9 (focused), §16 (authority), §21 (completion)
- Charter §1 inherited constraints, §3–§12, §14 (what synthesis was allowed to do)
- [`docs/prompts/13-chief-architect-synthesis-prompt.md`](../prompts/13-chief-architect-synthesis-prompt.md) — what synthesis was commissioned to do (map, not evidence)
- [`docs/working/SORT.md`](../working/SORT.md) — **Graduate table only**. Framing that the five stay five. Do not re-sort. Do not walk Translate / Watch / Refuse as a second leftovers pass
- [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md) — locked top (two programs, José hypothesis, central insight, adaptation). Do not rewrite the H- dump
- Runtime Handoff Digest (§17) — does **not** replace the full runtime report
- Leftovers Handoff Digest (§17) — does **not** replace the full leftovers report
- Score-harness Handoff Digest (§17) — does **not** replace the full score-harness report
- Runtime / leftovers / score-harness §13–§14 (weak and conflicting evidence) — load-bearing for the over-confidence attack
- [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md) — especially review-as-feature-ideation, mechanical review application, silent recommendation loss
- [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md)
- [`program/contracts/validation.md`](../../program/contracts/validation.md)
- [`program/contracts/definitive-specification.md`](../../program/contracts/definitive-specification.md) — software-first headings; this program reads “implementation-ready” as catalog-ready
- [`program/operator/approval-gates.md`](../../program/operator/approval-gates.md)
- [`program/contracts/identifiers.md`](../../program/contracts/identifiers.md)

## Required Decision Records

- None.

## Required Handoff Digests

- Accepted runtime report §17 (Handoff Digest). The **full** runtime report is also attached.
- Accepted leftovers report §17 (Handoff Digest). The **full** leftovers report is also attached.
- Accepted score-harness report §17 (Handoff Digest). The **full** score-harness report is also attached.

Charter §17: spec-review receives all three focused reports in full. Digests must not replace them.

## Explicitly Excluded Artifacts

- Bookmark JSON, X INDEX, unread Articles — intake closed
- `docs/working/arxiv-home/ai-papers/*.pdf` — do not open
- Vault traces / 339 stubs
- Watch files (`ARXIV`, `LANGCHAIN`, `AUTORESEARCH`, `VAULT`, `X-BOOKMARKS`) — already sorted; do not re-open the raw dumps
- Placeholder plans / later reviews (`docs/plans/*`, `docs/reviews/02-*.md`, `docs/specifications/02-*.md`)
- Chat history
- Root `HANDOFF.md` — do not recreate
- `../coding-agent-harness/ore` — ignore unless the owner says so
- `../coding-agent-harness/arvo` — **only** to check a fact already claimed; no boot, no Harbor run

## Authority Notes

Accepted Blueprint §7 and accepted Charter outrank SORT,
DISCOVERY-NOTES, and the proposed specification. The proposed
specification is the **subject**, not a lock that amends §7.
Accepted reports are evidence and recommendation. This manifest
and this stage’s launch message are maps, not evidence. The
review is not accepted until a human says so and the accepting
commit is recorded.

Exa is REST retrieval ([`AGENTS.md`](../../AGENTS.md)). Cite
primary pages. Do not cite Exa as a source tier. Do not harvest
new papers. Default: Exa does not need to run.

Reviews mint `FND-001`…`FND-199` only. IDs already taken:
`REQ-001`…`REQ-047`, `REC-001`…`REC-011`, `REC-100`…`REC-115`,
`REC-200`…`REC-210`, `RSK-001`…`RSK-030`, `OQ-001`…`OQ-018`
(`OQ-011` closed), `EVD-001`…`EVD-028`, `EVD-100`…`EVD-115`,
`EVD-200`…`EVD-219`. Do not remint them. Mint no `SPK`,
`PHASE`, `MS`, `REQ`, `REC`, `DEC`, `RSK`, `OQ`, or `EVD`.

## Expected Output

`docs/reviews/01-specification-adversarial-review.md`

## Validation task (after the review is written)

Read: `README.md`, `AGENTS.md`, `research-program.toml`, accepted
Blueprint, accepted Charter, the proposed specification, accepted
runtime report, accepted leftovers report, accepted score-harness
report, this manifest, the spec-review prompt,
`program/contracts/adversarial-review.md`,
`program/contracts/validation.md`,
`program/templates/finding.md`, the filled
`docs/reviews/01-specification-adversarial-review.md`.

Check: all 7 numbered headings present and filled; metadata and
status `Proposed — pending independent validation`; Attacks
attempted table covers every required attack (G-004 collapse;
in-the-tree ⇒ works; sixth test; Port-as-native; plan-as-backlog
/ this-spec-as-tickets-here; opened intake / daily-driver;
judge eaten; helper is a prompt; searcher as identity; invented
Harbor number; thin; merged; over-confident); findings use
`FND-001`…`FND-199` only and are sequential; every minted
finding has the full finding template; “no defect” attacks do
not mint decorative `FND`s; no feature ideation disguised as
defects; five tests still five in every proposed diff; no
G-006; proposed diffs do not merge G-004 with its cousin or
land the searcher as identity; `OQ-011` remains closed; Watch
shelves remain Watch unless a finding *shows* the spec
promoted them; no `REQ` / `REC` / `RSK` / `OQ` / `EVD` /
`SPK` / `PHASE` / `MS` minted; no Harbor run; no Arvo command
as a test; intake not reopened; Exa REST or documented skip;
citation portability (no prompt / manifest / chat / handoff
map as evidence); gate is Open | Conditional | Blocked with
the catalog-as-agenda reading; additional-round recommendation
follows the risk-triggered policy (not automatic); checklist
truthfulness (human-accept / validation / commit items
unchecked); `spec-review.status` not `accepted`; no revised
spec or plan file written.

Do not set `spec-review` to `accepted`. Write
`docs/validations/14-specification-adversarial-review-validation.md`.

## Recommended commit (human)

Package (this session, if committed separately):

```text
docs: install spec-review stage package (prompt-ready)
```

Review (execution session, not accepted):

```text
docs: add specification adversarial review
```
