# Arvo Mix release (KTD-D1)

Harbor and other sandboxes must **not** compile Elixir. Ship a target-built
**Mix release** (includes ERTS + NIFs). This is **not** an Ore-style single
static binary upload.

## Build (arch-matching)

Build on the same architecture as the Harbor task image (typically
`linux/amd64`):

```bash
cd arvo
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix release arvo
```

Artifacts:

| Path | Role |
|------|------|
| `_build/prod/rel/arvo/` | Expanded release tree |
| `_build/prod/arvo-VERSION.tar.gz` | Tarball for Harbor upload (`steps: [:assemble, :tar]`) |

Native NIF (`priv/native/fff_search.so`) is included when compiled for that
target. Cross-compile or use a Docker multi-stage builder matching the task
base image when the host arch differs.

## Install layout (sandbox)

```text
/opt/arvo/          # or /usr/local/arvo
  bin/arvo          # release start / eval / remote_console
  bin/arvo-chat     # headless product entry (overlay)
  lib/ ...
  erts-*/ ...
```

PATH wrapper:

```bash
ln -sf /opt/arvo/bin/arvo-chat /usr/local/bin/arvo-chat
```

## Headless entry (KTD-H1)

```bash
export HOME=/home/agent
export XAI_API_KEY=...
export ARVO_PROGRESSIVE_ATTENTION=1   # or 0 for attention-off baseline
export ARVO_CWD=/app                  # task workspace

arvo-chat --cwd /app --prompt "Fix the failing test" \
  --attention on --max-turns 25 --timeout-sec 600
```

Env equivalents:

| Env | Meaning |
|-----|---------|
| `HOME` | Isolated home; sessions under `$HOME/.arvo/sessions/` |
| `ARVO_CWD` | Task workspace (also `--cwd`) |
| `ARVO_PROMPT` | Prompt when not passed as `--prompt` |
| `ARVO_PROGRESSIVE_ATTENTION` | `1`/`on` or `0`/`off` treatment before `Session.open_new` |
| `ARVO_HEADLESS` | Set by wrapper (`1`); Application skips Focus + auto-resume |
| `XAI_API_KEY` | Model credentials (or product auth path) |

### Exit codes

| Code | Condition |
|------|-----------|
| 0 | Turn completed; session + audit written |
| 1 | Invalid args / missing cwd |
| 2 | Provider / model failure |
| 3 | Tool abort / unrecoverable tool error |
| 4 | Max turns |
| 5 | Idle / wall timeout |
| 6 | Missing audit when treatment requires evidence |

### Audit path for scorers

Newest session under `$HOME/.arvo/sessions/**/**.jsonl` with sibling
`*.audit.jsonl` (see `Arvo.Session.Audit.path/1` = `Path.rootname(session) <> ".audit.jsonl"`).

Example glob:

```text
$HOME/.arvo/sessions/*/*.audit.jsonl
```

## Dev without release

From the mix project:

```bash
export ARVO_HEADLESS=1
./bin/arvo-chat --cwd /tmp/task --prompt "hello" --attention on
```

Or:

```bash
ARVO_HEADLESS=1 mix run -e 'System.halt(Arvo.CLI.Chat.main_no_halt(["--cwd", "/tmp/t", "--prompt", "hi"]))'
```

## Smoke checklist

1. `MIX_ENV=prod mix release arvo` succeeds on target arch
2. `ARVO_HEADLESS=1 bin/arvo-chat --cwd … --prompt …` with fake `complete_fun` (ExUnit) writes audit
3. Clean image: unpack tarball only (no repo mount), `arvo-chat --help` exits 1 with usage
4. No Focus TTY ownership in headless (`Application.headless?/0`)
