# Sync testbench/<board-id>/TestConfig.h -> testbench/generic/TestConfig.h
# Usage: .\scripts\sync-testbench-test.ps1 lilygo-t-deck

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$BoardId
)

$Root = Split-Path -Parent $PSScriptRoot

$Src = Join-Path $Root (Join-Path "testbench\$BoardId" "TestConfig.h")
$Dst = Join-Path $Root "testbench\GenericTest\TestConfig.h"
$Example = Join-Path $Root (Join-Path "testbench\$BoardId" "TestConfig.h.example")

if (-not (Test-Path $Src)) {
    if (Test-Path $Example) {
        Write-Error "Missing TestConfig.h - copy testbench/$BoardId/TestConfig.h.example first"
    } else {
        Write-Error "Unknown board testbench: $BoardId (no TestConfig.h.example)"
    }
    exit 1
}

Copy-Item -Path $Src -Destination $Dst -Force
Write-Host "Synced testbench/$BoardId/TestConfig.h -> testbench/GenericTest/TestConfig.h"
Write-Host "Open testbench/GenericTest/GenericTest.ino, apply tft_setup.h, then upload."
