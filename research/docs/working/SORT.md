# Sort — 2026-08-14

Working notes. **Not** accepted. **Not** a Blueprint. **Not** a backlog.

Intake is closed enough. Sorted in clusters, not H-001…H-368. Graduate test: a falsifiable claim a later repo could Harbor-score with a **frozen** model. Karpathy fence: the agent must not edit the judge.

Sources: [`DISCOVERY-NOTES.md`](DISCOVERY-NOTES.md) (locked framing, atlas, dump headers), [`ARXIV-WATCH.md`](ARXIV-WATCH.md), [`AUTORESEARCH-WATCH.md`](AUTORESEARCH-WATCH.md), [`LANGCHAIN-WATCH.md`](LANGCHAIN-WATCH.md), [`VAULT-WATCH.md`](VAULT-WATCH.md) (V-001…V-014 only), [`X-BOOKMARKS-WATCH.md`](X-BOOKMARKS-WATCH.md) (XB cards only), [`arxiv-home/INDEX.md`](arxiv-home/INDEX.md). Did **not** open bookmark JSON, PDFs, vault traces, or unread X Articles.

Arvo tree facts (H-153–H-163, grounding snapshot) describe **what the code appears to contain**, not a product Robert uses. He does not use Arvo day to day and is not sure those features work. Treat “shipped” as “in the tree.” The thin OTP slice is still the gap: halt-on-quit, in-process tools, Mix-in-VM plugins, FFF on the brain, Session names `Arvo.TUI`.

---

## Graduate (5)

