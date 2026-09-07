#!/usr/bin/env bash
# ==============================================================================
# Script: install.sh
# Description: One-click installer for Conky Okami Widgets
# Usage: ./install.sh
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
FONT_SRC_DIR="$REPO_ROOT/fonts"
USER_FONT_DIR="$HOME/.local/share/fonts"
CONKY_CONFIG_DIR="$HOME/.config/conky"

echo "========================================================"
echo "           ⛩️ Conky Okami Widgets Installer"
echo "========================================================"
echo ""

# 1. Check for Conky & FontConfig dependencies
echo "[1/5] Checking system dependencies..."
MISSING_DEPS=()
command -v conky >/dev/null 2>&1 || MISSING_DEPS+=("conky")
command -v fc-cache >/dev/null 2>&1 || MISSING_DEPS+=("fontconfig")

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "[-] Warning: Missing required package(s): ${MISSING_DEPS[*]}"
    echo "    Please install them using your package manager:"
    if command -v apt >/dev/null 2>&1; then
        echo "    sudo apt install conky-all fontconfig"
    elif command -v pacman >/dev/null 2>&1; then
        echo "    sudo pacman -S conky fontconfig"
    elif command -v dnf >/dev/null 2>&1; then
        echo "    sudo dnf install conky fontconfig"
    fi
    echo ""
    read -rp "Continue installation anyway? [y/N]: " proceed
    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        echo "Installation aborted."
        exit 1
    fi
else
    echo "[+] All system dependencies (conky, fontconfig) found!"
fi

# 2. Install bundled Okami fonts
echo "[2/5] Installing bundled Okami fonts..."
if [ -d "$FONT_SRC_DIR" ]; then
    mkdir -p "$USER_FONT_DIR"
    cp -u "$FONT_SRC_DIR"/*.otf "$FONT_SRC_DIR"/*.ttf "$USER_FONT_DIR"/ 2>/dev/null || true
    fc-cache -f "$USER_FONT_DIR" >/dev/null 2>&1 || true

    if fc-list : family | grep -qi "Okami"; then
        echo "[+] Okami font successfully registered in font cache!"
    else
        echo "[!] Font copied to $USER_FONT_DIR. FontConfig cache refreshed."
    fi
else
    echo "[!] Warning: Font source directory not found at $FONT_SRC_DIR"
fi

# 3. Setup permissions on all scripts
echo "[3/5] Setting executable permissions..."
chmod +x "$REPO_ROOT/control.sh" "$REPO_ROOT/install.sh"
chmod +x "$REPO_ROOT/widgets/"*/*.sh 2>/dev/null || true
echo "[+] Script permissions set."

# 4. Initialize Conky user configuration
echo "[4/5] Initializing user configuration in ~/.config/conky/..."
mkdir -p "$CONKY_CONFIG_DIR"

# Link calendar helper script
if [ -f "$REPO_ROOT/widgets/calendar/okami-calendar.lua" ]; then
    ln -sf "$REPO_ROOT/widgets/calendar/okami-calendar.lua" "$CONKY_CONFIG_DIR/okami-calendar.lua"
fi

# Set default clock mode if not already present
if [ ! -f "$CONKY_CONFIG_DIR/clock.mode" ] && [ ! -f "$CONKY_CONFIG_DIR/clock-okami.mode" ]; then
    echo "12h-horizontal" > "$CONKY_CONFIG_DIR/clock.mode"
    echo "12h-horizontal" > "$CONKY_CONFIG_DIR/clock-okami.mode"
    echo "[+] Initialized default clock mode: 12h-horizontal"
fi

# Set default calendar mode if not already present
if [ ! -f "$CONKY_CONFIG_DIR/calendar.mode" ]; then
    echo "grid" > "$CONKY_CONFIG_DIR/calendar.mode"
    echo "[+] Initialized default calendar mode: grid"
fi

# 5. Launch widgets
echo "[5/5] Launching widgets..."
"$REPO_ROOT/control.sh" st

echo ""
echo "========================================================"
echo "      🎉 Installation & Setup Complete! 🎉"
echo "========================================================"
echo ""
echo "Widgets are now running on your desktop."
echo ""
echo "You can customize and tweak widgets anytime using control.sh:"
echo "  ./control.sh clo 12h-h         # Clock: 12-Hour Horizontal (Default)"
echo "  ./control.sh clo 12h-v         # Clock: 12-Hour Vertical (Stacked)"
echo "  ./control.sh clo 24h-h         # Clock: 24-Hour Horizontal (Inline)"
echo "  ./control.sh clo 24h-v         # Clock: 24-Hour Vertical (Stacked)"
echo "  ./control.sh cal grid          # Calendar: 7-Day Row Grid (Default)"
echo "  ./control.sh cal col           # Calendar: Vertical Column (01..31)"
echo "  ./control.sh 12h-v grid        # Tweak both widgets directly"
echo "  ./control.sh twk               # Interactive Tweak Menu"
echo ""
echo "Other commands:"
echo "  ./control.sh stat              # Check running status"
echo "  ./control.sh sp                # Stop all widgets"
echo "  ./control.sh st                # Start all widgets"
echo "  ./control.sh ls                # List widgets"
echo ""
