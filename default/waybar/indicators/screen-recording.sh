#!/usr/bin/env bash
# Waybar indicator: lit while a screen recording is running.
set -euo pipefail
pid_file="$HOME/.local/state/journey/screenrecord.pid"
if [[ -f $pid_file ]] && kill -0 "$(<"$pid_file")" 2>/dev/null; then
    printf '{"text":"󰑊","tooltip":"Recording — click to stop","class":"active"}\n'
else
    printf '{"text":"","class":""}\n'
fi
