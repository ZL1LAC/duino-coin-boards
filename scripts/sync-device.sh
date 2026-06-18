#!/usr/bin/env bash
# Sync a device profile into the active Arduino sketches.
# Usage:
#   ./scripts/sync-device.sh <device-id> test          # TestConfig.h -> GenericTest/
#   ./scripts/sync-device.sh <device-id> miner         # Settings.h -> ESP_Code/
#   ./scripts/sync-device.sh <device-id> miner-portal  # Settings.h + CAPTIVE_PORTAL
#   ./scripts/sync-device.sh <device-id> all           # both (default)

set -euo pipefail

DEVICE_ID="${1:?Usage: $0 <device-id> [test|miner|miner-portal|all]}"
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

enable_captive_portal() {
  python3 - "$ROOT/ESP_Code/Settings.h" <<'PY'
import re
import sys

path = sys.argv[1]
text = open(path, encoding="utf-8", errors="replace").read()
text = re.sub(r"^//\s*#define CAPTIVE_PORTAL\s*$", "#define CAPTIVE_PORTAL", text, flags=re.M)
if "#define CAPTIVE_PORTAL" not in text:
    insert = "\n// WiFiManager captive portal - AP Duino-Coin on first boot\n#define CAPTIVE_PORTAL\n"
    if "extern const char PASSWORD" in text:
        text = re.sub(
            r'(extern const char PASSWORD\[\][^\n]*\n)',
            r"\1" + insert,
            text,
            count=1,
        )
    else:
        text = insert + text
open(path, "w", encoding="utf-8").write(text)
PY
}

if [[ "$PROFILE" == "test" || "$PROFILE" == "all" ]]; then
  src="$(sync_from_example TestConfig.h)" || {
    echo "No TestConfig.h or TestConfig.h.example for $DEVICE_ID" >&2
    exit 1
  }
  cp "$src" "$ROOT/testbench/GenericTest/TestConfig.h"
  echo "Synced devices/$DEVICE_ID/TestConfig.h -> testbench/GenericTest/TestConfig.h"
fi

if [[ "$PROFILE" == "miner" || "$PROFILE" == "miner-portal" || "$PROFILE" == "all" ]]; then
  src="$(sync_from_example Settings.h)" || {
    echo "No Settings.h or Settings.h.example for $DEVICE_ID" >&2
    exit 1
  }
  cp "$src" "$ROOT/ESP_Code/Settings.h"
  echo "Synced devices/$DEVICE_ID/Settings.h -> ESP_Code/Settings.h"
fi

if [[ "$PROFILE" == "miner-portal" ]]; then
  enable_captive_portal
  echo "Enabled CAPTIVE_PORTAL in ESP_Code/Settings.h (no WiFi/credentials required at compile time)"
fi

case "$PROFILE" in
  test)          echo "Open testbench/GenericTest/GenericTest.ino" ;;
  miner)         echo "Open ESP_Code/ESP_Code.ino" ;;
  miner-portal)  echo "Open ESP_Code/ESP_Code.ino - first boot uses Duino-Coin WiFi AP" ;;
  *)             echo "Generic test: testbench/GenericTest/ | Miner: ESP_Code/" ;;
esac
