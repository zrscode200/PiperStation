# Piper Station Agent Instructions (Deep Agents)

This directory is a Piper Station hub-lite workspace. It is the central launch
point for Deep Agents Code work (`dcode`, or a compatible launcher such as
`lc-code`) across registered project repositories.

Deep Agents auto-loads this file from `.deepagents/AGENTS.md` in the hub into
its agent memory at the start of each thread. Treat it as the always-on
operating contract for project work in this hub. If other memory blocks appear
labeled with different file paths — the hub's root `AGENTS.md` or files under
the user profile — they belong to sibling runtimes or user-level memory; where
their runtime mechanics conflict with this file, this file governs the
session.

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
- Use Deep Agents-native behavior for planning, implementation, review,
  testing, subagents, handoff, and git operations within the routed workflow;
  substantial registered-project development enters through piper-workflow
  (Superpowers, then Ralph) rather than starting directly from a design or
  brainstorm conversation.
- Do not edit this hub's instruction, skill, subagent, or hook files unless
  the user explicitly asks for that change. Even when memory auto-save is
  enabled, record session learnings in conversation or, when durable, in
  `projects/<project-id>/memory.md` — not by rewriting hub instruction files.

## Runtime Constraints

These follow from how Deep Agents Code discovers and uses this hub:

- This hub must be its own git repository root (run `git init` here, or
  bootstrap with `--git-init`). Without git metadata at the hub, Deep Agents
  finds no project root and silently skips this file, the hub skills, and the
  hub subagents. A hub nested inside a larger repository resolves to the
  outer repository instead; the hub's own `.git` takes precedence once it
  exists.
- Always use absolute paths with file tools, for hub records and for
  registered project repos alike. Relative paths do not resolve against the
  working directory in this runtime.
- Hub files are read once per thread and snapshotted. After hub files change,
  start a new thread; a resumed thread replays the older snapshot, including
  a stale skill listing.
- Skill bodies are longer than the default file-read window. When reading a
  skill's `SKILL.md`, pass `limit=1000` so the full instructions load.
- The runtime treats this memory content as reference material. Apply it as
  the operating contract for hub work regardless, and say so when a conflict
  forces a choice.
- Keep the approval mode on Manual for project work from this hub. Auto mode
  anchors its trust boundary to this hub directory and will fight edits in
  registered repos elsewhere on disk. Headless runs execute file writes
  without approval gates — use them only when the user has explicitly
  accepted that, and note that gate-free execution does not widen the active
  permission profile: profile boundaries still apply to what you choose to
  do. YOLO mode only ever by explicit user decision.
