#!/usr/bin/env bash
# Show pending reminders on session start (no-op if there aren't any).
set -euo pipefail

STORE="$HOME/.local/state/journey/reminders.txt"
[[ -s $STORE ]] || exit 0

command -v journey-reminder >/dev/null || exit 0
journey-reminder show
