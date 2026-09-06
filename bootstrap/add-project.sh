#!/usr/bin/env sh
set -eu

# Source-distribution entry point; the hub-local bin wrapper infers its own hub.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
exec "$SCRIPT_DIR/../core/shared/.piper/lib/bootstrap/add-project.sh" "$@"
