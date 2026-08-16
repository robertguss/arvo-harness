# Measured results

Running log of live eval results. Numbers only count if the run is
reproducible from this repo (see `evals/README.md` at the repo root; results
and the code that produced them now version together). Newest first.

## R-003 - 2026-08-16 - Needle-junk: junk beyond the exception budget never reaches hot context (n=5 pairs)

**Setup.** Task `arvo-attention-needle-junk` (one 571-byte parser file needing
a rename among three ~95 KB archives the instruction forces the agent to read
fully). Same rig as R-001/R-002: Harbor 0.21.0 local Docker (linux/arm64,
OrbStack), containerized Mix release, model `xai:grok-4.5` via Grok OAuth,
5 trials per arm, default honesty gate (on runs must show a stub or reuse).
`max_turns` raised to 40 in both arms (25 starves this workload; see build
notes). Harness release built from `main` @ `8d45403` (`lib/` unchanged
since); task + configs that produced these numbers @ `65ed1ef`. Jobs:
`evals/jobs/arvo-attention-needle-junk-{oracle-1,on-1,on-rep,off-1,off-rep}`.

**Result.** All 10 trials passed task + honesty checks. Prediction (ON hot
bytes far below OFF, stubs > 0 every ON run, task success equal) held.

| Metric | Attention ON (n=5) | Attention OFF (n=5) |
|---|---|---|
| hot bytes (b_full) | 76,351-81,232 (mean 78,410) | 287,683-287,940 (mean 287,825) |
| task success | 5/5 | 5/5 |
| honesty | 5/5 | 5/5 |
| stubs in hot | 11-12 | 0 |
| results shelved cold | 20-26 | 0 |
| expands / denied | 0 / 0 | 0 / 0 |
| agent wall clock | 36.5-47.2 s (mean 41.5) | 35.7-46.0 s (mean 40.0) |

- Ratio of means: **0.272**. Worst case (fattest ON / leanest OFF): **0.282**.
  Zero overlap between arms.
- **The ON floor is the exception budget, not task need.** Every ON run
  landed at 76-81 KB because the policy full-hots first reads until the
  80,000-byte fidelity-exception budget is spent; the small always-hot
  results (needle, past-end errors, edit acks) push totals slightly past the
  budget line. On junk-dominated work the savings ratio is bounded by
  roughly budget / junk-total: the more junk, the better the ratio.
- **Selection answer: yes.** The needle landed full-hot in every ON run,
  11-12 junk chunks per run went to the cold shelf, and none came back
  (0 expands): the model never needed the junk it was forced to read.
- No latency signal: wall-clock ranges fully overlap.
- OFF is near-deterministic again (range 257 bytes), the same
  dump-everything signature as R-001.

**Scope honesty.** One task built so junk dominates; the 0.27 ratio scales
with junk volume by construction. It answers "does the firewall select?"
(yes: junk stays cold, the needle stays hot, zero task cost), not "what is
the typical savings on real work."

**Build notes.** Oracle passed first try (21 s). Two burned ON trials, kept
as `*.turn25-fail` and `*.expandloop-fail`:

1. `max_turns` 25 starves the forced-read workload (exit 4 mid-archive);
   raised to 40 in both arms.
2. An instruction demanding "see each file to its last line" is
   unsatisfiable under stubs (tails are shelved, and the 16 KB expand cap
   denies 19 KB chunks): grok obediently burned 15 expands before dying.
   Reworded so a cold-stub receipt counts as having read the chunk and the
   past-end-of-file error (errors always land full-hot) is the termination
   signal. Expands went from 15 to 0.

Sizing lesson that contradicts the earlier handoff note: clearing the
4,000-byte stub threshold is **not** enough to get junk stubbed. First reads
ride the 80,000-byte fidelity-exception budget into hot context, and the read
tool caps chunks at 50 KB (always under budget), so mid-size distractors
would produce zero stubs and fail the on-arm honesty gate. Archives are
sized ~95 KB so their chunks overflow the budget; the sizing rationale lives
in `evals/arvo-attention-needle-junk/tools/gen_workspace.py`.

New practice paid off: the verifier now copies the scored `*.audit.jsonl`
into `/logs/verifier/` (the R-002 forensics gap), and both burned trials
were diagnosed from those per-event copies.

## R-002 - 2026-08-15 - Small control: attention adds no tax on tiny work (n=5 pairs)

