# Sync a device profile into the active Arduino sketches.
# Usage:
#   .\scripts\sync-device.ps1 <device-id> test          # TestConfig.h -> testbench/GenericTest/
#   .\scripts\sync-device.ps1 <device-id> miner         # Settings.h -> ESP_Code/
#   .\scripts\sync-device.ps1 <device-id> miner-portal  # Settings.h + CAPTIVE_PORTAL
#   .\scripts\sync-device.ps1 <device-id> all           # both (default)

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$DeviceId,

    [Parameter(Position = 1)]
    [ValidateSet("test", "miner", "miner-portal", "all")]
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

function Enable-CaptivePortal {
    param([string]$Path)
    $text = Get-Content -Path $Path -Raw -Encoding UTF8
    if ($text -match '(?m)^#define CAPTIVE_PORTAL\s*$') { return }
    $text = $text -replace '(?m)^//\s*#define CAPTIVE_PORTAL\s*$', '#define CAPTIVE_PORTAL'
    if ($text -notmatch '(?m)^#define CAPTIVE_PORTAL\s*$') {
        $insert = "`n// WiFiManager captive portal - AP Duino-Coin on first boot`n#define CAPTIVE_PORTAL`n"
        if ($text -match '(?m)^extern const char PASSWORD\[\].*?\r?\n') {
            $text = [regex]::Replace($text, '(?m)^(extern const char PASSWORD\[\][^\r\n]*\r?\n)', "`$1$insert", 1)
        } else {
            $text = $insert + $text
        }
    }
    Set-Content -Path $Path -Value $text -Encoding UTF8 -NoNewline
}

if ($Profile -eq "test" -or $Profile -eq "all") {
    $src = Sync-FromExample "TestConfig.h"
    if (-not $src) {
        Write-Error "No TestConfig.h or TestConfig.h.example for $DeviceId"
        exit 1
    }
    $dst = Join-Path $Root "testbench\GenericTest\TestConfig.h"
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "Synced devices/$DeviceId/TestConfig.h -> testbench/GenericTest/TestConfig.h"
}

if ($Profile -eq "miner" -or $Profile -eq "miner-portal" -or $Profile -eq "all") {
    $src = Sync-FromExample "Settings.h"
    if (-not $src) {
        Write-Error "No Settings.h or Settings.h.example for $DeviceId"
        exit 1
    }
    $dst = Join-Path $Root "ESP_Code\Settings.h"
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "Synced devices/$DeviceId/Settings.h -> ESP_Code/Settings.h"
}

if ($Profile -eq "miner-portal") {
    Enable-CaptivePortal (Join-Path $Root "ESP_Code\Settings.h")
    Write-Host "Enabled CAPTIVE_PORTAL in ESP_Code/Settings.h (no WiFi/credentials required at compile time)"
}

switch ($Profile) {
    "test"         { Write-Host "Open testbench/GenericTest/GenericTest.ino (run setup-tft-espi.ps1 first for TFT boards)." }
    "miner"        { Write-Host "Open ESP_Code/ESP_Code.ino (run setup-tft-espi.ps1 first for TFT boards)." }
    "miner-portal" { Write-Host "Open ESP_Code/ESP_Code.ino - first boot uses Duino-Coin WiFi AP." }
    default        { Write-Host "Profiles synced. Generic test: testbench/GenericTest/GenericTest.ino | Miner: ESP_Code/ESP_Code.ino" }
}
