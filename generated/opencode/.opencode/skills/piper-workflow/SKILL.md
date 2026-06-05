---
name: piper-workflow
description: "Use when executing rather than exploring on a registered Piper Station project: write a formal spec and plan, prepare a Ralph-ready task queue, execute one scoped Ralph slice with verification and review gates, prepare compact-safe handoff, or route a protected finish action. Entered from brainstorm once direction is set, or via /superpowers, /ralph, /compact-handoff."
---

# Piper Workflow

Piper Workflow owns convergent execution for Piper Station project work: formal
planning, Ralph preparation, Ralph execution, compaction handoff, and finish
routing. It is entered from the `brainstorm` front door once a request has
converged on a direction, or directly through `/superpowers`, `/ralph`, and
`/compact-handoff`.

The `dispatcher` skill decides whether the root session handles this phase
inline or spawns a phase subagent with a delegation packet. Use `planner` for
Superpowers planning and `ralph` for one accepted implementation slice. This
skill defines the convergent behavior once the phase is selected.

`brainstorm` defines the divergent phase — orientation, framing, exploration,
conversational planning, registration, and routing. This skill assumes a
registered project and a direction that has converged toward durable work. If a
request is actually still divergent (orienting, exploring, or deciding what to
do), hand it back to the dispatcher for the `brainstorm` phase. Use the narrow
skills when their consequence applies: `review` for explicit review or review
gates, and `automation-policy` before protected automation or external state
changes.

Read `AGENTS.md` and `STATION.md` first. Resolve the project in
`projects/registry.json` to its `repo_path` and read
`projects/<project-id>/project.md`, `memory.md`, and `decisions.md` before
executing.

## Modes

Choose the smallest convergent path that fits:

| User intent | Mode | Supporting behavior |
| --- | --- | --- |
| Verify the direction, specify, or plan substantial work | Superpowers | `planner`, this skill, and `/superpowers` |
| Execute one clear queued task | Ralph | `ralph`, `/ralph`, and Ralph sections in `STATION.md` |
| Review an implemented slice | Review | `review` |
| Commit, PR, dependency, network, CI, destructive, or external action | Finish or approval flow | `automation-policy` |
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
edit only the real project repo. Finish, commit, PR, dependency, network, CI,
or destructive actions route through `automation-policy` before protected state
changes.

If a request is actually still divergent, hand it back to the dispatcher for
the `brainstorm` phase rather than escalating durable writes.

## Scope And Risk

Use the scope and risk tiers defined in `STATION.md`. Scope controls artifact
weight and review expectations; risk controls whether Ralph needs confirmation
or must stop before execution.

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
session. If the project repo is outside the current working directory, open OpenCode from the project directory or adjust workspace access before editing.

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
- Do not commit, push, merge, delete, install dependencies, or run external
  automation without explicit user approval; see `automation-policy.md`.
