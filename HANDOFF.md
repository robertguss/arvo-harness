# Handoff — write the runtime catalog (G-001, G-002, G-003)

- **Written:** 2026-08-15
- **From:** Charter accepted (`081ad36`) and recorded (`63862cf`). Blueprint accepted (`0b49540`). Fresh session on purpose.
- **Next job:** write **`docs/reports/10-runtime-research-report.md`**. That is the host-primitives catalog. Show Robert. **Stop.**
- **Eligible stage (`just status`):** `runtime` (prompt-ready). leftovers and score-harness are also legal; **do not write them in this session.**
- **Authority:** Git-tracked files. This handoff is a map, not evidence and not higher than the files it points at.

**How to start this session:** read this file first, then the attachment list below, then the commissioning prompt. Do not scrape a new paper dump. Do not re-sort. Do not write leftovers or score-the-harness. Do not code. Do not boot Arvo. Do not change the five tests. Do not mark runtime accepted.

Talk to Robert in **plain language**. He asked for that. The report still has to use the contract’s section names.

---

## What you are doing

The plan and the rules are accepted. Your job is the **runtime report**: name the three host pieces (window vs brain, hands somewhere else, plugin swap), say what the Arvo checkout *looks like* for each, and say what a later repo would measure to keep or drop them.

This repo **still only catalogs ideas**. You are not implementing a harness and not proving Arvo works.

When the file is filled, show Robert a short plain-language summary. He must accept it later (human + git). You do not accept it.

Commissioning prompt (full rules for the writer):
[`docs/prompts/10-runtime-research-prompt.md`](docs/prompts/10-runtime-research-prompt.md).

Attachment list:
[`docs/handoffs/runtime-attachment-manifest.md`](docs/handoffs/runtime-attachment-manifest.md).

Launch note (same job, shorter):
[`docs/handoffs/runtime-launch-message.md`](docs/handoffs/runtime-launch-message.md).

---

## Locked (do not re-litigate)

From the accepted [`docs/00-program-blueprint.md`](docs/00-program-blueprint.md) §7 and [`docs/01-research-charter.md`](docs/01-research-charter.md).

1. Personal lab, not a race.
2. Two programs. This repo writes the catalog. A later sibling repo runs tests.
3. No spikes, evals, Harbor, smoke tests, or PRs into Arvo **in this repo**.
4. Arvo is not a daily driver. “In the code” ≠ “works.”
5. Local instrument: `../coding-agent-harness/arvo` (HEAD was `84004e1` when this packet was written — re-check if you look). Ignore `ore/` unless he says so.
6. Runtime is the framework: window is a client of a living agent; brains vs hands; swap plugins without dropping state.
7. Thin OTP slice is the gap (one Session, tools in-process, Mix-compile plugins, quit-window kills the VM, file-search native code on the brain).
8. Adaptation, not photocopy, not “refuse every rewrite.” A Port-wrapped foreign harness is a shell.
9. Intake is closed.
10. Success bar: catalog (five tests + pattern cards), not a working harness.
11. Rigor: focused. Replication off. **Mint no `SPK-###`.**
12. This track is **only** G-001, G-002, G-003. leftovers and score-harness are other sessions.
13. Five tests stay five. No G-006.
14. G-004 ≠ “improves while you use it” — and it is **not your job**.
15. G-005 = specialized helpers — **not your job**.

---

## What the runtime report must contain

Contract: [`program/contracts/focused-research-report.md`](program/contracts/focused-research-report.md).
Exact headings are listed in the commissioning prompt. Fill every one.

Charter extras every `REC` must name: **claim, host primitive (exactly one of G-001…G-003), later measure, keep/drop**. Template: [`program/templates/recommendation.md`](program/templates/recommendation.md).

Identifiers: `REC-001`…`REC-099`. Shared `RSK` / `OQ` from `001` if you need them (none minted yet). Intake IDs `G-` / `H-` / `P-` are citations, not `REC` numbers.

Specialize:

- Three tests stay three. Restate measure and keep/drop; do not replace the Blueprint table.
- “In the Arvo tree” is a dated checkout description, not a passing test.
- Isolation ladder for G-002: process → Port → hidden `:peer` → Docker. Keep the thinnest that would later pass. Drop a shell.
- G-003: no Mix in the live product VM; no OTP relups as the plugin story.
- High confidence is rare. Hypotheses stay Medium/Low until phase-2 measures them.
- Popularity / star counts are not proof.

---

## Exa (required for current research)

Robert: use **Exa** for research. Use **Exa deep research** when it merits it. **Cost is not a reason to skip.** The account has balance.

This is retrieval, not a spike, and not a source to cite instead of the official page.

### How to get Exa in this Grok session

