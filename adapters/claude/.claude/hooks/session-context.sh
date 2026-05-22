#!/usr/bin/env sh
set -eu

input=$(cat)
source=$(printf "%s" "$input" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
source="${source:-startup}"

find_hub_dir() {
  dir="${PWD:-.}"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/CLAUDE.md" ] && [ -d "$dir/projects" ]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir=$(dirname -- "$dir")
  done
  return 1
}

hub_dir=$(find_hub_dir || printf '%s\n' "${PWD:-.}")
project_count=0

if [ -d "$hub_dir/projects" ]; then
  project_count=$(
    find "$hub_dir/projects" -mindepth 2 -maxdepth 2 -name project.md -type f 2>/dev/null |
      wc -l |
      tr -d ' '
  )
fi

printf 'Piper Station Claude hub-lite is active.\n'
printf 'Read CLAUDE.md and STATION.md before changing registered project repos.\n'

if [ "$project_count" = "0" ]; then
  printf 'No registered projects yet. Use /add-project or ./bin/add-project to register one.\n'
else
  printf 'Registered projects: %s. Load the relevant projects/<id>/ record before work.\n' "$project_count"
fi

case "$source" in
  resume|compact)
    cat <<'EOF'

Resume guidance:
- Reload projects/<id>/project.md, memory.md, decisions.md, and work/context-pack.md when present.
- Check work/handoff.md, task-queue.md, active-plan.md, and verification.md when present.
- Verify live branch, HEAD, and git status in the real project repo before editing.
- Rebuild the active task neighborhood from named files, changed files, relevant tests, docs, generated surfaces, and known reference paths.
- Expand beyond the packet when handoff state is stale, acceptance criteria are missing, verification is failing, generated parity is unclear, security or permissions behavior is involved, or review scope requires it.
EOF
    ;;
esac
