# Decisions

Running log of decisions Robert has locked, one index card each. Written so a
future session (human or AI) can catch up without re-reading the whole
program. Newest first.

## D-001 - 2026-08-15 - G-002 stays the garage test; context engineering routed elsewhere

**Decision.** G-002 tests exactly two things: tools cannot read the brain's
secrets (payload containment), and a dying tool cannot take down the Session
(crash containment). Context-window size is explicitly out of G-002's scope.
Robert's context-engineering question ("does moving tool work into processes
keep the brain's context small?") has different owners: the existing
progressive-attention system in arvo-harness and its Harbor eval today, and
G-005 child sessions for the bigger version later. An experiment that tests
two things answers neither.

**Index card (Robert's words, corrected together).** The brain calls tools;
the tools run in a separate building. Prove the building cannot read the
wallet, prove an explosion there does not touch the house, prove the work is
just as good. Drop any fence whose latency costs more than the safety it
adds.

**Sharpenings accepted with the lock** (2026-08-15 review; not yet folded
into SORT.md):

- Model isolation as a grid, not a ladder. Crash containment and payload
  containment are different threats; score each fence against each threat.
- The leak test must name every door: environment variables, VM state
  (persistent_term / app env), the wire between nodes, and files on disk.
  The disk door is the one the recorded test forgets: the OAuth token store
  under `~/.arvo` is readable by same-machine hands running as the same user.
- Replace "keep the thinnest ladder layer" with "keep the cheapest pair of
  fences": one against crashes, one against hostile payloads.
- Keys travel as scoped, short-lived grants (one card), never the wallet.
- BEAM processes are rooms in one house: real fences against Elixir-level
  crashes, no fence against native crashes (the fff NIF) or hostile code.
  The garage means an OS boundary: port program, peer node, or container.

**Next hands-on step (locked).** Run the existing attention eval end to end
(unit baselines, then oracle, then the on/off pair) and read the numbers
together. This is simultaneously the context experiment Robert wants and his
evals education.
