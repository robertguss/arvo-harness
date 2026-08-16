# Deep Research Prompt — Score the harness

- **Artifact ID:** PROMPT-score-harness
- **Program:** arvo-beam-harness-research
- **Stage:** score-harness — Score the harness
- **Kind:** independent (focused research, group A)
- **Status:** Installed — ready for a fresh execution session
- **Required output:** `docs/reports/12-score-harness-research-report.md`
- **Recommendation range:** `REC-200`…`REC-299`
- **Risk range:** shared `RSK-019`…`RSK-999` (mint from the unused
  bottom; `RSK-001`…`RSK-018` are already minted)
- **Open-question range:** shared `OQ-013`…`OQ-999` (`OQ-001`…`OQ-012`
  already minted; **disposition `OQ-011`**, do not remint it)
- **Depends on:** Accepted Charter (`081ad36932be7f3f0df062b592cc306c49f72af4`)
- **Must cite:** Accepted runtime report
  (`docs/reports/10-runtime-research-report.md`, accepting commit
  `636123f1a628803aa4ae2c44fc4659d167a80693`); accepted leftovers
  report (`docs/reports/11-leftovers-research-report.md`, accepting
  commit `9698362dbe5f90ff48e7aa1093d547d2e14d410a`)
- **Contract:** [`program/contracts/focused-research-prompt.md`](../../program/contracts/focused-research-prompt.md)
- **Report contract:** [`program/contracts/focused-research-report.md`](../../program/contracts/focused-research-report.md)

> This file commissions the score-harness report. It is not the report.
> Do not write leftovers, runtime, or synthesis in the same session.
> Do not mark `score-harness` accepted.

## Role

Act as a skeptical methods designer for a later experiment repo: name
how G-004 and G-005 would be scored so the harness cannot eat the
judge, and so the two tests stay unmerged. Resist “improves while you
use it,” nested-prompt helpers, and a sixth headline.

Talk to Robert in **plain language** when you finish. The report itself
must still use the contract’s section names.

## Mission

Answer:

> How should the later repo run G-004 and G-005 so the harness cannot
> edit the judge, and so the two tests stay unmerged?

Produce [`docs/reports/12-score-harness-research-report.md`](../reports/12-score-harness-research-report.md)
as a complete standalone focused research report.

This repo **still only catalogs ideas**. Name the two scoring methods.
Restate later measure and keep/drop. Do not run Harbor. Do not boot
Arvo. Do not mint `SPK-###`. Do not invent G-006. Do not absorb a
leftover card as a test.

When the file is filled, show Robert a short plain-language summary.
**Do not** accept the report. **Do not** start synthesis.

## Required inputs

Read in the order given in
[`docs/handoffs/score-harness-attachment-manifest.md`](../handoffs/score-harness-attachment-manifest.md)
and the root [`HANDOFF.md`](../../HANDOFF.md). Governing artifacts in
full: accepted Blueprint and accepted Charter. Then this prompt. Then
the accepted runtime report (host nouns a later loop may score). Then
the accepted leftovers report (REC-111 / REC-112 / OQ-011). Then SORT
Graduate G-004 and G-005 only.

## Required output path

`docs/reports/12-score-harness-research-report.md`

Do not create leftover, runtime, or synthesis artifacts. Do not create
a placeholder filename and call the stage done.

## Authority and precedence

Order: [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).

For this stage, project-specific readings:

1. Accepted `DEC-###` (none exist).
2. Locked constraints in
   [`docs/00-program-blueprint.md`](../00-program-blueprint.md) §7,
   especially items 15–16, and the §5 tests 4–5 table.
3. Normative rules in
   [`docs/01-research-charter.md`](../01-research-charter.md),
   especially §9 score-harness extras and §10 score-harness bar.
