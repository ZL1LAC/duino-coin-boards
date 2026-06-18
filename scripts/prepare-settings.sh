#!/usr/bin/env bash
# Generate ESP_Code/Settings.h for a firmware release build.
# Usage: prepare-settings.sh <device-id from devices/registry.json>
set -euo pipefail

BOARD="${1:?board id required}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/ESP_Code/Settings.h"
# Full miner template (display drivers, touch, blink constants) — device
# Settings.h.example is for local sync-device builds only.
EXAMPLE="$ROOT/ESP_Code/Settings.h.example"

cp "$EXAMPLE" "$OUT"

python3 - "$BOARD" "$OUT" "$ROOT/devices/registry.json" <<'PY'
import json
import re
import sys

board_id, path, registry_path = sys.argv[1:4]
registry = json.load(open(registry_path, encoding="utf-8"))
entry = next((b for b in registry["boards"] if b["id"] == board_id), None)
if not entry or not entry.get("firmware", {}).get("enabled"):
    raise SystemExit(f"board not in registry or firmware not enabled: {board_id}")

fw = entry["firmware"]
text = open(path, encoding="utf-8", errors="replace").read()

def set_define(name, enabled):
    global text
    if enabled:
        text = re.sub(rf"^//\s*#define {name}\s*$", f"#define {name}", text, flags=re.M)
        text = re.sub(rf"^//\s*#define {name}\b", f"#define {name}", text, flags=re.M)
    else:
        text = re.sub(rf"^#define {name}\s*$", f"// #define {name}", text, flags=re.M)

set_define("CAPTIVE_PORTAL", True)
for name in fw.get("defines_enable", []):
    set_define(name, True)
for name in fw.get("defines_disable", []):
    set_define(name, False)

open(path, "w", encoding="utf-8").write(text)
PY

echo "Wrote $OUT for board: $BOARD (CAPTIVE_PORTAL enabled)"