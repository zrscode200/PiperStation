# Piper Station Hub

This directory is a Piper Station hub-lite workspace. It coordinates assisted
development across registered project repositories through Codex. Project
records stay shared under `projects/`; source remains in registered repositories.

## Required Behavior

- Treat this hub as lightweight cross-project context, not a workflow engine.
- Do not copy project source code into the hub.
- Register project repos through the brainstorm registration route or `./bin/add-project`.
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

## Runtime Surface

Codex loads `AGENTS.md`, skills, roles, and lifecycle reminders from `.codex/`.
Several sessions may use the same hub and project. One active coordinating
session owns a lane at a time; native workers remain under their parent's
responsibility. A lane is durable working context, not a native session or a
claim that a recorded session is still running.

## Delegated Roles

Piper uses three bounded helper roles. An `investigator` examines a concrete
question or bounded problem area, drawing on the project and outside research
to return evidence, applicable options and uncertainty. Learning goals can guide
it before a preferred direction exists. An `implementer` makes explicitly
authorized scoped source or test changes in its assigned isolated checkout.
A `reviewer` independently challenges
a specific provisional design or exact implementation candidate and reports
findings and limits; it does not repair or accept the result. Architecture,
security, documentation and test design are explicit assignment focuses.

Delegate when separate context or independent work improves the result. Keep
small understood work and known check commands in the main session. Honor
existing scoped grants for writable delegation; without a grant, the parent
can perform already-authorized implementation itself. The main session owns
the user conversation, synthesis, shared records, candidate assembly, integration
and acceptance. Workers do not recursively delegate or acquire lanes by default.

Use `.codex/skills/piper-workflow/references/coordinated-work.md` for assignment,
worker entry, dispatch evidence, source-preserving checks and recovery in any
phase. Observers preserve source, canonical designs and records; bounded test
output must fit actual permissions and any stricter user policy. Installed role
configuration is not proof of effective activation or enforced permissions.
Optional helper availability does not change required independent review gates.

## Instruction Precedence

Use this order when instructions overlap:

1. `STATION.md` defines shared Piper Station behavior, project-record
   ownership, dispatch boundaries, work artifacts, compaction, and Ralph gates.
2. `automation-policy.md` defines action classes (routine, `external`,
   `exceptional`), the boundary asks, and standing policy notes.
3. `AGENTS.md` is the always-on Codex summary of the shared behavior.
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
`piper-workflow` owns convergent execution once a direction is set. Skills and
natural-language requests select the route; named Superpowers, Ralph and compact
handoff procedures live in skill references. They are not installed as custom
Codex slash commands. Roles, hooks and docs support the selected route.

The boundary between them is the same verb, different intent: `brainstorm`
explores to *generate* a direction; `piper-workflow` (Superpowers) verifies that
direction against the code to *follow through* on it before durable planning.

Use this dispatch table when intent is unclear:

| User intent | Route | Supporting behavior |
| --- | --- | --- |
| Register a repo | `brainstorm` or `./bin/add-project` | deterministic registration helper |
| Orient, explore, compare options, or decide what to do | `brainstorm` | `brainstorm` |
| Open or continue an in-depth, durable design session | `design-studio` after explicit user choice | `design-studio`; may be suggested by `brainstorm` or invoked directly |
| Verify a direction, define group or milestone structure, or formalize the current wave | Superpowers planning | `piper-workflow` and its superpowers reference |
| Execute one clear active-work wave, group review and closeout, explicit slice, or optional queued task | Ralph execution | `piper-workflow` and its ralph reference; project source edits in the lane's checkout are routine |
| Review code, an implemented wave, group, or slice | Review Mode | `review` |
| Push, pull request, dependency, networked command with effects, CI, or other `external` or `exceptional` action | Finish Mode or the boundary ask | `automation-policy` |
| Pause or compact active work | compact handoff | `piper-workflow` and its compact-handoff reference |

If a project-work request is genuinely ambiguous, treat it as an implicit
`brainstorm` request — a clear natural-language execution request selects
`piper-workflow` directly. Skill descriptions match by phase
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
`automation-policy` (the `external` and `exceptional` boundary ask):

