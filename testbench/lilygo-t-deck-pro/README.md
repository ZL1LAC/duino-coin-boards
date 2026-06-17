# LilyGO T-Deck Pro — testbench

**Board guide:** [boards/lilygo-t-deck-pro/](../../boards/lilygo-t-deck-pro/)

## Generic test

1. Install **GxEPD2** + **Adafruit GFX**
2. `TestConfig.h.example` → `TestConfig.h`
3. `.\scripts\sync-testbench-test.ps1 lilygo-t-deck-pro`
4. Upload `testbench/GenericTest/GenericTest.ino` · Serial **115200**

## Full miner

1. `Settings.h.example` → `Settings.h` (WiFi + credentials)
2. `.\scripts\sync-testbench-settings.ps1 lilygo-t-deck-pro`
3. Upload `ESP_Code/ESP_Code.ino`

V1.0 hardware: set `#define TDECK_PRO_EPD_RST -1` in TestConfig/Settings.
