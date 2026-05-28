#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station compact protection: before compacting, refresh projects/<id>/work/context-pack.md and handoff.md with the current task, next exact action, scope boundary, files to inspect first, verification state, review state, drift result, blockers, risks, broad-search triggers, and git state. The compact summary quality depends on these records being current."
}
EOF
