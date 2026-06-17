#!/usr/bin/env bash
# Sync testbench/<board-id>/Settings.h -> ESP_Code/Settings.h
# Usage: ./scripts/sync-testbench-settings.sh esp32c3-minitv

set -euo pipefail

BOARD_ID="${1:?Usage: $0 <board-id>}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/testbench/$BOARD_ID/Settings.h"
DST="$ROOT/ESP_Code/Settings.h"
EXAMPLE="$ROOT/testbench/$BOARD_ID/Settings.h.example"

if [[ ! -f "$SRC" ]]; then
  if [[ -f "$EXAMPLE" ]]; then
    echo "Missing $SRC — run: cp testbench/$BOARD_ID/Settings.h.example testbench/$BOARD_ID/Settings.h" >&2
  else
    echo "Unknown board testbench: $BOARD_ID" >&2
  fi
  exit 1
fi

cp "$SRC" "$DST"
echo "Synced: testbench/$BOARD_ID/Settings.h -> ESP_Code/Settings.h"
echo "Open ESP_Code/ESP_Code.ino in Arduino IDE, apply tft_setup.h, then upload."
