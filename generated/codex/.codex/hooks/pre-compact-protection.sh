#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station compact reminder: before compacting, rewrite projects/<id>/work/context-pack.md in full to reflect the current boundary, next exact action, scope boundary, files to inspect first, verification state, review state, drift result, blockers, risks, broad-search triggers, git state, and what to hand a human or fresh agent — regenerate the whole packet and reconcile against the existing packet and live git rather than section-editing. This hook reminds; it does not block compaction. The compact summary quality depends on these records being current."
}
EOF
