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
  `projects/<project-id>/project.md`, or in a lane's recorded git worktree of
  that repo.
- Keep behavior feedback in shared records when it applies to Piper Station;
  use runtime-specific notes only for harness mechanics.
- Do not store secrets, credentials, private keys, customer data, or raw
  sensitive logs in hub records.

## Runtime Surfaces

- Codex: `AGENTS.md` and `.codex/`.
- Claude Code: `CLAUDE.md` and `.claude/`.
- OpenCode: `opencode.json` and `.opencode/`.

A hub may have multiple runtime surfaces installed. Concurrency is per lane:
one active session per lane, regardless of harness. Concurrent lanes on one
project are supported through group folders and worktrees (see Project Records
and Group Lifecycle); two sessions on one lane are not.

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

Some repetition is intentional, but contracts are defined once. Root docs
repeat high-signal rules because they are always loaded; command/reference
files repeat procedure so they can be used directly; hooks repeat the short
compact field labels because they are runtime output; agents repeat role
boundaries because they are delegated prompts. Policy tables, ownership rules,
field lists, and checkpoint contracts are defined once in the canonical docs
above; every other surface points to the owning section by name instead of
restating it, so a rule change lands in one place.

## Dispatch Contract

`brainstorm` owns the decision-quality front door for the divergent phase —
orientation, framing, divergence, investigation, registration routing, and
route selection. It stays read-only for orientation and planning; explicit
registration is the narrow exception and must go through the deterministic
helper. `design-studio` is an optional deeper practice inside that divergent
movement: brainstorm may suggest it, and the user may invoke it directly, but
entry and durable studio artifacts require an explicit user choice.
`piper-workflow` owns convergent execution once a direction is set. Slash
commands are explicit shortcuts into the same behavior. Commands, narrow
skills, agents, hooks, and docs provide supporting behavior after a skill or
command has selected the route.

The boundary between them is the same verb, different intent: `brainstorm`
explores to *generate* a direction; `piper-workflow` (Superpowers) verifies that
direction against the code to *follow through* on it before durable planning.

Use this dispatch table when intent is unclear:

| User intent | Route | Supporting behavior |
| --- | --- | --- |
| Register a repo | `brainstorm`, `/add-project`, or `./bin/add-project` | deterministic registration helper |
| Orient, explore, compare options, or decide what to do | `brainstorm` | `brainstorm` |
| Open or continue an in-depth, durable design session | `design-studio` after explicit user choice | `design-studio`; may be suggested by `brainstorm` or invoked directly |
| Verify a direction, define group or milestone structure, or formalize the current wave | Superpowers Mode or `/superpowers` | `piper-workflow`, `/superpowers`, and this guide |
| Execute one clear active-work wave, group review and closeout, explicit slice, or optional queued task | Ralph Mode or `/ralph` | `/ralph` and this guide; project source edits require `local` profile coverage |
| Review code, an implemented wave, group, or slice | Review Mode | `review` |
| Local git, worktree, PR, dependency, network, CI, exceptional, or external action | Finish Mode or permission approval flow | `automation-policy` |
| Pause or compact active work | `/compact-handoff` | compact handoff guidance |

If a project-work request is ambiguous or arrives without a slash command, treat
it as an implicit `brainstorm` request — skill descriptions match by phase
(explore vs execute), and this contract owns the tie-break for genuine
ambiguity. A request does not enter Design Studio merely because it mentions
design or is complex; brainstorm explains the value of the deeper path and
waits for the user's explicit choice. Ordinary brainstorm may still hand
directly to Piper Workflow. Use visible mode names when they help continuity,
but do not make the user operate the mode layer. Prefer consequence language
such as "I will keep this read-only" or "I will create Ralph-ready work
records" over ceremonial mode announcements.

### Artifact Signal Policy

Infer durable artifacts from the user's intent signal and state the consequence
when it matters. `brainstorm` acts on the front-door band: read-only
orientation and conversational planning, plus explicit deterministic
registration. Explicit Design Studio entry owns useful hub design and
continuity artifacts without authorizing source implementation. The convergent
rows below belong to `piper-workflow` (formal planning, Ralph execution) and
`automation-policy` (permission-gated finish actions):

