#!/bin/bash
# Source aliases directly from repository.
# Usage: source /path/to/aliases/loader.sh

ALIASES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$ALIASES_DIR/load-order.conf"

if [[ ! -f "$CONF" ]]; then
    echo "al: load-order.conf not found at $CONF" >&2
    return 1
fi

while IFS=: read -r _num _cat _file; do
    [[ "$_num" =~ ^[[:space:]]*# || -z "${_num// }" ]] && continue
    _path="$ALIASES_DIR/$_cat/$_file"
    [[ -f "$_path" && -r "$_path" ]] && source "$_path"
done < "$CONF"

unset ALIASES_DIR CONF _num _cat _file _path
