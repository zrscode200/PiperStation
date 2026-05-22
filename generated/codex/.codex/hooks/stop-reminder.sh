#!/usr/bin/env sh
set -eu

json_escape() {
  printf "%s" "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

emit_continue() {
  message="$1"
  if [ -n "$message" ]; then
    escaped=$(json_escape "$message")
    printf '{"continue":true,"systemMessage":"%s"}\n' "$escaped"
  else
    printf '{"continue":true}\n'
  fi
}

emit_continue ""
