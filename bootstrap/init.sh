#!/usr/bin/env sh
set -eu

HUB_VERSION="0.1.0"
DRY_RUN=false
GIT_INIT=false
RUNTIME_INPUT=""
TARGET_INPUT=""

usage() {
  cat <<'EOF'
Usage:
  bootstrap/init.sh --runtime codex|claude|codex,claude [--dry-run] [--git-init] /path/to/piper-station-hub

Creates or updates a Piper Station hub directory from generated runtime templates.
Unselected runtime surfaces are left alone. Shared project records under
projects/ are preserved.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --runtime) shift; [ $# -gt 0 ] || { echo "Error: --runtime requires a value" >&2; exit 1; }; RUNTIME_INPUT="$1" ;;
    --dry-run) DRY_RUN=true ;;
    --git-init) GIT_INIT=true ;;
    --force) ;;
    -h|--help) usage; exit 0 ;;
    --) shift; TARGET_INPUT="${1:-}"; break ;;
    -*) echo "Error: unknown option: $1" >&2; usage >&2; exit 1 ;;
    *) if [ -z "$TARGET_INPUT" ]; then TARGET_INPUT="$1"; else echo "Error: unexpected extra argument: $1" >&2; exit 1; fi ;;
  esac
  shift
done

[ -n "$RUNTIME_INPUT" ] || { echo "Error: --runtime is required" >&2; usage >&2; exit 1; }
[ -n "$TARGET_INPUT" ] || { usage >&2; exit 1; }

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
GENERATED="$SOURCE_ROOT/generated"

normalize_runtimes() {
  result=""
  rest="$RUNTIME_INPUT"
  while :; do
    case "$rest" in
      *,*) runtime=${rest%%,*}; rest=${rest#*,} ;;
      *) runtime=$rest; rest="" ;;
    esac
    runtime=$(printf "%s" "$runtime" | sed 's/^ *//; s/ *$//')
    if [ -n "$runtime" ]; then
      case "$runtime" in
        codex|claude)
          case " $result " in *" $runtime "*) ;; *) result="${result}${result:+ }$runtime" ;; esac
          ;;
        *) echo "Error: unsupported runtime: $runtime" >&2; return 1 ;;
      esac
    fi
    [ -n "$rest" ] || break
  done
  printf '%s\n' "$result" | tr ' ' '\n'
}
RUNTIMES=$(normalize_runtimes) || exit 1
[ -n "$RUNTIMES" ] || { echo "Error: --runtime did not name any runtimes" >&2; exit 1; }
for runtime in $RUNTIMES; do [ -d "$GENERATED/$runtime" ] || { echo "Error: missing generated template for runtime '$runtime'" >&2; exit 1; }; done

if [ -e "$TARGET_INPUT" ] && [ ! -d "$TARGET_INPUT" ]; then echo "Error: target exists and is not a directory: $TARGET_INPUT" >&2; exit 1; fi
[ "$DRY_RUN" = true ] || mkdir -p "$TARGET_INPUT"
if [ -d "$TARGET_INPUT" ]; then
  TARGET_DIR=$(CDPATH= cd -- "$TARGET_INPUT" && pwd)
else
  parent=$(dirname -- "$TARGET_INPUT"); base=$(basename -- "$TARGET_INPUT")
  if [ -d "$parent" ]; then parent_abs=$(CDPATH= cd -- "$parent" && pwd); TARGET_DIR="$parent_abs/$base"; else TARGET_DIR="$TARGET_INPUT"; fi
fi
[ "$TARGET_DIR" != "$SOURCE_ROOT" ] || { echo "Error: refusing to initialize the bootstrap source as a hub: $SOURCE_ROOT" >&2; exit 1; }

