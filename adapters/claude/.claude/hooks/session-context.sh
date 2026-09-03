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

group_lanes=""
if [ -d "$hub_dir/projects" ]; then
  group_lanes=$(
    find "$hub_dir/projects" -mindepth 4 -maxdepth 4 -path '*/work/groups/*' -type d 2>/dev/null |
      sed "s|^$hub_dir/projects/||" |
      sort |
      tr '\n' ' '
  )
fi
if [ -n "$group_lanes" ]; then
  printf 'Group lanes (projects/<id>/work/groups/<gid>): %s. Select one lane per session; ask when more than one is active.\n' "$group_lanes"
fi

case "$source" in
  resume|compact)
    cat <<'EOF'

Resume guidance:
- Reload projects/<id>/project.md, memory.md, optional decisions.md, and the selected lane's context-pack.md (work/context-pack.md for the flat lane, work/groups/<gid>/context-pack.md for a group lane) when present.
- Check the lane's active-work.md, build-log.md, and optional task-queue.md under work/ or work/groups/<gid>/, plus work/roadmap.md when relevant.
- Verify live branch, HEAD, and git status in the lane's checkout (repo_path or its recorded worktree) before editing.
- Rebuild the active boundary neighborhood from named files, changed files, relevant tests, docs, generated surfaces, and known reference paths.
- Expand beyond the packet when the resume state is stale, acceptance criteria are missing, verification is failing, generated parity is unclear, security or permissions behavior is involved, or review scope requires it.
EOF
    ;;
esac
