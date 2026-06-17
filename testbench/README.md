# Testbench

Shared **generic display test** sketch — per-device config lives in [`devices/`](../devices/).

## Generic test (bring-up)

Minimal sketch — color bars, board name, serial ticks. No WiFi, no mining.

1. Read **`devices/<id>/README.md`**
2. `copy devices\<id>\TestConfig.h.example devices\<id>\TestConfig.h` (optional — `sync-device` can create from `.example`)
3. `.\scripts\sync-device.ps1 <id> test`
4. TFT_eSPI boards: `.\scripts\setup-tft-espi.ps1 <id>`
5. Open **`testbench/GenericTest/GenericTest.ino`** · upload · Serial **115200**

See [GenericTest/README.md](GenericTest/README.md).

## Full miner

1. Edit `devices/<id>/Settings.h` (from `Settings.h.example`)
2. `.\scripts\sync-device.ps1 <id> miner`
3. Open **`ESP_Code/ESP_Code.ino`** · upload

When mining works, set `firmware.enabled: true` in [devices/registry.json](../devices/registry.json).

## Layout

```
testbench/
├── README.md
└── GenericTest/     GenericTest.ino + BoardInit.h
```

Device folders (settings, README, tft_setup): **`devices/<id>/`**

Legacy `sync-testbench-*.ps1` scripts forward to `sync-device.ps1`.
