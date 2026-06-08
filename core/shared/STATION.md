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
| Execute one clear queued task | Ralph Mode or `/ralph` | `/ralph` and this guide; project source edits require `local` profile coverage |
| Review code or an implemented slice | Review Mode | `review` |
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
| "register this", "track this project", or "this is formal work now" | Registration | `project.md`, `memory.md`, and `decisions.md` only | Use the registration helper. Prefer hub-only records unless repo marker files are explicitly wanted. Do not create `work/` or start implementation. |
| "make this a formal plan", "prepare for Ralph", "create the queue", "we need continuity", or "set this up for later execution" | Formal planning or Ralph preparation | Useful `projects/<id>/work/` records | Create the durable record set the scope needs, such as active spec, active plan, task queue, context pack, and verification. State that source remains untouched. |
| "start Ralph", "build task X", "execute the first queue item", or "implement according to the plan" | Ralph execution | Update `work/` records as useful; edit the real project repo when `local` profile coverage exists | Confirm the selected task, diff boundary, risk, verification, writable repo access, and `local` profile coverage before editing. Route through `automation-policy` if coverage is absent. Execute one scoped slice. |
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
  decisions.md
  work/              # optional, created only when useful during active work
```

`work/` may contain `active-spec.md`, `active-plan.md`, `task-queue.md`,
`context-pack.md`, `verification.md`, and optional `specs/`, `plans/`, and
`runs/`.

Registration must not create `work/`.

### Work Artifact Reference

Create these only under `projects/<project-id>/work/`, never in the registered
project repo. Use the active files for the current scope; use the archive
directories only when substantial work needs preserved history.

| Artifact | Purpose | Create or update when |
| --- | --- | --- |
| `active-spec.md` | Stable requirements: problem statement, goals, non-goals, acceptance criteria, risks, and open questions. | Work is `S2+`, requirements need durable agreement, or Ralph needs a stable target. |
| `active-plan.md` | Current implementation approach, ordered slices, tradeoffs, dependencies, and verification strategy. | Work is `S1+` and the plan must survive compaction or handoff. |
| `task-queue.md` | Ralph-ready task ids with status, risk, acceptance criteria, verification, and expected diff boundary. | There are clear executable slices for Ralph or future sessions. |
| `context-pack.md` | The full compact/resume packet: goal, current task, next exact action, key files, what to inspect first, branch/HEAD/status, verification state, review state, drift, blockers, stop reason, and what to hand a human or fresh agent. | Active work may pause, compact, finish, hit a blocker, reach a milestone, switch projects, or hand off. |
| `verification.md` | Concise check evidence: commands run, results, failures, fallbacks, skipped checks, and remaining verification gaps. | Planning defines verification, Ralph runs checks, or verification is blocked. |
| `specs/` | Archived or named specs for milestones or alternatives. | `S3` or long-running work needs more than one durable spec. |
| `plans/` | Archived or named plans for milestones, alternatives, or superseded approaches. | `S3` or long-running work needs plan history beyond `active-plan.md`. |
| `runs/` | Optional per-run notes for substantial Ralph iterations or review/verification cycles. | Per-run execution detail would be too dense to preserve in `context-pack.md`. |

### Artifact Recording Economy

Record the least artifact state that preserves continuity. `context-pack.md` is
the only fully self-contained resume packet; other artifacts should stay lean
and avoid repeating repo path, branch, HEAD, full git state, next action,
blockers, review state, or commit state unless that detail is intrinsic to the
artifact's purpose.

- `active-spec.md`: stable requirements only. Do not turn it into progress,
  implementation notes, or git state.
- `active-plan.md`: current approach, slices, tradeoffs, dependencies, and
  verification strategy only. Do not duplicate the full queue or resume packet.
- `task-queue.md`: task ids, status, risk, acceptance criteria, verification,
  dependencies, and expected diff boundary only.
- `verification.md`: concise command results, failures, skipped checks, and
  gaps only. Prefer summaries over raw logs.
- `context-pack.md`: full resume state and cross-artifact pointers. Update it
  at pause, compact preparation, finish, blocker, milestone boundary, context
  low stop, project switch, or material plan/spec change.
- `specs/`, `plans/`, and `runs/`: use only for `S3` history or dense
  milestone records, not normal slice logging.

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
about a Piper artifact commit only when the scope or stopping point warrants
it. Checkpoints include the end of formal planning, a milestone boundary,
compact preparation, finish mode, before switching projects, or when the user
says to pause, save, compact, finish, or commit.

At every checkpoint:

1. Report changed Piper artifacts separately from registered project source
   changes.
2. Inspect git state for both the registered project repo and the Piper
   Station hub when artifacts changed.
3. State whether artifact changes are uncommitted in the hub.
4. If the workflow checkpoint chooses an artifact commit, treat it as a
   `local` permission action under `automation-policy.md` and keep it separate
   from any registered project source commit.

Scope controls how strongly artifact persistence is surfaced:

- `S0`: no artifact by default; no artifact commit prompt unless the user asked
  to record something.
- `S1`: prefer only `active-plan.md`; mention changed artifacts at finish or
  compact, and ask to commit only when the artifact affects future continuity.
- `S2`: use `active-spec.md`, `active-plan.md`, optional `task-queue.md`, and
  verification notes as the working contract; offer one artifact commit at
  planning finish, compact preparation, finish mode, or material plan/spec
  changes.
- `S3`: multi-milestone artifact state is durable project coordination; treat
  milestone boundaries, compact preparation, finish mode, and material plan or
  spec changes as artifact persistence checkpoints.

After ordinary Ralph slices, update and report `task-queue.md` and
`verification.md` when they are in use. Do not update `context-pack.md` or ask
to commit artifacts unless the slice completes a meaningful milestone,
materially changes the plan/spec, or the user is about to pause, compact,
switch context, or finish.

## Mode Routing

Route requests through `brainstorm` (the front door), `piper-workflow`
(convergent execution), command shortcuts, and the smallest mode that fits:

- Brainstorm (front door): orient, frame the problem, weigh options,
  investigate, route explicit registration through the helper, and produce a
  decision-ready hand-off brief; stay read-only except for that deterministic
  registration path.
- Superpowers Mode: verify the handed-off direction, then specify and plan
  before substantial implementation.
- Ralph Mode: execute one scoped task at a time, verify, drift-check, and use
  an implementation review gate for substantial slices.
- Review Mode: first check whether the work matches the request/spec/plan, then
  check code quality.
- Finish Mode: report verification, residual risk, changed files, and commit or
  pull request options without mutating git automatically.

Scope tiers:

- `S0`: direct small task; no artifact needed.
- `S1`: short active plan in `projects/<id>/work/active-plan.md`.
- `S2`: written spec and plan required before implementation.
- `S3`: split into milestones or sub-specs.

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
slices are implemented and initially verified, before marking the slice
complete in active work records. The reviewer inspects the actual code or diff
with the active spec, plan, task queue, and verification logs as context.

Review gate selection is based on scope and change impact. Risk tier controls
Ralph execution confirmation before editing, not review selection or permission
profile. Review gates are required for `S2/S3` slices and queued tasks that
touch foundational behavior such as bootstrap, install, update, registration,
generated commands, hooks, settings, config, test harnesses, project or hub
ownership, security policy, or automation policy.

The main session must validate reviewer findings before acting: give each
finding an explicit verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or
`false-positive` — before editing any code, then apply only `confirmed-in-scope`
fixes, turn `confirmed-out-of-scope` findings into follow-up notes or tasks, and
reverify review-driven fixes with the narrowest meaningful command for the fixed
behavior. If a required or expected gate is skipped, record review debt
and do not continue to dependent tasks until the debt is resolved or explicitly
accepted by the user.

## Compaction

At natural stopping points, prepare compact-safe state in
`projects/<id>/work/context-pack.md`, which also carries the handoff fields when
pausing or transferring work.

Compact-safe state must include goal, last completed task, current task status,
next exact action, scope boundary, files to inspect first after compact, known
reference paths, verification status, review state, drift result, blockers and
risks, git state, broad-search triggers, and stop reason.

`/compact` is human-triggered. Ralph may pause and say the state is
compact-ready when context is low, a milestone just finished, or the next slice
needs a clean context. Do not claim `/compact` ran unless the user or runtime
actually ran it.

After compact, start from the designed resume anchors: `context-pack.md`,
`task-queue.md`, `active-plan.md`, `verification.md`, project `decisions.md`,
and live branch/HEAD/status. Then rebuild enough of the active task neighborhood
to work safely. Expand beyond that for concrete triggers such as a stale resume
packet, missing acceptance criteria, failing verification, generated parity,
security or permissions behavior, or review scope.

Future runtime-style auto-compact protection could snapshot minimal active
state to `projects/<id>/work/` immediately before automatic compaction. Keep
this as future design work, not current hub-lite behavior.

## Project Repos

Project repos keep source code. Registration may add `.piper/project.json` and
`PIPER.md`, but those markers do not make the repo a Piper runtime.
