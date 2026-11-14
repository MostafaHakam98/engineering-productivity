#!/usr/bin/env bash
# Requires public network access. No host home, editor, tokens, or model calls.
set -euo pipefail
mkdir -p "$HOME"
bash /kit/ai/scripts/install-external-skills.sh claude codex metwally
bash /kit/ai/scripts/install-external-skills.sh claude codex metwally
bash /kit/extensions/install.sh metwally --build-only
