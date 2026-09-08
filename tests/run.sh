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
assert_design_studio_contract() {
  studio_skill_dir=$1
  assert_contains "$studio_skill_dir/SKILL.md" "Enter only on explicit intent"
  assert_contains "$studio_skill_dir/SKILL.md" "projects/<project-id>/project.md"
  assert_contains "$studio_skill_dir/SKILL.md" "One studio represents one design initiative"
  assert_contains "$studio_skill_dir/SKILL.md" "Reuse an existing studio when its initiative matches"
  assert_contains "$studio_skill_dir/SKILL.md" "derive a stable lower-kebab-case slug"
  assert_contains "$studio_skill_dir/SKILL.md" "If the slug already belongs to different work"
  assert_contains "$studio_skill_dir/SKILL.md" "edits to the registered project's source repository"
  assert_contains "$studio_skill_dir/SKILL.md" "Design Studio is discussion-first"
  assert_contains "$studio_skill_dir/SKILL.md" "not a studio exit into direct editing"
  assert_contains "$studio_skill_dir/SKILL.md" "Source implementation never starts from the studio"
  assert_contains "$studio_skill_dir/SKILL.md" "regardless of action"
  assert_not_contains "$studio_skill_dir/SKILL.md" "regardless of permission"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "standing policy notes"
  assert_contains "$studio_skill_dir/SKILL.md" "once the design tree has two or more entries"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "once the design tree has two or more entries"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "when they earn their place"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "Where Material Goes"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "do not create sibling lightweight notes"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "rather than as sibling notes"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "at creation and explain its role"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "remains reference material, not a verified input"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "checkout-redesign/"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "Each mutable fact has one owner"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "work/design/<studio-slug>/"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "accepted_revision: <current revision>"
  assert_contains "$studio_skill_dir/references/artifact-contracts.md" "Do not force artifacts"
}
assert_design_studio_journeys() {
  journey_root=$1
  journey_brainstorm=$2
  journey_studio_dir=$3
  journey_piper=$4
  journey_superpowers=$5
  journey_station=$6
  journey_testing=$7
  journey_direct_invocation=$8

  # 1. Lightweight brainstorm: no studio is required and direct handoff stays valid.
  assert_contains "$journey_brainstorm" "may still hand directly to \`piper-workflow\`"
  assert_contains "$journey_brainstorm" "studio merely because"

  # 2. Suggested studio: brainstorm explains the value and waits for explicit opt-in.
  assert_contains "$journey_brainstorm" "enter only after the user explicitly chooses it"

  # 3. Direct studio: the Codex root exposes direct and optional entry.
  assert_contains "$journey_studio_dir/SKILL.md" "Enter only on explicit intent"

  # 4. Emergent artifacts: descriptive outputs are not forced into category trees.
  assert_contains "$journey_studio_dir/references/artifact-contracts.md" "registration-flow.md"
  assert_contains "$journey_studio_dir/references/artifact-contracts.md" "Do not force artifacts into"

  # 5. Multi-session resume: one initiative is reused and Piper owns resume state.
  assert_contains "$journey_studio_dir/SKILL.md" "One studio represents one design initiative across conversations"
  assert_contains "$journey_studio_dir/references/artifact-contracts.md" "A studio README never replaces \`context-pack.md\`"

  # 6. Conclude without execution: useful design may end without a fake handoff.
  assert_contains "$journey_studio_dir/SKILL.md" "conclude as useful durable design without implementation"

  # 7. Accepted handoff: the exact pair is validated and referenced, not copied.

  # 8. Post-handoff revision: a changed design is stale until accepted and reverified.
  assert_contains "$journey_testing" "post-handoff revision"

  # 9. Post-design build request: development enters piper-workflow, never direct editing.
  assert_contains "$journey_studio_dir/SKILL.md" "A request to build, implement, or code"
  assert_contains "$journey_station" "Convergent entry, not direct editing"

  # Shared canon keeps the capability optional inside the divergent movement.
  assert_contains "$journey_station" "Ordinary brainstorm may still hand"
  assert_contains "$journey_station" "optional deeper practice inside that divergent"
  assert_contains "$journey_studio_dir/references/artifact-contracts.md" "For an existing lightweight note or ad hoc folder"
  assert_contains "$journey_studio_dir/references/artifact-contracts.md" "Never silently move or delete the original"
}