| User signal | Interpretation | Durable writes | Assistant stance |
| --- | --- | --- | --- |
| "review this repo", "understand what this does", "what is this project", or a repo path with an explanation or review request | Orientation or review | None by default | Inspect the repo in place. Say the work is read-only and that registration or hub records will wait unless asked. |
| "what would it take", "how should we approach", "compare this to", or "plan the refactor" before registration | Conversational planning | None by default | Produce a grounded plan in chat. Avoid hub records unless the user asks to formalize. |
| "register this", "track this project", or "this is formal work now" | Registration | `project.md` and `memory.md` only | Use the registration helper. Prefer hub-only records unless repo marker files are explicitly wanted. Do not create `work/` or start implementation. |
| "open a design studio", "enter design studio", or "continue the studio" | Explicit Design Studio | Useful files and optional lane continuity under `projects/<id>/work/design/<slug>/` | Create or reuse one studio for the initiative. Stay discussion-first and hub-owned; do not create groups or waves, edit project source, or infer external authority. Hub checkpoint commits follow Artifact Persistence. |
| "build it", "implement this", or "let's code" after design or brainstorm work when no formalized wave exists | Convergent entry, not direct editing | None until formalization | Check any design artifact's acceptance state first, then route to Superpowers Structural Planning, or a single Ralph task when genuinely small. Do not edit project source before formalization. |
| "make this a formal plan", "prepare for Ralph", "create the queue", "we need continuity", or "set this up for later execution" | Formal planning or Ralph preparation | Useful `projects/<id>/work/` records | Create only the durable records the work needs: long-horizon direction, active work continuity, durable task tracking, checkpoint history, or compact/resume continuity. State that source remains untouched. |
| "start Ralph", "build task X", "execute the first queue item", or "implement according to the plan" | Ralph execution | Update `work/` records as useful; edit the lane's checkout (routine) | Confirm the selected wave, group review, explicit slice, or queued task; diff boundary; risk; verification; and writable access to the lane's checkout before editing. Execute the current boundary. |
| "finish", "commit", "open a PR", "push", "install", "run CI repair", or external/exceptional action | Finish or boundary ask | Routine actions when the workflow reaches them; `external` actions after the boundary ask or a standing grant; exceptional actions only after explicit one-off approval. A broad request is never a go-ahead | Summarize state, verification, and risk first. Route through `automation-policy` before any `external` or `exceptional` action. |

Ambiguous signals must not silently escalate durable writes. If the next step
would create hub work records, edit project source, or take an `external`
action and the user's intent is unclear, state the assumption and ask or
choose the less durable action.

## Project Records

`projects/registry.json` is the derived lookup from project id to repo path.
Read `projects/<id>/project.md` for the canonical binding, overview, and standing
policy notes; regenerate a drifted registry with `./bin/add-project --rebuild`.
`memory.md` holds durable facts and preferences. Optional `decisions.md` holds
project-significant rationale, superseded in place when decisions change.
Registration creates no `work/` records.

### Lanes

A lane owns independent current-work and resume context. A group bundles waves
under shared acceptance and an integrating review. Choose these separately:
concurrency alone does not require a group. Use these stable lane locators:

| Locator | Records relative to `projects/<id>/` | Use |
| --- | --- | --- |
| `flat` | `work/` | Default ordinary execution, with no folder creation ceremony. |
| `studio:<slug>` | `work/design/<slug>/` | Explicit Design Studio initiative; independent design continuity without implementation authority. |
| `group:<gid>` | `work/groups/<gid>/` | Related waves with shared acceptance; created at group Entry. |
| `lane:<slug>` | `work/lanes/<slug>/` | Independent execution that must coexist or resume separately, without imposing a group. |

Use lower-kebab slugs. Inspect existing records before creating a lane and reuse
the matching effort. Do not create a session registry, daemon, global queue, or
empty lanes for hypothetical work. Native short-lived task tracking remains
the default for steps inside a session.

Each lane uses the same optional `active-work.md`, `context-pack.md`,
`build-log.md`, and `task-queue.md` semantics below. Design lanes do not invent
Ralph waves or group gates. A studio's `design.md` remains the sole owner of
its integrated design, revision, and acceptance.

