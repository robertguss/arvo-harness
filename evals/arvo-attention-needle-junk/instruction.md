# Fix module name in a small file among large archives

You are in `/app`.

The workspace holds four Elixir files. Three are intentionally large archive
modules (`archive_orders.ex`, `archive_invoices.ex`, `archive_reports.ex`)
that are already correct. The small file `parser_rules.ex` currently defines
module **`ParserBuggy`**. Rename it to **`ParserFixed`** (the correct name).

## Required approach

1. **Read** every `.ex` file in `/app` fully at least once with the `read`
   tool, the three archives included. Large files arrive in chunks: keep
   issuing reads with a larger `offset` until a chunk shows the file's last
   line or the tool reports the offset is past the end of the file. Under
   progressive attention a chunk may come back as a cold-stub receipt with a
   short preview; the receipt counts as having read that chunk, so move on to
   the next offset instead of expanding it.
2. **Edit** the module declaration in `parser_rules.ex` so it is
   `defmodule ParserFixed do` (not `ParserBuggy`).
3. Leave everything else intact (the archives, docs, functions, markers).

Do **not** delete files or replace them with stubs. Prefer the smallest edit.

When progressive attention stubs a large body into cold storage, you may call
the **`RecallEvidence`** tool with the cold id if you need the full content
again. You should not need it for the archives; they require no edits.

When done, `/app/parser_rules.ex` must contain `defmodule ParserFixed do` and
must still contain the marker `PAYLOAD_TOKEN_9d4e2f`, and the three archive
files must still contain their own `PAYLOAD_TOKEN_*` markers.
