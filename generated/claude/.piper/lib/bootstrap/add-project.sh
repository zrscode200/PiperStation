#!/usr/bin/env sh
set -eu

DRY_RUN=false
WRITE_REPO_MARKERS=true
HUB_INPUT=""
REPO_INPUT=""
PROJECT_ID=""
DISPLAY_NAME=""

usage() {
  cat <<'EOF'
Usage:
  bootstrap/add-project.sh --hub /path/to/hub --repo /path/to/repo [--project-id ID] [--display-name NAME] [--hub-only] [--dry-run]

Registers an existing git repo with a Piper Station hub-lite directory.

Options:
  --hub PATH          Piper Station hub directory.
  --repo PATH         Existing project repository directory.
  --project-id ID     Stable project id. Defaults from repo basename.
  --display-name NAME Human-readable project name. Defaults to project id.
  --hub-only          Only update hub records; do not write repo markers.
  --dry-run           Print intended actions without writing files.
  -h, --help          Show help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --hub)
      shift
      [ $# -gt 0 ] || { echo "Error: --hub requires a value" >&2; exit 1; }
      HUB_INPUT="$1"
      ;;
    --repo)
      shift
      [ $# -gt 0 ] || { echo "Error: --repo requires a value" >&2; exit 1; }
      REPO_INPUT="$1"
      ;;
    --project-id)
      shift
      [ $# -gt 0 ] || { echo "Error: --project-id requires a value" >&2; exit 1; }
      PROJECT_ID="$1"
      ;;
    --display-name)
      shift
      [ $# -gt 0 ] || { echo "Error: --display-name requires a value" >&2; exit 1; }
      DISPLAY_NAME="$1"
      ;;
    --hub-only)
      WRITE_REPO_MARKERS=false
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ -z "$HUB_INPUT" ] || [ -z "$REPO_INPUT" ]; then
  usage >&2
  exit 1
fi

if [ ! -d "$HUB_INPUT" ]; then
  echo "Error: hub directory does not exist: $HUB_INPUT" >&2
  exit 1
fi

if [ ! -d "$REPO_INPUT" ]; then
  echo "Error: project repo directory does not exist: $REPO_INPUT" >&2
  exit 1
fi

HUB_DIR=$(CDPATH= cd -- "$HUB_INPUT" && pwd -P)

if [ ! -f "$HUB_DIR/STATION.md" ] || [ ! -d "$HUB_DIR/projects" ]; then
  echo "Error: not a Piper Station hub-lite directory: $HUB_DIR" >&2
  exit 1
fi

if ! repo_root=$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null); then
  echo "Error: project repo must be a git worktree: $REPO_INPUT" >&2
  exit 1
fi

PROJECT_REPO=$(CDPATH= cd -- "$repo_root" && pwd -P)

if [ "$PROJECT_REPO" = "$HUB_DIR" ]; then
  echo "Error: refusing to register the hub directory as a project" >&2
  exit 1
fi

slugify() {
  printf "%s" "$1" |
    tr '[:upper:]' '[:lower:]' |
    sed 's/[^abcdefghijklmnopqrstuvwxyz0123456789._-]/-/g; s/--*/-/g; s/^-//; s/-$//'
}

if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(slugify "$(basename "$PROJECT_REPO")")
fi

if [ -z "$PROJECT_ID" ]; then
  echo "Error: could not derive a project id; pass --project-id" >&2
  exit 1
fi

case "$PROJECT_ID" in
  *[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-]*|"")
    echo "Error: project id may contain only letters, numbers, dots, underscores, and hyphens: $PROJECT_ID" >&2
    exit 1
    ;;
esac

case "$PROJECT_ID" in
  "."|".."|.*)
    echo "Error: project id must not be '.', '..', or start with a dot: $PROJECT_ID" >&2
    exit 1
    ;;
esac

DISPLAY_NAME="${DISPLAY_NAME:-$PROJECT_ID}"
PROJECT_DIR="$HUB_DIR/projects/$PROJECT_ID"
PROJECT_MD="$PROJECT_DIR/project.md"
MEMORY_MD="$PROJECT_DIR/memory.md"
DECISIONS_MD="$PROJECT_DIR/decisions.md"

