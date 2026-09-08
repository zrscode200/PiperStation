#!/usr/bin/env sh
set -eu
PIPER_BOOTSTRAP_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
exec python3 "$PIPER_BOOTSTRAP_DIR/install.py" "$@"
