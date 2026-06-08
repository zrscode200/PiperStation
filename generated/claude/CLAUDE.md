# Piper Station (Claude Code)

This directory is a Piper Station hub for coordinating Claude Code work across registered project repositories.

Treat this hub as lightweight cross-project context, not a workflow engine. The hub keeps small durable records per project. Source code lives in the registered repos. Active continuity lives lazily inside each project's optional `work/` directory.

Claude Code auto-loads this file. It is the always-on operating contract for work in this hub.

## Required Behavior

- Treat this hub as lightweight cross-project context, not as a source repo for registered projects.
- Do not copy project source code into the hub.
- Register projects with `/add-project` or `./bin/add-project`.
- Keep project records small: `project.md`, `memory.md`, `decisions.md`, and optional lazy `work/`.
- Use Claude Code-native behavior for planning, implementation, review, testing, subagents, handoff, and git operations.
- Do not start work, create plans, checkpoint state, commit, push, install dependencies, or edit project source as a side effect of registration.
- Do not store secrets, credentials, private keys, customer data, or raw sensitive logs in hub records.
- Use `automation-policy.md` before crossing the active permission profile boundary for source edits, local git, pushes, pull requests, dependency installs, non-destructive worktree create or switch operations, network, CI, deployments, or external automation. Deleting worktrees and other exceptional actions always need explicit one-off approval.

## Required Reading

Use these docs as the canonical human-readable references:

- `STATION.md` - primary operating guide.
- `PRODUCT.md` - product intent and non-goals.
- `ARCHITECTURE.md` - hub structure and project record boundaries.
- `CONVENTIONS.md` - naming, context, and work style conventions.
- `TESTING.md` - verification expectations.
- `SECURITY.md` - sensitive-data and boundary rules.
- `automation-policy.md` - permission profiles and action-boundary gates.

## Instruction Precedence

`STATION.md` defines shared behavior and ownership. `automation-policy.md`
defines permission profiles and action boundaries. This `CLAUDE.md` is the
always-on Claude Code summary. Skills route intent, slash commands provide
procedures, hooks give lifecycle reminders, and agents stay within their
delegated roles.

## Hub Commands

Slash commands are the user entry points. Run them from this hub directory.

- `/add-project <repo-path> [project-id]` - register a project repo with this hub.
- `/superpowers <project-id> [request]` - enter Superpowers Mode: discovery, spec, and plan.
- `/ralph <project-id> [task]` - enter Ralph Mode: execute one scoped task with verification, Implementation Review Gate, and compact-safe updates.
- `/compact-handoff [project-id]` - prepare a project's work records so the user can safely run `/compact`.

The deterministic shell equivalent for registration is:

```sh
./bin/add-project --repo /path/to/project-repo --project-id project-id
```

Use `--hub-only` when repo marker files are not wanted.

## Mode Routing

`brainstorm` owns the decision-quality front door for the divergent phase —
orientation, framing, divergence, investigation, and routing — and stays
read-only. `piper-workflow` owns convergent execution once a direction is set.
Slash commands are explicit shortcuts into convergent execution:
`/superpowers`, `/ralph`, and `/compact-handoff`. The front door needs no
command — a project-work request that is ambiguous or lacks an explicit
execution signal enters through `brainstorm`.

Route each request through the smallest mode that fits.

- Brainstorm (front door) - orient, frame the problem, weigh options, investigate, route explicit registration through the helper, and produce a decision-ready hand-off brief. Read-only except for that deterministic registration path.
- Superpowers Mode - verify the handed-off direction, then specify and plan before substantial implementation.
- Ralph Mode - execute one scoped task at a time, verify, drift-check, and use an implementation review gate for substantial slices.
- Review Mode - first check whether the work matches the request/spec/plan, then check code quality.
- Finish Mode - report verification, residual risk, changed files, and commit or pull request options without mutating git automatically.

