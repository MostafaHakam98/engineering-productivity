#!/usr/bin/env bash
# Explicit global opt-in; preserve existing hook files and hooksPath policy.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.git-hooks"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
previous="$(git config --global core.hooksPath || true)"
if [ -n "$previous" ] && [ "$previous" != "$TARGET" ]; then
    echo "Existing global core.hooksPath: $previous; refusing to replace it." >&2
    exit 1
fi
stage="$(mktemp -d "${TMPDIR:-/tmp}/ep-hooks.XXXXXX")"
trap 'rm -rf "$stage"' EXIT
for hook in pre-commit pre-push; do
    cp "$SCRIPT_DIR/$hook" "$stage/$hook"
    chmod +x "$stage/$hook"
done
python3 "$SCRIPT_DIR/../../scripts/lib/install_files.py" "$stage" "$TARGET" --prefix .engineering-productivity-hooks
# Preserve the config before changing it; config may itself be a dotfile link.
if [ -z "$previous" ]; then
    python3 - "$HOME/.gitconfig" <<'PY'
import pathlib, shutil, sys, tempfile
p = pathlib.Path(sys.argv[1])
if p.is_file():
    with tempfile.NamedTemporaryFile(prefix=p.name + '.ep-backup-', dir=p.parent, delete=False) as f:
        shutil.copyfileobj(p.open('rb'), f)
        print('Global Git config backup:', f.name)
PY
    git config --global core.hooksPath "$TARGET"
fi
echo "Global hooks configured: $TARGET"
