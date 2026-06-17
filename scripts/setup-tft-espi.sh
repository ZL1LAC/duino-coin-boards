#!/usr/bin/env bash
# Install TFT_eSPI board setup + optional ESP32-C3 SPI patch.
# Usage: setup-tft-espi.sh <board-id> [TFT_eSPI_dir]
set -euo pipefail

BOARD="${1:?board id required}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TFT_DIR="${2:-${ARDUINO_LIBRARIES:-$HOME/Arduino/libraries}/TFT_eSPI}"
SKETCH_SETUP_GENERIC="$ROOT/testbench/GenericTest/tft_setup.h"
SKETCH_SETUP_MINER="$ROOT/ESP_Code/tft_setup.h"
SELECT="$TFT_DIR/User_Setup_Select.h"

if [[ ! -d "$TFT_DIR" ]]; then
  echo "TFT_eSPI not found at: $TFT_DIR" >&2
  exit 1
fi

readarray -t CFG < <(python3 - "$BOARD" "$ROOT/devices/registry.json" <<'PY'
import json, sys
board_id, registry_path = sys.argv[1:3]
entry = next(b for b in json.load(open(registry_path))["boards"] if b["id"] == board_id)
fw = entry["firmware"]
print(fw.get("tft_setup", ""))
print(fw.get("tft_setup_id", ""))
print("1" if fw.get("esp32c3_spi_patch") else "0")
PY
)

SRC_REL="${CFG[0]}"
SETUP_ID="${CFG[1]}"
SPI_PATCH="${CFG[2]}"

if [[ -z "$SRC_REL" ]]; then
  echo "No tft_setup in registry for $BOARD — skipping TFT_eSPI config" >&2
  exit 0
fi

SRC="$ROOT/$SRC_REL"
if [[ ! -f "$SRC" ]]; then
  echo "TFT setup file missing: $SRC" >&2
  exit 1
fi

mkdir -p "$TFT_DIR/User_Setups"
BASENAME="$(basename "$SRC_REL")"
cp "$SRC" "$TFT_DIR/User_Setup.h"
cp "$SRC" "$TFT_DIR/User_Setups/$BASENAME"
cp "$SRC" "$SKETCH_SETUP_GENERIC"
cp "$SRC" "$SKETCH_SETUP_MINER"

if ! grep -q 'USER_SETUP_LOADED' "$TFT_DIR/User_Setup.h"; then
  cat >> "$TFT_DIR/User_Setup.h" <<'EOF'

#ifndef USER_SETUP_LOADED
#define USER_SETUP_LOADED
#endif
EOF
  cp "$TFT_DIR/User_Setup.h" "$SKETCH_SETUP_GENERIC"
  cp "$TFT_DIR/User_Setup.h" "$SKETCH_SETUP_MINER"
fi

if [[ -f "$SELECT" ]]; then
  python3 - "$SELECT" <<'PY'
import re, sys
path = sys.argv[1]
lines = open(path, encoding="utf-8").read().splitlines()
out = []
for line in lines:
    if re.match(r'^\s*#include\s+<User_Setups/', line):
        if not re.match(r'^\s*//', line):
            line = re.sub(r'^(\s*)#include', r'\1//#include', line)
    elif re.search(r'#include\s+<User_Setup\.h>', line):
        line = '#include <User_Setup.h>           // duino-coin-boards: active board (setup-tft-espi.sh)'
    out.append(line)
open(path, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
PY
  echo "Patched User_Setup_Select.h -> #include <User_Setup.h> only"
fi

if [[ -n "$SETUP_ID" && "$SETUP_ID" != "None" ]]; then
  grep -q '^#define USER_SETUP_ID' "$TFT_DIR/User_Setup.h" || \
    sed -i "1i#define USER_SETUP_ID ${SETUP_ID}" "$TFT_DIR/User_Setup.h"
fi

if [[ "$SPI_PATCH" == "1" ]]; then
  C3_H="$TFT_DIR/Processors/TFT_eSPI_ESP32_C3.h"
  if [[ -f "$C3_H" ]] && ! grep -q 'DR_REG_SPI2_BASE' "$C3_H"; then
    cat >> "$C3_H" <<'EOF'

// duino-coin-boards: ESP32-C3 SPI fix (Arduino ESP32 core 3.x)
#if CONFIG_IDF_TARGET_ESP32C3
  #ifdef REG_SPI_BASE
    #undef REG_SPI_BASE
  #endif
  #define REG_SPI_BASE(i) DR_REG_SPI2_BASE
#endif
EOF
  fi
fi

echo "TFT_eSPI configured for $BOARD"
echo "  User_Setup.h:     $TFT_DIR/User_Setup.h"
echo "  GenericTest copy: $SKETCH_SETUP_GENERIC"
echo "  ESP_Code copy:    $SKETCH_SETUP_MINER"
