# Piper Station Agent Instructions (Codex)

This directory is a Piper Station hub-lite workspace. It is the central launch
point for Codex work across registered project repositories.

Codex auto-loads this `AGENTS.md` at every session. Treat it as the always-on
operating contract for project work in this hub.

## Operating Contract

- Treat this hub as coordination context, not as a source repo for registered
  projects.
- Do not copy project source code into the hub.
- Register project repos with `./bin/add-project` or via the `brainstorm`
  skill.
- Registration only updates hub project records and optional repo marker files.
  It must not start implementation work, create plans, checkpoint state,
  commit, push, install dependencies, or edit project source files.
- Work on project source code only in the real repo path recorded in
  `projects/<project-id>/project.md`.
- When a registered project repo is outside the current Codex sandbox, start
  Codex with `--add-dir <project-repo>` (or otherwise grant writable workspace
  access) before Ralph executes. Registration can record an outside path, but
  edits require writable access in the active session.
- Use Codex-native behavior for planning, implementation, review, testing,
  subagents, handoff, and git operations.

## Codex Discovery Surfaces

Codex CLI discovers Piper Station behavior through these surfaces. Codex does
not auto-surface a `.codex/commands/` directory as slash commands; the
`brainstorm` and `piper-workflow` skills are the entry points instead.

- `AGENTS.md` (this file) — always loaded.
- `.codex/skills/brainstorm/SKILL.md` — decision-quality front door for the
  divergent phase (orient, frame, diverge, investigate, route). Trigger via
  `$brainstorm ...` or by stating the intent.
- `.codex/skills/brainstorm/references/` — the registration procedure
  (`add-project`) cited by the front door; orientation is inline in the skill.
- `.codex/skills/piper-workflow/SKILL.md` — convergent execution entry (formal
  planning, Ralph, compaction). Trigger via `$piper-workflow ...` once direction
  is set.
- `.codex/skills/piper-workflow/references/` — convergent procedure bodies
  (superpowers, ralph, compact-handoff) cited by the skill.
- `.codex/skills/review/SKILL.md` — explicit review and Ralph review-gate
  behavior.
- `.codex/skills/automation-policy/SKILL.md` — permission-profile manager and
  action-boundary gate.
- `.codex/agents/*.toml` declared in `config.toml`'s `[agents.X]` blocks —
  `reviewer`, `architect`, `security_reviewer`, `docs_researcher`, `tester`,
  `verifier`, `implementer` (role names match the `name = "..."` field in each
  `.toml`).
- `.codex/hooks/*.sh` wired in `hooks.json` — `SessionStart` (with
  `startup|resume|compact` matcher), `PreCompact`, `PostCompact`.
- `.codex/compact-prompt.md` referenced by `experimental_compact_prompt_file`.

## Required Reading

When working in this hub, use these docs as the canonical references:

- `STATION.md`: primary operating guide.
- `PRODUCT.md`: product intent and non-goals.
- `ARCHITECTURE.md`: hub and project record structure.
- `CONVENTIONS.md`: naming, context, and work style conventions.
- `TESTING.md`: verification expectations.
- `SECURITY.md`: sensitive-data and boundary rules.
- `automation-policy.md`: permission profiles and action-boundary gates.

## Instruction Precedence

`STATION.md` defines shared behavior and ownership. `automation-policy.md`
defines permission profiles and action boundaries. This `AGENTS.md` is the
always-on Codex summary. Skills route intent, command references provide
procedures, hooks give lifecycle reminders, and agents stay within their
delegated roles.

## Project Records

`projects/registry.json` is the hub-owned index of registered projects. Use it
to resolve a `project_id` to its `repo_path` and to list what this hub knows.
Per-project files remain the canonical rich record; the index is a derived
lookup, regenerable via `./bin/add-project --rebuild`.

Each registered project has:

```text
projects/<project-id>/
  project.md
  memory.md
  work/              # optional, created by Codex only when useful
```

- `project.md` binds the project id to the real repo path and stores a small
  project overview plus project policy preferences.
- `memory.md` stores durable facts, preferences, stable conventions, and
  reusable context.
- Optional `decisions.md` stores substantial decision logs future work should
  not silently reopen.
- `work/` stores optional active work continuity such as roadmap, active work,
  build log, compact pack, and durable task queue records.

Do not put routine progress logs, command output, temporary plans, secrets, or
raw sensitive logs into durable hub records.

Registration must not create `work/`. Codex may create it during active work
when continuity is useful.

## Artifact Persistence

