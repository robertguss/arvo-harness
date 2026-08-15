# Handoff — write the score-harness catalog (G-004 and G-005)

- **Written:** 2026-08-15
- **From:** Leftovers accepted (`9698362`) and recorded (`fe18e9f`). Runtime accepted (`636123f`). Charter accepted (`081ad36`). Blueprint accepted (`0b49540`). Fresh session on purpose.
- **Next job:** write **`docs/reports/12-score-harness-research-report.md`**. Name how the later repo runs G-004 and G-005 so the harness cannot edit the judge, and so the two tests stay unmerged. **Stop.**
- **Eligible stage (`just status`):** `score-harness` (prompt-ready). Synthesis is **not** legal until this report is accepted. Do not write it in this session.
- **Authority:** Git-tracked files. This handoff is a map, not evidence and not higher than the files it points at.

**How to start this session:** read this file first, then the attachment list below, then the commissioning prompt. Do not scrape a new paper dump. Do not re-sort. Do not write synthesis. Do not code. Do not boot Arvo. Do not run Harbor. Do not change the five tests. Do not mark score-harness accepted.

Talk to Robert in **plain language**. He asked for that. The report still has to use the contract’s section names.

---

## What you are doing

The plan, the rules, the three host primitives, and the leftover cards
are accepted. Your job is the **score-harness report**: how the later
repo would keep or drop a change without fooling itself.

- **G-004** = overnight keep/reset on a **fixed** test set. Scorer /
  judge tree read-only. Frozen model. One primary number declared
  **before** the run. Human owns `program.md`. **Not** “improves while
  you use it.”
- **G-005** = specialized helper as its **own Session** (scout / critic /
  planner). Three arms: none / parent-model / smaller-or-local. Local
  may lose. A nested prompt with a pid taped on is a drop.

This repo **still only catalogs ideas**. You are not running the loop
and not proving a holdout rise.

When the file is filled, show Robert a short plain-language summary. He
must accept it later (human + git). You do not accept it.

Commissioning prompt (full rules for the writer):
[`docs/prompts/12-score-harness-research-prompt.md`](docs/prompts/12-score-harness-research-prompt.md).

Attachment list:
[`docs/handoffs/score-harness-attachment-manifest.md`](docs/handoffs/score-harness-attachment-manifest.md).

Launch note (same job, shorter):
[`docs/handoffs/score-harness-launch-message.md`](docs/handoffs/score-harness-launch-message.md).

---

## Locked (do not re-litigate)

From the accepted [`docs/00-program-blueprint.md`](docs/00-program-blueprint.md) §7,
[`docs/01-research-charter.md`](docs/01-research-charter.md), accepted
[`docs/reports/10-runtime-research-report.md`](docs/reports/10-runtime-research-report.md),
and accepted
[`docs/reports/11-leftovers-research-report.md`](docs/reports/11-leftovers-research-report.md).

1. Personal lab, not a race.
2. Two programs. This repo writes the catalog. A later sibling repo runs tests.
3. No spikes, evals, Harbor runs, smoke tests, or PRs into Arvo **in this repo**.
4. Arvo is not a daily driver. “In the code” ≠ “works.”
5. Local instrument: `../coding-agent-harness/arvo`. Ignore `ore/` unless he says so.
6. Five tests stay five. No G-006. Leftover cards are not tests.
7. Host nouns are already named: window vs brain (G-001), hands somewhere else
   (G-002), plugin swap without Mix/relups (G-003). You may *score* those
   later. Do not rename them. JSONL auto-resume is not G-001. Port-wrap is
   not hands.
8. Adaptation, not photocopy, not “refuse every rewrite.” A Port-wrapped
   foreign harness is a shell.
9. Intake is closed. Do not re-sort.
10. Success bar: catalog (five tests + pattern cards + scoring methods),
    not a working harness.
11. Rigor: focused. Replication off. **Mint no `SPK-###`.**
12. This track is score-harness only. Synthesis is another session.
13. G-004 ≠ “improves while you use it.”
14. G-005 = specialized helpers as their own Session. Local may lose.
15. GEPA/ACE stay Watch *above* G-004 (`REC-111`). Traces / layer scores
    stay Watch *beside* scoring (`REC-112`). You must answer `OQ-011`
    (proposer slot?). Do not design an online improver.
16. Shared IDs taken: `REC-001`…`REC-011`, `REC-100`…`REC-115`,
    `RSK-001`…`RSK-018`, `OQ-001`…`OQ-012`. You mint `REC-200`…`REC-299`,
    `RSK-019+`, `OQ-013+`. Disposition `OQ-011`; do not remint it.

---

## What the score-harness report must contain

Contract: [`program/contracts/focused-research-report.md`](program/contracts/focused-research-report.md).
Exact headings are listed in the commissioning prompt. Fill every one.

