#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

if [ -t 0 ]; then
  input=""
else
  input=$(cat 2>/dev/null || true)
fi

source=$(printf "%s" "$input" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
source="${source:-startup}"

projects_count=0
projects_list=""
lanes_list=""
if [ -d "$ROOT/projects" ]; then
  projects_count=$(find "$ROOT/projects" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  if [ "$projects_count" -gt 0 ]; then
    projects_list=$(find "$ROOT/projects" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed 's#.*/##' | sort | sed 's/^/- /')
  fi
  lanes_list=$(find "$ROOT/projects" -mindepth 4 -maxdepth 4 -path '*/work/groups/*' -type d 2>/dev/null | sed "s#^$ROOT/projects/##" | sort | sed 's/^/- /')
fi

base_context="Piper Station hub-lite is active.
Register repos with ./bin/add-project. Durable hub context stays under projects/<project-id>/; optional active work continuity may live under projects/<project-id>/work/ (the flat lane) and, one lane per group, under projects/<project-id>/work/groups/<gid>/. Select one lane per session; ask when more than one is active.
Natural-language project work enters through the brainstorm skill (\$brainstorm ...) to orient, explore, and decide what is worth doing; it routes to piper-workflow (\$piper-workflow ...) for formal planning and Ralph execution once direction is set. Detailed procedures live under .codex/skills/brainstorm/references/ and .codex/skills/piper-workflow/references/."

resume_context="
Resume guidance: start from the selected lane's context-pack.md (projects/<id>/work/ for the flat lane, projects/<id>/work/groups/<gid>/ for a group lane) when present, verify branch/HEAD/git status in the lane's checkout (repo_path or its recorded worktree), rebuild the active boundary neighborhood from named files, changed files, relevant tests, configs, docs, generated surfaces, and known reference paths. Expand beyond that only for concrete triggers such as a stale resume packet, missing acceptance criteria, failing verification, generated parity, security/permissions behavior, or review scope."

if [ "$projects_count" -gt 0 ]; then
  projects_block="

Registered projects: $projects_count
$projects_list"
else
  projects_block="

No registered projects yet. Use ./bin/add-project --repo /path/to/repo to register."
fi
if [ -n "$lanes_list" ]; then
  projects_block="$projects_block

Group lanes (projects/<id>/work/groups/<gid>):
$lanes_list"
fi

additional_context="$base_context"
case "$source" in
  resume|compact) additional_context="${additional_context}${resume_context}" ;;
esac
additional_context="${additional_context}${projects_block}"

system_message="Piper Station hub-lite ready (source=$source, projects=$projects_count)."

PIPER_ADDITIONAL_CONTEXT="$additional_context" \
PIPER_SYSTEM_MESSAGE="$system_message" \
python3 -c '
import json, os, sys
json.dump({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": os.environ.get("PIPER_ADDITIONAL_CONTEXT", ""),
    },
    "systemMessage": os.environ.get("PIPER_SYSTEM_MESSAGE", ""),
}, sys.stdout)
sys.stdout.write("\n")
'
