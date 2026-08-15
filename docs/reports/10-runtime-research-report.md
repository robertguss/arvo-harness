# Focused Research Report — Runtime primitives

- **Artifact type:** Focused research report
- **Program:** arvo-beam-harness-research
- **Stage:** runtime — Runtime primitives
- **Status:** Draft — not accepted
- **Version:** 1.0
- **Created:** 2026-08-15
- **Research date:** 2026-08-15
- **Depends on:** Accepted Research Charter
  ([`docs/01-research-charter.md`](../01-research-charter.md),
  accepting commit `081ad36932be7f3f0df062b592cc306c49f72af4`);
  accepted Program Blueprint
  ([`docs/00-program-blueprint.md`](../00-program-blueprint.md),
  accepting commit `0b49540cae7d2a30ad4b4b145999e27b82c50dad`)
- **Output path:** `docs/reports/10-runtime-research-report.md`
- **Recommendation range used:** `REC-001`…`REC-011`
- **Risks minted:** `RSK-001`…`RSK-009`
- **Open questions minted:** `OQ-001`…`OQ-006`
- **Evidence IDs:** `EVD-001`…`EVD-028`
- **Spikes:** none (`SPK-###` unused)
- **Instrument:** `../coding-agent-harness/arvo` at
  `84004e1fcae11bbf72656c58e7fa5ae4aa92838b` (observed 2026-08-15)
- **Official docs dated:** Erlang/OTP **29.0.5**, Elixir **1.20.3**,
  Livebook **0.19.9** (pages opened 2026-08-15)

> This file catalogs three host primitives. It does not implement them,
> boot Arvo, or prove any feature works when run.
> A human must accept this report. This writing session does not.

## 1. Artifact metadata and actual research date

| Field | Value |
| ----- | ----- |
| Program ID | arvo-beam-harness-research |
| Stage | `runtime` |
| Kind | independent focused research (group A) |
| Primary question | What exactly are G-001, G-002, and G-003 on a real BEAM, and what would a later repo measure to keep or drop each one? |
| Actual research date | 2026-08-15 |
| Author role | BEAM / OTP systems researcher; skeptical Elixir maintainer |
| Rigor | focused (Blueprint §9) |
| Replication | off |
| DEC minted | none |
| Accepting commit | *(empty — not accepted)* |

## 2. Executive answer

G-001, G-002, and G-003 are three **different host nouns** on a real
BEAM. They stay three. José Valim stated them as official claims, not as
measurements.[^jose-1][^jose-2] This catalog names them, restates the
accepted later measure and keep/drop rule for each, and records what the
local Arvo *tree* appears to contain on 2026-08-15. Function is unproven.

1. **G-001 — window vs brain.** A living Session process outlives the
   tile. A new client attaches to that process. That is not “reload the
   JSONL after the VM died.” OTP nouns: Session as a `permanent` child
   (or equivalent always-on named process); Focus / attach as
   `temporary`; `os_signal` kills the tile, not the VM; clients join
   via `:pg` or Registry. Arvo’s tree still defaults
   `:halt_on_focus_quit` to `System.stop/1` after Focus returns, boots
   with `mix run --no-halt`, and has no `arvo attach` to a living
   Session.

2. **G-002 — hands somewhere else.** Tools run where keys and Session
   state are *not*. Kill hands mid-tool; brain + JSONL live; the same
   coding task still works. Isolation is a **location ladder**: process
   → Port → hidden `:peer` node → Docker node. Keep the *thinnest*
   layer that later passes isolation + survival + task. A shared cookie
   is not a fence. A Port wrapping a foreign harness is a shell — drop
   it. Arvo’s tree runs tools in-process on the Session VM; bash is
   `System.cmd`; FFF is a Rustler NIF with `otp_app: :arvo`; there is
   no `:peer` / `Node` use in `lib/`.

3. **G-003 — plugin swap without Mix and without relups.** Load new
   `.beam` with `:code.load_binary/3`. The Session mailbox stays. The
   in-flight turn finishes on *old* code (two-version modules). After
   the turn, `soft_purge`. The next turn sees the new manifest. Mix
   must leave the product VM. OTP release handling (`relup` / `appup` /
   SASL `release_handler`) is the wrong tool. `Code.append_path` plus
   hope is a drop. Arvo’s tree still does `mix compile` in the plugin
   dir, then `Code.append_path`.

| # | Plain name | SORT | Claim | Host move | Later measure | Keep / drop | Land in `arvo/` later |
| - | ---------- | ---- | ----- | --------- | ------------- | ----------- | --------------------- |
| 1 | Close the window, agent stays | G-001 | Quit Focus (or close the window) leaves Session + JSONL + HEAD alive. A new client attaches and continues the same tree. That is not JSONL auto-resume after a VM death. | Session `permanent`; Focus `temporary` (or a fresh attach process). Stop `:halt_on_focus_quit`. Boot a daemon / release / `run_erl`. Clients join via `:pg` or Registry. `os_signal` kills the tile, not the VM. | Kill the window / SIGTERM the tile. Session pid lives. JSONL still grows. A new client attaches and continues. Honesty on the continued session, same frozen model, does not get worse. | Keep if attach is not just disk resume. Drop if we only wrapped auto-resume in boot scripts. | yes-candidate |
| 2 | Tools live somewhere else | G-002 | Hands cannot see API keys. Kill hands; chat lives. Same coding task still works. Thinnest setup that passes. | Isolation ladder: process → Port → hidden `:peer` node (`--hidden`, per-session cookie, `Hands.API` only, no Session pid on hands) → Docker node. FFF NIF and bash live on hands. `:erpc` read-only and allowlisted, or a protocol we own. Shared cookie is not a fence. | Same task; only the topology changes. Hands cannot read keys. Kill hands mid-tool; Session + JSONL live. No orphan `bash -c`. Hidden BEAM and a container are different threats — score them separately. | Keep the *thinnest* layer that passes isolation + survival + task. Drop a layer that only adds latency. Drop if “hands” is a Port wrapping a foreign harness. | lab-first |
| 3 | Swap a plugin without restarting | G-003 | New plugin code; current turn finishes on old code; next turn sees new tools; no Mix compile inside the live app. | `:code.load_binary` + registry + two-version modules; `soft_purge` after the turn. Load `.beam` only. Reject `on_load`. No new atoms from user strings. Profile switch set-diffs the supervision tree, not only the tool menu. | Session mailbox intact. In-flight turn stays on old modules. Next turn sees the new manifest. Name the prefix-cache break. | Keep if Mix leaves the product VM and the swap is real. Drop if this is `Code.append_path` plus hope, or if cache-break cost eats the win. | yes-candidate |

This table restates Blueprint §5 and SORT Graduate G-001…G-003. It does
not replace them.

## 3. Scope and exclusions

### Included

- Name G-001, G-002, and G-003 as host primitives on a real BEAM.
- Restate later measure and keep/drop. Do not invent a fourth headline.
- Describe the dated Arvo checkout for those three. Local tree only to
  verify facts the notes or Blueprint already claimed.
- Compare process / Port / hidden `:peer` / Docker for G-002.
- Compare `:code.load_binary` / two-version modules vs
  `Code.append_path` vs Mix-in-VM vs OTP relups for G-003.
- Mint `REC-001`…`REC-011`, shared `RSK` / `OQ` from `001`.

### Excluded

- Coding, `mix` tasks, Harbor, boot or smoke of Arvo, PRs into `arvo/`.
- Minting `SPK-###`.
- Writing leftovers or score-harness reports.
- G-004, G-005, or a sixth test.
- Opening intake (bookmark JSON, PDFs, vault traces, unread Articles).
- MCP, Horde, Oban, libcluster, OTP relups, or LiveView as architecture.
- Treating Livebook as a UI to become.
- Treating Watch as a failure.
- Touching `ore/`.
- Marking `runtime` accepted.

## 4. Inherited constraints

From accepted Blueprint §7 and accepted Charter §1. Detail stays there.
Do not re-litigate.

1. Personal lab, not a race.
2. Two programs. This repo writes the catalog. A later sibling repo
   runs tests.
3. No spikes, evals, Harbor, smoke tests, or PRs into Arvo **here**.
4. Arvo is the instrument, not a daily driver. “In the tree” ≠ “works.”
5. Local path: `../coding-agent-harness/arvo`. Ignore `ore/` unless the
   owner says so.
6. The runtime is the framework: swap plugins without dropping state;
   the window is a client of a living agent; brains and hands sit in
   different places.
7. The gap is Arvo’s thin OTP slice: one Session, tools in-process,
   Mix-compile plugins, quit-window kills the VM, file-search native
   code on the brain.
8. Adaptation, not photocopy, not “refuse every rewrite.” A
   Port-wrapped foreign harness is a shell.
9. Intake is closed.
10. Success bar: catalog, not a working harness.
11. Rigor: focused. Replication off. No `SPK-###` here.
12. This track owns only G-001, G-002, G-003.
13. Five tests stay five. No G-006.
14. G-004 is a lab loop on a **fixed** test set — not this track.
15. G-005 helpers are specialized — not this track.
16. Phase-2’s first job includes an Arvo smoke check — **there**.

Graduate labels `G-001`…`G-005` and dump labels `H-` / `P-` / `V-` /
`XB-` / `LC-` are **intake IDs**. Cite them. They are not `REC`
numbers.

## 5. Methodology

1. Read the accepted Blueprint and accepted Charter in full, then the
   runtime commissioning prompt, then the focused-report, evidence-model,
   recommendation, and evidence-spike contracts. Skim SORT Graduate
   G-001…G-003 plus José / surfaces / isolation Translate clusters, the
   locked top of DISCOVERY-NOTES, the grounding snapshot, authority,
   anti-patterns, validation, and approval-gates. Did **not** re-sort.
   Did **not** open closed intake.

