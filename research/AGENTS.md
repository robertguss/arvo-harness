# Agent Rules — research program (`research/`)

Rules for humans and agents operating this research program. They govern the
`research/` subtree of the arvo-harness monorepo (the program was merged in
from the standalone `arvo-beam-harness-research` repo, history preserved);
harness code outside `research/` follows the repo-root agent rules instead.

## Authority

1. Git-tracked artifacts are authoritative. Chat history and model memory are not.
2. Precedence: accepted `DEC-###` → Blueprint → Charter → current stage prompt →
   revised specification → research reports (evidence) → reviews (proposals) →
   revised plan → `research-program.toml` (index only).
3. Details: `program/contracts/authority-and-precedence.md`.

## Fresh sessions

Every **substantive** stage runs in a fresh session with a self-contained
attachment manifest. Do not execute multiple substantive stages in one context.
Preparing prompts, manifests, and mechanical fixes is allowed in the current
session.

## Allowed file scope

Each stage may modify only the paths declared in its commissioning prompt and
manifest outputs. Do **not** silently edit governing artifacts (Blueprint,
Charter, accepted specs/plans) outside a commissioned revision stage.

## Validation and acceptance

- Placeholders (`Status: Placeholder — not accepted`) never unlock work.
- Independent validation before acceptance (`program/contracts/validation.md`).
- Validators fix mechanical issues only; no invented research.
- Human approval gates: `program/operator/approval-gates.md`.
- Humans own git; do not mark stages accepted without human approval and commit
  recording in the manifest.

## Identifiers and citations

- Stable IDs: `DEC`, `REC`, `REQ`, `FND`, `RSK`, `OQ`, `SPK`, `PHASE`, `MS`.
- Never reuse IDs. Disposition upstream IDs explicitly.
- Portable citations only (Markdown links, footnotes, source ledgers).

## Evidence

- Evidence before confidence.
- Evidence Ledgers on focused reports.
- Bounded spikes when load-bearing claims are testable.
- No popularity-as-proof; no silent recommendation loss.

## Exa (current research)

When a stage requires current primary-source research, call Exa over
**REST**. That is the working path. Do not use the Exa MCP server.

- Key: `EXA_API_KEY` in gitignored `.env`. Load it; never print it or
  write it into an artifact.
- Ordinary lookup: `POST https://api.exa.ai/search` with `type` `auto`
  or `fast`.
- Deep research: same endpoint, `type` `deep` or `deep-reasoning`.
- Multi-step Agent: `POST https://api.exa.ai/agent/runs`, then poll
  `GET https://api.exa.ai/agent/runs/{id}` (`effort` `high` / `xhigh`
  when the question is load-bearing).
- Exa is retrieval. Open the cited primary URL and classify that page.
  If the key is missing or the call fails, say so in Methodology and
  continue with built-in search. Do not pretend Exa ran.

## Skills

Portable skills live under `.agents/skills/`:

| Skill               | Use for                                                                |
| ------------------- | ---------------------------------------------------------------------- |
| `research-program`  | Discovery, resume, next stage, program orchestration                   |
| `research-stage`    | Just-in-time stage package (prompt, install, attach, launch, validate) |
| `research-validate` | Independent validation gate                                            |

Methodology library: `program/`. Operator start: `program/operator/getting-started.md`.

## Commands

```text
just init name="…"   # name bootstrap only; no git
just status          # stages and eligible next work
just check           # tree + placeholder/acceptance sanity
```

## Anti-patterns

See `program/reference/anti-patterns.md`. Especially: chat-history authority,
placeholder completion, plan-as-backlog, implementation before authority.
