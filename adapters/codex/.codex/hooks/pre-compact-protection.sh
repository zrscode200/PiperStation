#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station compact reminder: before compacting, refresh projects/<id>/work/context-pack.md with the current task, next exact action, scope boundary, files to inspect first, verification state, review state, drift result, blockers, risks, broad-search triggers, git state, and what to hand a human or fresh agent. This hook reminds; it does not block compaction. The compact summary quality depends on these records being current."
}
EOF
