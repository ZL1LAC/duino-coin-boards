# Duino-Coin board ports

Personal fork of [Duino-Coin](https://github.com/revoxhere/duino-coin) **ESP_Code** — adapted so mining runs on **specific boards and hardware** I use (displays, touch, pins, etc.).

Not limited to one MCU or screen type. Each device has its own folder under **`devices/`** with a README, settings, and hardware config.

Fork base: upstream **ESP_Code 4.3** · network: [duinocoin.com](https://duinocoin.com)

> Old repo names (`duino-coin-esp32c3-minitv`, `duino-coin-esp32c3-displays`) redirect here.

---

## Devices in this repo

| Device | MCU | Notes | Guide |
|--------|-----|-------|--------|
| Spotpear ESP32-C3 1.44" Mini TV | ESP32-C3 | ST7735 128×128 | [devices/esp32c3-minitv/](devices/esp32c3-minitv/) |
| ESP32-2424S012 round | ESP32-C3 | GC9A01 240×240, CST816D touch | [devices/esp32c3-round128/](devices/esp32c3-round128/) |
| LilyGO T-Deck | ESP32-S3 | ST7789 320×240 — **testbench** | [devices/lilygo-t-deck/](devices/lilygo-t-deck/) |
| Heltec WiFi LoRa 32 (V2) | ESP32 | SSD1306 OLED + LoRa — **testbench** | [devices/heltec-wifi-lora-32-v2/](devices/heltec-wifi-lora-32-v2/) |
| LilyGO T-Deck Pro | ESP32-S3 | GDEQ031T10 e-paper — **testbench** | [devices/lilygo-t-deck-pro/](devices/lilygo-t-deck-pro/) |

**Pre-built release firmware** (GitHub Releases): only devices with `firmware.enabled: true` in [devices/registry.json](devices/registry.json) — currently the two ESP32-C3 TFT boards.

Display comparison (C3 TFT): **[docs/DISPLAYS.md](docs/DISPLAYS.md)**

**Adding another device:** [docs/ADDING_A_BOARD.md](docs/ADDING_A_BOARD.md) · registry: [devices/registry.json](devices/registry.json) · scaffold: `bash scripts/new-device.sh <id> "<name>"`

---

## Quick start

### Pre-built binary (ESP32-C3 TFT devices)

See [firmware/README.md](firmware/README.md) and [docs/FLASH.md](docs/FLASH.md).

### Build from source (any device)

1. **Clone** and open the guide for your hardware: **`devices/<id>/README.md`**

2. **Sync device profile**
   ```powershell
   copy devices\lilygo-t-deck-pro\Settings.h.example devices\lilygo-t-deck-pro\Settings.h
   # edit WiFi + username in Settings.h
   .\scripts\sync-device.ps1 lilygo-t-deck-pro miner
   ```

3. **Libraries / TFT setup** — follow the device README (`setup-tft-espi.ps1` for TFT_eSPI boards).

4. **Upload** — open **`ESP_Code/ESP_Code.ino`** with the Arduino board settings from that README.

For **bring-up**, run generic test first: `sync-device.ps1 <id> test` → [testbench/GenericTest/GenericTest.ino](testbench/GenericTest/GenericTest.ino).

---

## Repository layout

```
duino-coin-devices/
├── ESP_Code/           Shared miner sketch (open ESP_Code.ino here)
├── devices/            Per-device README, Settings, TestConfig, tft_setup, registry.json
│   ├── registry.json
│   ├── esp32c3-minitv/
│   ├── lilygo-t-deck-pro/
│   └── ...
├── testbench/
│   └── GenericTest/    Shared bring-up sketch
├── docs/               Cross-device documentation
├── scripts/            sync-device, build-firmware, new-device
├── firmware/           Pre-built flash images (GitHub Releases)
└── patches/            Library / toolchain fixes
```

| Path | Purpose |
|------|---------|
| `devices/<id>/` | **Start here** — README, `Settings.h.example`, `TestConfig.h.example`, `tft_setup.h` |
| `devices/registry.json` | Device list, CI firmware matrix, TFT paths |
| `ESP_Code/` | Shared miner, `DisplayHal.h`, board drivers |
| `testbench/GenericTest/` | Display-only test before mining |
| `scripts/sync-device.ps1` | Copy device profile → active sketches |

---

## Adding a new device

1. `bash scripts/new-device.sh <device-id> "<Name>"`
2. Implement shared firmware in `ESP_Code/` as needed
3. Add entry to **`devices/registry.json`**
4. Document in `devices/<id>/README.md` and list in this README

Full checklist: **[docs/ADDING_A_BOARD.md](docs/ADDING_A_BOARD.md)**

---

## Upstream

[revoxhere/duino-coin](https://github.com/revoxhere/duino-coin)

## License

MIT — see [LICENSE](LICENSE).