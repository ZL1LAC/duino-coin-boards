#!/usr/bin/env bash
# Scaffold a new board folder from boards/_template.
# Usage: new-board.sh <board-id> "<Human readable name>"
# Example: new-board.sh esp32-s3-tdisplay "LilyGo T-Display S3"
set -euo pipefail

ID="${1:?board id required (lowercase, hyphens, e.g. esp32-s3-foo)}"
NAME="${2:?board display name required in quotes}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/boards/$ID"
TEMPLATE="$ROOT/boards/_template"

if [[ -d "$DEST" ]]; then
  echo "Board folder already exists: $DEST" >&2
  exit 1
fi

if [[ ! "$ID" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Board id must be lowercase alphanumeric with hyphens: $ID" >&2
  exit 1
fi

cp -r "$TEMPLATE" "$DEST"

python3 - "$ID" "$NAME" "$DEST/README.md" <<'PY'
import sys
board_id, board_name, readme = sys.argv[1:4]
text = open(readme, encoding="utf-8").read()
text = text.replace("{{BOARD_ID}}", board_id).replace("{{BOARD_NAME}}", board_name)
open(readme, "w", encoding="utf-8").write(text)
PY

echo "Created: boards/$ID/"
echo ""
echo "Next steps:"
echo "  1. Fill in boards/$ID/README.md and tft_setup.h"
echo "  2. Add firmware code in ESP_Code/ (DisplayHal.h, drivers, Settings.h.example)"
echo "  3. Add an entry to boards/registry.json (set firmware.enabled when ready for CI)"
echo "  4. Follow docs/ADDING_A_BOARD.md"
echo ""
echo "Registry snippet (edit mcu, defines, tft_setup paths):"
cat <<EOF
    {
      "id": "$ID",
      "name": "$NAME",
      "mcu": "ESP32-C3",
      "guide": "boards/$ID/README.md",
      "features": { "display": "", "resolution": "", "touch": false },
      "firmware": {
        "enabled": false,
        "esptool_chip": "esp32c3",
        "fqbn": "esp32:esp32:esp32c3:UploadSpeed=115200,CDCOnBoot=cdc,PartitionScheme=huge_app",
        "defines_enable": ["DISPLAY_???"],
        "defines_disable": ["DISPLAY_ST7735", "DISPLAY_GC9A01"],
        "tft_setup": "boards/$ID/tft_setup.h",
        "esp32c3_spi_patch": true
      }
    }
EOF
