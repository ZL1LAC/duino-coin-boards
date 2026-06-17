#!/usr/bin/env bash
# Scaffold a new device folder from devices/_template.
# Usage: new-device.sh <device-id> "<Human readable name>"
# Example: new-device.sh esp32-s3-tdisplay "LilyGo T-Display S3"
set -euo pipefail

ID="${1:?device id required (lowercase, hyphens, e.g. esp32-s3-foo)}"
NAME="${2:?device display name required in quotes}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/devices/$ID"
TEMPLATE="$ROOT/devices/_template"

if [[ -d "$DEST" ]]; then
  echo "Device folder already exists: $DEST" >&2
  exit 1
fi

if [[ ! "$ID" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Device id must be lowercase alphanumeric with hyphens: $ID" >&2
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

echo "Created: devices/$ID/"
echo ""
echo "Next steps:"
echo "  1. Fill in devices/$ID/README.md (and tft_setup.h if TFT_eSPI)"
echo "  2. Add firmware code in ESP_Code/ (DisplayHal.h, drivers, Settings.h.example)"
echo "  3. Add an entry to devices/registry.json (firmware.enabled when ready for CI)"
echo "  4. Follow docs/ADDING_A_BOARD.md"
echo ""
echo "Registry snippet (edit mcu, defines, tft_setup paths):"
cat <<EOF
    {
      "id": "$ID",
      "name": "$NAME",
      "mcu": "ESP32-C3",
      "guide": "devices/$ID/README.md",
      "features": { "display": "", "resolution": "", "touch": false },
      "firmware": {
        "enabled": false,
        "esptool_chip": "esp32c3",
        "flash_size": "4MB",
        "fqbn": "esp32:esp32:esp32c3:UploadSpeed=115200,CDCOnBoot=cdc,PartitionScheme=huge_app",
        "defines_enable": ["DISPLAY_???"],
        "defines_disable": [
          "DISPLAY_ST7735", "DISPLAY_GC9A01", "DISPLAY_ST7789",
          "DISPLAY_SSD1306", "DISPLAY_GDEQ031T10",
          "LILYGO_T_DECK", "LILYGO_T_DECK_PRO", "HELTEC_WIFI_LORA_32_V2"
        ],
        "tft_setup": "devices/$ID/tft_setup.h",
        "esp32c3_spi_patch": true
      }
    }
EOF
