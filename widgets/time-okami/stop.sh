#!/usr/bin/env bash
# ==============================================================================
# Script: stop.sh
# Description: Stop any running instance of the Okami Time Widget
# ==============================================================================

set -euo pipefail

echo "==> Stopping Okami Time Widget..."
pkill -f "conky -c .*/time-okami" 2>/dev/null && echo "[+] Widget stopped." || echo "[!] No running instance of Okami Time Widget found."
