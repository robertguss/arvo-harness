---
title: Providers and auth
type: entity
tags: [provider, auth, req_llm, xai]
updated: 2026-07-29
sources:
  - CONTEXT.md
  - docs/adr/0002-core-speaks-req-llm-types.md
  - arvo/lib/arvo/providers/
  - arvo/lib/arvo/auth/
  - ore/crates/ore-core/src/lib.rs
---

# Providers and auth

## Provider

Adapter to a model backend. v0.1 ships one (xAI/Grok subscription); Codex and
local OSS models intended later through the same seam. Avoid: backend, model
(`CONTEXT.md`).

## Arvo: req_llm types in core

[[sources/adr-0002-req-llm|ADR 0002]]: agent loop consumes `req_llm` types
directly (`ReqLLM.Context`, stream chunks, usage). Harness provider layer is only
what req_llm does not do:

- Provider registry (`Arvo.Providers.Registry`)
- Model selection
- OAuth token manager for subscription auth (`Arvo.Auth.TokenManager`)

No harness-owned message/chunk behaviour mirroring a second normalizer.
`jido_action` **is** wrapped behind `Tool` (experiment seam); providers are not.

## Auth

- Device-flow OAuth: `/login` → `Arvo.Auth.DeviceFlow`
- Token store: `Arvo.Auth.Store`
- Token manager wires completion (`Arvo.Providers.Completion`)

## Ore

`ore_core::provider`, `ore_core::auth` (Grok device flow, `TokenManager`,
`AuthStore`). Config via `~/.ore/config.toml` / env (`XAI_API_KEY`).
