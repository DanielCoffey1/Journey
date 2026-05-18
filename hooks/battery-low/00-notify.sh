#!/usr/bin/env bash
# Critical notification when battery is low. Triggered by journey-battery-watch.
set -euo pipefail
command -v notify-send >/dev/null || exit 0

status="$(journey-battery-status 2>/dev/null || echo 'Battery low')"
notify-send -u critical -t 0 " Battery low" "$status"
