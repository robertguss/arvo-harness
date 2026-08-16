# Validation Report — 00-program-blueprint

- **Result:** Pass
- **Validator:** Independent Validation Agent (`research-validate`)
- **Date:** 2026-08-14
- **Artifact path:** [`docs/00-program-blueprint.md`](../00-program-blueprint.md)
- **Commissioning prompt:** Discovery job in [`HANDOFF.md`](../../HANDOFF.md); this gate commissioned as an independent validation of that output
- **Git commit reviewed:** Working-tree file (uncommitted). `main` HEAD is `043a770d389c8cd366563a205b649ca042da7705` (`docs: index laptop PDF stash as P-027..P-030`). Origin `main` still has the Blueprint skeleton (`Status: Placeholder — not accepted`). `research-program.toml` `discovery.accepted_commit` is empty.

## Checks Performed

| Check | Result |
| ----- | ------ |
| Required 22 contract sections present and non-empty | Pass |
| Artifact metadata complete | Pass |
| Identifier ranges allocated; no silent reuse; none minted | Pass |
| Citation portability | Pass |
| Evidence Ledger / REC disposition / report Handoff Digest | N/A (Blueprint, not a focused report) |
| Completion checklist truthfulness | Pass |
| Scope and authority (Blueprint does not conduct the research) | Pass |
| Internal contradictions vs locked framing | Pass |
| Placeholder remnants on the Blueprint itself | Pass (none) |
| Downstream Charter / reports / specs / plans still placeholders | Expected; not a defect |
| No sixth headline test | Pass |
| G-004 not merged with “improves while you use it” | Pass |
| Three tracks after Charter, before synthesis | Pass |
| Omitted library tracks justified | Pass (all 16) |
| Manifest consistency | Pass (`discovery` is `awaiting-validation`; not flipped to `accepted`) |
| Allowed file scope | Pass on inspected discovery outputs |

All 22 required sections from [`program/contracts/program-blueprint.md`](../../program/contracts/program-blueprint.md) are present as `## 1`–`## 22` and contain project-specific prose, not `_To be filled_` / empty stubs:

1. Artifact Metadata
2. Product or Project Vision
3. Problem Statement
4. Intended Users and Stakeholders
5. Goals
6. Non-Goals
7. Locked Constraints
8. Success Criteria
9. Rigor Tier
10. Research Graph
11. Stage Descriptions and Dependencies
12. Parallelism
13. Optional Replication Points
14. Artifact Inventory
15. Identifier Allocations
16. Authority and Precedence
17. Human Approval Gates
18. Fresh-Session Policy
19. Validation and Commit Gates
20. Amendment Protocol
21. Completion Criteria
22. Implementation Handoff Expectation

Header metadata is complete (type, program, status, version, dates, rigor). Section 1 names owner, repository, local tree, instrument path, and `ore/` ignore rule.

Framing fidelity (SORT Graduate + Framing; DISCOVERY-NOTES locked top + status table; HANDOFF locked list): personal lab; two programs; five tests `G-001`…`G-005` only; G-004 kept as a fixed-set lab loop and split from the bigger cousin; G-005 specialists with parent-model vs smaller/local arms; intake closed; no spikes/code in this repo; Arvo is instrument not daily driver; focused rigor; sibling phase-2 repo plus smoke check *there*; catalog-shaped “implementation plan.”

Checklist:

- Framing, sections, tracks, identifier ranges, rigor, and human accept may be checked (human accepted the draft in chat on 2026-08-14).
- **Manifest updated; accepting commit recorded** is unchecked and that is required: there is no accepting commit.

Charter remains `Status: Placeholder — not accepted`. `docs/reports/` has only `README.md`. Specs, plans, and reviews remain placeholders. That is correct at this stage.

Observation, not a defect: [`program/reference/rigor-tiers.md`](../../program/reference/rigor-tiers.md) describes focused as “one or two” tracks; this program has three. Framing and the commissioning handoff required those three at focused; remaining focused attributes match (no spikes here, replication off by default, one synthesis, one spec review, one plan review).

## Mechanical Corrections

None. No trailing whitespace, heading-hierarchy breaks, malformed fences, or broken internal links found. No mechanical metadata typos that required an edit.

## Substantive Defects

None.

## Identifier Audit

