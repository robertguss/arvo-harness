# Handoff — write the leftovers catalog (pattern cards)

- **Written:** 2026-08-15
- **From:** Runtime accepted (`636123f`) and recorded (`ebba194`). Charter accepted (`081ad36`). Blueprint accepted (`0b49540`). Fresh session on purpose.
- **Next job:** write **`docs/reports/11-leftovers-research-report.md`**. Pattern cards on G-001…G-003. Most intake stays Watch. **Stop.**
- **Eligible stage (`just status`):** `leftovers` (prompt-ready). score-harness is also legal; **do not write it in this session.**
- **Authority:** Git-tracked files. This handoff is a map, not evidence and not higher than the files it points at.

**How to start this session:** read this file first, then the attachment list below, then the commissioning prompt. Do not scrape a new paper dump. Do not re-sort. Do not write score-the-harness. Do not code. Do not boot Arvo. Do not change the five tests. Do not mark leftovers accepted.

Talk to Robert in **plain language**. He asked for that. The report still has to use the contract’s section names.

---

## What you are doing

The plan, the rules, and the three host primitives are accepted. Your job is
the **leftovers report**: walk the already-sorted Translate / Watch / Refuse
shelves. Keep the *new* leftover (policy, metric, loop). Sit it on a named
BEAM noun (prefer G-001, G-002, or G-003). Say why it is not a sixth headline.
Leave most ideas on Watch **on purpose**. Keep Refuse refused.

This repo **still only catalogs ideas**. You are not implementing cards and
not proving a paper works on BEAM.

When the file is filled, show Robert a short plain-language summary. He must
accept it later (human + git). You do not accept it.

Commissioning prompt (full rules for the writer):
[`docs/prompts/11-leftovers-research-prompt.md`](docs/prompts/11-leftovers-research-prompt.md).

Attachment list:
[`docs/handoffs/leftovers-attachment-manifest.md`](docs/handoffs/leftovers-attachment-manifest.md).

Launch note (same job, shorter):
[`docs/handoffs/leftovers-launch-message.md`](docs/handoffs/leftovers-launch-message.md).

---

## Locked (do not re-litigate)

From the accepted [`docs/00-program-blueprint.md`](docs/00-program-blueprint.md) §7,
[`docs/01-research-charter.md`](docs/01-research-charter.md), and accepted
[`docs/reports/10-runtime-research-report.md`](docs/reports/10-runtime-research-report.md).

1. Personal lab, not a race.
2. Two programs. This repo writes the catalog. A later sibling repo runs tests.
3. No spikes, evals, Harbor, smoke tests, or PRs into Arvo **in this repo**.
4. Arvo is not a daily driver. “In the code” ≠ “works.”
5. Local instrument: `../coding-agent-harness/arvo`. Ignore `ore/` unless he says so.
6. Five tests stay five. No G-006. Cards are not tests.
7. Host nouns are already named: window vs brain (G-001), hands somewhere else
   (G-002), plugin swap without Mix/relups (G-003). Sit leftovers on those.
   Do not redesign them.
8. Adaptation, not photocopy, not “refuse every rewrite.” A Port-wrapped
   foreign harness is a shell.
9. Intake is closed. Do not re-sort.
10. Success bar: catalog (five tests + pattern cards), not a working harness.
11. Rigor: focused. Replication off. **Mint no `SPK-###`.**
12. This track is leftovers only. score-harness is another session.
13. G-004 ≠ “improves while you use it” — and it is **not your job**.
14. G-005 = specialized helpers — **not your job**.
15. Most Watch stays Watch. Refuse stays refused.
16. Shared IDs taken: `REC-001`…`REC-011`, `RSK-001`…`RSK-009`,
    `OQ-001`…`OQ-006`. You mint `REC-100`…`REC-199`, `RSK-010+`, `OQ-007+`.

---

## What the leftovers report must contain

Contract: [`program/contracts/focused-research-report.md`](program/contracts/focused-research-report.md).
Exact headings are listed in the commissioning prompt. Fill every one.

Charter extras every `REC` must name: **claim, host primitive (G-001 / G-002 /
G-003 / none), why Watch, later measure, keep/drop, why this is not a sixth
headline**. Template: [`program/templates/recommendation.md`](program/templates/recommendation.md).

