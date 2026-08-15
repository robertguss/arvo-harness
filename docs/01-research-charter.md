# Research Charter — arvo-beam-harness-research

- **Artifact type:** Research Charter
- **Program:** arvo-beam-harness-research
- **Status:** Accepted
- **Version:** 1.0
- **Created:** 2026-08-14
- **Last updated:** 2026-08-15
- **Depends on:** Accepted Program Blueprint
  ([`docs/00-program-blueprint.md`](00-program-blueprint.md),
  accepting commit `0b49540cae7d2a30ad4b4b145999e27b82c50dad`)
- **Accepting commit:** `081ad36932be7f3f0df062b592cc306c49f72af4`

> This file is the evidence and decision methodology every later stage
> inherits. It does not conduct the research, write pattern cards, or
> sequence experiments. Robert accepted this draft on 2026-08-15.
> Charter is `accepted` in `research-program.toml` at the commit above.

## 1. Artifact Metadata

| Field | Value |
| ----- | ----- |
| Program ID | arvo-beam-harness-research |
| Artifact | Research Charter |
| Owner | Robert Guss |
| Repository | [robertguss/arvo-beam-harness-research](https://github.com/robertguss/arvo-beam-harness-research) |
| Local tree | this checkout |
| Instrument | local Arvo checkout at `../coding-agent-harness/arvo` (read-only; not an output) |
| Sister tree | `../coding-agent-harness/ore` — ignore unless the owner says so |
| Rigor | focused (approved with the Blueprint) |
| Replication | off by default; do not commission in this repo |
| Spikes in this repo | none (`SPK-###` unused) |
| Identifiers minted here | none |
| Contract | [`program/contracts/research-charter.md`](../program/contracts/research-charter.md) |
| Evidence model | [`program/contracts/evidence-model.md`](../program/contracts/evidence-model.md) |
| Recommendation shape | [`program/templates/recommendation.md`](../program/templates/recommendation.md) |

This repository **only catalogs ideas**. A later sibling repository (name
TBD) runs tests. “Implementation plan” in this program means ranked
hypotheses plus a later measure plus keep/drop. It does not authorize
Elixir, Harbor, or PRs into Arvo **here**.

### Inherited constraints (do not re-litigate)

Copied from the accepted Blueprint §7, in Charter language. Detail stays
in the Blueprint. Amend only through
[`program/reference/amendment-protocol.md`](../program/reference/amendment-protocol.md).

1. Personal lab, not a race and not a pitch.
2. Two programs. This repo writes the catalog. A later sibling repo runs
   tests. The template’s “implementation plan” here sequences hypotheses.
3. No spikes, evals, Harbor runs, or PRs into Arvo **in this repo**.
4. Arvo is the instrument in `../coding-agent-harness/arvo`, not a daily
   driver. “In the tree” is a checkout description, not a finding that a
   feature works.
5. Ignore `ore/` unless the owner says so.
6. The runtime is the framework: swap plugins without dropping state;
   the window is a client of a living agent; brains and hands sit in
   different places.
7. The gap is Arvo’s thin OTP slice (one Session, tools in-process,
   Mix-compile plugins, quit-window kills the VM, file-search native
   code on the brain).
8. Adaptation, not photocopy, not “refuse every rewrite.” A Port-wrapped
   foreign harness is a shell.
9. Intake is closed.
10. Success bar for this program: a catalog (five tests + pattern cards),
    not a working harness.
11. Rigor is **focused**. Replication is off.
12. Three workstreams after this Charter is accepted: runtime, leftovers,
    score-harness. They are not extra headline tests.
13. Five headline tests stay five (`G-001`…`G-005`). Drop none. Invent
    no sixth.
14. G-004 is a lab loop on a **fixed** test set. Do not merge it with
    “improves while you use it.”
15. G-005 helpers are specialized (scout / critic / planner). Arms: none
    / parent-model / smaller-or-local. Local may lose.
16. Phase-2’s first job includes an Arvo smoke check — **there**, not
    here.

Graduate labels `G-001`…`G-005` and dump labels `H-###` / `P-###` /
`V-###` / `XB-###` / `LC-###` are **intake IDs**. Cite them. Do not
reuse those strings as `REC` / `REQ` numbers.

## 2. Research Philosophy

Evidence before confidence. Catalog honesty over completeness.

This lab exists to **see and name** pieces that TypeScript and Python
harnesses keep reinventing, keep the *new* leftover (policy, metric,
loop), and write a catalog another repo can try on a real BEAM. It does
not prove those leftovers work.

Work from these readings:

- **Leftover insight is not BEAM proof.** A paper can be right about a
  policy and still be hosted on a fake operating system. Naming the
  leftover is research. Claiming the adaptation works is a phase-2
  measurement.
- **Checkout text is not function.** A file in `arvo/` can contain a
  function. That does not mean Robert can run it, or that it does what
  the filename suggests.
- **Most intake should stay on Watch.** Leaving an idea there is
  success, not a backlog failure.
- **Popularity is not proof.** Star counts, “everyone uses X,” and
  fashion do not carry a load-bearing recommendation.
- **High confidence is rare** until a human locks a decision or a dated
  primary check confirms a document or source line. Hypotheses about
  what would work stay Medium or Low until phase-2 measures them.
- **One question per stage.** Do not absorb another track’s job to look
  complete.

Polished prose is not evidence. Distinguish verified fact, official
claim, corroboration, community report, experiment, inference, judgment,
user decision, and unverified hypothesis
([`program/contracts/evidence-model.md`](../program/contracts/evidence-model.md)).

## 3. Scope Discipline

One commissioned stage, one primary question, one reserved output path.
The Blueprint §11 row is the question. The commissioning prompt is the
boundary. Do not start the next substantive stage in the same session.

| Rule | Meaning here |
| ---- | ------------ |
| Fresh session | Every substantive stage gets its own session and attachment manifest under `docs/handoffs/`. Preparing prompts, manifests, and mechanical fixes may happen in a non-fresh session. Discovery-plus-Charter, Charter-plus-a-report, or any two focused reports in one context is forbidden. |
| Group A | After **this Charter is accepted**, `runtime`, `leftovers`, and `score-harness` may run in parallel. They do not depend on one another. Package their prompts together if useful; still launch each in a **separate** fresh session. |
| File scope | A stage may write only the paths its prompt and manifest name. Do not silently edit the accepted Blueprint, this Charter (once accepted), or other governing artifacts outside a commissioned revision. |
| Intake | Closed. Do not dump more papers, bookmark JSON, unread X Articles, vault `trace.jsonl`, or 339 stubs. SORT and DISCOVERY-NOTES are enough. Do not re-sort. |
| Code | None in this repo. No Elixir, no spikes, no evals, no Harbor, no smoke test of Arvo, no PRs into `arvo/`. |
| Identifiers | This Charter mints none. Later reports use the Blueprint ranges. Never reuse an ID. Disposition upstream IDs explicitly. |
| Amendment | Adding or dropping a headline test, merging G-004 with its cousin, opening intake, authorizing code here, using `arvo/` as the lab, or leaving focused rigor is material. Use the amendment protocol. |

### What each later stage is for

| Stage | Primary question (do not replace) | Must not do |
| ----- | --------------------------------- | ----------- |
| runtime | What are G-001, G-002, and G-003 on a real BEAM, and what would later prove we have them? | Code; smoke test; invent G-006; absorb leftovers or the overnight loop. |
| leftovers | Which intake ideas become pattern cards on those primitives, and which stay Watch or Refuse? | New intake; promote a Watch item to a headline; build Elixir-LangGraph. |
| score-harness | How should the later repo run G-004 and G-005 so the harness cannot edit the judge, and so the two tests stay unmerged? | Merge G-004 with “improves while you use it”; run the loop; treat a nested prompt as a child session. |
| synthesis | What single catalog-shaped specification do the three accepted reports support? | Invent G-006; write Elixir; silently drop a `REC`. |
| spec / plan spine | Correct the catalog; sequence hypotheses for the sibling repo. | Coding-agent ticket pile; authorize Elixir **here**. |

A later report may *cite* another Group A report only if that report is
already accepted. It must not wait for one (Group A stages do not depend
on each other).

## 4. Source Hierarchy

Keep the contract’s five tiers. Lower-tier evidence may reveal failure
modes. It must not carry a load-bearing recommendation alone when a
stronger source is available.

| Tier | What it is | How to read it here |
| ---- | ---------- | ------------------- |
| 1 | Official specifications, standards, primary documentation, source repositories, first-party release information | OTP / Erlang docs, Elixir docs, Harbor (or equivalent) official docs, Arvo’s own README and source **as instrument text**, first-party release notes. José Valim’s tweets about “the runtime is the framework” are **official claims**, not measurements. A line in `arvo/` is a dated checkout description, not a passing test. |
| 2 | Peer-reviewed research, authoritative institutional publications, maintainer-authored design records, official security advisories | Papers and maintainer notes are **insight sources**. They can name a leftover (what to page, when to compact, how to score a trajectory). They do not prove the leftover on BEAM. Harbor-style method papers inform score-harness *design*; they are not results we have run. |
| 3 | High-quality independent technical analysis, production case studies, reproducible benchmarks | Useful when they report a method or a failure mode. This program has **not** produced tier-3 measurements. Do not write as if we had. |
| 4 | Community reports, issue discussions, forum posts, practitioner anecdotes | Vault notes, X bookmarks, GitHub issues, Discord lore. Closed intake: cite the already-sorted cards (`H-` / `P-` / `V-` / `XB-` / `LC-`), do not reopen the raw dumps. Good for failure modes and Watch reasons. Not enough for a keep. |
| 5 | Vendor marketing and unsourced summaries | Product pages, star counts, “the standard tool,” unsourced threads. Insufficient for any `REC` that later work would spend time on. |

### Program readings that sit on this ladder

- **Blueprint locked constraints** are user decisions already accepted.
  Later stages inherit them. They are not evidence that the tests pass.
- **[`docs/working/SORT.md`](working/SORT.md)** (Graduate table +
  shelves) and the locked top of
  [`docs/working/DISCOVERY-NOTES.md`](working/DISCOVERY-NOTES.md) are
  **framing evidence**. They do not outrank the Blueprint.
- **Grounding snapshot** (what the Arvo tree appeared to contain on a
  date) is a checkout description. Classify it as a verified fact about
  *source text* or as an official claim in-tree, never as a verified
  fact about *runtime behavior*.
- **Star counts, download counts, and “everyone is doing X”** are tier 5
  unless a stronger source independently establishes the *mechanism*.

## 5. Citation Rules

Portable citations only: Markdown links, numbered footnotes, and source
ledgers with URLs and access dates. Do not rely solely on ephemeral UI
citation tokens (chat chips, tool-call ids, uncommitted paste).

Cite, in preference order:

1. This Charter and the accepted Blueprint, for rules and locks.
2. [`docs/working/SORT.md`](working/SORT.md) and
   [`docs/working/DISCOVERY-NOTES.md`](working/DISCOVERY-NOTES.md), for
   framing and intake IDs.
3. `program/contracts/*` and `program/templates/*`, for methodology.
4. Primary URLs (OTP docs, paper pages, José tweets) with an access
   date.
5. A local Arvo path **plus the date (and commit, if known)** of the
   observation.

Do **not** cite as authority: chat history, model memory, root
`HANDOFF.md`, attachment manifests, or `research-program.toml` (index
only). Those files may *point* at sources. They are not the sources.

When you quote Arvo: give the path, the symbol or string observed, and
the observation date. Say what it does **not** prove (that the feature
works when run).

When you cite a paper leftover: cite the paper (or its SORT / Watch
card) and name the leftover in one sentence. Do not treat the citation
as a BEAM result.

## 6. Current-Information Rules

Any claim that can change must be dated with the **actual research
date** of the report: tool versions, APIs, licensing, Harbor (or
equivalent) flags, Elixir / OTP versions, and **what the Arvo checkout
contains**.

Rules for this instrument:

- If you must look at `../coding-agent-harness/arvo`, do it only to
  verify a fact the notes or Blueprint already claim. Record path, date,
  and (if available) commit. Do **not** boot Arvo, run a task, or call
  that look a smoke test.
- If the tree has moved since the grounding snapshot, date the new
  observation. Still classify it as a checkout description.
- José tweets, paper pages, and official docs: record the URL and
  access date. Do not assume last month’s wording is this month’s.
- Do not refresh closed intake. A new paper appearing on arXiv during a
  later stage is not in scope unless a human amends intake.

Stale dated claims are not automatically false. They are **due for
revalidation**. Name the trigger (new OTP release, Arvo commit that
touches Session / Focus / plugins / tools, Harbor scorer change).

## 7. Evidence-Spike Protocol

The protocol exists:
[`program/contracts/evidence-spike.md`](../program/contracts/evidence-spike.md),
template [`program/templates/evidence-spike.md`](../program/templates/evidence-spike.md).

**This repository must not mint `SPK-###`.** `docs/evidence/` stays
empty of spike reports. Focused-tier “spikes only for material
uncertainty” is deferred to the sibling experiment repo. That overlay
does not raise *this* program to standard, and it does not authorize
spikes here.

Later reports still **name** what phase-2 would measure. That naming is
not a spike. Put it in the `REC`’s later-measure field and, if useful,
in the report’s Evidence Spikes section as “none in this repo; phase-2
would …”.

If a report is tempted to run a command that would answer a
load-bearing behavioral question (does quit kill the VM? do hands see
the key? does a plugin swap keep the mailbox?), **stop**. Write the
command as a later measure. Do not run it here.

A later amendment may turn on a single spike only if a claim is
contested and cannot wait for phase-2. That is not planned. Prototype
code must never become architecture by inertia — and there should be no
prototype code in this tree at all.

Phase-2, if it runs spikes, keeps its **own** ledger. It does not
back-fill `SPK-###` into this repo.

## 8. Evidence Ledger Format

Every focused report carries an Evidence Ledger. Minimum fields are
those in [`program/contracts/evidence-model.md`](../program/contracts/evidence-model.md):

| Field | Meaning here |
| ----- | ------------ |
| Evidence ID | Optional `EVD-###` allocated inside that report. Do not collide across reports. |
| Claim | One proposition. |
| Classification | Exactly one class from the table below. |
| Source or spike | Citation. **Not** a `SPK-###` in this repo. |
| Source tier | 1–5 from §4. |
| Date | Publication, release, or observation date. |
| Access or execution date | When *this* report checked it. “Execution” here means “read / looked,” not “ran a spike.” |
| Confidence | High, Medium, or Low — see §11. |
| Limitations | What the evidence does **not** prove. Required. For any Arvo-tree row, include that function is unproven. |
| Contradictory evidence | Related conflict, or none. |
| Downstream use | `REC-###`, `REQ-###`, `DEC-###`, `RSK-###`, or `OQ-###`. |
| Revalidation trigger | When to check again. |

### Claim classes (inherit, then read this way)

| Class | Meaning | Typical use here |
| ----- | ------- | ---------------- |
| Verified fact | Directly confirmed through primary evidence or reliable measurement | A dated read of a document, official page, or **source line**. Not a passing run of Arvo. |
| Official claim | Stated by the vendor, maintainer, standard, or institution | José tweets; OTP / Elixir / Harbor docs; Arvo README claims. |
| Independent corroboration | Confirmed by a strong independent source | Rare. We have not run corroborating experiments. |
| Community observation | Reported by practitioners, not independently proven | Vault notes, issues, bookmark cards. |
| Experimental result | Observed in a documented evidence spike | **Unused in this repo.** |
| Inference | Reasoned from cited evidence | “This paper leftover sits on G-002.” |
| Architectural judgment | Decision balancing evidence and constraints | Host primitive; isolation-ladder order; what stays Watch. |
| User decision | Explicitly selected by the owner | Blueprint §7 locks; five tests; focused rigor; intake closed. |
| Hypothesis | Not yet sufficiently verified | Almost every “this would work on BEAM” sentence. |

### Two distinctions every ledger row must respect

1. **Tree-description vs function.** “`arvo/` contains X on date D” ≠
   “X works.” Misclassifying the first as a verified fact about
   function is a defect.
2. **Paper leftover vs proven adaptation.** “The paper’s insight is Y”
   ≠ “Y on OTP is cheaper / clearer / newly possible.” The second is a
   hypothesis until phase-2 measures it.

`EVD-###` is optional. If a report allocates it, it says so in that
report and does not reuse numbers from another report.

## 9. Recommendation Format

Every `REC-###` uses
[`program/templates/recommendation.md`](../program/templates/recommendation.md)
in full:

- Classification, scope, confidence, decision urgency, evidence
  quality, related decisions
- Recommendation; Requirements and Constraints; Rationale; Evidence;
  Evidence Spikes; Tradeoffs; Failure Modes; Alternatives Considered;
  Downstream Implications; Revisit Triggers

Popularity alone is not sufficient. A major recommendation still needs
credible alternatives, tradeoffs, failure modes, and revisit triggers.

### Extra catalog fields (required on every `REC` in this program)

Add these under the recommendation body, with these names:

| Field | Required content |
| ----- | ---------------- |
| **Claim** | The falsifiable or catalogable proposition, in one or two sentences. |
| **Host primitive** | `G-001`, `G-002`, `G-003`, a named scoring method under `G-004` or `G-005`, or **none**. |
| **Why Watch** | If host is none: why the idea stays Watch or Refuse, not a headline. |
| **Later measure** | What the sibling repo would score, including the honesty / isolation / holdout rule that applies. Not a command run here. |
| **Keep / drop** | The rule a later operator uses after that measure. |

Track-specific extras:

- **runtime:** name exactly one of G-001…G-003. Do not merge two
  primitives into one `REC`. Restate measure and keep/drop; do not
  replace the Blueprint table.
- **leftovers:** also state **why this is not a sixth headline test**.
  Prefer cards that need G-001…G-003 as host.
- **score-harness:** tag **G-004 or G-005, not both**. If G-004, say
  it is the fixed-set lab loop, not “improves while you use it.” If
  G-005, name the specialist and the three arms (none / parent-model /
  smaller-or-local). Local may lose.

### How to fill the template fields here

| Template field | Reading in this catalog |
| -------------- | ----------------------- |
| Classification | **Required** = must appear in the catalog (the five tests; a scoring rule the sibling cannot skip). **Default** = recommended host or card. **Optional** = try only if a Required item needs it. **Watchlist** = stay on Watch (the common leftovers outcome). **Rejected** = Refuse shelf, or a shell (Port-wrapped foreign harness, Elixir-LangGraph, nested prompt taped to a pid). **Experimental** = unused here (no spikes). **Exception** = rare; needs a human decision. |
| Applies to | Sibling-repo test, catalog card, or Watch shelf — never “merge into `arvo/` this week.” |
| Decision urgency | **Required now** = the catalog is dishonest without it. **Required before implementation** = required before the sibling repo runs that test. **May defer** = can stay Watch. “Implementation” means phase-2 measurement, not Elixir in this tree. |
| Evidence quality | **Strong** is rare: a user decision, or a dated primary read of a document or source line. **Moderate**: well-cited inference or judgment with alternatives. **Weak**: community lore, a single paper, or any claim that treats the tree as proven. |
| Evidence Spikes | Write `None in this repo.` Then name the later measure. Do not leave the heading off. |
| Related decisions | `DEC-###` or None. This Charter mints no `DEC`. |

### Identifier ranges (do not mint outside your stage)

| Stage | `REC` range |
| ----- | ----------- |
| runtime | `REC-001`…`REC-099` |
| leftovers | `REC-100`…`REC-199` |
| score-harness | `REC-200`…`REC-299` |

Shared `RSK-###` and `OQ-###` pools are minted by the stage that finds
them. Synthesis converts accepted recommendations into `REQ-001`…`REQ-299`.

## 10. Evaluation Rubric

A later report is **done** when all of the following hold. Completeness
of prose is not the bar.

### Every focused report

1. Every `REC` names **claim, host primitive (or why Watch), later
   measure, and keep/drop**.
2. The Evidence Ledger classifies each material claim; tree-description
   is not scored as function; leftovers are not scored as proven
   adaptations.
3. No `SPK-###` is minted. No Arvo command was run as a test.
4. Intake IDs are cited, not reused as `REC` numbers.
5. High confidence appears only where §11 allows it.
6. Most intake items remain on Watch. The leftovers report must say so
   on purpose. Runtime and score-harness must not raid Watch to look
   busy.
7. The five headline tests are still five. No G-006, including by
   absorbing a Translate cluster.
8. The focused-report contract is met
   ([`program/contracts/focused-research-report.md`](../program/contracts/focused-research-report.md)):
   metadata, executive answer, scope, inherited constraints,
   methodology, source quality, comparative analysis, recommendation
   set, ledgers, risks, weak and conflicting evidence, assumptions,
   open questions, Handoff Digest, source ledger, checklist.

### Track-specific bars

| Track | Extra bar |
| ----- | --------- |
| runtime | G-001, G-002, and G-003 remain distinct. Measure and keep/drop are restated, not replaced. Isolation ladder is thinnest-that-passes, not “add Docker because papers do.” A Port wrapping a foreign harness is named as a drop. |
| leftovers | Pattern card = leftover insight + BEAM noun + why not a sixth headline. Refuse rows stay refused. Translate clusters are hypotheses, not new tests. |
| score-harness | G-004 and G-005 stay split. Scorer / judge tree is read-only. Model is frozen for a scoring run. One primary number is declared before the run (as a rule to use later). G-005 has three arms; local may lose. A nested prompt is not a child session. |

### Spine bars (after the three reports)

- **Synthesis:** every material `REC` has a disposition; no sixth test;
  the specification is a catalog, not a coding spec for this repo.
- **Reviews:** findings attack merge of G-004 with its cousin, “in the
  tree ⇒ works,” Port-as-native, plan-as-backlog, and opened intake.
  Reviews do not add attractive subsystems.
- **Implementation plan:** phases and milestones of *experiments in the
  sibling repo*. First milestone includes the Arvo smoke check
  **there**. Stop before a coding-agent ticket pile.

A report that recommends shipping a feature into `arvo/` as the
outcome of *this* program has failed the rubric.

## 11. Confidence Model

| Level | Allowed when | Forbidden when |
| ----- | ------------ | -------------- |
| **High** | (a) an explicit user decision already locked in the Blueprint or an accepted `DEC`, or (b) a dated primary check of a document or source line, with limitations stated. | Any claim that a leftover works on BEAM; any claim that an Arvo feature works when run; any popularity argument; any undated “the tree contains X.” |
| **Medium** | A well-cited inference or architectural judgment with alternatives, tradeoffs, and a named later measure. Official claims plus a clear leftover extraction. | Treating Medium as “we should build this now.” |
| **Low** | Hypotheses, single-source leftovers, community observations, Watch-shelf speculation, “might collapse into a Graduate we already have.” | Using Low-confidence rows as the sole support for a Required `REC`. |

Default: hypotheses stay **Medium or Low** until phase-2 measures them.
Do not raise confidence by writing more sentences.

Evidence quality and confidence can differ. A High-confidence *user
decision* can still rest on Weak *empirical* evidence that the idea
will work. Say both.

## 12. Risk and Open-Question Format

Mint from the shared pools in the stage that finds the item. Do not
reuse numbers. This Charter mints none.

### `RSK-###`

| Field | Content |
| ----- | ------- |
| ID | `RSK-001`…`RSK-999` |
| Description | What could go wrong in the *catalog* or in a later measurement — not a production-ops novel. |
| Likelihood | High / Medium / Low |
| Impact | High / Medium / Low |
| Mitigation | What this program can do (usually: keep Watch, split tests, forbid a shell). |
| Owner | Stage or human. |
| Trigger | What would make this risk active. |

Risks that matter on sight: merging G-004 with its cousin; treating
Arvo as proven; opening intake; promoting a Watch item to G-006;
Port-as-native; plan-as-backlog; using `arvo/` as the lab.

### `OQ-###`

| Field | Content |
| ----- | ------- |
| ID | `OQ-001`…`OQ-999` |
| Question | One question. |
| Blocking? | Yes only if the *catalog* cannot be honest without an answer. Almost nothing is blocking for phase-2 measurement — that is the point of later measures. |
| Owner | Stage or human. |
| Resolution path | Usually “name a later measure” or “ask the owner.” Not “run a spike here.” |
| Deadline | Stage completion, synthesis, or sibling-repo standup. |

## 13. Replication and Reconciliation Protocol

Replication is **off**. Focused tier. One operator. Load-bearing claims
are tests for a later repo, not findings a second agent must re-derive
here.

The protocol remains on the shelf:
[`program/contracts/replication-reconciliation.md`](../program/contracts/replication-reconciliation.md).
`research-program.toml` may list replication as enabled-but-not-required.
That does not commission a replica.

Reconciliation happens only if a later **amendment** turns a single
replication on. Reconciliation must not choose by majority, length,
confident prose, or model name. Independent reports stay committed.

Do not run a second agent “just to be sure” inside a focused-report
session.

## 14. Synthesis Rules

Inherit [`program/contracts/synthesis.md`](../program/contracts/synthesis.md).

Synthesis is decision-making, not summarization. It reads the accepted
Charter and the three accepted reports in full. It dispositions every
substantive `REC-###` with exactly one of: Accepted, Accepted with
modification, Merged, Deferred, Rejected, Superseded, Not applicable.

Extra rules for this program:

- Do **not** invent G-006. Merging two leftovers into a new headline
  is inventing G-006.
- Do **not** write Elixir, a module list for `arvo/`, or a Harbor run
  plan as if it belonged in this tree.
- Preserve Blueprint §7. A synthesis that “clarifies” G-004 into
  online improvement, or G-005 into a nested planner, has failed.
- Normalize terms to the five tests and the three host primitives.
  Do not introduce a parallel vocabulary (“agent OS,” “control plane”)
  as architecture.
- Convert decisions into `REQ-001`…`REQ-299` for **what the catalog
  claims**, not for tickets in this repo.
- First implementation strategy means the sibling repo’s first
  measurements, starting with the Arvo smoke check **there**.
- Status of the proposed spec: `Proposed — pending adversarial review`.

## 15. Adversarial-Review Rules

Inherit [`program/contracts/adversarial-review.md`](../program/contracts/adversarial-review.md).
Review is a separate discipline. The author is not assumed to have
found the worst flaws. Produce a small number of strong findings, not
a quota.

Severity, finding template, and risk-triggered extra rounds are
unchanged. “Blocks implementation” in a finding means **blocks the
sibling repo from treating the catalog as ready**, not “blocks Elixir
in this tree.”

### Attacks this program’s reviewers must attempt

1. **G-004 collapse.** Did the spec or plan merge the fixed-set lab
   loop with “improves while you use it”?
2. **In the tree ⇒ works.** Did any requirement treat a checkout
   description as a passing product?
3. **Sixth test.** Did a leftover, Translate cluster, or scoring idea
   become G-006?
4. **Port-as-native / Elixir-LangGraph.** Did adaptation become a
   shell or a photocopy?
5. **Plan-as-backlog.** Did the plan decompose into coding-agent
   tickets for *this* repo?
6. **Opened intake or daily-driver drift.** Did we start scraping
   again, or write as if Robert relies on Arvo?
7. **Judge eaten.** Can the harness edit the scorer, the holdout, or
   `program.md` under G-004?
8. **Helper is a prompt.** Is G-005 a nested persona with a process
   id taped on?

Reviews do not add features, MCP, Horde, Oban, libcluster, OTP relups,
or LiveView as identity. Preference is not a defect.

`FND-001`…`FND-199` for the specification. `FND-200`…`FND-399` for
the plan. Findings are proposed corrections, not commandments.

## 16. Validation Rules

Inherit [`program/contracts/validation.md`](../program/contracts/validation.md)
and the `research-validate` skill.

Every substantive artifact needs an independent validation before
human acceptance. The validator is not the author. Validators **fix
mechanical issues only** (whitespace, heading hierarchy, malformed
fences, incorrect internal links, mechanical metadata typos). They do
not invent research, citations, findings, recommendations, spike
results, or architectural decisions.

Substantive defects → stage `requires-revision`. Do not mark the stage
`accepted`.

This Charter’s own validation additionally checks: all 19 sections
project-specialized; no leftover placeholder-status banner on this
file; no sixth test; spikes forbidden here; “in the tree ≠ works”;
popularity is not proof; no focused reports written in the Charter
session; `charter.status` is not `accepted` until a human records the
accepting commit.

`just check` tests tree shape and acceptance consistency. It does not
mean the research is done.

## 17. Handoff Rules

Inherit [`program/contracts/handoffs.md`](../program/contracts/handoffs.md).

- Full artifacts remain authoritative. A Handoff Digest may shrink
  context. It must never silently replace its source report.
- Every fresh session gets an attachment manifest: governing artifacts
  in full (Blueprint + this Charter, once accepted), the stage prompt,
  direct prerequisite reports in full, accepted `DEC`s, and digests
  only for indirect reports unless nuance or conflict requires the
  full file.
- Synthesis and both adversarial reviews receive all three focused
  reports in full.
- Root `HANDOFF.md` and files under `docs/handoffs/` are **maps**, not
  evidence and not citable authority.
- After this Charter is accepted and committed, the next legal work is
  to **package** the three Group A stages. Do not write those reports
  in the Charter session. Do not package them before acceptance if
  that would smuggle a start.

Allowed in a non-fresh session: prepare prompts, manifests, mechanical
fixes, `just check`.

## 18. Anti-Patterns

Inherit [`program/reference/anti-patterns.md`](../program/reference/anti-patterns.md).
Especially: chat-history authority, research by popularity,
evidence-free confidence, silent recommendation loss, placeholder
completion, identifier reuse, plan-as-backlog, implementation before
authority, prototype capture, false parallelism.

### Program-specific (forbidden)

| Anti-pattern | Why it is forbidden here |
| ------------ | ------------------------ |
| Elixir-LangGraph / photocopy | Adaptation, not transcription. If the graph is a supervisor plus messages, say that. Do not port a paper because it is fashionable. |
| Port-as-native | Wrapping a foreign harness in a Port and calling it BEAM-native is a shell. |
| Arvo as daily driver | Robert does not use it and is not sure the tree works. Do not write as if we must protect a live tool. |
| In the tree ⇒ works | Checkout description is not a finding. |
| Opening intake | No more papers, bookmark JSON, unread Articles, or vault traces. |
| Sixth headline | No G-006, including by absorbing leftovers into runtime. |
| G-004 = online improvement | Different cousin. Do not merge. |
| Nested prompt as G-005 | A specialist is its own Session. |
| Plan-as-backlog | The final plan sequences hypotheses for the sibling repo. It is not hundreds of tickets in this tree. |
| Coding / Harbor / smoke test here | Phase-2, not this program. |
| Using `arvo/` as the lab | The lab is the sibling repo. Copying a *winning* file into `arvo/` is a later product gate. |
| Touching `ore/` | Unless the owner says so. |
| MCP / Horde / Oban / libcluster / OTP relups / LiveView as the center | Named non-goals. Study-don’t-build as architecture. |
| Treating Watch as a failure | Most ideas should stay there. |
| Citing HANDOFF or chat | Not authority. |
| Marking a stage accepted without the human’s commit | Git is the record. |
| Raising confidence to High on a hypothesis | Phase-2 measures; this repo names. |

## 19. Completion Standards

A stage is not complete because a filename exists.

A stage is complete when:

1. The commissioning prompt’s required sections are filled with
   project-specific content (no `_To be filled_`, no leftover
   placeholder-status banner on that artifact).
2. Independent validation has passed (or passed with mechanical
   corrections only).
3. The human accepts the artifact.
4. The accepting commit is recorded in `research-program.toml`.
5. Identifiers in scope are minted only in range, never reused, and
   (for synthesis and revisions) every upstream material ID is
   dispositioned.
6. This Charter’s rubric in §10 holds for that stage.

This Charter file meets items 1–4 (filled, independently validated,
human accepted, accepting commit recorded). Later stages still need
their own human accept + commit.

Program-level completion follows Blueprint §21 and
[`program/operator/completion-criteria.md`](../program/operator/completion-criteria.md),
with these readings:

- “Implementation may begin” means the sibling experiment repo may be
  stood up, starting with the Arvo smoke check **there**.
- Every `REC` has a disposition. Every `FND` has a disposition.
- `SPK` remains unused here.
- Five tests still five.
- This repo still contains no experiment code, no Harbor runs, and no
  PRs into Arvo.

The program does **not** succeed by shipping a harness.

## Completion Checklist

- [x] All sections project-specialized where needed
- [x] Source hierarchy and citation rules explicit
- [x] Evidence Ledger and recommendation formats locked
- [x] Human accepts Charter
- [x] Manifest updated; accepting commit recorded
