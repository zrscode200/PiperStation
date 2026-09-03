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
  `projects/<project-id>/project.md`, or in a lane's recorded git worktree of
  that repo.
- Use the active runtime's native behavior for planning, implementation,
  review, testing, subagents, handoff, and git operations
  within the routed workflow; substantial registered-project development
  enters through piper-workflow (Superpowers, then Ralph) rather than
  starting directly from a design or brainstorm conversation.

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
  work/              # optional, created by the active runtime only when useful
    groups/<gid>/    # one lane folder per group, created at group Entry
```

- `project.md` binds the project id to the real repo path and stores a small
  project overview plus project policy preferences — not a commit ledger; commit
  and acceptance history live in `build-log.md`, anchored to git.
- `memory.md` stores durable facts, preferences, stable conventions, and
  reusable context, not a per-wave changelog.
- Optional `decisions.md` stores substantial decision logs future work should
  not silently reopen; supersede a reversed decision in place rather than
  deleting it.
- `work/` stores optional active work continuity such as roadmap, active work,
  build log, compact pack, durable task queue records, lightweight design
  notes, and explicitly entered Design Studio folders. Each group is its own
  lane under `work/groups/<gid>/` with its own active work, compact pack,
  build log, and optional queue; the project-level files serve the flat lane.

Do not put routine progress logs, command output, temporary plans, secrets, or
raw sensitive logs into durable hub records.

Registration must not create `work/`. Codex or OpenCode may create it during
active work when continuity is useful.

## Artifact Persistence

Piper work artifacts stay under `projects/<project-id>/work/` by default. Do
not move roadmap, active work, build log, queues, or context packs into the
registered project repo unless the user explicitly asks for a project-local
copy.

Concurrency is per lane: one active session per lane, regardless of harness.
A group lane binds its `branch:` and `checkout:` in its `active-work.md`
header; `repo_path` is held by at most one lane and every other active lane
works in its own git worktree. Hub artifact commits are path-scoped — stage
only the lane's paths plus touched project-level files, never `git add -A` in
the shared hub checkout. See `STATION.md` → Project Records and Group
Lifecycle for lane selection, Entry, Closeout, and the legacy-layout move.

At each boundary trigger, satisfy the checkpoint invariant defined once in
`STATION.md` → Artifact Persistence: windows and ledger agree, a fresh session
can resume from hub records plus live git, and changed Piper artifacts are
reported separately from registered project source changes with their hub
commit state. Updating artifacts is allowed local assistance; committing Piper
artifact changes is a `local` permission action handled through
`automation-policy.md` when the active profile does not already cover local
git. Do not ask to commit after every artifact edit; ask only at the resume
triggers in that same list.

Record artifacts economically: `context-pack.md` is the only fully
self-contained resume packet, rewritten in full when updated and holding only
the non-derivable fields defined once in `STATION.md` → Compaction. Git is the
source of truth for branch/HEAD/commit/diff history — derive it live and let
`build-log.md` record the acceptance commit rather than repeating it across
other records; superseded detail rolls off into a sink at group closeout. See
`STATION.md` for temporal roles and fact ownership.

Plan in slices, execute in waves, and checkpoint at boundaries. Slices are
decomposition units; waves are implementation and checkpoint units. Detail the
current wave enough to execute safely, and sketch later waves only when the
current code, context, and prior results make them reliable. The default unit
is one ungrouped wave with a light boundary; ceremony scales with the boundary,
not the project.

Groups bundle related waves under a shared acceptance target and one
integrating review gate, entered by an explicit planning decision. Make the
group boundary, wave list, required gates, group review state, and acceptance
target visible in `active-work.md`.

Native task tracking is the in-session default for short-lived steps;
`task-queue.md` exists only when queued work must survive the session or move
across agents.

## Mode Routing

`brainstorm` owns the decision-quality front door for the divergent phase —
orientation, framing, divergence, investigation, and routing — and stays
read-only. `design-studio` is an optional deeper path inside that divergent
movement, directly invokable through OpenCode's skill surface or natural
language and entered from brainstorm only after explicit user choice.
`piper-workflow` owns convergent execution once a direction is set. Slash
commands are explicit shortcuts into convergent execution: `/superpowers`,
`/ralph`, and `/compact-handoff`. An ambiguous project-work request still
enters through `brainstorm`.

Route each request through the smallest mode that fits:

- Brainstorm (front door): orient, frame the problem, weigh options,
  investigate, route explicit registration through the helper, and produce a
  decision-ready hand-off brief. Read-only except for that deterministic
  registration path.
- Design Studio (optional divergent path): after explicit user choice, create
  or reuse hub-owned studio artifacts, work discussion-first across sessions,
  and continue, pause, conclude without execution, or hand an explicitly
  accepted revision to Piper Workflow. It does not edit project source or
  create groups and waves.
- Superpowers Mode: verify the handed-off direction, define the group or
  milestone structure (Structural Planning), then formalize the current wave
  (Wave Formalization) before substantial implementation.
- Ralph Mode: execute the current active-work wave, group review and closeout,
  one explicit slice, or one queued task, committing completed waves under
  `local`, with implementation review gates at meaningful boundaries.
- Review Mode: first check whether the work matches the request or active work,
  then check code quality; group reviews inspect the integrated cross-wave
  diff.
- Finish Mode: verify, summarize, and present commit or PR options without
  mutating git automatically.

Use `brainstorm` as the broad natural-language front door, `design-studio` only
for explicit deeper design, and `piper-workflow` for convergent execution. Use
`/superpowers` for explicit formal planning, `/ralph` for explicit Ralph
execution, `review` for explicit review work or review gates, and
`automation-policy` before crossing the active permission profile boundary.
Prefer consequence language such as "I will keep this read-only" or "I will
create Ralph-ready work records" over ceremonial mode announcements.

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
4. Select the lane (`STATION.md` → Lane selection; ask when more than one is
   active), then read its `context-pack.md`, `active-work.md`, `build-log.md`,
   and optional `task-queue.md` — under `projects/<project-id>/work/` for the
   flat lane or `work/groups/<gid>/` for a group lane — plus `roadmap.md` when
   present and relevant.
5. Inspect the lane's checkout (`repo_path` or its recorded worktree) with
   git status, current branch, current HEAD,
   and the files relevant to the user request.
6. State any uncommitted or recent user changes that affect the task.
7. Make a short task-specific plan unless the user has asked only for review or
   explanation.
8. Before Ralph execution or source edits, verify the lane's checkout
   (`repo_path` or its recorded worktree; if an active group header binds
   `repo_path`, the flat lane has none) is writable in the active session and
   confirm the active permission profile
   covers `local` source edits. If writable access or `local` profile coverage
   is absent, state what is required and route profile coverage through
   `automation-policy.md` before editing.
9. Implement in the lane's checkout, using the repo's own conventions and
   verification commands.
10. Update `projects/<project-id>/work/` only when active continuity is useful.
11. Update hub `memory.md`, `project.md` policy notes, or optional
    `decisions.md` only when durable context changed.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial
waves, queued work, or high-impact slices are implemented and initially
verified, before marking the boundary complete in active work records. The
reviewer inspects the actual code or diff with `active-work.md`,
`build-log.md`, optional `task-queue.md`, and relevant surrounding code as
context.

Review gate selection is based on scope and change impact. Risk tier controls
Ralph implementation confirmation before editing, not permission profile.
Review gates are required for `S2/S3` wave or group boundaries and queued tasks
that touch foundational behavior such as bootstrap, install, update,
registration, generated commands, hooks, settings, config, test harnesses,
project or hub ownership, security policy, or automation policy.
After the final wave in a group lands, run a group-level review gate over the
integrated cross-wave diff before the slice, group, or acceptance task is
marked complete, even if every per-wave gate already passed.

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

During Ralph Mode, rewrite `context-pack.md` in full — regenerate it to the
current boundary, not section-edit, reconciling against the prior packet and live
git first — at the resume triggers defined once in `STATION.md` → Artifact
Persistence → Boundary triggers. The packet holds only the non-derivable fields
defined under `STATION.md` → Compaction; branch, HEAD, status, changed files,
and what to inspect first are derived live at resume. Internal slice progress
should stay inside the current wave unless risk, verification, or drift
requires a stop. Append `build-log.md` at each boundary trigger, and update
optional `task-queue.md` only when a durable queue is in use, including
explicit group review gate status for multi-wave groups. If context is low or
the next wave needs a clean context, pause and tell the user the state is
compact-ready and they may run `/compact`.

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