echo "test root: $TMP_ROOT"
sh -n "$BOOTSTRAP"
sh -n "$ADD_PROJECT"
sh -n "$ROOT/scripts/render-templates.sh"
python3 "$ROOT/scripts/render_templates.py" --check >/dev/null
find "$ROOT/generated/codex/.piper/lib" -type f | while IFS= read -r helper; do
  assert_file "$helper"
  if git -C "$ROOT" check-ignore -q "${helper#"$ROOT"/}"; then
    fail "generated helper must not be ignored: $helper"
  fi
done
python3 -m json.tool "$ROOT/generated/codex/.codex/hooks.json" >/dev/null
codex_hub="$TMP_ROOT/codex-hub"
"$BOOTSTRAP" --runtime codex "$codex_hub" > "$TMP_ROOT/codex.log"
assert_file "$codex_hub/AGENTS.md"
assert_file "$codex_hub/STATION.md"
assert_file "$codex_hub/.codex/config.toml"
assert_file "$codex_hub/.codex/agents/investigator.toml"
assert_file "$codex_hub/.codex/agents/implementer.toml"
assert_file "$codex_hub/.codex/agents/reviewer.toml"
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
assert_file "$codex_hub/.codex/skills/design-studio/SKILL.md"
assert_file "$codex_hub/.codex/skills/design-studio/references/studio-method.md"
assert_file "$codex_hub/.codex/skills/design-studio/references/artifact-contracts.md"
assert_design_studio_contract "$codex_hub/.codex/skills/design-studio"
assert_design_studio_journeys \
  "$codex_hub/AGENTS.md" \
  "$codex_hub/.codex/skills/brainstorm/SKILL.md" \
  "$codex_hub/.codex/skills/design-studio" \
  "$codex_hub/.codex/skills/piper-workflow/SKILL.md" \
  "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" \
  "$codex_hub/STATION.md" \
  "$codex_hub/TESTING.md" \
  '`$design-studio ...` or natural-language intent'
assert_file "$codex_hub/.piper/lib/bootstrap/add-project.sh"
assert_file "$codex_hub/.piper/lib/work_ownership.py"
assert_executable "$codex_hub/bin/add-project"
assert_executable "$codex_hub/bin/piper-record"
assert_executable "$codex_hub/bin/piper-integrate"
assert_contains "$codex_hub/.piper/.gitignore" '/locks/'
"$codex_hub/bin/piper-record" --help > "$TMP_ROOT/record-help.log"
"$codex_hub/bin/piper-integrate" --help > "$TMP_ROOT/integration-help.log"
assert_executable "$codex_hub/.codex/hooks/session-context.sh"
assert_not_exists "$codex_hub/CLAUDE.md"
assert_not_exists "$codex_hub/.claude"
assert_not_exists "$codex_hub/.mcp.json"
assert_not_exists "$codex_hub/.piper/plugin"
assert_not_contains "$codex_hub/AGENTS.md" "Codex and OpenCode work"
assert_file_count "$codex_hub/.codex/agents" "*.toml" 3
assert_file_count "$codex_hub/.codex/skills/piper-workflow/references" "*.md" 5
assert_file_count "$codex_hub/.codex/skills/brainstorm/references" "*.md" 1
assert_file_count "$codex_hub/.codex/skills/design-studio/references" "*.md" 2
assert_not_exists "$codex_hub/.codex/commands"
assert_file_count "$codex_hub/.codex/skills" "SKILL.md" 5
assert_contains "$codex_hub/.codex/config.toml" 'path = "./skills/piper-workflow"'
assert_contains "$codex_hub/.codex/config.toml" 'path = "./skills/brainstorm"'
assert_contains "$codex_hub/.codex/config.toml" 'path = "./skills/design-studio"'
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
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "Ralph may spawn the"
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "security_reviewer\`, \`verifier\`, \`security_reviewer"
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" "profile coverage"
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/ralph.md" '\$ARGUMENTS'
assert_not_contains "$codex_hub/.codex/skills/piper-workflow/references/superpowers.md" "permission profile"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "references/add-project.md"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "Orient"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "projects/registry.json"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "# Brainstorm"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "Divergent Toolkit"
assert_contains "$codex_hub/.codex/skills/brainstorm/SKILL.md" "rather than execute"
assert_not_contains "$codex_hub/AGENTS.md" "Permission profiles"
assert_not_contains "$codex_hub/AGENTS.md" "profile coverage"
assert_not_contains "$codex_hub/.codex/agents/implementer.toml" "local profile coverage"
assert_not_contains "$codex_hub/.codex/agents/reviewer.toml" 'plan, spec, task queue, build logs'
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
assert_contains "$codex_hub/.codex/config.toml" '[agents.investigator]'
assert_contains "$codex_hub/.codex/config.toml" '[agents.implementer]'
assert_contains "$codex_hub/.codex/config.toml" '[agents.reviewer]'
# Hook behavior, lane discovery, and canonical instruction contracts are checked
# with parsed output and complete normalized prose in test_distribution.py.