| ID | Claim | BEAM move | Measure | Keep/drop | Land in `arvo/`? |
|----|--------|-----------|---------|-----------|------------------|
| **G-001 liveness** | Quit Focus (or close the window) leaves Session + JSONL + HEAD alive. A new client attaches and continues the same tree. That is not JSONL auto-resume after a VM death. | Session `permanent`; Focus `temporary` (or a fresh attach process). Stop `:halt_on_focus_quit`. Boot a daemon / release / `run_erl` (`arvo up` / attach / detach). Clients join via `:pg` or Registry. `os_signal` kills the tile, not the VM. | Kill Focus; SIGTERM the tile. Session pid lives. JSONL still appends. New Focus, `arvo-chat`, or IEx attaches and continues. Harbor attention honesty on the continued session, frozen model. Attach feels like tmux, not like restarting Claude (H-120, H-128, H-168, H-180, H-196). | Keep if attach ≠ disk resume and honesty does not regress. Drop if we only wrapped auto-resume in extra boot scripts. | **Yes-candidate.** Product shape of José’s first two sentences. |
| **G-002 hands** | Tools can run outside the Session VM so (a) hands cannot read `XAI_API_KEY` / cookie / Session state, (b) killing hands mid-tool leaves brain + JSONL intact, (c) the same Harbor attention task does not lose honesty. | Isolation ladder: process → Port → hidden `:peer` node (`--hidden`, per-session cookie, `Hands.API` only, no Session pid on hands) → Docker node. FFF NIF and bash live on hands. `:erpc` read-only and allowlisted, or a protocol we own. Shared cookie is not a fence. | Same Harbor attention task; topology is the only variable (H-192, H-126). Negative key test (H-123). Kill hands mid-tool (H-121). No orphan `bash -c` (H-171). Hidden BEAM ≠ bash jail — score them as different threats. | Keep the *thinnest* layer that passes (a)+(b)+(c). Drop a layer that adds latency without a new threat. Drop if “hands” is a Port wrapping a foreign harness (`jido_harness` shape). | **Lab first.** Copy into `arvo/` only if we later want it in that tree. Docker node is a separate call. |
| **G-003 code-server** | A plugin can be replaced mid-session so the Session mailbox does not drop, the in-flight turn finishes on old code, and the next turn sees new tools — without Mix on the brain and without OTP relups. | `:code.load_binary` + ETS registry + two-version modules; soft-purge after the turn. Load `.beam` only. Reject `on_load`. No new atoms from user strings. Profile switch set-diffs the supervision tree, not only the tool menu. | H-122: mailbox intact; old code for in-flight turn; new manifest next turn. Hot-reload latency (V-005). Name the prefix-cache break (P-018, XB-002). | Keep if Mix leaves the product VM and the swap is real. Drop if this is `Code.append_path` plus hope, or if cache-break cost dominates the UX win. | **Yes-candidate.** Plugins/profiles already ship; Mix-in-VM is the hazard (H-173). |
| **G-004 hill-climb** | With a frozen model and a **read-only** Harbor verifier, an overnight keep/reset loop that may edit only named harness files can raise a pre-declared primary metric on a **holdout** slice. | Each trial is a child Session (or child node). Mutation is `git` and, if useful, `:code.load_binary`. Writable: constitution, compact-strategy module, tool list, observe-only hooks. Human owns `program.md`. Judge tree is not writable. | `results.tsv`: keep / discard / crash. One primary per run tag (Harbor `task_ok` *or* attention honesty). Side stats (tokens, time) cannot keep. Holdout required. Simplicity: tiny gain + ugly complexity = discard. | Keep the *loop* if holdout rises without verifier edits, without “more tokens / more time” as the win, and without honesty collapse. Human still throws away hack-keeps (Shopify). Drop if it only Goodharts three tasks. | **No.** Lives in the later experiment repo. A winning constitution/module may later be copied into `arvo/`. The searcher does not become Arvo’s identity. |
| **G-005 child-session** | A specialized helper (scout / critic / planner) is its own Session, not a nested prompt. Test two model choices for that helper: (a) another copy of the parent model, (b) a smaller cheaper model, ideally local on Robert’s machine. Claim: isolation + the right specialist can cut parent waste or cost without dropping task success. Local/smaller is allowed to *lose* — that is a result. | Child Session or hands node + optional worktree. Parent does not import the child transcript. Child cannot `start_turn` on the parent. Specialization is the child’s constitution + tool set + model id, not a persona in the parent prompt. | Same tasks, three arms: no helper / helper=parent-model / helper=smaller-or-local. Score task success, parent waste, dollars, wall time. Scout cannot write or see keys. Split sequential vs parallelizable tasks (V-002). | Keep a specialist if it wins success, waste, or cost without a second brain for org-chart reasons (V-003). Keep local/smaller only if quality holds or the cost win is worth a known quality drop. Drop if the child is a nested prompt with a pid taped on, or if sequential tasks regress like V-002. | **Lab first.** Explore-shaped landing possible. Plan/todo as *product identity* stays refused. Local model is a helper option, not a requirement that the parent run locally. |

José’s three tweets are G-001 + G-002 + G-003. G-004 is how the later repo stays a lab and not a vibe. G-005 is the multi-agent leftover that survives V-002/V-003.

**Robert walkthrough (2026-08-14):** keep all five. Care most about G-002, then G-003. G-004: lab loop first; “improves while you use it” is the bigger cousin, do not merge. G-005: specialists + compare parent-model vs smaller/local (H-369–H-371).

**Robert (later, same day): those 5 are solid.** Headline list is locked.

**Robert also (same day):** agreed the three framing picks below. Correction: **Arvo is not his daily driver.** He does not use it now and is not sure the features in the tree work (H-372). “Land in `arvo/`” means “maybe copy into that unfinished tree later,” not “protect a tool he relies on.” This file is still not a Blueprint and not “discovery accepted.”

---

## Translate

We have a BEAM-shaped hypothesis. Not ready to Harbor-score as its own experiment — either it *is* the mechanism of a Graduate, or the leftover still needs a sharper claim.

