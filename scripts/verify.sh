#!/usr/bin/env bash
# Run inside the test container or a disposable checkout, never install globally.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"
export LC_ALL=C.UTF-8
python3 -B -m unittest discover -s tests -v
files=(forge bench shell/aliases/al git/hooks/pre-commit git/hooks/pre-push)
while IFS= read -r -d '' file; do files+=("$file"); done < <(
    find ai shell git browser extensions scripts tests -type f -name '*.sh' -print0
)
shellcheck -s bash -S error "${files[@]}"
