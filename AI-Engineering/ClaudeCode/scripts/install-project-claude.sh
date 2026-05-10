#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/project-template"
TARGET_DIR="$PWD/.claude"

if [ -d "$TARGET_DIR" ]; then
  echo "Project .claude directory already exists: $TARGET_DIR"
  echo "Refusing to overwrite. Use sync-project-claude.sh instead."
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Installing project Claude template..."
rsync -av --exclude='.gitkeep' "$SOURCE_DIR/" "$TARGET_DIR/"

echo "Installed project Claude template to: $TARGET_DIR"
echo "Next: edit project-specific files under .claude/maps and .claude/rules."