Use `brainstorm` as the broad natural-language front door and `piper-workflow`
for convergent execution. Use `/superpowers` for explicit formal planning,
`/ralph` for explicit one-task execution, `review` for explicit review work or
review gates, and `automation-policy` before crossing the active permission
profile boundary. Prefer consequence language such as "I will keep this
read-only" or "I will create Ralph-ready work records" over ceremonial mode
announcements.

### Scope Tiers

Scope tiers are advisory sizing, not artifact rules.

- `S0` - direct small task; stay in chat unless a durable need appears.
- `S1` - modest work; use a lightweight plan only when continuity matters.
- `S2` - substantial work; stable requirements, planning, decomposition, or verification records may help before execution.
- `S3` - broad or long-running work; split into milestones or sub-specs when that keeps execution clear.

### Risk Tiers

- `L0` - routine implementation risk.
- `L1` - normal implementation risk.
- `L2` - guarded implementation risk; get explicit confirmation before Ralph edits.
- `L3` - blocked inside Ralph; stop for replanning, a human decision, or an exceptional permission decision.

### Permission Profiles

- `strict` - read-only inspection, planning, review, safe git status/log/diff style commands, deterministic registration, and drafting.
- `local` - `strict` plus registered project source edits, Piper artifact updates, local checks/build/test, non-destructive worktree create or switch operations, and non-destructive local git actions when the workflow has reached that action.
- `external` - `local` plus dependency install or update, networked commands, push, pull request creation or update, CI reruns or repair, and other non-destructive external-system actions.
- `exceptional` - outside profiles; always requires explicit one-off approval.

Permission profiles gate action categories. They do not change Piper phase routing, artifact checkpoints, Ralph review gates, or finish behavior. Record project-level profile preferences in `projects/<project-id>/decisions.md`.

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
  decisions.md
  work/              # optional, created by Claude Code only when useful
```

- `project.md` binds the project id to the real repo path and stores a small project overview.
- `memory.md` stores durable facts, preferences, stable conventions, and reusable context.
- `decisions.md` stores meaningful choices, tradeoffs, accepted risks, and policies future work should not silently reopen.
- `work/` stores optional active continuity such as specs, plans, task queues, verification, and context packs.

Do not put routine progress logs, command output, temporary plans, secrets, or raw sensitive logs into `memory.md` or `decisions.md`.

Registration must not create `work/`. Claude Code may create it during active work when continuity is useful.

## Artifact Persistence

Piper work artifacts stay under `projects/<project-id>/work/` by default. Do not move specs, plans, queues, verification, or context packs into the registered project repo unless the user explicitly asks for a project-local copy.

When active work artifacts change, report them at natural checkpoints separately from registered project source changes. Check git state for both the real project repo and the Piper Station hub before finish or compact when artifacts changed. Updating artifacts is allowed local assistance; committing Piper artifact changes is a `local` permission action handled through `automation-policy.md` when the active profile does not already cover local git. Do not ask to commit after every artifact edit; ask only at continuity checkpoints defined in `STATION.md`.

Record artifacts economically: `context-pack.md` is the only fully self-contained resume packet. Keep specs, plans, queues, and verification records lean and purpose-specific.

## Working On A Project

Before editing a registered project:

1. Read this file and `STATION.md`.
2. Look up the project in `projects/registry.json` to confirm registration and resolve `repo_path`. If the user's id is ambiguous, list the registered `project_id` entries (with `description` where present) and ask which one to use.
3. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md` for the rich record.
4. Read `projects/<project-id>/work/context-pack.md` when present.
5. Inspect the real repo path with `git status`, current branch, current HEAD, and the files relevant to the user request.
6. If the repo is outside the hub, ensure Claude Code has workspace access through `/add-dir <repo-path>` or by launching with `claude --add-dir <repo-path>` before editing.
7. State any uncommitted or recent user changes that affect the task.
8. Make a short task-specific plan unless the user has asked only for review or explanation.
9. Before Ralph execution or source edits, verify the real project repo is writable in the active session and confirm the active permission profile covers `local` source edits; if writable access or `local` coverage is absent, state what is required and route profile coverage through `automation-policy.md` before editing.
10. Implement in the real project repo, using the repo's own conventions and verification commands.
11. Update `projects/<project-id>/work/` only when active continuity is useful.
12. Update hub `memory.md` or `decisions.md` only when durable context changed.