| Cluster | Hypothesis | Merged IDs |
|---------|------------|------------|
| **Surfaces are clients** (mechanism of G-001) | Session broadcasts; clients join. Session must not import a TUI module. `arvo-chat` already proves a second client; the missing piece is attach to a *living* Session. Deadlock class (TUI→Session pulls) goes away if both sides cast, or a projector process exists. HTTP à la OpenCode is the thing José said we get for free. | H-002, H-069–H-076, H-158, H-168–H-170, H-179, H-183, H-320, H-356, XB-020, P-007 (one loop, many projectors) |
| **Attention as topology** | Hot / warm / cold is a *layout* (budgeted messages, ETS or `:disk_log` index, optional Keepers as caches over already-shipped `<session>.cold/`), not only a prompt policy. Shipped rings are maps+files inside Session. Mailbox length and reductions are context-pressure signals. Density (P-029) is the leftover metric, not “more tokens.” | H-040–H-057, H-159, H-166, H-176–H-177, H-234, H-238, H-277, H-282, P-007 layers 1–2, P-029, V-007, V-008 |
| **Overflow menu** | Compaction changes what the model sees, never what exists. Handoff is the honest overflow; in-place LLM summary is the commodity we distrust. Cheap-then-dear pipeline (stub → structural prune → microcompact → collapse → semantic last). ACE leftover: iterative rewrite collapses context. Parallel compact (P-013) is a worker layout, not a new religion. | H-041–H-042, H-054, H-125, H-157, H-186, H-205, H-208, H-214, H-280, H-292, H-301, H-313, P-001, P-002, P-007, P-011, P-013, P-014, P-019 |
| **RLM / programmatic tools / CodeAct** | Competing answers to “context is too big.” Do not merge with rings by slogan. Default RLM: Port the official Python env on **hands**. IEx-as-RLM only if the heap is BEAM-shaped (ETS, Session dumps, mailboxes). Never `eval` on Session. Programmatic tool calling: model writes a short program; intermediates stay on hands; residue returns. | H-088–H-095, H-201, H-230, H-276, H-284, H-310, P-010, P-014, LC-009, alexzhang13/rlm |
| **GEPA / ACE as proposers** (above G-004) | Organism ≠ searcher ≠ judge. GEPA/ACE evolve constitution / playbook / tool text from trajectories. Population = processes; front or playbook = ETS; rollouts = child Sessions. They sit *above* keep/reset. They do not replace Harbor. AHE sting: evolving the system prompt was the weak lever. | H-096, H-100, H-151, H-202–H-204, H-274–H-275, H-287, H-299, H-309, H-311, P-003, P-004, P-011, P-012, P-027, LC-006 |
| **Traces as ore / layer scores** | Evals are mined from traces, then become the hill. Harbor is the format we already speak. Score *layers* (honesty, stub/reuse, isolation, kill-Focus-lives), not only `task_ok`. Trace-analyzers are cheap processes. Force-verify and onboard-the-env are leftover *policies* (middleware processes / hooks), not a graph runtime. | H-051, H-105, H-114, H-167, H-227–H-229, P-003, P-006, P-009, LC-001–LC-005, LC-010, V-004, V-005, V-014 |
| **Worktree + node** (filesystem fence next to G-005) | Worktree is the dirty-tree fence; hidden node is the VM fence. Two layers, one leftover (“don’t share a dirty tree”). Loopyard/Cursor/E2B are existence proofs, not architectures to swallow. Two hands for one brain (trusted repo vs sandbox clone) is the José-shaped version. | H-020, H-067, H-111, H-219, H-296, XB-007–XB-009, P-025, P-026 |
| **Profile as machine / Voyager skills** | Profile switch starts/stops OTP children. Plugins never own `start_turn`. Voyager leftover: skills the agent *writes* and we *load* (code server), indexed in ETS, run on hands. Hooks stay observe-only (`:telemetry`). MCP, if ever, is a Port on hands behind a profile. | H-077–H-087, H-193–H-194, H-216, H-241–H-242, H-273, H-294, H-308, P-024, XB-004, XB-014, XB-018 |
| **ACI as Hands protocol** | SWE-agent leftover: the *interface* to the repo matters as much as the model. Adaptation: shrink the action language to messages (`read`/`write`/`bash`/`glob`/`grep`), not a prompt template and not “give bash and pray.” | H-097, H-113, H-189, H-283, P-014, P-023, LC-009 |
| **Capability pids** | Unforgeable pids are already object capabilities. The bug is giving hands too big a pid. Per-turn / per-role grants (explore readonly; implementer may write; network-denied cannot egress) are constitutions on nodes, not allowlist UX. | H-013–H-015, H-017, H-019, H-245, H-263, H-312, H-324, P-022 |
| **Observability / replay** | `:telemetry` + JSONL + Observer *is* the harness debugger. Deterministic replay of Session messages against a fake provider. `LocalCluster` / `:peer` specifies brains vs hands before we believe it. Time-travel is HEAD + replay. | H-114–H-119, H-250–H-251, H-260, H-228, V-005 |
| **Prefix cache as economics** | Constitution + tool specs in `persistent_term`; never rebuild the prefix mid-turn. Plugin load and compact are named cache-break events. Measure them; don’t treat cache as weather. | H-112, H-213, H-239, H-281, P-018, XB-002 |
| **One brain, many hands** | José’s explicit example. Session coordinates multiple hands nodes the way Livebook coordinates runtimes. Not a chat democracy. FLAME is elastic hands, not day-one architecture. | H-004, H-021, H-150, H-236, H-244, H-253–H-254, H-262, H-303, H-109, Livebook `runtime/standalone.ex` |
| **Adaptation method** | After you say it in BEAM nouns, does a piece of their scaffolding disappear? Circle `erl` nouns; underline leftovers. A year of agent papers is an accidental OTP tutorial. The catalog unit is a pattern card, not a paper summary. | H-197–H-200, H-269–H-271, H-302–H-307, H-315–H-337, H-357–H-368, H-329 |

