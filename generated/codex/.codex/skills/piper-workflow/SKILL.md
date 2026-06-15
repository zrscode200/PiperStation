---
name: piper-workflow
description: "Codex convergent execution for Piper Station project work — use when executing rather than exploring. Trigger via $piper-workflow or by stating the intent once direction is set: formalize active work, update roadmap or build-log checkpoints, prepare an optional durable Ralph queue, execute the current Ralph wave, explicit slice, or queued task, operate the group lifecycle across entry, execution, closeout, and transition between groups, prepare compact-safe handoff, or route a permission-gated finish action. Routes to the matching procedure under references/."
---

# Piper Workflow (Codex)

Piper Workflow owns convergent execution for Piper Station project work in
Codex — within-group and across the group lifecycle: formal planning, Ralph
preparation, Ralph execution, group entry, closeout, and transition, compaction
handoff, and finish routing. It operates not only inside a single wave or group
but across the full sequence of groups toward a milestone. It is entered from
the `brainstorm` front door once a
request has converged on a direction, or directly by invoking
`$piper-workflow ...` or stating the intent.

Codex CLI does not surface `.codex/commands/` as slash commands; the detailed
procedures live as reference files in this skill directory. The divergent phase
— orientation, framing, exploration, and registration — belongs to `brainstorm`;
if a request is actually still divergent, hand it back. Read `AGENTS.md` and
`STATION.md` first, resolve the project in `projects/registry.json` to its
`repo_path`, and read `projects/<project-id>/project.md`, `memory.md`, and
optional `decisions.md` when it exists before executing.

## References

- `references/superpowers.md` — verify the handed-off direction, define the
  group or milestone structure (Structural Planning), and formalize the
  current wave (Wave Formalization).
- `references/ralph.md` — execute the current wave, explicit slice, or queued
  task with review discipline.
- `references/compact-handoff.md` — prepare compact-safe continuity records
  before pause or compaction.

Use the narrow skills when their specific consequence applies: `review` for
explicit review or review gates, and `automation-policy` before crossing the
active permission profile boundary. Orientation and registration route through
the `brainstorm` skill.

## Dispatch

Choose the smallest convergent path that fits:

| User intent | Route | Procedure |
| --- | --- | --- |
| Verify direction and define group or milestone structure | Superpowers Mode — Structural Planning | `references/superpowers.md` |
| Formalize the current wave into Ralph-ready detail | Superpowers Mode — Wave Formalization | `references/superpowers.md`; Ralph runs this pass at a wave boundary when the selected wave is still a sketch |
| Execute one clear active-work wave, explicit slice, or optional queued task | Ralph Mode | `references/ralph.md` and Ralph sections in `STATION.md`; project source edits require `local` profile coverage |
| Review code or an implemented wave, group, or slice | Review Mode | the `review` skill |
| Local git, worktree, PR, dependency, network, CI, exceptional, or external action | Finish Mode or permission flow | the `automation-policy` skill |
| Pause or compact active work | compact handoff | `references/compact-handoff.md` and compact sections in `STATION.md` |
| Orient, explore, or decide what to do | hand back | the `brainstorm` skill |

Prefer consequence language such as "I will create Ralph-ready work records"
over ceremonial mode announcements. Proceed when the route is clear and safe;
wait for go-ahead when confirmation is required, risk is `L2`, or the request is
ambiguous.

## Superpowers Entry

Superpowers begins where `brainstorm` ended. Its lead step is verification, not
open exploration: take the direction from brainstorm's hand-off brief and
confirm it against the real code — validate the brief's flagged assumptions,
check the files and call sites the work will touch, and confirm acceptance
criteria are testable — before locking durable active work.

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
  acceptance in `roadmap.md`, and record contracts later groups depend on.
- **Transition**: check whether the outcome reshapes later groups; carry
  learnings forward; continue to the next group's Entry, or surface for
  re-planning when the roadmap materially changes. Keep re-planning here in
  Superpowers; hand back to `brainstorm` only for a genuinely divergent question.

See `STATION.md` → Group Lifecycle for the canonical stage policy, gates, and
artifact obligations.

## Artifact Signal Policy

This skill handles the convergent signals; `brainstorm` owns the front-door
band: read-only orientation and planning, plus explicit deterministic
registration. When intent reaches these rows, durable writes are expected. The
full intent-to-writes map lives in `STATION.md`.

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

## Artifact Persistence Checkpoints

Piper artifacts stay in `projects/<project-id>/work/` by default. Updating
them during active work is allowed local assistance; committing those updates
is a `local` permission action and must go through `automation-policy` when the
active permission profile does not cover local git.
Record artifacts economically: `context-pack.md` is the only fully
self-contained resume packet; roadmap, active-work, queue, and build-log
records should stay purpose-specific and avoid repeating full
repo/git/resume state.

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

## Workspace Access

Before Ralph execution, verify writable repo access for the real project repo
in the active Codex session. If it is outside the current sandbox, tell the user
that Codex must be started with `--add-dir <project-repo>` or that sandbox
access must otherwise be granted before execution — do not declare the task
Ralph-ready until writable access exists.

## Subagent Helpers

The hub declares seven Codex subagent roles in `.codex/config.toml`:
`reviewer`, `implementer`, `tester`, `verifier`, `architect`,
`docs_researcher`, and `security_reviewer`. Spawn the matching role when its
specific responsibility applies — for example, `reviewer` during a Ralph review
gate, `verifier` for existing read-only checks, `tester` only for explicit
test-layer edits, or `security_reviewer` for auth/permissions changes.
(`architect` and `docs_researcher` also support `brainstorm`'s read-only
investigation.)

The main session stays responsible for the work. Validate each subagent finding
before acting: give each an explicit verdict — `confirmed-in-scope`,
`confirmed-out-of-scope`, or `false-positive` — before editing code; apply
only `confirmed-in-scope` fixes; turn `confirmed-out-of-scope` findings into
follow-up notes or queue items.

## Durable Context

Update hub records only when useful:

- `memory.md`: durable facts, user preferences, stable repo conventions, and
  reusable context.
- `project.md`: project policy preferences, one-off approvals, accepted risks,
  and project-level automation notes.
- optional `decisions.md`: substantial decision logs future work should not
  silently reopen.

Routine progress, command output, and transient notes should stay in the
conversation unless substantial active work needs continuity under
`projects/<project-id>/work/`.

Create `projects/<project-id>/work/` only when useful. Registration (in
`brainstorm`) must not create active work artifacts.

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Do not add sessions, checkpoints, dashboards, queue managers, or lifecycle
  shell workflows.
- Keep planning, Ralph, review, and compaction as prompt, skill, reference, and
  narrow consequence-specific behavior. The deterministic shell helper is for
  project registration only.
- Orientation and registration belong to `brainstorm`; this skill assumes a
  registered, converged target.
- Do not commit, push, merge, create or switch worktrees, install dependencies,
  or run external automation unless the selected workflow reached that action
  and the active permission profile allows it; see `automation-policy.md`.
  Delete, force-push, rewrite history, deploy to production, or take other
  exceptional actions only after explicit one-off approval through
  `automation-policy`.
