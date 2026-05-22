#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
if [ -t 0 ]; then
  input=""
else
  input=$(cat 2>/dev/null || true)
fi
is_resume=false
case "$input" in
  *'"source"'*':'*'"resume"'*) is_resume=true ;;
esac

if [ -f "$ROOT/STATION.md" ]; then
  cat <<'EOF'
Piper Station hub-lite is active.
Register repos with ./bin/add-project. Durable hub context stays under
projects/<project-id>/; optional active work continuity may live under
projects/<project-id>/work/.
EOF
fi

if [ "$is_resume" = true ]; then
  cat <<'EOF'

Resume guidance: when continuing compacted or active Ralph work, start from
context-pack.md and handoff.md when present, verify branch/HEAD/status, rebuild
the active task neighborhood, then expand only for a concrete reason such as
mismatch, missing acceptance criteria, failing verification, generated parity,
security/permissions behavior, or review scope.
EOF
fi

projects_dir="$ROOT/projects"
if [ -d "$projects_dir" ]; then
  count=$(find "$projects_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  if [ "$count" -gt 0 ]; then
    printf '\nRegistered projects: %s\n' "$count"
    find "$projects_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null |
      sed 's#.*/##' |
      sort |
      sed 's#^#- #'
  else
    printf '\nNo registered projects yet. Use ./bin/add-project --repo /path/to/repo.\n'
  fi
fi
