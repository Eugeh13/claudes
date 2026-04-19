#!/usr/bin/env bash
# Install claudes to ~/.local/bin (creates it if needed) and adds it to PATH if missing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/bin/claudes"
DEST_DIR="${CLAUDES_INSTALL_DIR:-$HOME/.local/bin}"
DEST="$DEST_DIR/claudes"

[[ -f "$SRC" ]] || { echo "error: $SRC not found"; exit 1; }

mkdir -p "$DEST_DIR"
install -m 0755 "$SRC" "$DEST"

echo "installed → $DEST"

# Hint about PATH
case ":$PATH:" in
  *":$DEST_DIR:"*) echo "PATH already includes $DEST_DIR" ;;
  *)
    echo ""
    echo "add this to your shell profile (~/.zshrc or ~/.bashrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

echo ""
echo "next: run 'claudes doctor' to verify dependencies."
