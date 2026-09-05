# Piper Station (Claude Code)

This directory is a Piper Station hub for coordinating Claude Code work across registered project repositories.

Treat this hub as lightweight cross-project context, not a workflow engine. The hub keeps small durable records per project. Source code lives in the registered repos. Active continuity lives lazily inside each project's optional `work/` directory.

Claude Code auto-loads this file. It is the always-on operating contract for work in this hub.

## Required Behavior

- Treat this hub as lightweight cross-project context, not as a source repo for registered projects.
- Do not copy project source code into the hub.
- Register projects with `/add-project` or `./bin/add-project`.
- Keep project records small: `project.md` (binding and policy, not a commit ledger), `memory.md` (durable facts, not a per-wave changelog), optional `decisions.md` (supersede in place), and optional lazy `work/`.
- Use Claude Code-native behavior for planning, implementation, review, testing, subagents, handoff, and git operations within the routed workflow; substantial registered-project development enters through piper-workflow (Superpowers, then Ralph) rather than starting directly from a design or brainstorm conversation.
- Do not start work, create plans, checkpoint state, commit, push, install dependencies, or edit project source as a side effect of registration.
- Do not store secrets, credentials, private keys, customer data, or raw sensitive logs in hub records.
- Use `automation-policy.md` before any `external` action (push, pull request, dependency install, networked command with effects, CI, deployment, external automation) or `exceptional` action. Source edits in the lane's checkout, local git, and non-destructive worktree create or switch operations are routine. Deleting worktrees and other exceptional actions always need explicit one-off approval.

## Required Reading

Use these docs as the canonical human-readable references:

- `STATION.md` - primary operating guide.
- `PRODUCT.md` - product intent and non-goals.
- `ARCHITECTURE.md` - hub structure and project record boundaries.
- `CONVENTIONS.md` - naming, context, and work style conventions.
- `TESTING.md` - verification expectations.
- `SECURITY.md` - sensitive-data and boundary rules.
- `automation-policy.md` - action classes (routine, `external`, `exceptional`), boundary asks, and standing policy notes.

## Instruction Precedence

`STATION.md` defines shared behavior and ownership. `automation-policy.md`
defines action classes and boundary asks. This `CLAUDE.md` is the
always-on Claude Code summary. Skills route intent, slash commands provide
procedures, hooks give lifecycle reminders, and agents stay within their
delegated roles.

## Hub Commands

Slash commands are the user entry points. Run them from this hub directory.

- `/add-project <repo-path> [project-id]` - register a project repo with this hub.
- `/superpowers <project-id> [<gid>] [request]` - enter Superpowers Mode: direction verification, group/milestone structure (Structural Planning), and current-wave detail (Wave Formalization).
- `/ralph <project-id> [<gid> | boundary]` - enter Ralph Mode: execute the current wave, an explicit slice, or a queued task with verification, Implementation Review Gate, and compact-safe updates. A `<gid>` names a group lane under `work/groups/`; with more than one active lane and no `<gid>`, Ralph asks.
- `/compact-handoff [project-id] [<gid>]` - prepare a lane's work records so the user can safely run `/compact`.

The deterministic shell equivalent for registration is:

```sh
./bin/add-project --repo /path/to/project-repo --project-id project-id
```

Use `--hub-only` when repo marker files are not wanted.

The divergent skill entry points are `brainstorm` and optional
`design-studio`. Invoke Design Studio directly through Claude Code's skill
surface or state a clear natural-language request to open or continue one;
brainstorm may suggest it, but may not enter it without explicit user choice.

## Mode Routing

`brainstorm` owns the decision-quality front door for the divergent phase —
orientation, framing, divergence, investigation, and routing — and stays
read-only. `design-studio` is an optional deeper path inside that divergent
movement, entered directly or after a user accepts brainstorm's suggestion.
`piper-workflow` owns convergent execution once a direction is set. Slash
commands are explicit shortcuts into convergent execution: `/superpowers`,
`/ralph`, and `/compact-handoff`. An ambiguous project-work request still
enters through `brainstorm`.

Route each request through the smallest mode that fits.