Charter extras every scoring-method `REC` must name: **claim, host
(G-004 or G-005, not both), later measure, keep/drop**, plus the G-004
or G-005 sentence (fixed-set loop / three arms, local may lose).
Template: [`program/templates/recommendation.md`](program/templates/recommendation.md).

Identifiers: `REC-200`…`REC-299`. Intake IDs `G-` / `H-` / `P-` / `V-` /
`XB-` / `LC-` are citations, not `REC` numbers.

Specialize:

- G-004 and G-005 stay split. Judge tree read-only. Frozen model. One
  primary declared before the run.
- `OQ-011` / `REC-111` / `REC-112` are dispositioned. No sixth test.
- High confidence is rare. “Holdout would rise” stays Medium/Low.
- Popularity / star counts are not proof. A method paper is not a run.

---

## Exa (REST only)

Follow [`AGENTS.md`](AGENTS.md). Load `EXA_API_KEY` from gitignored `.env`.
Call `https://api.exa.ai/search` or `/agent/runs`. **Do not use Exa MCP.**

Use Exa for current Harbor (or equivalent) official docs, and to open a
primary page **already cited** when wording is load-bearing. Do **not**
harvest arXiv or bookmarks. Cost is not a reason to skip a load-bearing
official page. If the key is missing, say so in Methodology.

---

## Read in this order

**Required (full):**

| Path | Why |
|------|-----|
| This file | Job, locks |
| [`docs/prompts/12-score-harness-research-prompt.md`](docs/prompts/12-score-harness-research-prompt.md) | Commission — follow it |
| [`docs/00-program-blueprint.md`](docs/00-program-blueprint.md) | Accepted plan |
| [`docs/01-research-charter.md`](docs/01-research-charter.md) | Accepted rules |
| [`docs/reports/10-runtime-research-report.md`](docs/reports/10-runtime-research-report.md) | Accepted host nouns |
| [`docs/reports/11-leftovers-research-report.md`](docs/reports/11-leftovers-research-report.md) | Accepted cards; `REC-111` / `REC-112` / `OQ-011` |
| [`docs/handoffs/score-harness-attachment-manifest.md`](docs/handoffs/score-harness-attachment-manifest.md) | Attachment list |
| [`program/contracts/focused-research-report.md`](program/contracts/focused-research-report.md) | Required report sections |
| [`program/contracts/evidence-model.md`](program/contracts/evidence-model.md) | Ledgers and claim classes |
| [`program/templates/recommendation.md`](program/templates/recommendation.md) | `REC` shape |
| [`program/contracts/evidence-spike.md`](program/contracts/evidence-spike.md) | Inherit, then mint none |
| [`AGENTS.md`](AGENTS.md) | Exa REST; no accept without human |
| [`research-program.toml`](research-program.toml) | Index |

**Required (skim):**

| Path | Why |
|------|-----|
| Blueprint §5 tests 4–5, §7.15–16, §11 score-harness row | The two tests; the fence |
| Charter §4–§12, §18 | Evidence, RECs, no spikes |
| [`docs/working/SORT.md`](docs/working/SORT.md) Graduate G-004 / G-005 | Do not re-sort |
| [`docs/working/DISCOVERY-NOTES.md`](docs/working/DISCOVERY-NOTES.md) locked top | Do not rewrite the dump |
| Runtime report §17 digest + §2 / §9 | Hosts a loop may score |
| Leftovers report §17 digest + `REC-111` / `REC-112` / `OQ-011` | Proposer slot; layer scores stay Watch |

**Do not read / do not attach:**

- Bookmark JSON, unread Articles, PDFs, vault traces
- Watch files (already sorted)
- Placeholder specs / plans / reviews
- Synthesis / spec / plan paths
- Chat history
- `ore/`

---

## How to talk to Robert when you finish

1. The score-harness report is filled (path).
2. This repo still only catalogs ideas. You did not run Harbor.
3. G-004 and G-005 are still two tests. The cousin is not merged.
4. The judge stays read-only. One primary is a rule for later, not a
   number you invented.
5. You have **not** accepted it.
6. Next after he accepts and commits: synthesis, fresh session. Do not
   write it now.

---

## Anti-patterns

- Writing synthesis in this session
- Merging G-004 with “improves while you use it”
- Treating a leftover card (especially GEPA/ACE) as a sixth test
- Nested prompt as G-005
- Re-sorting / opening intake with Exa
- Adding headline test 6
- Marking `score-harness` accepted
- Coding, Harbor run, Arvo smoke test
- Reusing leftover/runtime IDs
- Citing this HANDOFF in the report
- Pretending Exa ran if it did not
- Inventing a Harbor number as if this lab ran one

---

## After the report file exists

1. `just check`
2. Independent validation is allowed — mechanical only (`docs/validations/12-score-harness-research-validation.md`)
3. Human reviews / commits
4. Do not start synthesis

---

## Launch line for the new chat

```text
Read HANDOFF.md and do the job.
```
