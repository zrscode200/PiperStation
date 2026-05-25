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
assert_executable() { [ -x "$1" ] || fail "expected executable file: $1"; }
assert_not_exists() { [ ! -e "$1" ] || fail "unexpected path exists: $1"; }
assert_contains() { grep -q -- "$2" "$1" || fail "expected '$2' in $1"; }
assert_not_contains() { if grep -q -- "$2" "$1"; then fail "did not expect '$2' in $1"; fi; }
assert_file_count() { actual=$(find "$1" -type f -name "$2" | wc -l | tr -d ' '); [ "$actual" = "$3" ] || fail "expected $3 files matching $2 under $1, found $actual"; }
init_git_repo() { git -C "$1" init -q; git -C "$1" config user.name "Piper Unified Tests"; git -C "$1" config user.email "tests@example.invalid"; }

echo "test root: $TMP_ROOT"
sh -n "$BOOTSTRAP"
sh -n "$ADD_PROJECT"
sh -n "$ROOT/scripts/render-templates.sh"
python3 "$ROOT/scripts/render_templates.py" --check >/dev/null
for runtime in codex claude opencode; do
  helper="generated/$runtime/.piper/lib/bootstrap/add-project.sh"
  assert_file "$ROOT/$helper"
  if git -C "$ROOT" check-ignore -q "$helper"; then
    fail "generated add-project helper must not be ignored: $helper"
  fi
done
python3 -m json.tool "$ROOT/generated/codex/.codex/hooks.json" >/dev/null
python3 -m json.tool "$ROOT/generated/claude/.claude/settings.json" >/dev/null
python3 -m json.tool "$ROOT/generated/opencode/opencode.json" >/dev/null
cmp -s "$ROOT/generated/codex/AGENTS.md" "$ROOT/generated/opencode/AGENTS.md" || fail "Codex and OpenCode AGENTS.md must stay runtime-neutral"

