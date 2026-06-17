#!/usr/bin/env bash
# Deprecated — use scripts/sync-device.sh <id> miner
exec "$(dirname "$0")/sync-device.sh" "${1:?device id}" miner
