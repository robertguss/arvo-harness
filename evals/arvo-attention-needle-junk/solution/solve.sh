#!/usr/bin/env bash
# Oracle reference: minimal rename ParserBuggy -> ParserFixed. Hidden from agent.
set -euo pipefail
cd /app
if [ ! -f parser_rules.ex ]; then
  echo "missing parser_rules.ex" >&2
  exit 1
fi
sed -i 's/defmodule ParserBuggy do/defmodule ParserFixed do/' parser_rules.ex
grep -q 'defmodule ParserFixed do' parser_rules.ex
grep -q 'PAYLOAD_TOKEN_9d4e2f' parser_rules.ex
grep -q 'PAYLOAD_TOKEN_5a71c3' archive_orders.ex
grep -q 'PAYLOAD_TOKEN_e0b866' archive_invoices.ex
grep -q 'PAYLOAD_TOKEN_3c9ad1' archive_reports.ex
