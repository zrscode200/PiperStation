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
- Ask before commits, pushes, merges, pull requests, dependency installs, worktree changes, long-running or networked commands, destructive git actions, CI changes, deployments, or external automation. See `automation-policy.md`.

## Required Reading

Use these docs as the canonical human-readable references:

- `STATION.md` - primary operating guide.
- `PRODUCT.md` - product intent and non-goals.
- `ARCHITECTURE.md` - hub structure and project record boundaries.
- `CONVENTIONS.md` - naming, context, and work style conventions.
- `TESTING.md` - verification expectations.
- `SECURITY.md` - sensitive-data and boundary rules.
- `automation-policy.md` - approvals required for automation and external actions.

## Hub Commands

Slash commands are the user entry points. Run them from this hub directory.

- `/add-project <repo-path> [project-id]` - register a project repo with this hub.
- `/work-on <project-id> [request]` - orient to a registered project and route through Intent, Superpowers, Ralph, Review, or Finish modes.
- `/superpowers <project-id> [request]` - enter Superpowers Mode: discovery, spec, and plan.
- `/ralph <project-id> [task]` - enter Ralph Mode: execute one scoped task with verification, Implementation Review Gate, and compact-safe updates.
- `/compact-handoff [project-id]` - prepare a project's work records so the user can safely run `/compact`.

The deterministic shell equivalent for registration is:

```sh
./bin/add-project --repo /path/to/project-repo --project-id project-id
```

Use `--hub-only` when repo marker files are not wanted.

## Mode Routing

`piper-workflow` owns natural-language dispatch for ordinary project work.
Slash commands are explicit shortcuts into the same behavior. Use `/work-on`
when the user explicitly wants the routing command; otherwise let
`piper-workflow` handle project-work requests directly.

Route each request through the smallest mode that fits.

- Intent Mode - identify the project, user goal, scope tier, risk tier, and next safe mode.
- Superpowers Mode - discover, specify, and plan before substantial implementation.
- Ralph Mode - execute one scoped task at a time, verify, drift-check, and use an implementation review gate for substantial slices.
- Review Mode - first check whether the work matches the request/spec/plan, then check code quality.
- Finish Mode - report verification, residual risk, changed files, and commit or pull request options without mutating git automatically.

Use `piper-workflow` as the only broad natural-language project-work router.
Use `/superpowers` for explicit formal planning, `/ralph` for explicit one-task
execution, `review` for explicit review work or review gates, and
`automation-policy` before protected automation or external actions. Prefer
consequence language such as "I will keep this read-only" or "I will create
Ralph-ready work records" over ceremonial mode announcements.

### Scope Tiers

- `S0` - direct small task, no artifact needed.
- `S1` - short active plan in `projects/<id>/work/active-plan.md`.
- `S2` - written spec and plan required before implementation.
- `S3` - split into milestones or sub-specs.

### Risk Tiers

- `L0` - trivial or local.
- `L1` - normal implementation.
- `L2` - explicit user confirmation required before Ralph executes.
- `L3` - forbidden inside Ralph; stop and ask.

### Automation Tiers

- `A0` - allowed local assistance.
- `A1` - ask before acting.
- `A2` - explicit opt-in required.
- `A3` - forbidden by default.

See `automation-policy.md` for full classification.

## Project Records

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
- `work/` stores optional active continuity such as specs, plans, task queues, progress, verification, handoff notes, and context packs.

Do not put routine progress logs, command output, temporary plans, secrets, or raw sensitive logs into `memory.md` or `decisions.md`.

Registration must not create `work/`. Claude Code may create it during active work when continuity is useful.

## Working On A Project

Before editing a registered project:

