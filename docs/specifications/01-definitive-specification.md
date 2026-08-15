# Definitive Specification — arvo-beam-harness-research

- **Artifact type:** Proposed definitive specification
- **Program:** arvo-beam-harness-research
- **Status:** Proposed — pending adversarial review
- **Human acceptance:** Accepted by human 2026-08-15 — awaiting accepting commit
- **Version:** 0.1
- **Created:** 2026-08-15
- **Last updated:** 2026-08-15
- **Implementation status:** Catalog proposed. Not implementation authority. This repository still only catalogs ideas.
- **Accepting commit:** *(empty — awaiting recording commit)*
- **Requirement range used:** `REQ-001`…`REQ-047`
- **Risks minted here:** `RSK-030` (inherited `RSK-001`…`RSK-029` carried forward)
- **Open questions minted here:** none (`OQ-001`…`OQ-018` inherited; `OQ-011` closed)
- **DEC minted:** none
- **Spikes:** none (`SPK-###` unused)
- **Phases / milestones minted:** none (`PHASE` / `MS` belong to a later plan stage)

> This file is the proposed catalog. It is not a coding specification for
> this repository, not a Harbor result, and not proof that anything in
> Arvo works when run. It does not authorize Elixir, Harbor, or PRs into
> `arvo/` **here**. Robert accepted this draft on 2026-08-15. Synthesis
> is not `accepted` in `research-program.toml` until the accepting
> commit is recorded. Adversarial review is the next stage after that.
> This file is not implementation authority.

## 1. Artifact Metadata

