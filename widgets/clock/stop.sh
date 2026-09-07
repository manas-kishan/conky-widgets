#!/usr/bin/env bash
# ==============================================================================
# Script: stop.sh
# Description: Stop any running clock-okami Conky instances
# ==============================================================================

set -euo pipefail

echo "==> Stopping Okami Clock Widget..."
if pgrep -f "conky -c .*(clock\.conf|clock-okami)" >/dev/null; then
    pkill -f "conky -c .*(clock\.conf|clock-okami)"
    sleep 0.3
    echo "[+] Clock widget stopped."
else
    echo "[!] No running Okami Clock instances detected."
fi
