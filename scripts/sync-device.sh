#!/usr/bin/env bash
# Sync a device profile into the active Arduino sketches.
# Usage:
#   ./scripts/sync-device.sh <device-id> test    # TestConfig.h -> GenericTest/
#   ./scripts/sync-device.sh <device-id> miner   # Settings.h -> ESP_Code/
#   ./scripts/sync-device.sh <device-id> all     # both (default)

set -euo pipefail

DEVICE_ID="${1:?Usage: $0 <device-id> [test|miner|all]}"
PROFILE="${2:-all}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_DIR="$ROOT/devices/$DEVICE_ID"

if [[ ! -d "$DEVICE_DIR" ]]; then
  echo "Unknown device: $DEVICE_ID (no devices/$DEVICE_ID/)" >&2
  exit 1
fi

sync_from_example() {
  local name="$1"
  local src="$DEVICE_DIR/$name"
  local example="$DEVICE_DIR/${name}.example"
  if [[ -f "$src" ]]; then
    echo "$src"
    return 0
  fi
  if [[ -f "$example" ]]; then
    cp "$example" "$src"
    echo "Created devices/$DEVICE_ID/$name from .example" >&2
    echo "$src"
    return 0
  fi
  return 1
}

if [[ "$PROFILE" == "test" || "$PROFILE" == "all" ]]; then
  src="$(sync_from_example TestConfig.h)" || {
    echo "No TestConfig.h or TestConfig.h.example for $DEVICE_ID" >&2
    exit 1
  }
  cp "$src" "$ROOT/devices/GenericTest/TestConfig.h"
  echo "Synced devices/$DEVICE_ID/TestConfig.h -> devices/GenericTest/TestConfig.h"
fi

if [[ "$PROFILE" == "miner" || "$PROFILE" == "all" ]]; then
  src="$(sync_from_example Settings.h)" || {
    echo "No Settings.h or Settings.h.example for $DEVICE_ID" >&2
    exit 1
  }
  cp "$src" "$ROOT/ESP_Code/Settings.h"
  echo "Synced devices/$DEVICE_ID/Settings.h -> ESP_Code/Settings.h"
fi

case "$PROFILE" in
  test)  echo "Open testbench/GenericTest/GenericTest.ino" ;;
  miner) echo "Open ESP_Code/ESP_Code.ino" ;;
  *)     echo "Generic test: testbench/GenericTest/ | Miner: ESP_Code/" ;;
esac