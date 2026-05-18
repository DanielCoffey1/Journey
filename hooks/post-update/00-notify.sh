#!/usr/bin/env bash
# Notification confirming Journey + system upgrades finished.
set -euo pipefail
command -v notify-send >/dev/null || exit 0

version="$(cat "$HOME/.local/share/journey/version" 2>/dev/null || echo "")"
notify-send -u low " Journey updated" "${version:+v${version} — }Reboot if the kernel or hyprland was upgraded."
