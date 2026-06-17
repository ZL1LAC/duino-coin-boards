# Sync testbench/<board-id>/Settings.h -> ESP_Code/Settings.h
# Usage: .\scripts\sync-testbench-settings.ps1 esp32c3-minitv

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$BoardId
)

$Root = Split-Path -Parent $PSScriptRoot

$Src = Join-Path $Root (Join-Path "testbench\$BoardId" "Settings.h")
$Dst = Join-Path $Root "ESP_Code\Settings.h"
$Example = Join-Path $Root (Join-Path "testbench\$BoardId" "Settings.h.example")

if (-not (Test-Path $Src)) {
    if (Test-Path $Example) {
        Write-Error "Missing Settings.h - copy testbench/$BoardId/Settings.h.example first"
    } else {
        Write-Error "Unknown board testbench: $BoardId"
    }
    exit 1
}

Copy-Item -Path $Src -Destination $Dst -Force
Write-Host "Synced testbench/$BoardId/Settings.h -> ESP_Code/Settings.h"
Write-Host "Open ESP_Code/ESP_Code.ino in Arduino IDE. Run setup-tft-espi.ps1 if you changed TFT pins."