codex_hub="$TMP_ROOT/codex-hub"
"$BOOTSTRAP" --runtime codex "$codex_hub" > "$TMP_ROOT/codex.log"
assert_file "$codex_hub/AGENTS.md"
assert_file "$codex_hub/STATION.md"
assert_file "$codex_hub/.codex/config.toml"
assert_file "$codex_hub/.codex/agents/architect.toml"
assert_file "$codex_hub/.codex/agents/docs-researcher.toml"
assert_file "$codex_hub/.codex/agents/implementer.toml"
assert_file "$codex_hub/.codex/agents/reviewer.toml"
assert_file "$codex_hub/.codex/agents/security-reviewer.toml"
assert_file "$codex_hub/.codex/agents/tester.toml"
assert_file "$codex_hub/.codex/hooks/session-context.sh"
assert_file "$codex_hub/.codex/hooks/stop-reminder.sh"
assert_file "$codex_hub/.codex/commands/ralph.md"
assert_file "$codex_hub/.codex/commands/work-on.md"
assert_file "$codex_hub/.codex/commands/compact-handoff.md"
assert_file "$codex_hub/.codex/skills/ralph-loop/SKILL.md"
assert_file "$codex_hub/.piper/lib/bootstrap/add-project.sh"
assert_executable "$codex_hub/bin/add-project"
assert_executable "$codex_hub/.codex/hooks/session-context.sh"
assert_not_exists "$codex_hub/CLAUDE.md"
assert_not_exists "$codex_hub/.claude"
assert_not_exists "$codex_hub/.mcp.json"
assert_not_exists "$codex_hub/.piper/plugin"
assert_contains "$codex_hub/AGENTS.md" "Codex and OpenCode work"
assert_not_contains "$codex_hub/AGENTS.md" "point for Codex work"
assert_file_count "$codex_hub/.codex/agents" "*.toml" 6
assert_file_count "$codex_hub/.codex/commands" "*.md" 5
assert_file_count "$codex_hub/.codex/skills" "SKILL.md" 5
assert_contains "$codex_hub/.codex/config.toml" 'path = "./skills/hub-workflow"'
assert_contains "$codex_hub/.piper/hub-manifest.json" '"codex"'
assert_not_contains "$codex_hub/.piper/hub-manifest.json" '"claude"'
assert_contains "$codex_hub/.codex/commands/work-on.md" "argument-hint"
assert_not_contains "$codex_hub/.codex/commands/work-on.md" "argument-hint: \\["
assert_contains "$codex_hub/.codex/commands/work-on.md" 'argument-hint: "'
assert_contains "$codex_hub/.codex/commands/work-on.md" "piper-project:start"
assert_contains "$codex_hub/.codex/commands/work-on.md" "This command is prompt-driven routing"
assert_contains "$codex_hub/.codex/commands/ralph.md" "Implementation Review Gate"
assert_contains "$codex_hub/.codex/commands/ralph.md" "queued foundational work"
assert_contains "$codex_hub/.codex/commands/ralph.md" "review debt"
assert_contains "$codex_hub/.codex/commands/compact-handoff.md" "Required Compact Resume Packet"
assert_contains "$codex_hub/.codex/commands/compact-handoff.md" "Broad-search triggers"
assert_contains "$codex_hub/.codex/skills/ralph-loop/SKILL.md" "Review gate examples"
assert_contains "$codex_hub/.codex/skills/ralph-loop/SKILL.md" "Post-Compact Resume"
assert_contains "$codex_hub/.codex/skills/ralph-loop/SKILL.md" "changed code or diff"
assert_contains "$codex_hub/.codex/skills/superpowers-planning/SKILL.md" "Make it better"
assert_contains "$codex_hub/STATION.md" "designed resume anchors"
assert_contains "$codex_hub/STATION.md" "Do not claim"
assert_not_contains "$codex_hub/.codex/commands/superpowers.md" "Force Superpowers"
assert_not_contains "$codex_hub/STATION.md" "does not bring back"
assert_not_exists "$codex_hub/.codex/skills/planning/SKILL.md"
assert_not_exists "$codex_hub/.codex/skills/implementation-loop/SKILL.md"
python3 -m json.tool "$codex_hub/.piper/hub-manifest.json" >/dev/null
(cd "$codex_hub" && sh .codex/hooks/session-context.sh) > "$TMP_ROOT/codex-session-start.log"
assert_contains "$TMP_ROOT/codex-session-start.log" "hub-lite is active"
printf '{"hook_event_name":"SessionStart","source":"resume"}' | (cd "$codex_hub" && sh .codex/hooks/session-context.sh) > "$TMP_ROOT/codex-session-resume.log"
assert_contains "$TMP_ROOT/codex-session-resume.log" "Resume guidance"