branch=$(git -C "$PROJECT_REPO" symbolic-ref --short HEAD 2>/dev/null || printf "unknown")
head=$(git -C "$PROJECT_REPO" rev-parse --short HEAD 2>/dev/null || printf "unborn")
remote=$(git -C "$PROJECT_REPO" config --get remote.origin.url 2>/dev/null || printf "none")
registered_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

validate_display_name() {
  line_count=$(printf "%s" "$DISPLAY_NAME" | wc -l | tr -d ' ')
  if [ "$line_count" != "0" ]; then
    echo "Error: display name must not contain newlines or control characters" >&2
    exit 1
  fi

  if printf "%s" "$DISPLAY_NAME" | LC_ALL=C grep '[[:cntrl:]]' >/dev/null 2>&1; then
    echo "Error: display name must not contain newlines or control characters" >&2
    exit 1
  fi
}

ensure_parent_dir() {
  dst="$1"
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$(dirname "$dst")"
  fi
}

json_escape() {
  printf "%s" "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_field() {
  file="$1"
  key="$2"

  if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required to validate existing repo markers" >&2
    exit 1
  fi

  python3 -c 'import json, sys
with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)
value = data.get(sys.argv[2], "")
if value is None:
    value = ""
sys.stdout.write(str(value))
' "$file" "$key"
}

project_repo_path() {
  file="$1"
  if [ -f "$file" ]; then
    awk '
      /^[[:space:]]*- Path: `/ {
        sub("^[[:space:]]*- Path: `", "")
        sub("`[[:space:]]*$", "")
        print
        exit
      }
    ' "$file"
  fi
}

normalize_existing_path() {
  path="$1"
  if [ -d "$path" ]; then
    normalized=$(CDPATH= cd -- "$path" && pwd -P)
    printf "%s" "$normalized"
  else
    printf "%s" "$path"
  fi
}

