#!/usr/bin/env bash
# Deprecated — use scripts/sync-device.sh <id> test
exec "$(dirname "$0")/sync-device.sh" "${1:?device id}" test
