# Piper Station Hub

This directory is a Piper Station hub-lite workspace. It coordinates assisted
development across registered project repositories using one shared project
ledger and one or more native harness surfaces.

Installed runtime surfaces may include Codex, Claude Code, OpenCode, or any
combination of them. Runtime files provide native entry points; project records
stay shared under `projects/`.

## Required Behavior

- Treat this hub as lightweight cross-project context, not a workflow engine.
- Do not copy project source code into the hub.
- Register project repos with the native command surface or `./bin/add-project`.
- Registration only updates hub project records and optional repo marker files.
- Do not start work, create plans, checkpoint state, commit, push, install
  dependencies, or edit project source as a side effect of registration.
- Work on project source code only in the real repo path recorded in
  `projects/<project-id>/project.md`.
- Keep behavior feedback in shared records when it applies to Piper Station;
  use runtime-specific notes only for harness mechanics.
- Do not store secrets, credentials, private keys, customer data, or raw
  sensitive logs in hub records.

## Runtime Surfaces

- Codex: `AGENTS.md` and `.codex/`.
- Claude Code: `CLAUDE.md` and `.claude/`.
- OpenCode: `opencode.json` and `.opencode/`.

A hub may have multiple runtime surfaces installed. Use one harness actively on
a project at a time unless the user explicitly coordinates parallel work.

## Instruction Precedence

Use this order when instructions overlap:

1. `STATION.md` defines shared Piper Station behavior, project-record
   ownership, dispatch boundaries, work artifacts, compaction, and Ralph gates.
2. `automation-policy.md` defines permission profiles and action-boundary
   gates.
3. Runtime root docs (`AGENTS.md`, `CLAUDE.md`, and `opencode.json`
   instruction lists) are always-on summaries that adapt the shared behavior to
   each harness.
4. Skills route intent and provide consequence-specific operating checklists.
   They point back to the canonical docs instead of redefining global policy.
5. Commands and reference files provide procedure bodies for explicit actions.
6. Hooks and agents stay narrow: hooks surface lifecycle reminders, and agents
   perform delegated helper roles without owning policy.

Some repetition is intentional. Root docs repeat high-signal rules because they
are always loaded; command/reference files repeat procedure details so they can
be used directly; hooks repeat compact fields because they are runtime output;
agents repeat role boundaries because they are delegated prompts. Policy tables
and global ownership rules belong in the canonical docs above.

## Dispatch Contract

`brainstorm` owns the decision-quality front door for the divergent phase —
orientation, framing, divergence, investigation, registration routing, and
route selection. It stays read-only for orientation and planning; explicit
registration is the narrow exception and must go through the deterministic
helper. `piper-workflow` owns convergent execution once a direction is set.
Slash commands are explicit shortcuts into the same behavior. Commands, narrow
skills, agents, hooks, and docs provide supporting behavior after a skill or
command has selected the route.

The boundary between them is the same verb, different intent: `brainstorm`
explores to *generate* a direction; `piper-workflow` (Superpowers) verifies that
direction against the code to *commit* it before durable planning.

Use this dispatch table when intent is unclear:

| User intent | Route | Supporting behavior |
| --- | --- | --- |
| Register a repo | `brainstorm`, `/add-project`, or `./bin/add-project` | deterministic registration helper |
| Orient, explore, compare options, or decide what to do | `brainstorm` | `brainstorm` |
| Verify a direction, specify, or plan substantial work | Superpowers Mode or `/superpowers` | `piper-workflow`, `/superpowers`, and this guide |
| Execute one clear active-work wave, group review, explicit slice, or optional queued task | Ralph Mode or `/ralph` | `/ralph` and this guide; project source edits require `local` profile coverage |
| Review code, an implemented wave, group, or slice | Review Mode | `review` |
| Local git, worktree, PR, dependency, network, CI, exceptional, or external action | Finish Mode or permission approval flow | `automation-policy` |
| Pause or compact active work | `/compact-handoff` | compact handoff guidance |

If a project-work request is ambiguous or arrives without a slash command, treat
it as an implicit `brainstorm` request — skill descriptions match by phase
(explore vs execute), and this contract owns the tie-break for genuine
ambiguity. Use visible mode names when they help continuity, but do not make the
user operate the mode layer. Prefer consequence language such as "I will keep
this read-only" or "I will create Ralph-ready work records" over ceremonial mode
announcements.

### Artifact Signal Policy

Infer durable artifacts from the user's intent signal and state the consequence
when it matters. `brainstorm` acts on the front-door band: read-only
orientation and conversational planning, plus explicit deterministic
registration. The convergent rows below belong to `piper-workflow` (formal
planning, Ralph execution) and `automation-policy` (permission-gated finish
actions):