for hub in "$codex_hub"; do
  assert_not_contains "$hub/STATION.md" "profiles decide whether action categories"
  assert_contains "$hub/SECURITY.md" "\`external\` ask"
  assert_contains "$hub/CONVENTIONS.md" "Helpers protect cooperating operations"
  assert_not_contains "$hub/STATION.md" "profile coverage"
  assert_not_contains "$hub/STATION.md" "outside standing profiles"
  assert_contains "$hub/automation-policy.md" "Action Boundaries"
  assert_not_contains "$hub/automation-policy.md" "Permission Profiles"
  assert_contains "$hub/automation-policy.md" "no action-approval ask or approval record"
  assert_contains "$hub/automation-policy.md" "Piper never simulates a gate"
  assert_not_contains "$hub/automation-policy.md" "\`strict\`"
  assert_contains "$hub/automation-policy.md" "never a go-ahead"
  assert_not_contains "$hub/automation-policy.md" "\`local\`"
  assert_contains "$hub/automation-policy.md" "\`external\`"
  assert_contains "$hub/automation-policy.md" "\`exceptional\`"
  assert_contains "$hub/automation-policy.md" "an ask is a gate, not a trigger"
  assert_not_contains "$hub/automation-policy.md" "profile is a gate"
  assert_contains "$hub/automation-policy.md" "registered project source edits"
  assert_contains "$hub/automation-policy.md" "Ralph implementation edits are routine"
  assert_contains "$hub/automation-policy.md" "recorded in the lane"
  assert_contains "$hub/automation-policy.md" "standing policy notes"
  assert_contains "$hub/automation-policy.md" "profile-preference line"
  assert_contains "$hub/automation-policy.md" "only gate"
  assert_contains "$hub/automation-policy.md" "can never be pre-approved"
  assert_contains "$hub/automation-policy.md" "Non-destructive worktree creation is routine"
  assert_contains "$hub/automation-policy.md" "Deleting worktrees remains exceptional"
  assert_contains "$hub/automation-policy.md" "path-only commit preserving other"
  assert_contains "$hub/automation-policy.md" "exclusively assigned clean target and exact"
  assert_contains "$hub/automation-policy.md" "do not edit bootstrap-managed runtime config files"
  assert_contains "$hub/automation-policy.md" "add hooks as a Piper gate"
  assert_not_contains "$hub/automation-policy.md" "profile gate"