claude_hub="$TMP_ROOT/claude-hub"
"$BOOTSTRAP" --runtime claude "$claude_hub" > "$TMP_ROOT/claude.log"
assert_file "$claude_hub/CLAUDE.md"
assert_file "$claude_hub/STATION.md"
assert_file "$claude_hub/.claude/settings.json"
assert_file "$claude_hub/.claude/agents/architect.md"
assert_file "$claude_hub/.claude/agents/docs-researcher.md"
assert_file "$claude_hub/.claude/agents/implementer.md"
assert_file "$claude_hub/.claude/agents/reviewer.md"
assert_file "$claude_hub/.claude/agents/security-reviewer.md"
assert_file "$claude_hub/.claude/agents/tester.md"
assert_file "$claude_hub/.claude/hooks/session-context.sh"
assert_file "$claude_hub/.claude/hooks/pre-compact-protection.sh"
assert_file "$claude_hub/.claude/hooks/post-compact-resume.sh"
assert_file "$claude_hub/.claude/commands/ralph.md"
assert_file "$claude_hub/.claude/commands/work-on.md"
assert_file "$claude_hub/.claude/commands/compact-handoff.md"
assert_file "$claude_hub/.claude/skills/ralph-loop/SKILL.md"
assert_file "$claude_hub/.piper/lib/bootstrap/add-project.sh"
assert_executable "$claude_hub/bin/add-project"
assert_executable "$claude_hub/.claude/hooks/session-context.sh"
assert_file_count "$claude_hub/.claude/commands" "*.md" 5
assert_file_count "$claude_hub/.claude/skills" "SKILL.md" 5
assert_file_count "$claude_hub/.claude/agents" "*.md" 7
assert_not_exists "$claude_hub/AGENTS.md"
assert_not_exists "$claude_hub/.codex"
assert_not_exists "$claude_hub/.piper/plugin"
assert_not_exists "$claude_hub/.mcp.json"
assert_contains "$claude_hub/.piper/hub-manifest.json" '"claude"'
assert_not_contains "$claude_hub/.piper/hub-manifest.json" '"codex"'
assert_contains "$claude_hub/.claude/commands/work-on.md" 'argument-hint: "<project-id> \[request\]"'
assert_contains "$claude_hub/.claude/commands/compact-handoff.md" 'argument-hint: "\[project-id\] \[current task\]"'
assert_contains "$claude_hub/.claude/commands/work-on.md" "/add-dir"
assert_contains "$claude_hub/.claude/commands/work-on.md" "piper-project:start"
assert_contains "$claude_hub/.claude/commands/ralph.md" "Implementation Review Gate"
assert_contains "$claude_hub/.claude/commands/ralph.md" "Risk tier controls approval before execution, not review selection"
assert_contains "$claude_hub/.claude/commands/compact-handoff.md" "Required Compact Resume Packet"
assert_contains "$claude_hub/.claude/commands/compact-handoff.md" "Do not say"
assert_contains "$claude_hub/.claude/skills/hub-workflow/SKILL.md" "/add-dir"
assert_contains "$claude_hub/.claude/skills/ralph-loop/SKILL.md" "Claude Code session"
assert_contains "$claude_hub/.claude/skills/ralph-loop/SKILL.md" "read-only reviewer agent"
assert_contains "$claude_hub/.claude/agents/README.md" "same helper role set as the Codex surface"
assert_contains "$claude_hub/.claude/agents/docs-researcher.md" "OpenAI developer"
assert_contains "$claude_hub/.claude/agents/docs-researcher.md" "docs MCP server"
assert_contains "$claude_hub/.claude/agents/docs-researcher.md" "mcpServers"
assert_contains "$claude_hub/.claude/agents/docs-researcher.md" "mcp__openaiDeveloperDocs__search_openai_docs"
assert_contains "$claude_hub/.claude/agents/security-reviewer.md" "Authentication and authorization"
assert_contains "$claude_hub/.claude/settings.json" "PreCompact"
assert_contains "$claude_hub/STATION.md" "compact-ready"
assert_not_contains "$claude_hub/.claude/commands/superpowers.md" "Force Superpowers"
python3 -m json.tool "$claude_hub/.piper/hub-manifest.json" >/dev/null
printf '{"hook_event_name":"SessionStart","source":"compact"}' | (cd "$claude_hub" && sh .claude/hooks/session-context.sh) > "$TMP_ROOT/claude-session-compact.log"
assert_contains "$TMP_ROOT/claude-session-compact.log" "Resume guidance"
(cd "$claude_hub" && sh .claude/hooks/pre-compact-protection.sh) > "$TMP_ROOT/claude-pre-compact.log"
assert_contains "$TMP_ROOT/claude-pre-compact.log" "systemMessage"

