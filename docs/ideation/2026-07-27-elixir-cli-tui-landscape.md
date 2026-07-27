# Elixir CLI & TUI Landscape

**Date:** 2026-07-27  
**Status:** Research snapshot (partial coverage; see caveats)  
**Purpose:** Inventory of libraries, tools, and repos for building CLIs and full-screen TUIs in Elixir — for Arvo / coding-agent harness ideation and implementation choices.

## Summary

Elixir has a clear split between:

1. **Full-screen TUI frameworks** — Elm-style apps, widgets, event loops, alternate screen
2. **CLI tooling** — argument parsing, prompts, tables, progress bars (top-to-bottom scripts that exit)

Mature options range from the older termbox-based **Ratatouille** stack to newer pure-BEAM libraries (**Termite**, **term_ui**), SSH-hosted TUIs (**Garnish**), Rust-backed widgets (**ex_ratatui**), and a well-maintained non-fullscreen toolkit (**Owl**).

Curated discovery lists: [awesome-elixir — Command Line Applications](https://github.com/h4cc/awesome-elixir), [LibHunt CLI category](https://elixir.libhunt.com/categories/681-command-line-applications).

---

## Decision tree (practical)

| Need | Prefer |
|------|--------|
| Script with colors, tables, prompts, progress bars | **Owl** + Optimus or `OptionParser` |
| Full-screen interactive app, pure BEAM, modern | **term_ui** or build on **Termite** |
| Rich widgets / Rust ratatui ecosystem | **ex_ratatui** |
| TUI over SSH into a BEAM node | **Garnish** (or ex_ratatui SSH transport) |
| Learn TEA patterns / classic examples | **Ratatouille** (best-documented, largely frozen) |

---

## Full-screen TUI frameworks

### Ratatouille

- **Repo:** https://github.com/ndreynolds/ratatouille  
- **Hex:** `ratatouille` ~0.5.1 (last published ~2020-03-25)  
- **Model:** The Elm Architecture — `init` / `update` / `render`  
- **Backend:** termbox via **ex_termbox** NIFs  
- **View:** HTML-like View DSL  
- **Examples:** counter, editor, snake, documentation browser  
- **Used by:** tefter/cli, Toby (terminal Erlang observer)  
- **Notes:** Historical default and best teaching stack; maintenance largely frozen.

### Garnish

- **Repo:** https://github.com/ausimian/garnish  
- **Hex:** `garnish` ~0.3.0 (updated ~2026-02)  
- **Model:** Reuses Ratatouille’s view/rendering model  
- **Backend:** Erlang’s `:ssh` application (e.g. `ssh_cli` channel); escape sequences — **no ExTermbox NIF**  
- **Fit:** SSH-hosted TUIs into a BEAM node

### ElementTui

- **Repo:** https://codeberg.org/edwinvanl/elementtui  
- **Hex:** `elementtui` ~0.5.1 (updated ~2024-10)  
- **Backend:** termbox2  
- **API:** Element primitives (`text` / `flex` / `hbox`), `render` / `present`, `run_loop`  
- **Related:** component/example repos; **rtttex** app on `{:elementtui, "~> 0.5"}`

### ex_ratatui

- **Repo:** https://github.com/mcass19/ex_ratatui  
- **Hex:** `ex_ratatui` ~0.11.1 (updated ~2026-06)  
- **Backend:** Rust **ratatui** via **Rustler** NIFs  
- **Features:** Many widgets, constraint layout  
- **Runtimes:** LiveView-style callbacks **or** Elm-style reducer  
- **Transports:** local / SSH / Erlang distribution  
- **Fit:** When you want ratatui’s widget ecosystem from Elixir

### term_ui

- **Repo:** https://github.com/pcharbon70/term_ui  
- **Hex:** `term_ui` ~0.2.0 (updated ~2025-12)  
- **Inspiration:** BubbleTea + Ratatui  
- **Model:** Elm Architecture, built-in widgets  
- **Rendering:** Double-buffered differential updates (~60 FPS), direct-mode Elixir/BEAM  
- **Fit:** Modern pure-BEAM full-screen apps without C/Rust NIFs

---

## Low-level terminal libraries

### Termite

- **Repo:** https://github.com/Gazler/termite  
- **Hex:** `termite` ~0.4.3 (updated ~2026-07; **OTP 26+**)  
- **Traits:** Dependency-free, **NIF-free**  
- **Scope:** Cursor, ANSI / ANSI-256 styles, alternate screen, keyboard events  
- **Not:** Full widget set or TEA framework — a terminal I/O primitive  
- **Talk:** Gary Rennie, ElixirConf EU — [Building Terminal Applications With Elixir](https://www.elixirconf.eu/talks/building-terminal-applications-with-elixir/)

### ex_termbox

- **Repo:** https://github.com/ndreynolds/ex_termbox  
- **Hex:** ~1.0.2 (last published ~2020-03)  
- **Scope:** Low-level NIF bindings to original termbox C (`init`, `present`, `put_cell`, `poll_event`, …)  
- **Role:** Foundation for Ratatouille

### rrex_termbox

- **Hex:** `rrex_termbox` ~2.0.4 (updated ~2025-05)  
- **Scope:** Newer **termbox2** bindings; from v2.0.0 uses NIFs from the **termbox2** Hex package

### Also mentioned (lightly surveyed)

- **breeze** — LiveView-style layer on Termite (Hex activity ~2026)
- **ex_termbox_ok** — Hex re-publish (~2025)

---

## CLI UI (not full-screen TUI)

These target scripts that still run top-to-bottom and exit. For full-screen apps, Owl’s docs point users to TermUI, Ratatouille, or ExNcurses.

### Owl

- **Repo:** https://github.com/fuelen/owl  
- **Docs:** https://owl.hexdocs.pm/readme.html  
- **Hex:** `owl` ~0.13.1 (updated ~2026-06)  
- **Features:**
  - Tagged color text (including true-color 24-bit ANSI)
  - Validated input
  - Select / multi-select
  - Tables
  - Progress bars and spinners
  - ASCII boxes and related styled output
- **Fit:** Default non-fullscreen CLI toolkit; sizable dependent base

### Scribe

- **Repo:** https://github.com/codedge-llc/scribe  
- **Scope:** Pretty-print lists of maps/structs as configurable terminal tables (styles, alignment, optional color, custom columns)

### ExPrompt

- **Repo:** https://github.com/bjufre/ex_prompt  
- **Scope:** Interactive prompts — optional/required strings, multi-choice, yes/no, password (optionally hidden)

### Also listed in awesome-elixir

- **table_rex**, **Progress Bar**, **Prompt**, **ExCLI**

---

## Argument parsing and CLI generation

### Optimus

- **Repo:** https://github.com/funbox/optimus  
- **Scope:** Args, flags, options, subcommands; validation; auto help/version (including subcommand help)  
- **Caveat:** funbox/optimus README has indicated less active maintenance there; active work may continue at **savonarola/optimus** — verify before adopting.

### Firex

- **Repo:** https://github.com/msoedov/firex  
- **Scope:** Auto-generate a CLI from module functions (`use Firex` + OptionParser/escript), in the spirit of Python Fire

### stdlib

- **`OptionParser`** — built-in baseline for simple CLIs

---

## Comparison snapshot

| Library | Full-screen | NIF / native | Architecture | Activity signal (Hex ~) |
|---------|-------------|--------------|--------------|-------------------------|
| Ratatouille | Yes | C termbox (ex_termbox) | TEA | Frozen ~2020 |
| Garnish | Yes (SSH) | No NIF | Ratatouille-like views | Active ~2026 |
| ElementTui | Yes | termbox2 | Elements + loop | ~2024 |
| ex_ratatui | Yes | Rustler + ratatui | LiveView **or** TEA | Active ~2026 |
| term_ui | Yes | Pure BEAM | TEA + widgets | Active ~2025 |
| Termite | Low-level | Pure BEAM | Primitives only | Active ~2026 |
| Owl | No | Pure BEAM | Toolkit API | Active ~2026 |

---

## Relevance to Arvo / agent harness

Context from sibling ideation (`docs/ideation/2026-07-27-arvo-*`): TUI-first overnight feature list and harness ideation.

**Likely stacks for a TUI-first Elixir harness:**

1. **Fastest path to a polished non-fullscreen CLI** — Owl + Optimus/`OptionParser` for dashboards that print status, prompts, and tables without owning the whole terminal.
2. **True full-screen operator UI (local)** — **term_ui** or **Termite + custom view layer** if pure BEAM and OTP 26+ are hard requirements; **ex_ratatui** if widget density and layout constraints matter more than NIF complexity.
3. **Remote operator UI into a running BEAM node** — **Garnish** or ex_ratatui’s SSH/distribution transports.
4. **Avoid for greenfield** — Ratatouille alone as the long-term base (great examples, weak maintenance signal); pair only if borrowing TEA patterns.

**Open product questions (not answered by this survey):**

- Is Arvo primarily a **local** full-screen TUI, a **CLI + prompts**, or **SSH-into-cluster**?
- Acceptable native deps (Rustler/NIFs) vs pure BEAM deploy story?
- Target OTP version (Termite needs 26+)?

---

## Discovery links

| Resource | URL |
|----------|-----|
| awesome-elixir CLI section | https://github.com/h4cc/awesome-elixir |
| LibHunt CLI apps | https://elixir.libhunt.com/categories/681-command-line-applications |
| ElixirConf EU talk (Termite-focused) | https://www.elixirconf.eu/talks/building-terminal-applications-with-elixir/ |
| Ratatouille | https://github.com/ndreynolds/ratatouille |
| Garnish | https://github.com/ausimian/garnish |
| ElementTui | https://codeberg.org/edwinvanl/elementtui |
| ex_ratatui | https://github.com/mcass19/ex_ratatui |
| term_ui | https://github.com/pcharbon70/term_ui |
| Termite | https://github.com/Gazler/termite |
| Owl | https://github.com/fuelen/owl |

---

## Caveats and coverage gaps

- Hex **Last Updated** is package-publish time, not always latest git commit.
- No single primary source ranks “best maintained”; activity is inferred per package.
- Optimus fork/maintenance situation needs a manual check before production use.
- Relative popularity / download ranks for Firex, ExPrompt, breeze, etc. not fully quantified.
- Whether higher-level frameworks sit on Termite (beyond using it as a primitive) was not fully established.
- termbox vs termbox2 upstream status not re-verified in this pass.
- Packages named in awesome-elixir but not deep-dived: table_rex, progress_bar, Prompt, ExCLI.

---

## Sources

Primary package READMEs and Hex pages for: ratatouille, garnish, elementtui, ex_ratatui, term_ui, termite, ex_termbox, rrex_termbox, owl, optimus, firex, scribe, ex_prompt; plus awesome-elixir, LibHunt, and ElixirConf EU talk page.

Research produced 2026-07-27 via deep-research workflow; this document is the durable capture for the repo.