| Field | Value |
| ----- | ----- |
| Program ID | arvo-beam-harness-research |
| Artifact | Proposed definitive specification |
| Owner | Robert Guss |
| Repository | [robertguss/arvo-beam-harness-research](https://github.com/robertguss/arvo-beam-harness-research) |
| Local tree | this checkout |
| Instrument | local Arvo checkout at `../coding-agent-harness/arvo` @ `84004e1fcae11bbf72656c58e7fa5ae4aa92838b` (observed 2026-08-15 in the accepted reports). Function unproven. |
| Sister tree | `../coding-agent-harness/ore` — ignore unless the owner says so |
| Lab | a later sibling repository (name TBD). Not this tree. Not `arvo/` as the lab. |
| Rigor | focused (approved with the Blueprint) |
| Replication | off |
| Contract | [`program/contracts/definitive-specification.md`](../../program/contracts/definitive-specification.md); [`program/contracts/synthesis.md`](../../program/contracts/synthesis.md) |
| Requirement shape | [`program/templates/requirement.md`](../../program/templates/requirement.md) |
| Human acceptance | Accepted by human 2026-08-15 — awaiting accepting commit |
| Accepting commit | *(empty — awaiting recording commit)* |

### What this file claims

One catalog: five headline tests, three host primitives, leftover pattern
cards, two scoring methods, and a Watch / Refuse shelf. Requirements
`REQ-001`…`REQ-047` say **what the catalog claims**. They are not tickets
in this repository.

### What this file is not

A product architecture, a module list for `arvo/`, a Harbor run, a
working harness, or authority to write Elixir here.

## 2. Executive Decision Summary

The three accepted reports plus the accepted Charter support **one**
catalog-shaped specification. Synthesis ratifies the report resolutions.
It does not reopen them.

1. **This repository still only catalogs ideas.** A later sibling
   repository runs tests. Success here is a catalog, not a working
   harness (`REQ-001`, `REQ-003`).
2. **Five headline tests stay five.** `G-001`…`G-005`. No sixth. A
   leftover card is not a test. A layer score is not G-006. A proposer
   is not G-004 (`REQ-002`, `REQ-007`).
3. **Host nouns stay as runtime named them.** G-001 is attach to a
   living Session. G-002 is the thinnest isolation ladder that later
   passes. G-003 is `:code.load_binary` plus two-version modules and
   `soft_purge`. Required drops stay dropped: JSONL auto-resume is not
   G-001; a shared cookie is not a fence; a Port wrapping a foreign
   harness is not hands; Mix-in-VM and `append_path`-plus-hope are not
   G-003; OTP relups are not the plugin story.
4. **Leftover cards stay cards.** Eleven hosted cards sit on
   G-001…G-003. They are not headlines. Watch stays Watch. Refuse stays
   refused. Adaptation is the catalog method, not a test.
5. **G-004 is a lab loop on a fixed test set.** Frozen model. Judge
   tree, holdout, leftover-test identity, and `program.md` are
   read-only. One primary declared **before** the run. Writable: named
   harness files. Human owns `program.md`. **Not** “improves while you
   use it.” The loop is not Arvo’s identity. A winning *file* may later
   be copied. The searcher stays in the sibling repo.
6. **G-005 is a specialized helper as its own Session.** Scout ≠ critic
   ≠ planner. Three arms: none / parent-model / smaller-or-local. Local
   may lose. A nested prompt with a pid taped on is a drop. G-004 and
   G-005 stay **split** on purpose.
7. **Watch above and beside scoring stays Watch.** A proposer slot
   exists *above* G-004 (`OQ-011` already answered yes). GEPA / ACE
   stay Watch as possible later bodies of that slot. Layer watches
   (honesty, stub/reuse, isolation, kill-Focus-lives) stay Watch beside
   the one primary. Searcher-meta stays Watch. `program.md` moves on a
   slower clock. None of these is G-006.
8. **Harbor (or equivalent) is later method, not a number this lab
   ran.** Official docs dated 2026-08-15: default verifier is
   **shared**; the later repo should use **separate** mode. Absence of
   `evals/arvo-attention-reread/` at Arvo `84004e1` is a checkout fact,
   not a score.
9. **First later job.** Stand up the sibling repo. Smoke-check that
   Arvo boots and can finish a simple task **there**. Then run
   G-001…G-005 in the order the later plan names. Do not do that check
   here. Do not mint `PHASE` / `MS` here.
10. **Intake stays closed.** Do not dump more papers. Do not re-sort.
    Popularity is not proof. “In the tree” is not “works.” High
    confidence is rare. “Holdout would rise” stays Medium or Low.

This specification is **Proposed — pending adversarial review**.
Robert accepted this draft as the synthesis output on 2026-08-15.
It is not implementation authority. The synthesis stage is not
`accepted` in the index until the accepting commit is recorded.

## 3. Authority and Intended Use

### Authority

Order: [`program/contracts/authority-and-precedence.md`](../../program/contracts/authority-and-precedence.md).

Project-specific reading for this file:

1. Accepted `DEC-###` — none exist.
2. Locked constraints in the accepted Program Blueprint
   ([`docs/00-program-blueprint.md`](../00-program-blueprint.md),
   accepting commit `0b49540cae7d2a30ad4b4b145999e27b82c50dad`),
   especially §5, §6, §7, §11 synthesis row, and §22.
3. Normative rules in the accepted Research Charter
   ([`docs/01-research-charter.md`](../01-research-charter.md),
   accepting commit `081ad36932be7f3f0df062b592cc306c49f72af4`),
   especially §10 spine bar, §14 synthesis rules, and §18.
4. There is **no** current accepted specification. This is the first
   proposed one. A later revised specification, after adversarial
   review, becomes authority for **what the catalog claims**.
5. Accepted reports are **evidence and recommendations**. They do not
   secretly amend Blueprint §7.
   - Runtime
     ([`docs/reports/10-runtime-research-report.md`](../reports/10-runtime-research-report.md),
     `636123f1a628803aa4ae2c44fc4659d167a80693`).
   - Leftovers
     ([`docs/reports/11-leftovers-research-report.md`](../reports/11-leftovers-research-report.md),
     `9698362dbe5f90ff48e7aa1093d547d2e14d410a`).
   - Score-harness
     ([`docs/reports/12-score-harness-research-report.md`](../reports/12-score-harness-research-report.md),
     `c15dd31c44c197340d2b339657eb7f072f066d44`).
6. Framing evidence: Graduate table of
   [`docs/working/SORT.md`](../working/SORT.md); locked top of
   [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md).
   These do not outrank the Blueprint.
7. `research-program.toml` is an index only.
8. Chat history, model memory, root handoff maps, and attachment
   manifests are not authority and are not cited as evidence here.

A later specification may not secretly amend Blueprint §7.

### Intended use

| Reader | Use |
| ------ | --- |
| Robert | Accept, reject, or send back. Commit if accepted. |
| Spec-review (later fresh session) | Attack collapse, sixth test, tree-as-works, Port-as-native, judge-eaten, nested-prompt helper, searcher-as-identity. |
| Later sibling-repo operator | Know what to try and how to keep or drop it. First job is the Arvo smoke check **there**. |
| This repository’s coding agents | Do **not** treat `REQ-###` as tickets here. |

### Methodology (this synthesis)

1. Read the accepted Blueprint and Charter in full, then all three
   accepted reports in full, then the specification contract and
   requirement template. Skimmed SORT Graduate table only (did not
   re-sort) and the locked top of DISCOVERY-NOTES (did not rewrite the
   dump).
2. Dispositioned every material `REC-001`…`REC-011`,
   `REC-100`…`REC-115`, `REC-200`…`REC-210` before finishing the
   `REQ` list.
3. Restated Blueprint / report measure and keep/drop. Did not replace
   the five tests.
4. **Exa.** Official pages already cited in the three reports were
   enough. No load-bearing sentence in those pages was thin enough to
   merit a refresh. **Exa did not run in this synthesis session.**
   This is a documented skip, not a pretend run. No new papers were
   harvested. Intake was not reopened.
5. Did not boot Arvo. Did not run Harbor. Did not write Elixir. Did
   not mint `SPK-###`, `PHASE`, `MS`, `FND`, or `DEC`.

## 4. Problem and Product Definition

There is no product in this repository. There are two problems, and
they stay distinct.[^bp-3]

**Problem A — the runtime gap.** Arvo’s tree does not yet use the
runtime the way José’s bet requires. Closing the window still looks
like it should kill the agent. Tools still sit where the keys are.
Loading a plugin still looks like compiling inside the live app. Until
those three primitives are named as tests, every paper leftover has
nowhere honest to live.

**Problem B — leftover ideas without a host.** The closed intake is
full of policies and loops. Those ideas are guests. They need the
primitives in Problem A, and they need a way to be kept or dropped
later without turning this repo into a coding backlog.

**What “the product” would be later.** A catalog another person can
carry into a sibling experiment repo: five tests, host nouns, cards,
scoring methods, Watch / Refuse. Not a daily-driver harness. Not a
startup. Arvo remains the **instrument** in
`../coding-agent-harness/arvo`, not a user-facing product this program
ships.

José Valim’s official claim (not a measurement): the runtime is the
framework — swap plugins without dropping state; the window is a
client of a living agent; brains and hands sit in different
places.[^jose-1][^jose-2]

## 5. Goals and Non-Goals

### Goals (catalog)

Restated from Blueprint §5. Not replaced.

1. Keep this repo a catalog: named tests, pattern cards, later
   measures, keep/drop rules.
2. Keep intake closed.
3. Name five headline tests `G-001`…`G-005`. Do not add a sixth. Do
   not drop one.
4. Leave most ideas on Watch on purpose.
5. Hand a stranger the agenda so a sibling repo can try the tests
   without inventing them.

### Five-test restatement

Blueprint §5 table, restated. SORT Graduate rows G-001…G-005 and the
three accepted reports sharpen fences. They do not replace this table.

| # | Plain name | SORT | What we would try later | Measure (later repo) | Keep / drop | Copy into `arvo/`? |
| - | ---------- | ---- | ----------------------- | -------------------- | ----------- | ------------------ |
| 1 | Close the window, agent stays | G-001 | Quit the TUI; the agent process is still there; a new window reconnects. Not “reload the chat file after a crash.” | Kill the window / SIGTERM the tile. Session pid lives. JSONL still grows. A new client attaches and continues. Honesty on the continued session, same frozen model, does not get worse. | Keep if attach is not just disk resume. Drop if we only wrapped auto-resume in boot scripts. | Likely yes later |
| 2 | Tools live somewhere else | G-002 | Hands cannot see API keys. Kill hands; chat lives. Same coding task still works. Thinnest setup that passes. | Same task; only the topology changes. Hands cannot read keys. Kill hands mid-tool; Session + JSONL live. No orphan `bash -c`. Hidden BEAM and a container are different threats — score them separately. | Keep the *thinnest* layer that passes isolation + survival + task. Drop a layer that only adds latency. Drop if “hands” is a Port wrapping a foreign harness. | Lab first |
| 3 | Swap a plugin without restarting | G-003 | New plugin code; current turn finishes on old code; next turn sees new tools; no Mix compile inside the live app. | Session mailbox intact. In-flight turn stays on old modules. Next turn sees the new manifest. Name the prefix-cache break. | Keep if Mix leaves the product VM and the swap is real. Drop if this is `Code.append_path` plus hope, or if cache-break cost eats the win. | Likely yes later |
| 4 | Overnight loop on a fixed test | G-004 | Same model. Edit only named harness files. Scorer is off-limits. Keep or undo. Leftover tests must also improve. | `results.tsv`: keep / discard / crash. One primary number per run (task success *or* honesty — pick before the run). Holdout required. Side stats (tokens, time) cannot keep. Tiny gain + ugly complexity = discard. | Keep the *loop* if holdout rises without touching the scorer, without “more tokens / more time” as the win, and without honesty collapse. Drop if it only games three tasks. | **No.** Loop stays in the experiment repo. A winning file may be copied later. |
| 5 | Specialized helpers | G-005 | Own session, not a nested prompt. Scout ≠ critic ≠ planner. Arms: no helper / parent-model helper / smaller-or-local helper. Local is allowed to lose. | Same tasks, three arms. Score task success, parent waste, dollars, wall time. Scout cannot write or see keys. | Keep a specialist if it wins success, waste, or cost without adding a second brain for org-chart reasons. Drop if the child is a nested prompt with a process id taped on. | Lab first |

### Non-goals

This repository will not, and this specification does not authorize:

- Elixir, spikes, evals, Harbor runs, or PRs into Arvo **here**.
- Treating Arvo as a known-good daily tool, or “in the tree” as
  “works.”
- Using `arvo/` as the experiment lab.
- Re-opening intake.
- LangChain-on-BEAM, Elixir-LangGraph, or a photocopy of a paper.
- Wrapping a foreign harness in a Port and calling that native.
- Training or fine-tuning model weights.
- Touching `ore/` unless the owner says so.
- Merging G-004 with “the harness gets better while you use it.”
- Adding a sixth headline or dropping one of the five.
- Treating plan / todo / permission-popup chrome as product identity.
- Putting MCP, Horde, Oban, libcluster, OTP relups, or Phoenix
  LiveView at the center of the architecture.
- A parallel vocabulary (“agent OS,” “control plane”) as architecture.
- A coding backlog in this tree.

## 6. Locked Decisions and Invariants

From accepted Blueprint §7 and accepted Charter §1. Do not re-litigate
here. Amend only through the amendment protocol.

1. Personal lab, not a race and not a pitch.
2. Two programs. This repo writes the catalog. A later sibling repo
   runs tests.
3. No spikes, evals, Harbor runs, smoke tests, or PRs into Arvo
   **here**.
4. Arvo is not a daily driver. “In the tree” ≠ “works.”
5. Local instrument: `../coding-agent-harness/arvo`. Ignore `ore/`
   unless the owner says so.
6. The runtime is the framework: swap plugins without dropping state;
   the window is a client of a living agent; brains and hands sit in
   different places.
7. The gap is Arvo’s thin OTP slice (one Session, tools in-process,
   Mix-compile plugins, quit-window kills the VM, file-search native
   code on the brain).
8. Central insight: TypeScript/Python papers specify OTP, then fake an
   OS. Circle the Erlang noun; keep the *new* leftover.
9. Adaptation, not photocopy, not “refuse every rewrite.” A
   Port-wrapped foreign harness is a shell.
10. Intake is closed.
11. Success bar: a catalog, not a working harness.
12. Rigor is focused. Replication off. `SPK-###` unused here.
13. Five headline tests stay five. Drop none. Invent no sixth.
14. G-004 stays a lab loop on a **fixed** test set.
15. G-005 helpers are specialized (scout / critic / planner). Arms:
    none / parent-model / smaller-or-local. Local may lose.
16. Phase-2’s first job includes an Arvo smoke check — **there**.
17. The G-004 loop does not become Arvo’s identity.

Score-harness already answered questions this specification must **not**
reopen:

- **`OQ-011`:** yes, a proposer slot exists *above* G-004. Leftovers
  `REC-111` stays Watch. Not an online improver. Not G-006.
- **`REC-112` / `REC-209`:** a later judge may *watch* layers. Stay
  Watch. Not G-006. No invented Harbor number.
- G-004 and G-005 stay split. Cousin rejected. Nested prompt
  rejected. Searcher is not Arvo’s identity.
- Harbor official docs (2026-08-15): default verifier is shared;
  later repo should use separate mode.
- Checkout fact, not a score: `evals/arvo-attention-reread/` is
  absent at Arvo `84004e1`.

## 7. Final Technology Stack

**This repository has no technology stack.** It writes Markdown.

The **instrument** the catalog talks about, as already dated in the
accepted reports:

| Piece | What the reports recorded | What that does not mean |
| ----- | ------------------------- | ----------------------- |
| Arvo checkout | `../coding-agent-harness/arvo` @ `84004e1` on 2026-08-15 | The product works |
| Erlang/OTP | Official docs **29.0.5**, opened 2026-08-15 | We ran a cluster |
| Elixir | Official docs **1.20.3**, opened 2026-08-15 | We compiled a release |
| Livebook | Official runtime page **0.19.9** | Arvo is a Livebook runtime (refused) |
| Harbor | Official pages on harborframework.com, opened 2026-08-15 | This lab ran a job or has a number |

The **lab** is a later sibling repository. That repo may choose Harbor
(or an equivalent task + verifier + reward file) as the scoring format,
Elixir/OTP as the language of experiments, and the Arvo checkout as
the instrument. This specification does **not** pick a production
framework, a UI, a database, a cloud, or an “agent OS.”

Do not put Horde, Oban, libcluster, MCP, OTP relups, or Phoenix
LiveView at the center because they are fashionable.

## 8. System Context

```text
[this repo]  catalog only
     |
     |  after human accept + spec-review + later plan spine
     v
[sibling experiment repo]  the lab
     |
     |  first job: smoke-check Arvo boots and finishes a simple task
     v
[Arvo instrument]  ../coding-agent-harness/arvo   (read-only from this program)
     |
     |  later, separate product gate
     v
[optional copy of a winning *file* into arvo/]
     (never copy the G-004 searcher as Arvo’s identity)

ore/  — out of scope unless the owner says so
```

Actors: Robert (owner of this catalog); later experiment operator
(may be the same person); session agents commissioned one stage at a
time. Not actors: “Arvo users,” José Valim as a stakeholder to
satisfy, a market.

## 9. Architecture

The architecture **is** the catalog shape. There is no parallel
vocabulary.

| Layer | What it is | What it is not |
| ----- | ---------- | -------------- |
| Five headline tests | `G-001`…`G-005` | A sixth test, a leftover card, a layer score |
| Three host primitives | G-001 attach; G-002 isolation ladder; G-003 `load_binary` swap | HTTP control plane; Port-wrapped foreign harness; Mix-in-VM; OTP relups |
| Leftover cards | Policy / metric / loop sitting on a host | Headlines |
| Two scoring methods | G-004 fixed-set keep/reset; G-005 own-Session specialist | One merged “improver”; nested-prompt helper |
| Watch shelf | GEPA/ACE above G-004; layer scores beside scoring; searcher-meta; 23 SORT Watch clusters | A backlog; G-006 |
| Refuse shelf | 23 SORT Refuse clusters plus the required host drops | Research centers |

José’s three official claims remain G-001, G-002, and G-003. They are
not leftovers. G-004 is how the later repo stays a lab. G-005 is the
specialist leftover that survives as its own test.

## 10. Components and Boundaries

Components here are **tests and fences**, not Elixir modules.

| Component | Boundary | Inside | Outside |
| --------- | -------- | ------ | ------- |
| G-001 Session | Process that must outlive the tile | Permanent (or always-on named) Session, JSONL, attach via `:pg` / Registry | Focus / tile (temporary); `os_signal` on the tile; JSONL auto-resume after VM death |
| G-002 hands | Location of tools | Thinnest rung that later passes keys + kill + task; NIF and bash | Brain keys, cookie, Session pid; Port around a foreign harness; shared cookie as “auth” |
| G-003 plugin swap | Code server, not Mix, not SASL | `.beam` via `load_binary`; two versions; `soft_purge` after the turn; profile set-diff | Mix in the product VM; `Code.append_path` plus hope; `relup` / `release_handler`; `on_load` on the brain |
| G-004 loop | Sibling-repo searcher | Named writable files; `git` keep/reset; child Session per trial | Judge tree; holdout; `program.md`; leftover-test identity; live user sessions; `arvo/` as home of the loop |
| G-005 child | Own Session (or hands node) | Child constitution + tools + model id; three arms | Parent transcript import; child `start_turn` on parent; nested persona; org-chart second brain |
| Cards | Guests on a host | Insight + BEAM noun + later measure | A sixth Graduate row |
| Watch / Refuse | Shelves | Reading allowed | Promotion without amendment; Refuse as architecture |

## 11. Data Model

Catalog nouns already named. Not a schema this repo ships.

| Noun | Role | Who may write it (later lab) |
| ---- | ---- | ---------------------------- |
| Session JSONL | Immortal conversation log; crash boundary | Append-only during a living Session. Organism must not rewrite history. |
| Session pid / mailbox | The living brain G-001 attaches to | Runtime. Not reconstructed from disk and scored as attach. |
| `results.tsv` | G-004 trial log: keep / discard / crash + primary + side stats | The sibling-repo loop. |
| Run tag | Frozen model id, primary name, holdout id, writable-file allowlist, declared before trial 1 | Human / lab, before the run. |
| `program.md` | Searcher meta | **Human.** Slower clock than the organism and than the optional proposer. |
| Named harness files | Constitution, compact-strategy module, tool list, observe-only hooks | G-004 organism, then keep or `git` reset. |
| Harbor `tests/` + reward file | Later judge format | **Read-only** to the organism. Separate verifier mode. |
| Harbor `reward.txt` / `reward.json` | Later primary *or* watches | Method page, not a number this lab has. |
| Audit JSONL / named columns (`task_ok`, `honesty`, `waste_ratio`, `stub_reuse`) | Checkout text in Arvo at `84004e1` | Not a scoreboard this lab ran. Phase-2 may rebuild honesty from audit JSONL. |
| `evals/arvo-attention-reread/` | **Absent** at `84004e1` | Checkout fact. Not a result. |
| Git | Mutation and reset for G-004; history of this catalog | Sibling repo for experiments; this repo for documents. |

## 12. Interfaces and Integrations

This repository ships no APIs.

Later method, inherited as official claim about Harbor docs dated
2026-08-15, not as a run:[^harbor-tasks][^harbor-regrade][^harbor-docs]

- A Harbor task is `instruction.md` + `task.toml` + `environment/` +
  `tests/` (must write `reward.txt` or `reward.json`).
- Default verifier mode is **shared** (same container as the agent).
  That is a known hole (`RSK-020`).
- The later repo should use **separate** mode (or an equivalent OS
  fence the agent cannot write).
- Regrade may fix a grader *after* a run. Mid-search grader edit is
  eating the judge.
- Harbor lists GEPA as an *optimizer* integration. That is the Watch
  slot above the judge, not G-004.

G-002 protocol leftover (card, not an API this repo ships):
`Hands.API` messages `read` / `write` / `bash` / `glob` / `grep`. No
`eval`, no code load, no open `:erpc` back to the brain.

Official RLM Python env may later be Ported **on hands**. That Port is
a tool. A Port around Claude Code or another foreign *harness* is a
shell.

José named OpenCode-like attach as a *need*. The host noun is another
mailbox, not an HTTP clone as primary.

## 13. User Workflows

### Operator of this catalog (Robert)

1. Read this proposed specification.
2. Accept, send back, or amend locks (amendment protocol).
3. Commit if accepted. Agents do not mark `synthesis` accepted.
4. Later: spec-review in a **fresh** session. Not this session.

### Operator of the later sibling repo

1. Stand up the sibling repository.
2. Smoke-check that Arvo boots and can finish a simple task
   **there**. That check is not a stage in this program.
3. Run G-001…G-005 in the order the later plan names, with the
   fences in this catalog.
4. Record `results.tsv` / run tags. Keep or drop by the rules here.
5. Optionally copy a *winning file* into `arvo/` as a separate
   product gate. Do not copy the searcher.

There is no product UX program. Window-as-client is G-001, not a user
study.

## 14. Security and Privacy

Not a compliance program. The fence this catalog cares about is
**G-002**.

| Rule | Why |
| ---- | --- |
| Hands cannot read keys, cookie, or Session state | Location is the fence, not an allowlist |
| Kill hands; Session + JSONL live | Survival |
| Shared magic cookie (including `"arvo_headless"`) is not isolation or auth | OTP cookies are pairing, not crypto-strong; matching cookie plus `:erpc` is remote `apply` |
| Hands never holds the Session pid | Too-big-pid leftover |
| `:erpc` if used is read-only and allowlisted, or replaced by a protocol we own | Open `:erpc` is eval |
| Scout cannot write or see keys | G-005 isolation |
| NIF and bash live on hands | Native crash domain must not take the brain |
| No `eval` on the Session VM | Includes “just IEx for RLM” |
| Do not start distributed nodes without OTP’s TLS warning on the record | Not an ops program; do not pretend a cookie is TLS |

Personal lab. No regulated-data program. No user PII store in this
repo.

## 15. Reliability and Operations

Not an ops program. The reliability claim this catalog names is
**G-001**.

| Claim | Later measure | Drop |
| ----- | ------------- | ---- |
| Quit the window; Session lives | SIGTERM the tile; Session pid still there; JSONL still appends | VM died and JSONL was reloaded |
| New client attaches | Second Focus / `arvo-chat` / IEx joins via `:pg` or Registry | Boot script that only auto-resumes |
| Signal kills the tile, not the VM | `os_signal` on the tile executable does not `init:stop` the brain | `:halt_on_focus_quit` still stops the VM |

Host recipe (not a ticket here): Session `permanent` (or equivalent
always-on named process); Focus / attach `temporary`; stop
`:halt_on_focus_quit`; boot a daemon / release / `run_erl` so the
product is not `mix run --no-halt`; Session does not import a TUI
module.

A living Session without a tile must be findable and killable on
purpose. That is later lab work.

## 16. Testing and Verification

The tests **are** G-004 and G-005, plus leftover measures on
G-001…G-003. This repository does not run them.

### G-004 method (fixed-set lab loop)

- Frozen model id on the run tag.
- Child Session (or child node) per trial.
- Mutation via `git` and optional `:code.load_binary` (Mix out; no
  `on_load` on the brain).
- Writable: constitution, compact-strategy module, tool list,
  observe-only hooks.
- Read-only: Harbor `tests/`, `task.toml` `[verifier]`, holdout,
  leftover-test identity, `program.md`.
- Prefer Harbor `verifier.environment_mode = "separate"` (or
  equivalent). Shared mode is not an honest judge.
- `results.tsv`: keep / discard / crash.
- One primary declared **before** trial 1: Harbor task success *or*
  attention honesty. Side stats cannot keep.
- Holdout required. Tiny gain + ugly complexity = discard.
- Leftover G-001…G-003 measures must not collapse.
- **Not** “improves while you use it.”
- Loop stays in the sibling repo.

### G-005 method (own-Session specialist)

- Specialization = child constitution + tool set + model id.
- Parent does not import the child transcript. Child cannot
  `start_turn` on the parent.
- Scout cannot write or see keys.
- Same tasks, **three arms**: none / parent-model / smaller-or-local.
- Local / smaller is allowed to lose.
- Score task success, parent waste, dollars, wall time. Declare which
  of the four is keep-deciding **before** the run.
- One specialist family per run tag (scout *or* critic *or* planner).
- Split sequential vs parallelizable tasks.
- A nested prompt with a pid taped on is a drop.

### What verification is *not*

A command run in this repository. A Harbor number invented from a
paper. A citation of missing `evals/arvo-attention-reread/` as if it
scored a keep. A composite picked after seeing the spreadsheet.

### First later measurement sequence (high level; no `PHASE` / `MS`)

1. Sibling repo exists.
2. **Arvo smoke check there:** boots and can finish a simple task.
3. Then G-001…G-005 in the order the later implementation plan names.
   Inherited guidance, not a phase id: runtime expected G-001 after
   smoke; G-002 starts at the thinnest rung; G-003 after the host is
   named; G-004 only after smoke; G-005 may start with scout (narrowest
   tool set).
4. Optional Watch items (proposer, layers, worktree, many-hands,
   replay) only after the host they sit on has a named measure.
5. Copy of a winning *file* into `arvo/` is a later product gate, not
   step 1.

## 17. CI and Release

**Not applicable in this repository.** There is no application to
build, no release artifact, and no CI that scores a harness.

The sibling repo may later grow CI around Harbor jobs and judge-tree
diffs. That is not specified here and must not be smuggled into this
tree.

## 18. Migration (if applicable)

There are no users or APIs to migrate.

The only “migration” this catalog names is a **later product gate**:
copy a winning constitution, module, or topology *file* into `arvo/`.
Do not migrate the G-004 loop into `arvo/` as the product. Do not
treat a Mix release tarball described in `rel/RELEASE.md` as proof
that Harbor packaging is isolation.

## 19. Performance Expectations

No SLOs. Named later measures only:

| Measure | Host | Rule |
| ------- | ---- | ---- |
| Prefix-cache break after plugin load or compact | G-003 (also named on compact) | Time it. Side latency cannot keep a swap (`OQ-005`). |
| Isolation / hop latency on thicker G-002 rungs | G-002 | Drop a layer that only adds latency. |
| Hidden node vs Docker `exec` wall time | G-002 optional | Score separately; latency cannot keep Docker. |
| Worktree extra cost | optional card | Keep only if it passes a dirty-tree threat the VM fence failed. |
| G-005 dollars and wall time | G-005 | Side stats unless declared keep-deciding before the run. |
| G-004 tokens / time | G-004 | Cannot keep. |

Hypotheses that holdout would rise, or that a specialist would win,
stay **Medium or Low** until the sibling repo measures them.

## 20. Internal Contracts

These invariants bind every later reading of this catalog.

| Invariant | Binding |
| --------- | ------- |
| Five tests stay five | `REQ-002` |
| This repo does not run the tests | `REQ-003` |
| Cards are not tests | `REQ-007`, `REQ-022`…`REQ-032` |
| Watch stays Watch; Refuse stays refused | `REQ-043`…`REQ-047` |
| G-001 ≠ JSONL auto-resume | `REQ-013` |
| G-002 ≠ shared cookie, ≠ Port-wrap of a foreign harness | `REQ-015`, `REQ-016` |
| G-003 ≠ Mix-in-VM, ≠ relups | `REQ-020`, `REQ-021` |
| G-004 ≠ “improves while you use it”; loop ≠ Arvo identity | `REQ-038`, `REQ-037`, `REQ-039` |
| Judge / holdout / `program.md` read-only; one primary before the run | `REQ-035`, `REQ-036` |
| G-005 ≠ nested prompt; three arms; local may lose | `REQ-040`, `REQ-041`, `REQ-042` |
| G-004 and G-005 stay split | `REQ-002`, `REQ-034`, `REQ-040` |
| Adaptation, not photocopy | `REQ-005`, `REQ-033` |
| Checkout ≠ function | `REQ-006` |
| No invented Harbor number | `REQ-009`, `REQ-044` |

## 21. Dependency Bill of Materials

Dated sources already cited. Do not add fashion.

| Dependency | Version / date | Role | Cite as |
| ---------- | -------------- | ---- | ------- |
| Program Blueprint | accepted `0b49540`, 2026-08-14 | Lock | lock |
| Research Charter | accepted `081ad36`, 2026-08-15 | Rules | lock |
| Runtime report | accepted `636123f`, 2026-08-15 | Host nouns | accepted report |
| Leftovers report | accepted `9698362`, 2026-08-15 | Cards / Watch / Refuse | accepted report |
| Score-harness report | accepted `c15dd31`, 2026-08-15 | G-004 / G-005 methods | accepted report |
| SORT Graduate table | 2026-08-14 | Framing | framing |
| DISCOVERY-NOTES locked top | 2026-08-14 | Framing | framing |
| José tweets | 2026-08-14; accessed 2026-08-15 | Official claim | tier 1 claim |
| OTP docs | 29.0.5; accessed 2026-08-15 | Official VM nouns | tier 1 |
| Elixir `Code` | 1.20.3; accessed 2026-08-15 | `append_path` is not swap | tier 1 |
| Livebook runtimes | 0.19.9 | Cousin architecture, not a UI | tier 1 claim |
| Harbor official docs | pages as of 2026-08-15 | Later method | tier 1 method |
| GEPA / ACE / RLM / Voyager / parallel-compact abstracts | versions dated in leftovers / score-harness | Insight leftovers | tier 2 |
| Official RLM README | accessed 2026-08-15 | *Their* host, not ours | tier 1 claim |
| Arvo checkout | `84004e1`, 2026-08-15 | Instrument text | checkout; function unproven |

No new library, vendor box, or paper is added by this specification.

## 22. Normative Requirements

Use `REQ-001`…`REQ-299` only. Intake IDs `G-` / `H-` / `P-` / `V-` /
`XB-` / `LC-` are citations, not requirement numbers.

Implementation phase is `catalog only` or `later sibling repo`. This
stage mints no `PHASE-##`.

Verification named below is a later measure or an inspection of the
catalog, not a command run here.

### Catalog invariants

### REQ-001 — Two programs; this repo catalogs only

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** Blueprint §7.2; Charter §1; `REC-113`
- **Verification:** Inspection: this tree contains no experiment code, no Harbor job, no PR into `arvo/`.
- **Risk linkage:** `RSK-024`, `RSK-030`

#### Requirement

This repository MUST catalog ideas only. A later sibling repository
MUST be the lab that runs tests. `REQ-###` in this file MUST be read
as catalog claims, not as tickets in this tree.

#### Rationale

Locked two-program split. Synthesis that writes Elixir here has
failed.

#### Acceptance Evidence

Working tree of this repo has no experiment harness. Sibling repo is
named only as “later,” not stood up here.

#### Exceptions

None.

### REQ-002 — Five headline tests stay five

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** Blueprint §5, §7.13; `REC-001`, `REC-004`, `REC-009`, `REC-200`, `REC-203`
- **Verification:** Inspection: the catalog still names exactly `G-001`…`G-005`.
- **Risk linkage:** `RSK-010`, `RSK-022`

#### Requirement

The catalog MUST name exactly five headline tests: `G-001`, `G-002`,
`G-003`, `G-004`, `G-005`. It MUST NOT invent G-006. It MUST NOT drop
one of the five. It MUST keep G-004 and G-005 split. A leftover card,
layer score, proposer slot, or Watch cluster MUST NOT be promoted to
a headline.

#### Rationale

User decision. Merging leftovers into a new headline is inventing
G-006.

#### Acceptance Evidence

This file’s five-test table. No `G-006` identifier.

#### Exceptions

None without the amendment protocol.

### REQ-003 — This repository MUST NOT run the experiments

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** Blueprint §6, §7.3; Charter §3
- **Verification:** Inspection of this tree and of later session logs.
- **Risk linkage:** `RSK-024`

#### Requirement

This repository MUST NOT write Elixir for the tests, mint `SPK-###`,
run Harbor, boot or smoke-test Arvo, or open PRs into `arvo/`. Those
acts belong to the sibling repo.

#### Rationale

Focused catalog. “Implementation may begin” means the sibling repo
may be stood up, starting with the Arvo smoke check **there**.

#### Acceptance Evidence

No `docs/evidence/` spike reports. No Harbor job directory in this
tree.

#### Exceptions

Read-only inspection of Arvo only to check a fact already claimed,
with path + date + commit recorded. Not a smoke test.

### REQ-004 — Intake is closed

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** Blueprint §7.10; `REC-114`
- **Verification:** Inspection: no new arXiv harvest, bookmark dump, or re-sort.
- **Risk linkage:** `RSK-013`

#### Requirement

Intake MUST stay closed. Later stages MUST NOT dump more papers,
bookmark JSON, unread Articles, or vault traces, and MUST NOT
re-sort [`docs/working/SORT.md`](../working/SORT.md).

#### Rationale

The dump is enough. More intake is theater.

#### Acceptance Evidence

This specification cites already-sorted cards and already-cited
official pages only.

#### Exceptions

A human amendment of intake.

### REQ-005 — Adaptation, not photocopy; Port-wrap of a foreign harness is a shell

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** Blueprint §7.8–9; `REC-006`, `REC-113`, `REC-115`
- **Verification:** Inspection of later designs for photocopy / Port-as-native.
- **Risk linkage:** `RSK-003`, `RSK-012`

#### Requirement

Adaptation MUST circle Erlang nouns and keep the new leftover
(policy, metric, loop). A later design MUST NOT photocopy a paper
scaffold (Elixir-LangGraph). A Port wrapping a foreign coding-agent
CLI MUST be recorded as a shell, not as G-002 hands. A Port of an
official tool environment (bash, official RLM env) on hands is not
that shell.

#### Rationale

José’s gift is the runtime, not vendoring someone else’s harness.

#### Acceptance Evidence

`REQ-016`, `REQ-025`, `REQ-033`, `REQ-047`.

#### Exceptions

None.

### REQ-006 — Checkout description is not function

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** Charter §2, §8; runtime checkout-vs-function table
- **Verification:** Inspection: no REQ treats an Arvo path as a passing product.
- **Risk linkage:** `RSK-001`, `RSK-029`

#### Requirement

A dated line in `arvo/` MUST be classified as instrument text. It
MUST NOT be scored as “works when run.” Absence of
`evals/arvo-attention-reread/` at `84004e1` MUST be treated as a
checkout fact, not as a Harbor number.

#### Rationale

Robert does not use Arvo and is not sure the tree works.

#### Acceptance Evidence

This file’s BOM and §11 note on the missing `evals/` path.

#### Exceptions

None.

### REQ-007 — Cards are not tests; shelves stay shelves

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** `REC-113`, `REC-114`, `REC-115`
- **Verification:** Inspection of §9–§10 and leftover `REQ`s.
- **Risk linkage:** `RSK-010`, `RSK-011`

#### Requirement

A pattern card MUST be leftover insight + BEAM noun + host + why it
is not a sixth headline. Watch clusters MUST stay Watch until a
human promotes one. Refuse clusters MUST stay refused as
architecture.

#### Rationale

Most intake remaining on Watch is success.

#### Acceptance Evidence

Eleven hosted cards, two Translate items on Watch, one catalog
method, 23 Watch, 23 Refuse — as leftovers counted.

#### Exceptions

Human amendment of a single Watch or Refuse row.

### REQ-008 — First later job includes an Arvo smoke check there

- **Priority:** Must
- **Applies to:** later sibling-repo standup
- **Implementation phase:** later sibling repo
- **Source decisions:** Blueprint §7.14, §22
- **Verification:** Later sibling-repo log of a smoke check. Not run here.
- **Risk linkage:** `RSK-001`, `RSK-024`

#### Requirement

When the sibling experiment repo is stood up, its first job MUST
include a smoke check that Arvo boots and can finish a simple task
**there**. That check MUST NOT be performed as a stage of this
research program. “Arvo boots a TUI” MUST NOT be scored as G-001.

#### Rationale

The instrument may not even start. Measure that before scoring
attach, isolation, or a loop.

#### Acceptance Evidence

Named here; executed later.

#### Exceptions

None.

### REQ-009 — High confidence is rare; popularity is not proof

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** Charter §11; evidence model
- **Verification:** Inspection of confidence language in this file and later artifacts.
- **Risk linkage:** `RSK-014`, `RSK-027`

#### Requirement

High confidence MUST be reserved for user decisions and dated
primary reads of a document or source line. Claims that a leftover
works on BEAM, that holdout would rise, or that a specialist would
win MUST stay Medium or Low until the sibling repo measures them.
Popularity, star counts, and method-paper numbers MUST NOT keep a
design. This catalog MUST NOT invent a Harbor number.

#### Rationale

Evidence before confidence.

#### Acceptance Evidence

No High-confidence “would work” sentence in §22.

#### Exceptions

None.

### REQ-010 — This stage mints no `PHASE`, `MS`, `SPK`, `DEC`, or `FND`

- **Priority:** Must
- **Applies to:** catalog invariant
- **Implementation phase:** catalog only
- **Source decisions:** Blueprint §15; Charter §7, §14
- **Verification:** Inspection of identifiers in this file.
- **Risk linkage:** `RSK-030`

#### Requirement

Synthesis MUST NOT mint `PHASE-##`, `MS-###`, `SPK-###`, `DEC-###`,
or `FND-###`. First implementation strategy MUST be stated as
sibling-repo measurements, not as a ticket pile.

#### Rationale

Phases belong to the later plan stage. Spikes belong to phase-2’s
own ledger.

#### Acceptance Evidence

Identifier ranges in §1.

#### Exceptions

None.

### G-001 host

### REQ-011 — G-001 is attach to a living Session

- **Priority:** Must
- **Applies to:** sibling-repo test G-001
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-001`
- **Verification:** Later measure: kill Focus / SIGTERM the tile; Session pid lives; JSONL still appends; a new client attaches and continues; honesty on the continued session, frozen model, does not get worse.
- **Risk linkage:** `RSK-005`

#### Requirement

G-001 MUST remain its own headline: quit the window, the Session
process and JSONL stay, a new client attaches and continues the
same tree. G-001 MUST NOT be merged with G-002, G-003, or disk
resume.

#### Rationale

José’s “window is a client of a living agent.” OTP already has
permanent/temporary children and attachable mailboxes.

#### Acceptance Evidence

Five-test table row 1; runtime `REC-001`.

#### Exceptions

None.

### REQ-012 — G-001 host recipe

- **Priority:** Should
- **Applies to:** sibling-repo G-001 implementation *there*
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-002`
- **Verification:** Later: after quit, Session remains registered; a new attach process joins `:pg` / Registry; SIGTERM on the tile does not stop the brain.
- **Risk linkage:** `RSK-005`

#### Requirement

When the sibling repo builds G-001, it SHOULD use: Session
`permanent` (or equivalent always-on named process); Focus / attach
`temporary`; `:halt_on_focus_quit` stopped; boot a daemon / release
/ `run_erl` so the VM is not `mix run --no-halt`; clients join via
`:pg` or Registry; Session does not import a TUI module; `os_signal`
kills the tile, not the VM. Phoenix LiveView MUST NOT be the
default UI. Human IEx on the brain SHOULD remain a dev-only client.

#### Rationale

Unlinked Focus is necessary, not sufficient, if quit still halts
the VM.

#### Acceptance Evidence

Runtime `REC-002`. Keep this recipe if `REQ-011`’s measure passes
with it.

#### Exceptions

A different boot is allowed if attach is still a process fact, not
a file fact.

### REQ-013 — MUST NOT score JSONL auto-resume as G-001

- **Priority:** Must
- **Applies to:** catalog honesty for G-001
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-003`
- **Verification:** If the Session pid is gone and a new VM reloads JSONL, record **drop** for G-001 even if the chat looks continuous.
- **Risk linkage:** `RSK-005`

#### Requirement

The later repo MUST NOT score “we re-read the JSONL on next
`bin/arvo`” as G-001. Same-cwd auto-resume after a VM death MAY
remain as crash recovery beside G-001. It MUST NOT be a G-001 keep.

#### Rationale

G-001 is attach to a process that never died. Arvo already
auto-resumes on interactive boot; that can fool a careless scorer.

#### Acceptance Evidence

Drop rule in the five-test table.

#### Exceptions

None.

### G-002 host

### REQ-014 — G-002 is the thinnest isolation ladder that later passes

- **Priority:** Must
- **Applies to:** sibling-repo test G-002
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-004`
- **Verification:** Later: same task; only topology changes; negative key test; kill hands mid-tool; no orphan `bash -c`; report which rung first passed keys + survival + task.
- **Risk linkage:** `RSK-002`

#### Requirement

G-002 MUST be treated as an isolation **ladder**: process → Port →
hidden `:peer` → Docker. The sibling repo MUST keep the thinnest
rung that later passes (a) hands cannot read keys / cookie / Session
state, (b) kill hands mid-tool leaves Session + JSONL, (c) the same
task still works. Hidden BEAM and container MUST be scored as
different threats. A thicker rung that only adds latency MUST be
dropped. Phase-2 MUST start at process isolation, not at Docker
because papers do.

#### Rationale

Location, not allowlist, is the fence. José named Docker as an
example location, not a starting requirement.

#### Acceptance Evidence

Runtime `REC-004`; five-test table row 2.

#### Exceptions

None.

### REQ-015 — MUST NOT treat a shared cookie as a fence

- **Priority:** Must
- **Applies to:** any later G-002 node design
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-005`
- **Verification:** Later: from hands, attempt `:erpc` / env read of keys. Success → drop that pairing.
- **Risk linkage:** `RSK-006`, `RSK-009`

#### Requirement

A shared magic cookie, including release cookie `"arvo_headless"`,
MUST NOT be treated as isolation or auth. A per-session cookie MAY
be a pairing capability only with a narrow API and no Session pid
on hands; it is still not TLS and still not authn. `"arvo_headless"`
SHOULD be deleted or randomized before any node story.

#### Rationale

OTP: cookies are not cryptographically strong; traffic is cleartext
by default; a matching cookie plus `:erpc` is remote `apply`.

#### Acceptance Evidence

Runtime `REC-005`.

#### Exceptions

None.

### REQ-016 — MUST NOT Port-wrap a foreign harness as G-002 hands

- **Priority:** Must
- **Applies to:** G-002 “what counts as hands”
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-006`
- **Verification:** If the “hands” process’s argv is a foreign coding-agent CLI, record **drop**.
- **Risk linkage:** `RSK-003`

#### Requirement

A Port around Claude Code, another TypeScript CLI, or
`jido_harness` MUST NOT be catalogued or scored as BEAM-native
hands. A Port MAY still carry bash or an official Python RLM
environment on hands without becoming the harness.

#### Rationale

Adaptation uses OTP locations. Wrapping someone else’s harness does
not spend them.

#### Acceptance Evidence

Runtime `REC-006`; leftovers `REC-103` distinction.

#### Exceptions

None.

### REQ-017 — Docker node is an optional thicker G-002 rung

- **Priority:** May
- **Applies to:** sibling-repo G-002 arm, only after a hidden node is scored
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-007`
- **Verification:** Later: same task on hidden `:peer` vs `:peer` whose `exec` is `docker run`. Side latency cannot keep.
- **Risk linkage:** `RSK-002`

#### Requirement

A Docker-hosted node MAY be tried as a **separate** threat (bash
jail / filesystem) after or beside a hidden `:peer` measure. It MUST
NOT be the default keep and MUST NOT be day-one architecture. Keep
Docker only if it passes a threat the hidden node failed.

#### Rationale

Hidden BEAM ≠ Linux namespace. Vendor boxes stay Watch until this
arm needs a named box.

#### Acceptance Evidence

Runtime `REC-007`.

#### Exceptions

None.

### REQ-018 — Native code and bash live on hands, never on the brain

- **Priority:** Should
- **Applies to:** G-002 placement of FFF / NIFs / bash
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-008`
- **Verification:** Later: crash or unload the NIF / kill bash on hands; Session pid + JSONL live; hands still cannot read keys.
- **Risk linkage:** `RSK-028`

#### Requirement

File-search NIF and bash MUST live on the hands location G-002
keeps, not on the Session VM. A later design MUST NOT “isolate”
tools while leaving FFF loaded in `:arvo` on the brain. Plugin
`on_load` MUST be rejected on the brain. Port drivers MUST NOT be
used as a brain-side isolation trick.

#### Rationale

A dirty-scheduler or NIF crash must not take Session with it. The
flagship plugin in the Arvo tree is a NIF on the brain — worst
placement.

#### Acceptance Evidence

Runtime `REC-008`.

#### Exceptions

None that leave the NIF on the brain.

### G-003 host

### REQ-019 — G-003 is load_binary + two versions + soft_purge; Mix out

- **Priority:** Must
- **Applies to:** sibling-repo test G-003
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-009`
- **Verification:** Later: mailbox intact; in-flight turn stays on old modules; next turn sees the new manifest; prefix-cache break named and timed.
- **Risk linkage:** `RSK-007`, `RSK-008`

#### Requirement

A real plugin swap MUST load `.beam` with `:code.load_binary/3` (or
`prepare_loading` / `finish_loading` if several modules must flip
together), keep two versions so the in-flight turn stays on old
code, then `soft_purge` after the turn. Mix MUST NOT run in the
product VM. Profile switch MUST still set-diff the supervision
tree. Load `.beam` only. Reject `on_load`. No new atoms from user
strings. Do not swap mid-turn. Do not load a third copy until
`soft_purge` after the turn.

#### Rationale

That is what the code server already is.

#### Acceptance Evidence

Runtime `REC-009`; five-test table row 3.

#### Exceptions

Compile off the product VM, then `load_binary` on the brain, is
still G-003 if the measure passes.

### REQ-020 — MUST NOT keep Mix-in-VM or append_path-plus-hope as G-003

- **Priority:** Must
- **Applies to:** G-003 keep/drop
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-010`
- **Verification:** If the swap command shells Mix on the brain, or only appends ebin and `ensure_loaded`, record **drop**.
- **Risk linkage:** `RSK-008`

#### Requirement

A design whose live path is `mix compile` inside the product VM, or
`Code.append_path` without two-version + purge discipline, MUST be
recorded as a G-003 **drop**. Tests that skip compile when ebin
already exists MUST NOT be scored as a product keep.

#### Rationale

`Code.append_path` only adds a directory to the code path. Arvo’s
loader is that mutation plus Mix.

#### Acceptance Evidence

Runtime `REC-010`.

#### Exceptions

None.

### REQ-021 — MUST NOT implement G-003 with OTP relups

- **Priority:** Must
- **Applies to:** G-003 mechanism
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-011`
- **Verification:** If the design requires SASL `release_handler` or `restart_new_emulator` to change a plugin, record **drop**.
- **Risk linkage:** `RSK-004`

#### Requirement

G-003 MUST NOT be implemented with `.appup` / `relup` /
`release_handler:install_release/1`. Relups MAY remain a Watch/study
item for unrelated release engineering. They MUST NOT sit at the
center of this architecture.

#### Rationale

Release handling upgrades an entire OTP release. Plugin swap is
two-version modules on one Session.

#### Acceptance Evidence

Runtime `REC-011`; Blueprint §6.

#### Exceptions

None.

### Hosted leftover cards

Cards below are **not tests**. Later measures score the leftover on
its host. They do not mint G-006.

### REQ-022 — Surfaces are clients of a living Session

- **Priority:** Should
- **Applies to:** catalog card on G-001
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-100`
- **Verification:** Same as `REQ-011`; Session does not import a TUI module.
- **Risk linkage:** `RSK-005`

#### Requirement

The catalog MUST keep “one loop, many projectors” as a card on
G-001: Session broadcasts; clients join via `:pg` or Registry;
Session MUST NOT import a TUI module. HTTP à la OpenCode is the
need José named, not the host. An HTTP clone MUST NOT be the
primary architecture.

#### Rationale

The leftover is projector policy, not a new primitive.

#### Acceptance Evidence

Leftovers `REC-100`.

#### Exceptions

None.

### REQ-023 — Attention as topology, not only a prompt policy

- **Priority:** Should
- **Applies to:** catalog card on G-001
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-101`
- **Verification:** Later: same frozen model; layout vs prompt-only; leftover honesty slice; JSONL still exists; “more tokens” cannot keep.
- **Risk linkage:** `RSK-017`

#### Requirement

Hot / warm / cold MUST be kept as a *layout* card on G-001
(budgeted messages, ETS or `:disk_log` index). Mailbox length and
reductions MAY be context-pressure signals. GenericAgent density
(`P-029`) MUST stay Watch until it has an operational JSONL
definition (`OQ-007`). Vector DB / cross-project memory MUST stay
refused as a research center.

#### Rationale

Paging lives on the same Session G-001 already requires. A memory
product would be G-006.

#### Acceptance Evidence

Leftovers `REC-101`.

#### Exceptions

None.

### REQ-024 — Overflow menu: handoff first, workers optional

- **Priority:** Should
- **Applies to:** catalog card on G-001
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-102`
- **Verification:** Later: handoff vs in-place summary vs handoff + parallel compact workers; JSONL intact; honesty; wall time cannot keep.
- **Risk linkage:** `RSK-017`

#### Requirement

Overflow MUST stay a policy card on the living Session. Compaction
MUST change what the model sees, never what exists. Handoff SHOULD
be the honest overflow. Silent in-place rewrite of user-visible
history MUST be dropped. Parallel compact MAY be tried as a worker
layout; it MUST NOT become a religion or a sixth test. ACE’s
collapse warning MAY be cited here; the ACE *loop* MUST stay Watch
(`REQ-043`).

#### Rationale

The leftover is *when and how* the window shrinks.

#### Acceptance Evidence

Leftovers `REC-102`.

#### Exceptions

None.

### REQ-025 — RLM / CodeAct sit on hands, never on Session

- **Priority:** Should
- **Applies to:** catalog card on G-002
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-103`
- **Verification:** Later: official Python RLM env Ported on hands; negative key test; kill Port/node mid-query; no Session `eval`.
- **Risk linkage:** `RSK-016`

#### Requirement

RLM / CodeAct MUST be catalogued as a G-002 tool shape. Default
later try: Port the official Python environment on **hands**. Never
`eval` on the Session VM. Recurse via a broker so the sandbox never
sees API keys. IEx-as-RLM MAY be considered only if the heap is
already BEAM-shaped (`OQ-008`). A Port of the official RLM env is
not a foreign-harness shell (`REQ-016`).

#### Rationale

Long prompt as data is the leftover. Their default host `exec` is
*their* host, not ours.

#### Acceptance Evidence

Leftovers `REC-103`.

#### Exceptions

None that eval on Session.

### REQ-026 — Worktree is an optional filesystem fence next to G-002

- **Priority:** May
- **Applies to:** catalog card beside G-002
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-104`
- **Verification:** Later: hidden `:peer` vs hidden `:peer` + worktree. Side latency cannot keep.
- **Risk linkage:** `RSK-002`

#### Requirement

“Don’t share a dirty tree” MAY be tried as an extra fence beside
G-002. It MUST NOT replace the isolation ladder. Keep only if it
passes a dirty-tree threat the VM fence failed. Vendor boxes MUST
stay Watch.

#### Rationale

Two layers, one leftover. Not a new José sentence.

#### Acceptance Evidence

Leftovers `REC-104`.

#### Exceptions

None.

### REQ-027 — ACI is the Hands message language

- **Priority:** Should
- **Applies to:** catalog card on G-002
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-105`
- **Verification:** Later: same task on `{read,write,bash,glob,grep}` vs unrestricted bash.
- **Risk linkage:** `RSK-012`

#### Requirement

The catalog MUST keep a small `Hands.API` as the leftover: messages
`read` / `write` / `bash` / `glob` / `grep`, not a prompt template
and not “give bash and pray.” apply_patch / udiff MUST stay Watch.

#### Rationale

The repo interface matters as much as the model. That sentence does
not fall out of OTP by itself.

#### Acceptance Evidence

Leftovers `REC-105`.

#### Exceptions

None.

### REQ-028 — Capability is the pid you were sent

- **Priority:** Should
- **Applies to:** catalog card on G-002
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-106`
- **Verification:** Later: explore cannot write; implementer cannot read keys; hands cannot hold or call the Session pid; `:erpc` to the brain fails.
- **Risk linkage:** `RSK-006`

#### Requirement

Capability leftovers MUST sit on G-002: unforgeable pids; do not
give hands too big a pid; per-role grants are constitutions on
nodes. A shared cookie MUST still be a drop (`REQ-015`). Permission
popups MUST NOT become product identity.

#### Rationale

A fence is a location plus a pid you were not sent.

#### Acceptance Evidence

Leftovers `REC-106`.

#### Exceptions

None.

### REQ-029 — One brain, many hands is multiplicity of G-002

- **Priority:** May
- **Applies to:** catalog card on G-002
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-107`
- **Verification:** Later: one Session, two hands; kill one; Session + JSONL live; keys stay on the brain.
- **Risk linkage:** `RSK-010`

#### Requirement

One Session coordinating multiple hands locations MAY be tried
after one hands location exists. It MUST NOT be a chat democracy
and MUST NOT be merged with G-005. FLAME / Fly MUST stay study.
Livebook is the architecture cousin, not a UI to become.

#### Rationale

José named this under brains vs hands. Two hands are still G-002.

#### Acceptance Evidence

Leftovers `REC-107`.

#### Exceptions

None.

### REQ-030 — Voyager skills are G-003 payloads that run on hands

- **Priority:** Should
- **Applies to:** catalog card on G-003
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-108`
- **Verification:** Later: load `.beam` with `load_binary`; mailbox intact; old code in-flight; next turn new tool; skill process on hands; Mix on brain → drop.
- **Risk linkage:** `RSK-018`

#### Requirement

An executable skill library MUST be catalogued as a G-003 payload,
run on hands, not as a marketplace and not as markdown sold as
Voyager. Profile switch still set-diffs children. Hooks stay
observe-only. Curriculum / next-task proposer MUST NOT merge into
G-004. Start with a human-written `.beam`; agent-written safety is
`OQ-010`.

#### Rationale

G-003 already is plugin swap. Voyager is what you put in the code
server.

#### Acceptance Evidence

Leftovers `REC-108`.

#### Exceptions

None.

### REQ-031 — Prefix cache is a named G-003 cost

- **Priority:** Should
- **Applies to:** catalog card on G-003
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-109`
- **Verification:** Later: time to next completion after a swap and after a compact; report whether the prefix cache broke (`OQ-005`).
- **Risk linkage:** `RSK-007`

#### Requirement

Prefix-cache economics MUST remain a named cost on G-003’s
keep/drop. Constitution + tool specs SHOULD live in
`persistent_term`. Never rebuild the prefix mid-turn. Plugin load
and compact MUST be named cache-break events. A swap whose measured
break eats the win MUST be dropped. Host field is G-003 only.

#### Rationale

Do not treat cache as weather.

#### Acceptance Evidence

Leftovers `REC-109`; runtime `OQ-005`.

#### Exceptions

None.

### REQ-032 — Replay is a lab method on G-001, not a product

- **Priority:** May
- **Applies to:** catalog card / lab method on G-001
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-110`
- **Verification:** Later: replay a recorded Session JSONL against a fake provider.
- **Risk linkage:** `RSK-012`

#### Requirement

Deterministic replay of Session messages against a fake provider
MAY be kept as lab tooling to make G-001 / G-002 measures cheaper.
It MUST NOT become product identity. Observer and Livebook MUST NOT
become the UI.

#### Rationale

A debugger is how we later measure G-001. It is not a José
sentence.

#### Acceptance Evidence

Leftovers `REC-110`.

#### Exceptions

None.

### REQ-033 — Adaptation method is the catalog unit, not a test

- **Priority:** Must
- **Applies to:** this catalog’s honesty
- **Implementation phase:** catalog only
- **Source decisions:** `REC-113`
- **Verification:** Inspection of later specs/plans for Elixir-LangGraph or “skip the papers.”
- **Risk linkage:** `RSK-012`

#### Requirement

The catalog unit MUST remain: circle the `erl` nouns, underline the
leftover, sit it on G-001 / G-002 / G-003 or say Watch. After a
later try, ask whether a piece of their scaffolding disappeared. A
later spec that reads as Elixir-LangGraph or as “we have OTP so
skip the papers” MUST be dropped.

#### Rationale

Without this claim the adaptation stance vanishes into slogans.

#### Acceptance Evidence

Leftovers `REC-113`; this file’s §9.

#### Exceptions

None.

### G-004 scoring method

### REQ-034 — G-004 is the fixed-set keep/reset loop

- **Priority:** Must
- **Applies to:** sibling-repo test G-004
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-200`
- **Verification:** Later: `results.tsv` + holdout + leftover G-001…G-003 measures do not collapse. Do not run here.
- **Risk linkage:** `RSK-019`

#### Requirement

G-004 MUST remain its own headline: an overnight keep/reset loop on
a **fixed** test set, frozen model, child Session (or child node),
mutation via `git` and optional `:code.load_binary`. This MUST be
the fixed-set lab loop. It MUST NOT be “improves while you use it.”
Keep the *loop* if holdout rises without verifier edits, without
“more tokens / more time” as the win, and without honesty collapse.
Drop if it only Goodharts three tasks. Human still throws away
hack-keeps.

#### Rationale

Blueprint §5 row 4 and §7.15.

#### Acceptance Evidence

Score-harness `REC-200`; five-test table row 4.

#### Exceptions

None.

### REQ-035 — Judge tree, holdout, and `program.md` are read-only

- **Priority:** Must
- **Applies to:** sibling-repo test G-004; judge fence
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-201`
- **Verification:** Later: diff judge tree and `program.md` before vs after every trial; any write → crash/discard; confirm separate verifier (or equivalent).
- **Risk linkage:** `RSK-020`

#### Requirement

The organism MUST NOT edit the scorer, the holdout, leftover-test
identity, or `program.md`. Writable files MUST be only:
constitution, compact-strategy module, tool list, observe-only
hooks. The later repo SHOULD run G-004 with Harbor
`verifier.environment_mode = "separate"` (or an equivalent fence).
Shared-mode Harbor MUST NOT be treated as an honest G-004 judge.
Regrade MAY fix a grader after a run; it MUST NOT become a
mid-search mutation.

#### Rationale

A keep is meaningless if the harness can rewrite `tests/`. Official
Harbor default is shared; separate exists because the default is
not a fence.

#### Acceptance Evidence

Score-harness `REC-201`.

#### Exceptions

None.

### REQ-036 — Freeze the model; declare one primary before the run

- **Priority:** Must
- **Applies to:** sibling-repo scoring run under G-004
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-202`
- **Verification:** Later: run tag records model id, primary name, holdout id, and writable-file allowlist *before* trial 1; those four fields did not change.
- **Risk linkage:** `RSK-027`

#### Requirement

For a tagged G-004 run the model id MUST be frozen. Exactly one
primary MUST be declared before trial 1. Legal primaries: Harbor
task success (`reward.txt` 1/0 or the named `task_ok` float) *or*
attention honesty. Side stats, extra `reward.json` fields, and
layer watches MUST NOT keep unless that layer *was* the declared
primary. Switching the primary after seeing numbers invalidates
the tag. Tiny gain + ugly complexity = discard.

#### Rationale

A keep that chose its metric after the spreadsheet is not a keep.

#### Acceptance Evidence

Score-harness `REC-202`.

#### Exceptions

A later amendment may add a composite. First runs MUST NOT use one.

### REQ-037 — The G-004 loop is not Arvo’s identity

- **Priority:** Must
- **Applies to:** catalog honesty; later product gate
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-204`
- **Verification:** Later: loop, `results.tsv`, `program.md`, and judge tree live outside `arvo/`.
- **Risk linkage:** `RSK-025`

#### Requirement

The searcher MUST live in the sibling experiment repo. The loop
MUST NOT be copied into `arvo/` as the product. A winning *file*
(constitution, module) MAY later be copied as a separate gate.

#### Rationale

Landing the searcher would make Arvo an online improver in all but
name.

#### Acceptance Evidence

Score-harness `REC-204`; Blueprint §22.

#### Exceptions

None.

### REQ-038 — MUST NOT merge G-004 with “improves while you use it”

- **Priority:** Must
- **Applies to:** catalog honesty for G-004
- **Implementation phase:** catalog only
- **Source decisions:** `REC-205`
- **Verification:** Inspection: if a design has no frozen task list, or mutates constitution from live user sessions without a holdout, record **drop** as G-004.
- **Risk linkage:** `RSK-019`, `RSK-023`

#### Requirement

G-004 MUST NOT be merged with the cousin “the harness gets better
while you use it.” Online ACE-style memory, live playbook rewrite,
and “self-improving while coding” MUST NOT be this test.

#### Rationale

Blueprint §7.15. Charter review attack 1. Synthesis that “clarifies”
G-004 into online improvement has failed.

#### Acceptance Evidence

Score-harness `REC-205`; this file’s §5–§6.

#### Exceptions

None without amending §7.15.

### REQ-039 — MUST NOT land the searcher as product identity

- **Priority:** Must
- **Applies to:** later product gate; `arvo/` landing
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-207`
- **Verification:** A PR into `arvo/` whose subject is the searcher / keep-reset loop is a drop at the product gate.
- **Risk linkage:** `RSK-025`

#### Requirement

The G-004 searcher MUST NOT be shipped as what Arvo is. Copying a
winning file is a product gate. Copying the loop is changing the
product into the cousin.

#### Rationale

Twin of `REQ-037`. Blueprint score-harness non-goals.

#### Acceptance Evidence

Score-harness `REC-207`.

#### Exceptions

None.

### G-005 scoring method

### REQ-040 — G-005 is an own-Session specialist with three arms

- **Priority:** Must
- **Applies to:** sibling-repo test G-005
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-203`
- **Verification:** Later: same tasks, three arms; isolation checks; sequential vs parallelizable split. Do not run here.
- **Risk linkage:** `RSK-021`, `RSK-026`

#### Requirement

G-005 MUST remain its own headline, **split** from G-004. A
specialized helper (scout / critic / planner) MUST be its **own
Session** (or hands node). Specialization MUST be the child’s
constitution + tool set + model id. Parent MUST NOT import the
child transcript. Child MUST NOT `start_turn` on the parent. Scout
MUST NOT write or see keys. The later repo MUST run three arms on
the same tasks: none / parent-model / smaller-or-local. One
specialist family per run tag. The parent model NEED NOT run
locally. Plan/todo chrome MUST stay refused as identity; the lab
MAY still study planner-as-child.

#### Rationale

Isolation plus the right specialist is the leftover. A taped-on
prompt is not that claim.

#### Acceptance Evidence

Score-harness `REC-203`; five-test table row 5.

#### Exceptions

None.

### REQ-041 — MUST NOT treat a nested prompt as a G-005 child

- **Priority:** Must
- **Applies to:** catalog honesty for G-005
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-206`
- **Verification:** If the parent imported the child transcript, or the child can `start_turn` on the parent, or the child has no own constitution / tool set / model id, record **drop**.
- **Risk linkage:** `RSK-021`

#### Requirement

A nested prompt with a process id taped on MUST NOT be scored as
G-005. An org-chart second brain (V-003) MUST also be a drop.

#### Rationale

A persona paragraph is prompt theater.

#### Acceptance Evidence

Score-harness `REC-206`.

#### Exceptions

None.

### REQ-042 — Local or smaller helper MAY lose; declare the keep-deciding score first

- **Priority:** Must
- **Applies to:** sibling-repo test G-005
- **Implementation phase:** later sibling repo
- **Source decisions:** `REC-203`
- **Verification:** Later run tag names which of success / parent waste / dollars / wall time is keep-deciding *before* the sweep.
- **Risk linkage:** `RSK-026`

#### Requirement

G-005 MUST score task success, parent waste, dollars, and wall
time. Exactly one of those four MUST be declared keep-deciding
before the run. Local / smaller MUST be allowed to lose — that is a
result. Keep a specialist only if it wins the declared score
without adding a second brain for org-chart reasons. Keep
local/smaller only if quality holds or a known quality drop is
worth the cost.

#### Rationale

Skipping the none arm makes every helper look useful. Forbidding a
remote parent warps the test.

#### Acceptance Evidence

Score-harness `REC-203` arms table.

#### Exceptions

None.

### Watch, Refuse, and scoring cousins

### REQ-043 — GEPA / ACE and the proposer slot stay Watch above G-004

- **Priority:** Must
- **Applies to:** Watch shelf above G-004
- **Implementation phase:** catalog only
- **Source decisions:** `REC-111`, `REC-208` (merged)
- **Verification:** Inspection: no G-006; no online improver sold as G-004.
- **Risk linkage:** `RSK-015`, `RSK-023`

#### Requirement

A proposer slot MUST be named *above* G-004 and MUST stay Watch.
It is not G-004 and not G-006 and not “improves while you use it.”
GEPA / ACE / Meta-Harness MUST stay Watch as possible later bodies
of that slot. Organism ≠ searcher ≠ judge. The slot MUST NOT touch
the judge, the holdout, or `program.md`. `OQ-011` is **closed**:
yes, the slot is named; the leftover is not promoted.

#### Rationale

The leftover is real. Promoting it is G-006. Harbor lists GEPA as
an optimizer, not as the verifier.

#### Acceptance Evidence

Leftovers `REC-111`; score-harness `REC-208`; `OQ-011` in §25.

#### Exceptions

A later keep would require a phase-2 measure that the proposer
helped G-004’s holdout without eating the judge. Until then, Watch.

### REQ-044 — Layer scores stay Watch beside scoring; not G-006

- **Priority:** Must
- **Applies to:** Watch shelf beside scoring
- **Implementation phase:** catalog only
- **Source decisions:** `REC-112`, `REC-209` (merged)
- **Verification:** Inspection: watches are columns, not a sixth test; no invented Harbor number.
- **Risk linkage:** `RSK-022`, `RSK-027`, `RSK-029`

#### Requirement

A later judge MAY *watch* honesty, stub/reuse, isolation, and
kill-Focus-lives beside the one declared primary. Those watches
MUST stay Watch. They MUST NOT become G-006. They MUST NOT keep
unless that layer was the declared primary (`REQ-036`). Density
(`OQ-007`) MUST NOT be defined as a G-004 primary here. Audit
column names in Arvo source MUST NOT be cited as a score this lab
ran.

#### Rationale

A scoreboard is not a José primitive.

#### Acceptance Evidence

Leftovers `REC-112`; score-harness `REC-209`.

#### Exceptions

None.

### REQ-045 — Searcher-meta stays Watch; `program.md` on a slower clock

- **Priority:** Must
- **Applies to:** Watch shelf above the proposer
- **Implementation phase:** catalog only
- **Source decisions:** `REC-210`
- **Verification:** Inspection: Bilevel / AutoHarness / Hermes are not features; organism cannot edit `program.md`.
- **Risk linkage:** `RSK-020`, `RSK-023`

#### Requirement

Bilevel / AutoHarness / Hermes-style “mutate the searcher” MUST
stay Watch. The human MUST own `program.md`. It MUST move slower
than the G-004 writable set and slower than the optional proposer
slot.

#### Rationale

G-004 mutates the organism. A meta-searcher mutates the searcher.
Collapsing them eats the judge’s owner.

#### Acceptance Evidence

Score-harness `REC-210`.

#### Exceptions

None.

### REQ-046 — Every Watch cluster stays Watch

- **Priority:** Must
- **Applies to:** Watch shelf
- **Implementation phase:** catalog only
- **Source decisions:** `REC-114`
- **Verification:** Inspection of §26; no Watch row implemented as identity.
- **Risk linkage:** `RSK-011`

#### Requirement

The 23 SORT Watch clusters leftovers listed MUST stay Watch. Later
stages MUST NOT raid Watch to look busy.

#### Rationale

Leaving these on Watch is the leftovers success bar.

#### Acceptance Evidence

Leftovers `REC-114` table; §26.

#### Exceptions

A human amendment of a single named row.

### REQ-047 — Every Refuse cluster stays refused

- **Priority:** Must
- **Applies to:** Rejected shelf
- **Implementation phase:** catalog only
- **Source decisions:** `REC-115`
- **Verification:** If a design requires Horde / relups / shared cookie / foreign CLI / Session `eval` / LiveView-as-UI / HTTP-as-primary / photocopy as architecture, record **drop**.
- **Risk linkage:** `RSK-012`, `RSK-003`, `RSK-004`

#### Requirement

The 23 SORT Refuse clusters MUST stay refused as architecture. The
lab MAY still read them. They MUST NOT be research centers or
`arvo/` landing paths. Runtime Required drops (`REQ-015`,
`REQ-016`, `REQ-021`) MUST NOT be reminted.

#### Rationale

Refuse exists so these cannot become headlines.

#### Acceptance Evidence

Leftovers `REC-115`; §27.

#### Exceptions

A human amendment of a Refuse row.

## 23. Traceability

| REQ | Sources | Later home |
| --- | ------- | ---------- |
| REQ-001 | Blueprint §7.2; Charter §1; REC-113 | catalog invariant |
| REQ-002 | Blueprint §5, §7.13; REC-001, REC-004, REC-009, REC-200, REC-203 | catalog invariant |
| REQ-003 | Blueprint §6, §7.3; Charter §3 | catalog invariant |
| REQ-004 | Blueprint §7.10; REC-114 | catalog invariant |
| REQ-005 | Blueprint §7.8–9; REC-006, REC-113, REC-115 | catalog invariant |
| REQ-006 | Charter §2, §8; runtime checkout table | catalog invariant |
| REQ-007 | REC-113, REC-114, REC-115 | catalog invariant |
| REQ-008 | Blueprint §7.14, §22 | sibling-repo standup |
| REQ-009 | Charter §11 | catalog invariant |
| REQ-010 | Blueprint §15; Charter §7, §14 | catalog invariant |
| REQ-011 | REC-001 | sibling-repo test G-001 |
| REQ-012 | REC-002 | sibling-repo test G-001 |
| REQ-013 | REC-003 | sibling-repo test G-001 |
| REQ-014 | REC-004 | sibling-repo test G-002 |
| REQ-015 | REC-005 | sibling-repo test G-002 |
| REQ-016 | REC-006 | sibling-repo test G-002 |
| REQ-017 | REC-007 | sibling-repo test G-002 (optional) |
| REQ-018 | REC-008 | sibling-repo test G-002 |
| REQ-019 | REC-009 | sibling-repo test G-003 |
| REQ-020 | REC-010 | sibling-repo test G-003 |
| REQ-021 | REC-011 | sibling-repo test G-003 |
| REQ-022 | REC-100 | catalog card on G-001 |
| REQ-023 | REC-101 | catalog card on G-001 |
| REQ-024 | REC-102 | catalog card on G-001 |
| REQ-025 | REC-103 | catalog card on G-002 |
| REQ-026 | REC-104 | catalog card on G-002 (optional) |
| REQ-027 | REC-105 | catalog card on G-002 |
| REQ-028 | REC-106 | catalog card on G-002 |
| REQ-029 | REC-107 | catalog card on G-002 (optional) |
| REQ-030 | REC-108 | catalog card on G-003 |
| REQ-031 | REC-109 | catalog card on G-003 |
| REQ-032 | REC-110 | catalog card / lab method on G-001 (optional) |
| REQ-033 | REC-113 | catalog invariant |
| REQ-034 | REC-200 | sibling-repo test G-004 |
| REQ-035 | REC-201 | sibling-repo test G-004 |
| REQ-036 | REC-202 | sibling-repo test G-004 |
| REQ-037 | REC-204 | catalog invariant / later product gate |
| REQ-038 | REC-205 | catalog invariant |
| REQ-039 | REC-207 | later product gate |
| REQ-040 | REC-203 | sibling-repo test G-005 |
| REQ-041 | REC-206 | sibling-repo test G-005 |
| REQ-042 | REC-203 | sibling-repo test G-005 |
| REQ-043 | REC-111, REC-208 | Watch shelf |
| REQ-044 | REC-112, REC-209 | Watch shelf |
| REQ-045 | REC-210 | Watch shelf |
| REQ-046 | REC-114 | Watch shelf |
| REQ-047 | REC-115 | Rejected shelf |

No `DEC-###` exists to cite.

## 24. Risk Register

Inherited from the three accepted reports. Full write-ups stay in
those files. Synthesis adds `RSK-030` only.

| ID | Description | L | I | Mitigation | Owner | Trigger |
| -- | ----------- | - | - | ---------- | ----- | ------- |
| RSK-001 | In the tree ⇒ works | H | H | Checkout-vs-function; `REQ-006` | reviews | REQ treats an Arvo path as passing |
| RSK-002 | Docker-first because papers do | M | M | `REQ-014`, `REQ-017` | phase-2 | First G-002 sketch starts in Compose |
| RSK-003 | Port-as-native | M | H | `REQ-016`, `REQ-005` | synthesis + reviews | Foreign CLI under Hands |
| RSK-004 | Relups as the plugin story | L | H | `REQ-021` | reviews | SASL release_handler in a G-003 design |
| RSK-005 | G-001 collapsed to auto-resume | H | H | `REQ-013` | phase-2 | Keep after `bin/arvo` relaunch only |
| RSK-006 | Shared cookie treated as a fence | H if nodes | H | `REQ-015` | phase-2 | `cookie: "arvo_headless"` in a live node story |
| RSK-007 | Third load hard-purges the in-flight turn | M | H | `REQ-019` | phase-2 G-003 | Two swaps during one turn |
| RSK-008 | Mix remains in the product VM after a “swap” | M | H | `REQ-020` | phase-2 | Loader still shells `mix compile` |
| RSK-009 | Cleartext distribution / accidental cluster | M once nodes | H | Hidden + per-session pairing; OTP TLS warning recorded | phase-2 | First `:peer` start |
| RSK-010 | Sixth headline | M | H | `REQ-002`, `REQ-007` | reviews | A sixth Graduate row |
| RSK-011 | Raiding Watch | M | H | `REQ-046` | synthesis + reviews | Watch cluster as Default card without amendment |
| RSK-012 | Photocopy / Elixir-LangGraph / fake OS | M | H | `REQ-005`, `REQ-033`, `REQ-047` | reviews | Spec names LangGraph / “agent OS” as architecture |
| RSK-013 | Opening intake | M later | H | `REQ-004` | every later stage | New arXiv IDs SORT did not name |
| RSK-014 | Leftover treated as proven on BEAM | H | H | `REQ-009` | reviews | REQ says “RLM/GEPA/Voyager works on BEAM” |
| RSK-015 | G-004 cousin becomes a card-as-test | M | H | `REQ-038`, `REQ-043` | reviews | Online improver sold as G-004 |
| RSK-016 | IEx / `eval` on Session sold as RLM | M if RLM | H | `REQ-025` | phase-2 | `eval` / IEx on the Session VM |
| RSK-017 | Attention + overflow + memory products become “memory OS” | M | H | Split cards; `REQ-023`, `REQ-024` | reviews | Spec chapter titled as a memory product |
| RSK-018 | Voyager skill compiled with Mix on the brain | M if early | H | `REQ-030`, `REQ-020` | phase-2 | Loader still shells Mix |
| RSK-019 | G-004 collapses into “improves while you use it” | H | H | `REQ-038`, `REQ-034` | reviews | Spec sentence that drops “fixed test set” |
| RSK-020 | Judge eaten | H if shared | H | `REQ-035` | phase-2 G-004 | Shared-mode task, or keep after grader edit |
| RSK-021 | Nested prompt sold as G-005 | H | H | `REQ-041`, `REQ-040` | phase-2 G-005 | Parent prompt contains the specialist; no child constitution |
| RSK-022 | Layer scores become G-006 | M | H | `REQ-044`, `REQ-002` | reviews | `G-006` or “honesty suite” REQ |
| RSK-023 | GEPA / ACE become an online improver | M | H | `REQ-043` stays Watch | reviews + phase-2 | “ACE online playbook” in a G-004 design |
| RSK-024 | Running the loop in this repo | L | H | `REQ-003` | human + later stages | `harbor run` or `bin/arvo` in this tree |
| RSK-025 | Searcher lands as Arvo’s identity | M | H | `REQ-037`, `REQ-039` | later product gate | `searcher/` under `arvo/` |
| RSK-026 | Parent required to run locally | M | M | `REQ-040`, `REQ-042` | phase-2 G-005 | Design that forbids a remote parent |
| RSK-027 | Invented Harbor number treated as a result | M | H | `REQ-009`, `REQ-044` | reviews | A keep that cites a number with no phase-2 job dir |
| RSK-028 | Installed-agent image still contains Mix / keys | M | H | Inherit `REQ-014`, `REQ-018` | phase-2 | First Harbor adapter ships tools in-process |
| RSK-029 | Missing `evals/` path treated as a live scoreboard | M | M | `REQ-006`, `REQ-044` | phase-2 honesty scoreboard | Citation of that path as a result |
| RSK-030 | This specification is treated as a coding spec for *this* repo | M | H | `REQ-001`, `REQ-003`, `REQ-010`; status Proposed | reviews + plan stage | Tickets or Elixir in this tree citing `REQ-###` |

### RSK-030 — Catalog treated as coding spec for this repo

- **Description:** Readers treat `REQ-001`…`REQ-047` as implementation
  tickets in this tree, or start a coding-agent backlog here.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Status banner; `REQ-001`, `REQ-003`, `REQ-010`;
  Charter plan-as-backlog anti-pattern.
- **Owner:** synthesis; later plan review
- **Trigger:** Elixir, Harbor, or tickets in this repository citing
  this file

## 25. Open Questions

Inherited. None newly minted. None block *catalog* honesty.
`OQ-011` is closed.

| ID | Question | Blocking for catalog? | Status | Owner | Resolution path |
| -- | -------- | --------------------- | ------ | ----- | --------------- |
| OQ-001 | Does quit actually halt a running product VM? | No | Open | phase-2 | `REQ-011` measure |
| OQ-002 | Which ladder rung is actually thinnest that passes? | No | Open | phase-2 | `REQ-014` sweep |
| OQ-003 | What boot makes attach possible without a zombie `mix run --no-halt`? | No for catalog; yes before a G-001 keep | Open | phase-2 | Name a boot in the experiment repo |
| OQ-004 | Can a plugin `.beam` that today uses `on_load` / Rustler be loaded with `load_binary` on hands without restarting the brain? | No | Open | phase-2 | `REQ-018` + `REQ-019` |
| OQ-005 | Does the prefix-cache break eat the G-003 UX win? | No | Open | phase-2 | `REQ-031` |
| OQ-006 | Do remaining TUI→Session `get` calls deadlock under a second client? | No | Open | phase-2 | Attach two clients |
| OQ-007 | What is an operational definition of density on audit JSONL? | No | Open | leftovers-named; phase-2 | Define or leave P-029 on Watch |
| OQ-008 | Is IEx-as-RLM ever justified? | No | Open | phase-2 | Only if heap is BEAM-shaped; default remains Port of official Python env |
| OQ-009 | Does worktree still pay after a hidden node passes? | No | Open | phase-2 | `REQ-026` |
| OQ-010 | Can an agent-written skill be loaded without new atoms, `on_load`, or Mix on the brain? | No | Open | phase-2 | `REQ-030`; start with human-written `.beam` |
| OQ-011 | Does score-harness name a proposer slot above G-004? | No | **Closed — yes.** Slot named (`REQ-043`). Leftover stays Watch. Not reminted. | score-harness (answered) | Do not reopen |
| OQ-012 | Does parallel compact help a coding session after handoff-first? | No | Open | phase-2 | `REQ-024` |
| OQ-013 | Which Harbor reward field is the G-004 primary when both `reward.txt` and `reward.json` exist? | No | Open | phase-2 | Declare on the run tag |
| OQ-014 | Is the G-004 holdout a Harbor dataset split or a withheld local task slice? | No for catalog; yes before a G-004 keep | Open | phase-2 | Either, if withheld before trial 1 |
| OQ-015 | Which G-005 specialist should the first three-arm sweep use? | No | Open | phase-2 / later plan | Scout is the narrowest; not decided here |
| OQ-016 | What is an operational definition of “parent waste”? | No | Open | phase-2 | Freeze tokens / turns / tool calls on the run tag |
| OQ-017 | Attach Arvo as a Harbor installed agent or as an external agent? | No | Open | phase-2 | Isolation still follows G-002 |
| OQ-018 | After `evals/arvo-attention-reread/` disappeared, what is the first honesty scoreboard? | No | Open | phase-2 | Rebuild from audit JSONL, or pick Harbor `task_ok` first and watch honesty |

## 26. Deferred Work

Watchlist and optional items. Not a backlog. Not G-006.

| Item | Source | Why deferred |
| ---- | ------ | ------------ |
| Proposer slot above G-004 (GEPA / ACE / Meta-Harness as possible bodies) | REC-111, REC-208, `REQ-043` | Named; stays Watch |
| Layer watches (honesty, stub/reuse, isolation, kill-Focus-lives) | REC-112, REC-209, `REQ-044` | Columns, not a test |
| Searcher-meta; slower `program.md` | REC-210, `REQ-045` | Watch until an inner holdout exists |
| All 23 SORT Watch clusters | REC-114, `REQ-046` | Success bar |
| Docker node as thicker G-002 rung | REC-007, `REQ-017` | Optional; after hidden node |
| Worktree beside G-002 | REC-104, `REQ-026` | Optional |
| Many-hands multiplicity | REC-107, `REQ-029` | Optional; after one hands location |
| Replay / fake provider | REC-110, `REQ-032` | Optional lab method |
| Density metric P-029 | OQ-007 | No operational JSONL definition |
| IEx-as-RLM | OQ-008 | Conditional; default is Port-on-hands |
| Agent-written `.beam` | OQ-010 | After human-written skill |
| Parallel compact as worker layout | OQ-012 | After G-001 attach |
| Harbor adapter shape; honesty scoreboard rebuild | OQ-017, OQ-018 | Phase-2 |

## 27. Rejected Work

Required drops and Refuse. Reading is allowed. Architecture is not.

| Item | Source | Why rejected |
| ---- | ------ | ------------ |
| JSONL auto-resume scored as G-001 | REC-003, `REQ-013` | Disk resume ≠ attach |
| Shared cookie as fence / auth | REC-005, `REQ-015` | Pairing ≠ isolation |
| Port-wrap of a foreign harness as hands | REC-006, `REQ-016` | Shell |
| Mix-in-VM / `append_path` plus hope as G-003 | REC-010, `REQ-020` | Not two-version swap |
| OTP relups as the plugin story | REC-011, `REQ-021` | Wrong OTP product |
| Merging G-004 with “improves while you use it” | REC-205, `REQ-038` | Different cousin |
| Nested prompt as G-005 | REC-206, `REQ-041` | Prompt theater |
| Searcher as Arvo’s identity | REC-207, `REQ-039` | Loop is method, not product |
| All 23 SORT Refuse clusters | REC-115, `REQ-047` | Study-don’t-build as architecture |
| Horde / Oban / libcluster / Swarm as architecture | REC-115 | Filling silences with fashion |
| MCP in core | REC-115 | Foreign tool bus as center |
| Plan / todo / permission popups as identity | REC-115 | Product hard-no |
| Jido or Alloy *as* Session | REC-115 | LangChain-on-BEAM |
| Legion / Dune as the bash story | REC-115 | Isolation is another BEAM |
| Phoenix LiveView as default UI | REC-115 | Hard no |
| HTTP / OpenCode clone as primary | REC-115 | Need is attach; host is a mailbox |
| `eval` on the Session VM | REC-115 | Includes “just IEx for RLM” |
| Silent in-place compact that rewrites history | REC-115 | JSONL does not die |
| Feature race | REC-115 | Personal lab |
| Photocopy / Elixir-LangGraph / fake OS | REC-115, REC-113 | Adaptation, not transcription |
| Vector DB / cross-project memory as research center | REC-115 | Same-session rings first |
| Multi-agent chat democracy | REC-115 | Org chart ≠ architecture |
| Ore in-scope | REC-115 | Ignore unless the owner says so |
| Plugin marketplace | REC-115 | Hex / git / local path are enough |
| Arvo *is* a Livebook runtime | REC-115 | Steals the wrong layer |
| Elixir advocacy / skip the papers | REC-115 | Leftovers are the gold |
| Prompt theater / Sol packs | REC-115 | No leftover |
| LeWorldModel as harness work | REC-115 | Wrong field |
| G-006 of any kind | Blueprint §7.13 | Five stay five |

## 28. Recommendation Disposition Ledger

Every material `REC` has exactly one disposition. Report-class
**Rejected** rows are **Accepted** here *as rejections* (the drop is
kept), unless noted. Watchlist rows are **Accepted** as Watch or
**Merged** into a Watch `REQ`. No silent drop.

| REC | Disposition | Notes | Surviving REQ(s) |
| --- | ----------- | ----- | ---------------- |
| REC-001 | Accepted | G-001 host noun | REQ-011 |
| REC-002 | Accepted | Default host recipe | REQ-012 |
| REC-003 | Accepted | Drop kept: auto-resume is not G-001 | REQ-013 |
| REC-004 | Accepted | Thinnest ladder | REQ-014 |
| REC-005 | Accepted | Drop kept: shared cookie is not a fence | REQ-015 |
| REC-006 | Accepted | Drop kept: Port-wrap foreign harness | REQ-016 |
| REC-007 | Accepted | Optional thicker rung | REQ-017 |
| REC-008 | Accepted | NIF and bash on hands | REQ-018 |
| REC-009 | Accepted | `load_binary` + two versions + `soft_purge` | REQ-019 |
| REC-010 | Accepted | Drop kept: Mix-in-VM / path-only | REQ-020 |
| REC-011 | Accepted | Drop kept: relups are not plugins | REQ-021 |
| REC-100 | Accepted | Card, not a test | REQ-022 |
| REC-101 | Accepted | Card; density stays Watch | REQ-023 |
| REC-102 | Accepted | Card; ACE loop stays Watch | REQ-024 |
| REC-103 | Accepted | Card on hands; official RLM Port ≠ foreign-harness shell | REQ-025 |
| REC-104 | Accepted | Optional card | REQ-026 |
| REC-105 | Accepted | Card | REQ-027 |
| REC-106 | Accepted | Card | REQ-028 |
| REC-107 | Accepted | Optional card; not G-005 | REQ-029 |
| REC-108 | Accepted | Card; payload of G-003 | REQ-030 |
| REC-109 | Accepted | Card; named cost | REQ-031 |
| REC-110 | Accepted | Optional lab method | REQ-032 |
| REC-111 | Merged | Same Watch claim as REC-208: proposer *above* G-004 | REQ-043 |
| REC-112 | Merged | Same Watch claim as REC-209: layers beside scoring | REQ-044 |
| REC-113 | Accepted | Catalog method | REQ-033, REQ-005 |
| REC-114 | Accepted | Watch stays Watch | REQ-046, REQ-004 |
| REC-115 | Accepted | Refuse stays refused (drop kept) | REQ-047 |
| REC-200 | Accepted | G-004 method | REQ-034 |
| REC-201 | Accepted | Judge fence; separate verifier | REQ-035 |
| REC-202 | Accepted | Frozen model; one primary before the run | REQ-036 |
| REC-203 | Accepted | G-005 method; three arms | REQ-040, REQ-042 |
| REC-204 | Accepted | Loop is not identity | REQ-037 |
| REC-205 | Accepted | Drop kept: cousin merge | REQ-038 |
| REC-206 | Accepted | Drop kept: nested prompt | REQ-041 |
| REC-207 | Accepted | Drop kept: searcher-as-product | REQ-039 |
| REC-208 | Merged | Same Watch claim as REC-111; `OQ-011` closed yes | REQ-043 |
| REC-209 | Merged | Same Watch claim as REC-112 | REQ-044 |
| REC-210 | Accepted | Watch; slower `program.md` | REQ-045 |

**Count:** 38 rows. None silent. None reminted.

## 29. Definition of Done

This *proposed* specification is done as a synthesis artifact when:

1. The 30 numbered headings are filled as catalog readings.
2. Every material `REC` has one disposition.
3. `REQ-001`…`REQ-047` state the catalog claims.
4. Five tests are still five. G-004 and G-005 stay split.
5. Status is `Proposed — pending adversarial review`.
6. Independent validation has run in a **separate** session
   (not claimed here).
7. A human accepts and the accepting commit is recorded (not
   claimed here).

This *program* is not done when this file exists. Program-level done
still requires spec-review, a revised spec, a later plan spine, and
a sibling repo whose first job is the Arvo smoke check **there**.
This program still does not succeed by shipping a harness.

Catalog-ready is not coding-ready. “Implementation-ready” here means
the catalog is coherent enough to review, not that Elixir may start
in this tree.

## 30. Handoff to Adversarial Review

Next legal substantive stage, **after** human acceptance and commit
of this file, is spec-review in a **fresh** session.

Reviewers must attempt at least:

1. G-004 collapse into “improves while you use it.”
2. In the tree ⇒ works.
3. Sixth test (card, layer, proposer, Watch raid).
4. Port-as-native / Elixir-LangGraph.
5. Plan-as-backlog / this-spec-as-tickets-here (`RSK-030`).
6. Opened intake or daily-driver drift.
7. Judge eaten.
8. Helper is a nested prompt.
9. Searcher as Arvo’s identity.
10. Invented Harbor number; missing `evals/` path treated as a score.

Do not write that review in the synthesis session. Do not write a
revised spec or an implementation plan now.

### Source notes

[^bp-3]: Accepted Program Blueprint §3, [`docs/00-program-blueprint.md`](../00-program-blueprint.md), accepting commit `0b49540cae7d2a30ad4b4b145999e27b82c50dad`.
[^jose-1]: José Valim, 14 Aug 2026, https://x.com/josevalim/status/2088186994849468659 — accessed 2026-08-15 (via accepted runtime / leftovers reports).
[^jose-2]: José Valim, 14 Aug 2026, https://x.com/josevalim/status/2088208133487264078 — accessed 2026-08-15.
[^harbor-docs]: Harbor, *Motivation*, https://www.harborframework.com/docs — accessed 2026-08-15 (via accepted score-harness report).
[^harbor-tasks]: Harbor, *Task Structure*, https://www.harborframework.com/docs/tasks — accessed 2026-08-15.
[^harbor-regrade]: Harbor, *Regrade*, https://www.harborframework.com/docs/run-jobs/regrade — accessed 2026-08-15.

## Completion Checklist

- [x] Specification exists at `docs/specifications/01-definitive-specification.md`
- [x] All 30 numbered headings present and filled (catalog readings, not invented product architecture)
- [x] Status: `Proposed — pending adversarial review`
- [x] Every material `REC` dispositioned (38 rows; none silent)
- [x] `REQ-001`…`REQ-299` only; template fields filled
- [x] Five tests still five; no G-006; cards are not tests
- [x] G-004 and G-005 stay split; cousin not merged
- [x] Scorer / judge tree read-only; frozen model; one primary before the run
- [x] G-005 has three arms; local may lose; nested prompt is a drop
- [x] `OQ-011` / `REC-111` / `REC-208` stay Watch above G-004
- [x] `REC-112` / `REC-209` stay Watch; not G-006
- [x] Searcher is not Arvo’s identity
- [x] First later job includes Arvo smoke check **there**
- [x] No `SPK-###`; no `PHASE` / `MS`; no Harbor run; no Arvo command run as a test
- [x] Exa used via REST only as allowed, or skip documented
- [x] Intake not reopened
- [x] Shared new IDs start at `RSK-030` / `OQ-019` if minted (`RSK-030` only)
- [x] Standalone as a catalog (not a coding spec for this repo)
- [x] Plain-language summary shown to Robert *(session message, not this file)*
- [x] Independent validation passed
- [x] Human accepts specification
- [ ] Manifest updated; accepting commit recorded
