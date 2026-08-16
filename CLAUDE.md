# Project Instructions for AI Agents

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

## Research program

The BEAM-harness research program (hypothesis catalog, decisions, measured
results) lives under `research/`. `research/AGENTS.md` governs that subtree;
eval results land in `research/docs/working/RESULTS.md`. Its portable skills
sit in `research/.agents/skills/` and are not auto-loaded from the repo root.

## LLM wiki

Compiled knowledge under `wiki/`. Schema: `wiki/AGENTS.md`. Start at
`wiki/index.md`, then `wiki/overview.md`.

Do not edit raw sources as part of wiki maintenance.