4. **This prompt.**
5. Accepted runtime report
   ([`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md))
   as **evidence and recommendations**, not a second Blueprint. Host
   nouns G-001…G-003 and their keep/drop stay as runtime named them.
   Score-harness may *score* those hosts later; it must not rename
   them.
6. Accepted leftovers report
   ([`docs/reports/11-leftovers-research-report.md`](../reports/11-leftovers-research-report.md))
   as **evidence and recommendations**. Pattern cards are not tests.
   **REC-111** stays Watch *above* G-004. **REC-112** stays Watch
   *beside* scoring. **OQ-011** is owned by this report.
7. Framing evidence:
   [`docs/working/SORT.md`](../working/SORT.md) Graduate rows
   **G-004 and G-005 only**; locked top of
   [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md)
   (two programs, central insight, adaptation). These do **not**
   outrank the Blueprint.
8. `research-program.toml` is an index only.
9. Root `HANDOFF.md`, this prompt, and the attachment manifest are
   **maps**. Do not cite them as evidence in the report.
10. Chat history and model memory are not authority.

A later report may not secretly amend Blueprint §7. “In the Arvo tree”
is a checkout description, not a finding that a scorer works. A Harbor
method paper is design insight, not a result this lab has run.

## Locked context (do not re-litigate)

From the accepted Blueprint §7 and the accepted Charter. Detail stays
there.

1. Personal lab. Catalog only in this repo.
2. Five headline tests `G-001`…`G-005`. No sixth. Drop none.
3. This track owns **only** G-004 and G-005. Do not absorb runtime’s
   three tests or leftover cards.
4. Intake is closed. Do not dump more papers. Do not re-sort.
5. No spikes, evals, Harbor runs, smoke tests, or PRs into Arvo **here**.
6. Arvo is the instrument in `../coding-agent-harness/arvo`, not a daily
   driver. “In the tree” ≠ “works.”
7. Adaptation, not photocopy, not “refuse every rewrite.” A Port-wrapped
   foreign harness is a shell.
8. Central insight: TypeScript/Python papers specify OTP, then fake an
   OS. Circle the Erlang noun; keep the *new* leftover.
9. **G-004 is a lab loop on a fixed test set.** Frozen model. Scorer /
   judge tree read-only. One primary number declared **before** the
   run. Writable: named harness files. Human owns `program.md`.
   **Not** “improves while you use it.”
10. **G-005 helpers are specialized** (scout / critic / planner) as
    their **own Session**. Three arms: none / parent-model /
    smaller-or-local. Local may lose. A nested prompt with a pid taped
    on is a drop.
11. The G-004 loop does **not** become Arvo’s identity. A winning file
    may later be copied. The loop stays in the sibling repo.
12. Rigor is **focused**. Replication off. `SPK-###` unused here.
13. Phase-2’s first job includes an Arvo smoke check — **there**, not
    here.
14. Accepted runtime host nouns stay named (`REC-001`…`REC-011`).
    Especially: JSONL auto-resume is not G-001 (`REC-003`); Port-wrap
    of a foreign harness is not hands (`REC-006`).
15. Accepted leftovers: GEPA/ACE stay Watch above G-004 (`REC-111`).
    Traces-as-ore / layer scores stay Watch beside scoring (`REC-112`).
    Do not design an online improver. Do not make layer scores G-006.

Graduate labels `G-001`…`G-005` and dump labels `H-` / `P-` / `V-` /
`XB-` / `LC-` are **intake IDs**. Cite them. Do not reuse those strings
as `REC` numbers.

## Stage boundary

### Included

- Name G-004 (overnight keep/reset on a **fixed** test set).
- Name G-005 (specialized helper as its own Session; three arms).
- Write the judge fence: what the harness may edit, what is read-only
  (judge tree, holdout, `program.md`).
- Restate later measure and keep/drop for each test. Do not replace
  the Blueprint / SORT table with a new headline.
- Compare: fixed-set loop vs “improves while you use it”; own Session
  vs nested prompt; one primary vs a layer-scoreboard-as-test.
- Disposition leftovers **OQ-011**: does this report name a proposer
  slot *above* G-004? Cite `REC-111` / `REC-112`. Do not merge them
  into G-004. Do not invent a Harbor number as if this lab ran one.
- Inherit accepted runtime `REC-001`…`REC-011` as hosts a later loop
  may score. Cite them. Do not renumber or silently drop them.
- Write `REC-200`…`REC-299` as needed. Mint `RSK` from `RSK-019` and
  `OQ` from `OQ-013`. Do not remint `OQ-011`.
- Use Exa **REST** (see Methodology) for current Harbor (or
  equivalent) official docs, and to open an *already-cited* primary
  when wording is load-bearing. Do not harvest new papers.

### Excluded

- Coding, `mix` tasks, Harbor **runs**, boot/smoke of Arvo, PRs into
  `arvo/`.
- Minting `SPK-###`.
- Writing `docs/reports/10-*.md`, `11-*.md`, or any specification /
  plan / review.
- Inventing G-006. Promoting a leftover card or Watch cluster to a
  headline. Redesigning G-001…G-003.
- Merging G-004 with “improves while you use it.” Designing an online
  improver. Landing the searcher as Arvo’s identity.
- Treating a nested prompt as a child Session.
- Requiring the parent model to run locally.
- Opening intake (bookmark JSON, PDFs, vault traces, unread Articles,
  arXiv dump via Exa).
- Re-sorting SORT. Reading Watch dump files.
- Building Elixir-LangGraph, photocopying a paper, Port-as-native.
- MCP, Horde, Oban, libcluster, OTP relups, or LiveView as architecture.
- Treating Watch as a failure; raiding Watch to look busy.
- Marking `score-harness` accepted.
- Touching `ore/` unless the owner says so.

## Primary research question

How should the later repo run G-004 and G-005 so the harness cannot
edit the judge, and so the two tests stay unmerged?

## Subsidiary questions

1. **G-004 recipe.** Frozen model, child Session (or child node),
   mutation via `git` and (if useful) `:code.load_binary`, writable
   named files, `results.tsv` (keep / discard / crash), one primary
   per run tag, holdout, simplicity discard. What exactly is writable?
   What is forbidden?
2. **Cousin fence.** What is “improves while you use it,” and why does
   it stay a different cousin? Do not merge it into G-004.
3. **Judge fence.** How does the later repo keep the scorer / judge
   tree, the holdout, and `program.md` off-limits to the harness?
4. **G-005 recipe.** Own Session, not a nested prompt. Scout ≠ critic ≠
   planner. Three arms: none / parent-model / smaller-or-local. Local
   may lose. Parent does not import the child transcript. Child cannot
   `start_turn` on the parent. Scout cannot write or see keys.
5. **G-005 drop.** When is the child “a nested prompt with a pid taped
   on”? When is a second brain an org-chart (V-003) rather than a
   specialist?
6. **Runtime inheritance.** Which accepted `REC-001`…`REC-011` are
   hosts a later loop may score or mutate? Especially: auto-resume is
   not G-001; Port-wrap is not hands.
7. **Leftovers disposition.** Does this report name a proposer slot
   above G-004 (OQ-011 / REC-111)? What may a later judge *watch* from
   REC-112 without inventing a Harbor number or making layer scores
   G-006?
8. **Searcher meta.** Why do Bilevel / AutoHarness / Hermes-style
   “mutate the searcher” ideas stay Watch, with `program.md` on a
   slower clock?

## Inheritance contract

Inherit the accepted Charter in full, especially:

- Source hierarchy and citation rules (§4–§5). Harbor official docs
  are tier 1 *method* sources. Harbor-style papers are tier 2 design
  insight, not results we have run.
- Current-information rules (§6). Date Harbor (or equivalent) flags.
  Local tree only to verify a claimed fact (for example an already-
  named `evals/` path). Do not refresh closed intake.
- Spike rule (§7): **none here**. Name later measures instead.
- Evidence Ledger and claim classes (§8): method paper ≠ run result;
  tree-description ≠ function; leftover insight ≠ proven adaptation.
- Recommendation extra fields (§9): claim, host primitive, why Watch
  if none, later measure, keep/drop. **Score-harness extra:** a
  scoring-method `REC` tags **G-004 or G-005, not both**. If G-004,
  say it is the fixed-set lab loop, not “improves while you use it.”
  If G-005, name the specialist and the three arms; local may lose.
  Leftover-disposition Watchlist `REC`s may keep host **none**.
- Evaluation rubric (§10) score-harness bar: G-004 and G-005 stay
  split; scorer / judge tree read-only; model frozen for a scoring
  run; one primary declared before the run; three G-005 arms; local
  may lose; a nested prompt is not a child Session.
- Confidence model (§11): High is rare. “This loop would raise
  holdout” stays Medium or Low.
- Anti-patterns (§18).

Inherit the Blueprint score-harness row (§11), goals table tests 4–5
(§5), and locks §7.15–§7.16. Do not replace the five tests.

Inherit accepted runtime recommendations `REC-001`…`REC-011` as host
constraints a later loop may score. Disposition is not this stage’s
job except where a scoring rule would *rename* a host — do not.
Do not contradict a Required runtime drop.

Inherit accepted leftovers `REC-100`…`REC-115` as cards, not tests.
**Must disposition** `REC-111`, `REC-112`, and `OQ-011`. Do not remint
those IDs. Do not raid other leftover cards to look busy.

## Required research domains

1. Blueprint §5 tests 4–5, §7 items 15–16, §11 score-harness row.
2. SORT Graduate **G-004 and G-005 only**. Do not re-sort. Do not
   walk Translate / Watch / Refuse as a second leftovers pass.
3. Accepted runtime report: host nouns G-001…G-003 and drop rules
   (especially `REC-003`, `REC-006`).
4. Accepted leftovers report: `REC-111`, `REC-112`, `OQ-011`, digest
   §17. Cards stay cards.
5. DISCOVERY-NOTES locked top: two programs, central insight,
   adaptation. Do not rewrite the H- dump.
6. Harbor (or equivalent) **official** docs — current flags / format
   — as method design. Already-named paper abstracts (GEPA, ACE)
   only if a load-bearing sentence is still thin.
7. Arvo checkout only if a claim already says “the tree already has
   an eval path / headless Harbor artifact.” Date + commit. No boot.

## Methodology

1. Read every required full artifact completely before writing.
2. Work the **locked** two tests. Do not invent a third scoring
   headline.
3. Prefer restating Blueprint / SORT measure and keep/drop over
   rewriting them. Sharpen the fence; do not replace the claim.
4. **Exa via REST** when you must open a current primary page
   ([`AGENTS.md`](../../AGENTS.md) Exa section). Load `EXA_API_KEY`
   from gitignored `.env`. Never print the key.
   - Ordinary lookup: `POST https://api.exa.ai/search` `type` `auto`
     or `fast`, then open the official URL.
   - **Merits ordinary Exa:** current Harbor (or equivalent) official
     docs; an already-cited GEPA / ACE abstract if wording is
     load-bearing for the proposer-slot decision.
   - Deep (`type` `deep` / `deep-reasoning`) or Agent
     (`POST https://api.exa.ai/agent/runs`) only if official Harbor
     wording is thin or contradictory and the fence depends on it.
   - **Does not merit Exa at all:** new arXiv harvest, star counts,
     “what else is hot,” unread Articles, Watch dumps.
   - Exa is retrieval. Classify the *primary* page. Do not classify
     an Exa synthesis as a verified fact. Do not mint `SPK-###`.
   - If the key is missing or the call fails, say so in Methodology
     and continue with built-in search plus Blueprint / SORT /
     Charter / accepted reports. Do not pretend Exa ran. Do not use
     Exa MCP.
5. Compare: G-004 vs cousin; G-005 vs nested prompt; one primary vs
   layer-score-as-test; proposer-above vs proposer-as-G-004. One
   `REC` per decision area. Do not tag both G-004 and G-005 on one
   scoring-method `REC`.
6. Record uncertainty. Name later measures. Do not run them.

## Evidence and citation rules

Inherit Charter §4–§6 and §8.

- Portable Markdown links, footnotes, or a source ledger with URLs
  and access dates. No ephemeral UI tokens.
- Cite Blueprint, Charter, accepted runtime report, accepted leftovers
  report, SORT Graduate G-004/G-005, DISCOVERY-NOTES locked top, and
  official Harbor / already-named primary URLs. Do **not** cite
  HANDOFF, this prompt, chat, or the manifest as evidence.
- Harbor method paper = design insight, not a BEAM result and not a
  run this lab performed.
- Popularity / star counts are not proof.
- Every Evidence Ledger row needs Limitations.
- High confidence: user decision, or a dated primary read. Hypotheses
  about holdout rising stay Medium or Low.

## Evidence-spike policy

**None in this repo.** Inherit Charter §7 and
[`program/contracts/evidence-spike.md`](../../program/contracts/evidence-spike.md)
only as the protocol phase-2 may use later.

In the report’s Evidence Spikes section write `None in this repo.`
Then name later measures. If you are tempted to run a Harbor score or
boot Arvo to “see if the loop works,” **stop**. Write the measure.

## Comparison and scoring requirements

- Five tests stay five. A leftover card is not a test. A layer score
  is not G-006.
- G-004 and G-005 stay **split**. Say so on purpose.
- Scorer / judge tree is read-only. Model is frozen for a scoring run.
- One primary number is declared **before** the run (as a rule to use
  later). Side stats (tokens, time) cannot keep. Holdout required.
  Tiny gain + ugly complexity = discard.
- G-005 has three arms. Local / smaller is allowed to lose — that is
  a result.
- A nested prompt is not a child Session.
- Do not invent a primary Harbor number as if this lab ran one.
  Score-harness may *name* what a later judge would watch (honesty,
  isolation, kill-Focus-lives, stub/reuse) without promoting those
  watches to a sixth test.
- “Copy the loop into `arvo/`” is refused. A winning *file* may later
  be copied. The searcher is not Arvo’s identity.
- Do not raid leftover Watch cards to look busy. Bilevel / AutoHarness
  / Hermes meta stay Watch (`program.md` slower clock).

## Required recommendation identifiers

Use `REC-200`…`REC-299` only. Never reuse. Suggested shape:

- **Required** `REC`s for the catalog-honest scoring rules the sibling
  cannot skip: G-004 fixed-set loop; judge / `program.md` / holdout
  fence; frozen model + one primary before the run; G-005 own Session
  + three arms; loop is not Arvo’s identity.
- **Rejected** `REC`s for the cousin merge, nested-prompt-as-child,
  and searcher-as-product-identity.
- **Watchlist** `REC`s that disposition `REC-111` (proposer slot: name
  whether one exists *above* G-004; leftover stays Watch) and
  `REC-112` (what a later judge may watch; stay Watch; not G-006),
  plus searcher-meta (Bilevel / AutoHarness) if you must name it so
  it is not silently lost.
- Do not mint a Required `REC` that creates a sixth test or an online
  improver.

Every `REC` uses
[`program/templates/recommendation.md`](../../program/templates/recommendation.md)
**plus** Charter catalog fields: Claim, Host primitive, Why Watch,
Later measure, Keep / drop. Scoring-method `REC`s add the
score-harness extra (G-004 *or* G-005; the G-004 / G-005 sentences
above).

Evidence Spikes heading on each `REC`: `None in this repo.` then the
later measure.

## Required risk and open-question ranges

Mint `RSK-019+` and `OQ-013+`. Check accepted runtime (`RSK-001`…
`RSK-009`, `OQ-001`…`OQ-006`), accepted leftovers (`RSK-010`…
`RSK-018`, `OQ-007`…`OQ-012`), and `decisions/` first. Never reuse.

**Disposition `OQ-011` in this report.** Do not remint it. Answer:
does this report name a proposer slot above G-004?

`OQ-007` (density on audit JSONL) is leftovers-named. Do not invent a
Harbor number for it. Leave it to phase-2 unless a G-004 primary
cannot be honest without naming it — and even then, name a later
measure, do not define a fake score.

Format: Charter §12.

Risks that matter on sight: G-004 collapse into “improves while you
use it”; judge eaten; nested prompt as G-005; layer scores as G-006;
GEPA/ACE as an online improver; running the loop here; landing the
searcher as Arvo’s identity; requiring the parent to run locally;
inventing a Harbor number as a result.

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

Header status: `Draft — not accepted`. Record the actual research
date. Cite Blueprint / Charter / runtime / leftovers accepting
commits as this prompt does.

## Required tables

- **Split table:** G-004 vs G-005 — claim × writable / isolation ×
  forbidden × primary / scores × holdout or arms × keep/drop × land
  in `arvo/`?
- **Judge fence:** what the harness may edit vs what is read-only
  (judge tree, holdout, `program.md`, leftover tests).
- **G-004 loop recipe:** frozen model × child Session × mutation
  (`git` / `load_binary`) × writable files × `results.tsv` outcomes ×
  one primary per run tag × holdout × simplicity discard.
- **G-005 arms:** none / parent-model / smaller-or-local × specialist
  (scout / critic / planner) × isolation rules × scores (task
  success, parent waste, dollars, wall time).
- **Runtime inheritance:** which accepted `REC-001`…`REC-011` a later
  loop may score (hosts), without renaming them.
- **Leftovers disposition:** `REC-111` (proposer slot yes/no, still
  Watch) × `REC-112` (what a later judge may watch, still Watch, not
  G-006) × `OQ-011` answer.
- **Evidence Ledger** (Charter fields). Prefer `EVD-200+` if you
  allocate evidence IDs.
- **Recommendation ledger:** ID, title, host (G-004 / G-005 / none),
  classification, confidence, later measure.
- **Source ledger:** URL or path, date accessed, tier.

## Anti-patterns

Inherit [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md)
and Charter §18. Especially here:

- Chat-history authority; citing HANDOFF as evidence
- Merging G-004 with “improves while you use it”
- Nested prompt as G-005
- Sixth headline; leftover card as a test; layer scores as G-006
- Designing an online improver; promoting GEPA/ACE off Watch
- Inventing a Harbor number as if this lab ran one
- Landing the searcher as Arvo’s identity
- Opening intake / re-sorting / Exa-as-arXiv-dump
- Treating Watch as a failure; raiding leftover cards
- Coding / Harbor run / smoke test
- Redesigning G-001…G-003
- Starting synthesis in this session
- Marking the stage accepted
- Evidence-free confidence; High on a hypothesis
- Silent recommendation loss
- Identifier reuse (`REC-001`…`REC-011`, `REC-100`…`REC-115`,
  `RSK-001`…`RSK-018`, `OQ-001`…`OQ-012` are taken)

## Completion checklist

- [ ] Report exists at `docs/reports/12-score-harness-research-report.md`
- [ ] All report-contract headings present and filled
- [ ] Five tests still five; no G-006; leftover cards are not tests
- [ ] G-004 and G-005 stay split; cousin not merged
- [ ] Scorer / judge tree read-only; model frozen; one primary before
      the run
- [ ] G-005 has three arms; local may lose; nested prompt is a drop
- [ ] Each scoring-method `REC` tags G-004 or G-005, not both, plus
      claim, later measure, keep/drop
- [ ] `OQ-011` / `REC-111` / `REC-112` dispositioned; GEPA/ACE still
      Watch above G-004
- [ ] Evidence Ledger: method paper ≠ run; leftover ≠ proven adaptation
- [ ] No `SPK-###`; no Harbor run; no Arvo command run as a test
- [ ] Exa used via REST only as allowed, or failure documented
- [ ] Intake not reopened
- [ ] Shared IDs start at `RSK-019` / `OQ-013`; `REC-200`…`REC-299` only
- [ ] Plain-language summary shown to Robert
- [ ] Human accepts report — **leave unchecked**
- [ ] Manifest updated; accepting commit recorded — **leave unchecked**

## Allowed file scope

**Must write**

- `docs/reports/12-score-harness-research-report.md`

**Allowed extras**

- `docs/working/DISCOVERY-NOTES.md` — one pointer line at the top
- `research-program.toml` — `last_updated_date` and
  `score-harness.status` to `awaiting-validation` if you finish the
  file. Do **not** set `accepted`.
- `docs/validations/12-score-harness-research-validation.md` only if
  an *independent* validator writes it
- `docs/handoffs/score-harness-attachment-manifest.md` if you tighten
  the list you actually used

**Do not edit**

- Accepted Blueprint (except a mechanical link fix)
- Accepted Charter
- Accepted runtime report
- Accepted leftovers report
- SORT substance
- leftovers or runtime outputs beyond citation
- specs, plans, reviews

## Final response requirements

Plain language to Robert. Do not dump section numbers. Say:

1. The score-harness report is filled (path).
2. This repo still only catalogs ideas. You did not run Harbor.
3. G-004 and G-005 are still two tests. The cousin is not merged.
4. The judge stays read-only. One primary is a rule for later, not a
   number you invented.
5. You have **not** accepted the report.
6. Next after he accepts: synthesis in a fresh session. Do not write
   it now.

## Output behavior

Modify only the allowed paths above. Do not modify governing
artifacts or begin downstream stages.
