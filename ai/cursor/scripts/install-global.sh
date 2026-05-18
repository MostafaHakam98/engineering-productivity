#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/global/rules"
TARGET_DIR="$HOME/.cursor/rules"

mkdir -p "$TARGET_DIR"

echo "Installing global Cursor rules..."
rsync -av --exclude='.gitkeep' "$SOURCE_DIR/" "$TARGET_DIR/"

echo "Installed global Cursor rules to: $TARGET_DIR"