- Brainstorm (front door) - orient, frame the problem, weigh options, investigate, route explicit registration through the helper, and produce a decision-ready hand-off brief. Read-only except for that deterministic registration path.
- Design Studio (optional divergent path) - after explicit user choice, create or reuse hub-owned studio artifacts, work discussion-first across sessions, and continue, pause, conclude without execution, or hand an explicitly accepted revision to Piper Workflow; do not edit project source or create groups and waves.
- Superpowers Mode - verify the handed-off direction, define the group or milestone structure (Structural Planning), then formalize the current wave (Wave Formalization) before substantial implementation.
- Ralph Mode - execute the current active-work wave, group review and closeout, one explicit slice, or one queued task; verify, drift-check, commit completed waves on the lane's branch, and use implementation review gates at meaningful boundaries.
- Review Mode - first check whether the work matches the request or active work, then check code quality; group reviews inspect the integrated cross-wave diff.
- Finish Mode - report verification, residual risk, changed files, and commit or pull request options without mutating git automatically.

Use `brainstorm` as the broad natural-language front door, `design-studio` only
for explicit deeper design, and `piper-workflow` for convergent execution. Use
`/superpowers` for explicit formal planning,
`/ralph` for explicit Ralph execution, the Piper `review` skill for explicit
Piper review work or review gates, Claude Code's native `/review` when you
specifically want its built-in PR review command, and `automation-policy`
before an `external` or `exceptional` action. Prefer consequence
language such as "I will keep this
read-only" or "I will create Ralph-ready work records" over ceremonial mode
announcements.

### Scope Tiers

Scope tiers are advisory sizing, not artifact rules.

- `S0` - direct small task; stay in chat unless a durable need appears.
- `S1` - modest work; use `active-work.md` only when continuity matters.
- `S2` - substantial work; current-wave continuity, durable checkpoints, or durable queued execution may help before execution.
- `S3` - broad or long-running work; track group or milestone direction in roadmap when that keeps execution clear.

### Risk Tiers

- `L0` - routine implementation risk.
- `L1` - normal implementation risk.
- `L2` - guarded implementation risk; get explicit confirmation before Ralph edits.
- `L3` - blocked inside Ralph; stop for replanning, a human decision, or an `exceptional` action that needs a fresh instruction.

### Action Boundaries

- Routine - no ask, no record: reading, planning, review, registration, source edits in the lane's checkout, local checks and tests, local git add or commit on the lane's branch, non-destructive worktree create or switch operations, Piper artifact updates and their path-scoped hub commits, read-only network reads.
- `external` - ask once at the boundary where the workflow reaches it: push, pull request creation or update, dependency install or update, networked commands with effects, CI reruns or repair, and other non-destructive external-system actions; a standing grant in `projects/<project-id>/project.md` may pre-approve a named class with a target.
- `exceptional` - a fresh explicit instruction every time; can never be pre-approved: force push, rewriting pushed history, deleting branches, worktrees, or user data, discarding changes the boundary did not make, secrets, production deploys, irreversible external actions.

Routine actions proceed when the workflow reaches them; `external` and `exceptional` are the only Piper-level asks. Enforcement is Claude Code's own permission system (`.claude/settings.json` permissions and the session permission mode); where it is bypassed, the Piper asks are the only gate. A broad request like "finish this" is never a go-ahead. Go-aheads are recorded in the lane's `build-log.md`; `project.md` holds standing policy notes only.

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
  work/              # optional, created by Claude Code only when useful
    groups/<gid>/    # one lane folder per group, created at group Entry
