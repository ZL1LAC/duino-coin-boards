# Display & board guide

This firmware supports **multiple ESP32-C3 boards** from one codebase. Enable exactly **one** display in `Settings.h`.

**Main readme:** [README.md](README.md)

## Quick comparison

| | Spotpear Mini TV | ESP32-2424S012 (round) |
|---|------------------|-------------------------|
| **Board** | Spotpear ESP32-C3 1.44" | ESP32-2424S012 1.28" |
| **Panel** | ST7735 rectangular | GC9A01 round |
| **Resolution** | 128 × 128 | 240 × 240 |
| **Shape** | Square (mini TV case) | Circle (37 mm) |
| **Settings.h** | `#define DISPLAY_ST7735` | `#define DISPLAY_GC9A01` |
| **TFT_eSPI setup** | `Setup_Spotpear_ESP32C3_144.h` | `Setup_ESP32_2424S012.h` |
| **Setup reference** | `ST7735_setup.h` | `GC9A01_setup.h` |
| **README** | `README_ESP32C3_MiniTV.md` | `README_ESP32C3_Round128.md` |
| **Init** | `tft.init(INITR_GREENTAB)` | `tft.init()` + backlight GPIO3 |
| **SPI pins** | SCLK=3, MOSI=4, CS=2, DC=0, RST=5 | SCLK=6, MOSI=7, CS=10, DC=2, RST=-1 |
| **Touch** | — | CST816D I2C: SDA=4, SCL=5, INT=0, RST=1 |

Enable **one** display line in `Settings.h` only.

## Mining screen (same on both)

```
┌──────────────────────────────┐
│ ▂▄▆█  10ms   darkhunter~     │
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

On the **round** panel this layout is scaled and inset (`GC9A01_SX` / `GC9A01_SY` in `DisplayHal.h`) so rows stay inside the visible circle.

### Touch (ESP32-2424S012C only)

Driver is the **factory CST816D** code (`CST816D.cpp` / `CST816D.h`) from the board demo — INT pin is pulsed on init, then set `INPUT`.

| Gesture | Action |
|---------|--------|
| Tap | Cycle screen rotation (same as BOOT button) |
| Long press | Toggle backlight bright / dim |
| Swipe up / down | Brightness up / down |

Comment out `#define TOUCH_CST816D` in `Settings.h` to disable touch support.

## Switching boards

1. Change `#define` in `Settings.h` (`DISPLAY_ST7735` ↔ `DISPLAY_GC9A01`).
2. Swap TFT_eSPI `User_Setup_Select.h` to the matching setup file (see `patches/TFT_eSPI/`).
3. Re-upload (full recompile required).
4. ESP32-C3 **SPI patch** in `TFT_eSPI_ESP32_C3.h` is required for **both** boards on Arduino ESP32 core 3.x.

## Code location

| Display | `DisplayHal.h` section |
|---------|-------------------------|
| ST7735 | `#if defined(DISPLAY_ST7735)` — source layout (128×128) |
| GC9A01 | `#if defined(DISPLAY_GC9A01)` — scaled copy of ST7735 UI |
