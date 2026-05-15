#!/usr/bin/env bash
# Setup script to install Git hooks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR"

G='\033[0;32m'; R='\033[0;31m'; D='\033[2m'; NC='\033[0m'
ok()   { echo -e "  ${G}✓${NC}  $*"; }
fail() { echo -e "  ${R}✗${NC}  $*"; }
info() { echo -e "  ${D}·${NC}  $*"; }

# Determine target directory
if [ -d ".git" ]; then
    TARGET_DIR=".git/hooks"
    echo "  Installing hooks in current repository..."
elif [ -n "${1:-}" ]; then
    if [ ! -d "$1/.git" ]; then
        fail "Not a git repository: $1"
        exit 1
    fi
    TARGET_DIR="$1/.git/hooks"
    echo "  Installing hooks in $1..."
else
    read -rp "  Repository path (or Enter for global install): " repo_path
    if [ -z "$repo_path" ]; then
        git config --global core.hooksPath ~/.git-hooks
        TARGET_DIR="$HOME/.git-hooks"
        mkdir -p "$TARGET_DIR"
        echo "  Installing hooks globally in $TARGET_DIR..."
    else
        if [ ! -d "$repo_path/.git" ]; then
            fail "Not a git repository: $repo_path"
            exit 1
        fi
        TARGET_DIR="$repo_path/.git/hooks"
        echo "  Installing hooks in $repo_path..."
    fi
fi

mkdir -p "$TARGET_DIR"

echo ""
for hook in pre-commit pre-push; do
    if [ -f "$HOOKS_DIR/$hook" ]; then
        cp "$HOOKS_DIR/$hook" "$TARGET_DIR/"
        chmod +x "$TARGET_DIR/$hook"
        ok "Installed $hook"
    fi
done

echo ""
ok "Setup complete"
echo ""
info "Hooks run automatically on every commit and push"
info "To bypass (use sparingly):  git commit --no-verify"
