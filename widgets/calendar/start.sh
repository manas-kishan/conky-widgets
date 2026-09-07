#!/usr/bin/env bash
# ==============================================================================
# Script: start.sh
# Description: Launch the Okami Calendar Widget
# Usage: ./start.sh [--tweak | vertical | grid]
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Verify Okami font is registered in fontconfig
if ! fc-list : family | grep -qi "Okami"; then
    echo "[!] Notice: Okami font not detected in system font cache."
    echo "    Download link: https://www.fontshut.com/okami-font/"
fi

ARG="${1:-}"

# Check for tweak flag
if [[ "$ARG" == "--tweak" || "$ARG" == "-t" || "$ARG" == "twk" || "$ARG" == "twk--" ]]; then
    exec "$REPO_ROOT/control.sh" twk cal
fi

# If a specific mode argument was passed, save it directly to user config
mkdir -p "$HOME/.config/conky"
if [[ -n "$ARG" ]]; then
    case "$ARG" in
        grid|--grid|g|horizontal|h|row|grid-7)
            echo "grid" > "$HOME/.config/conky/calendar.mode"
            ;;
        vertical|--vertical|v|col|column|list)
            echo "vertical" > "$HOME/.config/conky/calendar.mode"
            ;;
    esac
fi

CONFIG_FILE="$SCRIPT_DIR/calendar.conf"

# Prepare Lua script in ~/.config/conky
mkdir -p "$HOME/.config/conky"
ln -sf "$SCRIPT_DIR/okami-calendar.lua" "$HOME/.config/conky/okami-calendar.lua"

# Stop any running calendar instance first
"$SCRIPT_DIR/stop.sh" 2>/dev/null || true

MODE="grid"
if [ -f "$HOME/.config/conky/calendar.mode" ]; then
    MODE="$(cat "$HOME/.config/conky/calendar.mode")"
fi

echo "==> Starting Conky with: calendar.conf (Mode: $MODE)..."
setsid conky -c "$CONFIG_FILE" </dev/null >/dev/null 2>&1 &

sleep 0.5
if pgrep -f "conky -c .*$(basename "$CONFIG_FILE")" >/dev/null; then
    echo "[+] Okami Calendar Widget is running successfully!"
else
    echo "[-] Failed to start Conky. Running in foreground to check error:"
    conky -c "$CONFIG_FILE" -i 1
fi