| Namespace | Blueprint allocation | Manifest | Notes |
| --------- | -------------------- | -------- | ----- |
| DEC | DEC-001..DEC-999 | same | None minted (`decisions/` is README only) |
| REC | 001–099 runtime; 100–199 leftovers; 200–299 score-harness | stage `recommendation_range` matches | No `REC` minted |
| REQ | REQ-001..REQ-299 | same | Reserved for synthesis |
| FND | 001–199 spec; 200–399 plan | global `FND-001..FND-999`; stage ranges match the split | Unused 400–999 is idle, not a collision |
| RSK / OQ | 001–999 shared | same | None minted |
| SPK | 001–999 reserved; **do not use in this repo** | same | Consistent with no-spikes lock |
| PHASE / MS | PHASE-01..99; MS-001..999 | same | Reserved for the hypothesis plan |

Intake labels `G-001`…`G-005` (and dump `H-` / `P-` / `V-` / `XB-` / `LC-`) are declared as intake IDs, not `REC`/`REQ`. No ID reuse. No `DEC` minted in discovery, matching the attachment manifest.

## Citation Audit

Citations are portable Markdown links to in-repo paths (`docs/working/SORT.md`, `docs/working/DISCOVERY-NOTES.md`, `program/contracts/*`, `program/reference/*`, `program/operator/*`) plus the GitHub repo URL, which matches `remote.origin.url` (`git@github.com:robertguss/arvo-beam-harness-research.git`).

No ephemeral UI citation tokens. José’s tweets are not required as primary citations here; the Blueprint points at SORT / DISCOVERY-NOTES as framing evidence and does not treat [`HANDOFF.md`](../../HANDOFF.md) as authority.

Evidence Ledger is not required on a Program Blueprint.

## Scope Audit

The file is a governing plan. It names tests, workstreams, and later measure/keep-drop rules; it does not run research, write the Charter, or invent a sixth test.

Graph: discovery → charter → **runtime / leftovers / score-harness (group A)** → synthesis → spec-review → spec-revision → implementation-plan → plan-review → plan-revision. The three tracks depend on Charter only; synthesis depends on Charter plus all three.

Each selected track states why it exists, why another cannot absorb it, which decision it informs, and who consumes it. All sixteen library tracks in [`program/reference/research-stage-library.md`](../../program/reference/research-stage-library.md) have a one-line omit justification.

Locked constraint 15 and score-harness non-goals keep G-004 unmerged from “improves while you use it.” Non-goals and leftovers completion forbid a sixth headline.

Authority section matches [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md), with project rules that working notes fall below this file after acceptance, chat/HANDOFF are not citable, the manifest cannot accept a stage by itself, and neither revised spec nor plan authorizes Elixir in this repo.

Working-note stale text in DISCOVERY-NOTES (“Not yet copied into the Blueprint”; dump-era “no Blueprint until…”) is **not** a Blueprint defect. The H- dump was not required to be reprinted.

## Git Diff Audit

No `git` CLI in this validation session. Compared the working tree to origin `main` (same commit as local HEAD `043a770`):

- `docs/00-program-blueprint.md` — skeleton on origin; filled Blueprint locally (in scope).
- `research-program.toml` — origin still `rigor_tier = "standard"`, `discovery.status = "planned"`, no focused stages, `synthesis.depends_on = ["charter"]`. Local index has `focused`, `discovery.status = "awaiting-validation"`, three `planned` tracks, `synthesis.depends_on = ["charter", "runtime", "leftovers", "score-harness"]`, empty `accepted_commit`. That is the allowed discovery index update. Validator did **not** set `accepted`.
- Charter, specs, plans, reviews remain placeholders (not written as if done).
- `docs/handoffs/discovery-attachment-manifest.md` is an allowed extra.

`just check` was not executed here. [`scripts/check_program.py`](../../scripts/check_program.py) only fails accepted stages that are missing or still placeholders; no stage is `accepted`, so that gate would not fail on this tree.

## Required Next Action

Validation **passes**. Leave `discovery.status = "awaiting-validation"`.

Human (Robert) already accepted the draft in chat on 2026-08-14. Remaining acceptance rule items from [`program/operator/resume-protocol.md`](../../program/operator/resume-protocol.md):

1. Commit the filled Blueprint and the allowed discovery extras (human-owned git). Suggested draft message in the Blueprint is still valid if a non-accepting snapshot is wanted first: `docs: fill Program Blueprint from agreed sort (not accepted)`.
2. Record the **accepting** commit in `research-program.toml` (`discovery.status = "accepted"`, `accepted_commit = "<hash>"`). Only that commit may mark the stage accepted.
3. Do **not** start the Charter in this session. Charter is the next legal stage only after discovery is accepted in the manifest.
