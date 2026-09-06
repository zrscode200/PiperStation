#!/usr/bin/env sh
set -eu

HUB_VERSION="0.2.0"
DRY_RUN=false
GIT_INIT=false
TARGET_INPUT=""

usage() {
  cat <<'USAGE'
Usage:
  bootstrap/init.sh [--runtime codex] [--dry-run] [--git-init] /path/to/piper-station-hub

Creates or updates a Codex Piper Station hub. The optional --runtime codex
argument is retained for existing callers. Other runtimes are not supported
on this branch. Generated files outside projects/ are managed; hub-owned
project records are preserved. Existing mixed-runtime hubs require migration
before this installer can update them. See docs/capability-matrix.md.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --runtime)
      shift
      [ $# -gt 0 ] || { echo "Error: --runtime requires a value" >&2; exit 1; }
      [ "$1" = codex ] || { echo "Error: unsupported runtime: $1; this branch supports codex only" >&2; exit 1; }
      ;;
    --dry-run) DRY_RUN=true ;;
    --git-init) GIT_INIT=true ;;
    --force) ;; # Legacy no-op; never bypasses ownership or migration checks.
    -h|--help) usage; exit 0 ;;
    --)
      shift
      [ $# -eq 1 ] && [ -z "$TARGET_INPUT" ] || { usage >&2; exit 1; }
      TARGET_INPUT="$1"
      break
      ;;
    -*) echo "Error: unknown option: $1" >&2; usage >&2; exit 1 ;;
    *)
      [ -z "$TARGET_INPUT" ] || { echo "Error: unexpected extra argument: $1" >&2; exit 1; }
      TARGET_INPUT="$1"
      ;;
  esac
  shift
done
[ -n "$TARGET_INPUT" ] || { usage >&2; exit 1; }

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SOURCE_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
TEMPLATE="$SOURCE_ROOT/generated/codex"
[ -d "$TEMPLATE" ] || { echo "Error: missing generated Codex template" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "Error: bootstrap requires python3 for manifest validation" >&2; exit 1; }
TARGET_DIR=$(python3 - "$TARGET_INPUT" "$SOURCE_ROOT" <<'PY'
import os, sys
target, source = os.path.realpath(sys.argv[1]), sys.argv[2]
if target == source or (os.path.exists(target) and os.path.samefile(target, source)):
    sys.exit(f"Error: refusing to initialize the bootstrap source as a hub: {source}")
print(target)
PY
)
[ ! -e "$TARGET_DIR" ] || [ -d "$TARGET_DIR" ] || { echo "Error: target exists and is not a directory: $TARGET_DIR" >&2; exit 1; }

# Validate every existing manifest and destination before the first write. The
# older mixed-runtime installer preserved unselected surfaces; silently doing
# that here would leave incompatible instructions alongside a new Codex core.
python3 - "$TARGET_DIR" "$TEMPLATE" <<'PY'
import json
import sys
from pathlib import Path, PurePosixPath

hub, template = map(Path, sys.argv[1:])
retired = (".claude", "CLAUDE.md", ".opencode", "opencode.json", ".deepagents")
manifest = hub / ".piper/hub-manifest.json"
if (hub / ".piper").is_symlink() or manifest.is_symlink():
    sys.exit("Error: managed manifest uses a symlink; no hub files changed")
try:
    data = json.loads(manifest.read_text()) if manifest.exists() else {}
    if not isinstance(data, dict):
        raise ValueError("expected an object")
    runtimes = data.get("runtimes", [])
    managed = data.get("managed_files", [])
    if not isinstance(runtimes, list) or not all(isinstance(x, str) for x in runtimes):
        raise ValueError("runtimes must be a list of names")
    if not isinstance(managed, list) or not all(isinstance(x, str) for x in managed):
        raise ValueError("managed_files must be a list of paths")
except (OSError, ValueError) as exc:
    sys.exit(f"Error: invalid existing hub manifest: {exc}; no hub files changed")
legacy = any((hub / item).exists() or (hub / item).is_symlink() for item in retired)
legacy = legacy or any(runtime != "codex" for runtime in runtimes)
legacy = legacy or any(path == item or path.startswith(item + "/") for path in managed for item in retired)
if legacy:
    sys.exit("Error: existing hub contains retired runtime surfaces; no hub files changed. "
             "Create a separate Codex hub or migrate the existing hub explicitly. "
             "See docs/capability-matrix.md; --force does not bypass this check.")
for rel in managed:
    path = PurePosixPath(rel)
    if (not rel or path.is_absolute() or ".." in path.parts or "\\" in rel
            or any(ord(char) < 32 or ord(char) == 127 for char in rel)):
        sys.exit(f"Error: unsafe managed manifest path: {rel!r}; no hub files changed")
    # These identities must stay reserved on case-insensitive filesystems too.
    parts = tuple(part.casefold() for part in path.parts)
    if ".git" in parts or parts[:2] == (".piper", "locks"):
        sys.exit(f"Error: reserved operational path in managed manifest: {rel!r}; no hub files changed")
# Reject symlinked destinations and parent components instead of following them
# outside the hub. Also catch file/directory collisions before partial refresh.
paths = {str(p.relative_to(template)) for p in template.rglob("*") if p.is_file()}
paths.update(managed)
paths.add(".piper/hub-manifest.json")
for rel in paths:
    dest = hub / rel
    for component in [dest, *dest.parents]:
        if component == hub:
            break
        if component.is_symlink():
            sys.exit(f"Error: managed destination uses a symlink: {component}; no hub files changed")
        if component != dest and component.exists() and not component.is_dir():
            sys.exit(f"Error: managed parent is not a directory: {component}; no hub files changed")
    if dest.exists() and not dest.is_file():
        sys.exit(f"Error: managed destination is not a file: {dest}; no hub files changed")
