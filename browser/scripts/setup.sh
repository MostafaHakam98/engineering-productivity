#!/usr/bin/env bash
# Parse .env as data; never execute configuration as shell code.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
exec python3 "$SCRIPT_DIR/configure.py" "$@"