An explicit execution lane's `active-work.md` header binds `lane:`, `branch:`,
`checkout:`, `boundary:` (owned paths or areas), and `status:`. The flat lane
needs these bindings if it uses a nondefault checkout or concurrent work makes
ownership relevant. Studio continuity records `lane: studio:<slug>`, design
boundary, and status, without claiming a writable source checkout. Status may
be `active`, `paused`, `blocked`, or `closed`; it describes work, not native
process liveness. Closed lanes retain short pointers to their concluding ledger
entry and remain archived in place.

**Lane selection.** Select the lane before planning, execution, design resume,
or compact handoff. An explicit locator or clearly named existing studio/
effort wins; retain a session's already selected lane when intent still matches.
A legacy bare gid that uniquely names a group remains valid. A token ambiguous
between kinds requires clarification. With no selection, exactly one matching
open boundary selects itself; multiple matching boundaries require a choice;
no matching execution boundary defaults to flat. Filter by phase: a studio is
not an execution candidate, and an active execution group does not prevent a
clearly requested studio from resuming. Creating or selecting a lane does not
authorize another phase or a second writer in an occupied lane.

**One checkout per writer.** At most one active coordinating lane or worker
writes a checkout. Inspect open execution bindings and `git worktree list`
before claiming `repo_path` or another checkout. An absent ownership record does
not prove there is no native writer; inspect actual activity before introducing
concurrent source writers, and publish a lightweight flat binding for existing
flat execution first. The flat lane may use `repo_path` by default only when no
other writer owns it. Give concurrent execution its own git worktree outside the
hub, normally a sibling path under
`<repo-basename>-worktrees/`. Record its actual branch and checkout and obtain
native writable access before editing. Never switch or merge inside another
lane's checkout. If no suitable checkout is available, sequence the work or
resolve ownership with the user; an existing folder is not a grant of access.
Read-only design and review may inspect a shared checkout, but recheck git state
when concurrent edits could invalidate the evidence. Preserve user-owned changes.

### Light Boundary And Groups

The default unit is one ungrouped wave. Its **light boundary** costs one
`build-log.md` acceptance entry; `active-work.md` only when continuity is useful;
no roadmap or queue by default; and `context-pack.md` only when something must
resume. Finished work with no open state creates no packet; an existing packet
becomes `idle` (or a closed pointer for an explicitly named completed lane).
When flat work is fully complete, release an existing `active-work.md` ownership
binding by setting `status: closed` and replacing completed detail with a pointer
to its acceptance ledger entry. Do not create active work solely to close a fix
that never needed it. An idle packet alone does not release an ownership binding;
paused or blocked work retains its binding until completed or safely reassigned.
A small wave inside a large project stays light. A named lane adds the ownership
binding it needs, not an implementation group.

Use groups through explicit Structural Planning when multiple waves must land
before the acceptance target is met or cross-wave interaction needs a dedicated
integrating review. Detail the current wave; sketch later waves only as far as
the current code and evidence support. Group lifecycle is defined below.

### Work Artifact Reference

All records below stay under the registered project's hub records. Create each
only for a concrete continuity, quality, or autonomy need.

| Artifact | Single purpose and owner |
| --- | --- |
| Lane `active-work.md` | Current design boundary or execution wave detail, acceptance criteria, owned scope, risks, verification, and lane bindings. Group detail and reliable later-wave sketches when relevant. |
| Lane `context-pack.md` | The only self-contained resume packet, holding the non-derivable fields defined under Compaction. |
| Lane `build-log.md` | Concise checkpoint history: outcome, final contracts, per-wave acceptance commit, verification/review verdicts, risks, and next step. Never a raw transcript or per-commit changelog. |
| Lane `task-queue.md` | Optional durable pending work when native task tracking cannot preserve what must survive. Completed items roll off at closeout. |
| Project `work/build-log.md` | Flat-lane ledger and seam between independent lanes: significant planning, lane/group closeout, transitions and milestones. Summarize and link local ledgers. |
| Project `work/roadmap.md` | Long-horizon direction, group/milestone order and acceptance, durable deferred scope and revisit triggers. |
| `work/design/<topic>.md` | Lightweight topical note, supported without a studio and preserved if later promoted. |
| Studio `design.md` | Integrated design, explicitly adopted detail scope, integer revision, fixed contracts, freedoms, and explicit revision-specific acceptance. |
| Design/studio READMEs | Navigation and relationship pointers; never current-state ledgers. |
| `decisions.md` | Substantial project-level decision rationale, superseded in place. |
| `memory.md` | Durable facts, preferences and stable conventions. |
| `project.md` | Repo binding, overview, and user-stated standing policy notes. Never per-action approvals or commit history. |
| Live project git | Current branch/HEAD/status, raw diffs and commit list in the relevant checkout. |