2. **Exa (required).** `search_tool` query `exa` in this Grok session
   returned no Exa MCP tools (connected servers were github, tasks,
   voice). A genuine attempt to attach Exa followed:
   - Installed the xAI Official marketplace plugin `exa`
     (`exa-labs/exa-grok-plugin`). Plugin MCP does not attach to *this*
     already-running session.
   - Added HTTP MCP `https://mcp.exa.ai/mcp` to user Grok config. Same
     limit: not available as `use_tool` in this session.
   - No `EXA_API_KEY` in the process environment. REST
     `POST https://api.exa.ai/search` returned HTTP 402 (payment
     required / x402).
   - Direct streamable-HTTP to `https://mcp.exa.ai/mcp` (browser-like
     User-Agent) succeeded: initialize, `tools/list`, then
     `web_search_exa` and `web_fetch_exa` against official OTP / Elixir
     / Livebook queries. Server identified itself as Exa MCP
     `exa-search-server` 3.2.1. Exa pointed at primary URLs
     (erlang.org OTP 29.0.5, hexdocs Livebook / Elixir).
   - Enabling `agent_run` via
     `https://mcp.exa.ai/mcp?tools=web_search_exa,web_fetch_exa,agent_run`
     returned JSON-RPC 401: “Authentication required. Use OAuth or
     provide an API key.” **Exa Agent / deep-reasoning did not run.**
     Ordinary Exa lookup did.

3. **Primary verification.** Exa output is retrieval, not a finding.
   Official pages Exa named were opened independently
   (`web_fetch` / `open_page`) on 2026-08-15 and classified as official
   claims or verified facts *about documents*. José’s two tweets were
   fetched with the built-in X thread tool and classified as official
   claims.

4. **Arvo checkout.** Read-only inspection of
   `../coding-agent-harness/arvo` on 2026-08-15 to verify facts the
   grounding snapshot and Blueprint already claimed. Recorded
   `git rev-parse HEAD` = `84004e1fcae11bbf72656c58e7fa5ae4aa92838b`
   (same short SHA the packaging notes named). **No `mix`, no boot, no
   task, no smoke test.**

5. Compared credible host options. One `REC` per decision area. Did not
   merge two primitives into one `REC`. Named later measures instead of
   running them.

6. High confidence only for user decisions and dated primary reads of a
   document or source line. Hypotheses about “this would work” stay
   Medium or Low.

## 6. Source quality and limitations

| Source class | Quality here | Limitation |
| ------------ | ------------ | ---------- |
| Accepted Blueprint + Charter | User decision (High as *lock*, not as empirical proof) | Locks the tests; does not prove they pass |
| OTP 29.0.5 / Elixir 1.20.3 official pages | Tier 1 official claim / verified fact about the document | Docs describe the VM, not Arvo, and not a phase-2 result |
| Livebook 0.19.9 runtime page | Tier 1 official claim about Livebook | Cousin architecture, not a harness measurement |
| José tweets 2026-08-14 | Tier 1 official claim | Not a measurement; no protocol, no test |
| Arvo source at `84004e1` | Verified fact about *source text* | Function unproven; Robert does not use the product |
| SORT + DISCOVERY-NOTES | Framing evidence | Do not outrank Blueprint |
| OpenCode / Pi as named cousins | Official claim of *need* (José) | Existence proofs of a product shape, not architectures to swallow |
| Exa MCP search/fetch | Retrieval tool | Not a source tier; not a verified fact |

No tier-3 measurements exist in this program. Popularity and star
counts are not used.

## 7. Evidence spikes

**None in this repo.**

Phase-2 (sibling experiment repo) would measure, and must not back-fill
`SPK-###` here:

| Tempted command (do **not** run here) | Which test | What it would answer |
| ------------------------------------- | ---------- | -------------------- |
| Quit Focus / SIGTERM the tile; inspect Session pid and JSONL mtime | G-001 | Does quit kill the VM, or only the tile? |
| Start a second client against the still-living node | G-001 | Is attach real, or only disk resume on next boot? |
| Print `XAI_API_KEY` / cookie / Session state from a tool process | G-002 | Negative key test |
| Kill the hands process / node mid-`bash`; watch Session + JSONL | G-002 | Survival |
| Same Harbor attention task on in-process vs process vs Port vs hidden `:peer` vs Docker | G-002 | Thinnest layer that still passes |
| `code:load_binary` a plugin module during an in-flight turn; then `soft_purge` | G-003 | Mailbox intact; old code for this turn; new manifest next turn |
| Time to next completion + whether the prefix cache broke | G-003 | Cache-break cost |

## 8. Comparative analysis

### 8.1 What José claimed, and what he did not measure

On 2026-08-14 José Valim wrote that people are “sleeping on Elixir for
a coding harness,” and named three runtime gifts:[^jose-1]

1. Hot-code swapping for an extensible plugin system “similar to Pi,”
   reloading live without dropping state.
2. Client/server “similar to OpenCode” as a byproduct of the actor
   model.
3. Built-in distribution to isolate **brains** (model + session) from
   **hands** (sandbox + tools), including one session coordinating
   agents in Docker or on a remote node — “this is basically how
   Livebook works anyway.”

Follow-up: “You don’t need an external framework for this. The runtime
is the framework.”[^jose-2]

Those sentences are **official claims**. They do not specify
supervision flags, cookie policy, `:erpc` allowlists, or a keep/drop
score. OpenCode-like attach and Pi-like plugin reload are existence
proofs of *need*. They do not authorize an HTTP control plane or a
process-recycling reload as the BEAM host nouns.

Livebook’s documented standalone runtime starts a **new Erlang VM node
per notebook**, isolated from the Livebook UI node and from other
notebooks.[^livebook-runtime] Attached runtime clusters into an already
running node. That is the official “brains vs nodes” cousin. It is not
a UI to become (Refuse H-145; Blueprint §6).

### 8.2 G-001 — quit the window, the agent stays

**OTP nouns.** A supervisor child with `restart => permanent` is always
restarted; `temporary` is never restarted; `transient` restarts only on
abnormal exit.[^otp-supervisor] That maps cleanly onto “Session must
not die when Focus dies.” Focus started with `Task.start` (unlinked) is
already closer to a disposable client than a linked child — but only if
its exit does not halt the VM.

A process mailbox is per-process. A new client that sends to the same
Session pid continues the same conversation. Reloading JSONL after
`init` died is a **different** recovery story (H-032, H-165). Auto-resume
on boot is disk resume. G-001 forbids scoring that as a keep.

Clients find the brain with `:pg` or Registry, not by importing a TUI
module. `:pg` is a process group belonging to a scope; joins are
explicit.[^otp-pg] Registered names are **local to a node** — a second
node must use `{Name, Node}` or a pid it was sent.[^otp-dist]

**Arvo tree (2026-08-15, `84004e1`).** Matches the 2026-08-14 grounding
snapshot on the load-bearing lines:

- App children, `one_for_one`: `Providers.Registry`,
  `Auth.TokenManager`, `Plugins.Supervisor`, `Plugins.Registry`,
  `Session`, `TUI`.[^arvo-app]
- Product boot is `bin/arvo` → `mix run --no-halt`.[^arvo-bin]
- Focus is `Task.start(fn -> Arvo.TUI.Focus.run() end)`, not a
  supervisor child.[^arvo-app]
- After Focus returns, `:halt_on_focus_quit` defaults **true** →
  `System.stop/1`. Tests force false. Repl also `System.stop`s.[^arvo-focus]
- Session is a named singleton GenServer; `Process.flag(:trap_exit, true)`.
  Turns are `Task.async` linked to Session, calling `Arvo.Agent.run`.
  Agent is **not** a process.[^arvo-session][^arvo-agent]
- Session still names `Arvo.TUI` (`put_tokens`, `put_attention_mode`,
  `put_access_chrome`, cast `{:set_live_panes, _}`).[^arvo-session-tui]
- TUI still `GenServer.call`s Session (`Session.get/0`) from slash /
  tree.[^arvo-tui-get]
- Headless `arvo-chat` is a **second client of a new boot**, then
  `System.halt`. There is no `arvo attach` symbol in the tree.
- Same-cwd auto-resume on interactive boot re-opens the last JSONL and
  re-applies the profile name.[^arvo-app]

**Checkout update vs 2026-08-14 snapshot:** the named deadlock write-up
`docs/solutions/logic-errors/session-tui-genserver-reverse-call-deadlock.md`
is **not** in this tree. The coupling the snapshot described is still
visible as source. Absence of that markdown is not absence of the call
pattern.

**Keep / drop (restated).** Keep if attach is not just disk resume.
Drop if we only wrapped auto-resume in extra boot scripts.

### 8.3 G-002 — isolation ladder

A fence is a **location**, not an allowlist (H-007). Official OTP gives
the rungs; it does not pick one for a coding harness.

