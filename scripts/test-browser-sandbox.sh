#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docker build -f "$REPO_DIR/tests/browser.Dockerfile" -t engineering-productivity-test:browser "$REPO_DIR"
docker run --rm --network none --cap-drop ALL --security-opt no-new-privileges \
    --read-only --tmpfs /tmp:rw,exec,nosuid,nodev,size=512m --ipc private --shm-size 256m \
    engineering-productivity-test:browser