Piper work artifacts stay under `projects/<project-id>/work/` by default. Do
not move roadmap, active work, build log, queues, or context packs into the
registered project repo unless the user explicitly asks for a project-local
copy.

When active work artifacts change, report them at natural checkpoints
separately from registered project source changes. Check git state for both
the real project repo and the Piper Station hub before finish or compact when
artifacts changed. Updating artifacts is allowed local assistance; committing
Piper artifact changes is a `local` permission action handled through
`automation-policy.md` when the active profile does not already cover local
git. Do not ask to commit after every artifact edit; ask only at continuity
checkpoints defined in `STATION.md`.

Record artifacts economically: `context-pack.md` is the only fully
self-contained resume packet. Keep roadmap, active-work, build-log, and queue
records lean and purpose-specific.

Plan in slices, execute in waves, and checkpoint at boundaries. Slices are
decomposition units; waves are implementation and checkpoint units. Detail the
current wave enough to execute safely, and sketch later waves only when the
current code, context, and prior results make them reliable.

## Mode Routing

`brainstorm` owns the decision-quality front door for the divergent phase —
orientation, framing, divergence, investigation, and routing — and stays
read-only. `piper-workflow` owns convergent execution once a direction is set.
State the intent (or invoke `$brainstorm ...` / `$piper-workflow ...`); a
project-work request that is ambiguous or lacks an explicit execution signal
enters through `brainstorm`.

Route each request through the smallest mode that fits:

- Brainstorm (front door): orient, frame the problem, weigh options,
  investigate, route explicit registration through the helper, and produce a
  decision-ready hand-off brief. Read-only except for that deterministic
  registration path.
- Superpowers Mode: verify the handed-off direction, then specify and plan
  before substantial implementation.
- Ralph Mode: execute the current active-work wave, one explicit slice, or one
  queued task, with implementation review gates at meaningful boundaries.
- Review Mode: first check whether the work matches the request or active work,
  then check code quality.
- Finish Mode: verify, summarize, and present commit or PR options without
  mutating git automatically.

Use `brainstorm` as the broad natural-language front door and `piper-workflow`
for convergent execution. Use the `review` skill for explicit review work or
review gates, and `automation-policy` before crossing the active permission
profile boundary. Prefer consequence language such as "I will keep this
read-only" or "I will create Ralph-ready work records" over ceremonial mode
announcements.

Scope tiers are advisory sizing, not artifact rules:

- `S0`: direct small task; stay in chat unless a durable need appears.
- `S1`: modest work; use `active-work.md` only when continuity matters.
- `S2`: substantial work; current-wave continuity, durable checkpoints, or
  durable queued execution may help before execution.
- `S3`: broad or long-running work; track group or milestone direction in
  roadmap when that keeps execution clear.

Risk tiers:

- `L0`: routine implementation risk.
- `L1`: normal implementation risk.
- `L2`: guarded implementation risk; get explicit confirmation before Ralph
  edits.
- `L3`: blocked inside Ralph; stop for replanning, a human decision, or an
  exceptional permission decision.

Permission profiles:

- `strict`: read-only inspection, planning, review, safe git status/log/diff
  style commands, deterministic registration, and drafting.
- `local`: `strict` plus registered project source edits, Piper artifact
  updates, local checks/build/test, non-destructive worktree create or switch
  operations, and non-destructive local git actions when the workflow has
  reached that action.
- `external`: `local` plus dependency install or update, networked commands,
  push, pull request creation or update, CI reruns or repair, and other
  non-destructive external-system actions.
- `exceptional`: outside profiles; always requires explicit one-off approval.

Permission profiles gate action categories. They do not change Piper phase
routing, artifact checkpoints, Ralph review gates, or finish behavior. Record
project-level profile preferences in `projects/<project-id>/project.md`.

## Working On A Project

Before editing a registered project:

1. Read this file and `STATION.md`.
2. Look up the project in `projects/registry.json` to confirm registration and
   resolve `repo_path`. If the user's id is ambiguous, list the registered
   `project_id` entries (with `description` where present) and ask which one
   to use.
3. Read `projects/<project-id>/project.md`, `memory.md`, and optional
   `decisions.md` when present.
4. Read `projects/<project-id>/work/context-pack.md`, `active-work.md`,
   `build-log.md`, optional `task-queue.md`, and `roadmap.md` when present and
   relevant.
5. Inspect the real repo path with git status, current branch, current HEAD,
   and the files relevant to the user request.
6. State any uncommitted or recent user changes that affect the task.
7. Make a short task-specific plan unless the user has asked only for review or
   explanation.
