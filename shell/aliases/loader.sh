#!/bin/bash
# Loader script to source aliases directly from repository
# Usage: source /path/to/aliases/loader.sh

# Get the directory where this script is located
ALIASES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load order: core first, then others, optional last
LOAD_ORDER=(
    "core"
    "navigation"
    "tools"
    "git"
    "docker"
    "prompt"
    "optional"
)

# Source all .sh files in each directory in order
for dir in "${LOAD_ORDER[@]}"; do
    dir_path="$ALIASES_DIR/$dir"
    if [[ -d "$dir_path" ]]; then
        for file in "$dir_path"/*.sh; do
            if [[ -f "$file" && -r "$file" ]]; then
                source "$file"
            fi
        done
    fi
done

unset ALIASES_DIR LOAD_ORDER dir dir_path file
