# Attachment Manifest — charter

## Required Full Artifacts

1. `docs/00-program-blueprint.md` — accepted governing plan
2. `docs/prompts/01-research-charter-prompt.md` — this stage’s commission
3. `docs/01-research-charter.md` — skeleton to replace
4. `program/contracts/research-charter.md` — required sections
5. `program/contracts/authority-and-precedence.md` — precedence
6. `program/contracts/evidence-model.md` — ledger and claim classes
7. `program/contracts/evidence-spike.md` — inherit, then forbid spikes *here*
8. `program/templates/recommendation.md` — `REC` shape later stages must use
9. `AGENTS.md` — no accept without human
10. `research-program.toml` — index only

## Required Skim

- `docs/00-program-blueprint.md` §7, §9, §11 (charter + three tracks), §13, §16–§22
- `docs/working/SORT.md` — Graduate table + Framing only (do not re-sort)
- `docs/working/DISCOVERY-NOTES.md` — locked framing at the top only
- `program/reference/anti-patterns.md`
- `program/reference/rigor-tiers.md` — focused
- `program/contracts/validation.md`
- `program/contracts/handoffs.md`
- `program/operator/approval-gates.md`

## Required Decision Records

- None.

## Required Handoff Digests

- None. No accepted reports yet.

## Explicitly Excluded Artifacts

- Bookmark JSON, X INDEX, unread Articles — intake closed
- `docs/working/arxiv-home/ai-papers/*.pdf`
- Vault traces / 339 stubs
- Watch files (`ARXIV`, `LANGCHAIN`, `AUTORESEARCH`, `VAULT`, `X-BOOKMARKS`) — already sorted
- Focused-report paths under `docs/reports/` — later stages
- Placeholder specs / plans / reviews
- Chat history
- `../coding-agent-harness/arvo` — only to check a fact already claimed; no smoke test

## Authority Notes

Accepted Blueprint outranks SORT and DISCOVERY-NOTES. This manifest and
root `HANDOFF.md` are maps, not evidence. Charter is not accepted until
a human says so and the accepting commit is recorded.

## Expected Output

`docs/01-research-charter.md`

## Validation task (after the Charter is written)

Read: `README.md`, `AGENTS.md`, `research-program.toml`, accepted Blueprint,
this manifest, the Charter prompt, `program/contracts/research-charter.md`,
`program/contracts/validation.md`, the filled `docs/01-research-charter.md`.

Check required sections, metadata, checklist truthfulness, no placeholder
status on the Charter itself, no sixth test, spikes forbidden in this repo,
“in the tree ≠ works,” popularity-is-not-proof, scope (no reports written).
Do not set `charter` to `accepted`. Write
`docs/validations/01-research-charter-validation.md`.

## Recommended commit (human)

```text
docs: fill Research Charter from accepted Blueprint (not accepted)
```
