---
title: "Source: ADR 0002 req_llm types"
type: source
tags: [source, adr]
updated: 2026-07-29
sources:
  - docs/adr/0002-core-speaks-req-llm-types.md
---

# Source: ADR 0002 — Core speaks req_llm types

**Path:** `docs/adr/0002-core-speaks-req-llm-types.md`

## Decision

Agent loop uses `req_llm` types directly. Harness provider layer = registry +
model selection + OAuth token manager only. No second message/chunk abstraction.

## Rejected

Harness-owned `Provider` behaviour with own structs (mirroring jido_action→Tool
wrap). Tool seam is the experiment; provider wire is not.

## Consequences

- req_llm breaking changes bleed into the loop (accepted, pinned)
- Multimodal content parts available when read gains images

## Wiki pages updated

- [[entities/providers-auth]]
- [[entities/profiles-plugins]]
- [[entities/arvo]]
