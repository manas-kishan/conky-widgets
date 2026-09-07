#!/usr/bin/env bash
# ==============================================================================
# Script: control.sh
# Description: Central control and customization manager for Conky widgets
# Usage: ./control.sh [command] [widget] [options]
# Shortcuts:
#   ./control.sh cal grid          (or: ./control.sh grid)
#   ./control.sh cal col           (or: ./control.sh col)
#   ./control.sh clo 12h-h         (or: ./control.sh 12h-h)
#   ./control.sh clo 12h-v         (or: ./control.sh 12h-v)
#   ./control.sh 12h-v grid        (multi-widget tweak)
#   ./control.sh st [clo|cal]      (start)
#   ./control.sh sp [clo|cal]      (stop)
#   ./control.sh rs [clo|cal]      (restart)
#   ./control.sh stat              (status)
#   ./control.sh ls                (list)
# ==============================================================================

set -euo pipefail

# Resolve script directory even if invoked via symlink
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$DIR/$SCRIPT_SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
WIDGETS_DIR="$REPO_ROOT/widgets"

usage() {
    echo "Usage: $(basename "$0") <command> [widget] [options]"
    echo ""
    echo "Commands & Shortcuts:"
    echo "  st,   start   [clo|cal]         Start widget (or all if omitted)"
    echo "  sp,   stop    [clo|cal]         Stop widget (or all if omitted)"
    echo "  rs,   restart [clo|cal]         Restart widget (or all if omitted)"
    echo "  twk,  tweak   [clo|cal] [mode]  Customize widget layout/format"
    echo "  stat, status                    Show running conky widgets"
    echo "  ls,   list                      List available widgets"
    echo ""
    echo "Widget Aliases:"
    echo "  clo, clock       -> Clock widget"
    echo "  cal, calendar    -> Calendar widget"
    echo ""
    echo "Clock Layouts (Shortcodes):"
    echo "  12h-h            -> 12-Hour Horizontal (Inline) [Default]"
    echo "  12h-v            -> 12-Hour Vertical   (Stacked)"
    echo "  24h-h            -> 24-Hour Horizontal (Inline)"
    echo "  24h-v            -> 24-Hour Vertical   (Stacked)"
    echo ""
    echo "Calendar Layouts (Shortcodes):"
    echo "  grid, row        -> 7 numbers per row left-to-right grid [Default]"
    echo "  col,  vertical   -> Vertical column (01..31)"
    echo ""
    echo "Multi-Widget Presets:"
    echo "  compact          -> 12h Horizontal Clock + 7-Day Grid Calendar [Default]"
    echo "  stacked          -> 12h Vertical Clock + Vertical Column Calendar"
    echo "  tech             -> 24h Horizontal Clock + 7-Day Grid Calendar"
    echo "  stacked-24h      -> 24h Vertical Clock + Vertical Column Calendar"
    echo ""
    echo "Quick Examples:"
    echo "  $(basename "$0") st                          # Start all widgets"
    echo "  $(basename "$0") cal grid                    # Calendar: 7-day row grid"
    echo "  $(basename "$0") cal col                     # Calendar: vertical column"
    echo "  $(basename "$0") clo 12h-h                   # Clock: 12h horizontal"
    echo "  $(basename "$0") clo 12h-v                   # Clock: 12h vertical"
    echo "  $(basename "$0") 12h-v grid                  # Tweak both widgets directly"
    echo "  $(basename "$0") preset stacked              # Apply dual-stacked preset"
    echo "  $(basename "$0") twk                         # Interactive tweak menu"
    echo "  $(basename "$0") sp                          # Stop all widgets"
    exit 1
}

# Normalize command names / aliases
resolve_action() {
    local act="${1:-}"
    case "$act" in
        twk|twk--|--twk|tweak|--tweak|-t|tw)
            echo "tweak"
            ;;
        st|start|--start|-s)
            echo "start"
            ;;
        sp|stop|--stop)
            echo "stop"
            ;;
        rs|restart|--restart|-r)
            echo "restart"
            ;;
        stat|status|--status)
            echo "status"
            ;;
        ls|list|--list|-l)
            echo "list"
            ;;
        preset|presets|--preset)
            echo "preset"
            ;;
        compact|tech|stacked|stacked-24h|all-vertical|grid-12h|grid-24h)
            echo "direct_preset"
            ;;
        clo|clock|clock-okami|cal|calendar|calendar-okami)
            echo "direct_widget"
            ;;
        12h-h|12h-v|24h-h|24h-v|12h-horizontal|12h-vertical|24h-horizontal|24h-vertical|horizontal)
            echo "direct_clock_mode"
            ;;
        grid|grid-7|col|column|row)
            echo "direct_cal_mode"
            ;;
        *)
            echo "$act"
            ;;
    esac
}

