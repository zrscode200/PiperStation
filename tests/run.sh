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
# Codex AGENTS.md is Codex-native and intentionally diverges from OpenCode's.
# (Previously: cmp -s assertion that Codex and OpenCode AGENTS.md were byte-identical.)

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
assert_file "$codex_hub/.codex/agents/verifier.toml"
assert_file "$codex_hub/.codex/hooks/session-context.sh"
assert_file "$codex_hub/.codex/hooks/pre-compact-protection.sh"
assert_file "$codex_hub/.codex/hooks/post-compact-resume.sh"
assert_not_exists "$codex_hub/.codex/hooks/stop-reminder.sh"
assert_executable "$codex_hub/.codex/hooks/pre-compact-protection.sh"
assert_executable "$codex_hub/.codex/hooks/post-compact-resume.sh"
assert_file "$codex_hub/.codex/skills/piper-workflow/references/ralph.md"
assert_file "$codex_hub/.codex/skills/piper-workflow/references/compact-handoff.md"
assert_file "$codex_hub/.codex/skills/piper-workflow/SKILL.md"
assert_file "$codex_hub/.codex/skills/brainstorm/SKILL.md"
assert_file "$codex_hub/.codex/skills/brainstorm/references/add-project.md"
assert_file "$codex_hub/.piper/lib/bootstrap/add-project.sh"
assert_executable "$codex_hub/bin/add-project"
assert_executable "$codex_hub/.codex/hooks/session-context.sh"
assert_not_exists "$codex_hub/CLAUDE.md"
assert_not_exists "$codex_hub/.claude"
assert_not_exists "$codex_hub/.mcp.json"
assert_not_exists "$codex_hub/.piper/plugin"
assert_contains "$codex_hub/AGENTS.md" "Codex Discovery Surfaces"
assert_contains "$codex_hub/AGENTS.md" "Codex auto-loads this"
assert_not_contains "$codex_hub/AGENTS.md" "Codex and OpenCode work"
assert_contains "$codex_hub/AGENTS.md" "piper-workflow"
assert_contains "$codex_hub/AGENTS.md" "brainstorm"
assert_contains "$codex_hub/AGENTS.md" "--add-dir"
assert_file_count "$codex_hub/.codex/agents" "*.toml" 7
assert_file_count "$codex_hub/.codex/skills/piper-workflow/references" "*.md" 3
assert_file_count "$codex_hub/.codex/skills/brainstorm/references" "*.md" 1
assert_not_exists "$codex_hub/.codex/commands"
assert_file_count "$codex_hub/.codex/skills" "SKILL.md" 4
assert_contains "$codex_hub/.codex/config.toml" 'path = "./skills/piper-workflow"'
assert_contains "$codex_hub/.codex/config.toml" 'path = "./skills/brainstorm"'
assert_not_contains "$codex_hub/.codex/config.toml" 'skills/hub-workflow'
assert_not_contains "$codex_hub/.codex/config.toml" 'skills/superpowers-planning'
assert_not_contains "$codex_hub/.codex/config.toml" 'skills/ralph-loop'
while IFS= read -r skill_path; do
  assert_file "$codex_hub/.codex/${skill_path#./}/SKILL.md"
