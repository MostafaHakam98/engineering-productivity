#!/usr/bin/env bash
# Install the shared AI config into one target's global config directory.
#
#   install-global.sh <target> [--dry-run]
#   install-global.sh all      [--dry-run]
#
# Instructions, skills, commands and agents are written into the target's
# config dir. Permissions are MERGED into the target's settings file, never
# replaced.
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
    echo "usage: install-global.sh <target|all> [--dry-run]"
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
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done

if [ "$TARGET" = "all" ]; then
    for t in "$TARGETS_DIR"/*.target; do
        if [ "$DRY_RUN" = 1 ]; then
            "$0" "$(basename "$t" .target)" --dry-run
        else
            "$0" "$(basename "$t" .target)"
        fi
        echo
    done
    exit 0
fi

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

STAGE="$("$SCRIPT_DIR/port.sh" "$TARGET")"
trap 'rm -rf "$STAGE"' EXIT

MANIFEST="$TARGET_HOME/$MANIFEST_NAME"
NEW_MANIFEST="$STAGE.manifest"
: > "$NEW_MANIFEST"

# Every staged path, relative to TARGET_HOME. Top-level entries of a skill
# directory are recorded as the directory itself, so a dropped skill is pruned
# whole while neighbouring external symlinks are untouched.
record() { printf '%s\n' "$1" >> "$NEW_MANIFEST"; }

install_tree() {
    local label="$1" live="$2" granularity="${3:-file}"
    local staged="$STAGE${live#"$TARGET_HOME"}"
    [ -e "$staged" ] || return 0

    echo "  $label -> $live"
    if [ "$granularity" = "dir" ]; then
        local d
        for d in "$staged"/*/; do
            [ -d "$d" ] || continue
            record "${live#"$TARGET_HOME"/}/$(basename "$d")"
        done
    elif [ -d "$staged" ]; then
        local f
        while IFS= read -r f; do
            record "${live#"$TARGET_HOME"/}/${f#"$staged"/}"
        done < <(find "$staged" -type f | sort)
    else
        record "${live#"$TARGET_HOME"/}"
    fi

    [ "$DRY_RUN" = 1 ] && return 0
    if [ -d "$staged" ]; then
        mkdir -p "$live"
        rsync -a --exclude='.gitkeep' "$staged/" "$live/"
    else
        mkdir -p "$(dirname "$live")"
        cp "$staged" "$live"
    fi
}

[ -n "$INSTRUCTIONS_DEST" ] && install_tree "instructions" "$INSTRUCTIONS_DEST"
[ -n "$SKILLS_DEST" ]       && install_tree "skills"       "$SKILLS_DEST" \
                                   "$([ "$SKILLS_FORMAT" = "skill-dir" ] && echo dir || echo file)"
[ -n "$COMMANDS_DEST" ]     && install_tree "commands"     "$COMMANDS_DEST"
[ -n "$AGENTS_DEST" ]       && install_tree "agents"       "$AGENTS_DEST"

# Prune paths a previous run installed that this run no longer ships.
if [ -f "$MANIFEST" ]; then
    while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        grep -qxF "$rel" "$NEW_MANIFEST" && continue
        stale="$TARGET_HOME/$rel"
        [ -e "$stale" ] || continue
        echo "  prune (no longer in kit) -> $stale"
        [ "$DRY_RUN" = 1 ] || rm -rf "$stale"
    done < "$MANIFEST"
fi

if [ -n "$PERMISSIONS_DEST" ]; then
    if [ "$DRY_RUN" = 1 ]; then
        echo "  permissions -> $PERMISSIONS_DEST (merge, skipped in dry run)"
    else
        echo "  permissions -> $PERMISSIONS_DEST (merged, existing keys preserved)"
        render_permissions "$SHARED_DIR/permissions.json" "$PERMISSIONS_DEST" "$PERMISSIONS_FORMAT"
    fi
fi

if [ "$DRY_RUN" = 0 ]; then
    mkdir -p "$TARGET_HOME"
    # Targets may map two artifact kinds into one directory (Cursor keeps the
    # instructions rule alongside the skill rules), so dedupe before writing.
    sort -u "$NEW_MANIFEST" > "$MANIFEST"
fi

echo "Done: $TARGET_LABEL"
