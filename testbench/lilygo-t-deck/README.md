# LilyGO T-Deck — testbench

**Start here** — generic display test (no mining):

```powershell
copy TestConfig.h.example TestConfig.h
.\scripts\sync-testbench-test.ps1 lilygo-t-deck
```

1. Copy `tft_setup.h` → `Arduino/libraries/TFT_eSPI/User_Setup.h`
   ```powershell
   .\scripts\setup-tft-espi.ps1 lilygo-t-deck
   ```
2. Open **`testbench/GenericTest/GenericTest.ino`** (not ESP_Code)
3. ESP32S3 Dev Module, 16 MB, OPI PSRAM, Huge APP, USB CDC — [board README](../../boards/lilygo-t-deck/README.md)
4. Serial **115200** — report what you see

**Full miner later:** `Settings.h.example` → `sync-testbench-settings.ps1` → `ESP_Code/ESP_Code.ino`
