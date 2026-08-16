#!/usr/bin/env python3
"""Generate the needle-junk workspace: one small parser file (the needle)
and three ~95 KB archive files (the junk). Deterministic; rerun to
regenerate byte-identical fixtures.

Sizing rationale (verified against lib/arvo/attention/policy.ex and
lib/arvo/tools/read.ex on 2026-08-15):

- The read tool returns at most 50,000 bytes per call, so a ~95 KB file
  arrives as a ~50 KB chunk plus a ~45 KB chunk.
- Attention full-hots the first read of a path as a fidelity exception while
  the 80,000-byte exception budget lasts. After one ~50 KB chunk lands hot,
  every later 45-50 KB chunk overflows the budget and is stubbed.
- The 4,000-byte stub threshold alone is NOT enough: three mid-size (10-20 KB)
  distractors would all ride the exception budget into hot context and produce
  zero stubs, failing the on-arm honesty gate.
"""

from pathlib import Path

WORKSPACE = Path(__file__).resolve().parent.parent / "environment" / "workspace"

ARCHIVE_TARGET_BYTES = 95_000

ARCHIVES = [
    ("archive_orders.ex", "ArchiveOrders", "order records", "PAYLOAD_TOKEN_5a71c3"),
    ("archive_invoices.ex", "ArchiveInvoices", "invoice records", "PAYLOAD_TOKEN_e0b866"),
    ("archive_reports.ex", "ArchiveReports", "report records", "PAYLOAD_TOKEN_3c9ad1"),
]

NEEDLE_NAME = "parser_rules.ex"

NEEDLE = '''# Small fixture for the progressive-attention needle-junk eval.
# Agent must rename module ParserBuggy -> ParserFixed (typo fix).
# REQUIRED_FACT_MARKER: PAYLOAD_TOKEN_9d4e2f
defmodule ParserBuggy do
  @moduledoc """
  Parses operator command strings. The module name carries a known typo; the
  three archive files beside this one are deliberately oversized and correct.
  """

  @sep " "

  def parse(line) when is_binary(line) do
    line |> String.trim() |> String.split(@sep, trim: true)
  end

  def command([head | _rest]), do: head
  def command([]), do: nil
end
'''


def archive_text(module: str, noun: str, token: str) -> str:
    head = (
        "# Oversized archive fixture for the progressive-attention needle-junk eval.\n"
        "# Correctly named module; nothing in this file needs editing.\n"
        f"# REQUIRED_FACT_MARKER: {token}\n"
        f"defmodule {module} do\n"
        '  @moduledoc """\n'
        f"  Deliberately oversized archive of {noun}. The one file that needs an\n"
        "  edit lives beside this archive and is small.\n"
        '  """\n'
        "\n"
    )
    tail = "\n  def hello, do: :ok\nend\n"
    lines = [head]
    size = len(head) + len(tail)
    i = 0
    while size < ARCHIVE_TARGET_BYTES:
        line = f"  # line {i:05d} {noun} padding\n"
        lines.append(line)
        size += len(line)
        i += 1
    lines.append(tail)
    return "".join(lines)


def main() -> None:
    WORKSPACE.mkdir(parents=True, exist_ok=True)
    (WORKSPACE / NEEDLE_NAME).write_text(NEEDLE)
    for name, module, noun, token in ARCHIVES:
        (WORKSPACE / name).write_text(archive_text(module, noun, token))
    for p in sorted(WORKSPACE.iterdir()):
        print(f"{p.stat().st_size:>7} {p.name}")


if __name__ == "__main__":
    main()
