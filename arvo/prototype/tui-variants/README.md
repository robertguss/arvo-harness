# PROTOTYPE — Arvo TUI variants (throwaway)

**Question:** What should Arvo’s daily-driver TUI look like?

**Not production.** Visual mockups only. No Session/Agent wiring.

## Run

```bash
# from repo root — one command
python3 -m http.server 8765 --directory arvo/prototype/tui-variants
```

Open: http://127.0.0.1:8765/?variant=A

Or open `index.html` directly in a browser.

## Variants (`?variant=`)

| Key   | Name             | Structure                                              |
| ----- | ---------------- | ------------------------------------------------------ |
| **A** | Classic stack    | Top strip · transcript · bottom input (Pi/Claude-like) |
| **B** | Three-pane IDE   | Sessions/profiles · chat · event rail                  |
| **C** | Command center   | Compact log · large compose · always-on slash dock     |
| **D** | Minimal zen      | Narrow measure · almost no chrome                      |
| **E** | Dashboard header | Metric cards · stream · slash hint dock                |

Switch: floating bar or `←` / `→`.

## After you pick

Capture the winner (or mix) in ideation notes / beads, then implement in real
term_ui (or chosen stack). Do not promote this HTML into production UI.
