# LLM Wiki Schema — arvo-harness

This directory is an **LLM-maintained wiki**: a persistent, compounding knowledge
base about Arvo. Humans curate sources and ask questions; the LLM writes and
maintains wiki pages.

Pattern source: [Karpathy llm-wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## Three layers

| Layer | Location | Rules |
| ----- | -------- | ----- |
| **Raw sources** | Repo paths outside `wiki/` (`README.md`, `CONTEXT.md`, `CONCEPTS.md`, `docs/`, `lib/`, `evals/`, solutions, ADRs) | **Immutable to the wiki agent.** Read only. Never edit a source "to match the wiki." |
| **Wiki** | `wiki/**/*.md` except this schema may be co-evolved with the human | LLM owns content. Create, update, cross-link, retire. |
| **Schema** | This file (`wiki/AGENTS.md`) | Conventions + workflows. Co-evolve with the human when friction appears. |

## Purpose

Project knowledge for **arvo-harness**: Arvo (Elixir harness), progressive
attention, evals/Harbor, plugins/profiles, Herdr panes. Not a personal journal
and not a substitute for code.

Ore lives in a sibling repo:
[ore-harness](https://github.com/robertguss/ore-harness).

Canonical vocabulary still lives in source docs when they exist:

- Product names / avoid-list → `CONTEXT.md`
- Process glossary (Session, HEAD, attention, …) → `CONCEPTS.md`
- Decisions → `docs/adr/`
- Bug learnings → `docs/solutions/`

Wiki **compiles and links** those; it does not replace those as source of truth
for normative wording. When wiki and source disagree, fix wiki or fix the
source — do not silently invent a third truth.

## Directory layout

```
wiki/
  AGENTS.md          # this schema
  index.md           # catalog of all pages (read first on query)
  log.md             # append-only activity log
  overview.md        # top-level synthesis
  lint-report.md     # last lint pass findings
  entities/          # systems, products, major modules
  concepts/          # domain ideas that span code
  sources/           # one page per ingested source (summary + pointers)
```

Optional later: `comparisons/`, `queries/` for filed answers.

## Page format (Obsidian-friendly)

Every content page:

```yaml
---
title: Human title
type: entity | concept | source | overview | query | comparison
tags: [tag1, tag2]
updated: YYYY-MM-DD
sources: []          # repo-relative paths or URLs; required for source pages
---
```

Body rules:

1. Use `[[wikilinks]]` for internal links (Obsidian). Prefer `[[entities/arvo]]`
   style paths without `.md`.
2. Cite raw sources with repo-relative paths in backticks or markdown links,
   e.g. `CONTEXT.md`, `[ADR 0001](../docs/adr/0001-elixir-beam-for-the-harness.md)`.
3. Keep pages focused. Split when a page covers more than one hub concern.
4. Frontmatter `updated` must change on every real content edit.
5. Do not dump whole source files into the wiki. Summarize + point.

## Page types

### Entity

A product, package, or hub module (Arvo, Session, FFF, Harbor evals). Include:
what it is, where it lives, key entrypoints, relationships, status caveats.

### Concept

Domain idea (harness, progressive attention, agent tile). Define, distinguish
near-synonyms, link entities that implement it.

### Source

One ingested raw document. Include: path, one-line purpose, key takeaways,
which wiki pages it updated, contradictions if any.

### Overview / query / comparison

Synthesis pages. Filed query answers become first-class pages when reusable.

## Special files

### index.md

Content catalog. Sections by type. Each row: link, one-line summary. Update on
**every** ingest and on any page create/rename/delete. On query: read index
first, then drill into pages.

### log.md

Append-only. Entry format (keep prefix stable for grep):

```markdown
## [YYYY-MM-DD] ingest | Short title
## [YYYY-MM-DD] query | Short title
## [YYYY-MM-DD] lint | Short title
## [YYYY-MM-DD] maintain | Short title
```

Body: bullets of what changed. `grep "^## \[" wiki/log.md | tail -5` = recent.

## Workflows

### Ingest

1. Read the raw source (never modify it).
2. Summarize takeaways; note contradictions with existing wiki pages.
3. Write/update `sources/<slug>.md`.
4. Update entity/concept pages touched by the source (often many).
5. Update `index.md`.
6. Append `log.md` entry.
7. If normative vocabulary changed in `CONTEXT.md` / `CONCEPTS.md`, align wiki
   wording to those sources.

Prefer one source at a time when the human is reviewing.

### Query

1. Read `index.md`.
2. Open relevant pages; cite them in the answer.
3. Prefer wiki synthesis over re-reading all raw sources; fall back to sources
   when wiki is thin or stale.
4. If the answer is reusable, file it as a wiki page and log `query`.

### Lint

On request or periodically:

- Contradictions between pages
- Stale claims vs newer sources/code
- Orphan pages (no inbound links)
- Concepts mentioned without a page
- Missing cross-links
- Gaps that need a new source or code read

Write findings to `lint-report.md` and log `lint`. Fix cheap issues in the same
pass.

### Maintain

Renames, splits, tag cleanup, index repair. Log as `maintain`.

## Scope defaults (this project)

**In scope:** architecture, product surfaces, trust spine, attention model,
eval methodology, documented solutions.

**Out of scope for bulk pages:** every Elixir module, every eval job artifact,
chat transcripts, secrets, generated `_build`.

Entity depth: **top hubs only** unless human asks for deeper map.

## Agent rules (must)

1. Never edit raw sources as part of wiki maintenance.
2. Never commit or push unless the human explicitly asks.
3. When implementing product code, treat `CONTEXT.md` / `CONCEPTS.md` as
   normative vocabulary sources; update wiki after or alongside doc changes.
4. Keep technical names exact (`Session.start_turn`, `req_llm`, Harbor, …).

## Suggested first reads for a new session

1. `wiki/index.md`
2. `wiki/overview.md`
3. `wiki/entities/arvo.md` or the hub for the task
4. `CONTEXT.md` + `CONCEPTS.md` if wording matters