---

## Watch

No BEAM-shaped claim yet — or the claim is “might collapse into a Graduate/Translate we already have.” Most of the dump belongs here. That is success.

| Cluster | Why not Translate yet | Merged IDs |
|---------|----------------------|------------|
| **Memory products / surveys** | Need is “more state than the window.” Likely collapses into shipped rings + Translate attention. Vector index is optional search, not the adaptation. mem0’s junk rate is a warning, not a design. | H-099, H-210–H-212, H-278–H-279, H-300, H-322, P-015–P-017, P-021, XB-015, V-006 |
| **Scaffold taxonomy / production maps** | Menus, not specs. Finish P-002’s seven compactors and P-007’s anatomy when a Graduate needs a knob name. Don’t implement thirteen agents. | H-206–H-207, H-209, P-001, P-002, P-005–P-008, P-020, P-028 |
| **NLAH / policy-as-document** | Constitution-as-data is already `persistent_term`. Their runtime-that-interprets-a-doc is a fake OS until we see a leftover beyond “the policy is editable.” | P-005, H-087, XB-014 |
| **Bilevel / AutoHarness / Hermes meta** | G-004 is the tiny loop. These mutate the *searcher* (`program.md`, Thompson sampling, practitioner kits). Read before promoting. Hold `program.md` to a slower clock. | P-027, P-008, V-001, V-013, H-229, XB-005, XB-006, XB-019 |
| **GenericAgent density** | Density-as-metric is the leftover. No operational definition that Harbor can score yet. Sit next to attention Translate until we can say what “density” means in audit JSONL. | P-029 |
| **Where hands can live** | Firecracker / gVisor / E2B / Daytona / Modal / Crabbox are top fences. Excellent *locations*, not frameworks. Promote a vendor only if G-002’s Docker arm needs a specific box. | H-022, H-353, XB-007–XB-009 |
| **WASM / Luerl vs hidden node** | Competing isolation hypotheses. Measure later; don’t assume. | H-026, H-147 |
| **Browser / computer-use** | A specialized hands node. Profile, not core. No claim yet that BEAM changes the interface. | H-224, H-297, LC (Stagehand as verify tool) |
| **Aider repo map** | Translation only if a Watcher child + ETS/Sourceror/tree-sitter-on-hands beats a markdown map. Not shown. | H-098, H-223, H-291 |
| **Best-of-n / prefetch / MCTS / ToT** | Runtime makes spawn cheap. That is not evidence they help coding. Cute; unproven. H-307: prompt-only versions will feel empty on BEAM. | H-062–H-063, H-220–H-222, H-288–H-289 |
| **Concurrency as product default** | Sequential tools is a product choice. Parallel *pure* tools are allowed because processes are cheap. Needs a Harbor error-rate + wall-time pair before it is Translate. Reduction fairness is a measurement, not a design. | H-058–H-064, H-124, H-258 |
| **Sleep-time / background extract** | Sweeper process, not a turn. Collapses into memory Watch or attention Translate once we know what is worth extracting. | P-017, H-212, H-326 |
| **Tidewave `project_eval`** | IEx-in-the-target-app is a plugin for the *target*, not an Arvo primitive. Docker remains the fence. Steal the instinct; don’t steal MCP. | H-085, H-110, H-334 |
| **Livebook as phase-2 notebook** | Cheap way to steal their runtime story. Not Arvo’s UI. Wait for the experiment repo. | H-094, H-119, H-145 (see Refuse) |
| **Comparative fake-BEAM** | Durable Objects, Temporal, Effect.ts, Orleans, k8s-as-supervisor, Redis-as-hippocampus. Pattern recognition / field guide. No harness experiment until a leftover is named. | H-338–H-356, H-342–H-349, H-317 |
| **Protocol weather** | A2A / AG-UI / LLMOS. Watch. Don’t build a platform. | H-226 |
| **LeWorldModel** | JEPA from pixels. Not harness engineering. | P-030 |
| **Vault leftovers unread** | Overnight-search quality. AutoHarness, HiL-Bench, ACC stages, Hermes kit — reopen the *source* when a Graduate needs it. Do not ingest 339 stubs. | V-001, V-008, V-013, V-014, vault `entities/papers/*` |
| **Unread X Articles + Sol packs** | Titles only. Prompt fashion. Skip unless we need examples of what people *ask* a harness to do. | XB-013, `x-bookmarks/ARTICLES.md`, ~150 uncarded bookmarks |
| **Wild / probably wrong** | CRIU-as-pause, Popcorn/AtomVM hands, Membrane token pipeline. Curriculum candy. JSONL + hibernate is the boring answer to “pause.” | H-146, H-148, H-149 |
| **Ore as contrast** | “Is this BEAM or just good harness taste?” is a valid later question. Ignore until we say so. | H-144, H-266 |
| **Human IEx on the brain** | Already specified as a client, full trust, dev-only. Not a product surface. No new claim. | H-037–H-038, H-088, H-115 |
| **apply_patch / udiff** | Commodity. Implement if the daily driver needs it. Not a BEAM bet. | H-113 |

