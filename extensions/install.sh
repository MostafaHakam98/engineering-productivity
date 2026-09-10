#!/usr/bin/env bash
# Build and install a VS Code extension declared under extensions/<name>/.
#
#   install.sh [name...] [--update] [--no-ai-config] [--editor CMD]
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
EDITOR_CMD=""
NAMES=()
while [ $# -gt 0 ]; do
    case "$1" in
        --update)       UPDATE=1; shift ;;
        --no-ai-config) AI_CONFIG=0; shift ;;
        --editor)       EDITOR_CMD="${2:?--editor needs a command}"; shift 2 ;;
        -h|--help)
            echo "usage: install.sh [name...] [--update] [--no-ai-config] [--editor CMD]"
            echo
            echo "extensions:"
            for d in "$SCRIPT_DIR"/*/; do
                [ -f "$d/extension.json" ] || continue
                printf '  %-12s %s\n' "$(basename "$d")" \
                    "$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["description"])' "$d/extension.json")"
            done
            exit 0 ;;
        *) NAMES+=("$1"); shift ;;
    esac
done

if [ ${#NAMES[@]} -eq 0 ]; then
    for d in "$SCRIPT_DIR"/*/; do
        [ -f "$d/extension.json" ] && NAMES+=("$(basename "$d")")
    done
fi

# Pick an editor CLI that can install a .vsix.
if [ -z "$EDITOR_CMD" ]; then
    for c in code code-insiders codium cursor; do
        command -v "$c" >/dev/null && { EDITOR_CMD="$c"; break; }
    done
fi
[ -n "$EDITOR_CMD" ] || { echo "no VS Code CLI found (tried code, code-insiders, codium, cursor)" >&2
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

    # Runtime prerequisites are reported, never installed silently.
    missing=""
    for tool in $(python3 -c '
import json,sys
d=json.load(open(sys.argv[1]))
print(" ".join(d.get("build",{}).get("requires",[]) + d.get("runtime",{}).get("requires",[])))
' "$manifest"); do
        command -v "$tool" >/dev/null || missing="$missing $tool"
    done
    if [ -n "$missing" ]; then
        echo "  missing prerequisites:$missing"
        hint="$(jq_field "$manifest" runtime.install)"
        [ -n "$hint" ] && echo "  install the agent runtime with: $hint"
        echo "  skipping $name"
        continue
    fi

    url="$(jq_field "$manifest" source.url)"
    ref="$(jq_field "$manifest" source.ref)"
    repo="$CACHE/$name"
    mkdir -p "$CACHE"

    if [ ! -d "$repo/.git" ]; then
        echo "  clone $url"
        git clone --quiet "$url" "$repo"
    elif [ "$UPDATE" = 1 ]; then
        echo "  fetch $name"
        git -C "$repo" fetch --quiet --all --tags --prune
    fi

    # "default" tracks whatever the remote's HEAD points at, so a repository
    # that renames its branch does not break the declaration.
    if [ -z "$ref" ] || [ "$ref" = "default" ]; then
        git -C "$repo" remote set-head origin --auto >/dev/null 2>&1 || true
        ref="$(git -C "$repo" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"
        ref="${ref#origin/}"
        [ -n "$ref" ] || ref="$(git -C "$repo" rev-parse --abbrev-ref HEAD)"
        echo "  default branch: $ref"
    fi

    git -C "$repo" checkout --quiet "$ref" || {
        echo "  ! cannot check out '$ref' — skipping $name" >&2; continue; }
    # Fast-forward only when tracking a branch, never when pinned to a commit.
    if [ "$UPDATE" = 1 ] && git -C "$repo" symbolic-ref -q HEAD >/dev/null; then
        git -C "$repo" pull --quiet --ff-only 2>/dev/null || true
    fi
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

    echo "  installing $artifact into $EDITOR_CMD"
    "$EDITOR_CMD" --install-extension "$repo/$artifact" --force

    # Install the matching agent config, so the extension arrives configured.
    target="$(jq_field "$manifest" aiTarget)"
    if [ "$AI_CONFIG" = 1 ] && [ -n "$target" ]; then
        echo "  installing AI config for target '$target'"
        "$REPO_DIR/ai/scripts/install-global.sh" "$target"
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

echo "Done. Reload the editor window to activate."
