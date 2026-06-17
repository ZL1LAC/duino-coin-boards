# LilyGO T-Deck Pro

Board-specific guide for the **[LilyGO T-Deck Pro](https://lilygo.cc/products/t-deck-pro)** — ESP32-S3 with **3.1" GDEQ031T10 e-paper** (320×240), keyboard, touch, LoRa SX1262.

**Project home:** [README.md](../../README.md) · **Testbench:** [testbench/lilygo-t-deck-pro/](../../testbench/lilygo-t-deck-pro/) · **Upstream:** [T-Deck-Pro GitHub](https://github.com/Xinyuan-LilyGO/T-Deck-Pro)

> **Status:** testbench bring-up — generic e-paper test first, then full miner. E-paper updates are slower than TFT; mining UI uses fast partial refresh.

---

## Hardware

| Item | Value |
|------|--------|
| MCU | ESP32-S3FN16R8 (dual-core, 16 MB flash, 8 MB OPI PSRAM) |
| Display | GDEQ031T10 e-paper, **240×320 portrait** (default `TFT_ROTATION 0`; rotation 1 → 320×240 landscape) |
| Driver IC | UC8253 via **GxEPD2** |
| Touch | CST328 (I²C) — not used by miner yet |
| Keyboard | TCA8418 — not used by miner yet |
| LoRa | SX1262 — not used by miner |
| Battery | ~1400 mAh, BQ25896 + BQ27220 PMU — **% shown top-right** on mining UI |
| USB | CDC serial @ **115200** |

### E-paper SPI pins (V1.1 — branch `HD-V2-250915`)

| Signal | GPIO |
|--------|------|
| MOSI | **33** |
| SCK | **36** |
| MISO | **47** (shared with SD/LoRa) |
| CS | **34** |
| DC | **35** |
| BUSY | **37** |
| RST | **16** (V1.1) — use **-1** on V1.0 hardware |
| Backlight | **45** (V1.1) |

**Module enables** (driven HIGH in init): GPS **39**, LoRa **46**, modem **41**, E-paper BL **45**.

**Shared SPI CS** (hold HIGH): LoRa CS **3**, LoRa RST **4**, SD CS **48**, EPD CS **34**.

### V1.0 vs V1.1

| Revision | EPD RST | Detect |
|----------|---------|--------|
| V1.1 | GPIO **16** | I2C device **0x5A** (DRV2605) present |
| V1.0 | **not wired** (`-1`) | ALS sensor **0x23** |

In `TestConfig.h` / `Settings.h` for V1.0:

```cpp
#define TDECK_PRO_EPD_RST -1
```

---

## Quick test (generic sketch)

1. Install **GxEPD2** (ZinggJM) + **Adafruit GFX** from Library Manager.
2. Copy `testbench/lilygo-t-deck-pro/TestConfig.h.example` → `TestConfig.h`
3. Sync:
   ```powershell
   .\scripts\sync-testbench-test.ps1 lilygo-t-deck-pro
   ```
4. **No TFT_eSPI** — this board uses GxEPD2 only.
5. Open **`testbench/GenericTest/GenericTest.ino`**, upload with board settings below.
6. Serial Monitor **115200** — B/W band pattern + board name (first refresh ~2–5 s).

When that looks good, move to the full miner via `Settings.h` + `sync-testbench-settings.ps1` → `ESP_Code/ESP_Code.ino`.

---

## Settings.h

Enable both defines:

```cpp
#define DISPLAY_GDEQ031T10
#define LILYGO_T_DECK_PRO
```

---

## Arduino IDE

| Setting | Value |
|---------|--------|
| Board | **ESP32S3 Dev Module** |
| USB CDC On Boot | **Enabled** |
| USB Mode | **Hardware CDC and JTAG** |
| Flash Size | **16 MB** |
| Partition Scheme | **Huge APP (3 MB)** or LilyGO’s 16M/3M APP |
| PSRAM | **OPI PSRAM** |
| Upload Speed | 921600 (or 115200 if upload fails) |
| Serial Monitor | **115200** |

**CI / arduino-cli FQBN:** `esp32:esp32:esp32s3:UploadSpeed=921600,USBMode=hwcdc,CDCOnBoot=cdc,PartitionScheme=huge_app,FlashSize=16M,PSRAM=opi`

---

## Libraries

| Library | Purpose |
|---------|---------|
| [GxEPD2](https://github.com/ZinggJM/GxEPD2) | GDEQ031T10 e-paper (required) |
| Adafruit GFX | GxEPD2 dependency |

No TFT_eSPI configuration for this board.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Blank e-paper, serial OK | Confirm `DISPLAY_GDEQ031T10` + `LILYGO_T_DECK_PRO` in `Settings.h` |
| Panel stuck / ghosting | V1.0: power-cycle battery ~10 s; V1.1: ensure RST=**16** |
| Wrong pins | MOSI=**33**, SCK=**36** — not T-Deck ST7789 pins (40/41) |
| Very slow updates | Normal — mining UI refreshes every ~3 s; full refresh every ~45 s |
| Busy Timeout! on serial | Was caused by updating too fast; re-flash latest firmware |
| Mining OK, no display | `Settings.h` still set for another board — run `sync-testbench-settings.ps1 lilygo-t-deck-pro` |

---

## Not yet implemented

- CST328 touch, TCA8418 keyboard
- LoRa / 4G / GPS / audio

## Battery

The onboard **BQ27220** fuel gauge (I²C **0x55**, SDA **GPIO 13**, SCL **GPIO 14**) is read automatically when `LILYGO_T_DECK_PRO` is enabled. No extra library is required — the miner polls state-of-charge every ~10 s and shows a B/W battery icon plus **%** in the top-right of the mining screen. A small bolt appears inside the icon while charging.

If the gauge is missing on serial you will see `Battery: BQ27220 not found on I2C` — check that the board is powered from battery or USB and that nothing else has claimed the I²C bus.
