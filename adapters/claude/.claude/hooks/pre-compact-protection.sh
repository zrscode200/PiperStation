#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station compact protection: before compaction, preserve the active project id, repo path, branch/HEAD/status, selected task, next exact action, scope boundary, files changed, files to inspect first, verification state, review state, drift result, blockers, risks, and broad-search triggers. If project work records are stale or missing, state that uncertainty in the compact summary."
}
EOF
