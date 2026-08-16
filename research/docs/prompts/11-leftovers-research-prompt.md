# Deep Research Prompt — Paper leftovers

- **Artifact ID:** PROMPT-leftovers
- **Program:** arvo-beam-harness-research
- **Stage:** leftovers — Paper leftovers
- **Kind:** independent (focused research, group A)
- **Status:** Installed — ready for a fresh execution session
- **Required output:** `docs/reports/11-leftovers-research-report.md`
- **Recommendation range:** `REC-100`…`REC-199`
- **Risk range:** shared `RSK-010`…`RSK-999` (mint from the unused
  bottom; `RSK-001`…`RSK-009` are already minted by accepted runtime)
- **Open-question range:** shared `OQ-007`…`OQ-999` (`OQ-001`…`OQ-006`
  already minted by accepted runtime)
- **Depends on:** Accepted Charter (`081ad36932be7f3f0df062b592cc306c49f72af4`)
- **May cite:** Accepted runtime report
  (`docs/reports/10-runtime-research-report.md`, accepting commit
  `636123f1a628803aa4ae2c44fc4659d167a80693`)
- **Contract:** [`program/contracts/focused-research-prompt.md`](../../program/contracts/focused-research-prompt.md)
- **Report contract:** [`program/contracts/focused-research-report.md`](../../program/contracts/focused-research-report.md)

> This file commissions the leftovers report. It is not the report.
> Do not write score-harness in the same session.
> Do not mark `leftovers` accepted.

## Role

Act as a skeptical cataloguer of paper leftovers: keep the *new*
insight (policy, metric, loop), sit it on a named BEAM host noun, and
refuse a sixth headline. Resist unsupported complexity and
Elixir-LangGraph.

Talk to Robert in **plain language** when you finish. The report itself
must still use the contract’s section names.

## Mission

Answer:

> Which intake ideas become pattern cards hosted on the runtime
> primitives, and which stay Watch or Refuse?

Produce [`docs/reports/11-leftovers-research-report.md`](../reports/11-leftovers-research-report.md)
as a complete standalone focused research report.

This repo **still only catalogs ideas**. A pattern card is leftover
insight + the BEAM noun it sits on + why it is not a sixth headline.
Most intake stays on Watch **on purpose**. Do not implement cards. Do
not boot Arvo. Do not mint `SPK-###`. Do not invent G-006.

When the file is filled, show Robert a short plain-language summary.
**Do not** accept the report. **Do not** start score-harness.

## Required inputs

Read in the order given in
[`docs/handoffs/leftovers-attachment-manifest.md`](../handoffs/leftovers-attachment-manifest.md)
and the root [`HANDOFF.md`](../../HANDOFF.md). Governing artifacts in
full: accepted Blueprint and accepted Charter. Then this prompt. Then
the accepted runtime report (host nouns you may sit cards on). Then
the SORT shelves and the locked top of DISCOVERY-NOTES.

## Required output path

`docs/reports/11-leftovers-research-report.md`

Do not create a score-harness report. Do not create a placeholder
filename and call the stage done.

## Authority and precedence

Order: [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).

For this stage, project-specific readings:

1. Accepted `DEC-###` (none exist).
2. Locked constraints in
   [`docs/00-program-blueprint.md`](../00-program-blueprint.md) §7.
3. Normative rules in
   [`docs/01-research-charter.md`](../01-research-charter.md).