| User signal | Interpretation | Durable writes | Assistant stance |
| --- | --- | --- | --- |
| "review this repo", "understand what this does", "what is this project", or a repo path with an explanation or review request | Orientation or review | None by default | Inspect the repo in place. Say the work is read-only and that registration or hub records will wait unless asked. |
| "what would it take", "how should we approach", "compare this to", or "plan the refactor" before registration | Conversational planning | None by default | Produce a grounded plan in chat. Avoid hub records unless the user asks to formalize. |
| "register this", "track this project", or "this is formal work now" | Registration | `project.md` and `memory.md` only | Use the registration helper. Prefer hub-only records unless repo marker files are explicitly wanted. Do not create `work/` or start implementation. |
| "make this a formal plan", "prepare for Ralph", "create the queue", "we need continuity", or "set this up for later execution" | Formal planning or Ralph preparation | Useful `projects/<id>/work/` records | Create only the durable records the work needs: long-horizon direction, active work continuity, durable task tracking, checkpoint history, or compact/resume continuity. State that source remains untouched. |
| "start Ralph", "build task X", "execute the first queue item", or "implement according to the plan" | Ralph execution | Update `work/` records as useful; edit the real project repo when `local` profile coverage exists | Confirm the selected wave, group review, explicit slice, or queued task; diff boundary; risk; verification; writable repo access; and `local` profile coverage before editing. Route through `automation-policy` if coverage is absent. Execute the current boundary. |
| "finish", "commit", "open a PR", "push", "install", "run CI repair", or external/exceptional action | Finish or permission-gated action | Local/external actions only after the workflow reaches that action and the permission profile allows it; exceptional actions only after explicit one-off approval | Summarize state, verification, and risk first. Route through `automation-policy` before crossing the active profile boundary or requesting exceptional approval. |

Ambiguous signals must not silently escalate durable writes. If the next step
would create hub records, edit project source (a `local` permission action), or
cross the active permission profile boundary and the user's intent is unclear,
state the assumption and ask or choose the less durable action.

## Project Records

`projects/registry.json` is the hub-owned index of registered projects. Use it
to resolve a `project_id` to its `repo_path` and to list the projects this hub
knows about. Per-project records remain the canonical rich source; the index is
a derived lookup. If it ever drifts, regenerate it with
`./bin/add-project --rebuild`.

Each registered project has:

```text
projects/<project-id>/
  project.md
  memory.md
  work/              # optional, created only when useful during active work
```

`project.md` stores repo binding, overview, and project policy preferences such
as permission profile, one-off approvals, accepted risks, and project-level
automation notes. `memory.md` stores durable facts, preferences, stable
conventions, and reusable context. `decisions.md` is optional for substantial
decision logs; registration does not create it.

`work/` may contain `roadmap.md`, `active-work.md`, `build-log.md`,
`context-pack.md`, and optional `task-queue.md`.

Registration must not create `work/`.

Use artifacts as structured working memory, not rigid ceremony. Plan in
slices, execute in waves, and checkpoint at boundaries. Slices are
decomposition units; waves are implementation and checkpoint units. Detail the
current wave enough to execute safely. Sketch later waves only when the current
code, context, and prior results make them reliable.

Groups bundle related waves under a shared acceptance target and one
integrating review gate. Use a group when multiple waves land before the larger
boundary is accepted, or when cross-wave interaction risk matters. A group has
its own boundary in `active-work.md`, its own checkpoint in `build-log.md`, and
its own review gate over the integrated cross-wave diff before acceptance.

### Work Artifact Reference

Create these only under `projects/<project-id>/work/`, never in the registered
project repo. Use each artifact only when it does a clear job for autonomy,
continuity, quality, or compact/resume.

| Artifact | Purpose | Create or update when |
| --- | --- | --- |
| `roadmap.md` | Longer-horizon direction: groups, milestones, deferred work, risks, and revisit triggers. | Project direction, group order, milestone sequence, deferred scope, or revisit triggers change. |
| `active-work.md` | Live group and wave workbench: current goal, group boundary, current wave details, reliable later-wave sketches, slice breakdown, required gates, group review state, acceptance criteria, risks, verification strategy, and open questions. | Current group or wave needs durable continuity before implementation, review, compact, or delayed execution. |
| `build-log.md` | Primary durable checkpoint ledger: what actually happened, final contracts, implementation summaries, review and verification results, risks, next steps, and commits. | A meaningful planning, wave, review/fix, finish, compact, blocker, group, or milestone checkpoint occurs. |
| `context-pack.md` | The full compact/resume packet: goal, current boundary, next exact action, key files, what to inspect first, branch/HEAD/status, verification state, review state including group-level review state when relevant, drift, blockers, stop reason, and what to hand a human or fresh agent. | Active work may pause, compact, finish, hit a blocker, reach a milestone, switch projects, or hand off. |
| `task-queue.md` | Optional durable Ralph execution queue: task ids with status, risk, acceptance criteria, verification, dependencies, expected diff boundary, and explicit group review gate items for multi-wave groups. | Native runtime task tracking is insufficient because waves, slices, or group gates must survive the current session or move across agents. |