| Rung | What official docs say it is | Threat it can address | What it does not | Drop rule |
| ---- | ---------------------------- | --------------------- | ---------------- | --------- |
| Process (`spawn_monitor`, heap limit, timeout, `:brutal_kill`) | A lightweight isolated heap + mailbox; links take you with them, monitors notify[^otp-proc] | Tool crash / OOM does not have to kill Session if you monitor, not link | Same VM, same `os:getenv`, same ETS, same NIF crash domain | Drop as the *only* fence if the negative key test fails (hands can still read `XAI_API_KEY`) |
| Port | Byte pipe to an **external OS process**; port dies if the owner dies; a buggy *port driver* can crash the VM[^otp-ports] | OS-process isolation for bash; killable child; no shared Erlang heap | Not a second BEAM; not a key fence if the Port’s env still has secrets; wrapping a foreign *harness* is a shell (H-107) | Drop if “hands” is a Port around Claude Code / a TS CLI. Keep as a *bash* transport only if a thinner process rung failed a kill/orphan test |
| Hidden `:peer` node | Another Erlang runtime; `-hidden` connections are not transitive and do not appear in `nodes/0`; `:peer` starts a linked node that dies when the control connection dies[^otp-dist][^otp-peer] | Separate heap, code, env, scheduler; `nodedown` fails in-flight tools; per-session cookie; no Session pid on hands | Not a Linux jail. Cookie match ⇒ `:erpc:call` can `apply` **anything** on the peer[^otp-erpc]. OTP says cookie “security” is *against accidental misuse*, cookies are not cryptographically strong, traffic is cleartext unless TLS[^otp-dist] | Drop if it only adds hop latency after a process/Port already passed keys + kill + task. Drop a **shared** cookie. Keep as the default *VM* fence to try after process fails keys |
| Docker (or other container) around a node | `:peer` `exec` can be `{docker, ["run", …]}`[^otp-peer]; José named Docker as an example location[^jose-1] | Filesystem / network / pid namespace; bash cannot see the brain’s disk or extras | Different threat than a hidden BEAM. Extra latency. Not a framework | Score separately from hidden BEAM. Keep only if the bash-jail threat remains after a hidden node passes. Lab first |

**Cookie is not a fence.** OTP: groups with identical cookie files
“communicate freely.” `erlang:set_cookie/2` is per-node pairing.
Distribution without `-proto_dist inet_tls` “may give the attacker
complete access to the node and by extension the cluster.”[^otp-dist]
`:erpc` evaluates `apply(Module, Function, Args)` on the remote
node.[^otp-erpc] A shared cookie plus open `:erpc` is remote eval on
the brain (Refuse H-012, H-175). Per-session cookie + hidden node +
narrow `Hands.API` (no Session pid on hands, no eval, no code load) is
the catalog shape. Even then, cookie is a *pairing* mechanism, not
authn.

**Arvo tree.** No `Node` / `:peer` / `net_kernel` in `lib/`. Release
cookie is the string `"arvo_headless"` in `mix.exs`.[^arvo-mix] Tools
run sequentially in the turn Task via `Arvo.Tool.invoke`.[^arvo-agent]
Bash is `Task.async` + `System.cmd("bash", ["-c", …])` with
`Task.shutdown(..., :brutal_kill)` — same user, same VM; brutal-kill of
the Task may leave a `bash -c` orphan (H-171).[^arvo-bash] FFF is
bundled `otp_app: :arvo`; `Fff.Plugin.activate` is
`Code.ensure_loaded(Fff.Native)`.[^arvo-fff] Tokens live in
`Auth.TokenManager` in the same VM; store file `~/.arvo/auth.json`.[^arvo-auth]
Herdr panes are a CLI subprocess to a multiplexer — chrome, not a tool
jail.

**Thinnest-that-passes.** Phase-2 starts at process isolation (tool
children, no secrets in the child env). If the negative key test fails,
step to Port for bash only. If keys or NIF crash domain still fail,
step to hidden `:peer`. If bash can still see the repo or egress in a
way the task forbids, step to Docker. Do not start at Docker because
papers do (Watch “where hands can live”).

**Keep / drop (restated).** Keep the thinnest layer that later passes
(a) keys, (b) kill-hands, (c) same task. Drop a layer that only adds
latency. Drop a Port-wrapped foreign harness.

### 8.4 G-003 — two-version modules, not Mix, not relups

**What the code server actually does.** A module has at most two
variants: *current* and *old*. Load a second copy: previous current
becomes old; both may run. Load a **third**: the server **purges** old
code and **terminates processes lingering in it**.[^otp-code-loading]
Fully qualified calls go to current; a process stays on old until it
makes such a call. `code:soft_purge/1` removes old code only if nobody
lingers; `code:purge/1` kills lingerers.[^otp-code]
`code:load_binary/3` loads object code from a binary without the code
server opening the file — the documented way to push `.beam` onto a
node.[^otp-code]

`-on_load` runs automatically on load and is the documented NIF hook.
If it fails, the new code is unloaded.[^otp-code-loading]
`code:atomic_load/1` rejects modules with `on_load`
(`on_load_not_allowed`).[^otp-code] Catalog rule: reject `on_load` in
product plugins; NIFs belong on hands (G-002), not as a brain load
hook.

**What Mix and `Code.append_path` actually do.**
`Code.append_path/2` appends a directory to the **code path** of this
node. It does not compile, does not create a second version, and does
not keep an in-flight turn on old code.[^elixir-code] Arvo’s loader
runs `System.cmd("mix", ["compile"], cd: dir)` when ebin is empty, then
`Code.append_path(ebin)`, then `String.to_existing_atom` on
`*Plugin.beam`.[^arvo-loader] That is Mix in the product VM (H-173).
`to_existing_atom` is already the careful atom path; the hazard is
compile-in-VM, not atom creation.

**What relups actually are.** OTP release handling is SASL’s framework
for upgrading an **entire release** with `.appup` / `relup`,
`release_handler:install_release/1`, possible `restart_new_emulator`,
and `sys:suspend` / `change_code` / `resume` on behaviour
processes.[^otp-relup] It is for Kernel/STDLIB/SASL and application
upgrades on an embedded node with heartbeat. It is not a plugin
marketplace. Using it as G-003 would pull SASL release_handler into
the product identity (Refuse H-131; Blueprint §6).

**Profile switch** in Arvo already set-diffs activate/deactivate and
starts `manifest.children` under `Plugins.Supervisor`
(`DynamicSupervisor`, one_for_one).[^arvo-profiles] That is the right
*tree* move. It is not a code-server swap.

**Keep / drop (restated).** Keep if Mix leaves the product VM and the
swap is real (mailbox intact, in-flight turn on old, next turn new
manifest). Drop if this is `Code.append_path` plus hope, or if
prefix-cache break cost eats the UX win (name the break; do not treat
cache as weather — Translate “prefix cache as economics”).

### 8.5 Checkout vs function

| Claim (tree) | Classification | Function? |
| ------------ | -------------- | --------- |
| HEAD `84004e1` on 2026-08-15 | Verified fact about git | No |
| Children list and Focus `Task.start` | Verified fact about source | No |
| `:halt_on_focus_quit` default true → `System.stop/1` | Verified fact about source | **Does not prove** quit kills a running product VM |
| `mix run --no-halt` boot | Verified fact about `bin/arvo` | No |
| Session `Task.async` → `Agent.run`; tools sequential in-process | Verified fact about source | No |
| Bash `System.cmd` | Verified fact about source | Does not prove orphan `bash -c` |
| Plugin `mix compile` + `Code.append_path` | Verified fact about source | No |
| FFF `otp_app: :arvo` NIF | Verified fact about source | Does not prove a dirty-scheduler crash |
| No `Node` / `:peer` in `lib/` | Verified fact about this checkout | No |
| Release cookie `"arvo_headless"` | Verified fact about `mix.exs` | No |
| No `arvo attach` | Verified fact about search | No |
| Deadlock markdown path from 2026-08-14 snapshot | **Not present** at this HEAD | Coupling source remains; the file does not |

## 9. One coherent recommendation set

### REC-001 — Name G-001 as attach to a living Session

- **Classification:** Required
- **Applies to:** Sibling-repo test G-001; catalog host noun
- **Confidence:** High (user decision that the test exists); Medium (host recipe will pass)
- **Decision urgency:** Required now
- **Evidence quality:** Strong for the lock; Weak for empirical pass
- **Related decisions:** None

#### Recommendation

Keep G-001 as its own headline: quit the window, the Session process
and JSONL stay, a new client attaches and continues. Do not merge it
with G-002, G-003, or disk resume.

#### Claim

Quit Focus (or SIGTERM the tile) leaves the Session pid alive and the
JSONL appendable; a new Focus, `arvo-chat`, or IEx attaches to that
living Session and continues the same tree.

#### Host primitive

G-001

#### Why Watch

Not Watch — this is headline test G-001.

#### Later measure

Kill Focus; SIGTERM the tile. Session pid lives. JSONL still appends.
New client attaches and continues. Harbor attention honesty on the
continued session, frozen model, does not get worse.

#### Keep / drop

Keep if attach is not just disk resume and honesty does not regress.
Drop if we only wrapped auto-resume in extra boot scripts.

#### Requirements and Constraints

- Five tests stay five.
- No coding in this repo.
- Auto-resume on boot may remain as crash recovery; it must not be
  scored as G-001.

#### Rationale

José’s “window is a client of a living agent” and “client/server is a
byproduct of actors” are this noun.[^jose-1] OTP already has
permanent/temporary children and attachable mailboxes. Arvo’s tree
still halts the VM when Focus returns.

#### Evidence

EVD-001, EVD-002, EVD-010, EVD-011, EVD-012, EVD-013.

#### Evidence Spikes

None in this repo. Later measure: the kill-window / attach sequence
above.

#### Tradeoffs

Daemon/release boot is a product-shape change (`mix run --no-halt` is
why halt-on-quit exists). A living Session without a tile is a
headless process that must be findable and killable on purpose.

#### Failure Modes

Scoring JSONL auto-resume as a keep (REC-003). Session still naming
`Arvo.TUI` so “headless attach” imports a TUI module (H-169).

#### Alternatives Considered

- HTTP/OpenCode clone as the primary attach (Refuse H-137) — rejected
  as architecture; the OTP move is another mailbox.
- Only flip `:halt_on_focus_quit` without a boot change — leaves
  `mix run --no-halt` as a zombie VM (H-165). Insufficient alone.

#### Downstream Implications

Leftovers may cite “surfaces are clients” only after this report is
accepted. Phase-2 first tries G-001 after the Arvo smoke check
*there*.

#### Revisit Triggers

Arvo commit that removes `:halt_on_focus_quit` or adds attach; OTP
supervisor/docs change; owner amends G-001.

---

### REC-002 — G-001 host recipe: permanent Session, temporary attach, no halt-on-quit

