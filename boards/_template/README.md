# {{BOARD_NAME}}

Board-specific guide for **{{BOARD_NAME}}** (`{{BOARD_ID}}`).

**Project home:** [README.md](../../README.md) · **Registry:** [boards/registry.json](../registry.json)

<!-- Fill in before first upload:
  - MCU, display driver, resolution
  - Pin map (SPI / I2C / buttons)
  - Arduino IDE Tools settings
  - TFT_eSPI setup steps
  - Troubleshooting from bring-up
-->

## Hardware

| Item | Value |
|------|--------|
| MCU | |
| Display | |
| Resolution | |
| Touch | none / driver |
| USB | |

## Settings.h

In `ESP_Code/Settings.h`, enable **one** display profile:

```cpp
// #define DISPLAY_ST7735
// #define DISPLAY_GC9A01
// #define DISPLAY_YOUR_NEW_DRIVER   ← add in DisplayHal.h first
```

## TFT_eSPI

1. Copy `tft_setup.h` from this folder → `Arduino/libraries/TFT_eSPI/User_Setup.h`
2. Apply patches from [patches/](../../patches/) if needed
3. Re-upload after any library change

## Arduino IDE

| Setting | Value |
|---------|--------|
| Board | |
| USB CDC On Boot | |
| Partition Scheme | |
| Upload Speed | |
| Serial Monitor | 115200 (ESP32-C3 USB-CDC) |

## Upload

Open `ESP_Code/ESP_Code.ino`, upload, Serial Monitor **115200**.

**Pre-built firmware:** after [registry.json](../registry.json) entry + CI update — [GitHub Releases](https://github.com/ZL1LAC/duino-coin-boards/releases).

## Checklist

See [docs/ADDING_A_BOARD.md](../../docs/ADDING_A_BOARD.md).
