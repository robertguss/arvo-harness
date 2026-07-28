# Concepts

Shared domain vocabulary for this project — entities, named processes, and status concepts with project-specific meaning. Seeded with core domain vocabulary, then accretes as ce-compound and ce-compound-refresh process learnings; direct edits are fine. Glossary only, not a spec or catch-all.

## Arvo product path

### Session

The singleton GenServer that owns open session identity, append-only history, the supervised product turn Task, cancel generation, and durable usage. Product interactive chat enters the agent only through Session-owned turns; bare Agent runs stay library/test territory.

### Product turn

One supervised Task lifecycle: start → model/tool loop → result → persist assistant/tool rows → usage ledger → idle (or cancel leaf). Surfaces dispatch start/cancel/steer; they do not own persist or Agent lifetime.

### HEAD

The explicit attention pointer on the session JSONL tree (via head_move records), not merely the last file line. Product context and next parent_id walk root → HEAD so abandoned forks stay on disk but off the hot path.

### Cancel-as-fork

Esc mid-turn kills in-flight work and appends an incomplete assistant leaf so HEAD remains coherent, without claiming a finished successful assistant. Prefer preserving an already-finished success over writing a cancel leaf when the Task completed first.

### Handoff

Attention handoff that creates a new session seeded only by a structured work-delta packet, leaving the parent JSONL intact. Must run as one idle-only Session transaction so create/seed/rebind cannot race a live product turn.

### Focus claim

Synchronous UI busy claim before fire-and-forget product chat spawn. Blocks double-Enter from starting a second turn; mid-busy input becomes steering instead. Complements Session’s real start_turn mutex; does not replace it. Session-driven status paint into Focus must not wait on the UI process while the UI can wait on Session — that reverse-call wait is a deadlock class, not a cosmetic UI freeze.

### Turn-busy

Session’s live-Task predicate used to refuse identity/HEAD rewrites (resume, rewind, open_new, rebind, handoff) while a product turn is running.

### Progressive attention

Harness-owned management of what the model sees each turn: budgeted hot context, structured warm work-delta, and session-complete addressable cold evidence. Not a permanent mind and not a markdown knowledge base; “learning” means reuse of cold evidence plus warm state. Distinct from Keepers (optional live process cache over cold).

### Dual view

Human-facing transcript may stay rich for debugging while the model’s hot messages stay progressive (stubs/budgeted). Inspect reconciles the two; honesty means labeling what the model saw, not forcing identical full dumps in both views.

### Warm work-delta

Small structured workshop state (paths, command/exit signals, failures, goal line) maintained primarily from the tool/session trace. Injected into hot under budget; handoff packet snapshots it. Rebuildable from cold/tools; must not grow into essay prose agents re-ingest as scripture.

### Cold evidence

Full tool bodies kept addressable under stable ids for the open session (v1 session-scoped completeness). Stubs in hot point here; expand/recall pulls bounded slices back under caps. Cross-session GC/immortality is deferred; Keepers if present are live caches over cold, not replacements.

### Context firewall

Product policy that large tool results enter model hot context as stubs by default while full bodies land in cold—enforced by the harness, not model self-discipline. Fidelity exceptions (small, error, pin, edit targets) keep coding usable.