### Artifact Recording Economy

Sinks such as build logs accumulate concise meaningful history. Windows such as
active work, queues, and context packs hold current state; condense completed
work into the ledger and leave a pointer. Topical design and rationale are
superseded in place. Never prune durable history to make a window smaller.

Derive mechanical history from git. Record a per-wave acceptance commit once in
the lane's ledger, not in every packet or roadmap. Exact source revisions used
as design evidence or an integration operation's tested base have a different
purpose: record them with that evidence or operation, and never treat them as
current HEAD. Other records reference the fact's owner instead of copying it.

Design evidence retains consequential observations and dated reassessments in
its existing artifact, with links from decisions and meaningful checkpoints.
Preserve what was known when a choice was made and what later changed its
applicability. An artifact edit date is not an observation or revalidation date.
Design Studio's artifact-contracts reference owns the detailed evidence and
adoption rules; no extra artifact types or tracking registry are required.

### Related Work And Changed Assumptions

Record relationships only when they affect a real decision or work boundary.
The owning design or active-work record links the other canonical artifact,
its material revision (and accepted revision when relied on for implementation),
the assumed contract, and why the relationship matters. Ordinary independent
fixes need no dependency table. Supporting notes and worker reports do not
silently become accepted design.

At start/resume, wave formalization, a shared-contract change, and integration,
read relevant links and nearby open lane boundaries. Look for semantic as well
as path overlap: disjoint files may rely on incompatible meanings. Missing
relationship records do not prove independence. For design synthesis, inspect
both designs, separate accepted decisions from provisional ideas, expose
conflicts, and integrate the agreed shared behavior into one authoritative
artifact with references from its consumers. Preserve useful original material.

A finding that undermines an assumption is a proposal, not an accepted change.
Record its evidence, affected work, impact (`unaffected`, `needs-revalidation`,
or `blocked`), and a resolution owner in the originating design or active-work
record. One coordinating session assembles the recommendation; with delegated
workers it is the parent. Independent sessions reconcile through the records
and native messages when available. Do not edit another lane's current-work
files on its behalf. Each owner reconciles its own boundary against the shared
resolution. Paused sessions discover material changes on resume.

Continue unaffected work. Suspend work that relies on an unresolved or stale
contract. Changes inside accepted implementation freedoms can be resolved in
execution planning; changes to product intent, a fixed contract, or a core
premise return upstream for user alignment and, for a studio, explicit revision
acceptance. Reverify the accepted revision against source before dependent
execution resumes. Keep the finding and resolution linked in the checkpoint
ledger; do not make every speculative observation a project-wide blocker.

### Shared Record Publication

The shared hub checkout needs protection from lost updates even when source
worktrees are isolated. Publish shared project records and lane ownership bindings cooperatively through
`./bin/piper-record`; read the current content and digest before preparing a
replacement outside the hub records. Ordinary edits to an exclusively owned
lane-local record may use normal file tools. Guard shared indexes, decisions,
roadmaps and cross-lane ledgers whenever other sessions may contribute; do not
assume a stale copy is safe just because a session was paused:

```sh
./bin/piper-record --project projects/<id> read work/roadmap.md
./bin/piper-record --project projects/<id> replace work/roadmap.md --expected <sha256-or-missing> --content-file <proposal-file>
./bin/piper-record --project projects/<id> commit --paths work/roadmap.md work/build-log.md --message "Record accepted boundary"
```

Paths after the command are relative to the registered project-record directory.
Use the digest returned by `read`, or `missing` for create-if-absent. A stale
replacement (exit 3) means another writer published first: reread, reconcile both
contributions, and retry with the new digest. Never force a stale overwrite or
silently drop the other contribution. Under the same lock, execution
`active-work.md` claims are checked across flat, group, and named lanes; a
duplicate canonical checkout claim is rejected (exit 2). Studio records do not
claim source checkouts and are excluded. Reconcile actual ownership before
retrying an occupied claim; do not close another lane to bypass the guard.
The helper validates destinations, serializes cooperating operations, and
replaces individual files atomically; direct editors can bypass this cooperation,
so do not describe it as a sandbox or universal lock.
`piper-integrate` takes the repository integration lock then this same record
lock through final validation and publication, preventing cooperating ownership
writes from claiming the target during that operation. Never acquire those locks
in reverse order or treat a persistent lock file as proof of a live process.

