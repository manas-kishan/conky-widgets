#!/usr/bin/env bash
# ==============================================================================
# Script: start.sh
# Description: Launch the Okami Clock Widget
# Usage: ./start.sh [--tweak | 12h-horizontal | 12h-vertical | 24h-horizontal | 24h-vertical]
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
    exec "$REPO_ROOT/control.sh" twk clo
fi

# If a specific mode argument was passed, save it directly to user config
mkdir -p "$HOME/.config/conky"
if [[ -n "$ARG" ]]; then
    case "$ARG" in
        --12h-h|--12h-horizontal|12h-h|12h-horizontal|horizontal)
            echo "12h-horizontal" > "$HOME/.config/conky/clock.mode"
            echo "12h-horizontal" > "$HOME/.config/conky/clock-okami.mode"
            ;;
        --12h-v|--12h-vertical|12h-v|12h-vertical|vertical|--stacked)
            echo "12h-vertical" > "$HOME/.config/conky/clock.mode"
            echo "12h-vertical" > "$HOME/.config/conky/clock-okami.mode"
            ;;
        --24h-h|--24h-horizontal|24h-h|24h-horizontal|--24h)
            echo "24h-horizontal" > "$HOME/.config/conky/clock.mode"
            echo "24h-horizontal" > "$HOME/.config/conky/clock-okami.mode"
            ;;
        --24h-v|--24h-vertical|24h-v|24h-vertical)
            echo "24h-vertical" > "$HOME/.config/conky/clock.mode"
            echo "24h-vertical" > "$HOME/.config/conky/clock-okami.mode"
            ;;
    esac
fi

CONFIG_FILE="$SCRIPT_DIR/clock.conf"

# Stop any running clock instance first
"$SCRIPT_DIR/stop.sh" 2>/dev/null || true

MODE="12h-horizontal"
if [ -f "$HOME/.config/conky/clock.mode" ]; then
    MODE="$(cat "$HOME/.config/conky/clock.mode")"
elif [ -f "$HOME/.config/conky/clock-okami.mode" ]; then
    MODE="$(cat "$HOME/.config/conky/clock-okami.mode")"
fi

echo "==> Starting Conky with: clock.conf (Mode: $MODE)..."
setsid conky -c "$CONFIG_FILE" </dev/null >/dev/null 2>&1 &

sleep 0.5
if pgrep -f "conky -c .*$(basename "$CONFIG_FILE")" >/dev/null; then
    echo "[+] Okami Clock Widget is running successfully!"
else
    echo "[-] Failed to start Conky. Running in foreground to check error:"
    conky -c "$CONFIG_FILE" -i 1
fi