PY

is_managed() { case "$1" in projects/*) return 1 ;; *) return 0 ;; esac; }
template_files() { (cd "$TEMPLATE" && find . -type f -print | sed 's#^\./##') | sort; }
previous_managed_files() {
  python3 - "$TARGET_DIR/.piper/hub-manifest.json" <<'PY'
import json, sys
from pathlib import Path, PurePosixPath
path = Path(sys.argv[1])
if path.exists():
    for rel in json.loads(path.read_text()).get("managed_files", []):
        parts = PurePosixPath(rel).parts
        if not parts or parts[0].casefold() != "projects":
            print(rel)
PY
}

initialize_git_repo() {
  [ "$GIT_INIT" = true ] || return 0
  command -v git >/dev/null 2>&1 || { echo "Error: --git-init requires git on PATH" >&2; exit 1; }
  toplevel=$(git -C "$TARGET_DIR" rev-parse --show-toplevel 2>/dev/null || true)
  if [ -n "$toplevel" ] && [ -d "$toplevel" ]; then
    toplevel=$(CDPATH= cd -- "$toplevel" && pwd -P)
  fi
  if [ "$toplevel" = "$TARGET_DIR" ]; then
    echo "preserve git worktree: $TARGET_DIR"
  elif [ "$DRY_RUN" = true ]; then
    echo "would initialize git repo: $TARGET_DIR"
  else
    # --git-init requests the hub's own Git root, even below an enclosing repo.
    # Record checkpoint commits must never mutate the parent repository.
    git -C "$TARGET_DIR" init -q
    echo "git init: $TARGET_DIR"
  fi
}
remove_empty_parent_dirs() {
  dir=$(dirname -- "$1")
  while [ "$dir" != "$TARGET_DIR" ] && [ "$dir" != / ]; do
    rmdir "$dir" 2>/dev/null || break
    dir=$(dirname -- "$dir")
  done
}
cleanup_stale_managed_files() {
  previous_managed_files | while IFS= read -r rel; do
    [ ! -f "$TEMPLATE/$rel" ] || continue
    dst="$TARGET_DIR/$rel"
    [ -f "$dst" ] || continue
    if [ "$DRY_RUN" = true ]; then
      echo "would remove stale managed hub file: $rel"
    else
      rm -f "$dst"
      remove_empty_parent_dirs "$dst"
      echo "remove stale managed: $rel"
    fi
  done
}
apply_mode() {
  if [ -x "$TEMPLATE/$1" ]; then chmod 755 "$2"; else chmod 644 "$2"; fi
}
copy_template_file() {
  rel="$1"; src="$TEMPLATE/$rel"; dst="$TARGET_DIR/$rel"
  if ! is_managed "$rel" && [ -e "$dst" ]; then
    echo "preserve hub file: $rel"
    return
  fi
  if [ "$DRY_RUN" = true ]; then
    [ -e "$dst" ] && echo "would update managed hub file: $rel" || echo "would create managed hub file: $rel"
    return
  fi
  mkdir -p "$(dirname -- "$dst")"
  tmp="$dst.tmp.$$"
  cp "$src" "$tmp"
  apply_mode "$rel" "$tmp"
  if [ -f "$dst" ] && cmp -s "$tmp" "$dst"; then
    rm -f "$tmp"
    apply_mode "$rel" "$dst"
    echo "preserve managed: $rel"
  else
    mv "$tmp" "$dst"
    echo "write managed: $rel"
  fi
}
write_manifest() {
  if [ "$DRY_RUN" = true ]; then
    echo "would update managed hub file: .piper/hub-manifest.json"
    return
  fi
  python3 - "$TARGET_DIR" "$TEMPLATE" "$HUB_VERSION" <<'PY'
import datetime, json, os, sys
from pathlib import Path
hub, template = map(Path, sys.argv[1:3])
files = sorted(str(p.relative_to(template)) for p in template.rglob("*") if p.is_file())
data = {
    "hub_version": sys.argv[3],
    "installed_at": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "runtimes": ["codex"],
    "file_mode": "managed-outside-projects",
    "files": files,
    "managed_files": [p for p in files if not p.startswith("projects/")],
}
manifest = hub / ".piper/hub-manifest.json"
manifest.parent.mkdir(parents=True, exist_ok=True)
tmp = manifest.with_name(f"{manifest.name}.tmp.{os.getpid()}")
tmp.write_text(json.dumps(data, indent=2) + "\n")
tmp.chmod(0o644)
tmp.replace(manifest)
PY
  echo "write managed: .piper/hub-manifest.json"
}

if [ "$GIT_INIT" = true ]; then
  command -v git >/dev/null 2>&1 || { echo "Error: --git-init requires git on PATH" >&2; exit 1; }
fi
[ "$DRY_RUN" = true ] || mkdir -p "$TARGET_DIR"
echo "Initializing Piper Station Codex hub at $TARGET_DIR"
initialize_git_repo
cleanup_stale_managed_files
template_files | while IFS= read -r rel; do copy_template_file "$rel"; done
write_manifest
echo "Done."