is_runtime_selected() { printf '%s\n' "$RUNTIMES" | grep -qx -- "$1"; }
rel_runtime() { case "$1" in AGENTS.md|.codex/*|.piper/plugin/*) printf codex ;; CLAUDE.md|.claude/*) printf claude ;; *) printf shared ;; esac; }
is_managed() { case "$1" in projects/*) return 1 ;; *) return 0 ;; esac; }
is_safe_manifest_rel() { case "$1" in ""|/*|../*|*/../*|projects/*) return 1 ;; *) return 0 ;; esac; }

template_files() { for runtime in $RUNTIMES; do (cd "$GENERATED/$runtime" && find . -type f -print | sed 's#^\./##'); done | sort -u; }
template_source() { rel="$1"; for runtime in $RUNTIMES; do [ -f "$GENERATED/$runtime/$rel" ] && { printf '%s\n' "$GENERATED/$runtime/$rel"; return 0; }; done; return 1; }
is_executable_template() { rel="$1"; src=$(template_source "$rel") || return 1; case "$rel" in bin/*|.piper/lib/bootstrap/*.sh|.codex/hooks/*.sh|.claude/hooks/*.sh) return 0 ;; *) [ -x "$src" ] ;; esac; }

nearest_existing_dir() { dir="$1"; while [ ! -d "$dir" ]; do parent=$(dirname -- "$dir"); [ "$parent" != "$dir" ] || return 1; dir="$parent"; done; printf '%s\n' "$dir"; }
is_path_in_git_worktree() { path="$1"; if [ -d "$path" ]; then git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; return $?; fi; parent=$(nearest_existing_dir "$path") || return 1; git -C "$parent" rev-parse --is-inside-work-tree >/dev/null 2>&1; }
initialize_git_repo() { [ "$GIT_INIT" = true ] || return 0; command -v git >/dev/null 2>&1 || { echo "Error: --git-init requires git on PATH" >&2; exit 1; }; if [ "$DRY_RUN" = true ]; then if is_path_in_git_worktree "$TARGET_DIR"; then echo "would preserve git worktree: $TARGET_DIR"; else echo "would initialize git repo: $TARGET_DIR"; fi; elif git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo "preserve git worktree: $TARGET_DIR"; else git -C "$TARGET_DIR" init -q; echo "git init: $TARGET_DIR"; fi; }

previous_managed_files() { manifest="$TARGET_DIR/.piper/hub-manifest.json"; [ -f "$manifest" ] || return 0; awk '/"managed_files"[[:space:]]*:/ { inside = 1; next } inside && /\]/ { exit } inside { line = $0; sub(/^[[:space:]]*"/, "", line); sub(/",[[:space:]]*$/, "", line); sub(/"[[:space:]]*$/, "", line); if (line != "") print line }' "$manifest"; }
remove_empty_parent_dirs() { file="$1"; dir=$(dirname -- "$file"); while [ "$dir" != "$TARGET_DIR" ] && [ "$dir" != "/" ]; do rmdir "$dir" 2>/dev/null || break; dir=$(dirname -- "$dir"); done; }
cleanup_stale_managed_files() { [ -f "$TARGET_DIR/.piper/hub-manifest.json" ] || return 0; current_file="$1"; previous_managed_files | while IFS= read -r rel; do [ -n "$rel" ] || continue; is_safe_manifest_rel "$rel" || continue; rel_rt=$(rel_runtime "$rel"); if [ "$rel_rt" != shared ] && ! is_runtime_selected "$rel_rt"; then continue; fi; grep -qx -- "$rel" "$current_file" && continue; dst="$TARGET_DIR/$rel"; [ -e "$dst" ] || continue; if [ "$DRY_RUN" = true ]; then echo "would remove stale managed hub file: $rel"; elif [ -f "$dst" ]; then rm -f "$dst"; remove_empty_parent_dirs "$dst"; echo "remove stale managed: $rel"; fi; done; }

ensure_parent_dir() { [ "$DRY_RUN" = true ] || mkdir -p "$(dirname -- "$1")"; }
apply_mode() { if is_executable_template "$1"; then chmod 755 "$2"; else chmod 644 "$2"; fi; }
copy_template_file() { rel="$1"; src=$(template_source "$rel") || { echo "Error: missing template source for $rel" >&2; exit 1; }; dst="$TARGET_DIR/$rel"; if is_managed "$rel"; then if [ "$DRY_RUN" = true ]; then [ -e "$dst" ] && echo "would update managed hub file: $rel" || echo "would create managed hub file: $rel"; return; fi; ensure_parent_dir "$dst"; tmp="$dst.tmp.$$"; cp "$src" "$tmp"; apply_mode "$rel" "$tmp"; if [ -e "$dst" ] && cmp -s "$tmp" "$dst"; then rm -f "$tmp"; apply_mode "$rel" "$dst"; echo "preserve managed: $rel"; else mv "$tmp" "$dst"; echo "write managed: $rel"; fi; else if [ "$DRY_RUN" = true ]; then [ -e "$dst" ] && echo "would preserve hub file: $rel" || echo "would create hub file: $rel"; return; fi; ensure_parent_dir "$dst"; if [ -e "$dst" ]; then echo "preserve: $rel"; else cp "$src" "$dst"; apply_mode "$rel" "$dst"; echo "create: $rel"; fi; fi; }

json_list_from_file() { file="$1"; first=true; while IFS= read -r rel; do [ -n "$rel" ] || continue; if [ "$first" = true ]; then first=false; else printf ',\n'; fi; printf '    "%s"' "$rel"; done < "$file"; }
manifest_files() { current_file="$1"; cat "$current_file"; [ -f "$TARGET_DIR/.piper/hub-manifest.json" ] || return 0; previous_managed_files | while IFS= read -r rel; do [ -n "$rel" ] || continue; is_safe_manifest_rel "$rel" || continue; rel_rt=$(rel_runtime "$rel"); if [ "$rel_rt" != shared ] && ! is_runtime_selected "$rel_rt" && [ -e "$TARGET_DIR/$rel" ]; then printf '%s\n' "$rel"; fi; done; }
runtime_file_from_manifest_files() { files="$1"; { if grep -q '^AGENTS.md$\|^\.codex/\|^\.piper/plugin/' "$files"; then printf 'codex\n'; fi; if grep -q '^CLAUDE.md$\|^\.claude/' "$files"; then printf 'claude\n'; fi; } | sort -u; }
write_manifest() { current_file="$1"; manifest="$TARGET_DIR/.piper/hub-manifest.json"; if [ "$DRY_RUN" = true ]; then [ -e "$manifest" ] && echo "would update managed hub file: .piper/hub-manifest.json" || echo "would write: .piper/hub-manifest.json"; return; fi; mkdir -p "$TARGET_DIR/.piper"; all="$TARGET_DIR/.piper/hub-manifest.files.$$"; managed="$TARGET_DIR/.piper/hub-manifest.managed.$$"; runtimes="$TARGET_DIR/.piper/hub-manifest.runtimes.$$"; tmp="$manifest.tmp.$$"; manifest_files "$current_file" | sort -u > "$all"; while IFS= read -r rel; do [ -n "$rel" ] && is_managed "$rel" && printf '%s\n' "$rel"; done < "$all" | sort -u > "$managed"; runtime_file_from_manifest_files "$all" > "$runtimes"; installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ"); { printf '{\n'; printf '  "hub_version": "%s",\n' "$HUB_VERSION"; printf '  "installed_at": "%s",\n' "$installed_at"; printf '  "runtimes": [\n'; json_list_from_file "$runtimes"; printf '\n  ],\n'; printf '  "file_mode": "managed-outside-projects",\n'; printf '  "files": [\n'; json_list_from_file "$all"; printf '\n  ],\n'; printf '  "managed_files": [\n'; json_list_from_file "$managed"; printf '\n  ]\n'; printf '}\n'; } > "$tmp"; mv "$tmp" "$manifest"; chmod 644 "$manifest"; rm -f "$all" "$managed" "$runtimes"; echo "write managed: .piper/hub-manifest.json"; }

if [ "$DRY_RUN" = true ]; then current_files_tmp="${TMPDIR:-/tmp}/piper-current-files.$$"; else mkdir -p "$TARGET_DIR/.piper"; current_files_tmp="$TARGET_DIR/.piper/current-files.$$"; fi
trap 'rm -f "$current_files_tmp"' EXIT HUP INT TERM
template_files > "$current_files_tmp"
echo "Initializing Piper Station hub at $TARGET_DIR for runtimes: $(printf '%s' "$RUNTIMES" | tr '\n' ',' | sed 's/,$//')"
initialize_git_repo
cleanup_stale_managed_files "$current_files_tmp"
template_files | while IFS= read -r rel; do [ -n "$rel" ] && copy_template_file "$rel"; done
write_manifest "$current_files_tmp"
echo "Done."
