#!/usr/bin/env bash
# Install the shared AI config into one target's global config directory.
#
#   install-global.sh <target> [--dry-run] [--permissions]
#   install-global.sh all      [--dry-run] [--permissions]
#
# Instructions, skills, commands and agents are written into the target's
# config dir, with recovery backups. Permissions are merged only with explicit
# --permissions; default installation leaves settings unchanged.
#
# Pruning is manifest-tracked, not rsync --delete: the target directories are
# shared with external skills (symlinks from ~/.agents/skills) and hand-written
# rules, so only paths this kit installed on a previous run are removed when
# the kit stops shipping them.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SHARED_DIR="$AI_DIR/shared"
TARGETS_DIR="$AI_DIR/targets"
MANIFEST_NAME=".engineering-productivity.manifest"

# shellcheck source=lib/render.sh
. "$SCRIPT_DIR/lib/render.sh"

usage() {
    echo "usage: install-global.sh <target|all> [--dry-run] [--permissions]"
    echo
    echo "targets:"
    for t in "$TARGETS_DIR"/*.target; do
        printf '  %-12s %s\n' "$(basename "$t" .target)" \
            "$(sed -n 's/^TARGET_LABEL="\(.*\)"$/\1/p' "$t")"
    done
}

[ $# -ge 1 ] || { usage; exit 1; }
case "$1" in -h|--help) usage; exit 0 ;; esac

TARGET="$1"; shift
DRY_RUN=0
PERMISSIONS=0
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        --permissions) PERMISSIONS=1; shift ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done

if [ "$TARGET" = "all" ]; then
    for t in "$TARGETS_DIR"/*.target; do
        options=()
        [ "$DRY_RUN" = 0 ] || options+=(--dry-run)
        [ "$PERMISSIONS" = 0 ] || options+=(--permissions)
        bash "$0" "$(basename "$t" .target)" "${options[@]}"
        echo
    done
    exit 0
fi

[[ "$TARGET" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "invalid target: $TARGET" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
TARGET_FILE="$TARGETS_DIR/$TARGET.target"
[ -f "$TARGET_FILE" ] || { echo "unknown target: $TARGET" >&2; echo >&2; usage >&2; exit 1; }

INSTRUCTIONS_DEST=""; INSTRUCTIONS_TITLE="Global Engineering Preferences"; INSTRUCTIONS_FORMAT="md"
SKILLS_DEST="";       SKILLS_FORMAT=""
COMMANDS_DEST="";     COMMANDS_FORMAT=""
AGENTS_DEST="";       AGENTS_FORMAT=""
PERMISSIONS_DEST="";  PERMISSIONS_FORMAT=""
PROJECT_DEST="";      PROJECT_FORMAT=""
# shellcheck source=/dev/null
. "$TARGET_FILE"

echo "Installing shared AI config -> $TARGET_LABEL ($TARGET_HOME)"
[ "$DRY_RUN" = 1 ] && echo "  (dry run — nothing will be written)"

STAGE="$(bash "$SCRIPT_DIR/port.sh" "$TARGET")"
trap 'rm -rf "$STAGE"' EXIT

# Permission changes are opt-in. Merge in staging, then deploy through the same
# backup and symlink checks as every other config file.
if [ "$PERMISSIONS" = 1 ] && [ -n "$PERMISSIONS_DEST" ]; then
    PERM_STAGE="$STAGE${PERMISSIONS_DEST#"$TARGET_HOME"}"
    python3 - "$PERMISSIONS_DEST" "$PERM_STAGE" <<'PYTHON'
import pathlib, sys
src, dest = map(pathlib.Path, sys.argv[1:])
# read-only input; the deployment helper rejects symlink destinations.
if src.is_file():
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(src.read_bytes())
PYTHON
    render_permissions "$SHARED_DIR/permissions.json" "$PERM_STAGE" "$PERMISSIONS_FORMAT"
fi

options=()
[ "$DRY_RUN" = 0 ] || options+=(--dry-run)
[ -z "$PERMISSIONS_DEST" ] || options+=(--keep "${PERMISSIONS_DEST#"$TARGET_HOME"/}")
python3 "$AI_DIR/../scripts/lib/install_files.py" "$STAGE" "$TARGET_HOME" "${options[@]}"
echo "Done: $TARGET_LABEL"
