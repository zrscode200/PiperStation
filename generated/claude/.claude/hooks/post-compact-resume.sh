#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station post-compact resume: reload CLAUDE.md, STATION.md, the relevant projects/<id>/project.md, memory.md, optional decisions.md, work/context-pack.md, work/active-work.md, work/build-log.md, optional work/task-queue.md, and work/roadmap.md when relevant. Verify live branch, HEAD, and git status in the real project repo before editing. Rebuild the active task neighborhood from named files, changed files, relevant tests, docs, generated surfaces, and known reference paths. Expand beyond that only for a concrete trigger such as a stale resume packet, missing acceptance criteria, failing verification, generated parity, security or permissions behavior, or review scope."
}
EOF
