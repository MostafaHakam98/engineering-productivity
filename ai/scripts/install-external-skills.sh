#!/usr/bin/env bash
# Install third-party skills declared in ai/shared/external-skills.json.
#
#   install-external-skills.sh [target...] [--update]
#
# Each source is cloned at its pinned ref into the manifest's 'root'
# (default ~/.agents/skills), then the listed skills are symlinked into every
# named target's skills directory. With no target, all targets that support
# skills are linked.
#
# The skills themselves are never copied into this repository — upstream keeps
# ownership and licensing, and the pinned ref makes the install reproducible.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$AI_DIR/shared/external-skills.json"
TARGETS_DIR="$AI_DIR/targets"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/engineering-productivity/external-skills"

command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

UPDATE=0
TARGETS=()
for arg in "$@"; do
    case "$arg" in
        --update) UPDATE=1 ;;
        *)        TARGETS+=("$arg") ;;
    esac
done

if [ ${#TARGETS[@]} -eq 0 ]; then
    for t in "$TARGETS_DIR"/*.target; do
        name="$(basename "$t" .target)"
        grep -q '^SKILLS_FORMAT="skill-dir"' "$t" && TARGETS+=("$name")
    done
fi

ROOT="$(python3 -c 'import json,os,sys; print(os.path.expanduser(json.load(open(sys.argv[1]))["root"]))' "$MANIFEST")"
mkdir -p "$ROOT" "$CACHE"

echo "External skills root: $ROOT"

# name<TAB>url<TAB>ref  per source
while IFS=$'\t' read -r sname surl sref; do
    repo="$CACHE/$sname"
    if [ ! -d "$repo/.git" ]; then
        echo "  clone $surl"
        git clone --quiet "$surl" "$repo"
    elif [ "$UPDATE" = 1 ]; then
        echo "  fetch $sname"
        git -C "$repo" fetch --quiet --all --tags
    fi
    git -C "$repo" fetch --quiet origin "$sref" 2>/dev/null || true
    git -C "$repo" checkout --quiet "$sref" 2>/dev/null || {
        echo "  ! cannot check out $sref in $sname — skipping" >&2; continue; }
    echo "  $sname @ $(git -C "$repo" rev-parse --short HEAD)"

    # name<TAB>path per skill of this source
    while IFS=$'\t' read -r kname kpath; do
        src="$repo/$kpath"
        if [ ! -d "$src" ]; then
            echo "    ! $kname: '$kpath' missing at this ref — re-verify the manifest" >&2
            continue
        fi
        rm -rf "${ROOT:?}/$kname"
        cp -R "$src" "$ROOT/$kname"
        echo "    + $kname"
    done < <(python3 -c '
import json, sys
m = json.load(open(sys.argv[1]))
for s in m["sources"]:
    if s["name"] == sys.argv[2]:
        for k in s["skills"]:
            print(k["name"] + "\t" + k["path"])
' "$MANIFEST" "$sname")
done < <(python3 -c '
import json, sys
for s in json.load(open(sys.argv[1]))["sources"]:
    print(s["name"] + "\t" + s["url"] + "\t" + s["ref"])
' "$MANIFEST")

# Symlink into each target so the kit-owned skills and the external ones sit
# side by side. Symlinks (not copies) keep a single upstream copy on disk and
# leave the kit's own install manifest untouched.
for target in "${TARGETS[@]}"; do
    tf="$TARGETS_DIR/$target.target"
    [ -f "$tf" ] || { echo "unknown target: $target" >&2; continue; }
    SKILLS_DEST=""
    # shellcheck source=/dev/null
    . "$tf"
    [ -n "$SKILLS_DEST" ] || continue
    mkdir -p "$SKILLS_DEST"
    echo "Linking into $TARGET_LABEL ($SKILLS_DEST)"
    for d in "$ROOT"/*/; do
        name="$(basename "$d")"
        link="$SKILLS_DEST/$name"
        if [ -e "$link" ] && [ ! -L "$link" ]; then
            echo "  ! $name: a real directory already exists here — skipping" >&2
            echo "    (the kit's own skill would be shadowed; resolve by hand)" >&2
            continue
        fi
        ln -sfn "$d" "$link"
        echo "  -> $name"
    done
done

echo "Done."
