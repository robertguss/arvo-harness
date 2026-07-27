# Arvo (mix project)

Elixir/BEAM coding-agent harness. See the [root README](../README.md) for philosophy and D1 product docs.

## Quick start

```bash
# from this directory
mix deps.get
mix test
bin/arvo
```

Requires Elixir ~> 1.20 and OTP 26+ (Termite raw Focus uses OTP 28+ shell adapter when available).

## Layout

| Path | Role |
|------|------|
| `lib/arvo/session.ex` | Product turn owner: start_turn, cancel, persist, usage, HEAD |
| `lib/arvo/turn_context.ex` | Single assembly site for messages/tools/skills |
| `lib/arvo/tui/focus.ex` | Default interactive surface |
| `lib/arvo/providers/completion.ex` | SSE streaming completion |
| `lib/arvo/session/handoff.ex` | Attention handoff → new session |
| `lib/arvo/agent.ex` | Pure agent loop (library; tests/injectors) |
| `lib/arvo/repl.ex` | Line-IO fallback (not product default) |

## Config (Application env)

| Key | Default | Meaning |
|-----|---------|---------|
| `:start_focus` | `true` | Boot Focus interactive |
| `:start_repl` | `false` | Boot Repl instead (mutually exclusive product path) |
| `:auto_resume` | `true` | Same-cwd resume last resumable session |
| `:auto_compact` | `false` | Silent auto-compact (off for honesty) |

Test env forces focus/repl/auto_resume off (`config/config.exs`).

## Auth

```bash
# preferred: device flow
# in arvo: /login

# or env
export XAI_API_KEY=...
```

Sessions live under `~/.arvo/sessions/<cwd-slug>/`.
