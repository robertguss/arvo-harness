# Obsidian vault — local harness autoresearch library

- **Status:** Map only. Not ingested claim-by-claim. Not an accepted report.
- **Cloned:** 2026-08-14
- **Path:** `../arvo-claw-obsidian-vault` ([robertguss/arvo-claw-obsidian-vault](https://github.com/robertguss/arvo-claw-obsidian-vault))
- **Lens:** this vault is a **prior autoresearch corpus**. Steal maps and leftovers. Do not copy every pass into this program.

---

## What it is

Robert’s OpenClaw/Obsidian vault. Two overnight topics already run hard:

| Topic | Where | What |
|-------|--------|------|
| **agent-harnesses** | `projects/autoresearch/agent-harnesses/` | Many dated runs (2026-04-19 → 2026-05-08): corpus, mechanisms, report, trace.jsonl |
| **RLM / DSPy / GEPA** | `projects/autoresearch/rlm-dspy-gepa/` | Same shape + raw HTML fetches of papers/repos |

Also: `entities/papers/` (~339 stubs), `entities/techniques/` (ACC, doom-loop, harness governance), `synthesis/agent-harness.md`, `projects/pyloop/research/` (Claude Code leak writeup, OpenAI harness-engineering, links), `twitter-bookmarks/` (older local bookmark sync).

This program’s ARXIV-WATCH / LANGCHAIN / AUTORESEARCH notes **overlap**. The vault is earlier, broader, and messier (web-search claims; some “harness = eval scaffold” vs our “harness = OS around the model”).

---

## First files to open when we mine it

1. `projects/autoresearch/agent-harnesses/synthesis.md` — living synthesis (protocols, benches, failure modes)
2. `projects/autoresearch/agent-harnesses/index.md` + latest `2026-05-08` report
3. `knowledge/autoresearch/index.md` — run log
4. `synthesis/agent-harness.md` + `entities/concepts/agent-harness.md` — pyloop-era definition
5. `entities/techniques/adaptive-context-compaction.md` — OPENDEV 5-stage ACC
6. `projects/pyloop/research/Links.md` — Meta-Harness, Hermes meta-harness, harness-engineering skill
7. `projects/autoresearch/rlm-dspy-gepa/2026-04-30/report.md` — GEPA/RLM/DSPy pass
8. `projects/autoresearch/weekly-arxiv/` — 2026-04-27, 2026-05-04
9. `entities/papers/` — stub index (many 2604/2605 arXiv ids we never opened)

---

## Leftovers not yet in *this* repo’s cards

Treat as **Watch** until we re-read the source (vault claims are overnight-search quality).

- **V-001** AutoHarness ([arXiv:2603.03329](https://arxiv.org/abs/2603.03329)) — agent synthesizes its own code harness (Thompson sampling). Missing from ARXIV-WATCH.
- **V-002** Multi-agent: +80% on parallelizable tasks, **−70%** on sequential (Google Research 180 configs). Isolation is not free.
- **V-003** Multi-agent can collapse to one agent + skills at ~equal accuracy, fewer tokens (Wang 2026). José-shaped: don’t multiply brains for org-chart reasons.
- **V-004** Verifiability ladder L1 formal → L4 judgment. Harnesses win at L1–2. Coding is L2. Don’t pretend Harbor scores L4.
- **V-005** Missing harness metrics the vault already named: crash recover time, $/token per config, **hot-reload latency**, time-to-first-trace. Those are BEAM-measurable.
- **V-006** mem0 audit: 97.8% of entries junk. Auto-memory is a refuse-by-default (matches `@trevin` bookmark).
- **V-007** Context rot / mid-window drop; fail after ~20–30 steps. Rings + handoff exist to fight this.
- **V-008** ACC (adaptive context compaction) 5 stages from OPENDEV — we have P-001; vault already distilled the stages.
- **V-009** “Meta harnesses improve the operating system, not the brain.” Vault quote. Same as our central insight, said in 2026-04.
- **V-010** pyloop bets: AST-native edits, TDD *enforcement*, deterministic self-heal. Python-specific. BEAM analog is not libcst — it is compiler/diagnostics as tools + never `eval` on Session.
- **V-011** Ralph as overnight *execution* pattern (fresh window, progress on disk). Autoresearch is overnight *experiment* pattern. Don’t conflate.
- **V-012** MCP: 30 CVEs in 60 days in their 2026 notes. Product hard-no stays. Lab may still study as a Port on hands.
- **V-013** Hermes Agent Meta-Harness (`howdymary/hermes-agent-metaharness`) + `charlesanim/harness-engineering` skill — practitioner tools we have not opened.
- **V-014** HiL-Bench (2604.09408), OrchestrationBench, SupervisorAgent (2510.26585) — evals *of the harness*, not of the model.

---

## How to use it (so we don’t drown)

- **Do not** import 339 paper stubs into ARXIV-WATCH in one go.
- When sorting: for each Graduate candidate, grep the vault first (`projects/autoresearch/**/corpus.md`, `entities/papers/`).
- Home-laptop arXiv stash may duplicate `entities/papers/` — check here before re-fetching.
- Twitter folder in the vault is an **older** bookmark sync; 2026-08 dump in this repo is newer.

---

## Clone note

Sibling of this program, same as `coding-agent-harness`. Not a submodule. `gh repo clone` already done on this VM.
