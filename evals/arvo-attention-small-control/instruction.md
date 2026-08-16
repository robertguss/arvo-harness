# Fix module name in small file

You are in `/app`.

The workspace holds a few small Elixir files. `small_module.ex` currently
defines module **`SmallBuggy`**. Rename it to **`SmallFixed`** (the correct
name).

## Required approach

1. **Read** `small_module.ex` (you may look at the other files too).
2. **Edit** the module declaration so it is `defmodule SmallFixed do` (not `SmallBuggy`).
3. Leave everything else intact (docs, functions, the other files).

Do **not** delete files or replace them with stubs. Prefer the smallest edit.

When progressive attention stubs a large body into cold storage, you may call
the **`RecallEvidence`** tool with the cold id if you need the full content again.

When done, `/app/small_module.ex` must contain `defmodule SmallFixed do` and
must still contain the marker `PAYLOAD_TOKEN_2b8e4d`.
