#!/usr/bin/env bash
# Install the shared project template into the current directory, in one
# target's dialect.
#
#   install-project.sh <target> [--force]
#
# Project files are meant to be committed to the product repository.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SHARED_DIR="$AI_DIR/shared"
TARGETS_DIR="$AI_DIR/targets"

# shellcheck source=lib/render.sh
. "$SCRIPT_DIR/lib/render.sh"

[ $# -ge 1 ] || {
    echo "usage: install-project.sh <target> [--force]"
    echo
    echo "targets:"
    for t in "$TARGETS_DIR"/*.target; do
        printf '  %-12s %s\n' "$(basename "$t" .target)" \
            "$(sed -n 's/^TARGET_LABEL="\(.*\)"$/\1/p' "$t")"
    done
    exit 1
}

TARGET="$1"; shift
[[ "$TARGET" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "invalid target: $TARGET" >&2; exit 1; }
FORCE=0
while [ $# -gt 0 ]; do
    case "$1" in
        --force) FORCE=1; shift ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

TARGET_FILE="$TARGETS_DIR/$TARGET.target"
[ -f "$TARGET_FILE" ] || { echo "unknown target: $TARGET" >&2; exit 1; }

PROJECT_DEST=""; PROJECT_FORMAT=""; SKILLS_DEST=""
# shellcheck source=/dev/null
. "$TARGET_FILE"

[ -n "$PROJECT_FORMAT" ] || { echo "$TARGET_LABEL has no project template."; exit 0; }

DEST="$PWD/$PROJECT_DEST"

# Codex and pi place their entry point at the project root, so it needs the
# same overwrite guard as the dot directory.
GUARDED=("$DEST")
case "$PROJECT_FORMAT" in
    agents-md|pi-project) GUARDED+=("$PWD/AGENTS.md") ;;
esac

if [ "$FORCE" = 0 ]; then
    for path in "${GUARDED[@]}"; do
        [ -e "$path" ] || [ -L "$path" ] || continue
        echo "Already exists: $path"
        echo "Refusing to overwrite. Merge manually, or re-run with --force."
        exit 1
    done
fi

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/ai-project.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
render_project "$SHARED_DIR/project-template" "$STAGE/$PROJECT_DEST" "$PROJECT_FORMAT" "$SKILLS_DEST"
python3 "$AI_DIR/../scripts/lib/install_files.py" "$STAGE" "$PWD" --prefix ".engineering-productivity-$TARGET-project"

echo "Installed $TARGET_LABEL project template to: $DEST"
echo "Next: fill in the project-specific sections — repo rules, repo map,"
echo "      entrypoints, dependency map, and ownership map."