4. **This prompt.**
5. Accepted runtime report
   ([`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md))
   as **evidence and recommendations**, not a second Blueprint. Host
   nouns G-001…G-003 and their keep/drop stay as runtime named them.
   Do not replace those tests.
6. Framing evidence:
   [`docs/working/SORT.md`](../working/SORT.md) Translate / Watch /
   Refuse shelves + Graduate table only as *host names*; locked top of
   [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md)
   (central insight, adaptation stance). These do **not** outrank the
   Blueprint.
7. `research-program.toml` is an index only.
8. Root `HANDOFF.md`, this prompt, and the attachment manifest are
   **maps**. Do not cite them as evidence in the report.
9. Chat history and model memory are not authority.

A later report may not secretly amend Blueprint §7. “In the Arvo tree”
is a checkout description, not a finding that a leftover works.

## Locked context (do not re-litigate)

From the accepted Blueprint §7 and the accepted Charter. Detail stays
there.

1. Personal lab. Catalog only in this repo.
2. Five headline tests `G-001`…`G-005`. No sixth. Drop none.
3. This track owns **pattern cards**, not the five headlines. Do not
   absorb runtime’s three tests or score-harness’s two.
4. Intake is closed. Do not dump more papers. Do not re-sort.
5. No spikes, evals, Harbor runs, smoke tests, or PRs into Arvo **here**.
6. Arvo is the instrument in `../coding-agent-harness/arvo`, not a daily
   driver. “In the tree” ≠ “works.”
7. Adaptation, not photocopy, not “refuse every rewrite.” A Port-wrapped
   foreign harness is a shell.
8. Central insight: TypeScript/Python papers specify OTP, then fake an
   OS. Circle the Erlang noun; keep the *new* leftover.
9. G-004 is a lab loop on a **fixed** test set. Not this track.
10. G-005 helpers are specialized. Not this track.
11. Rigor is **focused**. Replication off. `SPK-###` unused here.
12. Most ideas stay on Watch. That is success.
13. Refuse rows stay refused (study-don’t-build as architecture).
14. Accepted runtime host nouns: G-001 attach ≠ disk resume; G-002
    thinnest ladder, cookie not a fence, Port-wrap is a shell; G-003
    `load_binary` + two versions, Mix out, no relups
    (`REC-001`…`REC-011`). Sit cards on those. Do not redesign them.

Graduate labels `G-001`…`G-005` and dump labels `H-` / `P-` / `V-` /
`XB-` / `LC-` are **intake IDs**. Cite them. Do not reuse those strings
as `REC` numbers.

## Stage boundary

### Included

- Walk SORT **Translate**, **Watch**, and **Refuse** shelves.
- Write pattern cards for Translate clusters that have a BEAM-shaped
  leftover **and** a host among G-001…G-003 (or an honest “none /
  Watch”).
- For every card: leftover insight + BEAM noun + **why this is not a
  sixth headline** + later measure + keep/drop.
- Leave most Watch items on Watch, with a one-line reason.
- Keep Refuse rows refused, with a one-line reason (do not research
  them as centers).
- Inherit accepted runtime `REC`s as host names. Cite them. Do not
  renumber or silently drop them.
- Write `REC-100`…`REC-199` as needed. Mint `RSK` from `RSK-010` and
  `OQ` from `OQ-007`.
- Use Exa **REST** (see Methodology) only to open a *already-cited*
  primary page when the leftover’s official wording matters. Do not
  harvest new papers.

### Excluded

- Coding, `mix` tasks, Harbor, boot/smoke of Arvo, PRs into `arvo/`.
- Minting `SPK-###`.
- Writing `docs/reports/10-*.md` or `12-*.md`.
- Inventing G-006. Promoting a Watch or Translate cluster to a
  headline. Redesigning G-001…G-005.
- Opening intake (bookmark JSON, PDFs, vault traces, unread Articles,
  arXiv dump via Exa).
- Re-sorting SORT.
- Building Elixir-LangGraph, photocopying a paper, Port-as-native.
- MCP, Horde, Oban, libcluster, OTP relups, or LiveView as architecture.
- Treating Watch as a failure; raiding Watch to look busy.
- G-004 / G-005 design (score-harness). “Improves while you use it.”
- Marking `leftovers` accepted.
- Touching `ore/` unless the owner says so.

## Primary research question

Which intake ideas become pattern cards hosted on the runtime
primitives, and which stay Watch or Refuse?

## Subsidiary questions

1. **Cards.** For each Translate cluster, what is the leftover
   (policy / metric / loop), what BEAM noun does it sit on, and why
   is it not G-006?
2. **Host.** Which cards need G-001, G-002, or G-003 as host? Which
   have host **none** and stay Watch?
3. **Watch.** Why do the Watch clusters stay Watch? One honest line
   each. Do not promote.
4. **Refuse.** Why do the Refuse rows stay refused? Do not reopen them
   as research centers.
5. **Cousins of G-004 / G-005.** GEPA/ACE-as-proposers and similar sit
   *above* keep/reset or *beside* specialists. Card the leftover if
   needed; do not merge into G-004 or G-005 and do not design those
   tests.
6. **Runtime inheritance.** What do accepted `REC-001`…`REC-011` change
   about where a card may sit (e.g. RLM default on hands, no `eval` on
   Session, no Port-wrap as native)?

## Inheritance contract

Inherit the accepted Charter in full, especially:

- Source hierarchy and citation rules (§4–§5).
- Current-information rules (§6). Local tree only to verify a claimed
  fact. Do not refresh closed intake.
- Spike rule (§7): **none here**. Name later measures instead.
- Evidence Ledger and claim classes (§8): leftover insight ≠ proven
  adaptation; tree-description ≠ function.
- Recommendation extra fields (§9): claim, host primitive **or why
  Watch**, later measure, keep/drop, and leftovers extra **why this is
  not a sixth headline**.
- Evaluation rubric (§10) leftovers bar: most items still Watch;
  Refuse stays refused; Translate clusters are hypotheses.
- Confidence model (§11): High is rare. “This leftover would sing on
  BEAM” stays Medium or Low.
- Anti-patterns (§18).

Inherit the Blueprint leftovers row (§11) and goals table (§5). Do not
replace the five tests.

Inherit accepted runtime recommendations `REC-001`…`REC-011` as host
constraints. Disposition is not this stage’s job (synthesis does that).
Do not contradict a Required runtime drop (shared cookie, Port-wrap,
Mix-in-VM, relups, auto-resume-as-G-001).

## Required research domains

1. SORT Translate / Watch / Refuse (already sorted). Cite cluster
   names and merged intake IDs.
2. Accepted runtime report: host nouns G-001…G-003 and drop rules.
3. DISCOVERY-NOTES locked top: central insight, adaptation stance,
   José’s three official claims (already measured as *claims*, not
   results).
4. Primary pages **already named** on a card (paper abstract page,
   José tweet, official OTP/Elixir/Livebook URL) when wording is
   load-bearing. Do not open unread PDFs or bookmark JSON.
5. Arvo checkout only if a card claims “the tree already has X.”
   Date + commit. No boot.

## Methodology

1. Read every required full artifact completely before writing.
2. Work the **closed** shelves. Do not invent a new sort.
3. Prefer cards that need G-001…G-003. Prefer Watch over a thin card.
4. **Exa via REST** when you must open a current primary page
   ([`AGENTS.md`](../../AGENTS.md) Exa section). Load `EXA_API_KEY`
   from gitignored `.env`. Never print the key.
   - Ordinary lookup: `POST https://api.exa.ai/search` `type` `auto`
     or `fast`, then open the official URL.
   - Deep (`type` `deep` / `deep-reasoning`) or Agent
     (`POST https://api.exa.ai/agent/runs`) only if an *already-cited*
     leftover’s official wording is thin or contradictory.
   - **Does not merit Exa at all:** new arXiv harvest, star counts,
     Harbor boards, unread Articles, “what else is hot.”
   - Exa is retrieval. Classify the *primary* page. Do not classify
     an Exa synthesis as a verified fact. Do not mint `SPK-###`.
   - If the key is missing or the call fails, say so in Methodology
     and continue with built-in search plus local SORT/runtime. Do
     not pretend Exa ran. Do not use Exa MCP.
5. Compare: card vs Watch vs Refuse. One `REC` per decision area.
   Do not merge two host primitives into one card’s host field.
6. Record uncertainty. Name later measures. Do not run them.

## Evidence and citation rules

Inherit Charter §4–§6 and §8.

- Portable Markdown links, footnotes, or a source ledger with URLs
  and access dates. No ephemeral UI tokens.
- Cite Blueprint, Charter, accepted runtime report, SORT, DISCOVERY-NOTES,
  and already-named primary URLs. Do **not** cite HANDOFF, this prompt,
  chat, or the manifest as evidence.
- Paper leftover = insight source, not a BEAM result.
- Popularity / star counts are not proof.
- Every Evidence Ledger row needs Limitations.
- High confidence: user decision, or a dated primary read. Hypotheses
  about adaptation stay Medium or Low.

## Evidence-spike policy

**None in this repo.** Inherit Charter §7 and
[`program/contracts/evidence-spike.md`](../../program/contracts/evidence-spike.md)
only as the protocol phase-2 may use later.

In the report’s Evidence Spikes section write `None in this repo.`
Then name later measures. If you are tempted to run a Harbor score or
boot Arvo to “see if the leftover helps,” **stop**. Write the measure.

## Comparison and scoring requirements

- Five tests stay five. A card is not a test.
- Most intake remains Watch. Say so on purpose. Count or tabulate so
  a reader can see it.
- Refuse stays refused.
- Prefer host G-001, G-002, or G-003. Host **none** ⇒ Why Watch.
- Do not score leftovers as proven adaptations.
- Do not invent a primary Harbor number for a card (that is
  score-harness / phase-2). A card’s later measure may *name* what
  phase-2 would watch if it ever tried the leftover.
- “Copy into `arvo/` later” is not this track’s landing table. Cards
  may say lab-only / Watch.

## Required recommendation identifiers

Use `REC-100`…`REC-199` only. Never reuse. Suggested shape:

- One `REC` per Translate cluster you keep as a **Default** or
  **Optional** card (or merge two clusters only if they are the same
  leftover — say so).
- **Watchlist** `REC`s for Watch shelves you must name so they are
  not silently lost (you may group a Watch shelf as one `REC` with
  merged IDs listed).
- **Rejected** `REC`s for Refuse shelves you must keep refused (group
  allowed; list merged IDs).
- Do not mint a Required `REC` that creates a sixth test.

Every `REC` uses
[`program/templates/recommendation.md`](../../program/templates/recommendation.md)
**plus** Charter catalog fields: Claim, Host primitive (G-001, G-002,
G-003, or **none**), Why Watch, Later measure, Keep / drop, and
**Why this is not a sixth headline**.

Evidence Spikes heading on each `REC`: `None in this repo.` then the
later measure.

## Required risk and open-question ranges

Mint `RSK-010+` and `OQ-007+`. Check accepted runtime (`RSK-001`…
`RSK-009`, `OQ-001`…`OQ-006`) and `decisions/` first. Never reuse.

Format: Charter §12.

Risks that matter on sight: sixth headline; raiding Watch; photocopy /
Elixir-LangGraph; opening intake; treating a leftover as proven on
BEAM; collapsing G-004’s cousin into a card-as-test.

## Exact report structure

Use these headings, in this order
([`program/contracts/focused-research-report.md`](../../program/contracts/focused-research-report.md)):

1. Artifact metadata and actual research date
2. Executive answer
3. Scope and exclusions
4. Inherited constraints
5. Methodology (include how Exa was used, or why it was not)
6. Source quality and limitations
7. Evidence spikes (`None in this repo` + named later measures)
8. Comparative analysis
9. One coherent recommendation set (the `REC` bodies)
10. Evidence Ledger
11. Recommendation ledger (index table)
12. Risks
13. Weak evidence
14. Conflicting evidence
15. Assumptions
16. Open questions
17. Handoff Digest (all digest fields from the report contract)
18. Source ledger
19. Completion checklist

## Required tables

- **Shelf outcomes:** Translate / Watch / Refuse × what happened
  (card / stay Watch / stay Refuse) × merged intake IDs. Every SORT
  cluster from those three shelves appears once.
- **Pattern cards:** leftover insight × BEAM noun × host (G-001 /
  G-002 / G-003 / none) × why not a sixth headline × later measure ×
  keep/drop.
- **Runtime inheritance:** which accepted `REC-001`…`REC-011` constrain
  which cards.
- **Evidence Ledger** (Charter fields).
- **Recommendation ledger:** ID, title, host, classification,
  confidence, later measure.
- **Source ledger:** URL or path, date accessed, tier.

## Anti-patterns

Inherit [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md)
and Charter §18. Especially here:

- Chat-history authority; citing HANDOFF as evidence
- Sixth headline; promoting Watch
- Photocopy / Elixir-LangGraph / Port-as-native
- Leftover scored as proven adaptation
- Opening intake / re-sorting / Exa-as-arXiv-dump
- Treating Watch as a failure
- Coding / Harbor / smoke test
- Redesigning G-001…G-005
- Starting score-harness in this session
- Marking the stage accepted
- Evidence-free confidence; High on a hypothesis
- Silent recommendation loss
- Identifier reuse (`REC-001`…`REC-011`, `RSK-001`…`RSK-009`,
  `OQ-001`…`OQ-006` are taken)

## Completion checklist

- [ ] Report exists at `docs/reports/11-leftovers-research-report.md`
- [ ] All report-contract headings present and filled
- [ ] Five tests still five; no G-006
- [ ] Each `REC` has claim, host (or why Watch), later measure,
      keep/drop, and why not a sixth headline
- [ ] Most intake still Watch; Refuse still refused
- [ ] Evidence Ledger: leftover ≠ proven adaptation
- [ ] No `SPK-###`; no Arvo command run as a test
- [ ] Exa used via REST only as allowed, or failure documented
- [ ] Intake not reopened
- [ ] Shared IDs start at `RSK-010` / `OQ-007`
- [ ] Plain-language summary shown to Robert
- [ ] Human accepts report — **leave unchecked**
- [ ] Manifest updated; accepting commit recorded — **leave unchecked**

## Allowed file scope

**Must write**

- `docs/reports/11-leftovers-research-report.md`

**Allowed extras**

- `docs/working/DISCOVERY-NOTES.md` — one pointer line at the top
- `research-program.toml` — `last_updated_date` and
  `leftovers.status` to `awaiting-validation` if you finish the
  file. Do **not** set `accepted`.
- `docs/validations/11-leftovers-research-validation.md` only if an
  *independent* validator writes it
- `docs/handoffs/leftovers-attachment-manifest.md` if you tighten
  the list you actually used

**Do not edit**

- Accepted Blueprint (except a mechanical link fix)
- Accepted Charter
- Accepted runtime report
- SORT substance
- score-harness outputs
- specs, plans, reviews

## Final response requirements

Plain language to Robert. Do not dump section numbers. Say:

1. The leftovers report is filled (path).
2. This repo still only catalogs ideas.
3. Most items stayed on Watch. No sixth test.
4. You did not run spikes or treat leftovers as proven on BEAM.
5. You have **not** accepted the report.
6. Next after he accepts: score-harness in a fresh session. Do not
   write it now.

## Output behavior

Modify only the allowed paths above. Do not modify governing
artifacts or begin downstream stages.
