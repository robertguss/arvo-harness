# Research Charter Prompt — arvo-beam-harness-research

- **Artifact ID:** PROMPT-charter
- **Program:** arvo-beam-harness-research
- **Stage:** charter
- **Kind:** research-charter
- **Status:** Installed — ready for a fresh execution session
- **Required output:** `docs/01-research-charter.md`
- **Depends on:** Accepted discovery (`0b49540cae7d2a30ad4b4b145999e27b82c50dad`)
- **Contract:** [`program/contracts/research-charter.md`](../../program/contracts/research-charter.md)

> This file commissions the Charter. It does not *be* the Charter.
> Do not write focused research reports in the same session.

## Role

Write the Research Charter: the evidence and decision rules every later
stage inherits. Specialize the contract for **this** program. Do not
re-open the Blueprint.

## Mission

Replace the placeholder in `docs/01-research-charter.md`. Keep the 19
section headings. Fill every required contract section with
project-specific rules. No `_To be filled_` / `Placeholder — not accepted`.

Write so a stranger running `runtime`, `leftovers`, or `score-harness`
knows what counts as evidence here.

When the file is filled, show Robert a short plain-language summary.
**Do not** accept the Charter. **Do not** start a research report.

## Authority

Order: [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).

For this stage the accepted Blueprint is governing:

[`docs/00-program-blueprint.md`](../00-program-blueprint.md)

Working notes ([`docs/working/SORT.md`](../working/SORT.md),
[`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md))
are framing evidence. They do not outrank the Blueprint. Chat and this
prompt are not sources to cite in the Charter.

## Locked context (do not re-litigate)

Copy these into the Charter as inherited constraints, in Charter language.
Detail stays in the Blueprint.

1. Personal lab. Catalog only in this repo.
2. Five headline tests `G-001`…`G-005`. No sixth. Drop none.
3. Three workstreams after this Charter: runtime, leftovers, score-harness.
4. Intake is closed.
5. No spikes, evals, Harbor runs, or PRs into Arvo **in this repo**.
6. Arvo is the instrument in `../coding-agent-harness/arvo`, not a daily
   driver. “In the tree” is not “works.”
7. Adaptation, not photocopy, not “refuse every rewrite.” A Port-wrapped
   foreign harness is a shell.
8. G-004 is a lab loop on a **fixed** test set. Do not merge with
   “improves while you use it.”
9. G-005 helpers are specialized. Arms: none / parent-model /
   smaller-or-local. Local may lose.
10. Rigor is **focused**. Replication off by default.
11. This program’s later “implementation plan” sequences hypotheses for a
    sibling experiment repo. It does not authorize Elixir here.
12. Phase-2 first job includes an Arvo smoke check — **there**, not here.

## Stage boundary

### Included

- All required Charter sections, specialized.
- How later reports must classify claims (especially tree-description vs
  function, paper leftover vs proven adaptation).
- Spike rule for *this* repo: **none**. Name that phase-2 may measure.
- Evaluation rubric for catalog `REC`s (leftover + host noun + later
  measure + keep/drop), not for shipping features.
- Source hierarchy that puts OTP/Erlang docs and the Arvo checkout in
  tier 1 as *instruments and official claims*, papers as insight sources,
  and popularity / star counts as insufficient.

### Excluded

- Writing `docs/reports/10-*.md` / `11-*.md` / `12-*.md`
- Changing the five tests or adding tracks
- Re-sorting the dump
- Coding, smoke tests, Harbor
- Marking `charter` accepted
- Decision records (`DEC-###`) unless the human asks for one

## How to specialize the important sections

- **Philosophy:** evidence before confidence; leftover insight ≠ BEAM
  proof; catalog honesty over completeness.
- **Scope discipline:** one stage, one question (Blueprint §11). Group A
  may run in parallel after this Charter is accepted, in separate sessions.
- **Source hierarchy:** keep the five default tiers. Add program notes:
  José tweets are official claims, not measurements. Grounding snapshot
  and `arvo/` source are descriptions of a checkout. Harbor-style method
  papers inform score-harness design; they are not results we have run.
- **Citations:** portable Markdown / footnotes / source ledgers. No
  ephemeral UI tokens. Cite Blueprint, SORT, contracts — not chat.
- **Current-information:** versions, APIs, and “what Arvo contains” must
  be dated. If you must check the local tree, only to verify a fact the
  notes already claim. Do not smoke-test a task.
- **Spikes:** protocol exists in
  [`program/contracts/evidence-spike.md`](../../program/contracts/evidence-spike.md)
  for the sibling repo. This Charter must say **do not mint `SPK-###` here**.
- **Evidence Ledger / recommendations:** inherit
  [`program/contracts/evidence-model.md`](../../program/contracts/evidence-model.md)
  and [`program/templates/recommendation.md`](../../program/templates/recommendation.md).
  Major `REC`s still need alternatives, tradeoffs, failure modes, revisit
  triggers. Popularity is not enough.
- **Evaluation rubric:** a later report is done when each `REC` names the
  claim, the host primitive (or why Watch), the later measure, and
  keep/drop — and when most intake stays on Watch.
- **Confidence:** High is rare (user decision, or a dated primary check).
  Hypotheses stay Medium/Low until phase-2 measures them.
- **Replication:** off. Reconciliation only if a later amendment turns
  one on.
- **Synthesis / review / validation / handoff:** inherit the contracts;
  add: synthesis must not invent G-006; reviews must watch for G-004
  collapse and “in the tree ⇒ works”; validators fix mechanics only.
- **Anti-patterns:** inherit
  [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md)
  plus program-specific: Elixir-LangGraph, Port-as-native, treating Arvo
  as a daily driver, opening intake, plan-as-backlog.

## Identifier allocations

None minted by the Charter. Later reports use the Blueprint ranges
(`REC-001`…`REC-099` runtime, `REC-100`…`REC-199` leftovers,
`REC-200`…`REC-299` score-harness; shared `RSK` / `OQ`).

## Allowed extras in the Charter session

- `research-program.toml` — `last_updated_date` only if needed. Do **not**
  set `charter.status = accepted`.
- One pointer line at the top of `docs/working/DISCOVERY-NOTES.md`.
- `docs/handoffs/charter-attachment-manifest.md` if you tighten the list
  you actually used.

Do not edit the accepted Blueprint except a mechanical link fix. Do not
edit SORT substance.

## Completion checklist (Charter file)

- [ ] All sections project-specialized
- [ ] Source hierarchy and citation rules explicit
- [ ] Evidence Ledger and recommendation formats locked
- [ ] Human accepts Charter — **leave unchecked**
- [ ] Manifest updated; accepting commit recorded — **leave unchecked**

## After the Charter file exists

1. `just check`
2. Independent validation allowed (`research-validate`) — mechanical only
3. Human reviews and commits if they want
4. Do not start a focused research report

## Talk to Robert when you finish

Plain language. Do not dump section numbers. Say: the rules file is
filled; this repo still only catalogs; later reports must treat “in the
tree” as unproven and must not run spikes here; you have not accepted it;
next after he accepts is the three research tracks in fresh sessions.