```

- `project.md` binds the project id to the real repo path and stores a small project overview plus project policy preferences.
- `memory.md` stores durable facts, preferences, stable conventions, and reusable context.
- Optional `decisions.md` stores substantial decision logs future work should not silently reopen.
- `work/` stores optional active continuity such as roadmap, active work, build log, compact pack, durable task queue records, lightweight design notes, and explicitly entered Design Studio folders. Each group is its own lane under `work/groups/<gid>/` with its own active work, compact pack, build log, and optional queue; the project-level files serve the flat lane.

Do not put routine progress logs, command output, temporary plans, secrets, or raw sensitive logs into durable hub records.

Registration must not create `work/`. Claude Code may create it during active work when continuity is useful.

## Artifact Persistence

Piper work artifacts stay under `projects/<project-id>/work/` by default. Do not move roadmap, active work, build log, queues, or context packs into the registered project repo unless the user explicitly asks for a project-local copy.

Concurrency is per lane: one active session per lane, regardless of harness. A group lane binds its `branch:` and `checkout:` in its `active-work.md` header; `repo_path` is held by at most one lane and every other active lane works in its own git worktree. Hub artifact commits are path-scoped — stage only the lane's paths plus touched project-level files, never `git add -A` in the shared hub checkout. See `STATION.md` → Project Records and Group Lifecycle for lane selection, Entry, Closeout, and the legacy-layout move.

At each boundary trigger, satisfy the checkpoint invariant defined once in `STATION.md` → Artifact Persistence: windows and ledger agree, a fresh session can resume from hub records plus live git, and changed Piper artifacts are reported separately from registered project source changes with their hub commit state. Updating artifacts is allowed local assistance; committing Piper artifact changes is routine and path-scoped; the checkpoint decides whether one happens. Do not ask to commit after every artifact edit; ask only at the resume triggers in that same list.

Record artifacts economically: `context-pack.md` is the only fully self-contained resume packet, rewritten in full when updated and holding only the non-derivable fields defined once in `STATION.md` → Compaction. Git is the source of truth for branch/HEAD/commit/diff history — derive it live and let `build-log.md` record the acceptance commit rather than repeating it across other records; superseded detail rolls off into a sink at group closeout. See `STATION.md` for temporal roles and fact ownership.

Plan in slices, execute in waves, and checkpoint at boundaries. Slices are decomposition units; waves are implementation and checkpoint units. Detail the current wave enough to execute safely, and sketch later waves only when the current code, context, and prior results make them reliable. The default unit is one ungrouped wave with a light boundary; ceremony scales with the boundary, not the project.

Groups bundle related waves under a shared acceptance target and one integrating review gate, entered by an explicit planning decision. Make the group boundary, wave list, required gates, group review state, and acceptance target visible in `active-work.md`.

Claude Code's native task tracking is the in-session default for short-lived steps; `task-queue.md` exists only when queued work must survive the session or move across agents.

## Working On A Project

Before editing a registered project:

1. Read this file and `STATION.md`.
2. Look up the project in `projects/registry.json` to confirm registration and resolve `repo_path`. If the user's id is ambiguous, list the registered `project_id` entries (with `description` where present) and ask which one to use.
3. Read `projects/<project-id>/project.md`, `memory.md`, and optional `decisions.md` when present.
4. Select the lane (`STATION.md` → Lane selection; ask when more than one is active), then read its `context-pack.md`, `active-work.md`, `build-log.md`, and optional `task-queue.md` — under `projects/<project-id>/work/` for the flat lane or `work/groups/<gid>/` for a group lane — plus `roadmap.md` when present and relevant.
5. Inspect the lane's checkout (`repo_path` or its recorded worktree) with `git status`, current branch, current HEAD, and the files relevant to the user request.
6. If the lane's checkout is outside the hub, ensure Claude Code has workspace access through `/add-dir <checkout-path>` or by launching with `claude --add-dir <checkout-path>` before editing.
7. State any uncommitted or recent user changes that affect the task.
8. Make a short task-specific plan unless the user has asked only for review or explanation.
9. Before Ralph execution or source edits, verify the lane's checkout (`repo_path` or its recorded worktree; if an active group header binds `repo_path`, the flat lane has none) is writable in the active session; source edits there are routine. If writable access is absent, state what is required and wait.
10. Implement in the lane's checkout, using the repo's own conventions and verification commands.
11. Update `projects/<project-id>/work/` only when active continuity is useful.
12. Update hub `memory.md`, `project.md` policy notes, or optional `decisions.md` only when durable context changed.

## Skills And Agents

The Claude Code layer is intentionally small:

- Commands are user entry points under `.claude/commands/`.
- Skills are behavior guides under `.claude/skills/`; `brainstorm` is the broad
  front door, `design-studio` is the directly invokable optional deeper design
  path, and `piper-workflow` owns convergent execution.
- Subagents live under `.claude/agents/` for the same helper role set as the
  Codex surface: reviewer, implementer, tester, verifier, architect,
  docs-researcher, and security-reviewer.
- The docs-researcher wires the OpenAI developer docs MCP server in its own
  subagent frontmatter, matching the human-facing Codex docs-researcher role
  while Codex uses concrete agent id `docs_researcher`.

Root docs are the canonical references. Skills should point back to these docs instead of duplicating the whole station manual.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial waves, queued work, or high-impact slices are implemented and initially verified, before marking the boundary complete in active work records. The reviewer inspects the actual code or diff with `active-work.md`, `build-log.md`, optional `task-queue.md`, and relevant surrounding code as context.

Review gate selection is based on scope and change impact. Risk tier controls Ralph implementation confirmation before editing, not action class. Review gates are required for `S2/S3` wave or group boundaries and queued tasks that touch foundational behavior such as bootstrap, install, update, registration, generated commands, hooks, settings, config, test harnesses, project or hub ownership, security policy, or automation policy.
After the final wave in a group lands, run a group-level review gate over the integrated cross-wave diff before the slice, group, or acceptance task is marked complete, even if every per-wave gate already passed.

The main Claude Code session must validate reviewer findings before acting: give each finding an explicit verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive` — before editing any code, then apply only `confirmed-in-scope` fixes, turn `confirmed-out-of-scope` findings into follow-up notes or tasks, and reverify review-driven fixes with the narrowest meaningful command for the fixed behavior. If a required or expected gate is skipped, record review debt and do not continue to dependent tasks until the debt is resolved or explicitly accepted by the user.

