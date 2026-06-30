---
name: piper-workflow
description: "Use when executing rather than exploring on a registered Piper Station project: formalize active work, update roadmap or build-log checkpoints, prepare an optional durable Ralph queue, execute the current Ralph wave, explicit slice, or queued task with verification and review gates, operate the group lifecycle across entry, execution, closeout, and transition between groups, prepare compact-safe handoff, or route a permission-gated finish action. Entered from brainstorm once direction is set, or via /superpowers, /ralph, /compact-handoff."
---

# Piper Workflow

Piper Workflow owns convergent execution for Piper Station project work —
within-group and across the group lifecycle: formal planning, Ralph preparation,
Ralph execution, group entry, closeout, and transition, compaction handoff, and
finish routing. It operates not only inside a single wave or group but across the
full sequence of groups toward a milestone. It is entered from the `brainstorm`
front door once a request has
converged on a direction, or directly through `/superpowers`, `/ralph`, and
`/compact-handoff`.

`brainstorm` owns the divergent phase — orientation, framing, exploration,
conversational planning, registration, and routing. This skill assumes a
registered project and a direction that has converged toward durable work. If a
request is actually still divergent (orienting, exploring, or deciding what to
do), hand it back to `brainstorm`. Use the narrow skills when their consequence
applies: `review` for explicit review or review gates, and `automation-policy`
before crossing the active permission profile boundary.

Read `CLAUDE.md` and `STATION.md` first. Resolve the project in
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

Superpowers begins where `brainstorm` ended. Its lead step is verification, not
open exploration: take the direction from brainstorm's hand-off brief and
confirm it against the real code — validate the brief's flagged assumptions,
check the specific files and call sites the work will touch, and confirm the
acceptance criteria are testable — before locking durable active work. Open
exploration belongs to `brainstorm`.

Superpowers runs as two named passes. Structural Planning verifies the
direction and defines the group or milestone structure: every in-scope group
gets a boundary, an acceptance target, and revisit triggers, while later waves
and groups may stay sketches. Wave Formalization details the current wave into
Ralph-ready form; it also stands alone, run by Ralph at a wave boundary when
the selected wave is still a sketch.

## Group Lifecycle

Piper Workflow operates across groups, not only within one. The group lifecycle —
defined in `STATION.md` — has four stages, each run through this skill's modes:

- **Entry**: re-verify the next group's structural sketch against current code;
  run Superpowers Structural Planning scoped to that group if it needs repair,
  then Wave Formalization for its first wave.
- **Execution**: run the group's waves through Ralph Mode with per-wave gates.
  Commit the project source per completed wave when the active profile covers
  `local` — commit and report, no per-wave ask — separate from artifact commits.
- **Closeout**: run the group review gate over the integrated diff, commit any
  remaining group source, write the build-log closeout entry, tick the group's
  acceptance in `roadmap.md`, record contracts later groups depend on, and roll
  the group off the windows — condense its completed-wave detail into that
  build-log entry and drop it from `active-work.md` and `task-queue.md`.
- **Transition**: check whether the outcome reshapes later groups; carry
  learnings forward; continue to the next group's Entry, or surface for
  re-planning when the roadmap materially changes. Keep re-planning here in
  Superpowers; hand back to `brainstorm` only for a genuinely divergent question.

See `STATION.md` → Group Lifecycle for the canonical stage policy, gates, and
artifact obligations.

## Artifact Signal Policy

This skill handles the convergent signals. Brainstorm owns the front-door band:
read-only orientation and planning, plus explicit deterministic registration.
When intent reaches these rows, durable writes are expected. The full
intent-to-writes map lives in `STATION.md`.

Formal planning or Ralph preparation may create useful
`projects/<id>/work/` records when they do a clear job: preserve long-horizon
direction in `roadmap.md`, stabilize the current group and wave in
`active-work.md`, create durable queued execution in optional `task-queue.md`,
record checkpoint history in `build-log.md`, or prepare compact/resume
continuity in `context-pack.md`. Ralph execution may update those records and
edit only the real project repo when `local` profile coverage exists. Finish,
local git, worktree, PR, dependency, network, CI, external, or exceptional
actions route through `automation-policy` when they cross the active permission
profile boundary.

If a request is actually still divergent, hand it back to `brainstorm` rather
than escalating durable writes.

## Artifact Persistence Checkpoints

Piper artifacts stay in `projects/<project-id>/work/` by default. Updating
them during active work is allowed local assistance; committing those updates
is a `local` permission action and must go through `automation-policy` when
the active permission profile does not cover local git.
Record artifacts economically: `context-pack.md` is the only fully
self-contained resume packet, rewritten in full when updated; roadmap,
active-work, queue, and build-log records stay purpose-specific. Git is the
source of truth for branch/HEAD/commit/diff history — derive it live and let the
owning artifact record what it needs (context-pack's resume snapshot, build-log's
acceptance commit) rather than repeating it elsewhere. See `STATION.md` for the
temporal roles (accumulative sinks vs
current windows vs topical references), fact ownership, and the group-closeout
roll-off that keeps windows from becoming sinks.

Plan in slices, execute in waves, and checkpoint at boundaries. Detail the
current wave enough to execute safely. Sketch later waves only when the current
code, context, and prior results make them reliable.

Groups bundle related waves under a shared acceptance target and one
integrating review gate. Use a group when multiple waves land before the larger
boundary is accepted, or when cross-wave interaction risk matters. Make the
group boundary, wave list, required gates, group review state, and acceptance
target visible in `active-work.md`; for durable queues, list the group review
gate before the acceptance task.

Do not ask to commit after every artifact edit. At natural checkpoints, report
changed artifacts separately from registered project source changes, inspect
git state for both the real project repo and the Piper Station hub, and say
whether Piper artifact changes are uncommitted. Ask once about committing
Piper artifacts only when the stopping point or future continuity warrants it:

- `S0`: stay in chat unless a durable need appears.
- `S1`: use `active-work.md` only when continuity matters.
- `S2`: create only the records needed for current-wave active work,
  checkpoint history, compact/resume, or durable queued execution.
- `S3`: use `roadmap.md` when groups, milestones, deferred work, or revisit
  triggers need durable direction.

During Ralph execution, append `build-log.md` at wave, group, review/fix,
blocker, milestone, finish, or other meaningful boundaries. Update
`task-queue.md` only when a durable queue is in use. Avoid `context-pack.md`
updates and commit prompts unless the boundary is also a group closeout,
milestone, active-work change, pause, compact, project switch, blocker, or
finish.

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

Before Ralph execution, verify the real project repo is writable in the active
session. If the repo is outside the hub, ensure Claude Code has workspace access through `/add-dir <repo-path>` or `claude --add-dir <repo-path>` before editing.

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
- Do not commit, push, merge, create or switch worktrees, install dependencies,
  or run external automation unless the selected workflow has reached that
  action and the active permission profile allows it; see
  `automation-policy.md`. Delete, force-push, rewrite history, deploy to
  production, or take other exceptional actions only after explicit one-off
  approval through `automation-policy`.
