# Copy board tft_setup.h -> Arduino TFT_eSPI User_Setup.h
# Usage: .\scripts\setup-tft-espi.ps1 lilygo-t-deck
#        .\scripts\setup-tft-espi.ps1 lilygo-t-deck "D:\Arduino\libraries\TFT_eSPI"

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$BoardId,

    [Parameter(Position = 1)]
    [string]$TftEspiDir
)

$Root = Split-Path -Parent $PSScriptRoot
$RegistryPath = Join-Path $Root "boards\registry.json"

if (-not (Test-Path $RegistryPath)) {
    Write-Error "Missing registry: $RegistryPath"
    exit 1
}

$registry = Get-Content -Raw -Path $RegistryPath | ConvertFrom-Json
$board = $registry.boards | Where-Object { $_.id -eq $BoardId } | Select-Object -First 1

if (-not $board) {
    Write-Error "Unknown board id: $BoardId (not in boards/registry.json)"
    exit 1
}

$srcRel = $board.firmware.tft_setup
if (-not $srcRel) {
    Write-Error "No tft_setup path in registry for $BoardId"
    exit 1
}

$Src = Join-Path $Root ($srcRel -replace '/', '\')
if (-not (Test-Path $Src)) {
    Write-Error "TFT setup file missing: $Src"
    exit 1
}

if (-not $TftEspiDir) {
    if ($env:ARDUINO_LIBRARIES) {
        $TftEspiDir = Join-Path $env:ARDUINO_LIBRARIES "TFT_eSPI"
    } else {
        $TftEspiDir = Join-Path $env:USERPROFILE "Documents\Arduino\libraries\TFT_eSPI"
    }
}

if (-not (Test-Path $TftEspiDir)) {
    Write-Error "TFT_eSPI not found at: $TftEspiDir`nInstall Bodmer TFT_eSPI in Arduino Library Manager, or pass the library path as arg 2."
    exit 1
}

$setupContent = Get-Content -Raw -Path $Src
if ($setupContent -notmatch 'USER_SETUP_LOADED') {
    $setupContent = $setupContent.TrimEnd() + @"

#ifndef USER_SETUP_LOADED
#define USER_SETUP_LOADED
#endif
"@
}

$UserSetupsDir = Join-Path $TftEspiDir "User_Setups"
$Dst = Join-Path $TftEspiDir "User_Setup.h"
$Basename = Split-Path -Leaf $Src
$DstNamed = Join-Path $UserSetupsDir $Basename
$SelectPath = Join-Path $TftEspiDir "User_Setup_Select.h"
$SketchSetupGeneric = Join-Path $Root "testbench\GenericTest\tft_setup.h"
$SketchSetupMiner = Join-Path $Root "ESP_Code\tft_setup.h"

New-Item -ItemType Directory -Force -Path $UserSetupsDir | Out-Null
Set-Content -Path $Dst -Value $setupContent -NoNewline
Set-Content -Path $DstNamed -Value $setupContent -NoNewline
Set-Content -Path $SketchSetupGeneric -Value $setupContent -NoNewline
Set-Content -Path $SketchSetupMiner -Value $setupContent -NoNewline

if (Test-Path $SelectPath) {
    $commentInclude = '//#include'
    $patched = foreach ($line in (Get-Content $SelectPath)) {
        if ($line -match '^\s*#include\s+<User_Setups/') {
            if ($line -match '^\s*//') { $line } else { $line -replace '^(\s*)#include', "`${1}$commentInclude" }
        } elseif ($line -match '#include\s+<User_Setup\.h>') {
            '#include <User_Setup.h>  (duino-coin-boards active board)'
        } else {
            $line
        }
    }
    Set-Content -Path $SelectPath -Value $patched
    Write-Host "Patched User_Setup_Select.h -> #include User_Setup.h only"
} else {
    Write-Warning "User_Setup_Select.h not found - sketch tft_setup.h still applied"
}

if ($board.firmware.esp32c3_spi_patch) {
    $C3Header = Join-Path $TftEspiDir "Processors\TFT_eSPI_ESP32_C3.h"
    $PatchMarker = "duino-coin-boards: ESP32-C3 SPI fix"
    if ((Test-Path $C3Header) -and -not (Select-String -Path $C3Header -Pattern $PatchMarker -Quiet)) {
        Add-Content -Path $C3Header -Value @"

// $PatchMarker (Arduino ESP32 core 3.x)
#if CONFIG_IDF_TARGET_ESP32C3
  #ifdef REG_SPI_BASE
    #undef REG_SPI_BASE
  #endif
  #define REG_SPI_BASE(i) DR_REG_SPI2_BASE
#endif
"@
        Write-Host "Applied ESP32-C3 SPI patch -> $C3Header"
    }
}

Write-Host "TFT_eSPI configured for $BoardId"
Write-Host "  User_Setup.h:     $Dst"
Write-Host "  GenericTest copy: $SketchSetupGeneric"
Write-Host "  ESP_Code copy:    $SketchSetupMiner"
Write-Host ""
Write-Host "Rebuild GenericTest.ino in Arduino IDE (Verify/Compile then Upload)."
