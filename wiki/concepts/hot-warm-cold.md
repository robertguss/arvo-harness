---
title: Hot, warm, cold context
type: concept
tags: [attention, context]
updated: 2026-07-29
sources:
  - CONCEPTS.md
---

# Hot, warm, cold

Layers of [[entities/progressive-attention|progressive attention]].

## Hot

Budgeted messages the model sees this turn. Large tool results usually appear as
**stubs** (context firewall). Fidelity exceptions keep coding usable.

## Warm work-delta

Small structured workshop state: paths, command/exit signals, failures, goal
line. Maintained primarily from tool/session trace. Injected into hot under
budget; handoff packet snapshots it. Rebuildable from cold/tools; must not grow
into essay prose agents re-ingest as scripture.

## Cold evidence

Full tool bodies addressable under stable ids for the open session (v1
session-scoped completeness). Stubs in hot point here; expand/recall pulls
bounded slices back under caps. Cross-session GC/immortality deferred. Keepers
(if present) are live caches over cold, not replacements.

## Contrast with this wiki

This LLM wiki is a **markdown knowledge base** maintained across sessions. Cold
evidence is **session-scoped tool bodies**, not a substitute wiki. Do not
conflate the two.
