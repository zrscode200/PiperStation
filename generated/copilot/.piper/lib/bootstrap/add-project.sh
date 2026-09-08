#!/usr/bin/env sh
set -eu

# Compatibility entry point for callers with an explicit --hub argument.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
exec python3 "$SCRIPT_DIR/register.py" "$@"