### Artifact Recording Economy

Record the least artifact state that preserves continuity. `context-pack.md` is
the only fully self-contained resume packet; other artifacts should stay lean
and avoid repeating repo path, branch, HEAD, full git state, next action,
blockers, review state, or commit state unless that detail is intrinsic to the
artifact's purpose.

- `roadmap.md`: long-term direction only. Do not turn it into the current work
  tracker or checkpoint ledger.
- `active-work.md`: live group and wave planning only. Keep the current wave
  actionable; sketch later waves only when reliable. When a group exists, make
  the group header, wave list, required gates, group review state, and
  acceptance target explicit. Do not duplicate the full resume packet or
  chronological log.
- `build-log.md`: checkpoint summaries and final implemented contracts only.
  Prefer concise entries over raw logs or step-by-step transcripts. Give group
  closeout its own entry when a group boundary is reached.
- `context-pack.md`: full resume state and cross-artifact pointers. Update it
  at pause, compact preparation, finish, blocker, milestone boundary, context
  low stop, project switch, or material active-work change.
- `task-queue.md`: durable queued waves, slices, or group gate items only.
  Native runtime task tracking is the default for short-lived in-session steps.
  For multi-wave groups, list the group review gate as an explicit acceptance
  criterion before the acceptance task.

### Artifact Persistence

Piper work artifacts are hub-owned project state. Keep them in
`projects/<project-id>/work/` by default; do not move them into the registered
project repo unless the user explicitly asks for a project-local copy.

When `context-pack.md` changes, make it self-contained enough for a fresh
session to resume without transcript archaeology: include the target repo path,
branch, HEAD or relevant source commit, active scope, verification and review
state, changed source areas, next exact action, blockers, and whether related
source or hub changes are committed.

Artifact updates are normal local assistance while work is active. Permission
profiles gate whether a commit action can proceed; they do not make artifact
commits automatic or change checkpoint timing. Do not ask after every artifact
edit. Instead, disclose changed Piper artifacts at natural checkpoints and ask
about a Piper artifact commit only when the stopping point or future continuity
warrants it. Checkpoints include the end of formal planning, a milestone
boundary, compact preparation, finish mode, before switching projects, or when
the user says to pause, save, compact, finish, or commit.

At every checkpoint:

1. Report changed Piper artifacts separately from registered project source
   changes.
2. Inspect git state for both the registered project repo and the Piper
   Station hub when artifacts changed.
3. State whether artifact changes are uncommitted in the hub.
4. If the workflow checkpoint chooses an artifact commit, treat it as a
   `local` permission action under `automation-policy.md` and keep it separate
   from any registered project source commit.

Scope informs how strongly artifact persistence is surfaced; artifact creation
is driven by durable need:

- `S0`: stay in chat unless the user asks to record something or a durable
  project fact, policy preference, checkpoint, or verification result appears.
- `S1`: prefer chat or `active-work.md` only when the current work needs
  continuity.
- `S2`: likely benefits from a clear current wave in `active-work.md` and
  checkpoint entries in `build-log.md`; create `task-queue.md` only when
  durable queued execution is needed.
- `S3`: likely needs `roadmap.md` for group or milestone direction,
  `active-work.md` for the current group and wave, and checkpoint entries in
  `build-log.md`.

During Ralph execution, append `build-log.md` at wave, group, review/fix,
blocker, milestone, finish, or other meaningful boundaries. Update
`task-queue.md` only when a durable queue is in use. Do not update
`context-pack.md` or ask to commit artifacts unless the boundary is also a
group closeout, milestone, material active-work change, pause, compact, context
switch, blocker, or finish.

## Mode Routing

Route requests through `brainstorm` (the front door), `piper-workflow`
(convergent execution), command shortcuts, and the smallest mode that fits:

- Brainstorm (front door): orient, frame the problem, weigh options,
  investigate, route explicit registration through the helper, and produce a
  decision-ready hand-off brief; stay read-only except for that deterministic
  registration path.
- Superpowers Mode: verify the handed-off direction, then specify and plan
  before substantial implementation.
