# Handoff — write the research rules (Charter)

- **Written:** 2026-08-14
- **From:** Blueprint accepted (`0b49540`) and recorded (`c67ed91`). Fresh session on purpose.
- **Next job:** fill **`docs/01-research-charter.md`**. That is the rules file later stages inherit. Show Robert. **Stop.**
- **Eligible stage (`just status`):** `charter` (prompt-ready). Discovery is accepted. Do not mark Charter accepted.
- **Authority:** Git-tracked files. This handoff is a map, not evidence and not higher than the files it points at.

**How to start this session:** read this file first, then the short attachment list below. Do not scrape papers. Do not sort again. Do not write a research report. Do not code. Do not change the five tests. Do not mark charter accepted.

Talk to Robert in **plain language**. He asked for that. The Charter still has to use the contract’s section names.

---

## What you are doing

The official plan is accepted. Your job is the **Charter**: how this lab decides what counts as evidence, what a recommendation must look like, and what later stages are forbidden to do.

This repo **still only catalogs ideas**. The Charter is methodology, not the runtime report, not leftover pattern cards, and not the scoring design.

When the file is filled, show Robert a short plain-language summary. He must accept it later (human + git). You do not accept it.

Commissioning prompt (full rules for the writer):
[`docs/prompts/01-research-charter-prompt.md`](docs/prompts/01-research-charter-prompt.md).

---

## Locked (do not re-litigate)

From the accepted [`docs/00-program-blueprint.md`](docs/00-program-blueprint.md) §7.

1. Personal lab, not a race.
2. Two programs. This repo writes the catalog. A later sibling repo runs tests.
3. No spikes, evals, or PRs into Arvo **in this repo**.
4. Arvo is not a daily driver. “In the code” ≠ “works.”
5. Local instrument: `../coding-agent-harness/arvo`. Ignore `ore/` unless he says so.
6. Runtime is the framework: window vs brain, hands somewhere else, plugin swap without dropping state.
7. Thin OTP slice is the gap.
8. Adaptation, not photocopy, not “refuse every rewrite.”
9. Intake is closed.
10. Success bar: catalog (five tests + pattern cards), not a working harness.
11. Rigor: focused. Replication off.
12. Three workstreams after this Charter: runtime, leftovers, score-the-harness.
13. Five tests stay five (`G-001`…`G-005`).
14. G-004 ≠ “improves while you use it.”
15. G-005 = specialized helpers; parent-model vs smaller/local; local may lose.

---

## What the Charter must contain

Contract: [`program/contracts/research-charter.md`](program/contracts/research-charter.md).
Fill **every** required section. Keep the 19 headings in
[`docs/01-research-charter.md`](docs/01-research-charter.md).

Specialize for a **catalog-only, focused lab**:

- Spikes: protocol exists for later; **mint none here** (`SPK` unused).
- “In the Arvo tree” is a checkout description, not a finding that a feature works.
- Popularity / star counts are not proof.
- A later `REC` must name: claim, host primitive (or why it stays Watch), later measure, keep/drop.
- High confidence is rare until phase-2 measures something.
- Synthesis must not invent a sixth headline test.
- Reviews must watch for merging G-004 with its cousin, and for “in the tree ⇒ works.”

---

## Read in this order

**Required (full):**

| Path | Why |
|------|-----|
| This file | Job and locks |
| [`docs/prompts/01-research-charter-prompt.md`](docs/prompts/01-research-charter-prompt.md) | Commission |
| [`docs/00-program-blueprint.md`](docs/00-program-blueprint.md) | Accepted plan |
| [`docs/01-research-charter.md`](docs/01-research-charter.md) | Skeleton you replace |
| [`program/contracts/research-charter.md`](program/contracts/research-charter.md) | Required sections |
| [`program/contracts/evidence-model.md`](program/contracts/evidence-model.md) | Ledgers and claim classes |
| [`program/contracts/evidence-spike.md`](program/contracts/evidence-spike.md) | Inherit, then forbid here |
| [`program/templates/recommendation.md`](program/templates/recommendation.md) | Later `REC` shape |
| [`AGENTS.md`](AGENTS.md) | No accept without human |
| [`research-program.toml`](research-program.toml) | Index |

**Required (skim):**

| Path | Why |
|------|-----|
| Blueprint §7, §9, §11 (charter row), §13, §16–§22 | What to inherit |
| [`docs/working/SORT.md`](docs/working/SORT.md) Graduate + Framing only | Five tests; do not re-sort |
| [`docs/working/DISCOVERY-NOTES.md`](docs/working/DISCOVERY-NOTES.md) top only | Locked framing; do not rewrite the dump |
| [`docs/handoffs/charter-attachment-manifest.md`](docs/handoffs/charter-attachment-manifest.md) | Attachment list |
| [`program/reference/anti-patterns.md`](program/reference/anti-patterns.md) | Plus program-specific nos |
| [`program/contracts/authority-and-precedence.md`](program/contracts/authority-and-precedence.md) | Precedence |
| [`program/operator/approval-gates.md`](program/operator/approval-gates.md) | Humans accept Charter |

**Do not read / do not attach:**

- Bookmark JSON, unread Articles, PDFs, vault traces
- Watch files (already sorted)
- Placeholder specs / plans / reviews
- Chat history

---

## How to talk to Robert when you finish

1. The rules file is filled (path).
2. This repo still only catalogs ideas.
3. Later reports may not run spikes here, and may not treat Arvo as proven.
4. You have **not** accepted it.
5. Next after he accepts and commits: the three research tracks (`runtime`, `leftovers`, `score-harness`), each in a fresh session. Package those later. Do not write them now.

---

## Anti-patterns

- Writing a research report in this session
- Re-sorting the dump
- Adding headline test 6
- Marking `charter` accepted
- Coding, Harbor, Arvo smoke test
- Treating Arvo as a daily driver
- Jargon-first explanation to Robert
- Citing this HANDOFF in the Charter

---

## After the Charter file exists

1. `just check`
2. Independent validation is allowed — mechanical only
3. Human reviews / commits
4. Do not start the three reports

---

## Launch line for the new chat

```text
Read HANDOFF.md and do the job.
```