validate_existing_project() {
  if [ -e "$PROJECT_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: hub project '$PROJECT_ID' already exists and is not a directory: $PROJECT_DIR" >&2
    exit 1
  fi

  if [ -d "$PROJECT_DIR" ]; then
    if [ ! -f "$PROJECT_MD" ]; then
      echo "Error: hub project '$PROJECT_ID' already exists but is missing project.md" >&2
      exit 1
    fi

    existing_repo_path=$(project_repo_path "$PROJECT_MD")
    if [ -z "$existing_repo_path" ]; then
      echo "Error: hub project '$PROJECT_ID' already exists but project.md has no registry path" >&2
      exit 1
    fi

    existing_repo_path=$(normalize_existing_path "$existing_repo_path")
    if [ "$existing_repo_path" != "$PROJECT_REPO" ]; then
      echo "Error: hub project '$PROJECT_ID' already points at repo '$existing_repo_path', not '$PROJECT_REPO'" >&2
      exit 1
    fi
  fi
}

validate_existing_repo_marker() {
  marker="$PROJECT_REPO/.piper/project.json"
  if [ -f "$marker" ]; then
    if ! existing_project_id=$(json_field "$marker" "project_id"); then
      echo "Error: invalid JSON in repo marker: $marker" >&2
      exit 1
    fi
    if [ "$existing_project_id" != "$PROJECT_ID" ]; then
      echo "Error: repo is already marked as project id '$existing_project_id', not '$PROJECT_ID'" >&2
      exit 1
    fi
  fi
}

project_registry_block() {
  cat <<EOF
<!-- piper-project:start -->
- Project ID: \`$PROJECT_ID\`
- Display name: $DISPLAY_NAME
- Path: \`$PROJECT_REPO\`
- Remote: \`$remote\`
- Branch: \`$branch\`
- HEAD: \`$head\`
- Registered at: \`$registered_at\`
<!-- piper-project:end -->
EOF
}

write_project_md() {
  if [ "$DRY_RUN" = true ]; then
    if [ -f "$PROJECT_MD" ]; then
      echo "would update: projects/$PROJECT_ID/project.md"
    else
      echo "would create: projects/$PROJECT_ID/project.md"
    fi
    return
  fi

  ensure_parent_dir "$PROJECT_MD"
  tmp="$PROJECT_MD.tmp.$$"
  block="$PROJECT_MD.block.$$"
  project_registry_block > "$block"

  if [ ! -f "$PROJECT_MD" ]; then
    {
      printf '# %s\n\n' "$DISPLAY_NAME"
      printf '## Registry\n\n'
      cat "$block"
      printf '\n## Purpose\n\nTBD\n\n'
      printf '## Working Notes\n\n'
      printf -- '- Keep durable project context in this folder.\n'
      printf -- '- Keep implementation work in the repo path above.\n'
    } > "$tmp"
    mv "$tmp" "$PROJECT_MD"
    rm -f "$block"
    echo "create: projects/$PROJECT_ID/project.md"
    return
  fi

  start_count=$(grep -c '<!-- piper-project:start -->' "$PROJECT_MD" || true)
  end_count=$(grep -c '<!-- piper-project:end -->' "$PROJECT_MD" || true)

  if [ "$start_count" -ne "$end_count" ]; then
    rm -f "$tmp" "$block"
    echo "Error: malformed piper project markers in $PROJECT_MD" >&2
    exit 1
  fi

  if [ "$start_count" -eq 0 ]; then
    {
      cat "$PROJECT_MD"
      printf '\n\n## Registry\n\n'
      cat "$block"
    } > "$tmp"
  else
    python3 - "$PROJECT_MD" "$block" "$tmp" <<'PY'
import sys
source_path, block_path, target_path = sys.argv[1:]
source = open(source_path, encoding="utf-8").read().splitlines()
block = open(block_path, encoding="utf-8").read().splitlines()
out = []
inside = False
for line in source:
    if line.strip() == "<!-- piper-project:start -->":
        out.extend(block)
        inside = True
        continue
    if line.strip() == "<!-- piper-project:end -->":
        inside = False
        continue
    if not inside:
        out.append(line)
with open(target_path, "w", encoding="utf-8") as fh:
    fh.write("\n".join(out).rstrip() + "\n")
PY
  fi

  mv "$tmp" "$PROJECT_MD"
  rm -f "$block"
  echo "update: projects/$PROJECT_ID/project.md"
}

write_if_missing() {
  rel="$1"
  dst="$2"
  content="$3"

  if [ "$DRY_RUN" = true ]; then
    if [ -f "$dst" ]; then
      echo "would preserve: $rel"
    else
      echo "would create: $rel"
    fi
    return
  fi

  ensure_parent_dir "$dst"
  if [ -f "$dst" ]; then
    echo "preserve: $rel"
  else
    printf "%s\n" "$content" > "$dst"
    echo "create: $rel"
  fi
}

memory_md() {
  cat <<EOF
# $DISPLAY_NAME Memory

Durable facts and preferences for this project. Keep this concise and update it
only when future work would benefit from the context.

## Project Facts

- TBD

## User Preferences

- TBD

## Reusable Context

- TBD
EOF
}

decisions_md() {
  cat <<EOF
# $DISPLAY_NAME Decisions

Meaningful project decisions that future work should not reopen silently.

## Entries

- TBD
EOF
}

project_json() {
  escaped_project_id=$(json_escape "$PROJECT_ID")
  escaped_display_name=$(json_escape "$DISPLAY_NAME")
  cat <<EOF
{
  "schema_version": 1,
  "project_id": "$escaped_project_id",
  "display_name": "$escaped_display_name",
  "hub_lite": true,
  "runtime": "claude-code"
}
EOF
}

piper_md() {
  cat <<EOF
# Piper Station

This repository is registered with a Piper Station hub-lite workspace.

- Project ID: \`$PROJECT_ID\`
- Source ownership: this repo owns source code and repo-local docs.
- Hub ownership: the hub owns lightweight project context under
  \`projects/$PROJECT_ID/\`.

Use the hub for agent launch and durable cross-project context. Do not copy hub
runtime files into this repo.
EOF
}

echo "Registering project '$PROJECT_ID' in hub $HUB_DIR"

validate_display_name
validate_existing_project
validate_existing_repo_marker

write_project_md
write_if_missing "projects/$PROJECT_ID/memory.md" "$MEMORY_MD" "$(memory_md)"
write_if_missing "projects/$PROJECT_ID/decisions.md" "$DECISIONS_MD" "$(decisions_md)"

if [ "$WRITE_REPO_MARKERS" = true ]; then
  write_if_missing ".piper/project.json" "$PROJECT_REPO/.piper/project.json" "$(project_json)"
  write_if_missing "PIPER.md" "$PROJECT_REPO/PIPER.md" "$(piper_md)"
else
  echo "skip repo markers: --hub-only"
fi

echo "Done."
