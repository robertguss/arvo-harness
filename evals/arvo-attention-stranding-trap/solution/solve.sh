#!/usr/bin/env bash
# Oracle reference: take the approved name from the report, rename. Hidden from agent.
set -euo pipefail
cd /app
[ -f sensor_hub.ex ] || { echo "missing sensor_hub.ex" >&2; exit 1; }
[ -f build_report.sh ] || { echo "missing build_report.sh" >&2; exit 1; }
name="$(bash build_report.sh | sed -n 's/^approved_module_name: //p')"
[ -n "$name" ]
sed -i "s/defmodule SensorDraft do/defmodule ${name} do/" sensor_hub.ex
grep -q "defmodule ${name} do" sensor_hub.ex
grep -q 'PAYLOAD_TOKEN_b3d7f1' sensor_hub.ex
