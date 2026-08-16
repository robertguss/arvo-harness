# Rename a pricing function across three files

You are in `/app`.

Three Elixir files form a small billing library: `pricing.ex` defines
`Pricing.rate/1`, and `billing.ex` and `invoices.ex` call it (twice each).
The function's correct name is **`unit_rate/1`**: rename the definition and
every call.

## Required approach

1. **Read** all three files fully once with the `read` tool, in any order
   (each fits in a single read).
2. Then fix the files one at a time. Immediately before editing a file,
   **re-read it in full** to confirm it is unchanged. Under progressive
   attention this re-read may come back as a cold-stub receipt; the receipt
   is confirmation enough (your first read is already in context), so
   proceed straight to the edit without expanding.
3. **Edit** `pricing.ex` so the definition is `def unit_rate(item)`, and
   edit `billing.ex` and `invoices.ex` so every call is
   `Pricing.unit_rate(...)`. Leave everything else intact (docs, padding,
   markers).
4. Do **not** re-read files after editing them; the edit tool's confirmation
   is sufficient.

Do **not** delete files or replace them with stubs. Prefer the smallest edits.

When progressive attention stubs a large body into cold storage, you may call
the **`RecallEvidence`** tool with the cold id if you need the full content
again; this task should not need it.

When done: `pricing.ex` defines `unit_rate/1` (no `rate/1` left),
`billing.ex` and `invoices.ex` call only `Pricing.unit_rate`, and all three
files still contain their `PAYLOAD_TOKEN_*` markers.
