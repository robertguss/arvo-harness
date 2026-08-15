# Agent Instructions

Arvo is an Elixir/BEAM coding-agent harness. The Mix project is the repo root.

## Build and test

```bash
mix deps.get
mix test
bin/arvo
```

Requires Elixir ~> 1.20 and OTP 26+. `bin/arvo` uses mise when present.

Harbor attention evals: `evals/README.md`. Mix release packaging:
`rel/RELEASE.md`.

## Vocabulary

- Product names → `CONTEXT.md`
- Process glossary (Session, HEAD, attention, …) → `CONCEPTS.md`
- Decisions → `docs/adr/`
- Bug learnings → `docs/solutions/`

## LLM wiki

Compiled knowledge under `wiki/`. Schema: `wiki/AGENTS.md`. Start at
`wiki/index.md`, then `wiki/overview.md`.

Do not edit raw sources as part of wiki maintenance.
