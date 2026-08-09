#!/usr/bin/env sh
set -eu

# SessionStart hook (client-side; cwd is the hub launch directory). Plain
# stdout is injected as model-visible context for the next turn.

if [ -t 0 ]; then
  input=""
else
  input=$(cat 2>/dev/null || true)
fi
source=$(printf "%s" "$input" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
source="${source:-startup}"

hub_dir=$(pwd -P)

printf 'Piper Station Deep Agents hub-lite is active.\n'
printf 'This hub directory is the launch point. .deepagents/AGENTS.md is the always-on operating contract; read STATION.md before changing registered project repos.\n'

# Git-root self-check: without a git toplevel at the hub itself, Deep Agents
# finds no project root here and silently skips the hub instruction, skill,
# and subagent surfaces (or roots them at an outer repository).
git_top=$(git rev-parse --show-toplevel 2>/dev/null || printf '')
if [ "$git_top" != "$hub_dir" ]; then
  printf 'WARNING: Piper hub surfaces are disabled or mis-rooted. This hub is not a git repository root (detected toplevel: %s). Run git init in the hub, or bootstrap with --git-init, then start a new thread.\n' "${git_top:-none}"
fi

project_count=0
if [ -d "$hub_dir/projects" ]; then
  project_count=$(
    find "$hub_dir/projects" -mindepth 2 -maxdepth 2 -name project.md -type f 2>/dev/null |
      wc -l |
      tr -d ' '
  )
fi

if [ "$project_count" = "0" ]; then
  printf 'No registered projects yet. Use ./bin/add-project --repo /path/to/repo to register one.\n'
else
  printf 'Registered projects: %s. Load the relevant projects/<id>/ record before work.\n' "$project_count"
fi

case "$source" in
  resume|compact)
    cat <<'EOF'

Resume guidance:
- Reload projects/<id>/project.md, memory.md, optional decisions.md, and work/context-pack.md when present.
- Check work/active-work.md, work/build-log.md, optional work/task-queue.md, and work/roadmap.md when relevant.
- Verify live branch, HEAD, and git status in the real project repo (absolute paths) before editing.
- Hub instructions and skill listings in a resumed thread reflect thread start, not the current files; start a new thread after hub changes.
- Expand beyond the packet when the resume state is stale, acceptance criteria are missing, verification is failing, generated parity is unclear, security or permissions behavior is involved, or review scope requires it.
EOF
    ;;
esac
