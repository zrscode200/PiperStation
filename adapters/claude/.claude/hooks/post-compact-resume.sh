#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station post-compact resume: reload CLAUDE.md, STATION.md, the relevant projects/<id>/project.md, memory.md, decisions.md, and work/context-pack.md when present. Verify live branch, HEAD, and git status in the real project repo before editing. Rebuild the active task neighborhood from named files, changed files, relevant tests, docs, generated surfaces, and known reference paths. Expand beyond that only for a concrete trigger such as a stale resume packet, missing acceptance criteria, failing verification, generated parity, security or permissions behavior, or review scope."
}
EOF
