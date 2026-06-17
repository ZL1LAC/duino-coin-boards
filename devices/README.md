# Devices

Each folder here is **everything you need for one piece of hardware** — one README, miner settings, generic-test config, and TFT setup (when applicable).

Shared firmware stays in [`ESP_Code/`](../ESP_Code/) (open `ESP_Code.ino` in Arduino IDE). Shared bring-up sketch: [`testbench/GenericTest/`](../testbench/GenericTest/).

## Quick start

```powershell
# 1. Pick your device and read its README
# 2. Generic display test (optional)
copy devices\lilygo-t-deck-pro\TestConfig.h.example devices\lilygo-t-deck-pro\TestConfig.h
.\scripts\sync-device.ps1 lilygo-t-deck-pro test
# TFT boards: .\scripts\setup-tft-espi.ps1 lilygo-t-deck
# Upload testbench/GenericTest/GenericTest.ino

# 3. Full miner
copy devices\lilygo-t-deck-pro\Settings.h.example devices\lilygo-t-deck-pro\Settings.h
# Edit WiFi + username in Settings.h
.\scripts\sync-device.ps1 lilygo-t-deck-pro miner
# Upload ESP_Code/ESP_Code.ino
```

`sync-device` can copy from `.example` automatically if `Settings.h` / `TestConfig.h` do not exist yet.

## Registry

[`registry.json`](registry.json) lists all devices — CI release builds and `setup-tft-espi` read paths from here.

## Devices in this repo

| ID | MCU | Display |
|----|-----|---------|
| [esp32c3-minitv](esp32c3-minitv/) | ESP32-C3 | ST7735 128×128 |
| [esp32c3-round128](esp32c3-round128/) | ESP32-C3 | GC9A01 240×240 |
| [lilygo-t-deck](lilygo-t-deck/) | ESP32-S3 | ST7789 |
| [lilygo-t-deck-pro](lilygo-t-deck-pro/) | ESP32-S3 | GDEQ031T10 e-paper |
| [heltec-wifi-lora-32-v2](heltec-wifi-lora-32-v2/) | ESP32 | SSD1306 OLED |

Scaffold a new device: `bash scripts/new-device.sh <id> "<name>"` (from [`_template/`](_template/)).