## Compaction

Ralph rewrites `projects/<id>/work/context-pack.md` in full — regenerate it to the current boundary rather than section-editing, reconciling against the prior packet and live git first — at the resume triggers defined once in `STATION.md` → Artifact Persistence → Boundary triggers. The packet holds only the non-derivable fields defined under `STATION.md` → Compaction; branch, HEAD, status, changed files, and what to inspect first are derived live at resume. The next exact action should be a file to open, command to run, or question to answer, specific enough for a fresh Claude Code session to continue cold. Internal slice progress should stay inside the current wave unless risk, verification, or drift requires a stop. Append `build-log.md` at each boundary trigger, and update optional `task-queue.md` only when a durable queue is in use, including explicit group review gate status for multi-wave groups.

`/compact` is human-triggered. Ralph may pause and say the state is compact-ready when context is low, a milestone just finished, or the next wave needs a clean context. Ralph should continue normally when the next boundary is safe and context is not a concern. Do not claim `/compact` ran unless the user or Claude Code actually ran it.

Claude Code compact-protection hooks provide user-visible lifecycle guidance for manual or automatic compaction. `PreCompact` surfaces the Piper Station fields that matter before compacting, and `PostCompact` surfaces the resume anchors after compacting. The reliable model-visible resume path is still `SessionStart` with source `compact`. Hooks must not edit work records, run verification, commit, push, or invoke `/compact`.

Future runtime-style auto-compact protection could snapshot minimal active state
to `projects/<id>/work/` immediately before automatic compaction. That would
require a reliable active-project/session-state source and explicit ownership
rules for hook-written records. Keep this as future design work, not current
hub-lite behavior.

After compact, start from the selected lane's designed resume anchors (`work/` or `work/groups/<gid>/`): `context-pack.md`, `active-work.md`, `build-log.md`, optional `task-queue.md`, project `project.md`, `memory.md`, optional `decisions.md`, and live branch/HEAD/status. Read `roadmap.md` when longer-horizon direction matters. Then rebuild enough of the active boundary neighborhood to work safely. Expand beyond that for concrete triggers such as a stale resume packet, missing acceptance criteria, failing verification, generated parity, security or permissions behavior, or review scope.

## Project Repos

Project repos keep source code. Registration may add `.piper/project.json` and `PIPER.md`, but those marker files do not make the repo a Piper runtime.