1. Read this file and `STATION.md`.
2. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md`.
3. Read `projects/<project-id>/work/context-pack.md` when present.
4. Inspect the real repo path with `git status`, current branch, current HEAD, and the files relevant to the user request.
5. If the repo is outside the hub, ensure Claude Code has workspace access through `/add-dir <repo-path>` or by launching with `claude --add-dir <repo-path>` before editing.
6. State any uncommitted or recent user changes that affect the task.
7. Make a short task-specific plan unless the user has asked only for review or explanation.
8. Before Ralph execution or source edits, verify the real project repo is writable in the active session or state that writable access is required.
9. Implement in the real project repo, using the repo's own conventions and verification commands.
10. Update `projects/<project-id>/work/` only when active continuity is useful.
11. Update hub `memory.md` or `decisions.md` only when durable context changed.

## Skills And Agents

The Claude Code layer is intentionally small:

- Commands are user entry points under `.claude/commands/`.
- Skills are behavior guides under `.claude/skills/`.
- Subagents live under `.claude/agents/` for the same helper role set as the
  Codex surface: reviewer, implementer, tester, architect, docs-researcher, and
  security-reviewer.
- The docs-researcher wires the OpenAI developer docs MCP server in its own
  subagent frontmatter, matching the Codex docs-researcher role without making
  every Claude Code session load that server.

Root docs are the canonical references. Skills should point back to these docs instead of duplicating the whole station manual.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial slices are implemented and initially verified, before marking the slice complete in active work records. The reviewer inspects the actual code or diff with the plan, spec, task queue, and verification logs as context.

Review gate selection is based on scope and change impact. Risk tier controls approval. Review gates are required for `S2/S3` slices and queued tasks that touch foundational behavior such as bootstrap, install, update, registration, generated commands, hooks, settings, config, test harnesses, project or hub ownership, security policy, or automation policy.

The main Claude Code session must verify reviewer findings before acting, apply only valid in-scope fixes, and reverify review-driven fixes with the narrowest meaningful command for the fixed behavior. If a required or expected gate is skipped, record review debt and do not continue to dependent tasks until the debt is resolved or explicitly accepted by the user.

## Compaction

Ralph should prepare compact-safe state at natural stopping points by updating `projects/<id>/work/context-pack.md` and, when pausing, `projects/<id>/work/handoff.md`.

The compact state must include: goal, last completed task, current task status, next exact action, scope boundary, files to inspect first after compact, known reference paths, verification status, review state, drift result, blockers and risks, git state, broad-search triggers, and stop reason. The next exact action should be a file to open, command to run, or question to answer, specific enough for a fresh Claude Code session to continue cold.

Compact summary priorities are the fields that reduce expensive resume work: next exact action, scope boundary, files to inspect first, verification state, review state, drift result, git state, blockers, risks, and broad-search triggers. Keep them concise and specific.

`/compact` is human-triggered. Ralph may pause and say the state is compact-ready when context is low, a milestone just finished, or the next slice needs a clean context. Ralph should continue normally when the next task is safe and context is not a concern. Do not claim `/compact` ran unless the user or Claude Code actually ran it.

Claude Code compact-protection hooks provide user-visible lifecycle guidance for manual or automatic compaction. `PreCompact` surfaces the Piper Station fields that matter before compacting, and `PostCompact` surfaces the resume anchors after compacting. The reliable model-visible resume path is still `SessionStart` with source `compact`. Hooks must not edit work records, run verification, commit, push, or invoke `/compact`.

Future runtime-style auto-compact protection could snapshot minimal active state
to `projects/<id>/work/` immediately before automatic compaction. That would
require a reliable active-project/session-state source and explicit ownership
rules for hook-written records. Keep this as future design work, not current
hub-lite behavior.

After compact, start from the designed resume anchors: `context-pack.md`, `handoff.md`, `task-queue.md`, `active-plan.md`, `verification.md`, project `decisions.md`, and live branch/HEAD/status. Then rebuild enough of the active task neighborhood to work safely. Expand beyond that for concrete triggers such as mismatched handoff state, missing acceptance criteria, failing verification, generated parity, security or permissions behavior, or review scope.

## Project Repos

Project repos keep source code. Registration may add `.piper/project.json` and `PIPER.md`, but those marker files do not make the repo a Piper runtime.
