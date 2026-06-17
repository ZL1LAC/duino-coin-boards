# Duino-Coin ESP32-C3 display miners

One firmware fork for **ESP32-C3 boards with small TFT screens** — pick your hardware in `Settings.h`, apply the matching TFT_eSPI patch, and upload.

Fork of [Duino-Coin](https://github.com/revoxhere/duino-coin) **ESP_Code 4.3** · mines on the [Duino-Coin](https://duinocoin.com) network.

> **Previously:** [duino-coin-esp32c3-minitv](https://github.com/ZL1LAC/duino-coin-esp32c3-minitv) — GitHub redirects old links here.

---

## Supported boards

| Board | Model / SKU | Panel | Size | Touch | Setup guide |
|-------|-------------|-------|------|-------|-------------|
| Spotpear ESP32-C3 1.44" Mini TV | — | ST7735 | 128×128 | — | [README_ESP32C3_MiniTV.md](README_ESP32C3_MiniTV.md) |
| ESP32-2424S012 round | 2424S012**C** | GC9A01 | 240×240 | CST816D | [README_ESP32C3_Round128.md](README_ESP32C3_Round128.md) |
| ESP32-2424S012 round | 2424S012**N** | GC9A01 | 240×240 | none | same (disable touch in Settings) |

Full pin maps, `#define`s, and switching steps: **[DISPLAYS.md](DISPLAYS.md)**

All boards share the **same mining UI** (wifi, hashrate, diff, shares, IP, uptime). The round panel uses a scaled copy of the Spotpear layout so rows stay inside the visible circle.

---

## Quick start (any board)

1. **Clone**
   ```bash
   git clone https://github.com/ZL1LAC/duino-coin-esp32c3-displays.git
   cd duino-coin-esp32c3-displays
   ```

2. **Credentials** — copy `Settings.h.example` → `Settings.h`, set Duino-Coin username, WiFi (2.4 GHz), mining key.

3. **Pick one display** in `Settings.h` (comment out the other):
   ```cpp
   #define DISPLAY_ST7735    // Spotpear Mini TV
   // #define DISPLAY_GC9A01 // ESP32-2424S012 round
   ```

4. **TFT_eSPI** — copy the setup file from `patches/TFT_eSPI/` for your board into the Arduino TFT_eSPI library; apply the ESP32-C3 SPI fix (see [patches/TFT_eSPI/README.md](patches/TFT_eSPI/README.md)).

5. **Upload** `ESP_Code.ino` — board **ESP32C3 Dev Module**, USB CDC On Boot **Enabled**, partition **Huge APP**, upload **115200**.

---

## Repository layout

| Path | Purpose |
|------|---------|
| `ESP_Code.ino` | Main sketch |
| `Settings.h.example` | Config template (`Settings.h` is gitignored) |
| `DisplayHal.h` | Display abstraction — ST7735 + GC9A01 mining UI |
| `CST816D.cpp` / `.h` | Capacitive touch (round board) |
| `ST7735_setup.h` / `GC9A01_setup.h` | TFT_eSPI pin reference (repo root) |
| `patches/TFT_eSPI/` | Installable user setups + C3 SPI crash fix |
| `DISPLAYS.md` | Board comparison, touch gestures, switching |
| `Lopaka/` | [Lopaka](https://lopaka.app) import files for UI design |
| `README_ESP32C3_*.md` | Per-board Arduino IDE walkthroughs |

---

## Mining screen

```
┌──────────────────────────────┐
│ ▂▄▆█  10ms   node~           │
├──────────────────────────────┤
│  63.4              kH/s      │
├──────────────────────────────┤
│  6400          diff          │
│  0.2           sh/s          │
├──────────────────────────────┤
│ ✓ 110/110         (100%)     │
├──────────────────────────────┤
│ 192.168.x.x        0h9m24s   │
└──────────────────────────────┘
```

## Touch (ESP32-2424S012C only)

| Input | Action |
|-------|--------|
| Tap | Rotate display |
| Swipe up / down | Brightness |
| BOOT (GPIO9) | Rotate display |

---

## Adding another board

1. Add a `DISPLAY_*` block in `DisplayHal.h` (or extend an existing driver).
2. Add `*_setup.h` + `patches/TFT_eSPI/Setup_*.h`.
3. Document pins and steps in `DISPLAYS.md` and a `README_*.md`.

---

## Upstream

Official Duino-Coin: [revoxhere/duino-coin](https://github.com/revoxhere/duino-coin)

## License

MIT — same as upstream Duino-Coin. See [LICENSE](LICENSE).
