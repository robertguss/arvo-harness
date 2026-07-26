# Ore Harbor evals

Tasks for the real `ore chat` product path via `evals/harbor_agents/ore_agent.py`.

## Suites

### Generic coding

| Task | Capability | Beads |
|------|------------|-------|
| `ore-fix-failing-test` | Repair buggy Rust so `cargo test` passes | `coding-agent-harness-ffy` |

### fff search (`suite = fff-search`)

Measures flagship **search profile** + `fff_search` plugin quality and agent use.

| Task | Capability | Primary reward | Beads |
|------|------------|----------------|-------|
| `ore-fff-locate-then-edit` | Find unique token in multi-module crate, fix nearby bug | `cargo test` green + API intact; logs `fff_search` hits | `ffy.1.2` |
| `ore-fff-prefer-plugin` | Tool-choice doctrine: locate token → `answer.txt` | Correct path **and** `fff_search` if agent sessions exist | `ffy.1.3` |

**Engine unit baselines** (no Harbor): `cargo test -p ore-plugin-fff` — nested content, path hit, limit, multi-word, skip dirs, sandbox, scoped path, fuzzy path typo.

**Engine:** native `fff-search` 0.9.6 (shipped with `cg8`). Advanced Harbor tasks (`ffy.1.4`) still optional for agent-level fuzzy/ranking scenarios.

Epic: `coding-agent-harness-ffy.1`.

## Prerequisites

```bash
# Install ore (host binary uploaded into the sandbox)
cargo install --path ore/crates/ore --locked --force

# Harbor + credentials for live agent trials
# XAI_API_KEY or ~/.ore/auth.json from `ore login`
```

## Run patterns

```bash
# Unit engine bar (fast, no Docker)
cd ore && cargo test -p ore-plugin-fff

# Oracle (expected reward 1) / nop (expected 0) — adjust harbor CLI to your install
harbor run -p evals/ore-fff-locate-then-edit -a oracle
harbor run -p evals/ore-fff-prefer-plugin -a oracle

# Live Ore agent (needs network allowlist + key)
harbor run -p evals/ore-fff-locate-then-edit -a ore --agent-import-path evals.harbor_agents.ore_agent:OreAgent --ae XAI_API_KEY
harbor run -p evals/ore-fff-prefer-plugin -a ore --agent-import-path evals.harbor_agents.ore_agent:OreAgent --ae XAI_API_KEY
```

Exact Harbor flags may vary by Harbor version; see prior job logs under `evals/jobs/`.

## Design notes

- Project fixtures set `.ore/config.toml` → `profile = "search"` so boot auto-activates `fff`.
- Default profiles (`search.toml`) are seeded by `ore` via `ensure_default_profiles`.
- Prefer-plugin verifier: if no session JSONL tool activity (oracle), only `answer.txt` is checked; if the agent ran tools, `fff_search` must appear in session `tool_calls`.
- Locate-then-edit does **not** hard-require `fff_search` (end-to-end repair is primary); usage is recorded in `/logs/verifier/fff-usage.txt`.
