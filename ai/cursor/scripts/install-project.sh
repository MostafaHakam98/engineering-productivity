#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/project-template/.cursor"
TARGET_DIR="$PWD/.cursor"

if [ -d "$TARGET_DIR" ]; then
  echo "Project .cursor directory already exists: $TARGET_DIR"
  echo "Refusing to overwrite. Manually merge or delete it first."
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Installing project Cursor template..."
rsync -av --exclude='.gitkeep' "$SOURCE_DIR/" "$TARGET_DIR/"

echo "Installed project Cursor template to: $TARGET_DIR"
echo "Next: fill in project-specific content in .cursor/rules/repo.mdc, repo-map.mdc, entrypoints.mdc, dependency-map.mdc, and ownership-map.mdc"
