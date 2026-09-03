#!/usr/bin/env sh
set -eu

cat <<'EOF'
{
  "systemMessage": "Piper Station compact reminder: before compacting, rewrite the selected lane's context-pack.md (projects/<id>/work/ for the flat lane, projects/<id>/work/groups/<gid>/ for a group lane) in full to the current boundary with only the non-derivable fields: goal, boundary and status, next exact action, verification and review state not yet in build-log.md, blockers and risks and open questions, stop reason, and optional broad-search triggers or a resume note. Branch, HEAD, status, changed files, and what to inspect first are derived live at resume; do not copy them into the packet. Regenerate the whole packet and reconcile against the existing packet and live git rather than section-editing. This hook reminds; it does not block compaction. The compact summary quality depends on these records being current."
}
EOF
