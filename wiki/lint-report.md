---
title: Lint report
type: overview
tags: [lint]
updated: 2026-07-29
sources: []
---

# Lint report — 2026-07-29 (initial seed)

## Healthy

- Index lists all created pages; entity hubs cross-link.
- Normative vocabulary deferred to `CONTEXT.md` / `CONCEPTS.md` (no fork).
- Sources left in place; wiki points at them.
- Session / attention / evals stories align across README, CONCEPTS, evals README.
- Ore is a sibling repo; this wiki covers Arvo only.

## Gaps (ingest later)

| Gap | Severity | Note |
| --- | -------- | ---- |
| Arvo SPEC not ingested | Med | Status/claims may lag code |
| `docs/ideation/*` not ingested | Low | Exploratory, not normative |
| Deep crate/module pages | Out of scope | Top hubs only by design |

## Possible contradictions / watch items

1. **README status branch** — root README mentions D1 on `feat/arvo-d1-daily-driver`;
   verify branch name vs current `main` when citing “shipped path.” Wiki says
   “per README” without re-validating git branch.
2. **Keepers** — mentioned as optional/deferred in CONCEPTS + evals; no entity
   page (intentional). Do not invent Keepers design here.
3. **Agent.core_tools()** doc vs Tools.* set — Agent moduledoc says “default core
   four”; product path also has pane + recall_evidence. Wiki lists expanded set
   under [[entities/tools]]; if code defaults differ by surface, future ingest
   should pin exact lists.

## Orphans

None among seed pages (all linked from index; hubs link concepts).

## Missing concept pages (mentioned, not dedicated)

| Mention | Decision |
| ------- | -------- |
| Keepers | Deferred intentional |
| Skill packaging detail | Covered under profiles-plugins |
| Compaction algorithm | Power tool only; thin mention on Focus/Session |
| jido_action | Named in ADR source page only |

## Suggested next questions / sources

1. Ingest attention plan best doc under `docs/plans/` if residual-need decisions
   matter next session.
2. Read `Session` / `Attention.Policy` for exact stub thresholds when coding
   attention changes.
3. Confirm current default branch and README “shipped path” wording.

## Score

Seed wiki usable for orientation and agent query against hubs. Not a substitute
for reading code on implementation PRs.