8. Before Ralph execution or source edits, verify the real project repo is
   writable in the active session and confirm the active permission profile
   covers `local` source edits. If the repo is outside the current Codex
   sandbox, ensure Codex was started with `--add-dir <project-repo>` or that
   the sandbox otherwise grants writable access. If `local` profile coverage
   is absent, route through `automation-policy.md` before editing.
9. Implement in the real project repo, using the repo's own conventions and
   verification commands.
10. Update `projects/<project-id>/work/` only when active continuity is useful.
11. Update hub `memory.md`, `project.md` policy notes, or optional
    `decisions.md` only when durable context changed.

## Subagents

The hub declares seven Codex subagent roles in `config.toml` and provides their
`.toml` configs under `.codex/agents/`:

- `reviewer` — read-only implementation review for Ralph review gates.
- `implementer` — scoped implementation when the user explicitly delegates.
- `tester` — writes test-layer files, fixtures, or test data only when
  explicitly delegated.
- `verifier` — strict read-only helper for existing checks and failure
  analysis; it reports when a check needs writable state.
- `architect` — read-only architecture review for broad design and boundary
  risk.
- `docs_researcher` — documentation research through official docs and MCP
  tools.
- `security_reviewer` — read-only security review for auth, permissions,
  data, networking, secrets, and dependency trust.

Spawn a subagent with the matching `agent_type` when its specific role
applies. Implementation stays with the main session unless the user explicitly
asks for `implementer` delegation. Verify all subagent findings in the main
session before acting on them.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial
waves, queued work, or high-impact slices are implemented and initially
verified, before marking the boundary complete in active work records. The
reviewer subagent inspects the actual code or diff with `active-work.md`,
`build-log.md`, optional `task-queue.md`, and relevant surrounding code as
context.

Review gate selection is based on scope and change impact. Risk tier controls
Ralph implementation confirmation before editing, not permission profile.
Review gates are required for `S2/S3` wave or group boundaries and queued tasks
that touch foundational behavior such as bootstrap, install, update,
registration, generated commands, hooks, settings, config, test harnesses,
project or hub ownership, security policy, or automation policy.

The main agent must validate reviewer findings before acting: give each finding
an explicit verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or
`false-positive` — before editing any code, then apply only `confirmed-in-scope`
fixes, turn `confirmed-out-of-scope` findings into follow-up notes or tasks, and
reverify review-driven fixes with the narrowest meaningful command for the fixed
behavior. Record the gate status or skip reason when
active work records are in use. If a required or expected gate is skipped,
record review debt in active work records and do not continue to dependent
tasks until the debt is resolved or explicitly accepted by the user.

## Compaction Discipline

Codex CLI fires `PreCompact` and `PostCompact` hooks around compaction, and
`SessionStart` with `source=compact` after a compact completes. The
`PreCompact` hook surfaces a user-facing reminder; the model-visible
post-compact context arrives via the `SessionStart` hook (with
`hookSpecificOutput.additionalContext`). The hooks must not edit work
records, commit, push, or invoke `/compact`.

During Ralph Mode, update `context-pack.md` when pausing, preparing for compact,
finishing, blocked, crossing a milestone, context is low, switching projects,
or materially changing active work. Internal slice progress should stay inside
the current wave unless risk, verification, or drift requires a stop. Append
`build-log.md` at wave, review/fix, blocker, milestone, finish, or other
meaningful boundaries, and update optional `task-queue.md` only when a durable
queue is in use. If context is low or the next wave needs a clean context,
pause and tell the user the state is compact-ready and they may run `/compact`.

Do not claim `/compact` was run unless the user or Codex actually ran it.

After compact, start from the designed resume anchors: `context-pack.md`,
`active-work.md`, `build-log.md`, optional `task-queue.md`, project
`project.md`, `memory.md`, optional `decisions.md`, and live
branch/HEAD/status. Read `roadmap.md` when longer-horizon direction matters.
Then rebuild enough of the active boundary neighborhood to work safely. Expand
beyond that for concrete triggers such as a stale resume packet, missing
acceptance criteria, failing verification, generated parity, security or
permissions behavior, or review scope.

## Permission Boundaries

Use `automation-policy.md` before crossing the active profile boundary for
source edits, local git, pushes, merges, pull requests, dependency installs,
non-destructive worktree create or switch operations, long-running commands,
networked commands, CI changes, deployments, or external automation. Deleting
worktrees and other exceptional actions always need explicit one-off approval.
