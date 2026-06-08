#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station post-compact: reload AGENTS.md, STATION.md, and the active projects/<id>/project.md, memory.md, optional decisions.md, work/context-pack.md, work/active-work.md, work/build-log.md, optional work/task-queue.md, and work/roadmap.md when relevant. Verify branch, HEAD, and git status in the real project repo before editing. The model-visible resume anchors land via the SessionStart hook (source=compact)."
}
EOF
