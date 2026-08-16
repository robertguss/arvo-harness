#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  build-essential curl ca-certificates git pkg-config >/dev/null

curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable >/dev/null 2>&1
. "$HOME/.cargo/env"

mkdir -p /work
tar -C /src \
  --exclude=./_build \
  --exclude=./.git \
  --exclude=./evals/jobs \
  --exclude=./native/fff_search/target \
  --exclude='./priv/native/*.so' \
  -cf - . | tar -C /work -xf -

cd /work
export MIX_ENV=prod MIX_HOME=/tmp/mix HEX_HOME=/tmp/hex CARGO_TARGET_DIR=/tmp/cargo-target
mix local.hex --force >/dev/null
mix local.rebar --force >/dev/null
mix release arvo --overwrite

ls -la _build/prod/*.tar.gz
cp _build/prod/arvo-*.tar.gz /out/
echo LINUX-RELEASE-OK
