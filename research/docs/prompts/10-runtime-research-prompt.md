# Deep Research Prompt — Runtime primitives

- **Artifact ID:** PROMPT-runtime
- **Program:** arvo-beam-harness-research
- **Stage:** runtime — Runtime primitives
- **Kind:** independent (focused research, group A)
- **Status:** Installed — ready for a fresh execution session
- **Required output:** `docs/reports/10-runtime-research-report.md`
- **Recommendation range:** `REC-001`…`REC-099`
- **Risk range:** shared `RSK-001`…`RSK-999` (mint from the unused bottom)
- **Open-question range:** shared `OQ-001`…`OQ-999` (mint from the unused bottom)
- **Depends on:** Accepted Charter (`081ad36932be7f3f0df062b592cc306c49f72af4`)
- **Contract:** [`program/contracts/focused-research-prompt.md`](../../program/contracts/focused-research-prompt.md)
- **Report contract:** [`program/contracts/focused-research-report.md`](../../program/contracts/focused-research-report.md)

> This file commissions the runtime report. It is not the report.
> Do not write leftovers or score-harness in the same session.
> Do not mark `runtime` accepted.

## Role

Act as a BEAM / OTP systems researcher and a skeptical Elixir maintainer
who resists unsupported complexity. Write a **catalog** of three host
primitives, not a coding spec and not a product pitch.

Talk to Robert in **plain language** when you finish. The report itself
must still use the contract’s section names.

## Mission

Answer:

> What exactly are G-001, G-002, and G-003 on a real BEAM, and what
> would a later repo measure to keep or drop each one?

