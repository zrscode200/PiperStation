---
name: piper-workflow
description: "Use when executing rather than exploring on a registered Piper Station project: verify an ordinary brainstorm direction or an explicitly accepted Design Studio revision, formalize active work, prepare Ralph execution, operate waves and group lifecycle gates, prepare compact-safe handoff, or route a permission-gated finish action. Entered from brainstorm, an accepted design-studio handoff, or /superpowers, /ralph, /compact-handoff."
---

# Piper Workflow

Piper Workflow owns convergent execution for Piper Station project work —
within-group and across the group lifecycle: formal planning, Ralph preparation,
Ralph execution, group entry, closeout, and transition, compaction handoff, and
finish routing. It operates not only inside a single wave or group but across the
full sequence of groups toward a milestone. It is entered from the `brainstorm`
front door once a request has
converged on a direction, from `design-studio` with an explicitly accepted
revision, or directly through `/superpowers`, `/ralph`, and `/compact-handoff`.

`brainstorm` owns the divergent phase — orientation, framing, exploration,
conversational planning, registration, and routing. `design-studio` owns the
optional deeper divergent path and its canonical design revisions. This skill
assumes a registered project and a direction that has converged toward durable
work. If a request is actually still divergent, hand it back to `brainstorm` or
to Design Studio when an existing design premise must be reconsidered. Use the
narrow skills when their consequence applies: `review` for explicit review or
review gates, and `automation-policy` before crossing the active permission
profile boundary.

Read `{{INSTRUCTION_DOC}}` and `STATION.md` first. Resolve the project in
`projects/registry.json` to its `repo_path` and read
`projects/<project-id>/project.md`, `memory.md`, and optional `decisions.md`
when it exists before executing.

## Modes

Choose the smallest convergent path that fits:

| User intent | Mode | Supporting behavior |
| --- | --- | --- |
| Verify the direction and define group or milestone structure | Superpowers — Structural Planning | this skill and `/superpowers` |
| Formalize the current wave into Ralph-ready detail | Superpowers — Wave Formalization | `/superpowers`; Ralph runs this pass at a wave boundary when the selected wave is still a sketch |
| Execute one clear active-work wave, explicit slice, or optional queued task | Ralph | `/ralph` and Ralph sections in `STATION.md`; project source edits require `local` profile coverage |
| Review an implemented wave, group, or slice | Review | `review` |
| Local git, worktree, PR, dependency, network, CI, exceptional, or external action | Finish or permission flow | `automation-policy` |
| Pause or compact active work | compact handoff | `/compact-handoff` and compact sections in `STATION.md` |

When routing into Superpowers, Ralph, or compact handoff, read and follow the
matching command file before acting; those commands hold the detailed operating
procedure. Prefer consequence language such as "I will create Ralph-ready work
records" over ceremonial mode announcements. Proceed when the path is clear and
safe; wait for go-ahead when confirmation is required, risk is `L2`, or the
request is ambiguous.

## Superpowers Entry

Superpowers begins where upstream divergence ended: either an ordinary
brainstorm hand-off brief or an explicitly accepted Design Studio revision. Its
lead step is verification, not open exploration: confirm the upstream direction
against real code, validate flagged assumptions, check the files and call sites
the work will touch, and confirm the acceptance criteria are testable before
locking durable active work. Open exploration belongs upstream.

Superpowers runs as two named passes. Structural Planning verifies the
direction and defines the group or milestone structure: every in-scope group
gets a boundary, an acceptance target, and revisit triggers, while later waves
and groups may stay sketches. Wave Formalization details the current wave into
Ralph-ready form; it also stands alone, run by Ralph at a wave boundary when
the selected wave is still a sketch.

## Design Studio Handoff

An ordinary brainstorm hand-off brief remains valid input, and the absence of a
studio is never a blocker. Lightweight `work/design/<topic>.md` notes also
remain supported. Apply this additional contract only when the upstream handoff
declares:

```text
design_artifact: projects/<project-id>/work/design/<studio-slug>/design.md
accepted_revision: N
```

Before Structural Planning relies on that design:

1. Resolve the artifact inside the registered project's hub records and read
   its current metadata. The handed-off revision must be an integer.
