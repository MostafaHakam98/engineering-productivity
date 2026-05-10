#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/project-template"
TARGET_DIR="$PWD/.claude"

mkdir -p "$TARGET_DIR"

echo "Syncing non-project-specific Claude template files..."
rsync -av \
  --ignore-existing \
  --exclude='rules/repo.md' \
  --exclude='rules/build.md' \
  --exclude='maps/repo-map.md' \
  --exclude='maps/dependency-map.md' \
  --exclude='maps/entrypoints.md' \
  --exclude='maps/ownership-map.md' \
  "$SOURCE_DIR/" "$TARGET_DIR/"

echo "Sync complete."
echo "Project-specific files were not overwritten."