Produce [`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md)
as a complete standalone focused research report.

This repo **still only catalogs ideas**. Name the primitives. Restate
later measure and keep/drop. Do not implement them. Do not boot Arvo.
Do not mint `SPK-###`.

When the file is filled, show Robert a short plain-language summary.
**Do not** accept the report. **Do not** start another track.

## Required inputs

Read in the order given in
[`docs/handoffs/runtime-attachment-manifest.md`](../handoffs/runtime-attachment-manifest.md)
and the root [`HANDOFF.md`](../../HANDOFF.md). Governing artifacts in
full: accepted Blueprint and accepted Charter. Then this prompt. Then
the framing slices named below.

## Required output path

`docs/reports/10-runtime-research-report.md`

Do not create leftover or score-harness reports. Do not create a
placeholder filename and call the stage done.

## Authority and precedence

Order: [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).

For this stage, project-specific readings:

1. Accepted `DEC-###` (none exist).
2. Locked constraints in
   [`docs/00-program-blueprint.md`](../00-program-blueprint.md) §7.
3. Normative rules in
   [`docs/01-research-charter.md`](../01-research-charter.md).
4. **This prompt.**
5. Framing evidence:
   [`docs/working/SORT.md`](../working/SORT.md) Graduate rows G-001…G-003
   + José Translate clusters; locked top of
   [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md)
   (hypothesis, central insight, grounding snapshot). These do **not**
   outrank the Blueprint.
6. `research-program.toml` is an index only.
7. Root `HANDOFF.md`, this prompt, and the attachment manifest are
   **maps**. Do not cite them as evidence in the report.
8. Chat history and model memory are not authority.

A later report may not secretly amend Blueprint §7. “In the Arvo tree”
is a checkout description, not a finding that a feature works.

## Locked context (do not re-litigate)

From the accepted Blueprint §7 and the accepted Charter. Detail stays
there.

1. Personal lab. Catalog only in this repo.
2. Five headline tests `G-001`…`G-005`. No sixth. Drop none.
3. This track owns **only** G-001, G-002, G-003. Do not absorb leftovers
   or the overnight loop.
4. Intake is closed. Do not dump more papers.
5. No spikes, evals, Harbor runs, smoke tests, or PRs into Arvo **here**.
6. Arvo is the instrument in `../coding-agent-harness/arvo`, not a daily
   driver. “In the tree” ≠ “works.”
7. Adaptation, not photocopy, not “refuse every rewrite.” A Port-wrapped
   foreign harness is a shell — drop it if it shows up as “hands.”
8. G-004 is a lab loop on a **fixed** test set. Not this track.
9. G-005 helpers are specialized. Not this track.
10. Rigor is **focused**. Replication off. `SPK-###` unused here.
11. Phase-2’s first job includes an Arvo smoke check — **there**, not
    here.
12. José’s bet (official claim, not a measurement): swap plugins without
    dropping state; the window is a client of a living agent; brains and
    hands sit in different places (Livebook-shaped).
13. The gap is Arvo’s thin OTP slice: one Session, tools in-process,
    Mix-compile plugins, quit-window kills the VM, file-search native
    code on the brain.

Graduate labels `G-001`…`G-005` and dump labels `H-` / `P-` / `V-` /
`XB-` / `LC-` are **intake IDs**. Cite them. Do not reuse those strings
as `REC` numbers.

## Stage boundary

### Included

- Name G-001 (window vs brain / attach to a living Session).
- Name G-002 (hands somewhere else; thinnest isolation ladder that
  would later pass keys + kill-hands + same task).
- Name G-003 (plugin swap without Mix in the live app and without OTP
  relups).
- Describe what the Arvo *tree* appears to contain for those three,
  dated. Local tree only to verify a fact the notes already claim.
- Restate later measure and keep/drop for each test. Do not replace
  the Blueprint / SORT table with a new headline.
- Compare credible host options (process / Port / hidden `:peer` /
  Docker node; two-version modules vs `Code.append_path` vs relups).
- Write `REC-001`…`REC-099` as needed. Mint `RSK` / `OQ` from the
  shared pools if the catalog needs them.
- Use Exa (search, and deep research when merited) for **current
  primary sources** on those primitives. See Methodology.

### Excluded

- Coding, `mix` tasks, Harbor, boot/smoke of Arvo, PRs into `arvo/`.
- Minting `SPK-###`.
- Writing `docs/reports/11-*.md` or `12-*.md`.
- Inventing G-006. Absorbing Translate leftovers as new headlines.
- G-004 / G-005 design (score-harness). “Improves while you use it.”
- Opening intake (bookmark JSON, PDFs, vault traces, unread Articles).
- MCP, Horde, Oban, libcluster, OTP relups, or LiveView as the
  architecture. Livebook is a **brains-vs-nodes** official claim, not
  a UI to become.
- Treating Watch as a failure; raiding Watch to look busy.
- Marking `runtime` accepted.
- Touching `ore/` unless the owner says so.

## Primary research question

What exactly are G-001, G-002, and G-003 on a real BEAM, and what
would a later repo measure to keep or drop each one?

## Subsidiary questions

1. **G-001.** What does “quit the window, agent stays” mean as OTP
   supervision (permanent Session, temporary Focus / attach process)?
   How is that different from JSONL auto-resume after a VM death?
   What does the Arvo tree appear to do on Focus quit (checkout
   description only)?
2. **G-002.** What is the isolation ladder (process → Port → hidden
   `:peer` node → Docker node), and what would “thinnest that passes”
   mean later? What must a later negative key test and a kill-hands
   mid-tool test show? Why is a shared cookie not a fence?
3. **G-003.** What would a real plugin swap look like (`:code.load_binary`
   / two-version modules / soft-purge after the turn) versus Mix in
   the product VM or OTP relups? What mailbox / in-flight-turn /
   next-turn-manifest facts would later prove it?
4. **Instrument.** Which grounding-snapshot claims (DISCOVERY-NOTES
   2026-08-14) still match the local tree **as text**? Date the check.
   Do not run the product.
5. **Official claims.** What do current OTP / Erlang / Elixir docs
   actually say about the host nouns? What did José claim, and what
   did he not measure?
6. **Comparisons.** OpenCode-like attach and Pi-like plugin reload
   are existence proofs of *need*, not architectures to swallow.
   Livebook standalone runtime is the official “brains vs hands”
   cousin. What, if anything, do those sources change about the
   *host nouns* — not about chrome?

## Inheritance contract

Inherit the accepted Charter in full, especially:

- Source hierarchy and citation rules (§4–§5).
- Current-information rules (§6): date versions, APIs, and “what
  Arvo contains.” Local tree only to verify a claimed fact.
- Spike rule (§7): **none here**. Name later measures instead.
- Evidence Ledger and claim classes (§8): tree-description vs
  function; leftover vs proven adaptation.
- Recommendation extra fields (§9): claim, host primitive, why
  Watch, later measure, keep/drop. Runtime `REC`s name **exactly
  one** of G-001…G-003.
- Evaluation rubric (§10) and confidence model (§11): High is rare.
- Anti-patterns (§18).

Inherit the Blueprint runtime row (§11) and goals table (§5) for the
three tests. Restate measure and keep/drop. Do not replace them.

## Required research domains

1. OTP / Erlang official docs: processes, mailboxes, supervisors,
   Ports, distribution, hidden nodes, cookies, `:erpc`, `:pg` /
   Registry, `:code` (load, purge, two versions).
2. Elixir official docs only where they wrap those nouns (Task,
   Supervisor, `Code`, mix-in-VM hazards).
3. José Valim’s tweets named in DISCOVERY-NOTES (official claims).
4. Livebook’s **documented** standalone / runtime split (official
   claim about brains vs nodes — not “become LiveView”).
5. Arvo checkout as instrument text (`../coding-agent-harness/arvo`,
   currently present; record commit if you look).
6. Closed intake already sorted: SORT Graduate G-001…G-003 and the
   José / surfaces / isolation Translate clusters that are
   *mechanisms of those three tests*. Do not promote Watch items.

## Methodology

1. Read every required full artifact completely before writing.
2. Do **current** source-backed research. Prefer primary sources
   (tier 1–2 in the Charter).
3. **Use Exa** for that current research. Robert required it. Cost
   is not a reason to skip; the Exa account has balance.
   - Discover tools first: `search_tool` query `exa`.
   - If Exa MCP is connected, use it (`web_search_exa`,
     `web_fetch_exa`; `web_search_advanced_exa` when you need
     domain filters; `agent_run` / deep types when merited).
   - If MCP is missing, add or call Exa another way (Grok
     marketplace plugin **exa** at `https://mcp.exa.ai/mcp`, or
     REST `https://api.exa.ai/search` with `EXA_API_KEY`, or
     `npx -y exa-mcp-server`). Do not paste keys into the report.
   - **Ordinary lookup:** Exa search (`auto` / `fast`) + fetch the
     official page.
   - **Deep research when merited:** Exa `deep` or `deep-reasoning`
     search, or Exa Agent (`agent_run`, effort `high` or `xhigh` if
     the question is load-bearing). Cost is allowed.
   - **Merits deep research:** official OTP isolation vs
     distribution vs cookies; official code-server / two-version
     modules vs relups; official Livebook runtime split. Thin or
     contradictory documentary evidence on a load-bearing host
     noun.
   - **Does not merit deep research:** paper surveys, star counts,
     Harbor leaderboards, new intake, product chrome.
   - Exa output is **retrieval**, not a finding. Open the cited
     primary URL. Classify the *primary* page (official claim,
     verified fact about a document, etc.). Do not classify an Exa
     synthesis as a verified fact. Do not mint `SPK-###` for an
     Exa run.
   - **Do not use Exa to reopen intake** (no arXiv dump, no new
     bookmark harvest).
   - If Exa cannot be reached after a genuine attempt, say so in
     Methodology, then continue with built-in `web_search` /
     `open_page` / `web_fetch` and local sources. Do not pretend
     Exa ran.
4. Inspect the local Arvo tree **only** to verify a fact the notes
   or Blueprint already claim. Record path, date, commit
   (`84004e1` was HEAD when this package was written; re-check).
   Do **not** boot Arvo or run a task.
5. Compare credible alternatives. Make **one** recommendation per
   decision area. Do not merge two primitives into one `REC`.
6. Record uncertainty, weak evidence, and contradictions.
7. Name what phase-2 would measure. Do not run it.

## Evidence and citation rules

Inherit Charter §4–§6 and §8.

- Portable Markdown links, footnotes, or a source ledger with URLs
  and access dates. No ephemeral UI tokens.
- Cite Blueprint, Charter, SORT, DISCOVERY-NOTES, official docs,
  José tweet URLs, and dated Arvo paths. Do **not** cite HANDOFF,
  this prompt, chat, or the manifest as evidence.
- José tweets = official claims, not measurements.
- Grounding snapshot + `arvo/` source = checkout description.
- Popularity / star counts are not proof.
- Every Evidence Ledger row needs Limitations. For any Arvo-tree
  row, include that function is unproven.
- High confidence: user decision, or a dated primary read of a
  document or source line. Hypotheses about “this would work”
  stay Medium or Low.

## Evidence-spike policy

**None in this repo.** Inherit Charter §7 and
[`program/contracts/evidence-spike.md`](../../program/contracts/evidence-spike.md)
only as the protocol phase-2 may use later.

In the report’s Evidence Spikes section write `None in this repo.`
Then name the later measures. If you are tempted to run a command
that would answer “does quit kill the VM?” / “do hands see the
key?” / “does a swap keep the mailbox?”, **stop**. Write the
command as a later measure.

## Comparison and scoring requirements

- Keep G-001, G-002, and G-003 **distinct**.
- G-002 ladder: keep the *thinnest* layer that would later pass
  isolation + survival + same task. Drop a layer that only adds
  latency. Drop Port-wrapping a foreign harness.
- G-003: Mix must leave the product VM for a keep. Relups are the
  wrong tool. `Code.append_path` plus hope is a drop.
- G-001: keep if attach is not just disk resume. Drop if we only
  wrapped auto-resume in boot scripts.
- Restate Blueprint / SORT measure and keep/drop; do not invent a
  new primary score for this catalog track (scoring design is
  score-harness).
- “Copy into `arvo/` later” stays a later product gate. This
  report may say yes-candidate / lab-first. It may not ship.

## Required recommendation identifiers

Use `REC-001`…`REC-099` only. Never reuse. Suggested shape (you
may merge or split *within* a test, never across tests):

- At least one **Required** `REC` for G-001.
- At least one **Required** `REC` for G-002 (include the ladder
  and the drop rule for a shell).
- At least one **Required** `REC` for G-003 (include Mix-out and
  no-relups).
- Optional further `REC`s in range for named host options
  (Watchlist / Rejected / Optional).

Every `REC` uses
[`program/templates/recommendation.md`](../../program/templates/recommendation.md)
**plus** the Charter catalog fields: Claim, Host primitive, Why
Watch, Later measure, Keep / drop. Host primitive is exactly one
of G-001, G-002, G-003.

Evidence Spikes heading on each `REC`: `None in this repo.` then
the later measure.

## Required risk and open-question ranges

Mint `RSK-###` and `OQ-###` from the shared pools starting at
`001` if none exist yet (none are minted as of this package).
Do not use leftovers’ or score-harness’s future numbers by
guessing — check `decisions/` and existing reports first; they
should still be empty.

Format: Charter §12.

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

- **Three tests restated:** G-001 / G-002 / G-003 × claim × host
  move × later measure × keep/drop × land-in-`arvo/` later
  (yes-candidate / lab-first / no). Must not invent a fourth
  headline.
- **Isolation ladder** for G-002: process / Port / hidden `:peer`
  / Docker — threat each addresses, what it does not, drop rule.
- **Checkout vs function:** each material Arvo-tree claim, with
  classification and limitations.
- **Evidence Ledger** (Charter fields).
- **Recommendation ledger:** ID, title, test, classification,
  confidence, later measure.
- **Source ledger:** URL or path, date accessed, tier.

## Anti-patterns

Inherit [`program/reference/anti-patterns.md`](../../program/reference/anti-patterns.md)
and Charter §18. Especially here:

- Chat-history authority; citing HANDOFF as evidence
- In the tree ⇒ works
- Port-as-native / Elixir-LangGraph / photocopy
- OTP relups as the plugin story
- Sixth headline; raiding Watch
- Coding / Harbor / smoke test
- Treating Arvo as a daily driver
- Opening intake via Exa
- Popularity as proof
- Evidence-free confidence; High on a hypothesis
- Silent recommendation loss (write every `REC` you imply)
- Placeholder completion
- Starting leftovers or score-harness in this session
- Marking the stage accepted

## Completion checklist

- [ ] Report exists at `docs/reports/10-runtime-research-report.md`
- [ ] All report-contract headings present and filled
- [ ] G-001, G-002, G-003 still distinct; no G-006
- [ ] Each `REC` has claim, host primitive, later measure, keep/drop
- [ ] Evidence Ledger classifies tree-description vs function
- [ ] No `SPK-###`; no Arvo command run as a test
- [ ] Exa used (or failure documented in Methodology)
- [ ] Intake not reopened
- [ ] Plain-language summary shown to Robert
- [ ] Human accepts report — **leave unchecked**
- [ ] Manifest updated; accepting commit recorded — **leave unchecked**

## Allowed file scope

**Must write**

- `docs/reports/10-runtime-research-report.md`

**Allowed extras**

- `docs/working/DISCOVERY-NOTES.md` — one pointer line at the top
- `research-program.toml` — `last_updated_date` and
  `runtime.status` to `awaiting-validation` if you finish the
  file. Do **not** set `accepted`.
- `docs/validations/10-runtime-research-validation.md` only if an
  *independent* validator writes it
- `docs/handoffs/runtime-attachment-manifest.md` if you tighten
  the list you actually used

**Do not edit**

- Accepted Blueprint (except a mechanical link fix)
- Accepted Charter
- SORT substance
- leftovers / score-harness outputs
- specs, plans, reviews

## Final response requirements

Plain language to Robert. Do not dump section numbers. Say:

1. The runtime report is filled (path).
2. This repo still only catalogs ideas.
3. You did not run spikes or treat Arvo as proven.
4. You have **not** accepted the report.
5. Next after he accepts: leftovers and score-harness (fresh
   sessions; they may cite this report only if it is already
   accepted). Do not write them now.

## Output behavior

Modify only the allowed paths above. Do not modify governing
artifacts or begin downstream stages.
