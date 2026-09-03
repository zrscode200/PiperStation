#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station post-compact resume: reload CLAUDE.md, STATION.md, the relevant projects/<id>/project.md, memory.md, optional decisions.md, the selected lane's context-pack.md, active-work.md, build-log.md, and optional task-queue.md (under work/ for the flat lane or work/groups/<gid>/ for a group lane), and work/roadmap.md when relevant. Verify live branch, HEAD, and git status in the lane's checkout before editing. Rebuild the active boundary neighborhood from named files, changed files, relevant tests, docs, generated surfaces, and known reference paths. Expand beyond that only for a concrete trigger such as a stale resume packet, missing acceptance criteria, failing verification, generated parity, security or permissions behavior, or review scope."
}
EOF