| User signal | Interpretation | Durable writes | Assistant stance |
| --- | --- | --- | --- |
| "review this repo", "understand what this does", "what is this project", or a repo path with an explanation or review request | Orientation or review | None by default | Inspect the repo in place. Say the work is read-only and that registration or hub records will wait unless asked. |
| "what would it take", "how should we approach", "compare this to", or "plan the refactor" before registration | Conversational planning | None by default | Produce a grounded plan in chat. Avoid hub records unless the user asks to formalize. |
| "register this", "track this project", or "this is formal work now" | Registration | `project.md` and `memory.md` only | Use the registration helper. Prefer hub-only records unless repo marker files are explicitly wanted. Do not create `work/` or start implementation. |
| "open a design studio", "enter design studio", or "continue the studio" | Explicit Design Studio | Useful files under `projects/<id>/work/design/` plus existing Piper continuity records only when needed | Create or reuse one studio for the initiative. Stay discussion-first and hub-owned; do not create groups or waves, edit project source, or infer git/external authority. |
| "build it", "implement this", or "let's code" after design or brainstorm work when no formalized wave exists | Convergent entry, not direct editing | None until formalization | Check any design artifact's acceptance state first, then route to Superpowers Structural Planning, or a single Ralph task when genuinely small. Do not edit project source before formalization. |
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
    groups/<gid>/    # one lane folder per group, created at group Entry