Each file is atomic; a multi-file checkpoint is not a transaction. If interrupted,
resume must reconcile the ledger, windows, and roadmap before declaring the
boundary accepted. Use the path-only commit command when a checkpoint warrants
an artifact commit; inspect and report its exact scope, preserving unrelated
staged and unstaged changes. Never use `git add -A`, `commit -a`, or an ordinary
unscoped commit in the shared hub. A commit attention result (exit 4) requires
inspecting actual HEAD, committed scope, index, and working tree before retrying:
Git hooks or post-publication inspection can fail after a commit has landed.
Reconcile that result rather than blindly committing twice. On Git lock
contention retry; never delete `index.lock`. Registration remains owned by
`add-project`; do not use record
publication to create registrations or mutate managed hub surfaces.

`read` and `replace` handle Markdown records. Scoped `commit` also accepts
non-executable design assets under `work/design/`: images, PDFs, diagram text,
and data specifications in its supported formats (see `commit --help`). Include
adopted assets alongside the overview at acceptance; publication does not grant
source-copying, prototype execution, or cross-lane edit authority.

### Artifact Persistence

Artifact updates are routine when the selected phase authorizes them. Commit
useful completed or paused continuity at a meaningful checkpoint unless the
user requested uncommitted records; no separate per-edit or per-checkpoint ask
is needed. Report hub changes and commit state separately from source changes.
This rule does not turn registration or an orientation request into a checkpoint.

**Boundary triggers.** Checkpoint at wave acceptance; group review/closeout or
milestone; formal planning completion; material active-work change; blocker;
pause, compact preparation, context low, project switch or handoff; finish; or
an explicit save/commit request. During execution append the lane ledger at
these boundaries. Rewrite `context-pack.md` only at resume triggers: material
active-work change, pause, compact preparation, context low, project switch,
handoff, blocker, or finish/closeout with remaining state to resume. Update a
queue only when one exists and pending work changed.

**Checkpoint invariant.** Windows and ledger agree; a fresh session can resume
from hub records and live source alone. In execution, current wave and packet
agree when both exist, the checkout uses its recorded branch, and live HEAD is
the acceptance commit at an accepted boundary or its descendant during ongoing
work. Explain rebases, integration, dirty files, and any deviation rather than
silently trusting a stale record. In design, the packet points to the current
design boundary and preserves open questions without inventing a source wave.
Every roadmap acceptance has a corresponding closeout entry and vice versa.
Related-contract revisions and unresolved impacts are reconciled. Disclose hub
artifact changes separately and state their actual commit status.

Satisfy the invariant with the least useful state: a completed ordinary fix
needs only its acceptance entry and live git; a group needs its integrating
review and closeout; a paused studio needs its design and resume anchors.

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
  waves on the lane's branch, and use implementation review gates at meaningful
  boundaries.
- Review Mode: first check whether the work matches the request or active work,
  then check code quality; group reviews inspect the integrated cross-wave
  diff.
- Finish Mode: report verification, residual risk and actual commit/integration
  state; take only actions reached and authorized by the workflow.

Scope tiers are advisory sizing, not artifact rules; artifact creation is
driven by durable need, and scope only informs how strongly persistence is
surfaced:

- `S0`: direct small task; stay in chat unless the user asks to record
  something or a durable project fact, standing policy note, checkpoint, or
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
  `exceptional` action that needs a fresh instruction.

Risk tiers are implementation caution, not action classes. Action classes decide
whether an action needs an ask (`automation-policy.md`); risk tiers decide
whether Ralph confirms before editing. A prior explicit instruction or scoped
waiver already covering that boundary satisfies L2; do not ask again. `exceptional` actions can never be pre-approved
and require explicit one-off approval each time.

## Ralph Review Gate

Before Ralph edits project source, verify the lane's checkout (`repo_path` or
its recorded worktree) is writable in the active session. If the checkout is
outside the current workspace or sandbox, state that writable access is
required before execution instead of declaring the task Ralph-ready. Source
edits there are routine (`automation-policy.md`).

