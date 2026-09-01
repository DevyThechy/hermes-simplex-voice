#!/usr/bin/env bash
# Apply the SimpleX native voice call patch to a Hermes Agent checkout.
# Usage: ./apply.sh [path-to-hermes-agent]   (default: /usr/local/lib/hermes-agent)
set -euo pipefail

PATCH="$(cd "$(dirname "$0")" && pwd)/simplex-voice-calls.patch"
TARGET="${1:-/usr/local/lib/hermes-agent}"

if [ ! -f "$PATCH" ]; then
  echo "patch file not found: $PATCH" >&2
  exit 1
fi
if [ ! -d "$TARGET/.git" ]; then
  echo "not a git checkout: $TARGET" >&2
  exit 1
fi

cd "$TARGET"
if ! git diff --quiet -- plugins/platforms/simplex/adapter.py; then
  echo "adapter.py has local changes; stash or back them up before applying" >&2
  exit 1
fi

if ! git apply --3way --check "$PATCH"; then
  echo "patch does not apply on this checkout. Try: git -C $TARGET pull" >&2
  exit 1
fi

git apply --3way "$PATCH"
echo "Patch applied. Restart the gateway: systemctl --user restart hermes-gateway"