1. Discover: `search_tool` query `exa`. If tools appear, `use_tool` them. Do not guess parameter names — read the schema.
2. Typical Exa MCP tools ([docs](https://exa.ai/docs/reference/exa-mcp)):
   - `web_search_exa` — ordinary search
   - `web_fetch_exa` — read a page
   - `web_search_advanced_exa` — domain / date filters (enable if needed)
   - `agent_run` — Exa Agent; this is the deep multi-step run
3. If no Exa MCP is connected, try to add it (do not put keys in the report):
   - Grok marketplace: plugin **exa**, then `/mcp` and sign in. Server URL: `https://mcp.exa.ai/mcp`
   - Or REST: `POST https://api.exa.ai/search` with `Authorization: Bearer $EXA_API_KEY`
   - Search types: `auto` / `fast` for lookup; **`deep`** or **`deep-reasoning`** for deep research ([search guide](https://exa.ai/docs/reference/search-api-guide))
   - Local MCP fallback: `npx -y exa-mcp-server` with `EXA_API_KEY`
4. If Exa still cannot run after a genuine attempt, say so in Methodology and continue with built-in `web_search` / `open_page` / `web_fetch` plus local OTP/Arvo sources. Do **not** pretend Exa ran.

Built-in `web_search` / `open_page` / `web_fetch` / X search are fine **after** Exa points at a primary URL, or to open José’s tweets and OTP docs you already named.

### When deep research merits it

Use Exa `deep` / `deep-reasoning` or `agent_run` (effort `high` or `xhigh` is allowed) for load-bearing **documentary** questions that are thin or contradictory:

- Official OTP: processes vs Ports vs hidden nodes vs cookies / `:erpc`
- Official code server: `load_binary`, two-version modules, purge — vs OTP relups
- Official Livebook standalone / runtime split (brains vs nodes)

Do **not** spend deep research on paper surveys, star counts, Harbor leaderboards, or a new intake dump.

### What Exa must not do

- Reopen intake
- Count as `SPK-###`
- Count as a verified fact until you open the cited primary page
- Authorize coding or an Arvo smoke test

---

## Read in this order

**Required (full):**

| Path | Why |
|------|-----|
| This file | Job, locks, Exa |
| [`docs/prompts/10-runtime-research-prompt.md`](docs/prompts/10-runtime-research-prompt.md) | Commission — follow it |
| [`docs/00-program-blueprint.md`](docs/00-program-blueprint.md) | Accepted plan |
| [`docs/01-research-charter.md`](docs/01-research-charter.md) | Accepted rules |
| [`docs/handoffs/runtime-attachment-manifest.md`](docs/handoffs/runtime-attachment-manifest.md) | Attachment list |
| [`program/contracts/focused-research-report.md`](program/contracts/focused-research-report.md) | Required report sections |
| [`program/contracts/evidence-model.md`](program/contracts/evidence-model.md) | Ledgers and claim classes |
| [`program/templates/recommendation.md`](program/templates/recommendation.md) | `REC` shape |
| [`program/contracts/evidence-spike.md`](program/contracts/evidence-spike.md) | Inherit, then mint none |
| [`AGENTS.md`](AGENTS.md) | No accept without human |
| [`research-program.toml`](research-program.toml) | Index |

**Required (skim):**

| Path | Why |
|------|-----|
| Blueprint §5 (five-test table), §7, §11 runtime row | What to name |
| Charter §4–§12, §18 | Evidence, RECs, no spikes, anti-patterns |
| [`docs/working/SORT.md`](docs/working/SORT.md) Graduate G-001…G-003 + José/surfaces/isolation Translate only | Do not re-sort |
| [`docs/working/DISCOVERY-NOTES.md`](docs/working/DISCOVERY-NOTES.md) locked top + **Grounding snapshot** | Do not rewrite the dump |
| [`program/contracts/authority-and-precedence.md`](program/contracts/authority-and-precedence.md) | Precedence |
| [`program/reference/anti-patterns.md`](program/reference/anti-patterns.md) | Plus Charter program-specific nos |
| [`program/operator/approval-gates.md`](program/operator/approval-gates.md) | Humans accept the report |
| [`docs/handoffs/runtime-launch-message.md`](docs/handoffs/runtime-launch-message.md) | Same launch, shorter |

**Local instrument (check a claimed fact only):**

- `../coding-agent-harness/arvo` — read-only. Date + commit. No `mix`, no boot, no task.

**Do not read / do not attach:**

- Bookmark JSON, unread Articles, PDFs, vault traces
- Watch files (already sorted)
- Placeholder specs / plans / reviews
- leftovers / score-harness report paths
- Chat history
- `ore/`

---

## How to talk to Robert when you finish

1. The runtime report is filled (path).
2. This repo still only catalogs ideas.
3. You did not run spikes here, and you did not treat Arvo as proven.
4. You have **not** accepted it.
5. Next after he accepts and commits: leftovers and score-the-harness, each in a fresh session. They may cite this report only once it is accepted. Do not write them now.

---

## Anti-patterns

- Writing leftovers or score-harness in this session
- Re-sorting the dump / opening intake with Exa
- Adding headline test 6
- Marking `runtime` accepted
- Coding, Harbor, Arvo smoke test
- Treating Arvo as a daily driver
- Port-as-native / OTP relups as the plugin story
- In the tree ⇒ works
- Jargon-first explanation to Robert
- Citing this HANDOFF in the report
- Pretending Exa ran if it did not

---

## After the report file exists

1. `just check`
2. Independent validation is allowed — mechanical only (`docs/validations/10-runtime-research-validation.md`)
3. Human reviews / commits
4. Do not start the other two reports

---

## Launch line for the new chat

```text
Read HANDOFF.md and do the job.
```
