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
- `automation-policy.md`: permission profiles and action-boundary gates.

## Instruction Precedence

`STATION.md` defines shared behavior and ownership. `automation-policy.md`
defines permission profiles and action boundaries. This `AGENTS.md` is the
always-on OpenCode summary. Skills route intent, slash commands provide
procedures, `opencode.json` sets runtime permissions, and agents stay within
their delegated roles.

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
  work/              # optional, created by the active runtime only when useful
```

- `project.md` binds the project id to the real repo path and stores a small
  project overview.
- `memory.md` stores durable facts, preferences, stable conventions, and
  reusable context.
- `decisions.md` stores meaningful choices, tradeoffs, accepted risks, and
  policies future work should not silently reopen.
- `work/` stores optional active work continuity such as specs, plans, task
  queues, verification, and context packs.

Do not put routine progress logs, command output, temporary plans, secrets, or
raw sensitive logs into `memory.md` or `decisions.md`.

Registration must not create `work/`. Codex or OpenCode may create it during
active work when continuity is useful.

## Artifact Persistence

Piper work artifacts stay under `projects/<project-id>/work/` by default. Do
not move specs, plans, queues, verification, or context packs into the
registered project repo unless the user explicitly asks for a project-local
copy.

When active work artifacts change, report them at natural checkpoints
separately from registered project source changes. Check git state for both
the real project repo and the Piper Station hub before finish or compact when
artifacts changed. Updating artifacts is allowed local assistance; committing
Piper artifact changes is a `local` permission action handled through
`automation-policy.md` when the active profile does not already cover local
git. Do not ask to commit after every artifact edit; ask only at
scope-appropriate checkpoints defined in
`STATION.md`.

Record artifacts economically: `context-pack.md` is the only fully
self-contained resume packet. Keep specs, plans, queues, and verification
records lean and purpose-specific.

## Mode Routing

`brainstorm` owns the decision-quality front door for the divergent phase —
orientation, framing, divergence, investigation, and routing — and stays
read-only. `piper-workflow` owns convergent execution once a direction is set.
Slash commands are explicit shortcuts into convergent execution:
`/superpowers`, `/ralph`, and `/compact-handoff`. The front door needs no
command — a project-work request that is ambiguous or lacks an explicit
execution signal enters through `brainstorm`.

Route each request through the smallest mode that fits:

- Brainstorm (front door): orient, frame the problem, weigh options,
  investigate, route explicit registration through the helper, and produce a
  decision-ready hand-off brief. Read-only except for that deterministic
  registration path.
- Superpowers Mode: verify the handed-off direction, then specify and plan
  before substantial implementation.
- Ralph Mode: execute one scoped task at a time from a clear plan or task
  queue, with an implementation review gate for substantial slices.
- Review Mode: first check whether the work matches the request/spec/plan,
  then check code quality.
- Finish Mode: verify, summarize, and present commit or PR options without
  mutating git automatically.

Use `brainstorm` as the broad natural-language front door and `piper-workflow`
for convergent execution. Use `/superpowers` for explicit formal planning,
`/ralph` for explicit one-task execution, `review` for explicit review work or
review gates, and `automation-policy` before crossing the active permission
profile boundary. Prefer consequence language such as "I will keep this
read-only" or "I will create Ralph-ready work records" over ceremonial mode
announcements.

Scope tiers:

- `S0`: direct small task; no artifact needed.
- `S1`: short active plan in `projects/<project-id>/work/active-plan.md`.
- `S2`: written spec and plan required before implementation.
- `S3`: split into milestones or sub-specs.

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
project-level profile preferences in `projects/<project-id>/decisions.md`.

## Working On A Project

Before editing a registered project:

1. Read this file and `STATION.md`.
2. Look up the project in `projects/registry.json` to confirm registration and
   resolve `repo_path`. If the user's id is ambiguous, list the registered
   `project_id` entries (with `description` where present) and ask which one
   to use.
3. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md` for
   the rich record.
4. Read `projects/<project-id>/work/context-pack.md` when present.
5. Inspect the real repo path with git status, current branch, current HEAD,
   and the files relevant to the user request.
6. State any uncommitted or recent user changes that affect the task.
7. Make a short task-specific plan unless the user has asked only for review or
   explanation.
8. Before Ralph execution or source edits, verify the real project repo is
   writable in the active session and confirm the active permission profile
   covers `local` source edits. If writable access or `local` profile coverage
   is absent, state what is required and route profile coverage through
   `automation-policy.md` before editing.
9. Implement in the real project repo, using the repo's own conventions and
   verification commands.
10. Update `projects/<project-id>/work/` only when active continuity is useful.
11. Update hub `memory.md` or `decisions.md` only when durable context changed.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial
slices are implemented and initially verified, before marking the slice
complete in active work records. The reviewer inspects the actual code or diff
with the plan, spec, task queue, and verification logs as context.

Review gate selection is based on scope and change impact. Risk tier controls
Ralph implementation confirmation before editing, not permission profile.
Review gates are required for `S2/S3` slices and queued tasks that touch
foundational behavior such as bootstrap, install, update, registration,
generated commands, hooks, settings, config, test harnesses, project or hub
ownership, security policy, or automation policy.

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

During Ralph Mode, update `context-pack.md` when pausing, preparing for compact,
finishing, blocked, crossing a milestone, context is low, switching projects,
or materially changing the plan/spec. Ordinary slice bookkeeping should stay in
`task-queue.md` and `verification.md`. If context is low or the next slice
needs a clean context, pause and tell the user the state is compact-ready and
they may run `/compact`.

Do not claim `/compact` was run unless the user or active runtime actually ran
it.

Codex currently handles compaction through prompt/session guidance. OpenCode
supports automatic compaction when enabled in `opencode.json`. Because this
file is shared by both AGENTS.md-based runtimes, compact-protection behavior
must remain grounded in compact-safe work records rather than runtime-specific
shell hooks.

## Permission Boundaries

Use `automation-policy.md` before crossing the active profile boundary for
source edits, local git, pushes, merges, pull requests, dependency installs,
non-destructive worktree create or switch operations, long-running commands,
networked commands, CI changes, deployments, or external automation. Deleting
worktrees and other exceptional actions always need explicit one-off approval.