## Skills And Agents

The Claude Code layer is intentionally small:

- Commands are user entry points under `.claude/commands/`.
- Skills are behavior guides under `.claude/skills/`.
- Subagents live under `.claude/agents/` for the same helper role set as the
  Codex surface: reviewer, implementer, tester, verifier, architect,
  docs-researcher, and security-reviewer.
- The docs-researcher wires the OpenAI developer docs MCP server in its own
  subagent frontmatter, matching the Codex docs-researcher role without making
  every Claude Code session load that server.

Root docs are the canonical references. Skills should point back to these docs instead of duplicating the whole station manual.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial slices are implemented and initially verified, before marking the slice complete in active work records. The reviewer inspects the actual code or diff with the plan, spec, task queue, and verification logs as context.

Review gate selection is based on scope and change impact. Risk tier controls Ralph implementation confirmation before editing, not permission profile. Review gates are required for `S2/S3` slices and queued tasks that touch foundational behavior such as bootstrap, install, update, registration, generated commands, hooks, settings, config, test harnesses, project or hub ownership, security policy, or automation policy.

The main Claude Code session must validate reviewer findings before acting: give each finding an explicit verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive` — before editing any code, then apply only `confirmed-in-scope` fixes, turn `confirmed-out-of-scope` findings into follow-up notes or tasks, and reverify review-driven fixes with the narrowest meaningful command for the fixed behavior. If a required or expected gate is skipped, record review debt and do not continue to dependent tasks until the debt is resolved or explicitly accepted by the user.

## Compaction

Ralph should update `projects/<id>/work/context-pack.md` when pausing, preparing for compact, finishing, blocked, crossing a milestone, context is low, switching projects, or materially changing the plan/spec. Ordinary slice bookkeeping should stay in `task-queue.md` and `verification.md`.

The compact state must include: goal, last completed task, current task status, next exact action, scope boundary, files to inspect first after compact, known reference paths, verification status, review state, drift result, blockers and risks, git state, broad-search triggers, stop reason, and what to hand a human or fresh agent. The next exact action should be a file to open, command to run, or question to answer, specific enough for a fresh Claude Code session to continue cold.

Compact summary priorities are the fields that reduce expensive resume work: next exact action, scope boundary, files to inspect first, verification state, review state, drift result, git state, blockers, risks, and broad-search triggers. Keep them concise and specific.

`/compact` is human-triggered. Ralph may pause and say the state is compact-ready when context is low, a milestone just finished, or the next slice needs a clean context. Ralph should continue normally when the next task is safe and context is not a concern. Do not claim `/compact` ran unless the user or Claude Code actually ran it.

Claude Code compact-protection hooks provide user-visible lifecycle guidance for manual or automatic compaction. `PreCompact` surfaces the Piper Station fields that matter before compacting, and `PostCompact` surfaces the resume anchors after compacting. The reliable model-visible resume path is still `SessionStart` with source `compact`. Hooks must not edit work records, run verification, commit, push, or invoke `/compact`.

Future runtime-style auto-compact protection could snapshot minimal active state
to `projects/<id>/work/` immediately before automatic compaction. That would
require a reliable active-project/session-state source and explicit ownership
rules for hook-written records. Keep this as future design work, not current
hub-lite behavior.

After compact, start from the designed resume anchors: `context-pack.md`, `task-queue.md`, `active-plan.md`, `verification.md`, project `decisions.md`, and live branch/HEAD/status. Then rebuild enough of the active task neighborhood to work safely. Expand beyond that for concrete triggers such as a stale resume packet, missing acceptance criteria, failing verification, generated parity, security or permissions behavior, or review scope.

## Project Repos

Project repos keep source code. Registration may add `.piper/project.json` and `PIPER.md`, but those marker files do not make the repo a Piper runtime.
