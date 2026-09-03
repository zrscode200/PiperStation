#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station post-compact: reload AGENTS.md, STATION.md, and the active projects/<id>/project.md, memory.md, optional decisions.md, the selected lane's context-pack.md, active-work.md, build-log.md, and optional task-queue.md (under work/ for the flat lane or work/groups/<gid>/ for a group lane), and work/roadmap.md when relevant. Verify branch, HEAD, and git status in the lane's checkout before editing. The model-visible resume anchors land via the SessionStart hook (source=compact)."
}
EOF
