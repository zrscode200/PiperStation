#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station compact reminder: before compaction, preserve the active project id, repo path, branch/HEAD/status, selected task, next exact action, scope boundary, files changed, files to inspect first, verification state, review state, drift result, blockers, risks, broad-search triggers, and what to hand a human or fresh agent. This hook reminds; it does not block compaction. If project work records are stale or missing, state that uncertainty in the compact summary."
}
EOF