done
for skill_dir in "$codex_hub/.codex/skills"; do
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Divergent Toolkit"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Hand-Off Brief"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Register"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Artifact Signal Policy"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Orient"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "projects/registry.json"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "Inspect open lane headers"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "\`external\` or \`exceptional\` action"
  assert_not_contains "$skill_dir/brainstorm/SKILL.md" "permission profile"
  assert_contains "$skill_dir/brainstorm/SKILL.md" "read-only except explicit registration through the helper"
  assert_not_contains "$skill_dir/piper-workflow/SKILL.md" "permission profile"
  assert_not_contains "$skill_dir/piper-workflow/SKILL.md" "profile coverage"
  assert_not_contains "$skill_dir/piper-workflow/SKILL.md" "one-off approvals"
  assert_not_exists "$skill_dir/superpowers-planning/SKILL.md"
  assert_not_exists "$skill_dir/ralph-loop/SKILL.md"
  assert_contains "$skill_dir/review/SKILL.md" "Do not use this skill for general repo orientation"
  assert_contains "$skill_dir/review/SKILL.md" "selected wave, group, explicit slice, or"
  assert_contains "$skill_dir/review/SKILL.md" "integrated cross-wave diff"
  assert_contains "$skill_dir/review/SKILL.md" "selected lane"
  assert_contains "$skill_dir/review/SKILL.md" "base..group"
  assert_contains "$skill_dir/review/SKILL.md" "Route automation approval"
  assert_contains "$skill_dir/review/SKILL.md" 'root-session `automation-policy` skill'
  assert_contains "$skill_dir/review/SKILL.md" "confirmed-in-scope"
  assert_contains "$skill_dir/review/SKILL.md" "confirmed-out-of-scope"
  assert_contains "$skill_dir/review/SKILL.md" "false-positive"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Do not use this skill for ordinary local inspection"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "canonical global policy"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "action-boundary check"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "permission-profile manager"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Permission decisions and exceptional actions"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Registered project source edits are routine"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "\`local\` permission actions"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "nothing routes here for them"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "must use this skill before editing source"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "Non-destructive worktree creation or switching is"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "commits through \`piper-record\`; never unscoped"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "fresh explicit one-off instruction"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "outside standing profiles"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "routine, \`external\`, or \`exceptional\`"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "\`strict\`, \`local\`"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "do not edit bootstrap-managed runtime config files"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "hooks as a Piper gate"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "profile gate"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "never a go-ahead"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "in the lane's \`build-log.md\`"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "standing policy note"
  assert_contains "$skill_dir/automation-policy/SKILL.md" "projects/<project-id>/project.md"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "Record durable opt-ins or policy changes in"
  assert_not_contains "$skill_dir/automation-policy/SKILL.md" "Default Classifications"
  assert_not_exists "$skill_dir/hub-workflow/SKILL.md"
done

# Distribution refresh and migration tests are behavioral: compare actual files.
refresh_hub="$TMP_ROOT/refresh-hub"
"$BOOTSTRAP" "$refresh_hub" > "$TMP_ROOT/refresh-create.log"
printf 'local note\n' > "$refresh_hub/projects/README.md"
mkdir -p "$refresh_hub/projects/kept/work" "$refresh_hub/local-notes"
printf 'accepted decision\n' > "$refresh_hub/projects/kept/work/decisions.md"
printf 'user-owned\n' > "$refresh_hub/local-notes/note.md"
"$BOOTSTRAP" "$refresh_hub" > "$TMP_ROOT/refresh.log"
assert_contains "$refresh_hub/projects/README.md" "local note"
assert_contains "$refresh_hub/projects/kept/work/decisions.md" "accepted decision"
assert_contains "$refresh_hub/local-notes/note.md" "user-owned"

mkdir -p "$refresh_hub/.codex/hooks" "$refresh_hub/.piper/plugin/skills/old-skill"
printf 'old codex\n' > "$refresh_hub/.codex/hooks/old-managed.sh"
printf 'old codex skill\n' > "$refresh_hub/.piper/plugin/skills/old-skill/SKILL.md"
python3 - "$refresh_hub/.piper/hub-manifest.json" <<'PYMANIFEST'
import json, sys
from pathlib import Path
p = Path(sys.argv[1]); data = json.loads(p.read_text())
data['managed_files'] += ['.codex/hooks/old-managed.sh', '.piper/plugin/skills/old-skill/SKILL.md', 'projects/kept/work/decisions.md']
p.write_text(json.dumps(data))
PYMANIFEST
"$BOOTSTRAP" --dry-run "$refresh_hub" > "$TMP_ROOT/stale-dry.log"
assert_contains "$TMP_ROOT/stale-dry.log" "would remove stale managed hub file: .codex/hooks/old-managed.sh"
assert_file "$refresh_hub/.codex/hooks/old-managed.sh"
"$BOOTSTRAP" --runtime codex "$refresh_hub" > "$TMP_ROOT/stale-codex.log"
assert_not_exists "$refresh_hub/.codex/hooks/old-managed.sh"
assert_not_exists "$refresh_hub/.piper/plugin"
assert_contains "$refresh_hub/projects/kept/work/decisions.md" "accepted decision"

for choice in opencode deepagent codex,bad copilot,bad; do
  invalid_hub="$TMP_ROOT/invalid-$choice"
  if "$BOOTSTRAP" --runtime "$choice" "$invalid_hub" > "$TMP_ROOT/invalid-runtime.log" 2>&1; then fail "bootstrap should reject unsupported runtime"; fi
  assert_contains "$TMP_ROOT/invalid-runtime.log" "unsupported runtime"
  assert_not_exists "$invalid_hub"
done
python3 "$ROOT/tests/test_distribution.py" "$ROOT" "$TMP_ROOT"
python3 "$ROOT/tests/test_runtimes.py" "$ROOT" "$TMP_ROOT"
python3 "$ROOT/tests/test_records.py"
python3 "$ROOT/tests/test_integration.py"

project_repo="$TMP_ROOT/project-repo"
mkdir -p "$project_repo"
init_git_repo "$project_repo"
(cd "$project_repo" && printf 'sample
' > README.md && git add README.md && git commit -m "Initial sample" >/dev/null)
"$ADD_PROJECT" --hub "$refresh_hub" --repo "$project_repo" --project-id sample-project --display-name "Sample Project" > "$TMP_ROOT/add-project.log"
assert_file "$refresh_hub/projects/sample-project/project.md"
assert_file "$refresh_hub/projects/sample-project/memory.md"
assert_not_exists "$refresh_hub/projects/sample-project/decisions.md"
assert_contains "$refresh_hub/projects/sample-project/project.md" "Project Policy"
assert_contains "$refresh_hub/projects/sample-project/project.md" "Standing policy notes"
assert_not_contains "$refresh_hub/projects/sample-project/project.md" "Permission profile preference"
assert_not_exists "$refresh_hub/projects/sample-project/work"
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
"$ADD_PROJECT" --hub "$refresh_hub" --repo "$legacy_repo" --project-id legacy-project --display-name "Legacy Project" > "$TMP_ROOT/legacy-add-project.log"
assert_file "$refresh_hub/projects/legacy-project/project.md"
assert_contains "$TMP_ROOT/legacy-add-project.log" "update: .piper/project.json"
assert_not_contains "$legacy_repo/.piper/project.json" '"runtime"'
python3 -m json.tool "$legacy_repo/.piper/project.json" >/dev/null

hub_only_repo="$TMP_ROOT/hub-only-repo"
mkdir -p "$hub_only_repo"
init_git_repo "$hub_only_repo"
(cd "$refresh_hub" && ./bin/add-project --repo "$hub_only_repo" --project-id hub-only --hub-only) > "$TMP_ROOT/hub-only.log"
assert_file "$refresh_hub/projects/hub-only/project.md"
assert_not_exists "$refresh_hub/projects/hub-only/work"
assert_not_exists "$hub_only_repo/.piper/project.json"

# --- Project registry index ---
for hub in "$codex_hub" "$refresh_hub"; do
  assert_file "$hub/projects/registry.json"
  python3 -m json.tool "$hub/projects/registry.json" >/dev/null
done
assert_contains "$codex_hub/projects/registry.json" '"schema_version": 1'
empty_count=$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["projects"]))' "$codex_hub/projects/registry.json")
[ "$empty_count" = "0" ] || fail "expected fresh registry to be empty, got $empty_count entries"

# Three registrations in refresh_hub at this point: sample-project, legacy-project, hub-only.
refresh_count=$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["projects"]))' "$refresh_hub/projects/registry.json")
[ "$refresh_count" = "3" ] || fail "expected 3 registry entries in refresh_hub, got $refresh_count"
assert_contains "$refresh_hub/projects/registry.json" '"project_id": "sample-project"'
assert_contains "$refresh_hub/projects/registry.json" '"project_id": "legacy-project"'
assert_contains "$refresh_hub/projects/registry.json" '"project_id": "hub-only"'
project_repo_real=$(CDPATH= cd -- "$project_repo" && pwd -P)
assert_contains "$refresh_hub/projects/registry.json" "\"repo_path\": \"$project_repo_real\""

# Re-registering the same project_id is idempotent in the index.
python3 - "$refresh_hub/projects/legacy-project/project.md" <<'PY'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
new_line = "- Standing policy notes (read-only project, pre-approved external actions, closeout constraints, accepted risks): none recorded."
old_lines = "- Permission profile preference: strict unless recorded otherwise.\n- One-off approvals, accepted risks, and automation notes: none recorded."
if new_line not in text:
    raise SystemExit("expected the new policy line in legacy-project/project.md")
open(path, "w", encoding="utf-8").write(text.replace(new_line, old_lines))
PY
"$ADD_PROJECT" --hub "$refresh_hub" --repo "$legacy_repo" --project-id legacy-project --display-name "Legacy Project" > "$TMP_ROOT/legacy-re-add.log"
assert_contains "$refresh_hub/projects/legacy-project/project.md" "Permission profile preference: strict unless recorded otherwise."
assert_not_contains "$refresh_hub/projects/legacy-project/project.md" "Standing policy notes"
"$ADD_PROJECT" --hub "$refresh_hub" --repo "$project_repo" --project-id sample-project --display-name "Sample Project" > "$TMP_ROOT/re-add.log"
refresh_count_after=$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["projects"]))' "$refresh_hub/projects/registry.json")
[ "$refresh_count_after" = "3" ] || fail "re-registration changed entry count to $refresh_count_after"

# --description round-trips into the index.
desc_repo="$TMP_ROOT/desc-repo"
mkdir -p "$desc_repo"
init_git_repo "$desc_repo"
(cd "$desc_repo" && printf 'd
' > README.md && git add README.md && git commit -m "Initial desc" >/dev/null)
"$ADD_PROJECT" --hub "$refresh_hub" --repo "$desc_repo" --project-id desc-project --display-name "Desc Project" --description "Project for description test" > "$TMP_ROOT/desc-add.log"
assert_contains "$refresh_hub/projects/registry.json" '"description": "Project for description test"'

# Description over 120 chars is rejected.
long_desc="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
if "$ADD_PROJECT" --hub "$refresh_hub" --repo "$desc_repo" --project-id desc-project --description "$long_desc" > "$TMP_ROOT/desc-long.log" 2>&1; then
  fail "add-project should reject description over 120 chars"
fi
assert_contains "$TMP_ROOT/desc-long.log" "description must be 120 characters or fewer"

# A second project_id pointing at an already-registered repo_path is rejected (via the registry, not the repo marker).
dup_repo="$TMP_ROOT/dup-repo"
mkdir -p "$dup_repo"
init_git_repo "$dup_repo"
(cd "$dup_repo" && printf 'd
' > README.md && git add README.md && git commit -m "Initial dup" >/dev/null)
"$ADD_PROJECT" --hub "$refresh_hub" --repo "$dup_repo" --project-id dup-a --hub-only > "$TMP_ROOT/dup-a.log"
if "$ADD_PROJECT" --hub "$refresh_hub" --repo "$dup_repo" --project-id dup-b --hub-only > "$TMP_ROOT/dup-b.log" 2>&1; then
  fail "add-project should reject second project_id at same repo_path"
fi
assert_contains "$TMP_ROOT/dup-b.log" "already registered as project id 'dup-a'"

# --rebuild regenerates the index from project.md scan, dropping orphaned entries.
rm -rf "$refresh_hub/projects/desc-project"
"$ADD_PROJECT" --hub "$refresh_hub" --rebuild > "$TMP_ROOT/rebuild.log"
assert_contains "$TMP_ROOT/rebuild.log" "rebuild: projects/registry.json"
assert_not_contains "$refresh_hub/projects/registry.json" '"project_id": "desc-project"'
assert_contains "$refresh_hub/projects/registry.json" '"project_id": "sample-project"'
python3 -m json.tool "$refresh_hub/projects/registry.json" >/dev/null

# Dry-run does not mutate the registry.
"$ADD_PROJECT" --hub "$refresh_hub" --repo "$desc_repo" --project-id desc-project --description "Re-added" --dry-run > "$TMP_ROOT/desc-dry.log"
assert_contains "$TMP_ROOT/desc-dry.log" "would update: projects/registry.json"
assert_not_contains "$refresh_hub/projects/registry.json" "Re-added"

"$BOOTSTRAP" --runtime codex --dry-run "$TMP_ROOT/dry-new" > "$TMP_ROOT/dry.log"
assert_contains "$TMP_ROOT/dry.log" "would create managed hub file: STATION.md"
assert_not_exists "$TMP_ROOT/dry-new"

git_hub="$TMP_ROOT/git-hub"
"$BOOTSTRAP" --runtime codex --git-init "$git_hub" > "$TMP_ROOT/git-init.log"
assert_dir "$git_hub/.git"

if "$BOOTSTRAP" --runtime codex "$ROOT" > "$TMP_ROOT/source-refuse.log" 2>&1; then fail "bootstrap should refuse source repo"; fi
assert_contains "$TMP_ROOT/source-refuse.log" "refusing to initialize the bootstrap source"
if grep -R -n '{{' "$ROOT/generated/codex" > "$TMP_ROOT/placeholders.log"; then cat "$TMP_ROOT/placeholders.log" >&2; fail "unrendered template placeholder found"; fi
if grep -R -n '^argument-hint:\|^allowed-tools:\|^description:' "$ROOT/generated/codex/.codex/skills/piper-workflow/references" "$ROOT/generated/codex/.codex/skills/brainstorm/references" "$ROOT/generated/codex/.codex/skills/design-studio/references" > "$TMP_ROOT/refs-frontmatter.log"; then cat "$TMP_ROOT/refs-frontmatter.log" >&2; fail "skill references must not carry slash-command frontmatter"; fi
if grep -R -n '^description: [^"].*: ' "$ROOT/core/skills" "$ROOT/generated/codex/.codex/skills" > "$TMP_ROOT/skill-frontmatter.log"; then cat "$TMP_ROOT/skill-frontmatter.log" >&2; fail "unquoted skill description frontmatter with colon found"; fi
if grep -R -n -E '`(handoff|progress)\.md`' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-work-artifacts.log"; then cat "$TMP_ROOT/stale-work-artifacts.log" >&2; fail "active instructions must not use stale handoff.md or progress.md artifacts"; fi
if grep -R -n 'established docs location' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-project-local-artifacts.log"; then cat "$TMP_ROOT/stale-project-local-artifacts.log" >&2; fail "artifact persistence must keep Piper work artifacts hub-owned by default"; fi
if grep -R -n 'When an artifact changes, make it self-contained' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-self-contained-artifacts.log"; then cat "$TMP_ROOT/stale-self-contained-artifacts.log" >&2; fail "only context-pack should be the fully self-contained resume packet"; fi
if grep -R -n 'Update useful active work records, including' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-broad-artifact-updates.log"; then cat "$TMP_ROOT/stale-broad-artifact-updates.log" >&2; fail "Ralph slice bookkeeping must not broadly update every active artifact"; fi
if grep -R -n 'compact-safe reload state when active work records are in use' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-context-pack-every-planning.log"; then cat "$TMP_ROOT/stale-context-pack-every-planning.log" >&2; fail "Superpowers must defer context-pack unless a resume checkpoint is needed"; fi
if grep -R -n 'prepare compact-safe state at natural stopping points by updating' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-context-pack-natural-stops.log"; then cat "$TMP_ROOT/stale-context-pack-natural-stops.log" >&2; fail "runtime roots must not imply every natural stop updates context-pack"; fi
if grep -R -n -E 'one scoped task at a time|one scoped implementation slice|For ordinary slice-end bookkeeping|After ordinary Ralph slices|ordinary slice checkpoints|ordinary slice boundaries|next slice needs a clean context|active task neighborhood|last completed task|current task status|current task, next exact action|next task is safe|outside the task list|behavior the task did not ask|argument-hint: ".*current task' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" "$ROOT/scripts" > "$TMP_ROOT/stale-rigid-slice-workflow.log"; then cat "$TMP_ROOT/stale-rigid-slice-workflow.log" >&2; fail "active instructions must plan in slices, execute in waves, and checkpoint at boundaries"; fi
if grep -R -n -E "no artifact needed|short active plan in|written spec and plan required before implementation|For \`S1\`, prefer only \`active-plan.md\`|For \`S2\+\`, write|scope controls artifact|artifact weight|scope-appropriate checkpoints|active-spec\.md|active-plan\.md|verification\.md|specs/|plans/|runs/|plan, spec, task queue, build logs|implementer.s report" "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-scope-artifact-rules.log"; then cat "$TMP_ROOT/stale-scope-artifact-rules.log" >&2; fail "scope tiers and active prompts must use the compact artifact model"; fi
if grep -R -n -E 'For `S2/S3`, or for `S1`|do not commit unless the user approves through `automation-policy`|Piper Station compact protection|Ralph may spawn the|security_reviewer`, `verifier`, `security_reviewer|Bash\(git branch:\*\)|Bash\(git -C \* branch:\*\)|Bash\(git symbolic-ref:\*\)|Bash\(git -C \* symbolic-ref:\*\)' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-runtime-review-fixes.log"; then cat "$TMP_ROOT/stale-runtime-review-fixes.log" >&2; fail "runtime review fixes must not regress to stale compact, helper, or permission wording"; fi
if grep -R -n 'piper-workflow router\|piper workflow handles lookup, registration, orientation' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-router.log"; then cat "$TMP_ROOT/stale-router.log" >&2; fail "active instructions must not describe piper-workflow as the broad router"; fi
if grep -R -n -E 'At every checkpoint:|the complete required field list|Compact-safe state must include' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-checkpoint-script.log"; then cat "$TMP_ROOT/stale-checkpoint-script.log" >&2; fail "STATION.md must state the checkpoint invariant and one compact field list, not the old checkpoint script"; fi
if grep -R -n -E 'Include last completed boundary, current boundary|Git state: repo path, branch, HEAD|Group-level review state when a group exists|Piper artifact state:|context-pack.s resume snapshot|The compact state must include|Compact summary priorities' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-compact-field-lists.log"; then cat "$TMP_ROOT/stale-compact-field-lists.log" >&2; fail "commands and skills must point at the STATION compact field list instead of restating it"; fi
if grep -R -n 'Use one harness actively on a project at a time' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-one-harness.log"; then cat "$TMP_ROOT/stale-one-harness.log" >&2; fail "concurrency is per lane: one active session per lane, not one harness per project"; fi
if grep -R -n 'read-only band\|creates no hub records' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-brainstorm-readonly.log"; then cat "$TMP_ROOT/stale-brainstorm-readonly.log" >&2; fail "brainstorm registration wording must acknowledge the deterministic write exception"; fi
if grep -R -n -E 'automation approval\. Route those through|automation approval.*piper-workflow' "$ROOT/core/skills/review/SKILL.md" "$ROOT/generated/codex/.codex/skills/review/SKILL.md" > "$TMP_ROOT/stale-review-automation-routing.log"; then cat "$TMP_ROOT/stale-review-automation-routing.log" >&2; fail "review skill must route automation approval directly to automation-policy"; fi
if grep -R -n -E '(^|[^[:alnum:]_])A[0-3]([^[:alnum:]_]|$)|A-tier|Automation Tiers|automation tiers' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-automation-tiers.log"; then cat "$TMP_ROOT/stale-automation-tiers.log" >&2; fail "active instructions must use action classes, not stale automation tiers"; fi
if grep -R -n -E '[Pp]ermission [Pp]rofile|profile coverage|profile boundary|profile preference|policy preference|`strict`|`local` (permission|profile|coverage)|covers `local`|local profile' "$ROOT/core" "$ROOT/bootstrap/add-project.sh" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-profiles.log"; then cat "$TMP_ROOT/stale-profiles.log" >&2; fail "active instructions must use action classes, not permission profiles"; fi
if grep -R -n -E 'protected local git action|Risk tier controls approval|Risk tier determines whether execution|L2.*dependency|dependency or CI action' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-permission-risk-mix.log"; then cat "$TMP_ROOT/stale-permission-risk-mix.log" >&2; fail "active instructions must keep Ralph risk separate from action classes"; fi
if grep -R -n -E 'protected finish action|Do not commit, push, merge, delete, install dependencies|exceptional actions through the permission profile gate|exceptional actions may proceed|Only after the workflow reaches that action and the permission profile allows it' "$ROOT/core" "$ROOT/adapters" "$ROOT/generated" > "$TMP_ROOT/stale-permission-profile-semantics.log"; then cat "$TMP_ROOT/stale-permission-profile-semantics.log" >&2; fail "active instructions must keep exceptional actions one-off and source edits routine"; fi
# Codex procedure routing is checked through actual skill reference files and
# the root's full statement; a line-based grep misreads wrapped negation.


git -C "$ROOT" diff --check

echo "All tests passed."