# Resolve widget alias to directory name
resolve_widget() {
    local name="${1:-}"
    case "$name" in
        clo|clock|clock-okami|c)
            echo "clock"
            ;;
        cal|calendar|calendar-okami)
            echo "calendar"
            ;;
        all|"")
            echo ""
            ;;
        *)
            echo "$name"
            ;;
    esac
}

# Resolve mode alias to canonical mode name for clock
resolve_clock_mode() {
    local mode="${1:-}"
    case "$mode" in
        1|12h-h|12h-horizontal|horizontal|inline|12h)
            echo "12h-horizontal"
            ;;
        2|12h-v|12h-vertical|vertical|stacked|stacked-12h)
            echo "12h-vertical"
            ;;
        3|24h-h|24h-horizontal|24h)
            echo "24h-horizontal"
            ;;
        4|24h-v|24h-vertical|stacked-24h)
            echo "24h-vertical"
            ;;
        *)
            echo "$mode"
            ;;
    esac
}

# Resolve mode alias to canonical mode name for calendar
resolve_calendar_mode() {
    local mode="${1:-}"
    case "$mode" in
        1|grid|row|g|h|horizontal|grid-7|7)
            echo "grid"
            ;;
        2|col|column|v|vertical|list)
            echo "vertical"
            ;;
        *)
            echo "$mode"
            ;;
    esac
}