Identifiers: `REC-100`…`REC-199`. Intake IDs `G-` / `H-` / `P-` / `V-` /
`XB-` / `LC-` are citations, not `REC` numbers.

Specialize:

- Every SORT Translate / Watch / Refuse cluster appears once in a shelf table.
- Pattern card = leftover + BEAM noun + host + why not G-006.
- High confidence is rare. “Would sing on BEAM” stays Medium/Low.
- Popularity / star counts are not proof.

---

## Exa (REST only)

Follow [`AGENTS.md`](AGENTS.md). Load `EXA_API_KEY` from gitignored `.env`.
Call `https://api.exa.ai/search` or `/agent/runs`. **Do not use Exa MCP.**

Use Exa only to open a primary page **already cited** in SORT / runtime /
DISCOVERY-NOTES. Do **not** harvest arXiv or bookmarks. Cost is not a reason
to skip a load-bearing official page. If the key is missing, say so in
Methodology.

---

## Read in this order

**Required (full):**

| Path | Why |
|------|-----|
| This file | Job, locks |
| [`docs/prompts/11-leftovers-research-prompt.md`](docs/prompts/11-leftovers-research-prompt.md) | Commission — follow it |
| [`docs/00-program-blueprint.md`](docs/00-program-blueprint.md) | Accepted plan |
| [`docs/01-research-charter.md`](docs/01-research-charter.md) | Accepted rules |
| [`docs/reports/10-runtime-research-report.md`](docs/reports/10-runtime-research-report.md) | Accepted host nouns |
| [`docs/handoffs/leftovers-attachment-manifest.md`](docs/handoffs/leftovers-attachment-manifest.md) | Attachment list |
| [`program/contracts/focused-research-report.md`](program/contracts/focused-research-report.md) | Required report sections |
| [`program/contracts/evidence-model.md`](program/contracts/evidence-model.md) | Ledgers and claim classes |
| [`program/templates/recommendation.md`](program/templates/recommendation.md) | `REC` shape |
| [`program/contracts/evidence-spike.md`](program/contracts/evidence-spike.md) | Inherit, then mint none |
| [`AGENTS.md`](AGENTS.md) | Exa REST; no accept without human |
| [`research-program.toml`](research-program.toml) | Index |

**Required (skim):**

| Path | Why |
|------|-----|
| Blueprint §5, §7, §11 leftovers row | Cards, not headlines |
| Charter §4–§12, §18 | Evidence, RECs, no spikes |
| [`docs/working/SORT.md`](docs/working/SORT.md) Translate / Watch / Refuse | Do not re-sort |
| [`docs/working/DISCOVERY-NOTES.md`](docs/working/DISCOVERY-NOTES.md) locked top | Do not rewrite the dump |
| Runtime report §17 digest + §2 / §9 | Where cards sit |

**Do not read / do not attach:**

- Bookmark JSON, unread Articles, PDFs, vault traces
- Watch files (already sorted)
- Placeholder specs / plans / reviews
- score-harness report path
- Chat history
- `ore/`

---

## How to talk to Robert when you finish

1. The leftovers report is filled (path).
2. This repo still only catalogs ideas.
3. Most items stayed on Watch. No sixth test.
4. You did not run spikes, and you did not treat leftovers as proven on BEAM.
5. You have **not** accepted it.
6. Next after he accepts and commits: score-the-harness, fresh session. Do not write it now.

---

## Anti-patterns

- Writing score-harness in this session
- Re-sorting / opening intake with Exa
- Adding headline test 6
- Marking `leftovers` accepted
- Coding, Harbor, Arvo smoke test
- Photocopy / Elixir-LangGraph / Port-as-native
- Treating Watch as a failure
- Citing this HANDOFF in the report
- Pretending Exa ran if it did not
- Reusing `REC-001`…`REC-011` / `RSK-001`…`RSK-009` / `OQ-001`…`OQ-006`

---

## After the report file exists

1. `just check`
2. Independent validation is allowed — mechanical only (`docs/validations/11-leftovers-research-validation.md`)
3. Human reviews / commits
4. Do not start score-harness

---

## Launch line for the new chat

```text
Read HANDOFF.md and do the job.
```
