#!/usr/bin/env bash
# Render the shared AI config into one target's dialect, in a staging directory.
#
#   port.sh <target> [--out DIR]
#
# Nothing under $HOME is touched. Use this to inspect exactly what
# install-global.sh would write, or to diff a target before installing.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SHARED_DIR="$AI_DIR/shared"
TARGETS_DIR="$AI_DIR/targets"

# shellcheck source=lib/render.sh
. "$SCRIPT_DIR/lib/render.sh"

usage() {
    echo "usage: port.sh <target> [--out DIR]"
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
TARGET_FILE="$TARGETS_DIR/$TARGET.target"
[ -f "$TARGET_FILE" ] || { echo "unknown target: $TARGET" >&2; echo >&2; usage >&2; exit 1; }

OUT=""
while [ $# -gt 0 ]; do
    case "$1" in
        --out) OUT="${2:?--out needs a directory}"; shift 2 ;;
        *)     echo "unknown option: $1" >&2; exit 1 ;;
    esac
done

# Defaults, so a target file only declares what it supports.
INSTRUCTIONS_DEST=""; INSTRUCTIONS_TITLE="Global Engineering Preferences"; INSTRUCTIONS_FORMAT="md"
SKILLS_DEST="";       SKILLS_FORMAT=""
COMMANDS_DEST="";     COMMANDS_FORMAT=""
AGENTS_DEST="";       AGENTS_FORMAT=""
PERMISSIONS_DEST="";  PERMISSIONS_FORMAT=""
PROJECT_DEST="";      PROJECT_FORMAT=""
# shellcheck source=/dev/null
. "$TARGET_FILE"

OUT="${OUT:-$(mktemp -d "${TMPDIR:-/tmp}/ai-port-$TARGET.XXXXXX")}"
mkdir -p "$OUT"

# Placeholder values for this target, consumed by subst() in lib/render.sh.
export PH_SKILLS_DIR="$SKILLS_DEST"
export PH_CONFIG_DIR="$PROJECT_DEST"
export PH_RULE_EXT="md"
export PH_ENTRYPOINT="CLAUDE.md"
case "$PROJECT_FORMAT" in
    agents-md|pi-project) PH_ENTRYPOINT="AGENTS.md" ;;
    mdc-project)          PH_ENTRYPOINT="rules/project.mdc"; PH_RULE_EXT="mdc" ;;
esac

# Map each absolute destination under $TARGET_HOME to the same relative path
# inside the staging dir, so install-global.sh can rsync it back one-to-one.
stage() { printf '%s%s' "$OUT" "${1#"$TARGET_HOME"}"; }

[ -n "$INSTRUCTIONS_DEST" ] && render_instructions \
    "$SHARED_DIR/instructions.md" "$(stage "$INSTRUCTIONS_DEST")" \
    "$INSTRUCTIONS_TITLE" "$SKILLS_DEST" "$INSTRUCTIONS_FORMAT"

[ -n "$SKILLS_DEST" ] && render_skills \
    "$SHARED_DIR/skills" "$(stage "$SKILLS_DEST")" "$SKILLS_FORMAT"

[ -n "$COMMANDS_DEST" ] && render_commands \
    "$SHARED_DIR/commands" "$(stage "$COMMANDS_DEST")" "$COMMANDS_FORMAT"

[ -n "$AGENTS_DEST" ] && render_agents \
    "$SHARED_DIR/agents" "$(stage "$AGENTS_DEST")" "$AGENTS_FORMAT"

# Permissions merge into a live settings file, so they are rendered at install
# time against the real file rather than staged here.

echo "$OUT"