list_widgets() {
    echo "Available widgets in $WIDGETS_DIR:"
    for dir in "$WIDGETS_DIR"/*/; do
        if [ -d "$dir" ]; then
            name="$(basename "$dir")"
            configs=$(find "$dir" -maxdepth 1 -name "*.conf" -printf "%f ")
            short=""
            [ "$name" = "clock" ] && short="[alias: clo]"
            [ "$name" = "calendar" ] && short="[alias: cal]"
            echo "  - $name $short (configs: ${configs:-none})"
        fi
    done
}

start_widget() {
    local target
    target="$(resolve_widget "$1")"
    local widget_dir="$WIDGETS_DIR/$target"

    if [ ! -d "$widget_dir" ]; then
        echo "[-] Error: Widget '$target' not found in $WIDGETS_DIR" >&2
        return 1
    fi

    # Verify Okami font is registered in fontconfig
    if ! fc-list : family 2>/dev/null | grep -qi "Okami"; then
        echo "[!] Notice: Okami font not detected in system font cache."
        echo "    Download link: https://www.fontshut.com/okami-font/"
    fi

    # Prepare calendar helper script in ~/.config/conky if needed
    if [ "$target" = "calendar" ] && [ -f "$widget_dir/okami-calendar.lua" ]; then
        mkdir -p "$HOME/.config/conky"
        ln -sf "$widget_dir/okami-calendar.lua" "$HOME/.config/conky/okami-calendar.lua"
    fi

    local conf
    conf=$(find "$widget_dir" -maxdepth 1 -name "*.conf" | head -n 1)
    if [ -z "$conf" ]; then
        echo "[-] No configuration file found in $widget_dir" >&2
        return 1
    fi

    # Stop any currently running instance of this widget
    stop_widget "$target" >/dev/null 2>&1 || true

    local mode="default"
    if [ "$target" = "clock" ]; then
        if [ -f "$HOME/.config/conky/clock.mode" ]; then
            mode="$(cat "$HOME/.config/conky/clock.mode")"
        elif [ -f "$HOME/.config/conky/clock-okami.mode" ]; then
            mode="$(cat "$HOME/.config/conky/clock-okami.mode")"
        fi
    elif [ "$target" = "calendar" ]; then
        if [ -f "$HOME/.config/conky/calendar.mode" ]; then
            mode="$(cat "$HOME/.config/conky/calendar.mode")"
        elif [ -f "$HOME/.config/conky/calendar-okami.mode" ]; then
            mode="$(cat "$HOME/.config/conky/calendar-okami.mode")"
        fi
    fi

    echo "==> Starting Conky with: $(basename "$conf") (Mode: $mode)..."
    setsid conky -c "$conf" </dev/null >/dev/null 2>&1 &

    sleep 0.5
    if pgrep -f "conky -c .*$(basename "$conf")" >/dev/null; then
        echo "[+] Okami $(tr '[:lower:]' '[:upper:]' <<< ${target:0:1})${target:1} Widget is running successfully!"
    else
        echo "[-] Failed to start Conky for $target. Running in foreground to check error:"
        conky -c "$conf" -i 1
        return 1
    fi
}

stop_widget() {
    local target
    target="$(resolve_widget "$1")"
    echo "==> Stopping Okami $target widget..."
    if pgrep -f "conky -c .*($target\.conf|$target-okami)" >/dev/null; then
        pkill -f "conky -c .*($target\.conf|$target-okami)"
        sleep 0.3
        echo "[+] $target widget stopped."
    else
        echo "[!] No running Okami $target instances detected."
    fi
}

status_widgets() {
    echo "=== Running Conky Processes ==="
    pgrep -a conky || echo "No Conky processes running."
}

tweak_clock() {
    local choice="${1:-}"
    local mode_file="$HOME/.config/conky/clock.mode"
    local mode_file_compat="$HOME/.config/conky/clock-okami.mode"
    local widget_dir="$WIDGETS_DIR/clock"
    mkdir -p "$HOME/.config/conky"

    if [ -z "$choice" ]; then
        local current="12h-h"
        if [ -f "$mode_file" ]; then
            current="$(cat "$mode_file")"
        elif [ -f "$mode_file_compat" ]; then
            current="$(cat "$mode_file_compat")"
        fi

        echo "=========================================="
        echo "       ⛩️ Okami Clock Tweak Tool"
        echo "=========================================="
        echo "Current mode: $current"
        echo ""
        echo "Select a clock layout & format:"
        echo "  1) 12h-h : 12-Hour Horizontal (Inline) [Default]"
        echo "  2) 12h-v : 12-Hour Vertical   (Stacked)"
        echo "  3) 24h-h : 24-Hour Horizontal (Inline)"
        echo "  4) 24h-v : 24-Hour Vertical   (Stacked)"
        echo "  q) Quit without changing"
        echo ""
        read -rp "Enter choice [1-4 / shortcode]: " choice
    fi

    local selected
    selected="$(resolve_clock_mode "$choice")"
    local desc=""

    case "$selected" in
        12h-horizontal)
            desc="12-Hour Horizontal [12h-h]"
            ;;
        12h-vertical)
            desc="12-Hour Vertical (Stacked) [12h-v]"
            ;;
        24h-horizontal)
            desc="24-Hour Horizontal [24h-h]"
            ;;
        24h-vertical)
            desc="24-Hour Vertical (Stacked) [24h-v]"
            ;;
        q|Q)
            echo "Cancelled."
            return 0
            ;;
        *)
            echo "[-] Error: Unknown mode '$choice'"
            echo "Valid modes: 12h-h, 12h-v, 24h-h, 24h-v (or 1, 2, 3, 4)"
            return 1
            ;;
    esac

    echo "$selected" > "$mode_file"
    echo "$selected" > "$mode_file_compat"
    echo "[+] Okami Clock layout set to: $desc"

    # Restart clock widget if currently running
    if pgrep -f "conky -c .*(clock\.conf|clock-okami)" >/dev/null; then
        echo "==> Applying changes to running widget..."
        start_widget "clock"
    fi
}

tweak_calendar() {
    local choice="${1:-}"
    local mode_file="$HOME/.config/conky/calendar.mode"
    local mode_file_compat="$HOME/.config/conky/calendar-okami.mode"
    local widget_dir="$WIDGETS_DIR/calendar"
    mkdir -p "$HOME/.config/conky"

    if [ -z "$choice" ]; then
        local current="grid"
        if [ -f "$mode_file" ]; then
            current="$(cat "$mode_file")"
        elif [ -f "$mode_file_compat" ]; then
            current="$(cat "$mode_file_compat")"
        fi

        echo "=========================================="
        echo "       ⛩️ Okami Calendar Tweak Tool"
        echo "=========================================="
        echo "Current mode: $current"
        echo ""
        echo "Select a calendar layout:"
        echo "  1) grid : 7 numbers per row left-to-right grid [Default]"
        echo "  2) col  : Vertical Column [01..31]"
        echo "  q) Quit without changing"
        echo ""
        read -rp "Enter choice [1-2 / grid / col]: " choice
    fi

    local selected
    selected="$(resolve_calendar_mode "$choice")"
    local desc=""

    case "$selected" in
        vertical)
            desc="Vertical Column (01..31) [col]"
            ;;
        grid)
            desc="7-Day Grid (Left-to-right) [grid]"
            ;;
        q|Q)
            echo "Cancelled."
            return 0
            ;;
        *)
            echo "[-] Error: Unknown calendar mode '$choice'"
            echo "Valid modes: col (vertical), grid (7 numbers per row)"
            return 1
            ;;
    esac

    echo "$selected" > "$mode_file"
    echo "$selected" > "$mode_file_compat"
    echo "[+] Okami Calendar layout set to: $desc"

    # Restart calendar widget if currently running
    if pgrep -f "conky -c .*(calendar\.conf|calendar-okami)" >/dev/null; then
        echo "==> Applying changes to running widget..."
        start_widget "calendar"
    fi
}

apply_preset() {
    local name="${1:-}"
    case "$name" in
        compact|grid-12h|default|"")
            echo "==> Applying 'compact' preset (12h Horizontal Clock + 7-Day Grid Calendar)..."
            tweak_clock "12h-h"
            tweak_calendar "grid"
            ;;
        stacked|all-vertical|vertical)
            echo "==> Applying 'stacked' preset (12h Vertical Clock + Vertical Column Calendar)..."
            tweak_clock "12h-v"
            tweak_calendar "col"
            ;;
        tech|grid-24h|24h-grid)
            echo "==> Applying 'tech' preset (24h Horizontal Clock + 7-Day Grid Calendar)..."
            tweak_clock "24h-h"
            tweak_calendar "grid"
            ;;
        stacked-24h|all-vertical-24h)
            echo "==> Applying 'stacked-24h' preset (24h Vertical Clock + Vertical Column Calendar)..."
            tweak_clock "24h-v"
            tweak_calendar "col"
            ;;
        *)
            echo "Available multi-widget presets:"
            echo "  compact     -> 12h-h (Clock) + grid (Calendar) [Default]"
            echo "  stacked     -> 12h-v (Clock) + col  (Calendar)"
            echo "  tech        -> 24h-h (Clock) + grid (Calendar)"
            echo "  stacked-24h -> 24h-v (Clock) + col  (Calendar)"
            echo ""
            echo "Usage: ./control.sh preset <name>"
            echo "   or: ./control.sh <clock-layout> <cal-layout>"
            ;;
    esac
}

tweak_widget() {
    # If no arguments at all, open interactive menu
    if [ $# -eq 0 ]; then
        echo "=========================================="
        echo "       ⛩️ Conky Widgets Tweak Menu"
        echo "=========================================="
        echo "Select a widget or preset to tweak:"
        echo "  1) clo     : Okami Clock (12h-h, 12h-v, 24h-h, 24h-v)"
        echo "  2) cal     : Okami Calendar (grid, col)"
        echo "  3) preset  : Choose a layout preset combo"
        echo "  q) Quit"
        echo ""
        read -rp "Enter choice [1-3]: " ans
        case "$ans" in
            1|clo|clock)
                tweak_clock
                ;;
            2|cal|calendar)
                tweak_calendar
                ;;
            3|preset|presets)
                echo ""
                echo "Select a preset combo:"
                echo "  1) compact     : 12h Horizontal Clock + 7-Day Grid Calendar [Default]"
                echo "  2) stacked     : 12h Vertical Clock   + Vertical Column Calendar"
                echo "  3) tech        : 24h Horizontal Clock + 7-Day Grid Calendar"
                echo "  4) stacked-24h : 24h Vertical Clock   + Vertical Column Calendar"
                echo ""
                read -rp "Enter preset [1-4]: " pans
                case "$pans" in
                    1) apply_preset "compact" ;;
                    2) apply_preset "stacked" ;;
                    3) apply_preset "tech" ;;
                    4) apply_preset "stacked-24h" ;;
                    *) echo "Cancelled." ;;
                esac
                ;;
            q|Q)
                echo "Cancelled."
                return 0
                ;;
            *)
                echo "Invalid selection."
                return 1
                ;;
        esac
        return 0
    fi

    # Support preset command: e.g. twk-- preset compact
    if [ "$1" = "preset" ] || [ "$1" = "presets" ]; then
        shift 1
        apply_preset "${1:-}"
        return 0
    fi

    # Loop through arguments to allow tweaking multiple items at a time
    while [ $# -gt 0 ]; do
        local token="$1"
        local target
        target="$(resolve_widget "$token")"

        case "$target" in
            clock)
                if [ $# -gt 1 ] && [[ "$2" != "cal" && "$2" != "calendar" && "$2" != "clo" && "$2" != "clock" ]]; then
                    tweak_clock "$2"
                    shift 2
                else
                    tweak_clock ""
                    shift 1
                fi
                ;;
            calendar)
                if [ $# -gt 1 ] && [[ "$2" != "clo" && "$2" != "clock" && "$2" != "cal" && "$2" != "calendar" ]]; then
                    tweak_calendar "$2"
                    shift 2
                else
                    tweak_calendar ""
                    shift 1
                fi
                ;;
            *)
                # Check if token is a direct clock layout or preset
                case "$token" in
                    compact|tech|stacked|stacked-24h)
                        apply_preset "$token"
                        shift 1
                        ;;
                    12h-h|12h-v|24h-h|24h-v|12h*|24h*|horizontal)
                        tweak_clock "$token"
                        shift 1
                        ;;
                    grid|grid-7|col|column|row)
                        tweak_calendar "$token"
                        shift 1
                        ;;
                    *)
                        echo "[-] Error: Unknown widget, preset, or layout '$token'"
                        echo "Available widgets: clo (clock), cal (calendar)"
                        echo "Clock layouts: 12h-h, 12h-v, 24h-h, 24h-v"
                        echo "Calendar layouts: grid (7-day row), col (vertical column)"
                        echo "Presets: compact, stacked, tech, stacked-24h"
                        return 1
                        ;;
                esac
                ;;
        esac
    done
}

RAW_ACTION="${1:-}"
ACTION="$(resolve_action "$RAW_ACTION")"
shift 1 2>/dev/null || true

case "$ACTION" in
    list)
        list_widgets
        ;;
    tweak)
        tweak_widget "$@"
        ;;
    preset)
        apply_preset "$@"
        ;;
    direct_preset)
        apply_preset "$RAW_ACTION" "$@"
        ;;
    direct_widget|direct_clock_mode|direct_cal_mode)
        tweak_widget "$RAW_ACTION" "$@"
        ;;
    status)
        status_widgets
        ;;
    start)
        TARGET="$(resolve_widget "${1:-}")"
        if [ -n "$TARGET" ]; then
            start_widget "$TARGET"
        else
            echo "Starting all widgets..."
            for w in clock calendar; do
                [ -d "$WIDGETS_DIR/$w" ] && start_widget "$w"
            done
        fi
        ;;
    stop)
        TARGET="$(resolve_widget "${1:-}")"
        if [ -n "$TARGET" ]; then
            stop_widget "$TARGET"
        else
            echo "Stopping all widgets managed by this repo..."
            for w in calendar clock; do
                [ -d "$WIDGETS_DIR/$w" ] && stop_widget "$w"
            done
        fi
        ;;
    restart)
        TARGET="$(resolve_widget "${1:-}")"
        if [ -n "$TARGET" ]; then
            stop_widget "$TARGET"
            sleep 0.5
            start_widget "$TARGET"
        else
            echo "Restarting all widgets..."
            for w in calendar clock; do
                [ -d "$WIDGETS_DIR/$w" ] && stop_widget "$w"
            done
            sleep 0.5
            for w in clock calendar; do
                [ -d "$WIDGETS_DIR/$w" ] && start_widget "$w"
            done
        fi
        ;;
    *)
        usage
        ;;
esac
