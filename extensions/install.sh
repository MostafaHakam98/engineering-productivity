#!/usr/bin/env bash
# Build and install a VS Code extension declared under extensions/<name>/.
#
#   install.sh [name...] [--update] [--no-ai-config] [--editor CMD] [--build-only]
#
# Each extensions/<name>/extension.json declares where the source lives, how to
# build a .vsix from it, and which AI target (if any) carries its agent config.
# Source is cloned into a cache, never vendored here.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/engineering-productivity/extensions"

UPDATE=0
AI_CONFIG=1
BUILD_ONLY=0
EDITOR_CMD=""
NAMES=()
while [ $# -gt 0 ]; do
    case "$1" in
        --update)       UPDATE=1; shift ;;
        --no-ai-config) AI_CONFIG=0; shift ;;
        --build-only) BUILD_ONLY=1; AI_CONFIG=0; shift ;;
        --editor)       EDITOR_CMD="${2:?--editor needs a command}"; shift 2 ;;
        -h|--help)
            echo "usage: install.sh [name...] [--update] [--no-ai-config] [--editor CMD] [--build-only]"
            echo
            echo "extensions:"
            for d in "$SCRIPT_DIR"/*/; do
                [ -f "$d/extension.json" ] || continue
                printf '  %-12s %s\n' "$(basename "$d")" \
                    "$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["description"])' "$d/extension.json")"
            done
            exit 0 ;;
        --*) echo "unknown option: $1" >&2; exit 1 ;;
        *) [[ "$1" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "invalid extension: $1" >&2; exit 1; }
           NAMES+=("$1"); shift ;;
    esac
done

if [ ${#NAMES[@]} -eq 0 ]; then
    for d in "$SCRIPT_DIR"/*/; do
        [ -f "$d/extension.json" ] && NAMES+=("$(basename "$d")")
    done
fi

# Pick an editor CLI that can install a .vsix.
if [ -z "$EDITOR_CMD" ] && [ "$BUILD_ONLY" = 0 ]; then
    for c in code code-insiders codium cursor; do
        command -v "$c" >/dev/null && { EDITOR_CMD="$c"; break; }
    done
fi
[ -n "$EDITOR_CMD" ] || [ "$BUILD_ONLY" = 1 ] || { echo "no VS Code CLI found (tried code, code-insiders, codium, cursor)" >&2
                          echo "pass one with --editor" >&2; exit 1; }

jq_field() { python3 -c '
import json, sys
d = json.load(open(sys.argv[1]))
for k in sys.argv[2].split("."):
    d = d.get(k) if isinstance(d, dict) else None
    if d is None: break
print(d if d is not None else "")
' "$1" "$2"; }

for name in "${NAMES[@]}"; do
    manifest="$SCRIPT_DIR/$name/extension.json"
    [ -f "$manifest" ] || { echo "unknown extension: $name" >&2; exit 1; }

    echo "=== $(jq_field "$manifest" displayName) ==="

    command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
    command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
    if [ "$BUILD_ONLY" = 0 ]; then
        "$EDITOR_CMD" --version >/dev/null || { echo "editor CLI is unavailable" >&2; exit 1; }
    fi
    python3 - "$REPO_DIR/scripts/lib" "$CACHE/$name" <<'PYTHON'
import sys
sys.path.insert(0, sys.argv[1])
from install_files import checked
checked(sys.argv[2], leaf=True)
PYTHON

    # Runtime prerequisites are reported, never installed silently.
    missing=""
    for tool in $(python3 -c '
import json,sys
d=json.load(open(sys.argv[1]))
print(" ".join(d.get("build",{}).get("requires",[]) + ([] if sys.argv[2] == "1" else d.get("runtime",{}).get("requires",[]))))
' "$manifest" "$BUILD_ONLY"); do
        command -v "$tool" >/dev/null || missing="$missing $tool"
    done
    if [ -n "$missing" ]; then
        echo "  missing prerequisites:$missing"
        hint="$(jq_field "$manifest" runtime.install)"
        [ -n "$hint" ] && echo "  install the agent runtime with: $hint"
        echo "  cannot install $name" >&2
        exit 1
    fi

    url="$(jq_field "$manifest" source.url)"
    ref="$(jq_field "$manifest" source.ref)"
    [[ "$ref" =~ ^[a-f0-9]{40}$ ]] || { echo "extension source must be pinned to a commit" >&2; exit 1; }
    repo="$CACHE/$name"
    mkdir -p "$CACHE"

    if [ ! -d "$repo/.git" ]; then
        echo "  clone $url"
        git clone --quiet "$url" "$repo"
    elif [ "$UPDATE" = 1 ]; then
        echo "  fetch $name"
        git -C "$repo" fetch --quiet --all --tags --prune
    fi

    [ -z "$(git -C "$repo" status --porcelain)" ] || {
        echo "cache contains local changes: $repo" >&2; exit 1;
    }
    [ "$(git -C "$repo" remote get-url origin)" = "$url" ] || {
        echo "cache origin mismatch: $repo" >&2; exit 1;
    }
    git -C "$repo" checkout --quiet --detach "$ref"
    echo "  $name @ $(git -C "$repo" rev-parse --short HEAD)"

    artifact="$(jq_field "$manifest" build.artifact)"
    (
        cd "$repo"
        while IFS= read -r step; do
            [ -n "$step" ] || continue
            echo "  \$ $step"
            eval "$step"
        done < <(python3 -c '
import json,sys
for s in json.load(open(sys.argv[1]))["build"]["steps"]: print(s)
' "$manifest")
    )

    [ -f "$repo/$artifact" ] && [ ! -L "$repo/$artifact" ] || {
        echo "build artifact missing or symlinked: $artifact" >&2; exit 1;
    }
    if [ "$BUILD_ONLY" = 1 ]; then
        echo "  built and tested: $repo/$artifact"
        continue
    fi
    echo "  installing $artifact into $EDITOR_CMD"
    "$EDITOR_CMD" --install-extension "$repo/$artifact"

    # Install the matching agent config, so the extension arrives configured.
    target="$(jq_field "$manifest" aiTarget)"
    if [ "$AI_CONFIG" = 1 ] && [ -n "$target" ]; then
        echo "  installing AI config for target '$target'"
        bash "$REPO_DIR/ai/scripts/install-global.sh" "$target"
    fi

    settings="$(python3 -c '
import json,sys
for k, v in (json.load(open(sys.argv[1])).get("settings") or {}).items():
    print(f"    {k}: {v}")
' "$manifest")"
    if [ -n "$settings" ]; then
        echo "  settings worth reviewing:"
        printf '%s\n' "$settings"
    fi
done

if [ "$BUILD_ONLY" = 1 ]; then
    echo "Build complete; no editor or agent configuration was changed."
else
    echo "Done. Reload the editor window to activate."
fi