**Setup.** Task `arvo-attention-small-control` (three Elixir files of 267-583
bytes, single rename edit; every tool output sits far below the 4 KB stub
threshold). Same rig as R-001: Harbor 0.21.0 local Docker (linux/arm64,
OrbStack), containerized Mix release, model `xai:grok-4.5` via Grok OAuth,
max 25 turns, 5 trials per arm. Honesty scoring identical except the
reread-only "on run must show a stub or reuse" gate is waived
(`require_stub_reuse_on=False`): on a control task, zero stubs is the honest
outcome. Jobs:
`evals/jobs/arvo-attention-small-control-{oracle-1,on-1,on-rep,off-1,off-rep}`.

**Result.** All 10 trials passed task + honesty checks. Prediction (ratio
~1.0, no stubs, success unchanged, no latency penalty) held on all four
counts.

| Metric | Attention ON (n=5) | Attention OFF (n=5) |
|---|---|---|
| hot bytes (b_full) | 881-1,464 (mean 1,039) | 881-950 (mean 922) |
| task success | 5/5 | 5/5 |
| honesty | 5/5 | 5/5 |
| stubs in hot | 0 | 0 |
| results shelved cold | 2-3 | 0 |
| agent wall clock | 9.9-12.8 s (mean 11.6) | 9.5-12.0 s (mean 11.0) |

- Ratio of means: **1.126** — but read absolutes here, not ratios. Totals are
  ~1 KB, so one extra ~0.5 KB read by a single ON trial moves the ratio by
  more than 10%. Four of five ON runs landed byte-identical to OFF values
  (881/950 in both arms): the treatment added zero hot-byte overhead on
  identical tool paths.
- Zero stubs, expands, or denies anywhere. ON runs shelved 2-3 cold copies as
  bookkeeping; nothing entered hot context as a stub.
- No latency signal: per-trial ranges fully overlap.
- Verdict for the daily driver: attention idles cleanly on simple work; safe
  to leave on by default as far as this task class shows.

**Scope honesty.** One tiny task, one edit, n=5 pairs. Byte ratios are
unstable at ~1 KB denominators; this task answers "is there a tax?" (no
observable one), not "what is the exact overhead ratio."

**Build notes.** Oracle passed first try (21 s). Two live trials were burned
on the known macho-fail trap (macOS tarball because ARVO_RELEASE was not
exported); artifacts kept as `*.macho-fail`, and the Harbor adapter now fails
fast at setup on wrong-arch releases instead of producing misleading reward-0
trials.

## R-001 - 2026-08-15 - Progressive attention cuts hot bytes ~41% at zero task cost (n=5 pairs)

**Setup.** Task `arvo-attention-reread` (large-file re-read + rename edit),
Harbor 0.21.0 local Docker (linux/arm64, OrbStack), Arvo Mix release built in
container, model `xai:grok-4.5` via Grok OAuth (subscription, no API key),
max 25 turns. 5 trials per arm: attention on vs off. Jobs:
`evals/jobs/arvo-attention-reread-{on-1,on-rep,off-1,off-rep}`.

**Result.** All 10 trials passed task + honesty checks.

| Metric | Attention ON (n=5) | Attention OFF (n=5) |
|---|---|---|
| hot bytes (b_full) | 52,135 / 78,401-78,977 (mean 73,377) | 123,530-124,041 (mean 123,736) |
| task success | 5/5 | 5/5 |
| honesty | 5/5 | 5/5 |
| stubs in hot | 1-2 | 0 |
| results shelved cold | 6-11 | 0 |

- Ratio of means: **0.593**. Worst case (fattest ON / leanest OFF): **0.639**.
- Zero overlap between arms: every ON run was leaner than every OFF run.
- OFF is near-deterministic (stdev 231 bytes): dump-everything reads the same
  bytes every time. ON varies (one lean 52 KB outlier run): the model's path
  through stubs/expands differs per sample. Both always finished.
- Expands observed: occasional (0-1 per run), including denied expands with no
  task failure (no stranding seen on this task).

**Scope honesty.** One task, and one designed to flatter attention (forced big
re-read). This bounds the claim: "on re-read-heavy work, attention saves
~36-48% of hot bytes at no observed cost." The envelope needs more tasks.

**Next tasks planned** (build one at a time, oracle + same metrics each):

1. `arvo-attention-small-control` - tiny files, quick edit. Expect ratio ~1.0,
   no stubs. Question: does attention tax simple work?
2. `arvo-attention-needle-junk` - one relevant file among large distractors.
   Question: does the firewall select, not just compress?
3. `arvo-attention-multifile` - refactor across 3-4 cross-referencing files.
   Question: does the cold shelf get reused instead of re-read?
4. `arvo-attention-stranding-trap` - needed detail sits in a likely-stubbed
   region; success requires expand recovery. Question: where does attention
   hurt? (Task success must not drop.)