opencode_hub="$TMP_ROOT/opencode-hub"
"$BOOTSTRAP" --runtime opencode "$opencode_hub" > "$TMP_ROOT/opencode.log"
assert_file "$opencode_hub/AGENTS.md"
assert_file "$opencode_hub/STATION.md"
assert_file "$opencode_hub/opencode.json"
assert_file "$opencode_hub/.opencode/agents/architect.md"
assert_file "$opencode_hub/.opencode/agents/docs-researcher.md"
assert_file "$opencode_hub/.opencode/agents/implementer.md"
assert_file "$opencode_hub/.opencode/agents/reviewer.md"
assert_file "$opencode_hub/.opencode/agents/security-reviewer.md"
assert_file "$opencode_hub/.opencode/agents/tester.md"
assert_file "$opencode_hub/.opencode/commands/ralph.md"
assert_file "$opencode_hub/.opencode/commands/work-on.md"
assert_file "$opencode_hub/.opencode/commands/compact-handoff.md"
assert_file "$opencode_hub/.opencode/skills/ralph-loop/SKILL.md"
assert_file "$opencode_hub/.piper/lib/bootstrap/add-project.sh"
assert_executable "$opencode_hub/bin/add-project"
assert_file_count "$opencode_hub/.opencode/agents" "*.md" 7
assert_file_count "$opencode_hub/.opencode/commands" "*.md" 5
assert_file_count "$opencode_hub/.opencode/skills" "SKILL.md" 5
assert_not_exists "$opencode_hub/CLAUDE.md"
assert_not_exists "$opencode_hub/.codex"
assert_not_exists "$opencode_hub/.claude"
assert_not_exists "$opencode_hub/.piper/plugin"
assert_contains "$opencode_hub/.piper/hub-manifest.json" '"opencode"'
assert_not_contains "$opencode_hub/.piper/hub-manifest.json" '"codex"'
assert_not_contains "$opencode_hub/.piper/hub-manifest.json" '"claude"'
assert_contains "$opencode_hub/.opencode/commands/work-on.md" "argument-hint"
assert_contains "$opencode_hub/.opencode/commands/work-on.md" "piper-project:start"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "Implementation Review Gate"
assert_contains "$opencode_hub/.opencode/commands/compact-handoff.md" "Required Compact Resume Packet"
assert_contains "$opencode_hub/.opencode/skills/ralph-loop/SKILL.md" "OpenCode session"
assert_contains "$opencode_hub/.opencode/skills/ralph-loop/SKILL.md" "read-only reviewer subagent"
assert_contains "$opencode_hub/.opencode/agents/README.md" "same helper role set as the Codex and Claude Code"
assert_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "OpenAI developer"
assert_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "docs MCP server"
assert_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "openaiDeveloperDocs_\\*: allow"
assert_not_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "mcpServers"
assert_contains "$opencode_hub/.opencode/agents/security-reviewer.md" "Authentication and authorization"
assert_contains "$opencode_hub/STATION.md" "opencode.json"
assert_contains "$opencode_hub/AGENTS.md" "Codex and OpenCode work"
assert_not_contains "$opencode_hub/AGENTS.md" "point for OpenCode work"
assert_contains "$opencode_hub/opencode.json" '"compaction"'
assert_contains "$opencode_hub/opencode.json" '"permission"'
assert_contains "$opencode_hub/opencode.json" "\"openaiDeveloperDocs_\\*\": \"deny\""
assert_contains "$opencode_hub/opencode.json" '"type": "remote"'
assert_contains "$opencode_hub/opencode.json" '"enabled": true'
assert_not_contains "$opencode_hub/.opencode/commands/superpowers.md" "Force Superpowers"
python3 -m json.tool "$opencode_hub/.piper/hub-manifest.json" >/dev/null
python3 -m json.tool "$opencode_hub/opencode.json" >/dev/null

for hub in "$codex_hub" "$claude_hub" "$opencode_hub"; do
  assert_contains "$hub/STATION.md" "Commands own dispatch"
  assert_contains "$hub/STATION.md" "Use this dispatch table"
done
assert_contains "$codex_hub/AGENTS.md" "Supporting skills should not become independent routers"
assert_contains "$claude_hub/CLAUDE.md" "Supporting skills and agents should not become independent routers"
assert_contains "$opencode_hub/AGENTS.md" "Supporting skills should not become independent routers"
for skill_dir in "$codex_hub/.codex/skills" "$claude_hub/.claude/skills" "$opencode_hub/.opencode/skills"; do
  assert_contains "$skill_dir/hub-workflow/SKILL.md" "not the mode router"
  assert_contains "$skill_dir/superpowers-planning/SKILL.md" "Use this skill only after"
  assert_contains "$skill_dir/ralph-loop/SKILL.md" "not the initial router"
  assert_contains "$skill_dir/review/SKILL.md" "Do not use this skill for general repo orientation"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Do not use this skill for ordinary local inspection"
  assert_not_contains "$skill_dir/hub-workflow/SKILL.md" "Route the request through Intent"
done

both_hub="$TMP_ROOT/both-hub"
"$BOOTSTRAP" --runtime codex,claude "$both_hub" > "$TMP_ROOT/both.log"
assert_file "$both_hub/AGENTS.md"
assert_file "$both_hub/CLAUDE.md"
assert_file "$both_hub/.codex/config.toml"
assert_file "$both_hub/.claude/settings.json"
assert_contains "$both_hub/STATION.md" "multiple runtime surfaces"
assert_contains "$both_hub/.piper/hub-manifest.json" '"codex"'
assert_contains "$both_hub/.piper/hub-manifest.json" '"claude"'

