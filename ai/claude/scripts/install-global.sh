#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/global"
TARGET_DIR="$HOME/.claude"

mkdir -p "$TARGET_DIR"

echo "Installing global Claude config..."
rsync -av --exclude='.gitkeep' "$SOURCE_DIR/" "$TARGET_DIR/"

echo "Installed global Claude config to: $TARGET_DIR"
