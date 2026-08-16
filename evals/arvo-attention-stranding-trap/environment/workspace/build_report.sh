#!/usr/bin/env bash
# Calibration report generator. Deterministic output; the approved module
# name is published only in this report (encoded here so the report output,
# not this source, is the single place the plain name appears).
set -euo pipefail

enc='FrafbeErynl'
approved="$(printf '%s' "$enc" | tr 'A-Za-z' 'N-ZA-Mn-za-m')"

echo "calibration report v3 (deterministic)"
echo "site: bench-7"
for i in $(seq -w 0 149); do
  echo "channel $i gain=1.000 offset=0.000 status=ok"
done
echo "approved_module_name: ${approved}"
for i in $(seq -w 150 249); do
  echo "channel $i gain=1.000 offset=0.000 status=ok"
done
echo "end of report"