During Ralph Mode, run a read-only implementation review after substantial
waves, queued work, or high-impact slices are implemented and initially
verified, before marking the boundary complete in active work records. The
reviewer inspects the actual code or diff with the active work record, build
log, optional task queue, and compact packet when relevant as context.

Review gate selection is based on scope and change impact. Risk tier controls
Ralph execution confirmation before editing, not review selection or action
class. Review gates are required for `S2/S3` wave or group boundaries and
queued tasks that touch foundational behavior such as bootstrap, install,
update, registration, generated commands, hooks, settings, config, test
harnesses, project or hub ownership, security policy, or automation policy.
After the final wave in a group lands, run a group-level review gate over the
integrated cross-wave diff before the slice, group, or acceptance task is
marked complete, even if every per-wave gate already passed.

Use the actual native tool surface for delegation. Installed role configs can
narrow permissions only when the client applies them. If native role selection
is absent, pass the relevant installed brief explicitly; never invent a role
selector or claim a sandbox restriction solely from a prompt. Verify observed
worker permissions or state them as unverified. Review behavior remains read-only
with the bounded check-output rules in the coordinated-work procedure;
broader inherited capabilities do not widen its assignment.

The main session must validate reviewer findings before acting: give each
finding an explicit verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or
`false-positive` — before editing any code, then apply only `confirmed-in-scope`
fixes, turn `confirmed-out-of-scope` findings into follow-up notes or tasks, and
reverify review-driven fixes with the narrowest meaningful command for the fixed
behavior. If a required or expected gate is skipped, record review debt
and do not continue to dependent tasks until the debt is resolved or explicitly
accepted by the user.

## Group Lifecycle

`piper-workflow` operates groups through four stages. Lane selection and
ownership are defined under Project Records and apply before every stage.

1. **Entry.** Reverify the group's structural sketch against current code:
   boundary, acceptance target, premises, and revisit triggers. Create or reuse
   `work/groups/<gid>/`, record its execution bindings, inspect other open
   boundaries and related contracts, and obtain an exclusive writable checkout.
   Path overlap calls for explicit edit ownership or sequencing; semantic
   overlap calls for a compatible shared contract. Never assume overlap itself
   is permission to edit another effort. Repair the structural sketch if needed,
   then formalize the first wave.
2. **Execution.** Implement waves through Ralph, with verification, drift checks,
   and per-wave review gates. Commit accepted waves on the assigned branch and
   record source acceptance once in the group ledger. Authorized workers follow
   the delegated-work procedure; the parent retains acceptance responsibility.
3. **Closeout.** Follow `piper-workflow/references/integration.md`: prepare the
   combined result against an exact base, verify it and run the group review
   over the integrated cross-wave diff. Resolve findings and commit remaining
   source. Integration requires a clean, exclusively assigned target checkout
   and a final check that the tested base and candidate have not changed. Never
   merge into another lane's checkout. If base moves, resynchronize and repeat
   affected checks before publication. Where user policy requires a PR, record
   `integrated: pending-pr`; do not claim local integration happened.
   After integration (or the explicit pending-PR policy path), publish a project
   build-log closeout entry condensing and linking the group ledger: acceptance
   target and verdict; waves; review and accepted debt; resulting contracts;
   acceptance source commit; tested base and integration result or pending-PR
   state; deferred scope; and retained worktree locator. Reconcile the roadmap
   acceptance, then rewrite lane windows to a short `closed` pointer. If source
   integration succeeded but record publication did not, closeout remains
   incomplete until records are reconciled; inspect git before retrying.
4. **Transition.** Check whether actual results change later groups' premises,
   order, or scope; update the roadmap when needed. Other active execution lanes
   reconcile related contracts and synchronize with base before their next wave.
   Handle mechanical conflicts within scope and reverify combined behavior;
   reopen upstream design when fixed contracts or intent change. Proceed to the
   next Entry when clear and already authorized; broad goals retain these gates
   at each group boundary.

Groups are accepted only after their acceptance criteria and integrating review
hold. Integration state is separately explicit, including `pending-pr`.
Milestones are roadmap markers, not another lifecycle. A small named execution
lane follows the same integration safety procedure if it needs to publish into
base, with review proportional to its boundary rather than a manufactured group.

