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

## [2026-08-15] maintain | Split out of coding-agent-harness

- Repo is now **arvo-harness**; Mix project is the root (no `arvo/` prefix).
- Ore is a sibling repo (https://github.com/robertguss/ore-harness), not a tree here.
- Retired [[entities/beads]] — no issue tracker in this repo.
- Retargeted entity/source path prefixes (`lib/arvo/…`, `rel/RELEASE.md`, evals).
