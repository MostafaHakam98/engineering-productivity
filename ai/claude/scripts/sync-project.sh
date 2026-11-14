#!/usr/bin/env bash
# Shim: the Claude kit is now one target of the shared AI config.
# Canonical entry point: ai/scripts/sync-project.sh claude
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/../../scripts/install-project.sh" claude --force "$@"
