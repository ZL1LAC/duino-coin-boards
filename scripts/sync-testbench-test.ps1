# Deprecated — use scripts/sync-device.ps1 <id> test
param([Parameter(Mandatory=$true,Position=0)][string]$BoardId)
& (Join-Path $PSScriptRoot "sync-device.ps1") $BoardId test
