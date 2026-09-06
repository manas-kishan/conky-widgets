#!/usr/bin/env bash
# ==============================================================================
# Script: install_fonts.sh
# Description: Installs bundled fonts (e.g. Okami.otf) to user fonts directory
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
FONT_SRC_DIR="$REPO_ROOT/fonts"
USER_FONT_DIR="$HOME/.local/share/fonts"

echo "==> Setting up Conky Fonts..."

if [ ! -d "$FONT_SRC_DIR" ]; then
    echo "[-] Error: Font source directory not found at $FONT_SRC_DIR" >&2
    exit 1
fi

mkdir -p "$USER_FONT_DIR"

echo "==> Copying fonts to $USER_FONT_DIR..."
cp -u "$FONT_SRC_DIR"/*.otf "$FONT_SRC_DIR"/*.ttf "$USER_FONT_DIR"/ 2>/dev/null || true

echo "==> Refreshing FontConfig cache..."
fc-cache -f "$USER_FONT_DIR"

if fc-list : family | grep -qi "Okami"; then
    echo "[+] Okami font successfully installed and detected by fontconfig!"
else
    echo "[!] Warning: Font copied, but 'Okami' was not matched in fc-list."
fi

echo "==> Done!"
