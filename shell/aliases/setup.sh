#!/usr/bin/env bash
# Install aliases and portable CLI launchers with backups of replaced files.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
exec python3 "$REPO_DIR/scripts/setup_shell.py" "$@"