- **Classification:** Default
- **Applies to:** Sibling-repo G-001 implementation *there*; not a
  ticket in this repo
- **Confidence:** Medium
- **Decision urgency:** Required before implementation
- **Evidence quality:** Moderate
- **Related decisions:** None

#### Recommendation

When phase-2 builds G-001, use: Session `permanent` (or equivalent
always-on named process); Focus / attach `temporary`; stop
`:halt_on_focus_quit`; boot a daemon / release / `run_erl` so the VM
is not `mix run --no-halt`; clients join via `:pg` or Registry;
Session does not import a TUI module; `os_signal` kills the tile, not
the VM.

#### Claim

The OTP supervision and boot shape above is the host recipe that would
make “quit window, attach later” a process fact rather than a file
fact.

#### Host primitive

G-001

#### Why Watch

Not Watch — host recipe for G-001.

#### Later measure

Same as REC-001, plus: after quit, `nodes()` / local pid table still
has Session; a new attach process registers in `:pg`/Registry and
receives subsequent events; SIGTERM on the tile executable does not
`init:stop` the brain.

#### Keep / drop

Keep this recipe if REC-001’s measure passes with it. Drop a boot
script that only re-runs auto-resume and calls that “attach.”

#### Requirements and Constraints

- Do not make Phoenix LiveView the default UI.
- Human IEx on the brain is a dev-only client (H-037), not a product
  surface.

#### Rationale

OTP restart types and process groups are the documented nouns.[^otp-supervisor][^otp-pg]
Arvo already starts Focus unlinked; the remaining rot is halt-on-quit,
`mix run --no-halt`, and Session naming `Arvo.TUI`.

#### Evidence

EVD-003, EVD-010, EVD-011, EVD-012, EVD-014, EVD-015.

#### Evidence Spikes

None in this repo. Later measure as above.

#### Tradeoffs

A release/`run_erl` boot is more moving parts than a Mix script. Worth
it if and only if attach is real.

#### Failure Modes

TUI→Session synchronous `get` remains and deadlocks under attach
(H-170). Two Focuses steal the turn mutex (H-075 is the read-only
cousin).

#### Alternatives Considered

- Keep Focus as a supervised `permanent` child — rejected: quitting
  the window would then restart the tile, not detach.
- HTTP attach as primary — rejected (Refuse H-137).

#### Downstream Implications

Phase-2 smoke check must not treat “arvo boots a TUI” as G-001.

#### Revisit Triggers

New boot entry in Arvo; decision to ship `arvo up` / `attach` /
`detach`.

---

### REC-003 — Reject JSONL auto-resume as G-001

- **Classification:** Rejected
- **Applies to:** Catalog honesty for G-001
- **Confidence:** High (user decision + definition)
- **Decision urgency:** Required now
- **Evidence quality:** Strong (lock)
- **Related decisions:** None

#### Recommendation

Do not score “we re-read the JSONL on next `bin/arvo`” as G-001.

#### Claim

Same-cwd auto-resume after a VM death is crash recovery. G-001 is
attach to a process that never died.

#### Host primitive

G-001

#### Why Watch

Not Watch — this is a Refuse of a false keep, not a Watch card.

#### Later measure

If the Session pid is gone and a new VM reloads JSONL, record
**drop** for G-001 even if the chat looks continuous.

#### Keep / drop

Drop that design as a G-001 keep. Crash recovery may still exist
beside G-001.

#### Requirements and Constraints

JSONL remains the crash boundary (H-032). Silent history loss is still
forbidden.

#### Rationale

Blueprint §5 and SORT G-001 already draw this line. Arvo already
auto-resumes on interactive boot.[^arvo-app] That feature can fool a
careless scorer.

#### Evidence

EVD-001, EVD-013.

#### Evidence Spikes

None in this repo. Later measure: the Session-pid-gone / JSONL-reload drop above.

#### Tradeoffs

Operators still need crash recovery. Name it separately.

#### Failure Modes

A boot wrapper that kills and restarts the VM, then auto-resumes, sold
as “tmux-like attach.”

#### Alternatives Considered

- Count auto-resume as a partial keep — rejected; the catalog would lie.

#### Downstream Implications

Score-harness must not treat resume-on-boot as the G-001 primary.

#### Revisit Triggers

Owner amends G-001 (material; amendment protocol).

---

### REC-004 — G-002 ladder: keep the thinnest layer that later passes

- **Classification:** Required
- **Applies to:** Sibling-repo test G-002
- **Confidence:** Medium
- **Decision urgency:** Required now
- **Evidence quality:** Moderate
- **Related decisions:** None

#### Recommendation

Treat G-002 as an isolation **ladder** (process → Port → hidden
`:peer` → Docker). Phase-2 keeps the thinnest rung that passes (a)
hands cannot read keys / cookie / Session state, (b) kill hands
mid-tool leaves Session + JSONL, (c) the same task still works.
Score hidden BEAM and container as different threats.

#### Claim

Location, not allowlist, is the fence. A thicker rung that only adds
latency is a drop.

#### Host primitive

G-002

#### Why Watch

Not Watch — headline test G-002.

#### Later measure

Same Harbor attention task; topology is the only variable. Negative
key test. Kill hands mid-tool. No orphan `bash -c`. Report which rung
first passed (a)+(b)+(c).

#### Keep / drop

Keep that thinnest passing rung. Drop a layer that only adds latency.
Drop if “hands” is a Port wrapping a foreign harness (REC-006).

#### Requirements and Constraints

- Lab first for landing in `arvo/`.
- Shared cookie is not a fence (REC-005).
- `:erpc` on hands, if used, is read-only and allowlisted, or replaced
  by a protocol we own (H-017).
- Hands never holds the Session pid (H-014).

#### Rationale

OTP documents each rung and explicitly weakens cookies.[^otp-dist][^otp-ports][^otp-peer]
José named Docker as an example location, not a starting requirement.[^jose-1]
Arvo today has none of the VM/container rungs.

#### Evidence

EVD-001, EVD-004, EVD-005, EVD-006, EVD-016, EVD-017, EVD-018, EVD-019.

#### Evidence Spikes

None in this repo. Later measure: the topology sweep above.

#### Tradeoffs

Thinner is cheaper and easier to attach; thicker survives worse
neighbors. Starting thick hides whether the runtime gift was enough.

#### Failure Modes

Docker-first because papers do. Scoring a hidden node as a bash jail.

#### Alternatives Considered

- Process-only forever — may fail the key test; keep as first try, not
  as the lock.
- WASM / Luerl as the fence — Watch (H-026); do not assume.
- Firecracker / E2B as architecture — locations, not frameworks.

#### Downstream Implications

Leftovers “capability pids” and “worktree + node” sit on this ladder
after this report is accepted.

#### Revisit Triggers

Phase-2 measure; new OTP distribution/cookie docs; owner picks a
mandatory container.

---

### REC-005 — Reject a shared cookie as a fence

- **Classification:** Rejected
- **Applies to:** Any G-002 node design
- **Confidence:** High (dated primary read of OTP security section)
- **Decision urgency:** Required before implementation
- **Evidence quality:** Strong (document)
- **Related decisions:** None

#### Recommendation

Do not treat a shared magic cookie (including release cookie
`"arvo_headless"`) as isolation or auth.

#### Claim

OTP cookies decide which nodes may connect. They are not
cryptographically strong; traffic is cleartext by default; a matching
cookie plus `:erpc` is remote `apply` on the peer.

#### Host primitive

G-002

#### Why Watch

Not Watch — Refuse H-012 / H-175.

#### Later measure

From the hands node, attempt `:erpc:call(Brain, Application, get_env, [:arvo, :something])`
and read of `XAI_API_KEY`. If it succeeds, the cookie/API is not a
fence — **drop** that pairing.

#### Keep / drop

Drop shared-cookie designs. A *per-session* cookie may be a pairing
capability only with a narrow API and no Session pid on hands; still
not TLS, still not authn.

#### Requirements and Constraints

- Do not start distributed nodes without understanding OTP’s TLS
  warning.[^otp-dist]
- Delete or randomize `"arvo_headless"` before any node story (H-175).

#### Rationale

OTP says so in those words.[^otp-dist][^otp-erpc]

#### Evidence

EVD-004, EVD-006, EVD-019.

#### Evidence Spikes

None in this repo. Later measure: the hands `:erpc` / key-read drop above.

#### Tradeoffs

Per-session cookies and `-connect_all false` / `-hidden` are more
setup than one `.erlang.cookie`.

#### Failure Modes

Copying Livebook’s cluster instinct with one lab cookie.

#### Alternatives Considered

- TLS distribution as day-one — optional hardening, not the G-002
  headline; do not become an ops program (Blueprint omitted ops track).

#### Downstream Implications

Phase-2 node tests must include the negative `:erpc` case.

#### Revisit Triggers

OTP changes cookie/TLS defaults; Arvo removes the fixed release cookie.

---

### REC-006 — Reject Port-wrapping a foreign harness as G-002 hands

- **Classification:** Rejected
- **Applies to:** G-002 “what counts as hands”
- **Confidence:** High (user decision)
- **Decision urgency:** Required now
- **Evidence quality:** Strong (lock)
- **Related decisions:** None

#### Recommendation

A Port around Claude Code, another TS CLI, or `jido_harness` is a
shell. It is not BEAM-native hands.

#### Claim

Adaptation uses OTP locations. Wrapping someone else’s harness in a
Port does not spend those locations.

#### Host primitive

G-002

#### Why Watch

Not Watch — Refuse H-107 / H-200.

#### Later measure

If the “hands” process’s argv is a foreign coding-agent CLI, record
**drop** regardless of key-test cosmetics.

#### Keep / drop

Drop. A Port may still carry *bash* or an official Python RLM env on
hands (DISCOVERY-NOTES E3 / RLM default) without becoming the harness.

