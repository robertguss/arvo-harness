#!/usr/bin/env python3
"""Generate the multifile workspace: three ~12 KB cross-referencing Elixir
files. Deterministic; rerun to regenerate byte-identical fixtures.

Sizing rationale (verified against lib/arvo/attention/policy.ex,
lib/arvo/attention.ex and lib/arvo/tools/read.ex on 2026-08-16):

- Each file must exceed the 4,000-byte stub threshold or the reuse demotion
  never fires (small results stay full-hot on re-read by design).
- Each file must fit in one read chunk (< 50,000 bytes and < 2,000 lines) so
  a full re-read returns byte-identical text; the digest match is what lets
  the session serve the cold copy (reuse_cold) instead of re-ingesting.
- Total first-read bytes (3 x 12 KB = 36 KB) stay well under the 80,000-byte
  fidelity-exception budget, so this task isolates the reuse mechanism from
  the budget-overflow stubbing needle-junk already measured.
"""

from pathlib import Path

WORKSPACE = Path(__file__).resolve().parent.parent / "environment" / "workspace"

FILE_TARGET_BYTES = 12_000

PRICING_HEAD = '''# Pricing rules fixture for the progressive-attention multifile eval.
# The public function here carries a known wrong name; two files call it.
# REQUIRED_FACT_MARKER: PAYLOAD_TOKEN_c47a1e
defmodule Pricing do
  @moduledoc """
  Unit pricing for the small billing library in this workspace. The public
  pricing function must be renamed; its callers live in the sibling files.
  """

  @base_cents %{"standard" => 500, "bulk" => 350, "rush" => 900}

  def rate(item) when is_map(item) do
    tier = Map.get(item, :tier, "standard")
    qty = Map.get(item, :qty, 1)
    Map.fetch!(@base_cents, tier) * qty
  end

  def currency, do: :usd

'''

BILLING_HEAD = '''# Billing fixture for the progressive-attention multifile eval.
# Two calls into the pricing module must switch to the corrected name.
# REQUIRED_FACT_MARKER: PAYLOAD_TOKEN_8f2d9b
defmodule Billing do
  @moduledoc """
  Charges and estimates for the small billing library. Calls the pricing
  module in two places.
  """

  def charge(item) when is_map(item) do
    cents = Pricing.rate(item)
    %{amount_cents: cents, currency: Pricing.currency()}
  end

  def estimate(items) when is_list(items) do
    items |> Enum.map(fn item -> Pricing.rate(item) end) |> Enum.sum()
  end

'''

INVOICES_HEAD = '''# Invoices fixture for the progressive-attention multifile eval.
# Two calls into the pricing module must switch to the corrected name.
# REQUIRED_FACT_MARKER: PAYLOAD_TOKEN_41e7c2
defmodule Invoices do
  @moduledoc """
  Invoice lines and totals for the small billing library. Calls the pricing
  module in two places.
  """

  def line_item(item) when is_map(item) do
    %{desc: Map.get(item, :desc, ""), cents: Pricing.rate(item)}
  end

  def total(items) when is_list(items) do
    Enum.sum(Enum.map(items, fn item -> Pricing.rate(item) end))
  end

'''

FILES = [
    ("pricing.ex", PRICING_HEAD, "pricing table"),
    ("billing.ex", BILLING_HEAD, "billing ledger"),
    ("invoices.ex", INVOICES_HEAD, "invoice register"),
]


def file_text(head: str, noun: str) -> str:
    tail = "\n  def hello, do: :ok\nend\n"
    lines = [head]
    size = len(head) + len(tail)
    i = 0
    while size < FILE_TARGET_BYTES:
        line = f"  # line {i:05d} {noun} padding\n"
        lines.append(line)
        size += len(line)
        i += 1
    lines.append(tail)
    return "".join(lines)


def main() -> None:
    WORKSPACE.mkdir(parents=True, exist_ok=True)
    for name, head, noun in FILES:
        (WORKSPACE / name).write_text(file_text(head, noun))
    for p in sorted(WORKSPACE.iterdir()):
        print(f"{p.stat().st_size:>7} {p.name}")


if __name__ == "__main__":
    main()