---

## Refuse

Study-don’t-build as architecture, product hard-no, prompt theater, same-idea-other-VM with **no** leftover, photocopy, or Elixir advocacy. Lab may still *read* these; they are not research centers and not `arvo/` landing paths.

| Cluster | Why | Merged IDs |
|---------|-----|------------|
| **Horde / Oban / libcluster / Swarm as the architecture** | Filling silences we have not tried to fill with primitives. José: we should be embarrassed if the architecture needs them to exist. | H-005, H-130, H-264, atlas “study don’t build” |
| **OTP relups as the plugin story** | Wrong tool. Two-version modules + soft-purge after the turn is G-003. Relups are for a different problem. | H-131, H-033 |
| **Cookie as auth** | Shared cookie = unrestricted `:erpc` on the brain. Live instance: release cookie `"arvo_headless"`. Cookies can be *capabilities* only if per-session and narrow (that part lives under G-002). | H-012, H-132, H-175, H-245 |
| **MCP in core** | Foreign tool bus as the center is a fake distribution layer. 30 CVEs in 60 days in the vault notes. Edge-only (Port on hands) may still be Watch. | H-084, H-133, H-225, H-298, H-350, V-012 |
| **Plan / todo / permission popups as daily-driver identity** | Product hard-no. Fence is a location, not an allowlist. Lab may study plan-as-child-Session (G-005) without landing the chrome. | H-133, H-217, LC-007, P-007 permission modes |
| **Jido or Alloy *as* Session** | Cousins. Wrap actions (`jido_action` already). Don’t become LangChain-on-BEAM. Don’t let them own `start_turn`. | H-079, H-106, H-108, H-134, H-178, H-335 |
| **jido_harness / Port-wrap a TS CLI and call it native** | A shell, not an adaptation. The one rewrite we stay suspicious of. | H-107, H-200 |
| **Legion / Dune as the bash story** | They said it themselves: real isolation is another BEAM. AST sandbox is not the jail. | H-023, H-135 |
| **Phoenix LiveView as default UI** | Hard no. As a *lab* projector onto the same Session events, it is just another client (Translate surfaces). | H-076, H-136 |
| **HTTP / OpenCode clone as primary client/server** | The need is “a client attaches to a living brain.” The OTP move is another mailbox. | H-071, H-103, H-137, H-320 |
| **`eval` on the Session VM** | Includes “just IEx for RLM.” Recurse via a broker. Sandbox never sees keys. | H-091, H-138 |
| **Silent in-place compact that rewrites user-visible history** | JSONL does not die. Dual-view honesty is already product. | H-139, H-041, H-177 |
| **Feature race with Claude / OpenCode / Charm** | Personal lab, not a race. Chrome is not the object. | H-140 |
| **Photocopy / Elixir-LangGraph / “port the paper because it’s good”** | Adaptation, not transcription. If the graph is a supervisor plus messages, draw the tree. | H-141, H-317, H-331, LC-008 |
| **Vector DB / cross-project memory as the research center** | Same-session rings first. Auto-memory steers wrong (XB-015, V-006). | H-056, H-142, H-322 |
| **Multi-agent chat democracy** | No isolation story. Org chart ≠ architecture. | H-101, H-143, H-355, V-003 |
| **Ore in-scope** | Ignore unless we say so. | H-144 |
| **Plugin marketplace** | Hex, git path, local path are enough. | H-081 |
| **Arvo *is* a Livebook runtime; Focus is a Kino** | Steals the wrong layer. Livebook is the architecture paper for brains vs nodes, not a UI to become. | H-145 |
| **Elixir advocacy / “we have OTP so skip the papers”** | Smugness failure mode. The leftovers are the gold. OTP is the circled nouns. | H-330, H-315 |
| **Prompt theater / Sol packs / debate personas** | No leftover. Will not get better on BEAM. | H-307, XB-013, H-100 (as architecture) |
| **LeWorldModel as harness work** | Wrong field. | P-030 |
| **Building a fake OS in Elixir** | LangGraph / CrewAI / “agent OS” SDKs as a wishlist of *nouns* only. Implementing them on BEAM is simulating a simulation. | H-317, H-331 |

---

## Framing (Robert agreed 2026-08-14 — still not a Blueprint)

- **Success bar for *this* phase.** A catalog: the five headline experiments plus pattern cards. Not a working harness, not spikes in this repo. We do not need more papers.

- **Rigor.** **Focused.** On the five tests only: same model, leftover test slice, scorer is read-only, one main score. `research-program.toml` still says `standard` — flip it when the Blueprint is written.

- **Tracks (3).**
  1. **Runtime** — window vs brain, hands somewhere else, plugin swap (items 1–3).
  2. **Leftovers** — paper ideas we host on those primitives (not the headline five).
  3. **Score the harness** — overnight loop + specialized helpers (items 4–5).

- **Phase-2 repo.** New sibling when we run the first test. Not this research repo. Not `arvo/` as the experiment lab. Name TBD. Do not assume Arvo already works; a smoke check of the tree is part of standing that repo up.

If this still looks right, next legal *stage* is fill [`docs/00-program-blueprint.md`](../00-program-blueprint.md) in a **fresh** session. Do not treat this file as that Blueprint.