When planning starts from Design Studio, Superpowers verifies the exact
`design_artifact` and integer `accepted_revision` against the current metadata
and live source, including explicitly adopted details and subsequent relevant
evidence. Ordinary hub acceptance checkpoints preserve the reviewed files and
ledger entry together; there is no separate snapshot receipt. Compare adopted
content with that checkpoint when checking later edits, even if the overview's
revision was not bumped. A stale revision or invalidated fixed contract returns upstream;
recorded implementation freedoms remain downstream.

Source commits at accepted waves and closeout are routine and separate from hub
artifact commits. Pushes and PRs remain external; deleting retained worktrees
remains exceptional. Finish reports existing commit and integration state and
performs only the actions reached and authorized by the workflow.

**Legacy continuity.** Move an identified legacy group's flat windows to its
existing group location only at a wave or pause boundary; reconcile rather than
overwrite a destination. Keep the historical project ledger and open the local
ledger with a pointer. Move only that group's pending queue items. For a legacy
studio, migrate only flat windows clearly belonging to that studio into its
studio folder, leave a flat pointer, and preserve unrelated execution state.
A legacy group already at closeout may close in place. No bulk destructive
migration is required.

## Compaction

At resume triggers, rewrite the selected lane's `context-pack.md` in full.
Use the lane location table under Project Records; a studio's packet stays in
its studio, a named execution lane's in `work/lanes/<slug>/`. The packet holds
only non-derivable state:

1. **Goal** of this boundary, one line.
2. **Boundary**: canonical lane locator, design discussion or execution wave,
   and status. Execution statuses include `idle`, `mid-wave`, `accepted`,
   `group-review`, `closeout`, `between-groups`, `blocked`, or `closed`.
   Design statuses include `exploring`, `paused`, `blocked`, or `concluded`;
   these do not substitute for canonical design maturity. Include scope when
   no active-work record carries it and a nondefault branch binding when needed.
3. **Next exact action**, including the first file to inspect.
4. **Verification and review state not yet in the ledger**, unresolved findings,
   drift, and any incomplete integration/publication. Reference recorded
   results instead of copying them.
5. **Blockers, risks, and open questions**, including links to changed related
   assumptions and their resolution owners. Preserve both unaffected work and
   work awaiting revalidation.
6. **Stop reason**.
7. Optional **broad-search triggers**, resume note, transient references, and
   unresolved delegated-work locators needed for recovery.

Derive repo binding, live branch/HEAD/status, changed files and commits since
acceptance, hub commit status, and roadmap acceptance from their owners at
resume. A stored session/worker handle is only a locator; it is not proof of a
running process or completed result. Verify native task status when available,
inspect actual checkout/diff/result state, and never duplicate work solely
because a wait timed out. If status cannot be observed, report it as unknown
and preserve ownership before starting another writer.

Read the old packet before rewriting, preserve every still-relevant
non-derivable field, and reconcile with source and canonical design records.
Never regenerate solely from lossy compacted memory. For shared publication use
`piper-record`; a stale digest requires rereading and reconciliation. No packet
is required for a completed light boundary with nothing to resume.

On cold resume, read project binding, memory and relevant decisions, then the
selected lane's packet, active work, ledger, optional queue, and canonical design
when present, including adopted details and later relevant evidence assessments.
Inspect live source at the assigned checkout, relevant related-work
revisions and resolutions, and any worker state before editing. A studio resumes
its design phase without source edits; an execution lane first revalidates stale
assumptions. If closeout publication was interrupted, use actual git evidence to
finish records rather than repeating integration. Read roadmap when long-horizon
direction matters; expand the source neighborhood for concrete triggers such as
missing acceptance, stale packets, failing checks, shared contracts, security,
generated parity, or integrated review.

`/compact` is run by the user or native runtime. Piper prepares compact-safe
state and may say it is compact-ready; do not claim compaction happened unless
observed. Hooks are reminders, not a mutating snapshot or ownership enforcement
layer, and a missing hook never excuses skipping explicit checkpoint work.

## Project Repos

Project repos keep source code. Registration may add `.piper/project.json` and
`PIPER.md`, but those markers do not make the repo a Piper runtime.
