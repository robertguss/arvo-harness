# Measured results

Running log of live eval results. Numbers only count if the run is
reproducible from the repo (see `arvo-harness/evals/README.md`). Newest first.

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
