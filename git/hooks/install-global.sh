#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.git-hooks"

G='\033[0;32m'; D='\033[2m'; NC='\033[0m'
ok()   { echo -e "  ${G}✓${NC}  $*"; }
info() { echo -e "  ${D}·${NC}  $*"; }

mkdir -p "$TARGET"
git config --global core.hooksPath "$TARGET"

for hook in pre-commit pre-push; do
    if [[ -f "$SCRIPT_DIR/$hook" ]]; then
        cp "$SCRIPT_DIR/$hook" "$TARGET/$hook"
        chmod +x "$TARGET/$hook"
        ok "Installed $hook → $TARGET/$hook"
    fi
done

ok "Global hooks configured: core.hooksPath = $TARGET"
info "Hooks will run automatically on every commit and push"
