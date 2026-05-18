#!/usr/bin/env bash
# When the system font changes, restart the launcher so its GTK style picks it up.
set -euo pipefail
command -v journey-restart-companion >/dev/null || exit 0
journey-restart-companion >/dev/null 2>&1 || true
