#!/usr/bin/env bash
# Oracle reference: minimal rename BigBuggy -> BigFixed. Hidden from agent.
set -euo pipefail
cd /app
if [ ! -f big_module.ex ]; then
  echo "missing big_module.ex" >&2
  exit 1
fi
sed -i 's/defmodule BigBuggy do/defmodule BigFixed do/' big_module.ex
grep -q 'defmodule BigFixed do' big_module.ex
grep -q 'PAYLOAD_TOKEN_7f3a9c' big_module.ex
