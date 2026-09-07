#!/usr/bin/env bash
# ==============================================================================
# Script: start.sh
# Description: Launch the Okami Time Widget
# Usage: ./start.sh [--stacked]
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Verify Okami font is registered in fontconfig
if ! fc-list : family | grep -qi "Okami"; then
    echo "[!] Okami font not detected in font cache. Installing now..."
    "$REPO_ROOT/scripts/install_fonts.sh"
fi

CONFIG_FILE="$SCRIPT_DIR/time-okami.conf"

# Prepare Lua script in ~/.config/conky
mkdir -p "$HOME/.config/conky"
ln -sf "$SCRIPT_DIR/okami-calendar.lua" "$HOME/.config/conky/okami-calendar.lua"
rm -f "$HOME/.config/conky/okami-rotate.lua" "$HOME/.config/conky/time-okami-assets"

if [[ "${1:-}" == "--stacked" || "${1:-}" == "-s" ]]; then
    CONFIG_FILE="$SCRIPT_DIR/time-okami-stacked.conf"
    echo "==> Using Stacked Layout"
else
    echo "==> Using Inline Minimalist Layout"
fi

# Stop any running time-okami instance first
"$SCRIPT_DIR/stop.sh" 2>/dev/null || true

echo "==> Starting Conky with: $(basename "$CONFIG_FILE")..."
setsid conky -c "$CONFIG_FILE" </dev/null >/dev/null 2>&1 &

sleep 0.5
if pgrep -f "conky -c $CONFIG_FILE" >/dev/null; then
    echo "[+] Okami Time Widget is running successfully!"
else
    echo "[-] Failed to start Conky. Running in foreground to check error:"
    conky -c "$CONFIG_FILE" -i 1
fi