done <<EOF
$(sed -n 's/^[[:space:]]*path = "\(.*skills\/[^"]*\)"/\1/p' "$codex_hub/.codex/config.toml")
EOF
assert_contains "$codex_hub/.piper/hub-manifest.json" '"codex"'
assert_not_contains "$codex_hub/.piper/hub-manifest.json" '"claude"'
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Implementation Review Gate"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "queued foundational work"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "review debt"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "writable access is"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Drift And Stop Conditions"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Mark the task active"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Review gate examples"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Post-Compact Resume"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Ralph may use read-only \`reviewer\` or \`verifier\` helpers"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Use \`tester\` only when explicitly delegating test-layer"
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Ralph may spawn the"
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "security_reviewer\`, \`verifier\`, \`security_reviewer"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "reviewer"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "confirmed-in-scope"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "confirmed-out-of-scope"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "false-positive"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "covers \`local\` project source edits"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "lacks \`local\` profile coverage for source edits"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "exceptional actions only after explicit"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "For ordinary slice-end bookkeeping"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Update \`context-pack.md\` only when"
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" '\$ARGUMENTS'
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "Make it better"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "current goal, requirements"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "for sizing only"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "when they do a clear job"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "optional durable Ralph task list"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "If you cannot articulate what"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "project-local copy"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "Piper artifact commit"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "only fully self-contained resume"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/compact-handoff.md" "Required Compact Resume Packet"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/compact-handoff.md" "Broad-search triggers"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/compact-handoff.md" "Piper artifact state"
assert_contains "$codex_hub/.codex/skills/piper-workflow/references/compact-handoff.md" "backfill full resume metadata"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "Artifact Signal Policy"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "Do not ask to commit after every artifact edit"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "Record artifacts economically"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "append \`build-log.md\` at checkpoint cadence"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "writable repo access"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "Piper Workflow (Codex)"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "Codex CLI does not surface"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "references/add-project.md"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "Orient"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "projects/registry.json"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "Brainstorm (Codex)"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "Divergent Toolkit"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "rather than execute"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "executing rather than exploring"
assert_contains "$codex_hub/.codex/skills/piper-workflow/SKILL.md" "--add-dir"
assert_contains "$codex_hub/STATION.md" "designed resume anchors"
assert_contains "$codex_hub/STATION.md" "Do not claim"
assert_contains "$codex_hub/STATION.md" "Artifact Persistence"
assert_contains "$codex_hub/STATION.md" "Artifact Recording Economy"
assert_contains "$codex_hub/STATION.md" "only fully self-contained resume packet"
assert_contains "$codex_hub/STATION.md" "Piper work artifacts are hub-owned project state"
assert_contains "$codex_hub/STATION.md" "After ordinary Ralph slices"
assert_contains "$codex_hub/AGENTS.md" "Artifact Persistence"
assert_contains "$codex_hub/AGENTS.md" "Record artifacts economically"
assert_contains "$codex_hub/AGENTS.md" "\`local\` permission action"
assert_contains "$codex_hub/AGENTS.md" "Permission profiles gate action categories"
assert_contains "$codex_hub/AGENTS.md" "covers \`local\` source edits"
assert_contains "$codex_hub/AGENTS.md" "non-destructive worktree create or switch"
assert_contains "$codex_hub/.codex/agents/implementer.toml" "confirmed local profile coverage for source edits"
assert_contains "$codex_hub/.codex/agents/reviewer.toml" 'active-work.md'
assert_contains "$codex_hub/.codex/agents/reviewer.toml" 'build-log.md'
assert_contains "$codex_hub/.codex/agents/reviewer.toml" 'build/test output'
assert_contains "$codex_hub/.codex/agents/reviewer.toml" 'Use two passes'
assert_contains "$codex_hub/.codex/agents/reviewer.toml" 'active-work compliance'
assert_not_contains "$codex_hub/.codex/agents/reviewer.toml" 'plan, spec, task queue, build logs'
assert_contains "$codex_hub/STATION.md" "Work Artifact Reference"
assert_contains "$codex_hub/STATION.md" "Create these only under"
assert_contains "$codex_hub/STATION.md" "\`roadmap.md\`"
assert_contains "$codex_hub/STATION.md" "\`active-work.md\`"
assert_contains "$codex_hub/STATION.md" "\`build-log.md\`"
assert_contains "$codex_hub/STATION.md" "Scope tiers are advisory sizing, not artifact rules"
assert_contains "$codex_hub/STATION.md" "artifact creation"
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "Force Superpowers"
assert_not_contains "$codex_hub/STATION.md" "does not bring back"
assert_not_exists "$codex_hub/.codex/skills/superpowers-planning/SKILL.md"
assert_not_exists "$codex_hub/.codex/skills/ralph-loop/SKILL.md"
assert_not_exists "$codex_hub/.codex/skills/planning/SKILL.md"
assert_not_exists "$codex_hub/.codex/skills/implementation-loop/SKILL.md"
assert_not_exists "$codex_hub/.codex/skills/hub-workflow/SKILL.md"
python3 -m json.tool "$codex_hub/.piper/hub-manifest.json" >/dev/null
python3 -m json.tool "$codex_hub/.codex/hooks.json" >/dev/null
assert_contains "$codex_hub/.codex/hooks.json" '"PreCompact"'
assert_contains "$codex_hub/.codex/hooks.json" '"PostCompact"'
assert_contains "$codex_hub/.codex/hooks.json" '"startup|resume|compact"'
assert_not_contains "$codex_hub/.codex/hooks.json" '"Stop"'
assert_not_contains "$codex_hub/.codex/hooks.json" '"PreToolUse"'
assert_not_contains "$codex_hub/.codex/hooks.json" '"PermissionRequest"'
assert_contains "$codex_hub/.codex/config.toml" '[agents.architect]'
assert_contains "$codex_hub/.codex/config.toml" '[agents.docs_researcher]'
assert_contains "$codex_hub/.codex/config.toml" '[agents.implementer]'
assert_contains "$codex_hub/.codex/config.toml" '[agents.reviewer]'
assert_contains "$codex_hub/.codex/config.toml" '[agents.security_reviewer]'
assert_contains "$codex_hub/.codex/config.toml" '[agents.tester]'
assert_contains "$codex_hub/.codex/config.toml" '[agents.verifier]'
assert_contains "$codex_hub/.codex/config.toml" 'max_threads = 7'
assert_contains "$codex_hub/AGENTS.md" "seven Codex subagent roles"
assert_contains "$codex_hub/AGENTS.md" "verifier"
(cd "$codex_hub" && sh .codex/hooks/session-context.sh) > "$TMP_ROOT/codex-session-start.log"
assert_contains "$TMP_ROOT/codex-session-start.log" "hub-lite is active"
assert_contains "$TMP_ROOT/codex-session-start.log" '"hookSpecificOutput"'
assert_contains "$TMP_ROOT/codex-session-start.log" '"additionalContext"'
assert_contains "$TMP_ROOT/codex-session-start.log" '"systemMessage"'
python3 -m json.tool "$TMP_ROOT/codex-session-start.log" >/dev/null
printf '{"hook_event_name":"SessionStart","source":"resume"}' | (cd "$codex_hub" && sh .codex/hooks/session-context.sh) > "$TMP_ROOT/codex-session-resume.log"
assert_contains "$TMP_ROOT/codex-session-resume.log" "Resume guidance"
python3 -m json.tool "$TMP_ROOT/codex-session-resume.log" >/dev/null
printf '{"hook_event_name":"SessionStart","source":"compact"}' | (cd "$codex_hub" && sh .codex/hooks/session-context.sh) > "$TMP_ROOT/codex-session-compact.log"
assert_contains "$TMP_ROOT/codex-session-compact.log" "Resume guidance"
python3 -m json.tool "$TMP_ROOT/codex-session-compact.log" >/dev/null
(cd "$codex_hub" && sh .codex/hooks/pre-compact-protection.sh) > "$TMP_ROOT/codex-pre-compact.log"
assert_contains "$TMP_ROOT/codex-pre-compact.log" '"systemMessage"'
assert_contains "$TMP_ROOT/codex-pre-compact.log" "compact reminder"
assert_contains "$TMP_ROOT/codex-pre-compact.log" "does not block compaction"
python3 -m json.tool "$TMP_ROOT/codex-pre-compact.log" >/dev/null
(cd "$codex_hub" && sh .codex/hooks/post-compact-resume.sh) > "$TMP_ROOT/codex-post-compact.log"
assert_contains "$TMP_ROOT/codex-post-compact.log" '"systemMessage"'
python3 -m json.tool "$TMP_ROOT/codex-post-compact.log" >/dev/null

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
assert_file "$claude_hub/.claude/agents/verifier.md"
assert_file "$claude_hub/.claude/hooks/session-context.sh"
assert_file "$claude_hub/.claude/hooks/pre-compact-protection.sh"
assert_file "$claude_hub/.claude/hooks/post-compact-resume.sh"
assert_file "$claude_hub/.claude/commands/ralph.md"
assert_file "$claude_hub/.claude/commands/compact-handoff.md"
assert_file "$claude_hub/.claude/skills/piper-workflow/SKILL.md"
assert_file "$claude_hub/.claude/skills/brainstorm/SKILL.md"
assert_file "$claude_hub/.piper/lib/bootstrap/add-project.sh"
assert_executable "$claude_hub/bin/add-project"
assert_executable "$claude_hub/.claude/hooks/session-context.sh"
assert_file_count "$claude_hub/.claude/commands" "*.md" 4
assert_file_count "$claude_hub/.claude/skills" "SKILL.md" 4
assert_file_count "$claude_hub/.claude/agents" "*.md" 8
assert_not_exists "$claude_hub/AGENTS.md"
assert_not_exists "$claude_hub/.codex"
assert_not_exists "$claude_hub/.piper/plugin"
assert_not_exists "$claude_hub/.mcp.json"
assert_contains "$claude_hub/.piper/hub-manifest.json" '"claude"'
assert_not_contains "$claude_hub/.piper/hub-manifest.json" '"codex"'
assert_contains "$claude_hub/.claude/commands/compact-handoff.md" 'argument-hint: "\[project-id\] \[current task\]"'
assert_contains "$claude_hub/.claude/commands/ralph.md" "Implementation Review Gate"
assert_contains "$claude_hub/.claude/commands/ralph.md" "Risk tier controls Ralph implementation confirmation"
assert_contains "$claude_hub/.claude/commands/ralph.md" "writable access is"
assert_contains "$claude_hub/.claude/commands/ralph.md" "covers \`local\` project source edits"
assert_contains "$claude_hub/.claude/commands/ralph.md" "lacks \`local\` profile coverage for source edits"
assert_contains "$claude_hub/.claude/commands/ralph.md" "Review gate examples"
assert_contains "$claude_hub/.claude/commands/ralph.md" "Post-Compact Resume"
assert_contains "$claude_hub/.claude/commands/ralph.md" "ordinary slice boundaries"
assert_contains "$claude_hub/.claude/commands/ralph.md" "For ordinary slice-end bookkeeping"
assert_contains "$claude_hub/.claude/commands/ralph.md" "Update \`context-pack.md\` only when"
assert_contains "$claude_hub/.claude/commands/superpowers.md" "Make it better"
assert_contains "$claude_hub/.claude/commands/superpowers.md" "current goal, requirements"
assert_contains "$claude_hub/.claude/commands/superpowers.md" "for sizing only"
assert_contains "$claude_hub/.claude/commands/superpowers.md" "when they do a clear job"
assert_contains "$claude_hub/.claude/commands/superpowers.md" "project-local copy"
assert_contains "$claude_hub/.claude/commands/superpowers.md" "Piper artifact commit"
assert_contains "$claude_hub/.claude/commands/superpowers.md" "only fully self-contained resume"
assert_contains "$claude_hub/STATION.md" "Work Artifact Reference"
assert_contains "$claude_hub/STATION.md" "Artifact Persistence"
assert_contains "$claude_hub/STATION.md" "Artifact Recording Economy"
assert_contains "$claude_hub/STATION.md" "\`roadmap.md\`"
assert_contains "$claude_hub/STATION.md" "\`active-work.md\`"
assert_contains "$claude_hub/STATION.md" "\`build-log.md\`"
assert_contains "$claude_hub/.claude/commands/compact-handoff.md" "Required Compact Resume Packet"
assert_contains "$claude_hub/.claude/commands/compact-handoff.md" "Piper artifact state"
assert_contains "$claude_hub/.claude/commands/compact-handoff.md" "backfill full resume metadata"
assert_contains "$claude_hub/.claude/commands/compact-handoff.md" "Do not say"
assert_contains "$claude_hub/.claude/skills/piper-workflow/SKILL.md" "/add-dir"
assert_contains "$claude_hub/.claude/skills/piper-workflow/SKILL.md" "Artifact Signal Policy"
assert_contains "$claude_hub/.claude/skills/piper-workflow/SKILL.md" "Do not ask to commit after every artifact edit"
assert_contains "$claude_hub/.claude/skills/piper-workflow/SKILL.md" "Record artifacts economically"
assert_contains "$claude_hub/.claude/skills/brainstorm/SKILL.md" "rather than execute"
assert_contains "$claude_hub/CLAUDE.md" "Artifact Persistence"
assert_contains "$claude_hub/CLAUDE.md" "Record artifacts economically"
assert_contains "$claude_hub/CLAUDE.md" "Permission Profiles"
assert_contains "$claude_hub/CLAUDE.md" "Permission profiles gate action categories"
assert_contains "$claude_hub/CLAUDE.md" "covers \`local\` source edits"
assert_contains "$claude_hub/CLAUDE.md" "non-destructive worktree create or switch"
assert_contains "$claude_hub/CLAUDE.md" "Piper \`review\` skill"
assert_contains "$claude_hub/CLAUDE.md" "native \`/review\`"
assert_contains "$claude_hub/CLAUDE.md" "concrete agent id \`docs_researcher\`"
assert_not_contains "$claude_hub/.claude/settings.json" "Bash(git branch:"
assert_not_contains "$claude_hub/.claude/settings.json" "Bash(git -C * branch:"
assert_not_contains "$claude_hub/.claude/settings.json" "Bash(git symbolic-ref:"
assert_not_contains "$claude_hub/.claude/settings.json" "Bash(git -C * symbolic-ref:"
assert_contains "$claude_hub/.claude/agents/implementer.md" "coordinator confirmed \`local\` profile"
assert_contains "$claude_hub/.claude/agents/reviewer.md" "active-work.md"
assert_contains "$claude_hub/.claude/agents/reviewer.md" "build-log.md"
assert_contains "$claude_hub/.claude/agents/reviewer.md" "implementation report"
assert_not_contains "$claude_hub/.claude/agents/reviewer.md" "implementer's report"
assert_not_exists "$claude_hub/.claude/skills/superpowers-planning/SKILL.md"
assert_not_exists "$claude_hub/.claude/skills/ralph-loop/SKILL.md"
assert_contains "$claude_hub/.claude/agents/README.md" "same helper role set as the Codex surface"
assert_contains "$claude_hub/.claude/agents/README.md" "verifier"
assert_contains "$claude_hub/.claude/agents/tester.md" "test-layer"
assert_contains "$claude_hub/.claude/agents/verifier.md" "Strict read-only"
assert_contains "$claude_hub/.claude/agents/docs-researcher.md" "OpenAI developer"
assert_contains "$claude_hub/.claude/agents/docs-researcher.md" "docs MCP server"
assert_contains "$claude_hub/.claude/agents/docs-researcher.md" "mcpServers"
assert_contains "$claude_hub/.claude/agents/docs-researcher.md" "mcp__openaiDeveloperDocs__search_openai_docs"
assert_contains "$claude_hub/.claude/agents/security-reviewer.md" "Authentication and authorization"
assert_contains "$claude_hub/.claude/settings.json" "PreCompact"
assert_not_contains "$claude_hub/.claude/settings.json" "PreToolUse"
assert_not_contains "$claude_hub/.claude/settings.json" "PermissionRequest"
assert_contains "$claude_hub/STATION.md" "compact-ready"
assert_not_contains "$claude_hub/.claude/commands/superpowers.md" "Force Superpowers"
python3 -m json.tool "$claude_hub/.piper/hub-manifest.json" >/dev/null
printf '{"hook_event_name":"SessionStart","source":"compact"}' | (cd "$claude_hub" && sh .claude/hooks/session-context.sh) > "$TMP_ROOT/claude-session-compact.log"
assert_contains "$TMP_ROOT/claude-session-compact.log" "Resume guidance"
(cd "$claude_hub" && sh .claude/hooks/pre-compact-protection.sh) > "$TMP_ROOT/claude-pre-compact.log"
assert_contains "$TMP_ROOT/claude-pre-compact.log" '"systemMessage"'
assert_contains "$TMP_ROOT/claude-pre-compact.log" "compact reminder"
assert_contains "$TMP_ROOT/claude-pre-compact.log" "does not block compaction"
python3 -m json.tool "$TMP_ROOT/claude-pre-compact.log" >/dev/null

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
assert_file "$opencode_hub/.opencode/agents/verifier.md"
assert_file "$opencode_hub/.opencode/commands/ralph.md"
assert_file "$opencode_hub/.opencode/commands/compact-handoff.md"
assert_file "$opencode_hub/.opencode/skills/piper-workflow/SKILL.md"
assert_file "$opencode_hub/.opencode/skills/brainstorm/SKILL.md"
assert_file "$opencode_hub/.piper/lib/bootstrap/add-project.sh"
assert_executable "$opencode_hub/bin/add-project"
assert_file_count "$opencode_hub/.opencode/agents" "*.md" 8
assert_file_count "$opencode_hub/.opencode/commands" "*.md" 4
assert_file_count "$opencode_hub/.opencode/skills" "SKILL.md" 4
assert_not_exists "$opencode_hub/CLAUDE.md"
assert_not_exists "$opencode_hub/.codex"
assert_not_exists "$opencode_hub/.claude"
assert_not_exists "$opencode_hub/.piper/plugin"
assert_contains "$opencode_hub/.piper/hub-manifest.json" '"opencode"'
assert_not_contains "$opencode_hub/.piper/hub-manifest.json" '"codex"'
assert_not_contains "$opencode_hub/.piper/hub-manifest.json" '"claude"'
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "Implementation Review Gate"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "writable access is"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "covers \`local\` project source edits"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "lacks \`local\` profile coverage for source edits"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "Review gate examples"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "Post-Compact Resume"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "ordinary slice boundaries"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "For ordinary slice-end bookkeeping"
assert_contains "$opencode_hub/.opencode/commands/ralph.md" "Update \`context-pack.md\` only when"
assert_contains "$opencode_hub/.opencode/commands/superpowers.md" "Make it better"
assert_contains "$opencode_hub/.opencode/commands/superpowers.md" "current goal, requirements"
assert_contains "$opencode_hub/.opencode/commands/superpowers.md" "for sizing only"
assert_contains "$opencode_hub/.opencode/commands/superpowers.md" "when they do a clear job"
assert_contains "$opencode_hub/.opencode/commands/superpowers.md" "project-local copy"
assert_contains "$opencode_hub/.opencode/commands/superpowers.md" "Piper artifact commit"
assert_contains "$opencode_hub/.opencode/commands/superpowers.md" "only fully self-contained resume"
assert_contains "$opencode_hub/STATION.md" "Work Artifact Reference"
assert_contains "$opencode_hub/STATION.md" "Artifact Persistence"
assert_contains "$opencode_hub/STATION.md" "Artifact Recording Economy"
assert_contains "$opencode_hub/STATION.md" "\`roadmap.md\`"
assert_contains "$opencode_hub/STATION.md" "\`active-work.md\`"
assert_contains "$opencode_hub/STATION.md" "\`build-log.md\`"
assert_contains "$opencode_hub/.opencode/commands/compact-handoff.md" "Required Compact Resume Packet"
assert_contains "$opencode_hub/.opencode/commands/compact-handoff.md" "Piper artifact state"
assert_contains "$opencode_hub/.opencode/commands/compact-handoff.md" "backfill full resume metadata"
assert_contains "$opencode_hub/.opencode/skills/piper-workflow/SKILL.md" "Artifact Signal Policy"
assert_contains "$opencode_hub/.opencode/skills/piper-workflow/SKILL.md" "Do not ask to commit after every artifact edit"
assert_contains "$opencode_hub/.opencode/skills/piper-workflow/SKILL.md" "Record artifacts economically"
assert_contains "$opencode_hub/AGENTS.md" "Artifact Persistence"
assert_contains "$opencode_hub/AGENTS.md" "Record artifacts economically"
assert_contains "$opencode_hub/AGENTS.md" "Permission profiles"
assert_contains "$opencode_hub/AGENTS.md" "Permission profiles gate action categories"
assert_contains "$opencode_hub/AGENTS.md" "covers \`local\` source edits"
assert_contains "$opencode_hub/AGENTS.md" "non-destructive worktree create or switch"
assert_contains "$opencode_hub/opencode.json" '"task": "ask"'
assert_contains "$opencode_hub/opencode.json" '"todowrite": "ask"'
assert_contains "$opencode_hub/.opencode/agents/implementer.md" "edit: ask"
assert_contains "$opencode_hub/.opencode/agents/implementer.md" "coordinator confirmed \`local\` profile"
assert_contains "$opencode_hub/.opencode/agents/tester.md" "edit: ask"
assert_contains "$opencode_hub/.opencode/agents/reviewer.md" "todowrite: deny"
assert_contains "$opencode_hub/.opencode/agents/architect.md" "todowrite: deny"
assert_contains "$opencode_hub/.opencode/agents/verifier.md" "todowrite: deny"
assert_contains "$opencode_hub/.opencode/agents/security-reviewer.md" "todowrite: deny"
assert_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "todowrite: deny"
assert_contains "$opencode_hub/.opencode/agents/reviewer.md" "active-work.md"
assert_contains "$opencode_hub/.opencode/agents/reviewer.md" "build-log.md"
assert_contains "$opencode_hub/.opencode/agents/reviewer.md" "implementation report"
assert_not_contains "$opencode_hub/.opencode/agents/reviewer.md" "implementer's report"
assert_not_exists "$opencode_hub/.opencode/skills/superpowers-planning/SKILL.md"
assert_not_exists "$opencode_hub/.opencode/skills/ralph-loop/SKILL.md"
assert_contains "$opencode_hub/.opencode/agents/README.md" "same helper role set as the Codex and Claude Code"
assert_contains "$opencode_hub/.opencode/agents/README.md" "verifier"
assert_contains "$opencode_hub/.opencode/agents/tester.md" "test-layer"
assert_contains "$opencode_hub/.opencode/agents/verifier.md" "Strict read-only"
assert_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "OpenAI developer"
assert_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "docs MCP server"
assert_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "openaiDeveloperDocs_\\*: ask"
assert_not_contains "$opencode_hub/.opencode/agents/docs-researcher.md" "openaiDeveloperDocs_\\*: allow"
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
  assert_contains "$hub/STATION.md" "piper-workflow"
  assert_contains "$hub/STATION.md" "brainstorm"
  assert_contains "$hub/STATION.md" "owns convergent execution"
  assert_contains "$hub/STATION.md" "decision-quality front door"
  assert_contains "$hub/STATION.md" "profiles decide whether action categories"
  assert_contains "$hub/STATION.md" "Risk tiers are implementation caution"
  assert_contains "$hub/STATION.md" "Scope tiers are advisory sizing, not artifact rules"
  assert_contains "$hub/STATION.md" "artifact creation"
  assert_contains "$hub/STATION.md" "driven by durable need"
  assert_contains "$hub/STATION.md" "project source edits require \`local\` profile coverage"
  assert_contains "$hub/STATION.md" "exceptional actions only after explicit one-off approval"
  assert_contains "$hub/STATION.md" "Exceptional actions are outside standing profiles"
  assert_contains "$hub/automation-policy.md" "Permission Profiles"
  assert_contains "$hub/automation-policy.md" "\`strict\`"
  assert_contains "$hub/automation-policy.md" "\`local\`"
  assert_contains "$hub/automation-policy.md" "\`external\`"
  assert_contains "$hub/automation-policy.md" "\`exceptional\`"
  assert_contains "$hub/automation-policy.md" "profile is a gate, not a trigger"
  assert_contains "$hub/automation-policy.md" "registered project source edits"
  assert_contains "$hub/automation-policy.md" "Ralph implementation edits are \`local\` permission actions"
  assert_contains "$hub/automation-policy.md" "Non-destructive worktree creation or switching is"
  assert_contains "$hub/automation-policy.md" "deleting worktrees"
  assert_contains "$hub/automation-policy.md" "do not edit bootstrap-managed runtime config files"
  assert_contains "$hub/automation-policy.md" "add hooks as the profile gate"
done
assert_contains "$codex_hub/AGENTS.md" "piper-workflow"
assert_contains "$codex_hub/AGENTS.md" "brainstorm"
assert_contains "$codex_hub/AGENTS.md" "owns convergent execution"
assert_contains "$claude_hub/CLAUDE.md" "piper-workflow"
assert_contains "$claude_hub/CLAUDE.md" "brainstorm"
assert_contains "$claude_hub/CLAUDE.md" "owns convergent execution"
assert_contains "$opencode_hub/AGENTS.md" "piper-workflow"
assert_contains "$opencode_hub/AGENTS.md" "brainstorm"
assert_contains "$opencode_hub/AGENTS.md" "owns convergent execution"
for skill_dir in "$codex_hub/.codex/skills" "$claude_hub/.claude/skills" "$opencode_hub/.opencode/skills"; do
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Divergent Toolkit"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Hand-Off Brief"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Register"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Artifact Signal Policy"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Orient"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "projects/registry.json"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "read-only except explicit registration through the helper"
  assert_contains "$skill_dir/piper-workflow/SKILL.md" "Piper Workflow owns convergent execution"
  assert_contains "$skill_dir/piper-workflow/SKILL.md" "Artifact Signal Policy"
  assert_contains "$skill_dir/piper-workflow/SKILL.md" "Scope And Risk"
  assert_contains "$skill_dir/piper-workflow/SKILL.md" "Scope is advisory sizing"
  assert_contains "$skill_dir/piper-workflow/SKILL.md" "does not mechanically create artifacts"
  assert_contains "$skill_dir/piper-workflow/SKILL.md" "project source edits require \`local\` profile coverage"
  assert_contains "$skill_dir/piper-workflow/SKILL.md" "when \`local\` profile coverage exists"
  assert_contains "$skill_dir/piper-workflow/SKILL.md" "Permission profiles control action boundaries separately"
  assert_not_exists "$skill_dir/superpowers-planning/SKILL.md"
  assert_not_exists "$skill_dir/ralph-loop/SKILL.md"
  assert_contains "$skill_dir/review/SKILL.md" "Do not use this skill for general repo orientation"
  assert_contains "$skill_dir/review/SKILL.md" "Route automation approval"
  assert_contains "$skill_dir/review/SKILL.md" 'root-session `automation-policy` skill'
  assert_contains "$skill_dir/review/SKILL.md" "confirmed-in-scope"
  assert_contains "$skill_dir/review/SKILL.md" "confirmed-out-of-scope"
  assert_contains "$skill_dir/review/SKILL.md" "false-positive"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Do not use this skill for ordinary local inspection"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "canonical global policy"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "permission-profile manager and action-boundary gate"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Permission decisions and exceptional actions"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Registered project source edits are \`local\` permission actions"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "must use this skill before editing source"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Non-destructive worktree creation or switching is"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "\`exceptional\` is outside standing profiles"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "\`strict\`, \`local\`, \`external\`, or"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "do not edit bootstrap-managed runtime config files"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "hooks as the profile gate"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "projects/<project-id>/project.md"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "Record durable opt-ins or policy changes in"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "Default Classifications"
  assert_not_exists "$skill_dir/hub-workflow/SKILL.md"
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
# Codex AGENTS.md is now Codex-native; OpenCode AGENTS.md is unchanged.
# In a mixed hub the first-listed runtime's AGENTS.md wins (init.sh template_source order).
# (Previously: cmp -s asserted order-independence when both files were byte-identical.)
assert_contains "$codex_opencode_hub/AGENTS.md" "Codex Discovery Surfaces"
assert_not_contains "$codex_opencode_hub/AGENTS.md" "Codex and OpenCode work"
assert_contains "$opencode_codex_hub/AGENTS.md" "Codex and OpenCode work"
assert_not_contains "$opencode_codex_hub/AGENTS.md" "Codex Discovery Surfaces"
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
# triple_hub uses --runtime codex,claude,opencode; Codex is first-listed so its AGENTS.md wins.
assert_contains "$triple_hub/AGENTS.md" "Codex Discovery Surfaces"
assert_not_contains "$triple_hub/AGENTS.md" "Codex and OpenCode work"
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
assert_not_exists "$both_hub/projects/sample-project/decisions.md"
assert_contains "$both_hub/projects/sample-project/project.md" "Project Policy"
assert_contains "$both_hub/projects/sample-project/project.md" "Permission profile preference"
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

# --- Project registry index ---
for hub in "$codex_hub" "$claude_hub" "$opencode_hub" "$both_hub" "$triple_hub"; do
  assert_file "$hub/projects/registry.json"
  python3 -m json.tool "$hub/projects/registry.json" >/dev/null
done
assert_contains "$codex_hub/projects/registry.json" '"schema_version": 1'
empty_count=$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["projects"]))' "$codex_hub/projects/registry.json")
[ "$empty_count" = "0" ] || fail "expected fresh registry to be empty, got $empty_count entries"

# Three registrations in both_hub at this point: sample-project, legacy-project, hub-only.
both_count=$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["projects"]))' "$both_hub/projects/registry.json")
[ "$both_count" = "3" ] || fail "expected 3 registry entries in both_hub, got $both_count"
assert_contains "$both_hub/projects/registry.json" '"project_id": "sample-project"'
assert_contains "$both_hub/projects/registry.json" '"project_id": "legacy-project"'
assert_contains "$both_hub/projects/registry.json" '"project_id": "hub-only"'
project_repo_real=$(CDPATH= cd -- "$project_repo" && pwd -P)
assert_contains "$both_hub/projects/registry.json" "\"repo_path\": \"$project_repo_real\""

# Re-registering the same project_id is idempotent in the index.
"$ADD_PROJECT" --hub "$both_hub" --repo "$project_repo" --project-id sample-project --display-name "Sample Project" > "$TMP_ROOT/re-add.log"
both_count_after=$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["projects"]))' "$both_hub/projects/registry.json")
[ "$both_count_after" = "3" ] || fail "re-registration changed entry count to $both_count_after"

# --description round-trips into the index.
desc_repo="$TMP_ROOT/desc-repo"
mkdir -p "$desc_repo"
init_git_repo "$desc_repo"
(cd "$desc_repo" && printf 'd
' > README.md && git add README.md && git commit -m "Initial desc" >/dev/null)
"$ADD_PROJECT" --hub "$both_hub" --repo "$desc_repo" --project-id desc-project --display-name "Desc Project" --description "Project for description test" > "$TMP_ROOT/desc-add.log"
assert_contains "$both_hub/projects/registry.json" '"description": "Project for description test"'

# Description over 120 chars is rejected.
long_desc="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
if "$ADD_PROJECT" --hub "$both_hub" --repo "$desc_repo" --project-id desc-project --description "$long_desc" > "$TMP_ROOT/desc-long.log" 2>&1; then
  fail "add-project should reject description over 120 chars"
fi
assert_contains "$TMP_ROOT/desc-long.log" "description must be 120 characters or fewer"

# A second project_id pointing at an already-registered repo_path is rejected (via the registry, not the repo marker).
dup_repo="$TMP_ROOT/dup-repo"
mkdir -p "$dup_repo"
init_git_repo "$dup_repo"
(cd "$dup_repo" && printf 'd
' > README.md && git add README.md && git commit -m "Initial dup" >/dev/null)
"$ADD_PROJECT" --hub "$both_hub" --repo "$dup_repo" --project-id dup-a --hub-only > "$TMP_ROOT/dup-a.log"
if "$ADD_PROJECT" --hub "$both_hub" --repo "$dup_repo" --project-id dup-b --hub-only > "$TMP_ROOT/dup-b.log" 2>&1; then
  fail "add-project should reject second project_id at same repo_path"
fi
assert_contains "$TMP_ROOT/dup-b.log" "already registered as project id 'dup-a'"

# --rebuild regenerates the index from project.md scan, dropping orphaned entries.
rm -rf "$both_hub/projects/desc-project"
"$ADD_PROJECT" --hub "$both_hub" --rebuild > "$TMP_ROOT/rebuild.log"
assert_contains "$TMP_ROOT/rebuild.log" "rebuild: projects/registry.json"
assert_not_contains "$both_hub/projects/registry.json" '"project_id": "desc-project"'
assert_contains "$both_hub/projects/registry.json" '"project_id": "sample-project"'
python3 -m json.tool "$both_hub/projects/registry.json" >/dev/null

# Dry-run does not mutate the registry.
"$ADD_PROJECT" --hub "$both_hub" --repo "$desc_repo" --project-id desc-project --description "Re-added" --dry-run > "$TMP_ROOT/desc-dry.log"
assert_contains "$TMP_ROOT/desc-dry.log" "would update: projects/registry.json"
assert_not_contains "$both_hub/projects/registry.json" "Re-added"

"$BOOTSTRAP" --runtime codex --dry-run "$TMP_ROOT/dry-new" > "$TMP_ROOT/dry.log"
assert_contains "$TMP_ROOT/dry.log" "would create managed hub file: STATION.md"
assert_not_exists "$TMP_ROOT/dry-new"

git_hub="$TMP_ROOT/git-hub"
"$BOOTSTRAP" --runtime claude --git-init "$git_hub" > "$TMP_ROOT/git-init.log"
assert_dir "$git_hub/.git"

if "$BOOTSTRAP" --runtime codex "$ROOT" > "$TMP_ROOT/source-refuse.log" 2>&1; then fail "bootstrap should refuse source repo"; fi
assert_contains "$TMP_ROOT/source-refuse.log" "refusing to initialize the bootstrap source"
if grep -R -n '{{' "$ROOT/generated/codex" "$ROOT/generated/claude" "$ROOT/generated/opencode" > "$TMP_ROOT/placeholders.log"; then cat "$TMP_ROOT/placeholders.log" >&2; fail "unrendered template placeholder found"; fi
if grep -R -n '^argument-hint: [^"]' "$ROOT/generated/claude/.claude/commands" "$ROOT/generated/opencode/.opencode/commands" > "$TMP_ROOT/frontmatter.log"; then cat "$TMP_ROOT/frontmatter.log" >&2; fail "unquoted argument-hint frontmatter found"; fi
if grep -R -n '^argument-hint:\|^allowed-tools:\|^description:' "$ROOT/generated/codex/.codex/skills/piper-workflow/references" "$ROOT/generated/codex/.codex/skills/brainstorm/references" > "$TMP_ROOT/codex-refs-frontmatter.log"; then cat "$TMP_ROOT/codex-refs-frontmatter.log" >&2; fail "Codex skill references must not carry slash-command frontmatter"; fi
if grep -R -n '^description: [^"].*: ' "$ROOT/core/skills" "$ROOT/generated/codex/.codex/skills" "$ROOT/generated/claude/.claude/skills" "$ROOT/generated/opencode/.opencode/skills" > "$TMP_ROOT/skill-frontmatter.log"; then cat "$TMP_ROOT/skill-frontmatter.log" >&2; fail "unquoted skill description frontmatter with colon found"; fi
if grep -R -n -E '`(handoff|progress)\.md`' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-work-artifacts.log"; then cat "$TMP_ROOT/stale-work-artifacts.log" >&2; fail "active instructions must not use stale handoff.md or progress.md artifacts"; fi
if grep -R -n 'established docs location' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-project-local-artifacts.log"; then cat "$TMP_ROOT/stale-project-local-artifacts.log" >&2; fail "artifact persistence must keep Piper work artifacts hub-owned by default"; fi
if grep -R -n 'When an artifact changes, make it self-contained' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-self-contained-artifacts.log"; then cat "$TMP_ROOT/stale-self-contained-artifacts.log" >&2; fail "only context-pack should be the fully self-contained resume packet"; fi
if grep -R -n 'Update useful active work records, including' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-broad-artifact-updates.log"; then cat "$TMP_ROOT/stale-broad-artifact-updates.log" >&2; fail "Ralph slice bookkeeping must not broadly update every active artifact"; fi
if grep -R -n 'compact-safe reload state when active work records are in use' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-context-pack-every-planning.log"; then cat "$TMP_ROOT/stale-context-pack-every-planning.log" >&2; fail "Superpowers must defer context-pack unless a resume checkpoint is needed"; fi
if grep -R -n 'prepare compact-safe state at natural stopping points by updating' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-context-pack-natural-stops.log"; then cat "$TMP_ROOT/stale-context-pack-natural-stops.log" >&2; fail "runtime roots must not imply every natural stop updates context-pack"; fi
if grep -R -n -E "no artifact needed|short active plan in|written spec and plan required before implementation|For \`S1\`, prefer only \`active-plan.md\`|For \`S2\+\`, write|scope controls artifact|artifact weight|scope-appropriate checkpoints|active-spec\.md|active-plan\.md|verification\.md|specs/|plans/|runs/|plan, spec, task queue, build logs|implementer.s report" "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-scope-artifact-rules.log"; then cat "$TMP_ROOT/stale-scope-artifact-rules.log" >&2; fail "scope tiers and active prompts must use the compact artifact model"; fi
if grep -R -n -E 'For `S2/S3`, or for `S1`|do not commit unless the user approves through `automation-policy`|Piper Station compact protection|Ralph may spawn the|security_reviewer`, `verifier`, `security_reviewer|Bash\(git branch:\*\)|Bash\(git -C \* branch:\*\)|Bash\(git symbolic-ref:\*\)|Bash\(git -C \* symbolic-ref:\*\)' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-runtime-review-fixes.log"; then cat "$TMP_ROOT/stale-runtime-review-fixes.log" >&2; fail "runtime review fixes must not regress to stale compact, helper, or permission wording"; fi
if grep -R -n 'piper-workflow router\|piper workflow handles lookup, registration, orientation' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-router.log"; then cat "$TMP_ROOT/stale-router.log" >&2; fail "active instructions must not describe piper-workflow as the broad router"; fi
if grep -R -n 'openaiDeveloperDocs_\*: allow\|"openaiDeveloperDocs_\\\*": "allow"' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-openai-docs-permission.log"; then cat "$TMP_ROOT/stale-openai-docs-permission.log" >&2; fail "OpenCode docs-researcher must ask before OpenAI docs MCP use"; fi
if grep -R -n 'read-only band\|creates no hub records' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-brainstorm-readonly.log"; then cat "$TMP_ROOT/stale-brainstorm-readonly.log" >&2; fail "brainstorm registration wording must acknowledge the deterministic write exception"; fi
if grep -R -n -E 'automation approval\. Route those through|automation approval.*piper-workflow' "$ROOT/core/skills/review/SKILL.md" "$ROOT/generated/codex/.codex/skills/review/SKILL.md" "$ROOT/generated/claude/.claude/skills/review/SKILL.md" "$ROOT/generated/opencode/.opencode/skills/review/SKILL.md" > "$TMP_ROOT/stale-review-automation-routing.log"; then cat "$TMP_ROOT/stale-review-automation-routing.log" >&2; fail "review skill must route automation approval directly to automation-policy"; fi
if grep -R -n -E '(^|[^[:alnum:]_])A[0-3]([^[:alnum:]_]|$)|A-tier|Automation Tiers|automation tiers' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-automation-tiers.log"; then cat "$TMP_ROOT/stale-automation-tiers.log" >&2; fail "active instructions must use permission profiles, not stale automation tiers"; fi
if grep -R -n -E 'protected local git action|Risk tier controls approval|Risk tier determines whether execution|L2.*dependency|dependency or CI action' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-permission-risk-mix.log"; then cat "$TMP_ROOT/stale-permission-risk-mix.log" >&2; fail "active instructions must keep Ralph risk separate from permission profiles"; fi
if grep -R -n -E 'protected finish action|Do not commit, push, merge, delete, install dependencies|exceptional actions through the permission profile gate|exceptional actions may proceed|Only after the workflow reaches that action and the permission profile allows it' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-permission-profile-semantics.log"; then cat "$TMP_ROOT/stale-permission-profile-semantics.log" >&2; fail "active instructions must keep exceptional actions one-off and source edits locally gated"; fi
if grep -R -n '\.codex/commands' "$ROOT/core" "$ROOT/adapters" "$ROOT/docs/capability-matrix.md" "$ROOT/generated" > "$TMP_ROOT/codex-commands.log"; then
  if grep -v -e 'does not' -e 'not auto-surface' "$TMP_ROOT/codex-commands.log" > "$TMP_ROOT/codex-commands-active.log"; then
    cat "$TMP_ROOT/codex-commands-active.log" >&2
    fail "active docs must describe Codex commands as skill references, not .codex/commands"
  fi
fi

git -C "$ROOT" diff --check

echo "All tests passed."
