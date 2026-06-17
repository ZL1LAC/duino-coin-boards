# Duino-Coin board ports

Personal fork of [Duino-Coin](https://github.com/revoxhere/duino-coin) **ESP_Code** — adapted so mining runs on **specific boards and hardware** I use (displays, touch, pins, etc.).

Not limited to one MCU or screen type. Each board gets a `README_*.md` and whatever code/patches it needs.

Fork base: upstream **ESP_Code 4.3** · network: [duinocoin.com](https://duinocoin.com)

> Old repo names (`duino-coin-esp32c3-minitv`, `duino-coin-esp32c3-displays`) redirect here.

---

## Boards in this repo

| Board | MCU | Notes | Guide |
|-------|-----|-------|--------|
| Spotpear ESP32-C3 1.44" Mini TV | ESP32-C3 | ST7735 128×128 | [README_ESP32C3_MiniTV.md](README_ESP32C3_MiniTV.md) |
| ESP32-2424S012 round | ESP32-C3 | GC9A01 240×240, CST816D touch (C model) | [README_ESP32C3_Round128.md](README_ESP32C3_Round128.md) |

Display comparison and switching: **[DISPLAYS.md](DISPLAYS.md)**

More boards will be added here as separate folders or README + patches — not every port will be ESP32-C3 or have a display.

---

## Quick start (current ESP32-C3 display builds)

1. **Clone**
   ```bash
   git clone https://github.com/ZL1LAC/duino-coin-boards.git
   cd duino-coin-boards
   ```

2. **Credentials** — `copy Settings.h.example Settings.h` (Windows) or `cp Settings.h.example Settings.h`, then set username, WiFi, mining key.

3. **Pick hardware** in `Settings.h` — enable one `DISPLAY_*` line for TFT boards (see board README).

4. **Libraries / patches** — follow the README for your board (TFT_eSPI setup, `patches/`).

5. **Upload** `ESP_Code.ino` with the board and partition settings from that README.

---

## Repository layout

| Path | Purpose |
|------|---------|
| `ESP_Code.ino` | Main miner sketch (upstream-based) |
| `Settings.h.example` | Config template (`Settings.h` gitignored) |
| `DisplayHal.h` | Display drivers and mining UI |
| `patches/` | Library / toolchain fixes per board |
| `README_*.md` | Per-board setup guides |
| `DISPLAYS.md` | TFT board comparison (when applicable) |
| `Lopaka/` | UI layout imports for display boards |

---

## Adding a new board

1. Document it in a new `README_<board>.md`.
2. Add only the code you need (`DisplayHal.h`, drivers, patches, etc.).
3. List it in this README under **Boards in this repo**.

---

## Upstream

[revoxhere/duino-coin](https://github.com/revoxhere/duino-coin)

## License

MIT — see [LICENSE](LICENSE).