2. Require `status: accepted-for-planning`, integer `revision`, and integer
   `accepted_revision`; both metadata revisions must equal the handed-off
   `accepted_revision: N`. A missing, provisional, superseded, or mismatched
   design is stale and returns to Design Studio.
3. Read the canonical design and the significant supporting artifacts it links.
   Follow evidence and rationale links; do not treat supporting material as a
   replacement authority for `design.md`.
4. Verify its goals, assumptions, fixed contracts, and core premises against
   the live registered source before formal planning. Record the artifact path
   and exact accepted revision in execution work records, but reference rather
   than copy the design.
5. Make implementation choices only inside the recorded implementation
   freedoms. If live source invalidates a fixed contract or core premise,
   return upstream to Design Studio instead of silently redesigning it here.

A material design edit after handoff increments the current revision and makes
the prior pair stale. Do not proceed on the new revision until the user
explicitly accepts it and Superpowers reverifies it against live source.

## Group Lifecycle

Piper Workflow operates across groups, not only within one. The group lifecycle —
defined in `STATION.md` — has four stages, each run through this skill's modes:

- **Entry**: re-verify the next group's structural sketch against current code;
  create the group's lane folder `work/groups/<gid>/` and bind it (`branch:`,
  `checkout:` — a worktree when another lane holds `repo_path` — `boundary:`,
  `status: active`), surfacing any boundary overlap with other active lanes;
  run Superpowers Structural Planning scoped to that group if it needs repair,
  then Wave Formalization for its first wave.
- **Execution**: run the group's waves through Ralph Mode in the lane's
  checkout with per-wave gates; wave entries go to the group ledger. Commit the
  project source per completed wave on the lane's branch when the active
  profile covers `local` — commit and report, no per-wave ask — separate from
  artifact commits.
- **Closeout**: sync with base, verify, run the group review gate over
  `base..group`, commit any remaining group source, integrate into base (or
  record `integrated: pending-pr`), write the closeout entry in the project
  `build-log.md`, tick the group's acceptance in `roadmap.md`, record contracts
  later groups depend on, and roll the group off the windows — condense the
  group ledger into that closeout entry and rewrite the lane's windows to a
  short `closed` pointer.
- **Transition**: check whether the outcome reshapes later groups; carry
  learnings forward; lanes still active sync with base before their next wave;
  continue to the next group's Entry, or surface for re-planning when the
  roadmap materially changes. Keep re-planning here in Superpowers; hand back
  to `brainstorm` only for a genuinely divergent question.

See `STATION.md` → Group Lifecycle for the canonical stage policy, gates, and
artifact obligations.

## Artifact Signal Policy

This skill handles the convergent signals. Brainstorm owns the front-door band:
read-only orientation and planning, plus explicit deterministic registration;
Design Studio owns optional deeper design and its hub artifacts. When intent
reaches Piper Workflow, durable execution records are expected. The full
intent-to-writes map lives in `STATION.md`.

Every convergent entry selects a lane first (`STATION.md` → Group Lifecycle →
Lane selection): the flat lane under `projects/<id>/work/` or a group lane
under `projects/<id>/work/groups/<gid>/`; with more than one candidate, ask,
never guess. Formal planning or Ralph preparation may create useful records in
that lane when they do a clear job: preserve long-horizon direction in
`roadmap.md`, stabilize the current group and wave in `active-work.md`, create
durable queued execution in optional `task-queue.md`, record checkpoint
history in `build-log.md`, or prepare compact/resume continuity in
`context-pack.md`. Ralph execution may update those records and
edit only the lane's checkout when `local` profile coverage exists. Finish,
local git, worktree, PR, dependency, network, CI, external, or exceptional
actions route through `automation-policy` when they cross the active permission
profile boundary.

When work starts from Design Studio, `active-work.md` records only the
`design_artifact` and exact `accepted_revision` plus downstream execution state;
it does not duplicate the canonical design.

If a request is actually still divergent, hand it back to `brainstorm` rather
than escalating durable writes.

## Artifact Persistence Checkpoints

