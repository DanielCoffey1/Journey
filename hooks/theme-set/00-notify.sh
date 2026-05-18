#!/usr/bin/env bash
# Confirm the new theme via a brief notification.
set -euo pipefail
command -v notify-send >/dev/null || exit 0

name="$(cat "$HOME/.config/journey/current/theme.name" 2>/dev/null || echo "(unknown)")"
notify-send -u low -t 2000 " Theme" "Now: $name"
