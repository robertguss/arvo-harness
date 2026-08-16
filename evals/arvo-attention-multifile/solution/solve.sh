#!/usr/bin/env bash
# Oracle reference: rename rate/1 -> unit_rate/1 across all three files. Hidden from agent.
set -euo pipefail
cd /app
for f in pricing.ex billing.ex invoices.ex; do
  [ -f "$f" ] || { echo "missing $f" >&2; exit 1; }
done
sed -i 's/def rate(item)/def unit_rate(item)/' pricing.ex
sed -i 's/Pricing\.rate(/Pricing.unit_rate(/g' billing.ex invoices.ex
grep -q 'def unit_rate(item)' pricing.ex
! grep -q 'def rate(' pricing.ex
grep -q 'Pricing.unit_rate(' billing.ex
! grep -q 'Pricing\.rate(' billing.ex
grep -q 'Pricing.unit_rate(' invoices.ex
! grep -q 'Pricing\.rate(' invoices.ex
grep -q 'PAYLOAD_TOKEN_c47a1e' pricing.ex
grep -q 'PAYLOAD_TOKEN_8f2d9b' billing.ex
grep -q 'PAYLOAD_TOKEN_41e7c2' invoices.ex
