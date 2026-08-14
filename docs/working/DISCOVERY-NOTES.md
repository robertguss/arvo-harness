# Living notes — Arvo / BEAM research program

**Blueprint (2026-08-14):** [`docs/00-program-blueprint.md`](../00-program-blueprint.md) — human accepted; accepting commit not yet recorded.

- **Repo:** [robertguss/arvo-beam-harness-research](https://github.com/robertguss/arvo-beam-harness-research)
- **Status:** Working notes. **Not** an accepted Blueprint or Charter.
- **Updated:** 2026-08-14 (rev 13 — Blueprint filled, not accepted)
- **Owner:** Robert Guss (with Thinking Partner, Research, Engineering)

This file is the system of record for *conversation so far*. Chat is not authority.

**Sort (2026-08-14):** [`SORT.md`](SORT.md) — five tests locked; framing agreed. Dump below is preserved. Discovery is **not** accepted.

**Next after human accepts and commits the Blueprint:** Charter, in a fresh session. Do not scrape more.

**Paper field guide (Front A intake):** [`ARXIV-WATCH.md`](ARXIV-WATCH.md) — P-001…P-026.

**LangChain / Trivedy:** [`LANGCHAIN-WATCH.md`](LANGCHAIN-WATCH.md). Harness-eval gospel next to José’s runtime gospel.

**Autoresearch → harness:** [`AUTORESEARCH-WATCH.md`](AUTORESEARCH-WATCH.md). Karpathy’s keep/reset loop with the *harness* as `train.py` and Harbor as `prepare.py`.

X bookmarks dumped 2026-08-14: 197 posts → [`x-bookmarks/`](x-bookmarks/) · cards [`X-BOOKMARKS-WATCH.md`](X-BOOKMARKS-WATCH.md).

**Laptop papers:** 6 PDFs in [`arxiv-home/`](arxiv-home/INDEX.md). Indexed as P-004, P-010, P-027–P-030. Readable natively (no markdown conversion).

**Obsidian vault (cloned 2026-08-14):** `../arvo-claw-obsidian-vault` — prior autoresearch on agent-harnesses + RLM/DSPy/GEPA. Map: [`VAULT-WATCH.md`](VAULT-WATCH.md).

---

## In one paragraph

Personal lab to push the BEAM as hard as possible for an agentic coding harness (Arvo). Hypothesis is José Valim’s: the runtime *is* the framework.

**What this work is (leaning locked, Robert 2026-08-14):** most agent innovation is happening in TypeScript and Python because that is what the researchers know. Elixir flies under the radar. People keep reinventing the BEAM, OTP, and primitives we get for free. A big part of this program is **seeing and naming those patterns**, then **experimenting with them on the real runtime**. Adaptation: stop simulating the OS; use it.

This repo catalogs theses. A later project tries them. Landing in `arvo/` is a third gate.

---

## Two programs (locked)

| Phase | Where | What we do | What we do *not* do |
|-------|--------|------------|---------------------|
| **1 — this repo** | arvo-beam-harness-research | Widespread research, ideation, hypotheses, a catalog of things to try | Spikes, evals, PRs into Arvo |
| **2 — later** | a new project (not stood up yet) | Implement experiments, measure, score, incorporate or drop | Invent the research agenda from scratch |

The template’s “implementation plan” in **phase 1** means: **ranked hypotheses + what we would measure + keep/drop criteria**. It does not mean code.

**Lab vs `arvo/` tree:** the lab may try things the *intended* refusal list forbids (MCP, plan mode, etc.). Copying into [coding-agent-harness](https://github.com/robertguss/coding-agent-harness) `arvo/` is a **separate gate**.

**Arvo is not Robert’s daily driver (locked 2026-08-14).** He does not use it now. He is not sure the features in the tree work. Older notes that say “daily driver” mean “the product-shaped codebase / intended stance,” not “the tool he works in every day.” Grounding snapshot = what the code looks like, not a verified product.

---

## Hypothesis (José)

[Tweet, 14 Aug 2026](https://x.com/josevalim/status/2088186994849468659) and follow-up [“the runtime is the framework”](https://x.com/josevalim/status/2088208133487264078):

1. Hot-code swap plugins (Pi-like) without dropping state
2. Client/server as a byproduct of actors (OpenCode-like)
3. Distribution isolates **brains** (model + session) from **hands** (sandbox + tools) — “this is basically how Livebook works”

Arvo was started on that bet. Today it spends a *thin* OTP slice: singleton Session, turn Task, in-process tools, plugin load via compile + path. Focus quit still halts the VM. That is the gap, not “pick Elixir.”

---

## Three research fronts (sequence leaning locked)

| Front | Question |
|-------|----------|
| **A** | What is cutting-edge in agentic / harness engineering (mostly Python / arXiv)? |
| **B** | Which BEAM primitives and runtime gifts can we push that are *native*? |
| **C** | How do we **translate** A into a BEAM-native move (not the same scaffold on a different VM)? |

Sequence leaning: **B** (squeeze native primitives) and **A** (papers / other harnesses) in parallel as *intake*. **C** is still the interesting question — *did BEAM change the idea?* — but it is not a gate that blocks a rewrite-shaped experiment.

**Rewrite rule — challenged 2026-08-14, no longer locked.**

Earlier notes said: if a paper is the same idea on another VM, it does not get an Elixir rewrite. Robert challenged that. The architect had applied a *product / graduation* filter at *intake*. That was too tight for a lab.

Working stance (leaning locked after Robert, 2026-08-14):

**The interesting move is adaptation**, not refusal and not transcription.

Papers will have ideas that may work *especially well* in Elixir if we adapt them onto processes, mailboxes, the code server, ETS, supervisors, Ports, and nodes. The host is allowed to change the idea. That is the point.

| Layer | Stance |
|-------|--------|
| **Intake / this dump** | Any paper/technique is welcome. Including “this might sing on BEAM if we reshape it.” |
| **Lab** | Adapt: keep the insight, change the substrate. A thin rewrite is allowed when that *is* the adaptation. Wrapping a foreign harness in a Port and calling it native is a shell, not an adaptation. |
| **After a try** | What got cheaper, clearer, or newly possible because of the runtime? If nothing, that is a result. |
| **Land in `arvo/`** | Separate product gate. |

José’s point cuts both ways: the building blocks make adaptation *cheap*.

---

## Central insight — they specified OTP, then faked an OS

**Leaning locked** (Robert: “crucial insight I have noticed as well,” 2026-08-14).

A lot of recent agent papers and harnesses accidentally specify **OTP**:

processes · mailboxes / queues · capabilities · sandboxes · reloadable skills · supervisors · checkpoints · child workers · attachable clients

…then they **build a fake OS** in TypeScript or Python (AgentProcess, job queues, capability tokens, in-process sandboxes, plugin hosts, memory pagers, HTTP “control planes”).

**Adaptation is: stop simulating the runtime; use it.**

This is José’s tweet seen from the paper side. He said the building blocks are already in the runtime. The literature is independently rediscovering those blocks and reimplementing them badly.

| They wrote | They meant (OTP) |
|------------|------------------|
| AgentProcess / agent runtime | Process + GenServer |
| Message queue / event bus | Mailbox |
| Capability token / ACL | Pid you were sent (and a node you cannot reach) |
| Sandbox / libOS / “runtime” | Port, hidden node, containerized node |
| Skill / plugin hot reload | Code server, two-version modules |
| Supervisor / orchestrator | Supervisor, application |
| Checkpoint / snapshot | JSONL + `:sys` / state |
| Sub-agent / fork | Child process or child node |
| Control plane / HTTP server | Another client of the same process |
| Memory store / pager | ETS, `persistent_term`, files |
| Job queue | Task + supervisor (or just send) |
| Graceful cancel | Monitor + kill + a cancel message |
| Worker pool | Cheap processes; maybe a Task.Supervisor |

**What this is not:** “Elixir is better, skip the papers.” The papers still have the *insights* (what to page, when to compact, how to evolve a prompt, what an ACI should be). They just keep inventing a worse Erlang to host them.

**What this is not:** “OTP is already a harness.” Arvo today only spends a thin slice. The gap is *using* the OS they keep specifying.

**Why TS/Python keep winning the narrative:** that is the water the labs swim in. The ideas are often good. The host is a habit, not a proof. Our job is not to dunk on the habit. It is to **spot the reinvented primitive**, keep the new policy/insight, and try it where the primitive is native.

**This phase vs later**

| Now (this repo) | Later (experiment project) |
|-----------------|----------------------------|
| See the pattern. Name their noun → our noun. Keep the underlined insight. | Try the adaptation. See if it gets cheaper, clearer, or newly possible. |

Discovery is pattern recognition. Experiment is belief-testing. Both are the work. Neither is “rewrite Arvo this week.”

---

## Idea shelves (proposed)

Looser *intake* so Python-heavy papers survive. Not a looser *graduation* bar.

| Shelf | Meaning |
|-------|---------|
| **Watch** | Paper or primitive; no translation yet |
| **Translate** | We have a BEAM-shaped hypothesis (C fired) |
| **Graduate** | Ready for the experiment project: claim, what we’d measure, what “land in Arvo” means |

Most ideas should stay on Watch. That is success.

---

## Candidate spikes (not a backlog — evidence for later)

From Engineering + Research, synthesized. **No coding until phase 2 / a greenlight.**

1. **E2 — Focus as disposable client.** Already unlinked (`Task.start`). Real work: stop `:halt_on_focus_quit`; Session must not know a TUI module (cast/send only). Quit tile ≠ kill brain. Human IEx attach can sit beside this (dev-only, full trust).
2. **E3-thin — hidden hands node.** Port or `:peer`, `--hidden`, per-session cookie, narrow API, **no secrets on hands**. `:erpc read` only. Kill the node; Session + JSONL live. Shared cookie = unrestricted `:erpc` on the brain — do not do that.
3. **E1 — plugin hot-load.** `:code.load_binary` + ETS; Session mailbox stays. Tools aimed at hands; slash/UI on brain. Not OTP relups. Not mid-turn. Not the FFF NIF.
4. **E3-bash.** Same protocol; node in **Docker**. Hidden BEAM ≠ bash jail.
5. **IEx / RLM — two products.**
   - **Human IEx** on the **brain** (live debug, patch). Dev-only.
   - **Agent RLM** ([arXiv:2512.24601](https://arxiv.org/abs/2512.24601)): prompt as data in a REPL + recursive `llm_query`. Official impl is **Python**. Default: Port that env in Docker on hands. **IEx-as-RLM only if the context is BEAM-shaped** (ETS, Session dumps, mailboxes). “We’re Elixir so the REPL is IEx” is not a reason. Never `eval` on the Session VM. Recurse via a broker so the sandbox never sees API keys.

### Hard nos (for Arvo product; lab may still *study* them)

Horde / libcluster / Oban as the architecture; MCP in core; Jido or Alloy *as* Session; Legion/Dune as the bash isolation story; relups for plugins; attached Phoenix as default; cookie as auth; permission popups / plan / todo in the daily driver.

---

## What others spent (so we don’t redo them)

| System | What they used BEAM for | Not a harness |
|--------|-------------------------|---------------|
| **Livebook** | Brains vs Port-spawned / attached / remote nodes. Architecture paper: `runtime/standalone.ex` | Notebook, not an agent |
| **Tidewave** | IEx-for-the-agent *inside the target app* (`project_eval`). MCP. Docker is the real fence | Runtime intelligence, not Arvo |
| **Alloy** | Minimal OTP agent *loop* | Don’t let it own `start_turn` |
| **Jido** | Native Elixir agents | Study; don’t become LangChain-on-BEAM |
| **jido_harness** | Wraps TS CLIs (Claude Code, etc.) | Anti-pattern *for Arvo* |
| **Legion / Dune** | In-VM AST / eval sandbox | They say: real isolation = another BEAM |
| **Pi** | `/reload` recycles the extension process | Not BEAM hot-swap |
| **OpenCode** | HTTP client/server | José means message-passing is cheaper, not “build Hono” |

---

## Discovery status

Interview paused after an **ideation dump**. First sort is in [`SORT.md`](SORT.md). Do not accept Blueprint until framing is approved *and* Robert says the sort is right.

| # | Topic | State |
|---|--------|--------|
| 1 | Problem | **Locked:** personal lab; José hypothesis; learn + catalog; not compete |
| 2 | Done-enough for *this* phase | **Locked:** open-ended research; output is a collection of hypotheses; spikes are the *next* project |
| 3 | Graduation bar | **Headline five locked** (Robert 2026-08-14). Loose intake still; most ideas stay on Watch. |
| 4 | Work sequence | **Sort + framing agreed.** Blueprint next, fresh session. |
| 5 | Edification | **Revised:** papers and other harnesses are in-scope to *learn and to try*. A same-VM-idea Elixir rewrite is allowed as a lab experiment. Not automatic as an `arvo/` landing. |
| 6 | Working method | **Locked:** braindump of theses / theories / hypotheses. Papers + harness techniques + squeeze BEAM primitives. No testing design, no spike planning, no Blueprint until Robert wants to sort. |
| 7 | Rewrite rule | **Challenged / unlocked.** Adaptation is the verb. |
| 8 | Central insight | **Leaning locked:** papers specify OTP, then fake an OS in TS/Python. Stop simulating the runtime; use it. |
| 9 | Program purpose | **Leaning locked:** discover reinvented-BEAM patterns in TS/Python innovation; experiment with them on the real runtime. Elixir flies under the radar; that is an opportunity, not a complaint. |

Framing leftover from the dump is **agreed** in [`SORT.md`](SORT.md) (focused, three tracks, new sibling repo, catalog as success). Not yet copied into the Blueprint.

---

## Repos

| Repo | Role |
|------|------|
| [arvo-beam-harness-research](https://github.com/robertguss/arvo-beam-harness-research) | **This program** (created from the template 2026-08-14). `just init name="arvo-beam-harness-research"` run 2026-08-14. |
| [artifact-driven-research-program](https://github.com/robertguss/artifact-driven-research-program) | **Template only.** Do not land program notes here |
| [coding-agent-harness](https://github.com/robertguss/coding-agent-harness) `arvo/` | Product-shaped Elixir harness **in the tree**. Not Robert’s daily driver; features unverified. **Local:** `../coding-agent-harness`. Ignore `ore/` unless we say so |
| [arvo-claw-obsidian-vault](https://github.com/robertguss/arvo-claw-obsidian-vault) | Prior OpenClaw/Obsidian library. Autoresearch runs on harnesses + RLM/GEPA. **Local:** `../arvo-claw-obsidian-vault` |
| [alexzhang13/rlm](https://github.com/alexzhang13/rlm) | Official RLM (Python REPL) |

---

## Next (research, not spikes)

1. **Now:** fill the Blueprint in a **fresh** session. Start with root [`HANDOFF.md`](../../HANDOFF.md).
2. `just init` already done (2026-08-14). Do not accept discovery in the writing session.

Prior ideation in the *product* repo (do not treat as this program's authority): `coding-agent-harness` `docs/ideation/` (2026-07-27) and ADR-0001/0002. This dump may repeat those ideas so they live here.

---

## BEAM primitive atlas (draft — research only)

Only primitives that can change an agent loop. Not a tour of OTP.

### Isolation
Process, Port, hidden node, Docker. Links vs monitors. `spawn_monitor` + `max_heap_size` + timeout + `:brutal_kill`.

- **Hypothesis:** the fence is a *location* (process / VM / container), not an allowlist.
- **José mapping:** brains vs hands.
- **Shelf:** Translate (already have a BEAM-shaped claim).

### Liveness
Code server (`:code.load_binary`, two-version modules), iex attach, observer / telemetry.

- **Hypothesis:** Session can outlive the tile *and* the plugin code.
- **José mapping:** Pi-like plugins + “runtime is the framework.”
- **Shelf:** Translate.

### Attention-as-topology
ETS / cold evidence, `:pg` / Registry, hibernate, mailbox priority.

- **Hypothesis:** hot / warm / cold is a process layout, not only a prompt policy.
- **Shelf:** Watch → Translate (needs a sharper claim).

### Concurrency policy
Sequential tools is a product choice because processes are cheap. Parallel tool children. Dirty schedulers / NIFs (FFF already exists).

- **Hypothesis:** we can *measure* whether parallel tools help because of BEAM, not because we copied a thread pool.
- **Shelf:** Watch.

### Study, don’t build as architecture
Horde, Oban, relups, PubSub-for-its-own-sake. Allowed on Watch.

### Watch-shelf papers (edification; no translation yet)
- RLM — [arXiv:2512.24601](https://arxiv.org/abs/2512.24601)
- GEPA — DSPy genetic-Pareto prompt optimization (paper/notes TBD)
- Others as Robert drops links

---

## Idea dump (unsorted) — 2026-08-14

Working catalog. **Not prioritized. Not shelves. Not a backlog.** Temporary IDs `H-001…` so we can sort later without losing items. These are *not* `REC`/`REQ`/`FND`.

Each line: **claim**. Clusters are for reading, not ranking. Repeats from earlier notes and from `coding-agent-harness` `docs/ideation/` are kept on purpose.

### José's three bets, exploded

- **H-001** Hot-code swap of plugins can look like Pi `/reload` without recycling a process: `:code.load_binary` / two-version modules, Session mailbox stays.
- **H-002** Client/server is a byproduct of actors: Focus, NDJSON, IEx, a remote tile are *clients of Session*, not an HTTP server we invent.
- **H-003** Brains (model + session + keys) and hands (sandbox + tools) are *locations*. Distribution is how Livebook already does this (`runtime/standalone.ex`).
- **H-004** One Session can coordinate **multiple** hands nodes (José's explicit example). That is the BEAM-shaped multi-agent, not a chat democracy.
- **H-005** "The runtime is the framework" means we should be embarrassed if the architecture needs Horde, Oban, Phoenix, or LangChain-on-BEAM to exist.
- **H-006** Arvo already placed this bet and spends a thin OTP slice (singleton Session, turn Task, in-process tools, compile+path plugins, Focus quit halts the VM). The research object is **that gap**.

### Isolation — where the fence lives

- **H-007** The fence is a location (process / Port / hidden VM / container), not an allowlist. Product hard-no on permission popups is the same idea in UX clothes.
- **H-008** Tool = `spawn_monitor` + `max_heap_size` + timeout + `:brutal_kill`. Crash or OOM a tool; Session lives.
- **H-009** Links are for "this death should take me with it." Monitors are for "I need to know." Today's Focus↔Session coupling is probably the wrong one.
- **H-010** **E2:** Focus is a disposable client. Stop `:halt_on_focus_quit`. Session must not know a TUI *module* (cast/send only). Quit tile ≠ kill brain.
- **H-011** **E3-thin:** hidden hands node (`:peer` or Port-spawned), `--hidden`, per-session cookie, narrow API, **no secrets on hands**.
- **H-012** Shared cookie = unrestricted `:erpc` on the brain. That is not a fence. Do not do that.
- **H-013** Hands API is *capability-shaped*: `read` / `write` / `bash` / `glob` / `grep`. No `eval`, no code load, no `:erpc` back to brain.
- **H-014** Brain may call only `Hands.API.*`. Hands never holds the Session pid.
- **H-015** Unforgeable pids are already an object-capability system. The bug is giving hands too big a pid.
- **H-016** **E3-bash:** same protocol, node inside Docker. Hidden BEAM ≠ bash jail. Both layers, different threats.
- **H-017** `:erpc` on hands is read-only and allowlisted. Anything else is a custom GenServer protocol we own.
- **H-018** `nodedown` fails in-flight tools and leaves Session + JSONL intact.
- **H-019** Per-turn or per-role capability grant: explore node is read-only; implementer node may write; network-denied node cannot egress.
- **H-020** Two hands for one brain: repo-local (fast, trusted-ish) vs sandbox clone / worktree (destructive).
- **H-021** FLAME / Fly machines as *elastic hands* is a José mapping worth studying, not a day-one architecture.
- **H-022** Firecracker / gVisor / E2B / Daytona / Modal are "where hands can live," not frameworks.
- **H-023** Legion/Dune said it themselves: real isolation is another BEAM, not an AST sandbox. Study; don't make them the bash story.
- **H-024** NIFs (FFF) belong on hands, never on the brain VM. A dirty-scheduler crash must not take Session with it.
- **H-025** Plugin-supplied NIFs / Port drivers are a hands-only privilege.
- **H-026** WASM plugins (`wasmex`) are an isolation hypothesis *competing with* hidden nodes — measure later, don't assume.

### Liveness — what is allowed to die

- **H-027** Session outlives the tile, the plugin code, a turn Task, a hands node, and a compact worker.
- **H-028** `arvo up` / `arvo attach` / `arvo detach` is the product shape of "runtime is the framework" (`run_erl` / `to_erl` / heart, Livebook-family).
- **H-029** `os_signal`: window close and SIGTERM stop Focus, not the VM. `halt` is a bug if a Session is alive.
- **H-030** Supervision: Session `permanent`, Focus `temporary`, turn Tasks `temporary`, hands `transient`, plugin children `temporary`.
- **H-031** Chaos hypotheses to score later: kill Focus; kill hands; flood mailbox; load plugin mid-session; atom-table pressure. Session + JSONL survive.
- **H-032** JSONL is the crash boundary. A VM crash is allowed; a silent history loss is not.
- **H-033** `:code.load_binary` + ETS for plugin hot-load (**E1**). Not OTP relups. Not mid-turn. Soft-purge after the in-flight turn finishes (two-version modules).
- **H-034** Skills, profile TOML, and constitutions hot-swap without a Session restart. Code swap is the special case.
- **H-035** `on_load` in plugins is hostile. Reject or isolate.
- **H-036** Unbounded `String.to_atom` from plugin/tool names will kill the VM. Binaries / existing atoms only.
- **H-037** Human IEx attaches to the **brain**, full trust, dev-only. That is a client (H-002), not a product surface.
- **H-038** `remote_console` / Garnish / SSH-into-node are "second Focus," not a new architecture.
- **H-039** Heart + systemd user service: the brain is a daemon you happen to look at with a TUI.

### Attention as topology (not only a prompt policy)

- **H-040** Hot / warm / cold is a *layout*: budgeted messages; structured work-delta; immortal JSONL (+ optional Keeper processes).
- **H-041** Compaction changes what the model sees, never what exists. JSONL does not die.
- **H-042** Handoff (new session + work-delta packet) is the honest overflow story; in-place LLM summary is the commodity story we distrust.
- **H-043** Keepers are dumb addressable stores under Session policy. Crash of a Keeper ≠ death of Session. They are not a second agent framework.
- **H-044** ETS (or `:disk_log` + ETS index) is the addressable id→body map. Off-heap binaries for large tool results.
- **H-045** `persistent_term` for immutable constitution / skill index; ETS for warm; process state for the live turn; JSONL for cold.
- **H-046** Mailbox *length* and reduction pressure are signals for "context is too hot," not only tokenizer counts.
- **H-047** Selective receive / message priority: Esc and steer jump the queue ahead of tool results and stream tokens.
- **H-048** Hibernate idle Sessions. A parked brain should be cheap.
- **H-049** `:pg` / Registry is how surfaces and Keepers are found, not PubSub-for-its-own-sake.
- **H-050** Dual view is already a product concept: human transcript can be rich; model hot is progressive. Honesty = label what the model saw.
- **H-051** Attention evidence stream is the eval seam: the same access decisions the TUI shows can score Harbor-style evals.
- **H-052** Skills and cold memory are one idea — **progressive context**: metadata always, body on demand.
- **H-053** Recall is the inverse of compact. Policy + user `/recall` before a model-owned recall tool.
- **H-054** Structural prune + deterministic work-delta first; narrative LLM summary only as backup.
- **H-055** Content-addressed cold store: identical reads/tool bodies dedup. Cheap, testable, not a vector DB.
- **H-056** Cross-session memory and vector DBs stay off the table until same-session rings are honest.
- **H-057** HEAD of the session tree must not be confused with HEAD of git.

### Concurrency and the topology of work

- **H-058** Sequential tools is a *product* default, not a BEAM limit. Parallelism is allowed because processes are cheap, not because we copied a thread pool.
- **H-059** Parallel *pure* tools (read/search) under `Task.Supervisor`; write/bash serial; Esc kills the group.
- **H-060** Per-path single-writer processes: two writes to the same file never race; reads may fan out.
- **H-061** Turn group = stream reader + tool children + compact worker. Esc = group shutdown + cancel-as-fork node.
- **H-062** Best-of-n / fallback model = parallel completion processes with a chooser, not a prompt trick.
- **H-063** Speculative prefetch (read-ahead of likely files) is a process you can kill, not a smarter prompt.
- **H-064** Reduction fairness: a hog tool must not starve Focus paint. Measure; don't casually bump process priority.
- **H-065** Explore spawn is a **child Session or hidden node**, not a nested prompt. Readonly constitution.
- **H-066** Pair / critic / judge are processes with a narrow mailbox (read evidence, emit a note). They do not own `start_turn`.
- **H-067** Worktree-per-session + hands node-per-worktree is the Loopyard-shaped idea. Study Loopyard; don't swallow it.
- **H-068** Dirty schedulers already pay for FFF. More native work copies that pattern or it stays on hands.

### Surfaces are clients

- **H-069** One Session, many clients: Focus, line Repl, NDJSON, IEx, Garnish, a future web tile. One HEAD, one turn, one Esc domain.
- **H-070** Session must not import a TUI module. Events out, commands in. TUI is a projector.
- **H-071** Unix socket speaking ETF or JSONL is a reasonable *local* attach. HTTP à la OpenCode is the thing José said we get for free and should not rebuild.
- **H-072** Event schema + projectors (TUI, NDJSON, telemetry, attention evidence) deletes dual-path rot.
- **H-073** Herdr / ephemeral panes are workspace chrome, not the agent tile, not a sub-agent primitive.
- **H-074** Esc and HEAD jump must tear down Arvo-owned panes so processes do not outlive abandoned branches.
- **H-075** A second human can attach read-only (Observer-like) without stealing the turn mutex.
- **H-076** Phoenix LiveView as default UI is a hard no. As a *lab* projector onto the same Session events, it is just another client.

### Plugins and profiles as the machine

- **H-077** Profile switch set-diffs the **supervision tree**, not only the tool menu. Switching profile changes the machine.
- **H-078** One real OTP child per flagship profile first (indexer, watcher). Not an arbitrary multi-agent host.
- **H-079** Plugins ship tools, slash, hooks, skills. They never own the agent loop. Alloy/Jido must not become Session.
- **H-080** Hooks are observe-only. That is how we stay off permission rails and MCP-in-core.
- **H-081** Hex packages, git path, and local path are all valid *plugin sources*. A marketplace is not.
- **H-082** Mix.install plugins are a workshop luxury; a hands release should load `.beam` only.
- **H-083** Slash commands can be Mix tasks on the brain. Tools cannot.
- **H-084** MCP, if ever, is a Port adapter **on hands**, behind a profile, never in core.
- **H-085** Tidewave-style `project_eval` is a *plugin for the target app*, not an Arvo primitive. Docker remains the fence.
- **H-086** ElixirLS / Mix test / Dialyzer / Credo are tools a profile may start as children, not core identity.
- **H-087** Constitution (model, max_turns, handoff threshold, skill set, tool versions) lives in `persistent_term` and is hot-reloadable.

### REPL, RLM, and "just eval it"

- **H-088** Human IEx on the brain ≠ agent RLM. Two products. Never confuse them.
- **H-089** Official RLM is Python ([arXiv:2512.24601](https://arxiv.org/abs/2512.24601), [alexzhang13/rlm](https://github.com/alexzhang13/rlm)). Default: Port that env in Docker on **hands**.
- **H-090** IEx-as-RLM only if the working set is BEAM-shaped (ETS, Session dumps, mailboxes). "We're Elixir so the REPL is IEx" is not a reason.
- **H-091** Never `eval` on the Session VM. Recurse via a broker so the sandbox never sees API keys.
- **H-092** Progressive attention (H-040–H-056) and RLM are competing answers to "context is too big." Measure; do not merge them by slogan.
- **H-093** A BEAM-shaped RLM would treat Session/ETS/JSONL as the REPL's data, and `llm_query` as a message to the brain — not `Code.eval_string` in Session.
- **H-094** Livebook as the **phase-2 experiment notebook** (not as Arvo's UI) is a cheap way to steal their runtime story.

### Papers and other systems (intake, no translation yet)

- **H-095** RLM — REPL as working memory; recursive `llm_query`.
- **H-096** GEPA — genetic-Pareto prompt/constitution evolution. Edify; do not port DSPy.
- **H-097** CodeAct / SWE-agent ACI — action interface design. Ask: does BEAM change the *interface* or only the host?
- **H-098** Aider repo map / tree-sitter / Sourceror — repo orientation. Translation only if ETS/process layout beats a markdown map.
- **H-099** MemGPT / Letta / OS-as-agent — paging memory. Likely collapses into H-040 or is same-idea-other-VM.
- **H-100** ACE / reflexion / self-consistency — prompt-loop tricks. Watch; translation bar is high.
- **H-101** AutoGen / MetaGPT / CAMEL / ChatDev / "multi-agent debate" — study isolation stories, refuse as Arvo architecture.
- **H-102** Pi — tiny core, JSONL trees, `/reload` recycles the extension process. Our delta is *not* recycling the process.
- **H-103** OpenCode — HTTP client/server. Our delta is message-passing, not Hono.
- **H-104** Claude Code / Codex / Cursor background agents — isolation = VM/container; plan/todo/MCP are product refusals we may still *study*.
- **H-105** Harbor / Terminal-Bench / SWE-bench — phase-2 scoreboard, not this repo's work.
- **H-106** Jido / Jidoka — native Elixir agents; cousin; don't become LangChain-on-BEAM.
- **H-107** jido_harness wrapping TS CLIs — anti-pattern *for Arvo*.
- **H-108** Alloy — minimal OTP loop. Don't let it own `start_turn`.
- **H-109** Livebook — architecture paper for brains vs Port-spawned / attached / remote nodes.
- **H-110** Tidewave — IEx-for-the-agent inside the target app; MCP; Docker is the fence.
- **H-111** Loopyard — branch-per-agent in Docker Compose. Compare, don't merge.
- **H-112** Prompt caching / prefix breakpoints as a first-class harness concern (provider-shaped, maybe not BEAM-shaped).
- **H-113** apply_patch / udiff vs whole-file write — commodity; implement if daily-driver needs it, don't research it as a BEAM bet.

### Observability as curriculum

- **H-114** `:telemetry` for TTFT, tool wall time, cancel latency, plugin reload time, compact savings, profile switch. Status strip is a projector.
- **H-115** `:sys.get_state` / Observer / recon on the brain is a workshop privilege. That *is* the framework.
- **H-116** Deterministic replay: log Session messages, replay against a fake provider. Property-test the protocol (`StreamData`).
- **H-117** Time-travel is HEAD navigation plus replay, not a new debugger product.
- **H-118** `LocalCluster` / `:peer` tests are how we *specify* brains vs hands before we believe it.
- **H-119** Livebook + Kino as the experiment dashboard in phase 2.

### Measurement ideas (phase 2 — write them now so they exist)

- **H-120** Kill Focus: Session pid alive, JSONL appendable, a new client can attach and continue.
- **H-121** Kill hands node mid-tool: brain survives, keys not on the dead node, next tool can start a new node.
- **H-122** Plugin reload: mailbox doesn't drop; in-flight turn finishes on old code; next turn sees new tools.
- **H-123** Hands cannot read `XAI_API_KEY` / cookie / Session state (negative test).
- **H-124** Parallel pure tools vs sequential: wall time *and* error rate on a Harbor-like task. Credit BEAM only if topology is the variable.
- **H-125** Handoff vs in-place compact vs RLM vs "just 1M context": same tasks, score recovery after overflow.
- **H-126** Hidden-node overhead vs in-process tools vs Docker node: latency, isolation, operational pain.
- **H-127** Mailbox growth, atom table, and Resident memory of Keepers vs JSONL-only.
- **H-128** Attach/detach cycle: does `arvo attach` feel like tmux, or like restarting Claude?
- **H-129** Same eval, two topologies (not Arvo vs Ore unless we say so). Language is not the variable.

### Anti-hypotheses (ideas we write down so they don't sneak back)

- **H-130** Horde / libcluster / Swarm / Oban as the architecture.
- **H-131** OTP relups as the plugin story.
- **H-132** Cookie as auth.
- **H-133** MCP in core; plan mode; todo tool; permission popups; write confirmations.
- **H-134** Jido or Alloy *as* Session.
- **H-135** Legion/Dune as the bash isolation story.
- **H-136** Attached Phoenix as default.
- **H-137** HTTP API as the primary client/server design (OpenCode clone).
- **H-138** `eval` on the Session VM, including "just IEx for RLM."
- **H-139** In-place silent compaction that rewrites user-visible history.
- **H-140** Feature race with Claude Code / OpenCode / Charm on chrome.
- **H-141** Porting a paper to Elixir because the paper is good.
- **H-142** Vector DB / cross-project memory as a research center.
- **H-143** Multi-agent chat democracy without an isolation story.
- **H-144** Treating Ore as in-scope (ignore unless we say so).

### Wild / probably wrong / still write them

- **H-145** Arvo *is* a Livebook runtime; Focus is a Kino. (Probably wrong; steals the wrong layer.)
- **H-146** CRIU / disk hibernation of a BEAM as "pause this agent." (Probably wrong; JSONL + hibernate is enough.)
- **H-147** Luerl / a tiny language on hands as the plugin VM instead of another BEAM.
- **H-148** Popcorn / AtomVM as ultra-light hands. (Curriculum candy; likely a trap.)
- **H-149** Membrane as the token stream pipeline. (Joke until it isn't.)
- **H-150** One agent Session coordinating a *fleet* of project nodes the way Livebook coordinates runtimes — José already said this; we have not believed it yet.
- **H-151** GEPA evolving the *constitution TOML* against Harbor scores as a phase-2 loop. The harness is the organism; GEPA is the breeder.
- **H-152** The daily-driver refusal list is a *lab menu*: every hard-no is a Watch item we may spike in the experiment project and still never land in `arvo/`.

### Already-in-Arvo ideas to keep in the catalog (so they have IDs)

- **H-153** Singleton Session owns identity, JSONL, product turn Task, cancel, usage.
- **H-154** Product turn is a supervised Task; surfaces do not own persist or Agent lifetime.
- **H-155** HEAD is an explicit pointer via `head_move`, not the last file line.
- **H-156** Cancel-as-fork; tree navigator; idle-only identity rewrites (`turn-busy`).
- **H-157** Handoff is one idle-only Session transaction.
- **H-158** Focus claim is a UI mutex; it must not deadlock with Session-driven paint.
- **H-159** Context firewall: large tool results stub in hot, full body in cold.
- **H-160** Agent tile ≠ workspace chrome. Arvo is one tile, not an IDE.
- **H-161** Profiles = named plugin bundles on top of `base`. Profile is the product unit.
- **H-162** Core speaks req_llm types (ADR-0002). Own experimental seams only.
- **H-163** Elixir/BEAM is the curriculum (ADR-0001), not the faster TUI choice.

---

*Dump is open. Add `H-164+` rather than editing history. Sort pass comes after Robert says the well is dry.*

---

## Grounding snapshot — local Arvo (`../coding-agent-harness/arvo`, 2026-08-14)

Inspected the sibling checkout. This is **what the tree does today**, not what we wish. Earlier `H-###` lines that assumed a thinner product (attention as future, no second client, etc.) should be read against this.

### Supervision and boot

- App children, `one_for_one`: `Providers.Registry`, `Auth.TokenManager`, `Plugins.Supervisor`, `Plugins.Registry`, `Session`, `TUI`.
- Product boot is `bin/arvo` → `mix run --no-halt`. That is why Focus quit must stop the VM or you get a headless zombie.
- Focus is started with **`Task.start`** (unlinked) from `Application.maybe_start_interactive/0`. It is **not** a supervisor child.
- `:halt_on_focus_quit` defaults **true** → `System.stop/1`. Tests force false. Repl also `System.stop`s on quit.
- Headless already exists: `ARVO_HEADLESS` / `ARVO_MODE=chat|headless`, plus `bin/arvo-chat` (`Arvo.CLI.Chat`). No Focus, no auto-resume. Harbor path.

### Session / turn

- Named singleton GenServer. `Process.flag(:trap_exit, true)`.
- Product turns: `Session.start_turn` → **`Task.async`** (linked to Session) → `Agent.run`. Not a `Task.Supervisor`.
- `Agent` is **not a process**. Tools run **sequentially, in-process**, inside that turn Task via `Arvo.Tool.invoke`.
- Bash is `Task.async` + `System.cmd("bash", ["-c", …])` — same user, same VM, nested linked task. Timeout uses `Task.shutdown(..., :brutal_kill)`.
- Esc = `Task.shutdown` + cancel-as-fork leaf + pane teardown. Session stays.
- JSONL append-only + explicit HEAD + handoff + `/compact` as a **power** tool. Silent auto-compact **off** unless `:auto_compact` / `force: true`.
- Auto-resume last resumable same-cwd session on boot; re-applies profile by name.

### Session ↔ TUI coupling (the interesting rot)

- Focus injects `event_fun` that calls `Arvo.TUI.handle_event/1` (cast). Session wraps it so UI failures cannot kill the turn.
- Session **still names** `Arvo.TUI`: `put_tokens`, `put_attention_mode`, `put_access_chrome`, and `GenServer.cast(Arvo.TUI, {:set_live_panes, _})`.
- TUI **calls Session synchronously** from slash, Esc, tree jump, and `load_live_panes/0`. Documented deadlock: `docs/solutions/logic-errors/session-tui-genserver-reverse-call-deadlock.md`.
- They already know: Session must not `call` TUI (AB-BA). They have not inverted the remaining TUI→Session pulls.

### Attention — shipped, not a wish

- Progressive attention is product-default-on. Policy + cold sidecars + warm map + audit JSONL + dual-view chrome + `/inspect` `/recall`.
- Cold is **files**: `<session>.cold/<id>.body` + `index.jsonl`, sha256 digest. Not ETS. Not Keepers.
- Warm is a **map in Session state** (paths, last commands, last error, failures, optional goal). Deterministic updates from tools.
- Keepers are **parked**. Audit has residual-need metrics and will not auto-unpark.
- Harbor suite `evals/arvo-attention-reread/` scores honesty / stub+reuse / hot waste from `*.audit.jsonl`. Mix **release tarball** is the Harbor artifact.

### Plugins / profiles / FFF

- Load path: `mix compile` in the plugin dir + `Code.append_path` + `Module.concat` / `String.to_existing_atom` on `*Plugin.beam`.
- Activate starts `manifest.children` under `Plugins.Supervisor` (`DynamicSupervisor`, one_for_one), registers tools/skills/namespaced slash.
- Profile switch is set-diff activate/deactivate. `base` always on.
- Trust (`~/.arvo/trust.json`) gates **project-local plugin dirs**. Project *profile name* in `.arvo/config.toml` still auto-activates; bundled/global plugins load on untrusted projects.
- FFF is **bundled into `:arvo`** (`otp_app: :arvo`, Rustler NIF). `Fff.Plugin.activate` is `Code.ensure_loaded(Fff.Native)`. `children: []`. The flagship plugin is a NIF on the **brain** VM.

### Isolation that is not there

- No `Node`, no `:peer`, no hidden cookie-per-session. Distribution appears only as release `cookie: "arvo_headless"`.
- No Docker/hands node. Containerization is the *philosophy* line, not a runtime.
- Herdr panes are a **CLI subprocess** to a multiplexer, registered on Session, torn down on Esc/HEAD/cancel. Workspace chrome, not a tool jail.
- Auth tokens live in the same VM as bash and FFF (`TokenManager`, `~/.arvo/auth.json`).
- `jido_action` is the tool schema wrapper (ADR-0002). Jido does not own Session.

### Two clients already

| Client | How it dies | Shares Session? |
|--------|-------------|-----------------|
| Focus (`Task.start` + Termite) | `System.stop` on quit | Yes, in this VM |
| `arvo-chat` (headless) | `System.halt` after one turn | Own boot, no attach-to-live-Session |

There is no `arvo attach` to a VM that already has a Session.

---

## Idea dump continued — from the local tree (`H-164+`)

Still unsorted. These are the ideas the *code* forced.

- **H-164** The turn isolation gap is `Task.async` (linked to Session) vs a `Task.Supervisor` of unlinked/monitor-only children. Session already traps exits; the link is leftover.
- **H-165** `mix run --no-halt` is why `:halt_on_focus_quit` exists. Attach/detach (`H-028`) is a *boot* change (daemon / release / `run_erl`), not a Focus flag.
- **H-166** Cold is already a content-addressed file store. Keepers, if ever, are a **cache over `<session>.cold/`**, not a new persistence story.
- **H-167** Harbor attention evals + audit JSONL are the existing scoreboard. Phase-2 topology experiments should emit the **same audit trail**, not invent a second eval religion.
- **H-168** `arvo-chat` already proves a second client. The missing José piece is: Focus quits and `arvo-chat` (or IEx, or a new Focus) attaches to the **same living Session**.
- **H-169** Session naming `Arvo.TUI` is the opposite of “events out, commands in.” Replace with a client registry (`:pg` / `Registry`) so headless has no TUI module in the beam.
- **H-170** TUI→Session synchronous pulls (`owned_panes`, slash that `Session.get`) are the documented deadlock class. Casts both ways, or a third projector process.
- **H-171** Bash is a nested `Task.async` under the turn Task. Brutal-kill of the turn may leave a `bash -c` orphan. Port or a hands node has a kill story; `System.cmd` does not.
- **H-172** Herdr pane teardown is the first real “extra processes for work.” It is chrome isolation, not tool isolation. Do not confuse them.
- **H-173** Plugin load hazard is **`mix compile` in the product VM**, not atom generation (`to_existing_atom` is already careful). Hot-load = drop Mix from the brain.
- **H-174** The first BEAM-native plugin (FFF) is a NIF on the Session VM. That is the worst possible placement for José’s brains/hands split.
- **H-175** Release cookie `"arvo_headless"` is a live instance of “cookie as completeness.” Delete or randomize before any node story.
- **H-176** Progressive attention is **shipped**. The open translation is whether hot/warm/cold becomes a process layout (ETS, Keepers, mailbox pressure) or stays maps+files inside Session.
- **H-177** Dual-view + attention chrome already teach the operator what the model saw. Any RLM/REPL idea must not undo that honesty.
- **H-178** `jido_action` in tree is the correct “wrap, don’t become” stance. Don’t spend research re-litigating Alloy/Jido-as-Session.
- **H-179** `one_for_one` already means TUI crash ≠ Session crash — but Focus lives **outside** the tree, so the supervisor cannot restart the tile. Either Focus becomes a temporary child, or attach is a new process.
- **H-180** Auto-resume is “session outlives the VM **via JSONL**.” José wants session outlives the **tile** inside a still-running VM. Both can be true; they are different bets.
- **H-181** `trust.json` is an allowlist for *plugin source*. Tool *execution* has no fence. Philosophy says containerization; code says `System.cmd`.
- **H-182** Untrusted projects still auto-activate a named profile’s bundled plugins. Trust is narrower than it sounds.
- **H-183** `event_fun` is a closure subscription. The BEAM version is `:pg` / Registry: Session broadcasts, any client joins. That is H-002 made literal.
- **H-184** `:atomics` in `Agent` for stream/thought flags is already a tiny BEAM-shaped hot-path trick. Curriculum is leaking in. Good.
- **H-185** Pane reapers (poll Herdr process-info, kill on empty) are Session-owned workers. Pattern to copy for tool timeouts — or to move *off* Session onto hands.
- **H-186** `/compact` still exists next to `/handoff`. The product prefers handoff; the code still has a summarizer. Lab may measure them; daily driver should not grow a third overflow story.
- **H-187** Headless Harbor runs a **Mix release with ERTS**. That is already a second packaging of the same brain. A hands release could be a *third* (tiny) release, not a rewrite.
- **H-188** TokenManager + bash + FFF + Session share one address space. Any “keys never on hands” test (H-123) fails **today** by construction.
- **H-189** `TurnContext.build()` is the single assembly site. A hands split should not fork this; it should send an already-built turn plan.
- **H-190** TTY detect shells out to `test -t 0`. Ports are already used for trivia. Bash jail via Port is not a new primitive, just a serious use.
- **H-191** Documented solutions (`trust-spine` races, Herdr ownership, TUI deadlock) are load-bearing. New topology must not re-break them. They are also evidence that OTP coupling is already the hard part.
- **H-192** Eval variable for this program: **same Harbor attention task, different topology** (in-process tools vs Port vs hidden node vs Docker node). Task success held constant; honesty + isolation + kill-Focus-lives as extra scores.
- **H-193** `Plugins.Supervisor` is stub-commented “walking skeleton” but it already starts children. Profile-as-machine (H-077) is a *depth* bet on this process, not a greenfield.
- **H-194** Skills are paths + progressive disclosure, not processes. A “skill process” would be invention unless a profile child is literally serving skill bodies.
- **H-195** Device-flow login runs *outside* the TUI GenServer mailbox on purpose. That’s the right instinct: blocking I/O is not Session, not TUI. Hands-shaped.
- **H-196** Same-cwd auto-resume + `mix run --no-halt` + halt-on-quit means the daily driver **never practices** a long-lived VM. The workshop cannot feel José’s bet until boot changes.

---

*Still open. Add `H-197+`. Sort after the well is dry.*

---

## Idea dump continued — papers, harness techniques, BEAM squeeze (`H-197+`)

Braindump only. Rewrite-shaped ideas are allowed. No test plans.

### The rewrite thesis (meta)

- **H-197** “Same idea, other VM” is a *claim we can try to falsify*, not a reason to skip the idea. The try may be a rewrite.
- **H-198** A rewrite that sits on processes, the code server, and distribution is not a transcription. The host is part of the idea.
- **H-199** Cheap rewrites are what José is selling. Refusing them would refuse the runtime’s gift.
- **H-200** The only rewrite we should still be suspicious of: wrapping a TS/Python harness in a Port and calling it native (`jido_harness` shape). That is a *shell*, not a rewrite.

### Papers / techniques worth stealing or retrying on BEAM

- **H-201** **RLM** ([arXiv:2512.24601](https://arxiv.org/abs/2512.24601)): prompt as data in a REPL; recursive `llm_query`. Try Python-in-Docker *and* a BEAM-shaped REPL over ETS/Session/JSONL. Both are legal. Compare.
- **H-202** **GEPA** ([arXiv:2507.19457](https://arxiv.org/abs/2507.19457)): genetic-Pareto prompt evolution via natural-language reflection on trajectories. Organism = constitution + system prompt + tool descriptions. Population of prompts as processes; Pareto front as an ETS table.
- **H-203** **ACE** — Agentic Context Engineering ([arXiv:2510.04618](https://arxiv.org/abs/2510.04618)): context as an evolving playbook of bullets (generator / reflector / curator). Playbook = ETS or a Keeper. Three roles = three processes, not three prompts in one loop.
- **H-204** **Meta-Harness** ([arXiv:2603.28052](https://arxiv.org/abs/2603.28052)): outer loop searches over *harness code*. Hot-swap is the mutation operator. The code server *is* the search space.
- **H-205** **Parallel context compaction** ([arXiv:2605.23296](https://arxiv.org/abs/2605.23296)): compact slices concurrently instead of one synchronous summary. BEAM makes “N compactors under a supervisor” boring. Commodity systems struggle here.
- **H-206** **Inside the Scaffold** ([arXiv:2604.03515](https://arxiv.org/abs/2604.03515)): 13 coding agents, 12 dimensions, **seven compaction strategies**. Use as a menu to steal from, not a taxonomy to implement.
- **H-207** Anthropic **context engineering**: compaction, just-in-time retrieval, tool-result clearing, file-based memory tool. Steal the *moves*. The file memory tool is just cold+recall with different branding.
- **H-208** **Frequent intentional compaction** (HumanLayer / Dex Horthy): keep the window 40–60% full on purpose; compact as a workflow, not an emergency. Handoff vs compact vs “small always” are three theses about the same pain.
- **H-209** **Codified context** ([arXiv:2602.20478](https://arxiv.org/abs/2602.20478)): hot constitution + specialist agents + cold spec docs. Maps almost 1:1 onto constitution / profile children / cold store.
- **H-210** **MemGPT / Letta / OS-as-agent**: page memory in and out. Try it. Maybe it collapses into rings. Maybe a process-per-page is actually better.
- **H-211** **Mem0 / tool-driven memory CRUD**: the model issues ADD/UPDATE/DELETE. That is a mailbox protocol. A Memory process with a tiny API.
- **H-212** Codex-style **background memory extraction**: phase-1 extractors in parallel, phase-2 consolidator. Parallel extractors are Tasks. Consolidator is one process. Stale prune is a sweeper.
- **H-213** Claude Code **prefix-cache religion**: keep the prompt prefix stable so cached tokens stay cheap. A BEAM thesis: Session is the cache key; don’t reshuffle system/tools mid-turn; plugin hot-swap is a *cache break* we can measure.
- **H-214** **Tool-result clearing** (Anthropic): drop old tool bodies from hot, keep the call. Already the context firewall. Thesis: clearing is a mailbox/ETS eviction, not a prompt rewrite.
- **H-215** **Skills / progressive disclosure** (agentskills.io): name+desc always, body on demand. Same shape as cold. One mechanism, two nouns.
- **H-216** **Hooks** (Claude Code): observe and intervene at lifecycle points. Observe-only vs mutate. Mutating hooks are a second agent. Observing hooks are telemetry + `:telemetry` attach.
- **H-217** **Plan mode / todo**: product hard-no, lab yes. Thesis: a Plan is just another Session with a different constitution, not a feature flag.
- **H-218** **Sub-agents**: commodity = nested prompt. Thesis: a sub-agent is a child Session or a hands node. Isolation is the idea; the prompt fork is a poor man’s node.
- **H-219** **Worktree-per-agent** (Cursor background, Loopyard, Claude worktrees): isolation via git + filesystem. Thesis: worktree + hands node is the BEAM version.
- **H-220** **MCTS / tree search over actions** (some scaffolds in 2604.03515): each branch is a process; the tree is a supervisor. Probably too cute. Write it down anyway.
- **H-221** **Best-of-n / self-consistency**: N completion processes, one chooser. The runtime makes this a one-liner. Measure whether it helps coding, not whether we can spawn.
- **H-222** **Speculative tool execution**: start likely reads before the model finishes talking. Stream tokens and a prefetch process race. Cancel the losers.
- **H-223** **Repo map** (Aider): AST / tags cache as persistent warm orientation. Sourceror + ETS. Or tree-sitter NIF on *hands*.
- **H-224** **Computer-use / browser / screenshot**: a hands node with a display. Not core identity; a profile.
- **H-225** **MCP**: lab may wrap it as a Port on hands. Thesis: MCP is a foreign tool bus. Native tools stay BEAM messages.
- **H-226** **A2A / AG-UI / LLMOS**: protocol weather. Watch. Don’t build a platform.
- **H-227** **Harbor / Terminal-Bench / SWE-bench**: the scoreboard we already have a foot in. New theses should be able to speak that language later — not now.
- **H-228** Lilian Weng **Harness Engineering** (2026-07): observability as the bottleneck of harness evolution. `:telemetry` + JSONL + Observer is our version of AHE.
- **H-229** **VeRO / agents-optimize-agents**: eval harness that tunes agents. Phase-2 cousin of GEPA/Meta-Harness.
- **H-230** **CodeAct**: the action language is code, not JSON tools. Thesis: on BEAM the action language could be a tiny message protocol *or* a sandboxed Elixir subset on hands. Try both.

### Squeeze the runtime (theses about primitives)

- **H-231** Everything interesting in a harness is already a BEAM noun: process, mailbox, monitor, link, Port, node, code server, ETS, persistent_term, `:pg`, supervisor, application, signal, cookie, NIF, dirty scheduler.
- **H-232** The agent loop is a **receive loop**. “While-loop + tools” is what you write when you don’t have mailboxes.
- **H-233** Esc is **preemption**, not a flag. A high-priority message and a kill. The runtime already has this.
- **H-234** Context pressure is **mailbox + heap + token budget**. Three gauges, one policy process.
- **H-235** Isolation is **where the pid lives**, stacked: process → Port → hidden node → container → machine. Each layer is a thesis we can try.
- **H-236** Distribution is how you draw a trust boundary without an allowlist. Livebook already did the homework.
- **H-237** The code server is a plugin host that predates plugins. Two-version modules = mid-turn safety.
- **H-238** ETS is the warm/cold index the Python world keeps rediscovering as “memory.”
- **H-239** `persistent_term` is the constitution. Immutable, cheap reads, explicit swap.
- **H-240** `:pg` / Registry is how clients find a Session. HTTP is a worse Registry.
- **H-241** Supervisors are profile activation. Start/stop a machine, not a menu.
- **H-242** Applications are bigger profiles. A “Phoenix profile” could be an OTP app.
- **H-243** Ports are the honest FFI: bash, ripgrep, Python RLM, MCP, Herdr.
- **H-244** Hidden nodes are disposable worlds. Kill the world, keep the brain.
- **H-245** Cookies are capabilities if they are per-session and narrow. Shared cookies are a master key.
- **H-246** Monitors are tool timeouts. Links are “this death is my death.” Most harness bugs are using the wrong one.
- **H-247** `max_heap_size` is an OOM fence for a single tool. Python people write supervisors in YAML for this.
- **H-248** Hibernate is a parked session. Cheap idle is a product feature (daemon brain).
- **H-249** Selective receive is steer/Esc jumping the queue. Prompt queues are a fake version.
- **H-250** `:telemetry` is the harness debugger. Status strip is a subscriber.
- **H-251** Observer / `:sys.get_state` / recon is the operator UI we get for free. Other VMs buy APM.
- **H-252** `run_erl` / `to_erl` / heart is attach/detach. tmux for BEAM.
- **H-253** FLAME is elastic hands. Burst a node, throw it away.
- **H-254** `:peer` is the test-and-prod way to start a disposable VM. `slave` is dead.
- **H-255** NIFs are speed with a death radius. Dirty schedulers shrink the radius. Another node removes it.
- **H-256** Off-heap binaries are large tool bodies. Copying them through mailboxes is the silent tax.
- **H-257** Atoms are a finite namespace. Plugins must not mint them from user strings. This is a security thesis, not style.
- **H-258** Reduction counting is fairness. A hog tool starving the TUI is a scheduler thesis.
- **H-259** `disk_log` / append-only files are JSONL’s older sibling. Maybe the session log should be an OTP log.
- **H-260** Time-travel is message replay. The Session protocol is an event log we can play again.
- **H-261** Chaos is `Process.exit`. The lab’s scientific instrument is kill-and-see-what-lives.
- **H-262** One Session coordinating many hands nodes is Livebook. We have not actually tried believing José’s third sentence.
- **H-263** Object capabilities: a pid you were not sent, you cannot call. Hands should not hold the Session pid. That *is* the auth model.
- **H-264** The runtime is the framework **only if we stop adding frameworks** (Horde, Oban, LangChain, Phoenix-as-host) to fill silences we have not tried to fill with primitives.

### Wilder theses (keep them)

- **H-265** The daily-driver refusal list is a lab syllabus. Every hard-no is a paper we may try off to the side.
- **H-266** Ore exists so we can ask “is this BEAM or just good harness taste?” Same idea, other VM, *on purpose*. (Still ignore Ore until we say so — but the thesis is sitting there.)
- **H-267** If we rewrite RLM, GEPA, ACE, MemGPT, and parallel-compact onto BEAM and *none* of them get cheaper or clearer, José’s tweet is a vibe and we should say so.
- **H-268** If even one of them becomes obviously a process layout, the lab paid for itself.

---

*Dump still open. Add `H-269+`. Sort when Robert says stop.*

---

## Idea dump continued — adapt the paper, don’t photocopy it (`H-269+`)

Theses of the form: **paper insight → BEAM-shaped adaptation**. Not “reimplement the GitHub.”

### Adaptation as a method

- **H-269** Adaptation is the lab’s verb. Steal the *insight*. Let processes, mailboxes, code server, ETS, supervisors, Ports, and nodes change the shape.
- **H-270** A good adaptation test: after you say it in BEAM nouns, does a piece of their scaffolding disappear? If yes, the runtime did work. If you still need their whole framework, you transcribed.
- **H-271** Many 2025–2026 “agent runtime” papers are accidentally specifying OTP in Python/TS. The adaptation is: stop simulating the runtime; use it.

### Papers that look *especially* adaptable

- **H-272** **Agent libOS** ([arXiv:2606.03895](https://arxiv.org/html/2606.03895)): AgentProcess, message queues, capabilities, child processes, checkpoints, tool tables, skills, budgets. That is OTP vocabulary with the serial numbers filed off. Adaptation: Session *is* AgentProcess; mailbox *is* the queue; pid *is* the capability; supervisor *is* fork; JSONL *is* the checkpoint.
- **H-273** **Voyager** ([arXiv:2305.16291](https://arxiv.org/abs/2305.16291)): ever-growing *executable* skill library + curriculum + self-repair from errors. Adaptation: a skill is a loadable module (code server), not a markdown file. Hot-swap the skill. Index it in ETS. Run it on hands. Curriculum process proposes the next task.
- **H-274** **ACE playbook**: bullets with ids. Adaptation: ETS table of `{id, text, hits, last_used}`; curator is a process that mutates rows; generator only *reads*. No LLM “CRUD in prose.”
- **H-275** **GEPA**: reflect on trajectories, evolve prompts on a Pareto front. Adaptation: each candidate constitution is a process (or a module version); rollouts are child Sessions; the front lives in ETS; merge is `code.soft_purge` of losers. Trajectory = JSONL + audit, which we already keep.
- **H-276** **RLM**: recursive `llm_query` over a REPL heap. Adaptation: the heap is ETS + cold files + mailbox dumps, not a Python interpreter — *unless* the problem is Python-shaped, in which case Port the official env on hands. Two adaptations, one paper.
- **H-277** **MemGPT paging**: OS metaphor. Adaptation: we *have* an OS. Hot = message list, warm = Session state / ETS, cold = files, swap = recall/compact messages. The paper’s pager becomes a process with a budget.
- **H-278** **Mem0 tool-CRUD memory**: model issues ADD/UPDATE/DELETE. Adaptation: those are messages to a Memory GenServer. Schema lives in the process, not in the prompt.
- **H-279** **Codex background extraction**: parallel extract, then consolidate. Adaptation: `Task.Supervisor` of extractors + one consolidator. Stale prune is a periodic sweeper. No job queue product.
- **H-280** **Parallel compaction** paper: compact slices concurrently. Adaptation: partition the tree by subtree / by tool-id / by time band; N compactors; Session merges. This paper is almost written for us.
- **H-281** **Prefix-cache religion** (Claude economics): stable prefixes. Adaptation: constitution + tool specs in `persistent_term`; never rebuild the prefix mid-turn; plugin load is an explicit cache-break event we can name.
- **H-282** **Tool-result clearing**: Adaptation: eviction from the hot list, body stays in cold. Already half-true. The paper’s “memory tool” is `/recall` with a file API. We can try their API shape without their store.
- **H-283** **SWE-agent ACI**: the *interface* to the repo matters as much as the model. Adaptation: ACI as a Hands protocol (messages), not a prompt template. Different VMs, same insight: shrink the action language.
- **H-284** **CodeAct**: actions are code. Adaptation A: Python/JS on hands (their idea, our fence). Adaptation B: a tiny command language that is just messages. Adaptation C: sandboxed Elixir on a *hands* node, never on Session. The paper doesn’t have to pick; we can try three.
- **H-285** **OpenHands** runtime: sandbox as a first-class runtime, not an afterthought. Adaptation: hands node / Docker node *is* their runtime. Don’t port the platform; steal “runtime is part of the agent.”
- **H-286** **LLM-in-Sandbox** ([arXiv:2601.16206](https://arxiv.org/html/2601.16206v1)): put the model-usable computer *in* the sandbox to elicit agentic behavior. Adaptation: the sandbox is a BEAM with a small API. The brain only sends goals and receives notes.
- **H-287** **Reflexion**: verbal feedback into a memory buffer after a trial. Adaptation: a Reflector process that only appends notes to warm/cold; next Session reads them. Not a second personality in the same prompt.
- **H-288** **ReAct / Plan-and-Execute**: Adaptation: Plan is a child Session with a plan-constitution; Execute is a hands-heavy Session. Two pids, one goal. Product can still refuse “plan mode”; the lab can try the split.
- **H-289** **Tree-of-Thoughts / MCTS-over-actions**: Adaptation: each thought is a process; the tree is a supervisor; bad branches get killed. Probably theatrical. Still an adaptation worth writing down.
- **H-290** **Multi-agent debate / critic**: Adaptation: critic is a process with read-only evidence and a narrow mailbox. It cannot `start_turn`. Isolation is the adaptation; the debate prompt is not.
- **H-291** **Aider repo map**: Adaptation: a Watcher child (profile supervision tree) maintains an ETS repo map via Sourceror / tree-sitter-on-hands. The map is a process that ages, not a markdown blob we re-inject.
- **H-292** **Frequent intentional compaction**: Adaptation: a Budget process that *forces* handoff/compact early, on purpose. Policy lives outside the model. The insight is “stay half-empty,” not their particular summarizer.
- **H-293** **Codified context** (hot constitution, specialist agents, cold specs): Adaptation: `persistent_term` + profile children + cold files. Their three tiers are three BEAM nouns we already have names for.
- **H-294** **Hooks**: Adaptation: `:telemetry` attach points + observe-only processes. Mutating hooks are another agent (child Session), not a callback soup.
- **H-295** **Sub-agents in Claude/Cursor**: Adaptation: child Session or hidden node + worktree. The insight is isolation + smaller context, not “nested prompt with a persona.”
- **H-296** **Worktree-per-agent**: Adaptation: worktree is the filesystem fence; hidden node is the VM fence. Two layers, one paper-level idea (“don’t share a dirty tree”).
- **H-297** **Computer-use / browser-use**: Adaptation: a specialized hands node (Playwright Port, or a display). Profile, not core. The paper’s insight is “the computer is a tool surface.”
- **H-298** **MCP**: Adaptation: a Port translator on hands so foreign tools look like messages. Native tools never become MCP. The protocol is an edge, not a center.
- **H-299** **Meta-Harness** (search over harness code): Adaptation: the search operator *is* `:code.load_binary`. Mutate a module, run a child Session, keep or purge. Their outer loop is our code server.
- **H-300** **Agentic Memory / learned memory control** (survey [arXiv:2512.13564](https://arxiv.org/abs/2512.13564) and follow-ons): Adaptation: memory ops as messages; the *policy* of what to store can be a small model or a GEPA’d constitution. The store should still be ETS/files, not “the model’s vibes.”
- **H-301** **Inside the Scaffold** seven compaction strategies: Adaptation menu — hard truncate, sliding window, LLM summary, tool-clear, verify-summary, handoff, structural prune. Each can be a strategy *module* hot-swapped behind one Compactor process.

### Why some papers might work *better* here

- **H-302** Anything that wants **many short-lived workers** (GEPA population, parallel compact, parallel extract, best-of-n, speculative tools) is swimming with the runtime.
- **H-303** Anything that wants **a long-lived brain and disposable hands** (OpenHands runtime, LLM-in-Sandbox, libOS AgentProcess, Livebook) is swimming with distribution.
- **H-304** Anything that wants **skills as executable, reloadable programs** (Voyager, Meta-Harness, plugin markets) is swimming with the code server.
- **H-305** Anything that wants **memory as addressable state** (MemGPT, ACE, Mem0, Anthropic memory tool) is swimming with ETS + files. Vector DBs are optional, not the adaptation.
- **H-306** Anything that wants **clients attaching to a living agent** (OpenCode server, pair programming, headless eval) is swimming with actors. HTTP is optional.
- **H-307** Anything that is *only* a prompt trick (ToT slogans, debate personas, “you are a senior engineer”) probably does **not** get better on BEAM. Adaptation will feel empty. That’s useful negative space.

### A few more “what if we adapted X” sparks

- **H-308** Voyager skill library + Arvo plugins: the agent *writes* a plugin, we compile/load it, next turn it is a tool. Curriculum for a coding harness, not Minecraft.
- **H-309** GEPA + Harbor attention suite: evolve the constitution / attention policy / tool descriptions against honesty + task_ok. The organism is the harness, not a math prompt.
- **H-310** RLM + progressive attention: REPL walks *cold ids* and Session dumps; `llm_query` is a message to the brain. Two papers, one adaptation — “context is data, not a growing string.”
- **H-311** ACE playbook + skills.md: one addressable bullet store. Stop having two progressive-disclosure systems.
- **H-312** libOS capabilities + unforgeable pids: throw away their capability language; send pids instead.
- **H-313** Parallel compact + JSONL tree: compact per abandoned fork, not the live HEAD. Branches are already isolated on disk; workers can match that.
- **H-314** Reflexion + cancel-as-fork: the cancel leaf *is* a trial. A reflector can write “why we aborted” into warm without rewriting history.

---

*Dump still open. Add `H-315+`. Sort when Robert says stop.*

---

## Idea dump continued — the fake-OS insight (`H-315+`)

- **H-315** The central insight *is* a thesis: 2024–2026 agent literature is an accidental OTP spec plus a worse implementation language.
- **H-316** José and the papers are saying the same sentence from opposite ends. He: the runtime is the framework. They: we need a framework that is a runtime. Adaptation: believe both, delete the fake OS.
- **H-317** LangGraph / CrewAI / AutoGen / “agent OS” SDKs are the fake OS in library form. Studying them is useful as a *wishlist of nouns*. Implementing them on BEAM would be simulating a simulation.
- **H-318** Agent libOS is the clearest specimen: they named AgentProcess, Object Memory, tool table, JIT tools, child processes, hierarchical budgets, checkpoints, typed capabilities. That is a design doc for OTP written by someone who has not met it.
- **H-319** Pi’s `/reload` recycles a process because their host has no code server. The paper-level need is “reload skills, keep state.” The fake-OS move is kill-and-respawn. The OTP move is load_binary.
- **H-320** OpenCode’s HTTP server is a fake distribution layer. The need is “a client attaches to a living brain.” The OTP move is another mailbox.
- **H-321** Docker-as-the-only-fence is a fake isolation hierarchy. Docker is a *good top layer*. Under it they still fake process isolation with threads, try/catch, and allowlists.
- **H-322** Vector-DB memory is often a fake address space. The need is “I have more state than fits in the prompt.” ETS + files + an id is an address space. Vectors are a *search index*, optional.
- **H-323** “Orchestrator agent” is a fake supervisor. The need is “start, restart, kill, budget children.” That is literally a supervisor + a budget in state.
- **H-324** “Permission broker / tool gateway” is a fake capability system. The need is “this worker must not see keys or the Session.” Don’t give it the pid. Put it on another node.
- **H-325** “Session store in SQLite / Redis” is a fake process that forgot it died. Sometimes you want durability (JSONL). Sometimes you wanted a process and serialized it because Node exits when the tab closes.
- **H-326** “Background job queue for memory extraction” is a fake Task.Supervisor. The need is “don’t block the turn.” Send a message; a sweeper works.
- **H-327** “Streaming control plane” is a fake mailbox with backpressure bolted on. The BEAM mailbox *is* the stream.
- **H-328** The fake OS is not stupid. They are discovering *requirements*. Our job is to keep the requirements and throw away the simulated kernel.
- **H-329** A reading method: for each paper, list the nouns. Circle the ones that already exist in `erl` man pages. Underline the ones that are actually new (paging policy, GEPA reflection, ACI shape, prefix-cache economics). Adapt the underlined. Don’t rebuild the circled.
- **H-330** The failure mode of this insight: smugness. “We have OTP so we don’t need their idea.” The ideas are often the underlined parts. OTP is the circled parts. Both lists matter.
- **H-331** The other failure mode: building Elixir-LangGraph because the paper had a graph. If the graph is just a supervisor tree plus messages, draw the tree. Don’t port the library.
- **H-332** Arvo’s thin OTP slice is the embarrassing exhibit. We *have* the real OS and we still run tools in-process, halt the VM on tile quit, and compile plugins with Mix. The papers are faking an OS; we are under-using a real one.
- **H-333** Livebook is the existence proof that “use the runtime” is not a slogan. Brains vs Port-spawned / attached / remote nodes is already a product.
- **H-334** Tidewave is a mixed exhibit: IEx-in-the-target-app is using the runtime; MCP around it is a fake bus. Steal the first, leave the second.
- **H-335** Jido is a mixed exhibit: native processes, but a framework gravity well. Steal loop/action shapes; don’t let it become the OS.
- **H-336** If this insight is right, the research catalog’s most valuable pages are **mapping tables** (their noun → our noun + the leftover insight), not Elixir ports of architectures.
- **H-337** If this insight is wrong, we will adapt three papers onto OTP and get nothing cheaper or clearer. That is an allowed result (H-267). The insight is a thesis, not a trophy.

---

*Dump still open. Add `H-338+`. Sort when Robert says stop.*

---

## Idea dump continued — they reinvented the BEAM in the language they know (`H-338+`)

Not only agent papers. The same move shows up across “modern backend,” “durable workflows,” and “agent OS.” Pattern recognition is the work.

### Why this keeps happening

- **H-338** Researchers and harness authors write TS/Python because that is the lab language, the paper language, and the hiring language. Host choice is path dependence, not an evaluation of runtimes.
- **H-339** Elixir flying under the radar is the opening. We do not need mindshare to *try* the primitives. We need eyes to *see* when a paper has drawn OTP.
- **H-340** The tell: a README that invents a kernel noun (AgentProcess, Durable Object, Workflow, Fiber, Crew, Graph, Sandbox, Memory OS, Tool Gateway). Translate the noun. Keep the policy.
- **H-341** The other tell: they need Redis, SQLite, HTTP, and a queue product before the first agent can have a mailbox.

### The wider fake-BEAM catalog (same pattern, other neighborhoods)

- **H-342** **Effect.ts / ZIO / cats-effect** — fibers, supervision, interruption, typed errors. Honest about being a runtime. Still a runtime *inside* TS/JVM. Thesis: they documented the missing VM.
- **H-343** **Cloudflare Durable Objects** — named, single-threaded, long-lived state with a mailbox. That is a registered GenServer. Adaptation: Session already wanted to be one.
- **H-344** **Temporal / Azure Durable Functions / Cloudflare Workflows / Inngest / Trigger.dev** — durable execution, retries, children, cancellation. That is a supervisor plus a log. The *insight* is “the turn must survive the process.” JSONL + a living VM is two different answers; they only had the first.
- **H-345** **Orleans grains / Dapr actors / Akka** — they *admit* actors. Useful cousins. Not TS-fake; still not BEAM (location transparency as a product, different failure story).
- **H-346** **Kubernetes as supervisor** — restart, budget, probe, evict. The cluster is the VM when your language has no VM. Adaptation: don’t k8s a coding session; supervise it.
- **H-347** **BullMQ / Celery / Sidekiq / Oban-in-other-languages** — a mailbox that forgot it was a mailbox and became a company.
- **H-348** **Redis as the agent’s hippocampus** — shared memory because processes don’t share and don’t last. ETS + a node is the thing they wanted.
- **H-349** **LangGraph checkpointing** — `gen_statem` plus a journal, sold as a framework.
- **H-350** **MCP** — a foreign function bus because two runtimes cannot send messages. Port + a protocol is fine at the *edge*. As the *center* it is a fake distribution layer.
- **H-351** **VS Code extension host / Electron utility process** — plugin isolation by spawning a process because they cannot load two versions of a module. Code server + a hands node.
- **H-352** **Deno permissions / WASM component model** — capability systems built because pids are forgeable and address spaces are shared. Unforgeable pids + another node.
- **H-353** **E2B / Modal / Firecracker-as-product** — excellent *top* fence. Often treated as the *only* fence because the language has no cheap middle (process / Port / hidden node).
- **H-354** **OpenAI / Claude / Cursor “agent runtimes”** — session objects, tool gates, cancel, sub-agents, hooks. Productized OTP glossaries. Steal the UX requirements; don’t steal the host.
- **H-355** **AutoGen / CrewAI / “multi-agent OS”** — org charts as architecture. The org chart is a supervision tree plus who may message whom.
- **H-356** **Streaming UI protocols (AG-UI, RSC, tRPC subscriptions)** — attaching a projector to a living process. Focus/NDJSON/IEx are that, if we stop killing the VM.

### What we are actually collecting

- **H-357** The catalog’s unit is a **pattern card**, not a paper summary: *their noun → BEAM noun → leftover insight → what a try would even mean.*
- **H-358** Leftover insight is the gold. “Compact at 50% on purpose.” “Evolve the constitution from trajectories.” “Prefix must be stable.” “ACI smaller than bash.” Those do not fall out of OTP by themselves.
- **H-359** Experiment (later) is: take one leftover insight, host it on the real primitive, see if the fake kernel was load-bearing or just furniture.
- **H-360** If the fake kernel was furniture, we publish a mapping and move on. That *is* a result. Most cards should end there.
- **H-361** If the fake kernel was load-bearing (their Python REPL *is* the idea; their vector index *is* the idea), then we either Port it on hands or admit BEAM does not help. Also a result.
- **H-362** The work is closer to **comparative anatomy** than to “Elixir advocacy.” We are dissecting animals that grew the same organs in a different phylum.

### Pushing this line harder (theses, not a plan)

- **H-363** A year of agent papers may be the best OTP tutorial nobody meant to write. Read them as that.
- **H-364** The under-the-radar problem is also a *clarity* gift: we are not racing their changelog. We can wait until the noun is stable, then map it.
- **H-365** Arvo is the instrument, not the prize. The prize is a catalog of “they reinvented X; here is X; here is the leftover idea; here is what happened when we tried it.”
- **H-366** The daily driver can stay small while the lab is wide. Using the runtime in the lab does not mean dumping Effect-shaped everything into `arvo/`.
- **H-367** “Discovering patterns” is Front A and Front B braided: every paper is a chance to name a primitive we have not squeezed yet.
- **H-368** The first artifact that would make this real is not code. It is a growing **field guide**: twenty pattern cards, half of them “just a mailbox,” a few of them “oh, that’s actually new.”

---

## Idea dump continued — sort walkthrough (`H-369+`)

Robert walked the five “try later” items 2026-08-14. Kept all five. Added:

- **H-369** Helper agents are **specialized** (scout / critic / planner): different rules, tools, and job — not a persona stuffed into the parent prompt.
- **H-370** For each helper, test **another copy of the parent model** vs a **smaller cheaper model**. Include a **local** model on Robert’s machine as the cheap arm when we can.
- **H-371** Local/smaller is allowed to make things worse. Measure success, cost, and time. Do not assume local is better. The parent model does not have to be local.

Also locked in conversation (see [`SORT.md`](SORT.md)): G-001–G-003 kept; G-002 is the one he cares about most; G-004 lab loop ≠ “improves while you use it” (bigger cousin, don’t merge).

- **H-372** Arvo is **not** Robert’s daily driver. He does not use it. He is not sure the features work. Do not plan as if we are protecting a tool he relies on. “In the tree” ≠ “works.”

---

*Dump still open. Add `H-373+`. First sort is in [`SORT.md`](SORT.md).*
