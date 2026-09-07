#!/usr/bin/env bash
# ==============================================================================
# Script: stop.sh
# Description: Stop any running calendar-okami Conky instances
# ==============================================================================

set -euo pipefail

echo "==> Stopping Okami Calendar Widget..."
if pgrep -f "conky -c .*(calendar\.conf|calendar-okami)" >/dev/null; then
    pkill -f "conky -c .*(calendar\.conf|calendar-okami)"
    sleep 0.3
    echo "[+] Calendar widget stopped."
else
    echo "[!] No running Okami Calendar instances detected."
fi
