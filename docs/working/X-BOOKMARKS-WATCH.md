# X bookmarks — idea mine (`@_robguss`)

- **Status:** Working notes. Not an accepted report.
- **Fetched:** 2026-08-14
- **Count:** 197 (API returned two pages; no further `next_token`)
- **Dump:** [`x-bookmarks/INDEX.md`](x-bookmarks/INDEX.md) · [`x-bookmarks/bookmarks.json`](x-bookmarks/bookmarks.json)
- **Lens:** circle OTP; underline leftover. Ignore prompt-slop and model-of-the-week.

No tokens in these files.

---

## What the pile actually is

Not a research library. A **practitioner firehose**: Pi, Codex, Claude, Hermes, Herdr, skills, planner/implementer splits, local models, a little autoresearch.

José is in here once (the tweet we already locked). Viv/LangChain barely. Karpathy/autoresearch shows up as community remixes, not the original repo.

Top handles by count are mixed (TypeScript teachers, crypto, etc.). Signal is in **themes**, not frequent posters.

---

## Cards (high signal)

### Runtime / José / Pi (already on our wall)

- **XB-001** [José — runtime is the framework](https://x.com/josevalim/status/2088186994849468659). Already `H-001`–`H-006`. Bookmark confirms it is *his* saved copy of the bet.
- **XB-002** [Armin / Pi KV cache](https://x.com/mitsuhiko/status/2080243367535898707). Harnesses can silently **torch prefix cache**. Same leftover as Copilot-at-scale (P-018). Name cache-break events (plugin load, compact).
- **XB-003** [Tobi on Herdr](https://x.com/tobi/status/) — in dump as “favorite way to explain herdr…”. Workspace chrome, not the agent. Matches Arvo tile vs Herdr.
- **XB-004** [herdr 0.7 plugins](https://x.com/herdrdev/status/2066560459591893350). Herdr stays lean; custom via plugins. Same profile/plugin thesis, different process (the multiplexer, not Session).

### Autoresearch / harness hill-climb

- **XB-005** [0xSero — autoresearch anything](https://x.com/0xSero/status/2082863372853559652). Community already generalizes Karpathy off the GPU. Shopify article is the adult version.
- **XB-006** [Aman Chadha primer: Autoresearch and Harness Engineering](https://x.com/i_amanchadha/status/2080856252687745093). Explicit pairing of the two words we care about. Follow the linked primer when home-laptop papers land.

### Parallel work / isolation (fake nodes)

- **XB-007** [Cursor cloud subagents from a local coordinator](https://x.com/poteto/status/2084844251100438890). Brain local, hands in the cloud. José’s third sentence in product clothes.
- **XB-008** [Herdr + AgentBox on E2B](https://x.com/madarco/status/2069840292166197332). Parallel boxes, each a PR + browser tests. Hands = container. `/goal` + backlog file.
- **XB-009** [Crabbox — each local agent gets a cloud box](https://x.com/jasonzhou1993/status/2069753641129689272). Sync dirty tree, run full suite, isolate. Worktree + node.
- **XB-010** [tmux as agent I/O](https://x.com/bentlegen/status/2056843687187923058). Read panes, answer prompts, drive TUIs, subagents in splits. Herdr/pane registry cousin. Circled: Port to a multiplexer.

### Planner / implementer / “reasoning sandwich”

- **XB-011** [xhigh planner + Composer implementer subagents in Pi](https://x.com/fitchmultz/status/2058582687124967461). Trivedy’s sandwich as two *models*, not two reasoning levels.
- **XB-012** [Handoff skill: grill-me in Claude, execute in Codex worktrees](https://x.com/BHolmesDev/status/2060114425776869813). Handoff packet we already have; they use it **across harnesses**.
- **XB-013** Lots of Codex 5.6 Sol “spawn parallel subagents / computer use” prompts (`@Voxyz_ai`, `@eidzoku`, `@skcd42`). Leftover is thin (prompt fashion). Circled: child Sessions. Skip the prompt packs unless we need examples of what people *ask* a harness to do.

### Skills / memory / constitution

- **XB-014** [SOUL.md at the top of the prompt](https://x.com/akshay_pachaar/status/2058584154292584853). Before memory, skills, tools. That’s constitution / `persistent_term`.
- **XB-015** [Disable Claude auto-memory](https://x.com/trevin/status/2070532169349652935). Stale memory steers wrong. Honest cold > silent “memory.”
- **XB-016** [Mine your own sessions → skills](https://x.com/reach_vb/status/2058315996260102376). Trivedy data-mining, pointed at *personal* traces. Eval-engineering’s cousin.
- **XB-017** [Explore-unknowns skill: interview one question at a time](https://x.com/dzhng/status/2073729706789343488). Same shape as our discovery protocol.
- **XB-018** [Pi that changes itself](https://x.com/davis7/status/2055168353355059376). Hot-swap as product UX. José’s first sentence, in Pi.

### “Harness” as a trained object

- **XB-019** [Harness-1 — 20B search agent + state-externalizing harness](https://x.com/patpcj/status/2063298457398636570). Model *and* harness co-designed so state lives outside the window. AHE/Meta-Harness neighborhood. Worth a later paper/card if a link exists.

### Local / Hermes / gateway (attach-detach)

- **XB-020** Hermes + private gateway + wiki (`@bradmillscan`, `@_jonatasantos`). `arvo up` / attach energy. Circled: long-lived brain, many clients. Underlined: they still fake the OS with a “gateway.”

---

## Low-value bulk (do not card)

Model-release hype, Sol/Ultra prompt recipes, Instagram study tips, generic “how I use Grok,” clip accounts. ~150 of 197. Correct that most stay uncarded.

---

## What this pile adds to the program

1. **José + Pi + Herdr + autoresearch** are already *his* bookmarks. The wall is not our invention.
2. Practitioner consensus: **planner ≠ implementer**, **isolate the hands** (cloud box / E2B / worktree), **skills from traces**, **don’t trust auto-memory**.
3. Cache honesty (Pi) and session-mining (Codex) are leftovers we had from papers; bookmarks are the street versions.
4. Almost nobody here is thinking BEAM. That is the under-the-radar opening.

---

## Refresh

```bash
python3 scripts/x_dump_bookmarks.py
```

Needs a live `X_USER_BEARER` in `.env` (token expires ~2h unless refreshed).
