#!/usr/bin/env sh
set -eu
PIPER_LIFECYCLE_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
exec python3 "$PIPER_LIFECYCLE_ROOT/.piper/lib/lifecycle.py" --runtime codex --event post-compact