- Ralph Mode: execute the current active-work wave, group review, one explicit
  slice, or one queued task; verify, drift-check, and use implementation review
  gates at meaningful boundaries.
- Review Mode: first check whether the work matches the request or active work,
  then check code quality; group reviews inspect the integrated cross-wave
  diff.
- Finish Mode: report verification, residual risk, changed files, and commit or
  pull request options without mutating git automatically.

Scope tiers are advisory sizing, not artifact rules:

- `S0`: direct small task; stay in chat unless a durable need appears.
- `S1`: modest work; use `active-work.md` only when continuity matters.
- `S2`: substantial work; current-wave continuity, durable checkpoints, or
  durable queued execution may help before execution.
- `S3`: broad or long-running work; track group or milestone direction in
  roadmap when that keeps execution clear.

Risk tiers:

- `L0`: routine implementation risk, tiny and obvious with very low blast
  radius.
- `L1`: normal implementation risk with clear acceptance criteria and local
  verification.
- `L2`: guarded implementation risk; Ralph must get explicit user confirmation
  before editing because the task touches sensitive behavior, shared contracts,
  broad coupling, generated/runtime configuration, unclear rollback, or
  materially ambiguous requirements.
- `L3`: blocked inside Ralph; stop for replanning, a human decision, or an
  exceptional permission decision.

Risk tiers are implementation caution, not permission classes. Permission
profiles decide whether action categories such as source edits, local git,
non-destructive worktree changes, dependency, network, pull request, or CI may
proceed. Exceptional actions are outside standing profiles and require explicit
one-off approval.

## Ralph Review Gate

Before Ralph edits project source, verify the real project repo is writable in
the active session and confirm the active permission profile covers `local`
source edits. If the repo is outside the current workspace or sandbox, state
that writable access is required before execution instead of declaring the task
Ralph-ready. If `local` profile coverage is absent, route through
`automation-policy` before editing.

During Ralph Mode, run a read-only implementation review after substantial
waves, queued work, or high-impact slices are implemented and initially
verified, before marking the boundary complete in active work records. The
reviewer inspects the actual code or diff with the active work record, build
log, optional task queue, and compact packet when relevant as context.

Review gate selection is based on scope and change impact. Risk tier controls
Ralph execution confirmation before editing, not review selection or permission
profile. Review gates are required for `S2/S3` wave or group boundaries and
queued tasks that touch foundational behavior such as bootstrap, install,
update, registration, generated commands, hooks, settings, config, test
harnesses, project or hub ownership, security policy, or automation policy.
After the final wave in a group lands, run a group-level review gate over the
integrated cross-wave diff before the slice, group, or acceptance task is
marked complete, even if every per-wave gate already passed.

The main session must validate reviewer findings before acting: give each
finding an explicit verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or
`false-positive` — before editing any code, then apply only `confirmed-in-scope`
fixes, turn `confirmed-out-of-scope` findings into follow-up notes or tasks, and
reverify review-driven fixes with the narrowest meaningful command for the fixed
behavior. If a required or expected gate is skipped, record review debt
and do not continue to dependent tasks until the debt is resolved or explicitly
accepted by the user.

## Compaction

At pause, compact, handoff, blocker, milestone, finish, or project-switch
boundaries, prepare compact-safe state in `projects/<id>/work/context-pack.md`.
That file also carries the handoff fields when pausing or transferring work.

Compact-safe state must include goal, last completed boundary, current boundary
status, next exact action, scope boundary, files to inspect first after compact,
known reference paths, verification status, review state, group-level review
state when a group exists, drift result, blockers and risks, git state,
broad-search triggers, and stop reason.

`/compact` is human-triggered. Ralph may pause and say the state is
compact-ready when context is low, a milestone just finished, or the next wave
needs a clean context. Do not claim `/compact` ran unless the user or runtime
actually ran it.

After compact, start from the designed resume anchors: `context-pack.md`,
`active-work.md`, `build-log.md`, optional `task-queue.md`, project
`project.md`, `memory.md`, and live branch/HEAD/status. Read `roadmap.md` when
longer-horizon direction matters, and read optional `decisions.md` only when it
exists. Then rebuild enough of the active boundary neighborhood to work safely.
Expand beyond that for concrete triggers such as a stale resume packet, missing
acceptance criteria, failing verification, generated parity, security or
permissions behavior, or review scope.

Future runtime-style auto-compact protection could snapshot minimal active
state to `projects/<id>/work/` immediately before automatic compaction. Keep
this as future design work, not current hub-lite behavior.

## Project Repos

Project repos keep source code. Registration may add `.piper/project.json` and
`PIPER.md`, but those markers do not make the repo a Piper runtime.