- Thread pickers scope to this hub directory by default; launching from the
  hub keeps a per-hub session namespace.

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
defines permission profiles and action boundaries. This file is the always-on
Deep Agents summary. Skills route intent, skill references provide procedures,
hooks give lifecycle reminders, and subagents stay within their delegated
roles.

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
```

- `project.md` binds the project id to the real repo path and stores a small
  project overview plus project policy preferences — not a commit ledger;
  commit and acceptance history live in `build-log.md`, anchored to git.
- `memory.md` stores durable facts, preferences, stable conventions, and
  reusable context, not a per-wave changelog.
- Optional `decisions.md` stores substantial decision logs future work should
  not silently reopen; supersede a reversed decision in place rather than
  deleting it.
- `work/` stores optional active work continuity such as roadmap, active work,
  build log, compact pack, durable task queue records, lightweight design
  notes, and explicitly entered Design Studio folders.

Do not put routine progress logs, command output, temporary plans, secrets, or
raw sensitive logs into durable hub records.

Registration must not create `work/`. The runtime may create it during active
work when continuity is useful.

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
self-contained resume packet, rewritten in full when updated. Git is the source
of truth for branch/HEAD/commit/diff history — derive it live and let the owning
artifact record what it needs (context-pack's resume snapshot, build-log's
acceptance commit) rather than repeating it across roadmap, active-work,
project, or queue records; superseded detail rolls off into a sink at group
closeout. See `STATION.md` for temporal roles and fact ownership.

Plan in slices, execute in waves, and checkpoint at boundaries. Slices are
decomposition units; waves are implementation and checkpoint units. Detail the
current wave enough to execute safely, and sketch later waves only when the
current code, context, and prior results make them reliable.

Groups bundle related waves under a shared acceptance target and one
integrating review gate. Use a group when multiple waves land before the larger
boundary is accepted, or when cross-wave interaction risk matters. Make the
group boundary, wave list, required gates, group review state, and acceptance
target visible in `active-work.md`.

## Mode Routing

`brainstorm` owns the decision-quality front door for the divergent phase —
orientation, framing, divergence, investigation, and routing — and stays
read-only. `design-studio` is an optional deeper path inside that divergent
movement, entered only after explicit user choice. `piper-workflow` owns
convergent execution once a direction is set.

Deep Agents surfaces the hub skills with a name, description, and path; state
the intent in natural language, or use the runtime's `/skill:brainstorm`,
`/skill:design-studio`, or `/skill:piper-workflow` command to load one
directly. There is no custom slash-command surface: the detailed procedures
for registration, Superpowers, Ralph, and compact handoff live as reference
files under each owning skill's `references/` directory. An ambiguous
project-work request still enters through `brainstorm`.

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
the `review` skill for explicit review work or review gates, and
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

In this runtime the profiles ride on Manual approval mode: the profile decides
which approvals you request and accept, and the approval screen is the
per-action gate. Under `strict`, decline gated write and execute actions.
Under `local`, approve edits, local checks, and local git in the registered
repo and hub records as the workflow reaches them. Under `external`,
additionally approve network, push, install, and CI actions when the workflow
reaches them. Exceptional actions always need a fresh explicit user approval.

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
   and the files relevant to the user request — using absolute paths.
6. State any uncommitted or recent user changes that affect the task.
7. Make a short task-specific plan unless the user has asked only for review or
   explanation.
8. Before Ralph execution or source edits, verify the real project repo is
   writable in the active session and confirm the active permission profile
   covers `local` source edits. The registered repo lives outside this hub;
   reach it by absolute path and expect each gated write there to surface an
   approval. If `local` profile coverage is absent, route through
   `automation-policy.md` before editing.
9. Implement in the real project repo, using the repo's own conventions and
   verification commands.
10. Update `projects/<project-id>/work/` only when active continuity is useful.
11. Update hub `memory.md`, `project.md` policy notes, or optional
    `decisions.md` only when durable context changed.

## Subagents

The hub ships the same helper role set as the other Piper Station surfaces,
defined under `.deepagents/agents/` and reachable through the `task` tool:

- `reviewer` — read-only implementation review for Ralph review gates.
- `implementer` — scoped implementation when the user explicitly delegates.
- `tester` — writes test-layer files, fixtures, or test data only when
  explicitly delegated.
- `verifier` — strict read-only helper for existing checks and failure
  analysis; it reports when a check needs writable state.
- `architect` — read-only architecture review for broad design and boundary
  risk.
- `docs-researcher` — documentation research through official docs.
- `security-reviewer` — read-only security review for auth, permissions,
  data, networking, secrets, and dependency trust.

In this runtime helper roles are constrained by instruction, not by a
sandbox: every subagent technically inherits the full tool set. Treat the
read-only roles as read-only anyway, validate their findings in the main
session before acting, and deny any unexpected write or execute approval that
arrives from a helper `task` run. The built-in `general-purpose` subagent
remains available for generic delegation.

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

Deep Agents compacts automatically as context fills and archives summarized
history outside the hub; the timing is not configurable. Compact-safe work
records are therefore the continuity mechanism: write durable state before the
boundary arrives, not after. A `PreCompact` hook surfaces a reminder before
compaction, and the `SessionStart` hook replays resume guidance when a
compacted or resumed thread starts.

During Ralph Mode, rewrite `context-pack.md` in full — regenerate it to the
current boundary, not section-edit, reconciling against the prior packet and
live git first — when pausing, preparing for compact, finishing, blocked,
crossing a milestone, context is low, switching projects, or materially
changing active work. Internal slice progress should stay inside the current
wave unless risk, verification, or drift requires a stop. Append
`build-log.md` at wave, group, review/fix, blocker, milestone, finish, or
other meaningful boundaries, and update optional `task-queue.md` only when a
durable queue is in use, including explicit group review gate status for
multi-wave groups. If context is low or the next wave needs a clean context,
pause and tell the user the state is compact-ready.

Do not claim a compaction ran unless the runtime actually performed it.

After compact or resume, start from the designed resume anchors:
`context-pack.md`, `active-work.md`, `build-log.md`, optional
`task-queue.md`, project `project.md`, `memory.md`, optional `decisions.md`,
and live branch/HEAD/status. Read `roadmap.md` when longer-horizon direction
matters. Then rebuild enough of the active boundary neighborhood to work
safely. Expand beyond that for concrete triggers such as a stale resume
packet, missing acceptance criteria, failing verification, generated parity,
security or permissions behavior, or review scope. Remember the runtime
snapshot: hub instructions and skill listings in a resumed thread reflect
thread start, not the current files.

## Permission Boundaries

Use `automation-policy.md` before crossing the active profile boundary for
source edits, local git, pushes, merges, pull requests, dependency installs,
non-destructive worktree create or switch operations, long-running commands,
networked commands, CI changes, deployments, or external automation. Deleting
worktrees and other exceptional actions always need explicit one-off approval.
