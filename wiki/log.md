# Wiki log

Append-only. Grep recent: `grep "^## \[" wiki/log.md | tail -5`

## [2026-07-29] ingest | Seed full pass — project wiki

- Created `wiki/` schema (`AGENTS.md`), `index.md`, `overview.md`, `log.md`.
- Entity hubs: arvo, ore, session, progressive-attention, focus-tui,
  profiles-plugins, tools, providers-auth, herdr-panes, fff, evals-harbor, beads.
- Concepts: harness, product-turn-head, hot-warm-cold, agent-tile, dual-view.
- Sources: README, CONTEXT, CONCEPTS, ADR 0001/0002, evals README, three
  solutions (trust-spine, deadlock, herdr-panes).
- Root `AGENTS.md` / `CLAUDE.md` pointer sections added.
- Lint pass: see `lint-report.md`.

## [2026-07-29] lint | Initial health check after seed

- Findings written to `lint-report.md`.
- Fixed during pass: none blocking; noted gaps for follow-up ingest.
