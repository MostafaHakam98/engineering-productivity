#!/bin/bash
# Install alias files to ~/.bashrc.d/
# Usage: ./setup.sh [copy|symlink|direct]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.bashrc.d"
BASHRC="$HOME/.bashrc"
CONF="$SCRIPT_DIR/load-order.conf"
METHOD="${1:-copy}"

[[ -f "$CONF" ]]                            || { echo "setup: load-order.conf not found" >&2; exit 1; }
[[ "$METHOD" =~ ^(copy|symlink|direct)$ ]]  || { echo "Usage: $0 [copy|symlink|direct]" >&2; exit 1; }

_skip() { [[ "$1" =~ ^[[:space:]]*# || -z "${1// }" ]]; }

_ensure_bashrc_sourcing() {
    grep -q "bashrc.d" "$BASHRC" 2>/dev/null && return
    printf '\n# Source bashrc.d files\nif [ -d ~/.bashrc.d ]; then\n  for f in ~/.bashrc.d/*.sh; do [ -r "$f" ] && source "$f"; done\n  unset f\nfi\n' >> "$BASHRC"
    echo "  patched ~/.bashrc to source ~/.bashrc.d/"
}

mkdir -p "$TARGET_DIR"
find "$TARGET_DIR" -maxdepth 1 -name '[0-9][0-9]-*.sh' -delete 2>/dev/null || true

case "$METHOD" in
    copy)
        while IFS=: read -r num cat file; do
            _skip "$num" && continue
            src="$SCRIPT_DIR/$cat/$file"
            if [[ -f "$src" ]]; then
                cp "$src" "$TARGET_DIR/${num}-${file}" && echo "  copied ${num}-${file}"
            else
                echo "  missing: $cat/$file" >&2
            fi
        done < "$CONF"
        _ensure_bashrc_sourcing
        ;;
    symlink)
        while IFS=: read -r num cat file; do
            _skip "$num" && continue
            src="$SCRIPT_DIR/$cat/$file"
            if [[ -f "$src" ]]; then
                ln -sf "$src" "$TARGET_DIR/${num}-${file}" && echo "  linked ${num}-${file}"
            else
                echo "  missing: $cat/$file" >&2
            fi
        done < "$CONF"
        _ensure_bashrc_sourcing
        ;;
    direct)
        loader_path="$SCRIPT_DIR/loader.sh"
        source_line="[ -f \"$loader_path\" ] && source \"$loader_path\""
        if grep -qF "$loader_path" "$BASHRC" 2>/dev/null; then
            echo "  already configured"
        else
            printf '\n# Source aliases directly from repository\n%s\n' "$source_line" >> "$BASHRC"
            echo "  added direct sourcing to ~/.bashrc"
        fi
        ;;
esac