#### Requirements and Constraints

Blueprint §7 item 9; Charter anti-pattern Port-as-native.

#### Rationale

José’s gift is distribution and processes, not “we have Ports so we
can vendor a TS agent.”

#### Evidence

EVD-001, EVD-005.

#### Evidence Spikes

None in this repo. Later measure: the foreign-CLI argv drop above.

#### Tradeoffs

A shell would show a demo faster and prove nothing this lab exists to
learn.

#### Failure Modes

Renaming the Port “Hands.API.”

#### Alternatives Considered

- Temporary Port-wrap as a spike in phase-2 — still a shell; do not
  let it become architecture (Charter §7).

#### Downstream Implications

Synthesis must not accept a REQ that names a foreign CLI as hands.

#### Revisit Triggers

Owner explicitly amends the shell rule.

---

### REC-007 — Docker node is an optional thicker G-002 rung

- **Classification:** Optional
- **Applies to:** Sibling-repo G-002 arm, only after a hidden node is
  scored
- **Confidence:** Medium
- **Decision urgency:** May defer
- **Evidence quality:** Moderate
- **Related decisions:** None

#### Recommendation

After (or beside) a hidden `:peer` measure, a Docker-hosted node is
allowed as a **separate** threat (bash jail / filesystem). It is not
the default keep and not day-one architecture.

#### Claim

Hidden BEAM ≠ Linux namespace. José’s Docker example is a location,
not a requirement.

#### Host primitive

G-002

#### Why Watch

Not a new headline. Optional thicker rung of G-002. Vendor boxes
(E2B, Firecracker, …) stay Watch until this arm needs a specific box.

#### Later measure

Same task on hidden `:peer` vs `:peer` whose `exec` is `docker run`.
Score honesty, key isolation, kill-hands, wall time. Do not let side
latency keep the thicker arm.

#### Keep / drop

Keep Docker only if it passes a threat the hidden node failed. Drop if
it only adds latency.

#### Requirements and Constraints

Land in `arvo/`: lab first. FLAME / Fly as elastic hands stays study
(H-021).

#### Rationale

`:peer` documents Docker `exec` as a supported start mechanism.[^otp-peer]
Livebook’s Fly/Kubernetes runtimes are documented cousins, not Arvo
UI.[^livebook-runtime]

#### Evidence

EVD-004, EVD-007, EVD-018, EVD-024.

#### Evidence Spikes

None in this repo. Later measure: the hidden-node vs Docker `exec` sweep above.

#### Tradeoffs

Real bash isolation vs operational weight.

#### Failure Modes

Swallowing Loopyard/E2B as architecture (Translate “worktree + node”).

#### Alternatives Considered

- Docker as the first rung — rejected (popularity / paper habit).

#### Downstream Implications

Score-harness may add a topology tag; it must not merge this with
G-004.

#### Revisit Triggers

Hidden-node measure fails a filesystem/egress threat.

---

### REC-008 — Native code and bash live on hands, never on the brain

- **Classification:** Default
- **Applies to:** G-002 placement of FFF / NIFs / `bash`
- **Confidence:** Medium
- **Decision urgency:** Required before implementation
- **Evidence quality:** Moderate
- **Related decisions:** None

#### Recommendation

Move file-search NIF and bash off the Session VM onto the hands
location that G-002 keeps. A dirty-scheduler or NIF crash must not
take Session with it.

#### Claim

The flagship plugin in the Arvo tree is a NIF on the brain — the worst
placement for brains vs hands (H-174).

#### Host primitive

G-002

#### Why Watch

Not Watch — placement rule for G-002.

#### Later measure

Crash or unload the NIF / kill bash on hands; Session pid + JSONL
live. Hands still cannot read keys.

#### Keep / drop

Keep this placement if G-002’s thinnest passing rung can host the NIF
and bash. Drop a design that “isolates” tools but leaves FFF loaded in
`:arvo` on the brain.

#### Requirements and Constraints

Reject plugin `on_load` on the brain (G-003). Port *drivers* can crash
the VM — do not “isolate” by writing a brain-side driver.[^otp-ports]

#### Rationale

OTP: an erroneous port driver crashes the runtime; NIFs are in-VM.
Location is the only honest fence for native code.

#### Evidence

EVD-005, EVD-016, EVD-017, EVD-020.

#### Evidence Spikes

None in this repo. Later measure: crash NIF / kill bash on hands; Session + JSONL live.

#### Tradeoffs

FFF today is compiled into `:arvo` because Rustler `otp_app` is
`:arvo`. Moving it is a real packaging change — later, not here.

#### Failure Modes

Loading the NIF on both nodes “for convenience.”

#### Alternatives Considered

- Keep FFF on brain, isolate only bash — fails the NIF crash domain.

#### Downstream Implications

G-003 must not `load_binary` a NIF module into the Session VM.

#### Revisit Triggers

Arvo splits FFF into a hands-only app; Rustler packaging changes.

---

### REC-009 — G-003 is load_binary + two versions + soft_purge; Mix out; no relups

- **Classification:** Required
- **Applies to:** Sibling-repo test G-003
- **Confidence:** Medium
- **Decision urgency:** Required now
- **Evidence quality:** Moderate
- **Related decisions:** None

#### Recommendation

A real plugin swap loads `.beam` with `:code.load_binary/3` (or
`prepare_loading` / `finish_loading` if several modules must flip
together), keeps two versions so the in-flight turn stays on old code,
then `soft_purge` after the turn. Mix is not in the product VM. OTP
relups are not the plugin story. Profile switch still set-diffs the
supervision tree.

#### Claim

Session mailbox does not drop; in-flight turn finishes on old modules;
next turn sees the new manifest.

#### Host primitive

G-003

#### Why Watch

Not Watch — headline test G-003.

#### Later measure

H-122: mailbox intact; old code for in-flight turn; new manifest next
turn. Name the prefix-cache break (P-018, XB-002). Measure hot-reload
latency.

#### Keep / drop

Keep if Mix leaves the product VM and the swap is real. Drop if this
is `Code.append_path` plus hope, or if cache-break cost eats the win.

#### Requirements and Constraints

- Load `.beam` only. Reject `on_load`. No new atoms from user strings.
- Do not swap mid-turn (H-033).
- Do not use SASL `release_handler` / `relup` as the mechanism
  (REC-011).

#### Rationale

This is what the code server already is.[^otp-code-loading][^otp-code]
Arvo’s loader is Mix + path (H-173). Relups are a different OTP
product.[^otp-relup]

#### Evidence

EVD-001, EVD-008, EVD-009, EVD-021, EVD-022, EVD-023.

#### Evidence Spikes

None in this repo. Later measure as above.

#### Tradeoffs

Prebuilding `.beam` (CI / a workshop Mix) vs compiling live. Fully
qualified calls needed to flip to current — plugin loops must be
written for that, or the turn stays on old forever.

#### Failure Modes

Third load hard-purges and kills the in-flight turn (RSK-007).
`on_load` pulls a NIF into the brain.

#### Alternatives Considered

- Mix.install in the live app — workshop luxury (H-082), not product.
- Recycle a plugin OS process (Pi) — existence proof of need, not the
  BEAM move.

#### Downstream Implications

Leftovers “profile as machine / Voyager skills” sit on this primitive.

#### Revisit Triggers

Arvo grows a `.beam`-only loader; OTP code-server semantics change.

---

### REC-010 — Reject Mix-in-VM and append_path-plus-hope as G-003

- **Classification:** Rejected
- **Applies to:** G-003 keep/drop
- **Confidence:** High (user decision + dated source + Elixir docs)
- **Decision urgency:** Required now
- **Evidence quality:** Strong for “what the tree/docs say”
- **Related decisions:** None

#### Recommendation

Do not keep a design whose live path is `mix compile` inside the
product VM, or `Code.append_path` without two-version + purge
discipline.

#### Claim

`Code.append_path` only adds a directory to the code path. It does not
keep an in-flight turn on old modules.

#### Host primitive

G-003

#### Why Watch

Not Watch — drop rule already in Blueprint §5.

#### Later measure

If the swap command shells out to Mix on the brain node, or only
appends ebin and `ensure_loaded`, record **drop**.

#### Keep / drop

Drop.

#### Requirements and Constraints

Tests may skip compile when ebin already exists — that shortcut is not
a product keep.

#### Rationale

Elixir documents `append_path` as a path list mutation.[^elixir-code]
Arvo’s loader is that mutation plus Mix.[^arvo-loader]

#### Evidence

EVD-009, EVD-021.

#### Evidence Spikes

None in this repo. Later measure: Mix on brain or path-only → drop, as above.

#### Tradeoffs

None that justify Mix in the product VM.

#### Failure Modes

“We compiled once in CI then append_path” sold as hot swap without
proving two versions.

#### Alternatives Considered

- Compile on hands, load_binary on brain — still G-003; Mix is off the
  *product* VM. Allowed later if the measure passes.

#### Downstream Implications

Phase-2 must not green a Mix-in-VM demo.

#### Revisit Triggers

Owner amends G-003.

---

### REC-011 — Reject OTP relups as the plugin story

- **Classification:** Rejected
- **Applies to:** G-003 mechanism
- **Confidence:** High (user decision + dated OTP release-handling page)
- **Decision urgency:** Required now
- **Evidence quality:** Strong (document + lock)
- **Related decisions:** None

#### Recommendation

Do not implement G-003 with `.appup` / `relup` /
`release_handler:install_release/1`.

#### Claim

Release handling upgrades an entire OTP release (and sometimes the
emulator). Plugin swap is two-version modules on one Session.

#### Host primitive

G-003

#### Why Watch

Not Watch — Refuse H-131.

#### Later measure

If the design requires SASL release_handler or `restart_new_emulator`
to change a plugin, record **drop**.

#### Keep / drop