Piper artifacts stay in `projects/<project-id>/work/` by default. Updating
them during active work is allowed local assistance; committing those updates
is a `local` permission action and must go through `automation-policy` when
the active permission profile does not cover local git.
Record artifacts economically: `context-pack.md` is the only fully
self-contained resume packet, rewritten in full when updated and holding only
the non-derivable fields defined once in `STATION.md` → Compaction; roadmap,
active-work, queue, and build-log records stay purpose-specific. Git is the
source of truth for branch/HEAD/commit/diff history — derive it live and let the
owning artifact record what it needs (build-log's acceptance commit) rather
than repeating it elsewhere. See `STATION.md` for the temporal roles
(accumulative sinks vs current windows vs topical references), fact ownership,
and the group-closeout roll-off that keeps windows from becoming sinks.

Plan in slices, execute in waves, and checkpoint at boundaries. Detail the
current wave enough to execute safely. Sketch later waves only when the current
code, context, and prior results make them reliable. The default unit is one
ungrouped wave with a light boundary (`STATION.md` → Project Records).

Groups bundle related waves under a shared acceptance target and one
integrating review gate. Entering a group is an explicit planning decision: use
one when multiple waves must land before the larger boundary is accepted, when
cross-wave interaction risk matters, or when the work will run alongside other
work on the project. Make the group boundary, wave list, required gates, group
review state, and acceptance target visible in `active-work.md`; for durable
queues, list the group review gate before the acceptance task.

Do not ask to commit after every artifact edit. At each boundary trigger,
satisfy the checkpoint invariant defined once in `STATION.md` → Artifact
Persistence — windows and ledger agree, a fresh session can resume from hub
records plus live git, and changed Piper artifacts are reported separately from
registered project source changes with their hub commit state — and nothing
more. Ask once about committing Piper artifacts only when the stopping point or
future continuity warrants it. Scope tiers (`STATION.md` → Mode Routing) inform
how strongly persistence is surfaced; they do not create artifacts.

During Ralph execution, append `build-log.md` at wave, group, review/fix,
blocker, milestone, finish, or other meaningful boundaries — the boundary
triggers defined once in `STATION.md` → Artifact Persistence. Update
`task-queue.md` only when a durable queue is in use. Rewrite `context-pack.md`
and consider an artifact commit only at the resume triggers in that same list.

## Scope And Risk

Use the scope and risk tiers defined in `STATION.md`. Scope is advisory sizing:
it guides planning depth, review expectations, and continuity pressure, but it
does not mechanically create artifacts. Risk controls Ralph implementation
caution. Permission profiles control action boundaries separately.

## Durable Context

Update hub records only when useful:

- `memory.md`: durable facts, user preferences, stable repo conventions, and
  reusable context — not a per-wave changelog.
- `project.md`: project policy preferences, one-off approvals, accepted risks,
  and project-level automation notes — not a commit ledger; commit history lives
  in `build-log.md`, anchored to git.
- optional `decisions.md`: substantial decision logs future work should not
  silently reopen; supersede a reversed decision in place rather than deleting it.

Routine progress, command output, and transient notes should stay in the
conversation unless substantial active work needs continuity under
`projects/<project-id>/work/`.

Before Ralph execution, verify the lane's checkout (`repo_path` or its recorded
worktree) is writable in the active session. {{WORKSPACE_ACCESS}}

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Do not add sessions, checkpoints, dashboards, queue managers, or lifecycle
  shell workflows.
- Keep planning, Ralph, review, and compaction as prompt, command, and narrow
  consequence-specific behavior. The deterministic shell helper is for project
  registration.
- Orientation and registration belong to `brainstorm`; this skill assumes a
  registered, converged target.
- Do not make Design Studio mandatory. Preserve direct brainstorm-to-Piper
  planning, and do not silently reinterpret a stale or contradicted accepted
  design during Superpowers.
- Do not commit, push, merge, create or switch worktrees, install dependencies,
  or run external automation unless the selected workflow has reached that
  action and the active permission profile allows it; see
  `automation-policy.md`. Delete, force-push, rewrite history, deploy to
  production, or take other exceptional actions only after explicit one-off
  approval through `automation-policy`.