```

`project.md` stores repo binding, overview, and project policy preferences such
as permission profile, one-off approvals, accepted risks, and project-level
automation notes. It is not a commit ledger or a per-wave changelog — commit and
acceptance history live in `build-log.md`, anchored to git. `memory.md` stores
durable facts, preferences, stable conventions, and reusable context, not a
per-wave completion log. `decisions.md` is optional for substantial decision
logs; registration does not create it, and it is created only when a real
decision needs a durable home. Supersede a reversed decision in place — mark it
`Superseded` with a pointer to the decision that replaced it rather than deleting
it.

`work/` may contain `roadmap.md`, `active-work.md`, `build-log.md`,
`context-pack.md`, optional `task-queue.md`, lightweight design notes under
`work/design/<topic>.md`, optional full studios under
`work/design/<studio-slug>/`, and one lane folder per group under
`work/groups/<gid>/`.

**Lanes.** A lane is the unit that owns a set of window artifacts and one
checkout. The **flat lane** is the project-level `active-work.md`,
`context-pack.md`, and optional `task-queue.md`; it serves ungrouped waves and
the Design Studio boundary. Each group is its own **group lane**:
`work/groups/<gid>/{active-work,context-pack,build-log,task-queue}.md`, where
`<gid>` is the group's lower-kebab id fixed at Structural Planning (for example
`g1-deepagent-adapter`) and the folder name is that id. Every group uses its
folder, created at group Entry and never by registration. Windows live where
their boundary lives: one active session works a lane at a time, and several
lanes of one project may be active in parallel sessions.

**One checkout per lane.** The registered `repo_path` is held by at most one
lane at a time. A lane holds it when its `active-work.md` header records
`checkout:` equal to `repo_path`; the flat lane holds it by default, only while
no active group header does. Every other active lane works in its own git
worktree of the project repo (`git worktree add`, a `local` action; default
path `<repo-parent>/<repo-basename>-worktrees/<gid>`), recorded as its
`checkout:`. A flat lane that takes a worktree records `checkout:` and
`branch:` in its own `active-work.md` header, so that file is then required.
Before editing, a session reads the active group headers: if one binds
`repo_path`, the flat lane has no checkout of its own. The lane's checkout
must be writable in the active session — a worktree outside `repo_path` needs
its own workspace access grant — and every git-derived fact for the lane is
read in that checkout. While a group holds `repo_path`, an ungrouped request
is surfaced rather than started: run it inside that group (its single
build-log entry then lands in that group's ledger), wait, or give it a
worktree.

Registration must not create `work/`.

Use artifacts as structured working memory, not rigid ceremony. Plan in
slices, execute in waves, and checkpoint at boundaries. Slices are
decomposition units; waves are implementation and checkpoint units. Detail the
current wave enough to execute safely. Sketch later waves only when the current
code, context, and prior results make them reliable.

The default unit of work is one ungrouped wave. Its **light boundary** costs
one `build-log.md` entry at acceptance; `active-work.md` only when the wave
needs continuity before it lands; no `roadmap.md` and no `task-queue.md`; and
`context-pack.md` only when there is something to resume (pause, compact,
blocker). A finished ungrouped wave with no open state writes no packet; if one
exists, it is rewritten to `idle`. Ceremony scales with the boundary, not with
the project: a small wave inside a large project pays the light boundary.

Groups bundle related waves under a shared acceptance target and one
integrating review gate. Entering a group is an explicit planning decision
(Superpowers Structural Planning), never a default: use a group when multiple
waves must land before the larger boundary is accepted, when cross-wave
interaction risk matters, or when the work will run alongside other work on
the same project. A group has its own lane folder: its boundary in that
folder's `active-work.md`, its ledger in that folder's `build-log.md`, and its
own review gate over the integrated cross-wave diff before acceptance. Its
operating stages are defined under Group Lifecycle.

### Work Artifact Reference

Create these only under `projects/<project-id>/work/`, never in the registered
project repo. Use each artifact only when it does a clear job for autonomy,
continuity, quality, or compact/resume. The windows and the ledger exist per
lane: at the project level for the flat lane, and inside `work/groups/<gid>/`
for each group lane.

| Artifact | Purpose | Create or update when |
| --- | --- | --- |
| `roadmap.md` | Longer-horizon direction: groups, milestones, their durable order and acceptance status, deferred work, risks, and revisit triggers. | Project direction, group order, milestone sequence, acceptance status, deferred scope, or revisit triggers change. |
| `active-work.md` | Live group and wave workbench: current goal, group boundary, current wave details, reliable later-wave sketches, slice breakdown, required gates, group review state, acceptance criteria, risks, verification strategy, and open questions. In a group lane its header also binds the lane: `branch:`, `checkout:`, `boundary:` (owned paths or areas), and `status:`. | Current group or wave needs durable continuity before implementation, review, compact, or delayed execution. |
| `build-log.md` | The single interpretive checkpoint ledger for its lane: concise summaries of what happened, final contracts, the per-wave acceptance commit, review and verification results, risks, and next steps. Not a per-commit changelog or raw transcript — the commit list and diffs derive from git. The project ledger is the seam between lanes (ungrouped-wave entries, planning entries that define groups, group closeout entries, transition entries, milestones); a group ledger holds that group's Entry, wave, review/fix, blocker, compact, and base-sync entries. | A meaningful planning, wave, review/fix, finish, compact, blocker, group, or milestone checkpoint occurs. |
| `work/groups/<gid>/` | A group lane: the group's own `active-work.md`, `context-pack.md`, `build-log.md`, and optional `task-queue.md`, with the lane binding in the `active-work.md` header. After closeout the windows are rewritten to a short `closed` pointer and the folder remains as the group's archive. | Group Entry; the folder name is the gid fixed at Structural Planning. Never at registration or planning. |
| `context-pack.md` | The resume packet: the non-derivable state of the current boundary, rewritten in full. Its fields are defined once under Compaction; anything git or the ledger can answer is derived at resume, not stored here. | A resume trigger fires (see Boundary triggers under Artifact Persistence): active work may pause, compact, finish, hit a blocker, reach a milestone, switch projects, or hand off. |
| `task-queue.md` | Optional durable Ralph execution queue: task ids with status, risk, acceptance criteria, verification, dependencies, expected diff boundary, and explicit group review gate items for multi-wave groups. Holds pending work only; completed items roll off at group closeout. | Native runtime task tracking is insufficient because waves, slices, or group gates must survive the current session or move across agents. |
| `work/design/<topic>.md` | Lightweight topical design note for work that does not need a full studio. Topical, superseded in place, and preserved if later promoted. | A useful design note deserves durability but not a multi-file, multi-session studio. |
| `work/design/<studio-slug>/` | Optional full Design Studio. Project and studio READMEs provide navigation; `design.md` owns the integrated design, integer revision, and explicit revision-specific acceptance; optional artifacts emerge with descriptive names. | The user explicitly enters Design Studio and the initiative needs deeper or multi-session design. Reuse the existing initiative folder and never destructively migrate a note or ad hoc folder. |

### Artifact Recording Economy

Record the least artifact state that preserves continuity. `context-pack.md` is
the only fully self-contained resume packet; every other artifact stays lean and
holds only what is intrinsic to its own purpose.

**Temporal roles.** Most lifecycle problems come from mixing three roles:

- *Sinks* accumulate by design and should grow with the project — `build-log.md`
  (the chronological ledger), `decisions.md`, and durable `memory.md` facts. Do
  not prune them; their growth is correct.
- *Windows* hold only current state — `active-work.md`, `task-queue.md`, and
  `context-pack.md`. Superseded detail rolls off into a sink at the next
  boundary; a window that retains completed history has become a second-rate
  sink.
- *Topical references* are durable but organized by subject, not time, and are
  superseded in place — `decisions.md`, lightweight
  `work/design/<topic>.md` notes, and a studio's canonical `design.md` plus
  supporting artifacts. READMEs remain navigation rather than mutable state
  ledgers.

**Derive, do not duplicate.** Git in the registered project repo is the source of
truth for the mechanical history axis: raw diffs, the commit list, and current
branch/HEAD/status, each read in the lane's checkout. Read these live at each
checkpoint and resume rather than
trusting a stored value; record an observed commit only in the artifact that
owns it — `build-log.md`'s per-wave acceptance commit — and do not repeat it
across the other records (`context-pack.md`, `roadmap.md`, `active-work.md`,
`task-queue.md`, `project.md`, `memory.md`). Re-recording the
same commit hash or HEAD across several artifacts is the main cause of
cross-artifact drift, because each copy ages on its own. Read the cheap
current-position facts first — `git rev-parse HEAD`, `git status --short`, and
branch — and take the acceptance commit from `build-log.md`; reach for full diffs
or history (`git diff`, `git log`) only when the task itself needs them, such as a
review or drift-check, not to reconstruct breadcrumbs that are already recorded.
This extends the existing default of leaning on native runtime task tracking for
short-lived steps — here, lean on git for history.

**Fact ownership.** Each fact has one home; other artifacts reference it, they do
not restate it:

| Fact | Single home |
| --- | --- |
| Raw diff, commit list, current branch/HEAD/status | git (project repo), read live in the lane's checkout |
| Per-wave acceptance commit, review verdict, contracts, next step | the lane's `build-log.md`, recorded once at the boundary |
| Current boundary pointer and the resume packet | the lane's `context-pack.md` |
| Current wave detail, slice breakdown, acceptance criteria, current scope and non-goals | the lane's `active-work.md` |
| Group lane binding: branch, checkout, owned boundary, lane status | the group's `active-work.md` header, set at Entry |
| Long-horizon direction, group/milestone order and acceptance status, milestone labels, durable non-goals | `roadmap.md` |
| Substantial decision rationale | `decisions.md` (supersede in place) |
| Repo binding and project policy preferences | `project.md` |
| Durable facts and stable conventions | `memory.md` |

Per-artifact rules follow from the roles and ownership above:

- `roadmap.md`: long-term direction only. Do not turn it into the current work
  tracker or checkpoint ledger. It owns durable group and milestone order and
  acceptance status (pending to accepted); the fine-grained current tracker is
  `active-work.md` and the checkpoint ledger is `build-log.md`.
- `active-work.md`: the current group and wave window only. Keep the current wave
  actionable; sketch later waves only when reliable. In a group lane, make the
  group header, wave list, required gates, group review state, and acceptance
  target explicit, and bind the lane in the header — `branch:`, `checkout:`,
  `boundary:` (owned paths or areas), `status:` (`active` or `closed`) — as
  bindings set at Entry, not derived state. Do not duplicate the resume packet
  or chronological log. At group closeout, its completed-wave detail rolls off
  into the project build-log closeout entry, and the lane's windows are
  rewritten to a short `closed` pointer (never deleted).
- `build-log.md`: the single interpretive ledger for its lane. Record concise
  checkpoint summaries, final contracts, the per-wave acceptance commit, and
  review and verification results once at each boundary. It is not a per-commit
  changelog or a raw verification transcript — the commit list and diffs derive
  from git. A group ledger (`work/groups/<gid>/build-log.md`) holds the group's
  Entry, per-wave acceptance, review/fix, blocker, compact, and base-sync
  entries. The project ledger is the seam between lanes: ungrouped-wave
  entries, planning entries that define groups, group closeout entries,
  transition entries, and milestones. Give group closeout its own entry in the
  project ledger; it condenses the group ledger and points back to it.
- `context-pack.md`: the resume packet of non-derivable state, rewritten in
  full to reflect only the current boundary (fields under Compaction). Derive
  git state live; reference `build-log.md` for history rather than replaying it.
- `task-queue.md`: durable queued waves, slices, or group gate items only.
  Native runtime task tracking is the default for short-lived in-session steps.
  Completed items roll off at group closeout; keep only pending work. For
  multi-wave groups, list the group review gate as an explicit acceptance
  criterion before the acceptance task.
- `work/design/<topic>.md`: keep lightweight topical notes supported. If later
  promoted, preserve the note, integrate useful content into a new or existing
  studio through discussion, and add relationship or supersession links rather
  than moving or deleting it.
- `work/design/<studio-slug>/`: create or reuse only after explicit Design
  Studio entry. Keep `work/design/README.md` as the project index when present,
  the studio `README.md` as local navigation, and `design.md` as the sole owner
  of current integrated design, revision, and acceptance. Optional ledgers and
  supporting artifacts exist only when useful; do not force category
  directories.

### Artifact Persistence

Piper work artifacts are hub-owned project state. Keep them in
`projects/<project-id>/work/` by default; do not move them into the registered
project repo unless the user explicitly asks for a project-local copy.

When `context-pack.md` changes, rewrite it in full so a fresh session can resume
without transcript archaeology. Its fields are defined once under Compaction;
do not restate them here or elsewhere.

Artifact updates are normal local assistance while work is active. Permission
profiles gate whether a commit action can proceed; they do not make artifact
commits automatic or change checkpoint timing. Do not ask after every artifact
edit. Instead, disclose changed Piper artifacts at checkpoints and ask about a
Piper artifact commit only when the stopping point or future continuity
warrants it.

**Boundary triggers.** One list, referenced everywhere else. A checkpoint is
any of: a wave accepted; a group review, closeout, or milestone; the end of
formal planning; a material change to active work; a blocker; pause, compact
preparation, context low, project switch, or hand-off; finish; or the user
saying pause, save, compact, finish, or commit. During Ralph execution a
checkpoint appends `build-log.md`, and updates `task-queue.md` only when a
durable queue is in use. `context-pack.md` is rewritten, and an artifact commit
considered, only at the resume triggers: group closeout, milestone, material
active-work change, pause, compact preparation, context low, project switch,
hand-off, blocker, or finish.

**Checkpoint invariant.** Every checkpoint must leave two things true:

1. The lane's windows and ledger agree on where work is, any divergence is
   explained rather than silently carried, and a fresh session could resume
   from the hub records plus live git alone. Concretely: the lane's
   `active-work.md` current wave matches its `context-pack.md` boundary when
   both exist; the live HEAD of the lane's checkout equals (at an accepted
   boundary) or descends from (mid-wave, with uncommitted files noted) the
   latest acceptance commit in the lane's `build-log.md`, on the lane's
   recorded branch; the checkout is on that branch; and every roadmap group
   marked accepted has a closeout entry in the project ledger, and vice versa.
2. Changed Piper artifacts are disclosed separately from registered project
   source changes, with their hub commit state stated. An artifact commit,
   when the checkpoint chooses one, is a `local` permission action under
   `automation-policy.md`, kept separate from any project source commit, and
   path-scoped: the hub checkout is shared by every session, so stage and
   commit only your lane's paths plus the project-level files you touched —
   never `git add -A` or `commit -a` in the hub — and mention, never stage,
   other lanes' uncommitted files. On an `index.lock` collision, retry; never
   delete the lock.

How much writing that takes depends on the boundary: a light boundary satisfies
the invariant with one build-log entry and live git; a group closeout needs the
full roll-off. Record what the invariant requires, not a fixed set of files.

**Reference method** (one way to satisfy the invariant, not a required
script): report changed Piper artifacts separately from project source
changes; inspect git state in the project repo and, when artifacts changed, in
the hub; state whether artifact changes are uncommitted in the hub; decide
whether this checkpoint warrants an artifact commit; then reconcile the windows
against the ledger and resolve unexplained mismatches before continuing.

## Mode Routing

Route requests through `brainstorm` (the front door), optional `design-studio`,
`piper-workflow` (convergent execution), command shortcuts, and the smallest
mode that fits:

- Brainstorm (front door): orient, frame the problem, weigh options,
  investigate, route explicit registration through the helper, and produce a
  decision-ready hand-off brief; stay read-only except for that deterministic
  registration path.
- Design Studio (optional divergent path): after explicit user choice, create
  or reuse durable hub-owned design artifacts, work discussion-first across
  sessions, and either pause, conclude without implementation, or hand an
  explicitly accepted revision to Piper Workflow. It does not create groups or
  waves or edit project source.
- Superpowers Mode: verify the handed-off direction, define the group or
  milestone structure (Structural Planning), then formalize the current wave
  (Wave Formalization) before substantial implementation.
- Ralph Mode: execute the current active-work wave, group review and closeout,
  one explicit slice, or one queued task; verify, drift-check, commit completed
  waves under `local`, and use implementation review gates at meaningful
  boundaries.
- Review Mode: first check whether the work matches the request or active work,
  then check code quality; group reviews inspect the integrated cross-wave
  diff.
- Finish Mode: report verification, residual risk, changed files, and commit or
  pull request options without mutating git automatically.

Scope tiers are advisory sizing, not artifact rules; artifact creation is
driven by durable need, and scope only informs how strongly persistence is
surfaced:

- `S0`: direct small task; stay in chat unless the user asks to record
  something or a durable project fact, policy preference, checkpoint, or
  verification result appears.
- `S1`: modest work; use `active-work.md` only when the current work needs
  continuity.
- `S2`: substantial work; a clear current wave in `active-work.md` and
  checkpoint entries in `build-log.md` likely help; create `task-queue.md`
  only when durable queued execution is needed.
- `S3`: broad or long-running work; `roadmap.md` for group or milestone
  direction, `active-work.md` for the current group and wave, and checkpoint
  entries in `build-log.md`.

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

Before Ralph edits project source, verify the lane's checkout (`repo_path` or
its recorded worktree) is writable in the active session and confirm the
active permission profile covers `local` source edits. If the checkout is
outside the current workspace or sandbox, state that writable access is
required before execution instead of declaring the task Ralph-ready. If `local` profile coverage is absent, route through
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

## Group Lifecycle

The group lifecycle is the operating layer above the wave: it bounds a group and
carries work from one group to the next, so long-running multi-group work does
not rely on ad hoc judgment at each boundary. `piper-workflow` owns this
lifecycle as convergent execution above the wave and operates each stage through
its existing modes. Within-group execution — waves, slices, and per-wave review
gates — is covered under Mode Routing and the Ralph Review Gate.

**Lane selection.** Every entry into Ralph, Superpowers, or compact handoff
selects one lane first, by one rule: a token that names an existing
`work/groups/<gid>` folder selects that group lane, and any other token is a
boundary inside the selected lane; with no token, exactly one candidate lane —
one group whose header status is `active` while the flat lane has no open
boundary (no packet, or a packet whose status is `idle`), or the flat lane
alone — is selected; with more than one candidate, ask, never guess;
with none, the flat lane. A group is active when its folder exists and its
header `status:` is not `closed`.

A group moves through four stages, each driven by `piper-workflow`:

1. **Entry.** Before the group's first wave, `piper-workflow` re-verifies the
   group's structural sketch — boundary, acceptance target, and revisit triggers
   — against the current code, which may have moved since the roadmap was drawn
   or since a prior group landed. It creates the group lane folder
   `work/groups/<gid>/`, binds the lane in the `active-work.md` header
   (`branch:`, `checkout:`, `boundary:`, `status: active`) — taking a worktree
   when another lane already holds `repo_path` — and reads the other active
   lanes' headers to surface any overlap between their `boundary:` and this
   one, for the user to decide; overlap is never a block. It runs Superpowers
   Structural Planning scoped to this group when the sketch needs repair, then
   Wave Formalization for the first wave. Repair drift that only reshapes this
   group here; escalate drift that invalidates the group's premise or changes
   other groups (see Transition).
2. **Execution.** `piper-workflow` implements the group's waves through Ralph
   Mode in the lane's checkout on the lane's branch, with verification, drift
   checks, and per-wave review gates; wave entries go to the group ledger. A
   wave that is implemented, verified, drift-checked, and reviewed when its
   gate applies is a natural commit point for the project source (see commit
   cadence below).
3. **Closeout.** After the final wave lands, `piper-workflow` closes the group
   in this order: sync the group branch with the project's base branch;
   verify; run the group review gate over the integrated cross-wave diff
   (`base..group`, in the lane's checkout) and resolve findings; commit any
   remaining group source not already committed per wave; integrate the group
   branch into base — a merge that preserves the group's commits by default;
   if the user chooses a rebase, record old tip → new tip in the closeout
   entry; where policy forbids a local merge, record `integrated: pending-pr`
   — then write the group-closeout entry in the **project** `build-log.md`,
   mark the acceptance target met, and tick the group's status in
   `roadmap.md`. The closeout entry condenses the group ledger and points back
   to it: acceptance target and verdict; the wave list with one-line outcomes;
   the group-gate result, finding verdicts, and any accepted review debt; the
   contracts or learnings later groups depend on; the group branch, its final
   acceptance commit, and the integration commit (or `pending-pr`); deferred
   scope; and the worktree path, which remains (deleting a worktree is
   `exceptional`). It then **rolls the group off the windows**: the
   completed-wave detail is condensed into that closeout entry (summarized,
   not relocated verbatim, so the ledger keeps concise entries), and the
   lane's `active-work.md`, `context-pack.md`, and `task-queue.md` are
   rewritten to a short `closed` pointer to it — never deleted — so the folder
   remains as the group's archive. A group is complete only when its
   acceptance target is met and the integrating review gate has passed.
4. **Transition.** Between closeout and the next group's Entry, `piper-workflow`
   checks whether this group's actual outcome changes the sketches, ordering, or
   premises of later groups, and carries the captured contracts and learnings
   forward, recording any reshaped later-group scope or roadmap drift in
   `roadmap.md`. Lanes still active in parallel sync their branch with base
   before their next wave — whether a lane is behind is derived
   (`git log <group>..<base>`), never recorded — and treat merge-conflict edits
   as expected expansion in their drift check. It proceeds to the next group's
   Entry when the outcome holds the roadmap, and surfaces the change for
   re-planning when it materially reshapes later groups or a milestone.
   Re-planning stays within `piper-workflow` (Superpowers); hand back to
   `brainstorm` only when the change reopens a genuinely divergent question.

When planning starts from a Design Studio handoff, Superpowers verifies the
exact `design_artifact` and integer `accepted_revision` against the current
`design.md` metadata and live source. Choices inside recorded implementation
freedoms stay downstream. A stale revision or source evidence that invalidates
a fixed contract or core premise returns to Design Studio rather than being
silently redesigned in execution planning.

Advancing through these stages follows normal mode routing: `piper-workflow`
proceeds when the next stage is clear and authorized, and waits for go-ahead when
confirmation is required or the next group's direction is unsettled.

Commit cadence rides on these boundaries: per-wave source commits during
Execution and a group source commit at Closeout, each on the lane's branch in
the lane's checkout and each a `local` action under `automation-policy`. Under `local` coverage, commit and report each completed
wave without a per-wave ask; surface for approval when the profile is below
`local`. Keep source commits separate from Piper artifact commits, at wave and
group boundaries, not mid-slice. These are commits only — push and pull requests
remain `external` actions.

Milestones are roadmap-level markers that a sequence of groups completes a larger
deliverable; they are not a separate lifecycle. When a group closeout also
completes a milestone, note it in the closeout entry and mark the milestone met
in `roadmap.md`.

The lifecycle composes existing `piper-workflow` mechanisms — Superpowers
Structural Planning and Wave Formalization at Entry, Ralph Mode at Execution, the
group review gate and build-log closeout entry at Closeout — adding only the
cross-group steps: entry re-verification, the roadmap acceptance tick,
carry-forward, and the transition check.

**Legacy layout.** A group whose windows still live in the flat lane moves into
`work/groups/<gid>/` once, at its next wave or pause boundary: only if the
folder does not already exist (if it does, reconcile, never overwrite); the
flat `build-log.md` is a sink and is not split — the new group ledger opens
with a pointer to the earlier entries; only queue items tagged with the group
move; the header bindings are added in the same path-scoped hub commit; and a
legacy group already at Closeout closes out in place.

## Compaction

At the resume triggers (see Boundary triggers under Artifact Persistence),
prepare compact-safe state in the selected lane's `context-pack.md`:
`projects/<id>/work/context-pack.md` for the flat lane,
`projects/<id>/work/groups/<gid>/context-pack.md` for a group lane. That file
also carries the handoff fields when pausing or transferring work.

The packet holds only non-derivable state. Its required fields, defined here
and nowhere else:

1. **Goal** of the current boundary, one line.
2. **Boundary**: the lane (`flat` or `<gid>`), the wave, and its status — `idle`, `mid-wave`,
   `accepted`, `group-review`, `closeout`, `between-groups`, `blocked`, or
   `closed` (a group lane after closeout).
   Add the scope boundary when no `active-work.md` carries it, and the branch
   when it is not the repo's default branch.
3. **Next exact action**, naming the first file to open.
4. **Verification and review state not yet recorded in `build-log.md`**:
   unverified claims, open findings with their verdicts, and drift when it is
   not none.
5. **Blockers, risks, and open questions.**
6. **Stop reason.**
7. Optional: **broad-search triggers**, and a short **resume note** for a human
   or fresh agent. Transient reference paths go here; durable ones belong in
   `memory.md`.

Derived at resume, never authored into the packet: the repo path
(`project.md` and the registry); branch, HEAD, and status (live git); files
changed and commits since the last acceptance commit in `build-log.md` (live
git); what to inspect first (the changed files, `active-work.md`, and the
build-log tail); hub artifact commit state (live git in the hub); and group or
transition state (`roadmap.md` plus the closeout entries). If git or the ledger
can answer a field, the packet references it rather than copying it. An `idle`
packet — nothing active, next action "pick the next boundary" — is a few lines.

Regenerate, do not append. Rewrite `context-pack.md` in full so it reflects only
the current boundary; never section-edit or append, which is what lets stale
lower sections — verification, review, stop reason — survive and contradict the
header. Superseded verification and review history stays in `build-log.md` and is
referenced, not replayed; git state is derived live rather than copied from a HEAD
that can age.

Cold-resume guard: a full rewrite must first read the existing packet, carry
forward every still-relevant non-derivable field from it, and reconcile against
live git before replacing it. Never regenerate purely from freshly compacted,
lossy working memory — that can drop a still-relevant field.

`/compact` is human-triggered. Ralph may pause and say the state is
compact-ready when context is low, a milestone just finished, or the next wave
needs a clean context. Do not claim `/compact` ran unless the user or runtime
actually ran it.

After compact, start from the designed resume anchors in the selected lane:
its `context-pack.md`, `active-work.md`, `build-log.md`, optional
`task-queue.md`, project `project.md`, `memory.md`, and live branch/HEAD/status
in the lane's checkout; derive the fields listed above before acting on the
packet. Read `roadmap.md` when
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
