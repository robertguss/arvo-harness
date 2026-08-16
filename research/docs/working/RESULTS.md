# Measured results

Running log of live eval results. Numbers only count if the run is
reproducible from this repo (see `evals/README.md` at the repo root; results
and the code that produced them now version together). Newest first.

## R-005 - 2026-08-16 - Stranding trap: a fully-buried fact is recovered by expand every time, at ~2 s cost (n=5 pairs)

**Setup.** Task `arvo-attention-stranding-trap` (rename a module to a name
published only inside an ~11.6 KB deterministic bash report, at byte offset
~6,950 — past the 400-byte stub preview, under the 16 KB expand cap). Bash
results get no fidelity exception (only `read` does), so under attention-on
the report always stubs regardless of budget: the needed fact is invisible
until the agent recalls the cold body. The name is rot13-encoded in the
generator script so no workspace grep leaks it, and the instruction mandates
running the exact report command with no filter pipes (a `| grep` would
produce a tiny full-hot result and bypass the trap in both arms). Same rig as
R-001..R-004, model `xai:grok-4.5`, `max_turns` 25, default honesty gate.
Harness release from `main` @ `8d45403`; task + configs @ `89e5237`. Jobs:
`evals/jobs/arvo-attention-stranding-trap-{oracle-1,on-1,on-rep,off-1,off-rep}`.

**Result.** All 10 trials passed task + honesty checks. Prediction (stub every
ON run, recovery via expand, task success equal) held; the open question was
whether the model would strand, and it never did.

| Metric | Attention ON (n=5) | Attention OFF (n=5) |
|---|---|---|
| hot bytes (b_full) | 679 (all five identical) | 12,279 (all five identical) |
| expanded bytes (recalled cold bodies) | 11,600 every run | 0 |
| task success | 5/5 | 5/5 |
| honesty | 5/5 | 5/5 |
| stubs in hot | 1 (the report) | 0 |
| expands / denied | 1 / 0 every run | 0 / 0 |
| tool results | 8 | 6 |
| agent wall clock | 13.1-14.8 s (mean 13.7) | 11.2-12.1 s (mean 11.8) |

- **Stranding answer: no.** In all five ON runs the model hit the stub,
  issued one `RecallEvidence` call with the cold id on the first attempt,
  got the full 11,600-byte body (under the 16 KB cap, so never denied), and
  completed the rename. Audit forensics confirm the mandated path exactly:
  bash report (stubbed) → read needle file → expand → edit; the generator
  script source was never read.
- **Do not read b_full alone here.** ON's 679 vs OFF's 12,279 looks like an
  18x saving, but the expand pushed the full 11,600-byte body into hot
  context: total prompt-visible bytes are 12,279 in both arms — identical by
  design, because this task makes the whole stubbed body necessary. The
  firewall's deferral won nothing and lost nothing on bytes; what it bought
  was the *option* to skip the body, which this task deliberately removes.
- Cost of the stub-then-recall round trip: +2 tool results and ~+2 s wall
  (mean 13.7 vs 11.8 s, ranges nearly disjoint) — one extra model turn.
  That is the measured price of attention when the gamble loses.

**Scope honesty.** The body fits under the 16 KB expand cap, so one recall
suffices; the harder variants — a body over the cap needing sliced recalls,
or several facts scattered across multiple stubbed bodies — are untested.
Within-arm determinism again: five pairs sample one tool path five times
(stability, not variance). And the trap has a known residual bypass: a model
could read the tiny script and rot13-decode the name, violating the
instruction; grok never tried, but the design leans on instruction-following
rather than making the bypass impossible.

**Build notes.** Oracle passed first try (21 s); zero burned live trials —
first task in the suite to go clean end to end. Design keys, from
`lib/arvo/attention/policy.ex` and `lib/arvo/tools/bash.ex`: non-read tools
never get fidelity exceptions, so a >4 KB bash result stubs deterministically
(no ~95 KB budget-overflow sizing needed, unlike R-003); and bash output under
100 KB arrives untruncated, keeping the report deterministic. Fact placement
window: past the 400-byte preview, under the 16 KB cap — sized ~11.6 KB total
with the fact at ~6.9 KB.

## R-004 - 2026-08-16 - Multifile: every unchanged re-read served from the cold shelf (n=5 pairs)

**Setup.** Task `arvo-attention-multifile` (rename `Pricing.rate/1` to
`unit_rate/1` across three ~12 KB cross-referencing files; the instruction
mandates a full re-read of each file immediately before editing it). Files
sized above the 4 KB stub threshold, inside a single 50 KB read chunk (so the
re-read digest matches), and 36 KB total, deliberately under the 80 KB
exception budget so this task isolates the reuse mechanism from the
budget-overflow stubbing R-003 measured. Same rig as R-001..R-003, model
`xai:grok-4.5`, `max_turns` 25, default honesty gate (reuse counts toward
the stub/reuse signal). Harness release from `main` @ `8d45403`; task +
configs @ `08f6bf4`. Jobs:
`evals/jobs/arvo-attention-multifile-{oracle-1,on-1,on-rep,off-1,off-rep}`.

**Result.** All 10 trials passed task + honesty checks. Prediction (reuse ≈ 3
per ON run, hot bytes ≈ half of OFF, task success equal) held exactly.

| Metric | Attention ON (n=5) | Attention OFF (n=5) |
|---|---|---|
| hot bytes (b_full) | 36,392 (all five identical) | 72,443 (all five identical) |
| task success | 5/5 | 5/5 |
| honesty | 5/5 | 5/5 |
| reuse_cold / same_path_reinvoke | 3 / 3 every run | 0 / 0 |
| stubs in hot (demoted re-reads) | 3 | 0 |
| expands / denied | 0 / 0 | 0 / 0 |
| agent wall clock | 22.4-24.4 s (mean 23.3) | 22.0-35.2 s (mean 25.5) |

- Ratio of means: **0.502** (worst case identical: the runs are byte-for-byte
  deterministic within each arm; grok took the same tool path all ten times).
- **Reuse answer: yes.** Every mandated pre-edit re-read of an unchanged file
  was served from the cold shelf as a ~450-byte receipt instead of a 12 KB
  re-ingest, in all five ON runs, and the edits still landed correctly from
  the first read held in context.
- The 0.502 ratio is by construction (the instruction makes both arms read
  everything exactly twice); the finding is reuse 3/3 at zero task cost, not
  the ratio itself.
- Wall clock: no penalty (ON sat slightly leaner; ranges overlap).

**Scope honesty.** The re-reads are instruction-forced, so this measures the
mechanism (an unchanged same-path re-read gets served cold), not how often
real work re-reads. Within-arm determinism means the five pairs sample one
tool path five times; n=5 here confirms stability, not variance.

**Build notes.** Oracle passed first try (21 s); zero burned live trials.
Design constraints that made reuse observable, from `lib/arvo/attention.ex`:
reuse demotion needs the result above the stub threshold (small results stay
full-hot on re-read by design), an unchanged digest (so files must fit one
read chunk), and an unedited path. Post-edit re-reads were explicitly
forbidden in the instruction: an edited path re-read stubs by design (its
fidelity window is gone) and would bait expands.

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
