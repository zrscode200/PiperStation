---
name: piper-workflow
description: "Use when executing rather than exploring on a registered Piper Station project: write a formal spec and plan, prepare a Ralph-ready task queue, execute one scoped Ralph slice with verification and review gates, prepare compact-safe handoff, or route a permission-gated finish action. Entered from brainstorm once direction is set, or via /superpowers, /ralph, /compact-handoff."
---

# Piper Workflow

Piper Workflow owns convergent execution for Piper Station project work: formal
planning, Ralph preparation, Ralph execution, compaction handoff, and finish
routing. It is entered from the `brainstorm` front door once a request has
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
`projects/<project-id>/project.md`, `memory.md`, and `decisions.md` before
executing.

## Modes

Choose the smallest convergent path that fits:

| User intent | Mode | Supporting behavior |
| --- | --- | --- |
| Verify the direction, specify, or plan substantial work | Superpowers | this skill and `/superpowers` |
| Execute one clear queued task | Ralph | `/ralph` and Ralph sections in `STATION.md`; project source edits require `local` profile coverage |
| Review an implemented slice | Review | `review` |
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
acceptance criteria are testable — before locking a durable spec and plan. Open
exploration belongs to `brainstorm`.

## Artifact Signal Policy

This skill handles the convergent signals. Brainstorm owns the front-door band:
read-only orientation and planning, plus explicit deterministic registration.
When intent reaches these rows, durable writes are expected. The full
intent-to-writes map lives in `STATION.md`.

Formal planning or Ralph preparation may create useful
`projects/<id>/work/` records such as active spec, active plan, task queue,
context pack, and verification. Ralph execution may update those records and
edit only the real project repo when `local` profile coverage exists. Finish,
local git, worktree, PR, dependency, network, CI, external, or exceptional
actions route through `automation-policy` when they cross the active permission
profile boundary.

If a request is actually still divergent, hand it back to `brainstorm` rather
than escalating durable writes.

## Artifact Persistence Checkpoints

Piper artifacts stay in `projects/<project-id>/work/` by default. Updating
them during active work is allowed local assistance; committing those updates
is a `local` permission action and stays at the existing artifact checkpoint.
Record artifacts economically: `context-pack.md` is the only fully
self-contained resume packet; specs, plans, queues, and verification records
should stay purpose-specific and avoid repeating full repo/git/resume state.

Do not ask to commit after every artifact edit. At natural checkpoints, report
changed artifacts separately from registered project source changes, inspect
git state for both the real project repo and the Piper Station hub, and say
whether Piper artifact changes are uncommitted. Ask once about committing
Piper artifacts only when the scope or stopping point warrants it:

- `S0`: only if the user explicitly asked to record artifacts.
- `S1`: prefer only `active-plan.md`; ask at finish or compact only when the
  artifact matters for continuity.
- `S2`: use spec, plan, optional queue, and verification records; ask at
  planning finish, compact preparation, finish mode, or material plan/spec
  changes.
- `S3`: at milestone boundaries, compact preparation, finish mode, or material
  plan/spec changes.

After ordinary Ralph slices, update and report `task-queue.md` and
`verification.md` when they are in use. Avoid `context-pack.md` updates and
commit prompts unless the slice is also a milestone, changes the plan/spec, or
the user is about to pause, compact, switch projects, or finish.

## Scope And Risk

Use the scope and risk tiers defined in `STATION.md`. Scope controls artifact
weight and review expectations; risk controls Ralph implementation caution.
Permission profiles control action boundaries separately.

## Durable Context

Update hub records only when useful:

- `memory.md`: durable facts, user preferences, stable repo conventions, and
  reusable context.
- `decisions.md`: meaningful choices, tradeoffs, accepted risks, or policy
  decisions future work should not silently reopen.

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
