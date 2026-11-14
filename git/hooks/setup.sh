#!/usr/bin/env bash
# Install in the explicit repository (including worktrees), or the current one.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
repo="${1:-$PWD}"
if [ "$repo" = "--global" ]; then
    exec bash "$SCRIPT_DIR/install-global.sh"
fi
if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
    echo "Not a git repository: $repo" >&2; exit 1
fi
# Respect an existing hooksPath. Silently replacing it could disable an
# organization's security hooks or overwrite a shared hooks directory.
if [ -n "$(git -C "$repo" config core.hooksPath || true)" ]; then
    echo "core.hooksPath is already configured; refusing to replace existing hooks policy." >&2
    exit 1
fi
TARGET="$(git -C "$repo" rev-parse --path-format=absolute --git-path hooks)"
stage="$(mktemp -d "${TMPDIR:-/tmp}/ep-hooks.XXXXXX")"
trap 'rm -rf "$stage"' EXIT
for hook in pre-commit pre-push; do
    cp "$SCRIPT_DIR/$hook" "$stage/$hook"
    chmod +x "$stage/$hook"
done
python3 "$SCRIPT_DIR/../../scripts/lib/install_files.py" "$stage" "$TARGET" --prefix .engineering-productivity-hooks
echo "Hooks installed in $TARGET"
