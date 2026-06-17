# LilyGO T-Deck

Board-specific guide for the **[LilyGO T-Deck](https://lilygo.cc/products/t-deck)** (ESP32-S3, ST7789 2.8" 320×240, keyboard, trackball).

**Project home:** [README.md](../../README.md) · **Testbench:** [testbench/lilygo-t-deck/](../../testbench/lilygo-t-deck/) · **Upstream pins:** [LilyGO T-Deck wiki](https://wiki.lilygo.cc/products/t-deck-series/t-deck/)

> **Status:** generic testbench bring-up — use `testbench/GenericTest/GenericTest.ino` first; miner UI is T-Display S3 layout until tuned from your feedback.

---

## Hardware

| Item | Value |
|------|--------|
| MCU | ESP32-S3FN16R8 (dual-core, 16 MB flash, 8 MB OPI PSRAM) |
| Display | ST7789 IPS, 320×240 (landscape @ rotation 1) |
| Touch | GT911 (I²C) — not used by miner yet |
| Keyboard | I²C — not used by miner yet |
| Trackball | GPIO 1–3, 15 — not used by miner yet |
| Power enable | GPIO **10** (`BOARD_POWERON`) — must be HIGH before display/SPI |
| Backlight | GPIO **42** |
| USB | CDC serial @ **115200** |

### SPI display pins

| Signal | GPIO |
|--------|------|
| MOSI | 41 |
| MISO | 38 |
| SCK | 40 |
| CS | 12 |
| DC | 11 |
| RST | (not wired — software reset) |
| BL | 42 |

Other SPI chip-selects (hold HIGH during init): SD **39**, LoRa **9**.

---

## Quick test (generic sketch)

1. Copy `testbench/lilygo-t-deck/TestConfig.h.example` → `TestConfig.h`
2. Sync:
   ```powershell
   .\scripts\sync-testbench-test.ps1 lilygo-t-deck
   ```
3. `.\scripts\setup-tft-espi.ps1 lilygo-t-deck`
4. Open **`testbench/GenericTest/GenericTest.ino`**, upload with board settings below.
5. Serial Monitor **115200** — color bars + board name on screen; `tick N` on serial.

When that looks good, move to the full miner via `Settings.h` + `sync-testbench-settings.ps1` → `ESP_Code/ESP_Code.ino`.

---

## Settings.h

Enable both defines (testbench profile does this for you):

```cpp
#define DISPLAY_ST7789
#define LILYGO_T_DECK   // power-on + SPI bring-up in DisplayHal.h
```

---

## Arduino IDE

| Setting | Value |
|---------|--------|
| Board | **ESP32S3 Dev Module** |
| USB CDC On Boot | **Enabled** |
| USB Mode | **Hardware CDC and JTAG** |
| Flash Size | **16 MB** |
| PSRAM | **OPI PSRAM** |
| Partition Scheme | **Huge APP (3 MB)** |
| Upload Speed | 921600 (or 115200 if upload fails) |
| Serial Monitor | **115200** |

**CI / arduino-cli FQBN:** `esp32:esp32:esp32s3:UploadSpeed=921600,USBMode=hwcdc,CDCOnBoot=cdc,PartitionScheme=huge_app,FlashSize=16M,PSRAM=opi`

---

## TFT_eSPI

1. Install **TFT_eSPI** (Bodmer) via Library Manager.
2. Copy `tft_setup.h` from this folder → `Arduino/libraries/TFT_eSPI/User_Setup.h`
3. Rebuild after any library change.

If colors look wrong or the panel is blank after a TFT_eSPI update, see LilyGO’s note about the [2024-07-26 init sequence](https://wiki.lilygo.cc/products/t-deck-series/t-deck/) — their [T-Deck repo](https://github.com/Xinyuan-LilyGO/T-Deck) may ship a newer `Setup210` than upstream TFT_eSPI.

---

## Bootloader / flash

Hold **BOOT** (GPIO 0), tap reset, release BOOT if upload fails.

---

## Troubleshooting

| Symptom | Check |
|---------|--------|
| Blank display | Re-copy `tft_setup.h` to `User_Setup.h` (**no `TFT_BL`** — backlight is in `BoardInit.h`) |
| Guru Meditation on boot | Re-copy `tft_setup.h` — must include **`#define USE_HSPI_PORT`** (ESP32 core 3.x + stock TFT_eSPI) |
| Garbled colors | Match `tft_setup.h` to LilyGO `Setup210`; try `TFT_INVERSION_ON` in User_Setup |
| No serial | USB CDC on boot, 115200 baud |
| Upload fails | BOOT+reset; lower upload speed; correct COM port |
| UI clipped / odd layout | Expected for now — layout targets T-Display S3; T-Deck is 320×240 |

---

## Not yet implemented

- GT911 touch, trackball, keyboard input
- T-Deck–specific mining UI layout
- LoRa / SD card (ignored by miner)