codex_opencode_hub="$TMP_ROOT/codex-opencode-hub"
"$BOOTSTRAP" --runtime codex,opencode "$codex_opencode_hub" > "$TMP_ROOT/codex-opencode.log"
opencode_codex_hub="$TMP_ROOT/opencode-codex-hub"
"$BOOTSTRAP" --runtime opencode,codex "$opencode_codex_hub" > "$TMP_ROOT/opencode-codex.log"
assert_file "$codex_opencode_hub/AGENTS.md"
assert_file "$opencode_codex_hub/AGENTS.md"
cmp -s "$codex_opencode_hub/AGENTS.md" "$opencode_codex_hub/AGENTS.md" || fail "Codex/OpenCode AGENTS.md must not depend on runtime order"
assert_contains "$codex_opencode_hub/AGENTS.md" "Codex and OpenCode work"
assert_not_contains "$codex_opencode_hub/AGENTS.md" "point for Codex work"
assert_not_contains "$codex_opencode_hub/AGENTS.md" "point for OpenCode work"
assert_contains "$codex_opencode_hub/.piper/hub-manifest.json" '"codex"'
assert_contains "$codex_opencode_hub/.piper/hub-manifest.json" '"opencode"'

opencode_claude_hub="$TMP_ROOT/opencode-claude-hub"
"$BOOTSTRAP" --runtime opencode,claude "$opencode_claude_hub" > "$TMP_ROOT/opencode-claude.log"
assert_file "$opencode_claude_hub/AGENTS.md"
assert_file "$opencode_claude_hub/CLAUDE.md"
assert_file "$opencode_claude_hub/opencode.json"
assert_file "$opencode_claude_hub/.claude/settings.json"
assert_contains "$opencode_claude_hub/.piper/hub-manifest.json" '"opencode"'
assert_contains "$opencode_claude_hub/.piper/hub-manifest.json" '"claude"'
assert_not_contains "$opencode_claude_hub/.piper/hub-manifest.json" '"codex"'

triple_hub="$TMP_ROOT/triple-hub"
"$BOOTSTRAP" --runtime codex,claude,opencode "$triple_hub" > "$TMP_ROOT/triple.log"
assert_file "$triple_hub/AGENTS.md"
assert_file "$triple_hub/CLAUDE.md"
assert_file "$triple_hub/opencode.json"
assert_file "$triple_hub/.codex/config.toml"
assert_file "$triple_hub/.claude/settings.json"
assert_file "$triple_hub/.opencode/agents/reviewer.md"
assert_contains "$triple_hub/AGENTS.md" "Codex and OpenCode work"
assert_not_contains "$triple_hub/AGENTS.md" "point for Codex work"
assert_not_contains "$triple_hub/AGENTS.md" "point for OpenCode work"
assert_contains "$triple_hub/.piper/hub-manifest.json" '"codex"'
assert_contains "$triple_hub/.piper/hub-manifest.json" '"claude"'
assert_contains "$triple_hub/.piper/hub-manifest.json" '"opencode"'

printf 'local note
' > "$both_hub/projects/README.md"
"$BOOTSTRAP" --runtime codex,claude "$both_hub" > "$TMP_ROOT/refresh.log"
assert_contains "$both_hub/projects/README.md" "local note"
"$BOOTSTRAP" --runtime codex "$both_hub" > "$TMP_ROOT/codex-refresh.log"
assert_file "$both_hub/.claude/settings.json"
assert_contains "$both_hub/.piper/hub-manifest.json" '"claude"'

