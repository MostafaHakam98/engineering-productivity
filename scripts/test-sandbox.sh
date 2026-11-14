#!/usr/bin/env bash
# Build a disposable test image; run without host home, privileges, or network.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="${1:-24.04}"
case "$version" in 22.04|24.04) ;; *) echo 'usage: test-sandbox.sh [22.04|24.04]' >&2; exit 1 ;; esac
image="engineering-productivity-test:ubuntu-$version"
docker build --build-arg "UBUNTU_VERSION=$version" -f "$REPO_DIR/tests/Dockerfile" -t "$image" "$REPO_DIR"
docker run --rm --network none --cap-drop ALL --security-opt no-new-privileges \
    --read-only --tmpfs /tmp:rw,exec,nosuid,nodev,size=512m "$image"
