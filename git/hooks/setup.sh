#!/bin/bash
# Setup script to install Git hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR"

# Determine target directory
if [ -d ".git" ]; then
    # We're in a git repository
    TARGET_DIR=".git/hooks"
    echo "Installing hooks in current repository..."
elif [ -n "$1" ]; then
    # Target directory provided as argument
    if [ ! -d "$1/.git" ]; then
        echo "❌ Error: $1 is not a git repository"
        exit 1
    fi
    TARGET_DIR="$1/.git/hooks"
    echo "Installing hooks in $1..."
else
    # Ask user
    read -p "Enter path to git repository (or press Enter for global install): " repo_path
    if [ -z "$repo_path" ]; then
        # Global install
        git config --global core.hooksPath ~/.git-hooks || true
        TARGET_DIR="$HOME/.git-hooks"
        mkdir -p "$TARGET_DIR"
        echo "Installing hooks globally in $TARGET_DIR..."
    else
        if [ ! -d "$repo_path/.git" ]; then
            echo "❌ Error: $repo_path is not a git repository"
            exit 1
        fi
        TARGET_DIR="$repo_path/.git/hooks"
        echo "Installing hooks in $repo_path..."
    fi
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy hooks
echo ""
echo "Copying hooks..."
for hook in pre-commit pre-push; do
    if [ -f "$HOOKS_DIR/$hook" ]; then
        cp -v "$HOOKS_DIR/$hook" "$TARGET_DIR/"
        chmod +x "$TARGET_DIR/$hook"
        echo "✅ Installed $hook"
    fi
done

echo ""
echo "✅ Setup complete!"
echo ""
echo "Hooks are now active. They will run automatically on:"
echo "  - pre-commit: Before each commit"
echo "  - pre-push: Before each push"
echo ""
echo "To bypass (use sparingly):"
echo "  git commit --no-verify"
echo "  git push --no-verify"
