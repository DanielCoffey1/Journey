#!/usr/bin/env bash
# Waybar indicator: lit when Mako is in do-not-disturb mode.
set -euo pipefail
if command -v makoctl >/dev/null && makoctl mode 2>/dev/null | grep -qx "do-not-disturb"; then
    printf '{"text":"󰂛","tooltip":"Do not disturb","class":"active"}\n'
else
    printf '{"text":"","class":""}\n'
fi
