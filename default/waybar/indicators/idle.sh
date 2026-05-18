#!/usr/bin/env bash
# Waybar indicator: shows "active" when idle inhibition is on (hypridle off).
set -euo pipefail
if [[ -e "$HOME/.local/state/journey/toggles/idle-off" ]]; then
    # idle inhibited (won't lock / suspend on idle)
    printf '{"text":"󰈉","tooltip":"Idle inhibited","class":"active"}\n'
else
    printf '{"text":"","class":""}\n'
fi
