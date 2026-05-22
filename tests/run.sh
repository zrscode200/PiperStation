#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BOOTSTRAP="$ROOT/bootstrap/init.sh"
ADD_PROJECT="$ROOT/bootstrap/add-project.sh"
TMP_ROOT="${TMPDIR:-/tmp}/piper-unified-test-$$"
mkdir -p "$TMP_ROOT"

fail() { echo "FAIL: $1" >&2; exit 1; }
assert_file() { [ -f "$1" ] || fail "missing file: $1"; }
assert_dir() { [ -d "$1" ] || fail "missing directory: $1"; }
assert_not_exists() { [ ! -e "$1" ] || fail "unexpected path exists: $1"; }
assert_contains() { grep -q -- "$2" "$1" || fail "expected '$2' in $1"; }
assert_not_contains() { if grep -q -- "$2" "$1"; then fail "did not expect '$2' in $1"; fi; }
init_git_repo() { git -C "$1" init -q; git -C "$1" config user.name "Piper Unified Tests"; git -C "$1" config user.email "tests@example.invalid"; }

echo "test root: $TMP_ROOT"
sh -n "$BOOTSTRAP"
sh -n "$ADD_PROJECT"
sh -n "$ROOT/scripts/render-templates.sh"
python3 "$ROOT/scripts/render_templates.py" --check >/dev/null
python3 -m json.tool "$ROOT/generated/codex/.codex/hooks.json" >/dev/null
python3 -m json.tool "$ROOT/generated/codex/.piper/plugin/.codex-plugin/plugin.json" >/dev/null
python3 -m json.tool "$ROOT/generated/claude/.claude/settings.json" >/dev/null

codex_hub="$TMP_ROOT/codex-hub"
"$BOOTSTRAP" --runtime codex "$codex_hub" > "$TMP_ROOT/codex.log"
assert_file "$codex_hub/AGENTS.md"
assert_file "$codex_hub/.codex/config.toml"
assert_file "$codex_hub/.piper/plugin/commands/ralph.md"
assert_file "$codex_hub/.piper/plugin/skills/ralph-loop/SKILL.md"
assert_not_exists "$codex_hub/CLAUDE.md"
assert_not_exists "$codex_hub/.claude"
assert_contains "$codex_hub/.piper/hub-manifest.json" '"codex"'
assert_not_contains "$codex_hub/.piper/hub-manifest.json" '"claude"'
python3 -m json.tool "$codex_hub/.piper/hub-manifest.json" >/dev/null

claude_hub="$TMP_ROOT/claude-hub"
"$BOOTSTRAP" --runtime claude "$claude_hub" > "$TMP_ROOT/claude.log"
assert_file "$claude_hub/CLAUDE.md"
assert_file "$claude_hub/.claude/settings.json"
assert_file "$claude_hub/.claude/commands/ralph.md"
assert_file "$claude_hub/.claude/skills/ralph-loop/SKILL.md"
assert_not_exists "$claude_hub/AGENTS.md"
assert_not_exists "$claude_hub/.codex"
assert_not_exists "$claude_hub/.piper/plugin"
assert_contains "$claude_hub/.piper/hub-manifest.json" '"claude"'
python3 -m json.tool "$claude_hub/.piper/hub-manifest.json" >/dev/null

both_hub="$TMP_ROOT/both-hub"
"$BOOTSTRAP" --runtime codex,claude "$both_hub" > "$TMP_ROOT/both.log"
assert_file "$both_hub/AGENTS.md"
assert_file "$both_hub/CLAUDE.md"
assert_file "$both_hub/.codex/config.toml"
assert_file "$both_hub/.claude/settings.json"
assert_contains "$both_hub/STATION.md" "A hub may have both surfaces installed"
assert_contains "$both_hub/.piper/hub-manifest.json" '"codex"'
assert_contains "$both_hub/.piper/hub-manifest.json" '"claude"'

printf 'local note
' > "$both_hub/projects/README.md"
"$BOOTSTRAP" --runtime codex,claude "$both_hub" > "$TMP_ROOT/refresh.log"
assert_contains "$both_hub/projects/README.md" "local note"
"$BOOTSTRAP" --runtime codex "$both_hub" > "$TMP_ROOT/codex-refresh.log"
assert_file "$both_hub/.claude/settings.json"
assert_contains "$both_hub/.piper/hub-manifest.json" '"claude"'

mkdir -p "$both_hub/.claude/hooks" "$both_hub/.codex/hooks"
printf 'old claude
' > "$both_hub/.claude/hooks/old-managed.sh"
printf 'old codex
' > "$both_hub/.codex/hooks/old-managed.sh"
{
  printf '{
'
  printf '  "managed_files": [
'
  printf '    ".claude/hooks/old-managed.sh",
'
  printf '    ".codex/hooks/old-managed.sh"
'
  printf '  ]
'
  printf '}
'
} > "$both_hub/.piper/hub-manifest.json"
"$BOOTSTRAP" --runtime codex "$both_hub" > "$TMP_ROOT/stale-codex.log"
assert_file "$both_hub/.claude/hooks/old-managed.sh"
assert_not_exists "$both_hub/.codex/hooks/old-managed.sh"
"$BOOTSTRAP" --runtime claude "$both_hub" > "$TMP_ROOT/stale-claude.log"
assert_not_exists "$both_hub/.claude/hooks/old-managed.sh"

project_repo="$TMP_ROOT/project-repo"
mkdir -p "$project_repo"
init_git_repo "$project_repo"
(cd "$project_repo" && printf 'sample
' > README.md && git add README.md && git commit -m "Initial sample" >/dev/null)
"$ADD_PROJECT" --hub "$both_hub" --repo "$project_repo" --project-id sample-project --display-name "Sample Project" > "$TMP_ROOT/add-project.log"
assert_file "$both_hub/projects/sample-project/project.md"
assert_file "$both_hub/projects/sample-project/memory.md"
assert_file "$both_hub/projects/sample-project/decisions.md"
assert_not_exists "$both_hub/projects/sample-project/work"
assert_file "$project_repo/.piper/project.json"
assert_file "$project_repo/PIPER.md"
python3 -m json.tool "$project_repo/.piper/project.json" >/dev/null

hub_only_repo="$TMP_ROOT/hub-only-repo"
mkdir -p "$hub_only_repo"
init_git_repo "$hub_only_repo"
(cd "$both_hub" && ./bin/add-project --repo "$hub_only_repo" --project-id hub-only --hub-only) > "$TMP_ROOT/hub-only.log"
assert_file "$both_hub/projects/hub-only/project.md"
assert_not_exists "$both_hub/projects/hub-only/work"
assert_not_exists "$hub_only_repo/.piper/project.json"

"$BOOTSTRAP" --runtime codex --dry-run "$TMP_ROOT/dry-new" > "$TMP_ROOT/dry.log"
assert_contains "$TMP_ROOT/dry.log" "would create managed hub file: STATION.md"
assert_not_exists "$TMP_ROOT/dry-new"

git_hub="$TMP_ROOT/git-hub"
"$BOOTSTRAP" --runtime claude --git-init "$git_hub" > "$TMP_ROOT/git-init.log"
assert_dir "$git_hub/.git"

if "$BOOTSTRAP" --runtime codex "$ROOT" > "$TMP_ROOT/source-refuse.log" 2>&1; then fail "bootstrap should refuse source repo"; fi
assert_contains "$TMP_ROOT/source-refuse.log" "refusing to initialize the bootstrap source"

git -C "$ROOT" diff --check

echo "All tests passed."
