#!/usr/bin/env bash
# ==============================================================================
# Script: conky-control.sh
# Description: Multi-widget manager for Conky widgets
# Usage: ./conky-control.sh [start|stop|restart|status|list] [widget_name]
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
WIDGETS_DIR="$REPO_ROOT/widgets"

usage() {
    echo "Usage: $(basename "$0") <command> [widget_name]"
    echo ""
    echo "Commands:"
    echo "  start [widget]    Start specified widget (or all widgets if omitted)"
    echo "  stop [widget]     Stop specified widget (or all widgets if omitted)"
    echo "  restart [widget]  Restart specified widget (or all widgets if omitted)"
    echo "  status            Show status of running conky widgets"
    echo "  list              List all available widgets in repository"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") start time-okami"
    echo "  $(basename "$0") restart time-okami"
    echo "  $(basename "$0") stop"
    exit 1
}

list_widgets() {
    echo "Available widgets in $WIDGETS_DIR:"
    for dir in "$WIDGETS_DIR"/*/; do
        if [ -d "$dir" ]; then
            name="$(basename "$dir")"
            configs=$(find "$dir" -maxdepth 1 -name "*.conf" -printf "%f ")
            echo "  - $name (configs: ${configs:-none})"
        fi
    done
}

start_widget() {
    local target="$1"
    local widget_dir="$WIDGETS_DIR/$target"

    if [ ! -d "$widget_dir" ]; then
        echo "[-] Error: Widget '$target' not found in $WIDGETS_DIR" >&2
        return 1
    fi

    # Check for start.sh script first
    if [ -x "$widget_dir/start.sh" ]; then
        echo "[+] Launching $target via start.sh..."
        "$widget_dir/start.sh"
        return 0
    fi

    # Fallback: look for .conf files
    local conf
    conf=$(find "$widget_dir" -maxdepth 1 -name "*.conf" | head -n 1)
    if [ -n "$conf" ]; then
        echo "[+] Launching $target with config $(basename "$conf")..."
        nohup conky -c "$conf" >/dev/null 2>&1 &
        echo "[+] $target started (PID: $!)."
    else
        echo "[-] No configuration file found in $widget_dir" >&2
        return 1
    fi
}

stop_widget() {
    local target="$1"
    local widget_dir="$WIDGETS_DIR/$target"

    if [ -x "$widget_dir/stop.sh" ]; then
        echo "[+] Stopping $target via stop.sh..."
        "$widget_dir/stop.sh"
        return 0
    fi

    echo "[+] Terminating conky instances matching $target..."
    pkill -f "conky.*$target" 2>/dev/null || echo "[!] No running process found for $target"
}

status_widgets() {
    echo "=== Running Conky Processes ==="
    pgrep -a conky || echo "No Conky processes running."
}

ACTION="${1:-}"
TARGET="${2:-}"

case "$ACTION" in
    list)
        list_widgets
        ;;
    status)
        status_widgets
        ;;
    start)
        if [ -n "$TARGET" ]; then
            start_widget "$TARGET"
        else
            echo "Starting all widgets..."
            for dir in "$WIDGETS_DIR"/*/; do
                [ -d "$dir" ] && start_widget "$(basename "$dir")"
            done
        fi
        ;;
    stop)
        if [ -n "$TARGET" ]; then
            stop_widget "$TARGET"
        else
            echo "Stopping all widgets managed by this repo..."
            for dir in "$WIDGETS_DIR"/*/; do
                [ -d "$dir" ] && stop_widget "$(basename "$dir")"
            done
        fi
        ;;
    restart)
        if [ -n "$TARGET" ]; then
            stop_widget "$TARGET"
            sleep 0.5
            start_widget "$TARGET"
        else
            echo "Restarting all widgets..."
            for dir in "$WIDGETS_DIR"/*/; do
                [ -d "$dir" ] && stop_widget "$(basename "$dir")"
            done
            sleep 0.5
            for dir in "$WIDGETS_DIR"/*/; do
                [ -d "$dir" ] && start_widget "$(basename "$dir")"
            done
        fi
        ;;
    *)
        usage
        ;;
esac
