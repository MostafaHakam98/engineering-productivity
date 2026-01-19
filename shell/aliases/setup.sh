#!/bin/bash
# Setup script to copy aliases to ~/.bashrc.d/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.bashrc.d"

echo "Setting up bash aliases..."
echo "Source: $SCRIPT_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Build list of current source files (excluding setup.sh)
CURRENT_FILES=()
for file in "$SCRIPT_DIR"/*.sh; do
  if [[ "$(basename "$file")" != "setup.sh" ]]; then
    CURRENT_FILES+=("$(basename "$file")")
  fi
done

# Remove old files that are no longer in source
echo "Cleaning up old files..."
REMOVED_COUNT=0
for old_file in "$TARGET_DIR"/*.sh; do
  if [[ -f "$old_file" ]]; then
    old_basename="$(basename "$old_file")"
    if [[ ! " ${CURRENT_FILES[@]} " =~ " ${old_basename} " ]]; then
      rm -v "$old_file"
      ((REMOVED_COUNT++))
    fi
  fi
done
if [[ $REMOVED_COUNT -eq 0 ]]; then
  echo "  No old files to remove"
fi

# Copy all .sh files (excluding setup.sh)
echo ""
echo "Copying alias files..."
for file in "$SCRIPT_DIR"/*.sh; do
  if [[ "$(basename "$file")" != "setup.sh" ]]; then
    cp -v "$file" "$TARGET_DIR/"
  fi
done

# Make them executable
echo ""
echo "Making files executable..."
chmod +x "$TARGET_DIR"/*.sh

# Check if ~/.bashrc sources ~/.bashrc.d/
BASHRC_SOURCE='if [ -d ~/.bashrc.d ]; then
  for file in ~/.bashrc.d/*.sh; do
    [ -r "$file" ] && source "$file"
  done
  unset file
fi'

if ! grep -q "bashrc.d" "$HOME/.bashrc" 2>/dev/null; then
    echo ""
    echo "⚠️  Your ~/.bashrc doesn't seem to source ~/.bashrc.d/"
    echo "Add this to your ~/.bashrc:"
    echo ""
    echo "$BASHRC_SOURCE"
    echo ""
    read -p "Would you like to add it automatically? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source bashrc.d files" >> "$HOME/.bashrc"
        echo "$BASHRC_SOURCE" >> "$HOME/.bashrc"
        echo "✅ Added to ~/.bashrc"
    fi
else
    echo "✅ ~/.bashrc already sources ~/.bashrc.d/"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "To use the aliases, either:"
echo "  1. Restart your terminal, or"
echo "  2. Run: source ~/.bashrc"
echo ""
echo "See README.md for alias documentation."
