# Core speaks req_llm types

The agent loop consumes `req_llm`'s types directly — `ReqLLM.Context`, stream
chunks, usage structs — with no harness-owned Provider behaviour or message
structs in between. The harness's own provider layer is only what req_llm
doesn't do: a provider registry, model selection, and an OAuth token manager for
subscription auth. req_llm already is the multi-provider normalizer
(chat-completions / responses / messages, base_url overrides); wrapping a
normalizer in another normalizer is double abstraction for one shipped provider.

## Considered Options

A harness-owned `Provider` behaviour with its own message/chunk/usage structs,
mirroring how `jido_action` is wrapped behind the `Tool` behaviour (ticket 07).
Rejected: the tool seam is wrapped because tools are the extension surface Rob
experiments on; the provider wire is not the experiment (per 07's rule — own
only where the seam is the experiment). The wrapper would cost a permanent
translation layer, and if req_llm ever dies the swap is one AI-driven refactor
of the loop's type usage.

Note the deliberate asymmetry with ADR-adjacent ticket 07: `jido_action`
wrapped, `req_llm` not.

## Consequences

- req_llm breaking changes bleed into the agent loop; accepted eyes-open (active
  project, pinned dependency).
- Image/multimodal content blocks come for free via req_llm content parts —
  nothing in the seam precludes vision when `read` gains images.
- Decision record: wayfinder ticket
  [Design the provider seam](../../wayfinder/tickets/10-design-the-provider-seam.md).
