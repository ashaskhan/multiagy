#!/bin/bash
set -euo pipefail

REPO="${MULTIAGY_REPO:-ashaskhan/multiagy}"
BRANCH="${MULTIAGY_BRANCH:-main}"
RAW="https://raw.githubusercontent.com/$REPO/$BRANCH"
INSTALL_DIR="/usr/local/bin"

# ── helpers ──────────────────────────────────────────────────────────────────
print_step () { echo "  → $1"; }
abort ()       { echo "Error: $1" >&2; exit 1; }

# ── platform ─────────────────────────────────────────────────────────────────
case "$(uname -s)" in
  Darwin)
    PLATFORM="darwin"
    ;;
  Linux)
    PLATFORM="linux"
    ;;
  *)
    abort "Unsupported platform. Multiagy currently supports Linux and macOS."
    ;;
esac

# ── preflight ────────────────────────────────────────────────────────────────
command -v curl &>/dev/null || abort "curl is required but not found"

# fall back to ~/.local/bin if /usr/local/bin isn't writable without sudo
if [ ! -w "$INSTALL_DIR" ]; then
  INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"
  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Warning: $INSTALL_DIR is not in your PATH."
    echo "  Add this to your shell profile (~/.zshrc or ~/.bashrc):"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
  fi
fi

echo "Installing Multiagy to $INSTALL_DIR ..."

# ── download multiagy script ─────────────────────────────────────────────────
print_step "Downloading multiagy..."
curl -fsSL "$RAW/multiagy" -o "$INSTALL_DIR/multiagy"
chmod +x "$INSTALL_DIR/multiagy"

# ── download macOS icon if on macOS ──────────────────────────────────────────
if [ "$PLATFORM" = "darwin" ]; then
  print_step "Downloading icon..."
  curl -fsSL "$RAW/icon.icns" -o "$INSTALL_DIR/icon.icns" 2>/dev/null || true
fi

echo ""
echo "✓ Multiagy installed successfully!"
echo ""
echo "Usage:"
echo "  multiagy help"
echo "  multiagy new <profile-name> --auth-only"
echo "  multiagy <profile-name>"
echo ""

# Run doctor diagnosis
"$INSTALL_DIR/multiagy" doctor || true
