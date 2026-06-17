#!/usr/bin/env bash
# Sync testbench/<board-id>/TestConfig.h -> testbench/generic/TestConfig.h
# Usage: ./scripts/sync-testbench-test.sh lilygo-t-deck

set -euo pipefail

BOARD_ID="${1:?board id required}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/testbench/$BOARD_ID/TestConfig.h"
DST="$ROOT/testbench/GenericTest/TestConfig.h"
EXAMPLE="$ROOT/testbench/$BOARD_ID/TestConfig.h.example"

if [[ ! -f "$SRC" ]]; then
  if [[ -f "$EXAMPLE" ]]; then
    echo "Missing TestConfig.h — copy testbench/$BOARD_ID/TestConfig.h.example first" >&2
  else
    echo "Unknown board testbench: $BOARD_ID" >&2
  fi
  exit 1
fi

cp "$SRC" "$DST"
echo "Synced testbench/$BOARD_ID/TestConfig.h -> testbench/GenericTest/TestConfig.h"
echo "Open testbench/GenericTest/GenericTest.ino, apply tft_setup.h, then upload."
