#!/usr/bin/env bash
# Oracle reference: minimal rename SmallBuggy -> SmallFixed. Hidden from agent.
set -euo pipefail
cd /app
if [ ! -f small_module.ex ]; then
  echo "missing small_module.ex" >&2
  exit 1
fi
sed -i 's/defmodule SmallBuggy do/defmodule SmallFixed do/' small_module.ex
grep -q 'defmodule SmallFixed do' small_module.ex
grep -q 'PAYLOAD_TOKEN_2b8e4d' small_module.ex
