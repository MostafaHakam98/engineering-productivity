#!/bin/bash
# Loader script to source aliases directly from repository
# Usage: source /path/to/aliases/loader.sh

# Get the directory where this script is located
ALIASES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define exact load order matching original numbering scheme
# This ensures files are loaded in the correct sequence
# Order: 00-core, 10-navigation, 20-colors, 30-ls, 40-tools, 50-git, 60-docker, 70-prompt, 80-fzf, 90-nvm, 95-atuin, 99-path
LOAD_ORDER=(
    "core/core.sh"              # 00
    "navigation/navigation.sh"   # 10
    "core/colors.sh"             # 20
    "core/ls.sh"                 # 30
    "tools/tools.sh"             # 40
    "git/git.sh"                 # 50
    "docker/docker.sh"           # 60
    "prompt/prompt.sh"           # 70
    "optional/fzf.sh"            # 80
    "optional/nvm.sh"            # 90
    "optional/atuin.sh"          # 95
    "core/path.sh"               # 99
)

# Source files in the defined order
for rel_path in "${LOAD_ORDER[@]}"; do
    file_path="$ALIASES_DIR/$rel_path"
    if [[ -f "$file_path" && -r "$file_path" ]]; then
        source "$file_path"
    fi
done

unset ALIASES_DIR LOAD_ORDER rel_path file_path
