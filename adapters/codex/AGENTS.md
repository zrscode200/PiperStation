# Piper Station Agent Instructions

This directory is a Piper Station hub-lite workspace. It is the central launch
point for Codex and OpenCode work across registered project repositories.

## Operating Contract

- Treat this hub as coordination context, not as a source repo for registered
  projects.
- Do not copy project source code into the hub.
- Register project repos with `./bin/add-project`.
- Registration only updates hub project records and optional repo marker files.
  It must not start implementation work, create plans, checkpoint state,
  commit, push, install dependencies, or edit project source files.
- Work on project source code only in the real repo path recorded in
  `projects/<project-id>/project.md`.
- Use the active runtime's native behavior for planning, implementation,
  review, testing, subagents, handoff, and git operations.

## Required Reading

When working in this hub, use these docs as the canonical references:

- `STATION.md`: primary operating guide.
- `PRODUCT.md`: product intent and non-goals.
- `ARCHITECTURE.md`: hub and project record structure.
- `CONVENTIONS.md`: naming, context, and work style conventions.
- `TESTING.md`: verification expectations.
- `SECURITY.md`: sensitive-data and boundary rules.
- `automation-policy.md`: approvals required for automation and external
  actions.

## Project Records

Each registered project has:

```text
projects/<project-id>/
  project.md
  memory.md
  decisions.md
  work/              # optional, created by the active runtime only when useful
```

- `project.md` binds the project id to the real repo path and stores a small
  project overview.
- `memory.md` stores durable facts, preferences, stable conventions, and
  reusable context.
- `decisions.md` stores meaningful choices, tradeoffs, accepted risks, and
  policies future work should not silently reopen.
- `work/` stores optional active work continuity such as specs, plans, task
  queues, progress, verification, handoff notes, and context packs.

Do not put routine progress logs, command output, temporary plans, secrets, or
raw sensitive logs into `memory.md` or `decisions.md`.

Registration must not create `work/`. Codex or OpenCode may create it during
active work when continuity is useful.

## Mode Routing

`piper-workflow` owns natural-language dispatch for ordinary project work.
Slash commands are explicit shortcuts into the same behavior. Use `/work-on`
when the user explicitly wants the routing command; otherwise let
`piper-workflow` handle project-work requests directly.

Route each request through the smallest mode that fits:

- Intent Mode: classify the request, project, scope tier, risk tier, and
  whether direct work is safe.
- Superpowers Mode: discover, specify, and plan before substantial
  implementation.
- Ralph Mode: execute one scoped task at a time from a clear plan or task
  queue, with an implementation review gate for substantial slices.
- Review Mode: first check whether the work matches the request/spec/plan,
  then check code quality.
- Finish Mode: verify, summarize, and present commit or PR options without
  mutating git automatically.

Use supporting skills after the route is selected: `superpowers-planning` for
Superpowers Mode, `ralph-loop` for one clear Ralph task, `review` for explicit
review work or review gates, and `automation-policy` before protected
automation or external actions.

Scope tiers:

- `S0`: direct small task; no artifact needed.
- `S1`: short active plan in `projects/<project-id>/work/active-plan.md`.
- `S2`: written spec and plan required before implementation.
- `S3`: split into milestones or sub-specs.

Risk tiers:

- `L0`: trivial or local.
- `L1`: normal implementation.
- `L2`: needs explicit user confirmation before Ralph executes.
- `L3`: forbidden inside Ralph; stop and ask.

## Working On A Project

Before editing a registered project:

1. Read this file and `STATION.md`.
2. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md`.
3. Read `projects/<project-id>/work/context-pack.md` when present.
4. Inspect the real repo path with git status, current branch, current HEAD,
   and the files relevant to the user request.
5. State any uncommitted or recent user changes that affect the task.
6. Make a short task-specific plan unless the user has asked only for review or
   explanation.
7. Implement in the real project repo, using the repo's own conventions and
   verification commands.
8. Update `projects/<project-id>/work/` only when active continuity is useful.
9. Update hub `memory.md` or `decisions.md` only when durable context changed.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial
slices are implemented and initially verified, before marking the slice
complete in active work records. The reviewer inspects the actual code or diff
with the plan, spec, task queue, and verification logs as context.

Review gate selection is based on scope and change impact. Risk tier determines
whether execution needs explicit user approval. Review gates are required for
`S2/S3` slices and queued tasks that touch foundational behavior such as
bootstrap, install, update, registration, generated commands, hooks, settings,
config, test harnesses, project or hub ownership, security policy, or automation
policy.

The main agent must verify reviewer findings before acting, apply only valid
in-scope fixes, and reverify review-driven fixes with the narrowest meaningful
command for the fixed behavior. Record the gate status or skip reason when
active work records are in use. If a required or expected gate is skipped,
record review debt in active work records and do not continue to dependent
tasks until the debt is resolved or explicitly accepted by the user.

## Compaction Discipline

During Ralph Mode, prepare compact-safe state at natural stopping points by
updating `projects/<project-id>/work/context-pack.md`, plus `handoff.md` when
pausing or handing off. If context is low or the next slice needs a clean
context, pause and tell the user the state is compact-ready and they may run
`/compact`.

Do not claim `/compact` was run unless the user or active runtime actually ran
it.

Codex currently handles compaction through prompt/session guidance. OpenCode
supports automatic compaction when enabled in `opencode.json`. Because this
file is shared by both AGENTS.md-based runtimes, compact-protection behavior
must remain grounded in compact-safe work records rather than runtime-specific
shell hooks.

## Approval Boundaries

Ask before commits, pushes, merges, pull requests, dependency installs,
worktree changes, long-running commands, networked commands, destructive git
actions, CI changes, deployments, or external automation.
