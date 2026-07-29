# Fix module name in large file

You are in `/app`.

The file `big_module.ex` is intentionally large. It currently defines module
**`BigBuggy`**. Rename it to **`BigFixed`** (the correct name).

## Required approach

1. **Read** `big_module.ex` fully at least once (you may re-read it).
2. **Edit** the module declaration so it is `defmodule BigFixed do` (not `BigBuggy`).
3. Leave the rest of the file intact (padding comments, `hello/0`, docs).

Do **not** delete the file or replace it with a stub. Prefer the smallest edit.

When progressive attention stubs a large body into cold storage, you may call
the **`RecallEvidence`** tool with the cold id if you need the full content again.

When done, `/app/big_module.ex` must contain `defmodule BigFixed do` and must
still contain the marker `PAYLOAD_TOKEN_7f3a9c`.
