# Sync a device profile into the active Arduino sketches.
# Usage:
#   .\scripts\sync-device.ps1 <device-id> test    # TestConfig.h -> testbench/GenericTest/
#   .\scripts\sync-device.ps1 <device-id> miner   # Settings.h -> ESP_Code/
#   .\scripts\sync-device.ps1 <device-id> all     # both (default)

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$DeviceId,

    [Parameter(Position = 1)]
    [ValidateSet("test", "miner", "all")]
    [string]$Profile = "all"
)

$Root = Split-Path -Parent $PSScriptRoot
$DeviceDir = Join-Path $Root (Join-Path "devices" $DeviceId)

if (-not (Test-Path $DeviceDir)) {
    Write-Error "Unknown device: $DeviceId (no devices/$DeviceId/)"
    exit 1
}

function Sync-FromExample {
    param([string]$Name)
    $src = Join-Path $DeviceDir $Name
    $example = Join-Path $DeviceDir ($Name + ".example")
    if (Test-Path $src) { return $src }
    if (Test-Path $example) {
        Copy-Item -Path $example -Destination $src -Force
        Write-Host "Created devices/$DeviceId/$Name from .example"
        return $src
    }
    return $null
}

if ($Profile -eq "test" -or $Profile -eq "all") {
    $src = Sync-FromExample "TestConfig.h"
    if (-not $src) {
        Write-Error "No TestConfig.h or TestConfig.h.example for $DeviceId"
        exit 1
    }
    $dst = Join-Path $Root "testbench\GenericTest\TestConfig.h"
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "Synced devices/$DeviceId/TestConfig.h -> devices/GenericTest/TestConfig.h"
}

if ($Profile -eq "miner" -or $Profile -eq "all") {
    $src = Sync-FromExample "Settings.h"
    if (-not $src) {
        Write-Error "No Settings.h or Settings.h.example for $DeviceId"
        exit 1
    }
    $dst = Join-Path $Root "ESP_Code\Settings.h"
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "Synced devices/$DeviceId/Settings.h -> ESP_Code/Settings.h"
}

if ($Profile -eq "test") {
    Write-Host "Open testbench/GenericTest/GenericTest.ino (run setup-tft-espi.ps1 first for TFT boards)."
} elseif ($Profile -eq "miner") {
    Write-Host "Open ESP_Code/ESP_Code.ino (run setup-tft-espi.ps1 first for TFT boards)."
} else {
    Write-Host "Profiles synced. Generic test: testbench/GenericTest/GenericTest.ino | Miner: ESP_Code/ESP_Code.ino"
}