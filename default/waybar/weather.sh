#!/usr/bin/env bash
# Waybar custom/weather module — wttr.in summary as JSON.
# Output is the JSON `text`/`tooltip`/`class` schema waybar expects.
set -euo pipefail

emit() {
    # $1 = text, $2 = tooltip, $3 = class
    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
        "${1//\"/\\\"}" "${2//\"/\\\"}" "${3:-}"
}

if ! command -v curl >/dev/null; then
    emit "" "weather: curl missing" "unavailable"; exit 0
fi

loc="${WEATHER_LOCATION:-}"
url="https://wttr.in/${loc}?format=%C+%t+%w&u"

out="$(curl -fsSL --max-time 4 "$url" 2>/dev/null || true)"
if [[ -z $out ]] || [[ $out == *"Unknown location"* ]] || [[ $out == *"<html>"* ]]; then
    emit "" "weather: unavailable" "unavailable"; exit 0
fi

emit "$out" "$out" ""