Drop relups as the plugin story. Relups remain a Watch/study item for
unrelated release engineering.

#### Requirements and Constraints

Blueprint §6: do not put OTP relups at the center of the architecture.

#### Rationale

OTP’s own workflow is unpack → install_release → make_permanent, with
appup instructions and possible emulator restart.[^otp-relup] That is
not “next turn sees new tools.”

#### Evidence

EVD-001, EVD-008.

#### Evidence Spikes

None in this repo. Later measure: release_handler / relup required → drop, as above.

#### Tradeoffs

Relups give synchronized `code_change` for gen_servers. Session should
not need that to flip a tool module; if it does, the Session is
entangled with plugin internals.

#### Failure Modes

“We already have SASL in the release, so use it.”

#### Alternatives Considered

- `sys:change_code` on Session for constitution-only updates — not
  G-003; constitution is data (`persistent_term`, H-087).

#### Downstream Implications

Reviews must attack relups-as-plugins if they reappear.

#### Revisit Triggers

Owner amends the Refuse row.

## 10. Evidence Ledger

| ID | Claim | Classification | Source or spike | Tier | Date | Access | Confidence | Limitations | Contradictory evidence | Downstream | Revalidation trigger |
| -- | ----- | -------------- | --------------- | ---- | ---- | ------ | ---------- | ----------- | ---------------------- | ---------- | -------------------- |
| EVD-001 | Five tests and runtime locks are accepted user decisions | User decision | [Blueprint](../00-program-blueprint.md) §5, §7; [Charter](../01-research-charter.md) §1 | 1 (lock) | 2026-08-14 / 15 | 2026-08-15 | High | Not evidence the tests pass | None | REC-001–011 | Amendment of Blueprint §7 |
| EVD-002 | José named plugins-without-drop-state, actors⇒clients, brains vs hands / Livebook | Official claim | [tweet 2088186994849468659](https://x.com/josevalim/status/2088186994849468659); [tweet 2088208133487264078](https://x.com/josevalim/status/2088208133487264078) | 1 | 2026-08-14 | 2026-08-15 | High as *wording* | Not a measurement | None | REC-001, REC-004, REC-009 | New José thread that retracts |
| EVD-003 | `permanent` / `temporary` / `transient` restart types | Verified fact about document | [supervisor](https://www.erlang.org/doc/apps/stdlib/supervisor.html) OTP 29.0.5 | 1 | OTP 29.0.5 | 2026-08-15 | High | Does not prove Arvo’s tree uses them | None | REC-002 | OTP supervisor change |
| EVD-004 | Hidden nodes, non-transitive connections, cookie pairing, TLS warning, cookies not crypto-strong | Verified fact about document | [Distributed Erlang](https://www.erlang.org/doc/system/distributed.html) OTP 29.0.5 | 1 | OTP 29.0.5 | 2026-08-15 | High | Docs ≠ a cluster we ran | None | REC-004, REC-005, REC-007 | OTP distribution change |
| EVD-005 | Ports talk to an OS process; buggy port drivers can crash the VM | Verified fact about document | [Ports](https://www.erlang.org/doc/system/ports.html) OTP 29.0.5 | 1 | OTP 29.0.5 | 2026-08-15 | High | Does not bless Port-as-harness | None | REC-004, REC-006, REC-008 | OTP ports change |
| EVD-006 | `:erpc:call` is remote `apply` | Verified fact about document | [erpc](https://www.erlang.org/doc/apps/kernel/erpc.html) OTP 29.0.5 | 1 | OTP 29.0.5 | 2026-08-15 | High | We did not invoke erpc | None | REC-005 | OTP erpc change |
| EVD-007 | Livebook standalone = new VM node per notebook, isolated from the UI node | Official claim | [Livebook runtimes](https://livebook.hexdocs.pm/runtime.html) v0.19.9 | 1 | 0.19.9 | 2026-08-15 | High as *Livebook’s claim* | Not Arvo; not a measurement | None | REC-004, REC-007 | Livebook runtime rewrite |
| EVD-008 | Relups upgrade a whole release via appup/relup/release_handler; may restart the emulator | Verified fact about document | [Release Handling](https://www.erlang.org/doc/system/release_handling.html) OTP 29.0.5 | 1 | OTP 29.0.5 | 2026-08-15 | High | Wrong tool for plugins (judgment) | None | REC-009, REC-011 | OTP SASL change |
| EVD-009 | Two-version modules; third load purges and kills lingerers; `load_binary`; `soft_purge`; `on_load` | Verified fact about document | [Code loading](https://www.erlang.org/doc/system/code_loading.html); [code](https://www.erlang.org/doc/apps/kernel/code.html) OTP 29.0.5 | 1 | OTP 29.0.5 | 2026-08-15 | High | We did not load a module | None | REC-009, REC-010 | OTP code-server change |
| EVD-010 | Arvo HEAD is `84004e1…` on 2026-08-15 | Verified fact about git | `git rev-parse HEAD` in `../coding-agent-harness/arvo` | 1 | 2026-08-15 | 2026-08-15 | High | Tree can move | None | all Arvo rows | New Arvo commit |
| EVD-011 | App children + Focus `Task.start` + halt-on-quit comment | Verified fact about source | [`application.ex`](../../../coding-agent-harness/arvo/lib/arvo/application.ex) | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven | None | REC-001, REC-002 | File change |
| EVD-012 | Focus default halt is `System.stop/1` | Verified fact about source | [`focus.ex`](../../../coding-agent-harness/arvo/lib/arvo/tui/focus.ex) `halt_after_focus/0` | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven | Tests force false — does not change product default | REC-001, REC-002 | File change |
| EVD-013 | Interactive boot auto-resumes last same-cwd JSONL | Verified fact about source | [`application.ex`](../../../coding-agent-harness/arvo/lib/arvo/application.ex) `maybe_auto_resume/1` | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven | Headless disables auto-resume | REC-003 | File change |
| EVD-014 | `bin/arvo` execs `mix run --no-halt` | Verified fact about source | [`bin/arvo`](../../../coding-agent-harness/arvo/bin/arvo) | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven | None | REC-002 | Boot change |
| EVD-015 | Session names `Arvo.TUI`; TUI calls `Session.get` | Verified fact about source | [`session.ex`](../../../coding-agent-harness/arvo/lib/arvo/session.ex); [`tui.ex`](../../../coding-agent-harness/arvo/lib/arvo/tui.ex) | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven; named deadlock doc **absent** at this HEAD | 2026-08-14 snapshot cited a markdown file that is not here | REC-002 | File change |
| EVD-016 | Agent is not a process; tools sequential via `Tool.invoke` | Verified fact about source | [`agent.ex`](../../../coding-agent-harness/arvo/lib/arvo/agent.ex) | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven | None | REC-004, REC-008 | File change |
| EVD-017 | Bash is `System.cmd("bash", ["-c", …])` | Verified fact about source | [`bash.ex`](../../../coding-agent-harness/arvo/lib/arvo/tools/bash.ex) | 1 | 2026-08-15 | 2026-08-15 | High | Orphan hypothesis unproven | None | REC-004, REC-008 | File change |
| EVD-018 | No `Node` / `:peer` / `net_kernel` in `lib/` | Verified fact about this checkout | ripgrep over `arvo/lib` 2026-08-15 | 1 | 2026-08-15 | 2026-08-15 | High | Could exist outside `lib/` | Release cookie only | REC-004 | Tree change |
| EVD-019 | Release cookie `"arvo_headless"` | Verified fact about source | [`mix.exs`](../../../coding-agent-harness/arvo/mix.exs) `releases` | 1 | 2026-08-15 | 2026-08-15 | High | Unused until distribution is on | None | REC-005 | mix.exs change |
| EVD-020 | FFF NIF `otp_app: :arvo`; activate `ensure_loaded(Fff.Native)` | Verified fact about source | [`native.ex`](../../../coding-agent-harness/arvo/lib/fff/native.ex); [`plugin.ex`](../../../coding-agent-harness/arvo/plugins/fff/lib/fff/plugin.ex) | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven | None | REC-008 | FFF packaging change |
| EVD-021 | Plugin load is Mix compile + `Code.append_path` | Verified fact about source | [`loader.ex`](../../../coding-agent-harness/arvo/lib/arvo/plugins/loader.ex) | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven | ebin-present skips Mix | REC-009, REC-010 | Loader change |
| EVD-022 | `Code.append_path` only appends a code-path directory | Verified fact about document | [Code](https://elixir.hexdocs.pm/Code.html) Elixir 1.20.3 | 1 | 1.20.3 | 2026-08-15 | High | Not a swap primitive | None | REC-010 | Elixir Code change |
| EVD-023 | Profile switch set-diffs plugins; children under DynamicSupervisor | Verified fact about source | [`profiles.ex`](../../../coding-agent-harness/arvo/lib/arvo/profiles.ex); [`registry.ex`](../../../coding-agent-harness/arvo/lib/arvo/plugins/registry.ex) | 1 | 2026-08-15 | 2026-08-15 | High | Function unproven | None | REC-009 | File change |
| EVD-024 | `:peer` starts linked nodes; `exec` may be Docker; dies when control connection dies | Verified fact about document | [peer](https://www.erlang.org/doc/apps/stdlib/peer.html) OTP 29.0.5 | 1 | OTP 29.0.5 | 2026-08-15 | High | We did not start a peer | Docs emphasize Common Test | REC-004, REC-007 | OTP peer change |
| EVD-025 | `:pg` is a process-group membership service | Verified fact about document | [pg](https://www.erlang.org/doc/apps/kernel/pg.html) OTP 29.0.5 | 1 | OTP 29.0.5 | 2026-08-15 | High | Not used in Arvo | None | REC-002 | OTP pg change |
| EVD-026 | SORT Graduate G-001…G-003 measure/keep-drop match Blueprint §5 | Verified fact | [SORT.md](../working/SORT.md) Graduate table compared to [Blueprint](../00-program-blueprint.md) §5 | 4 (framing source) | 2026-08-14 | 2026-08-15 | High as *wording* | Not governing after Blueprint; not a passing test | None | all RECs | Re-sort (forbidden unless amended) |
| EVD-027 | Grounding snapshot 2026-08-14 matches this HEAD on halt, Mix plugins, in-process tools, FFF-on-brain, no attach | Verified fact about source vs notes | [DISCOVERY-NOTES](../working/DISCOVERY-NOTES.md) grounding snapshot; this checkout | 1 (tree) / 4 (notes) | 2026-08-14 / 15 | 2026-08-15 | High for *match* | Function unproven; deadlock markdown missing | Deadlock file path stale | checkout table | New snapshot |
| EVD-028 | Exa MCP search/fetch ran; Exa Agent did not (401) | Verified fact about this session’s retrieval | Exa MCP `exa-search-server` 3.2.1 via `https://mcp.exa.ai/mcp` | n/a (tool) | 2026-08-15 | 2026-08-15 | High | Not a source; Agent unauthenticated | REST `/search` 402 without key | Methodology | Exa auth changes |

Every Arvo-tree row: **function is unproven.**

## 11. Recommendation ledger

| ID | Title | Test | Classification | Confidence | Later measure |
| -- | ----- | ---- | -------------- | ---------- | ------------- |
| REC-001 | Name G-001 as attach to a living Session | G-001 | Required | High lock / Medium pass | Kill tile; Session+JSONL live; new client continues; honesty hold |
| REC-002 | Permanent Session, temporary attach, no halt-on-quit | G-001 | Default | Medium | REC-001 plus pid still registered; signal kills tile not VM |
| REC-003 | Reject JSONL auto-resume as G-001 | G-001 | Rejected | High | If pid died and JSONL reloaded → drop |
| REC-004 | Thinnest isolation ladder that passes | G-002 | Required | Medium | Same task; keys; kill-hands; no orphan bash |
| REC-005 | Reject shared cookie as fence | G-002 | Rejected | High | Hands `:erpc` / env read of keys → drop |
| REC-006 | Reject Port-wrap foreign harness | G-002 | Rejected | High | Foreign CLI argv → drop |
| REC-007 | Docker node optional thicker rung | G-002 | Optional | Medium | Hidden node vs Docker `exec`; side latency cannot keep |
| REC-008 | NIF and bash on hands | G-002 | Default | Medium | Crash NIF/kill bash; Session lives |
| REC-009 | load_binary + two versions + soft_purge; Mix out | G-003 | Required | Medium | Mailbox; old code in-flight; new manifest next; name cache-break |
| REC-010 | Reject Mix-in-VM / append_path hope | G-003 | Rejected | High | Mix on brain or path-only → drop |
| REC-011 | Reject OTP relups as plugins | G-003 | Rejected | High | release_handler / relup required → drop |

## 12. Risks

### RSK-001 — In the tree ⇒ works

- **Description:** Readers treat this report’s Arvo paths as a passing product.
- **Likelihood:** High
- **Impact:** High
- **Mitigation:** Checkout-vs-function table; every tree ledger row states function unproven.
- **Owner:** runtime report; later reviewers
- **Trigger:** Synthesis writes REQs as if Arvo already attaches / isolates / hot-loads

### RSK-002 — Docker-first because papers do

- **Description:** Phase-2 starts G-002 at a container because papers and vendor boxes do, skipping thinner rungs.
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** REC-004 thinnest-that-passes; REC-007 optional
- **Owner:** phase-2
- **Trigger:** First G-002 sketch starts in Compose

### RSK-003 — Port-as-native

- **Description:** A Port around a foreign coding-agent CLI is catalogued as BEAM-native hands.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** REC-006; Charter anti-pattern
- **Owner:** runtime + synthesis
- **Trigger:** A foreign CLI appears under `Hands`

### RSK-004 — Relups as the plugin story

- **Description:** G-003 is implemented with SASL `relup` / `release_handler` instead of two-version modules.
- **Likelihood:** Low
- **Impact:** High
- **Mitigation:** REC-011
- **Owner:** runtime + reviews
- **Trigger:** SASL release_handler in a G-003 design

### RSK-005 — G-001 collapsed to auto-resume

- **Description:** JSONL reload after a VM death is scored as “attach to a living Session.”
- **Likelihood:** High
- **Impact:** High
- **Mitigation:** REC-003
- **Owner:** score-harness (later) + phase-2
- **Trigger:** A keep recorded after `bin/arvo` relaunch only

### RSK-006 — Shared cookie treated as a fence

- **Description:** A shared magic cookie (including `"arvo_headless"`) is treated as isolation or auth.
- **Likelihood:** High if anyone turns distribution on
- **Impact:** High
- **Mitigation:** REC-005; H-175
- **Owner:** phase-2
- **Trigger:** `cookie: "arvo_headless"` left in a live node story

### RSK-007 — Third load hard-purges the in-flight turn

- **Description:** Loading a third copy of a plugin module purges old code and kills the process still running it.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** REC-009: no third version until `soft_purge` after the turn
- **Owner:** phase-2 G-003
- **Trigger:** Two swaps during one turn

### RSK-008 — Mix remains in the product VM after a “swap”

- **Description:** A demo still shells `mix compile` on the brain and is recorded as a G-003 keep.
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** REC-010
- **Owner:** phase-2
- **Trigger:** Loader still shells `mix compile`

### RSK-009 — Cleartext distribution / accidental cluster

- **Description:** Turning on nodes without hidden/per-session pairing (or TLS awareness) exposes the brain.
- **Likelihood:** Medium once nodes exist
- **Impact:** High
- **Mitigation:** Hidden + per-session cookie + no shared `.erlang.cookie`; OTP TLS warning recorded, not solved here
- **Owner:** phase-2
- **Trigger:** First `:peer` start

## 13. Weak evidence

- Any sentence of the form “this would work on BEAM” — hypothesis until phase-2.
- José’s Livebook analogy — official claim, not a measured harness.
- OpenCode / Pi — need, not architecture.
- 2026-08-14 deadlock markdown path — stale; coupling is inferred from source, not from that file.
- Orphan `bash -c` (H-171) — plausible from `System.cmd` + `Task.shutdown`, not observed.
- Prefix-cache break cost — named, not measured (leftover P-018 / XB-002).
- Exa Agent / deep-reasoning — did not run (401). Ordinary Exa search/fetch did.

## 14. Conflicting evidence

| Tension | Resolution in this catalog |
| ------- | -------------------------- |
| José: client/server “similar to OpenCode” vs Refuse HTTP-as-primary | Need is attach; host noun is another mailbox, not Hono |
| José: Pi-like reload vs OTP two-version modules | Need is no-drop-state; host noun is the code server, not process recycle |
| José: Docker example vs thinnest ladder | Docker is an optional thicker rung (REC-007) |
| Livebook standalone starts Mix.install on the notebook node vs “Mix out of the product VM” | Livebook’s notebook node is not Arvo’s Session VM; do not copy Mix.install onto the brain |
| Grounding snapshot cites a deadlock doc that is not in `84004e1` | Treat the doc path as stale; treat Session↔TUI calls as current source |
| `Task.start` Focus is already unlinked vs quit still halt | Unlinked client is necessary, not sufficient (H-165) |
| Cookie can be per-node (OTP) vs “cookie is not a fence” | Pairing ≠ isolation; REC-005 |

No conflict authorizes merging two headline tests.

## 15. Assumptions

1. The sibling experiment repo, not this tree, will run the later measures.
2. Arvo remains the instrument path unless the owner says otherwise.
3. OTP 29.0.5 / Elixir 1.20.3 wording is current as of 2026-08-15.
4. Harbor attention honesty remains the honesty scoreboard when phase-2 scores G-001/G-002 (H-167). This report does not design that scorer (score-harness track).
5. Intake stays closed; no new paper dump changes these nouns.
6. Exa retrieval did not invent official URLs — each cited page was opened.

## 16. Open questions

### OQ-001 — Does quit actually halt a running product VM?

- **Blocking?** No
- **Owner:** phase-2
- **Resolution path:** Later measure in REC-001 (do not run here)
- **Deadline:** Sibling-repo standup / first G-001 run

### OQ-002 — Which ladder rung is actually thinnest that passes?

- **Blocking?** No
- **Owner:** phase-2
- **Resolution path:** REC-004 sweep
- **Deadline:** First G-002 run

### OQ-003 — What boot (`run_erl` / release / systemd) makes attach possible without a zombie `mix run --no-halt`?

- **Blocking?** No for the catalog; yes before a G-001 keep
- **Owner:** phase-2
- **Resolution path:** Name a boot in the experiment repo; do not design it here
- **Deadline:** Before G-001 keep

### OQ-004 — Can a plugin `.beam` that today uses `on_load` / Rustler be loaded with `load_binary` on hands without restarting the brain?

- **Blocking?** No
- **Owner:** phase-2
- **Resolution path:** REC-008 + REC-009 measures
- **Deadline:** First G-003 run that includes FFF

### OQ-005 — Does the prefix-cache break eat the G-003 UX win?

- **Blocking?** No
- **Owner:** phase-2
- **Resolution path:** Name and time the break (REC-009)
- **Deadline:** G-003 keep/drop

### OQ-006 — Do remaining TUI→Session `get` calls deadlock under a second client?

- **Blocking?** No
- **Owner:** phase-2
- **Resolution path:** Attach two clients; or invert pulls (H-170)
- **Deadline:** G-001 attach attempt

## 17. Handoff Digest

- **Decisions supported:** Blueprint §5 tests G-001…G-003 and §7 locks; Charter no-spikes / tree≠function / popularity-is-not-proof.
- **Recommendations accepted by the report:** REC-001, REC-002, REC-004, REC-008, REC-009 as the catalog’s keep-shaped set; REC-003, REC-005, REC-006, REC-010, REC-011 as required drops; REC-007 as optional thicker G-002.
- **Recommendations challenged:** None upstream (no prior `REC`s). This report challenges treating Arvo as proven, auto-resume as G-001, shared cookies as fences, Port-wrap as hands, Mix/append_path as swap, and relups as plugins.
- **Evidence strength:** Strong on locks and dated official pages / source lines. Weak/Medium on every “would work” claim.
- **Weak and conflicting evidence:** §13–§14. José vs OpenCode/Pi/Docker wording resolved as need vs host noun. Deadlock markdown path stale.
- **Assumptions:** §15.
- **Risks:** RSK-001…RSK-009.
- **Open questions:** OQ-001…OQ-006. None block *catalog* honesty.
- **Required downstream decisions:** Human accept + commit of this report before leftovers/score-harness may *cite* it. Phase-2 still starts with an Arvo smoke check *there*. Do not write leftovers or score-harness in the runtime session.
- **Relevant identifiers:** `REC-001`…`REC-011`; `RSK-001`…`RSK-009`; `OQ-001`…`OQ-006`; `EVD-001`…`EVD-028`; intake `G-001`…`G-003`; José H-001…H-006; isolation H-007…H-026; liveness H-027…H-039; surfaces H-069…H-076; plugins H-077…H-087, H-173; grounding H-153…H-175.
- **Full-report sections that must be read before deciding:** §2 (table), §8 (ladder + code-server vs relups), §9 (every `REC`), §10 (tree vs function), §14 (conflicts).

A Handoff Digest must not replace this file.

## 18. Source ledger

| Source | URL or path | Accessed | Tier |
| ------ | ----------- | -------- | ---- |
| Program Blueprint | [`docs/00-program-blueprint.md`](../00-program-blueprint.md) | 2026-08-15 | lock |
| Research Charter | [`docs/01-research-charter.md`](../01-research-charter.md) | 2026-08-15 | lock |
| SORT Graduate + José/surfaces/isolation | [`docs/working/SORT.md`](../working/SORT.md) | 2026-08-15 | framing |
| DISCOVERY-NOTES (locked top + grounding snapshot) | [`docs/working/DISCOVERY-NOTES.md`](../working/DISCOVERY-NOTES.md) | 2026-08-15 | framing |
| José Valim, 14 Aug 2026 | https://x.com/josevalim/status/2088186994849468659 | 2026-08-15 | 1 official claim |
| José Valim, “the runtime is the framework” | https://x.com/josevalim/status/2088208133487264078 | 2026-08-15 | 1 official claim |
| OTP Distributed Erlang 29.0.5 | https://www.erlang.org/doc/system/distributed.html | 2026-08-15 | 1 |
| OTP Compilation and Code Loading 29.0.5 | https://www.erlang.org/doc/system/code_loading.html | 2026-08-15 | 1 |
| OTP `code` 29.0.5 | https://www.erlang.org/doc/apps/kernel/code.html | 2026-08-15 | 1 |
| OTP Ports 29.0.5 | https://www.erlang.org/doc/system/ports.html | 2026-08-15 | 1 |
| OTP `erpc` 29.0.5 | https://www.erlang.org/doc/apps/kernel/erpc.html | 2026-08-15 | 1 |
| OTP Release Handling 29.0.5 | https://www.erlang.org/doc/system/release_handling.html | 2026-08-15 | 1 |
| OTP `supervisor` 29.0.5 | https://www.erlang.org/doc/apps/stdlib/supervisor.html | 2026-08-15 | 1 |
| OTP `peer` 29.0.5 | https://www.erlang.org/doc/apps/stdlib/peer.html | 2026-08-15 | 1 |
| OTP `pg` 29.0.5 | https://www.erlang.org/doc/apps/kernel/pg.html | 2026-08-15 | 1 |
| OTP Processes 29.0.5 | https://www.erlang.org/doc/system/ref_man_processes.html | 2026-08-15 | 1 |
| Elixir `Code` 1.20.3 | https://elixir.hexdocs.pm/Code.html | 2026-08-15 | 1 |
| Livebook runtimes 0.19.9 | https://livebook.hexdocs.pm/runtime.html | 2026-08-15 | 1 |
| Arvo checkout | `../coding-agent-harness/arvo` @ `84004e1fcae11bbf72656c58e7fa5ae4aa92838b` | 2026-08-15 | 1 instrument text |
| Evidence model / REC template / spike contract | `program/contracts/*`, `program/templates/recommendation.md` | 2026-08-15 | methodology |
| Exa MCP (retrieval only) | `https://mcp.exa.ai/mcp` (server 3.2.1) | 2026-08-15 | not a cited tier |

Do not cite chat, root HANDOFF, or attachment manifests as evidence.

## 19. Completion checklist

- [x] Report exists at `docs/reports/10-runtime-research-report.md`
- [x] All report-contract headings present and filled
- [x] G-001, G-002, G-003 still distinct; no G-006
- [x] Each `REC` has claim, host primitive, later measure, keep/drop
- [x] Evidence Ledger classifies tree-description vs function
- [x] No `SPK-###`; no Arvo command run as a test
- [x] Exa used (ordinary search/fetch; Agent/deep documented as 401)
- [x] Intake not reopened
- [x] Plain-language summary shown to Robert *(in the session message, not this file)*
- [ ] Human accepts report — **leave unchecked**
- [ ] Manifest updated; accepting commit recorded — **leave unchecked**

[^jose-1]: José Valim, 14 Aug 2026, https://x.com/josevalim/status/2088186994849468659 — accessed 2026-08-15.
[^jose-2]: José Valim, 14 Aug 2026, https://x.com/josevalim/status/2088208133487264078 — accessed 2026-08-15.
[^otp-dist]: Erlang/OTP 29.0.5, *Distributed Erlang*, https://www.erlang.org/doc/system/distributed.html — accessed 2026-08-15.
[^otp-code-loading]: Erlang/OTP 29.0.5, *Compilation and Code Loading*, https://www.erlang.org/doc/system/code_loading.html — accessed 2026-08-15.
[^otp-code]: Erlang/OTP 29.0.5, `code`, https://www.erlang.org/doc/apps/kernel/code.html — accessed 2026-08-15.
[^otp-ports]: Erlang/OTP 29.0.5, *Ports and Port Drivers*, https://www.erlang.org/doc/system/ports.html — accessed 2026-08-15.
[^otp-erpc]: Erlang/OTP 29.0.5, `erpc`, https://www.erlang.org/doc/apps/kernel/erpc.html — accessed 2026-08-15.
[^otp-relup]: Erlang/OTP 29.0.5, *Release Handling*, https://www.erlang.org/doc/system/release_handling.html — accessed 2026-08-15.
[^otp-supervisor]: Erlang/OTP 29.0.5, `supervisor`, https://www.erlang.org/doc/apps/stdlib/supervisor.html — accessed 2026-08-15.
[^otp-peer]: Erlang/OTP 29.0.5, `peer`, https://www.erlang.org/doc/apps/stdlib/peer.html — accessed 2026-08-15.
[^otp-pg]: Erlang/OTP 29.0.5, `pg`, https://www.erlang.org/doc/apps/kernel/pg.html — accessed 2026-08-15.
[^otp-proc]: Erlang/OTP 29.0.5, *Processes*, https://www.erlang.org/doc/system/ref_man_processes.html — accessed 2026-08-15 (opened via Exa fetch; used for mailbox/link/monitor nouns).
[^elixir-code]: Elixir 1.20.3, `Code.append_path/2`, https://elixir.hexdocs.pm/Code.html — accessed 2026-08-15.
[^livebook-runtime]: Livebook 0.19.9, *Runtimes*, https://livebook.hexdocs.pm/runtime.html — accessed 2026-08-15.
[^arvo-app]: `../coding-agent-harness/arvo/lib/arvo/application.ex` at `84004e1`, 2026-08-15.
[^arvo-bin]: `../coding-agent-harness/arvo/bin/arvo` at `84004e1`, 2026-08-15.
[^arvo-focus]: `../coding-agent-harness/arvo/lib/arvo/tui/focus.ex` at `84004e1`, 2026-08-15.
[^arvo-session]: `../coding-agent-harness/arvo/lib/arvo/session.ex` at `84004e1`, 2026-08-15.
[^arvo-agent]: `../coding-agent-harness/arvo/lib/arvo/agent.ex` at `84004e1`, 2026-08-15.
[^arvo-session-tui]: `Arvo.Session.maybe_record_usage/1` and `notify_pane_chrome/1` in `session.ex` at `84004e1`, 2026-08-15.
[^arvo-tui-get]: `Arvo.TUI` slash `"tree"` clause calling `Arvo.Session.get/0` in `tui.ex` at `84004e1`, 2026-08-15.
[^arvo-mix]: `../coding-agent-harness/arvo/mix.exs` `releases` `cookie: "arvo_headless"` at `84004e1`, 2026-08-15.
[^arvo-bash]: `../coding-agent-harness/arvo/lib/arvo/tools/bash.ex` at `84004e1`, 2026-08-15.
[^arvo-fff]: `../coding-agent-harness/arvo/lib/fff/native.ex` and `plugins/fff/lib/fff/plugin.ex` at `84004e1`, 2026-08-15.
[^arvo-auth]: `../coding-agent-harness/arvo/lib/arvo/auth/store.ex` and `token_manager.ex` at `84004e1`, 2026-08-15.
[^arvo-loader]: `../coding-agent-harness/arvo/lib/arvo/plugins/loader.ex` at `84004e1`, 2026-08-15.
[^arvo-profiles]: `../coding-agent-harness/arvo/lib/arvo/profiles.ex` and `plugins/registry.ex` at `84004e1`, 2026-08-15.
