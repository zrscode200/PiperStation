#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station post-compact: reload AGENTS.md, STATION.md, and the active projects/<id>/project.md, memory.md, decisions.md, and work/context-pack.md when present. Verify branch, HEAD, and git status in the real project repo before editing. The model-visible resume anchors land via the SessionStart hook (source=compact)."
}
EOF