mkdir -p "$both_hub/.claude/hooks" "$both_hub/.codex/hooks" "$both_hub/.piper/plugin/.codex-plugin" "$both_hub/.piper/plugin/commands" "$both_hub/.piper/plugin/skills/old-skill"
printf 'old claude
' > "$both_hub/.claude/hooks/old-managed.sh"
printf 'old codex
' > "$both_hub/.codex/hooks/old-managed.sh"
printf '{"name":"old-codex-plugin"}
' > "$both_hub/.piper/plugin/.codex-plugin/plugin.json"
printf '{"mcpServers":{}}
' > "$both_hub/.piper/plugin/.mcp.json"
printf 'old codex plugin
' > "$both_hub/.piper/plugin/commands/old-managed.md"
printf 'old codex skill
' > "$both_hub/.piper/plugin/skills/old-skill/SKILL.md"
{
  printf '{
'
  printf '  "managed_files": [
'
  printf '    ".claude/hooks/old-managed.sh",
'
  printf '    ".codex/hooks/old-managed.sh",
'
  printf '    ".piper/plugin/.codex-plugin/plugin.json",
'
  printf '    ".piper/plugin/.mcp.json",
'
  printf '    ".piper/plugin/commands/old-managed.md",
'
  printf '    ".piper/plugin/skills/old-skill/SKILL.md"
'
  printf '  ]
'
  printf '}
'
} > "$both_hub/.piper/hub-manifest.json"
"$BOOTSTRAP" --runtime codex "$both_hub" > "$TMP_ROOT/stale-codex.log"
assert_file "$both_hub/.claude/hooks/old-managed.sh"
assert_not_exists "$both_hub/.codex/hooks/old-managed.sh"
assert_not_exists "$both_hub/.piper/plugin/.codex-plugin/plugin.json"
assert_not_exists "$both_hub/.piper/plugin/.mcp.json"
assert_not_exists "$both_hub/.piper/plugin/commands/old-managed.md"
assert_not_exists "$both_hub/.piper/plugin/skills/old-skill/SKILL.md"
assert_not_exists "$both_hub/.piper/plugin"
"$BOOTSTRAP" --runtime claude "$both_hub" > "$TMP_ROOT/stale-claude.log"
assert_not_exists "$both_hub/.claude/hooks/old-managed.sh"

invalid_hub="$TMP_ROOT/invalid-runtime"
if "$BOOTSTRAP" --runtime codex,bad "$invalid_hub" > "$TMP_ROOT/invalid-runtime.log" 2>&1; then fail "bootstrap should reject unsupported runtime"; fi
assert_contains "$TMP_ROOT/invalid-runtime.log" "unsupported runtime: bad"
assert_not_exists "$invalid_hub"

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
assert_contains "$project_repo/.piper/project.json" '"hub_lite": true'
assert_not_contains "$project_repo/.piper/project.json" '"runtime"'
python3 -m json.tool "$project_repo/.piper/project.json" >/dev/null

legacy_repo="$TMP_ROOT/legacy-repo"
mkdir -p "$legacy_repo/.piper"
init_git_repo "$legacy_repo"
(cd "$legacy_repo" && printf 'legacy
' > README.md && git add README.md && git commit -m "Initial legacy" >/dev/null)
printf '{
  "schema_version": 1,
  "project_id": "legacy-project",
  "display_name": "Legacy Project",
  "hub_lite": true,
  "runtime": "claude-code"
}
' > "$legacy_repo/.piper/project.json"
"$ADD_PROJECT" --hub "$both_hub" --repo "$legacy_repo" --project-id legacy-project --display-name "Legacy Project" > "$TMP_ROOT/legacy-add-project.log"
assert_file "$both_hub/projects/legacy-project/project.md"
assert_contains "$TMP_ROOT/legacy-add-project.log" "update: .piper/project.json"
assert_not_contains "$legacy_repo/.piper/project.json" '"runtime"'
python3 -m json.tool "$legacy_repo/.piper/project.json" >/dev/null

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
if grep -R -n '{{' "$ROOT/generated/codex" "$ROOT/generated/claude" "$ROOT/generated/opencode" > "$TMP_ROOT/placeholders.log"; then cat "$TMP_ROOT/placeholders.log" >&2; fail "unrendered template placeholder found"; fi
if grep -R -n '^argument-hint: [^"]' "$ROOT/generated/codex/.codex/commands" "$ROOT/generated/claude/.claude/commands" "$ROOT/generated/opencode/.opencode/commands" > "$TMP_ROOT/frontmatter.log"; then cat "$TMP_ROOT/frontmatter.log" >&2; fail "unquoted argument-hint frontmatter found"; fi

git -C "$ROOT" diff --check

echo "All tests passed."
