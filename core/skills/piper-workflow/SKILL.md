---
name: piper-workflow
description: "Execute converged work on a registered Piper Station project: verify direction, formalize bounded work, implement and review it, coordinate authorized workers, integrate results, or resume an execution lane. Use after brainstorm, an accepted Design Studio handoff, or an explicit implementation request."
---

# Piper Workflow

This skill owns convergent execution. Read `AGENTS.md` and the relevant canonical
sections of `STATION.md`. Resolve the project through `projects/registry.json`,
read its `project.md`, relevant `memory.md` and decisions, and select its lane
before acting. Source stays in the registered repo or assigned worktrees; all
Piper work records stay in the hub.

## Choose The Smallest Useful Procedure

- Verify direction, plan groups, or formalize a wave: read
  `references/superpowers.md`.
- Execute a clear wave, slice, or task: read `references/ralph.md`. It formalizes
  a sketched current wave before editing.
- Coordinate related independent sessions or explicitly authorized workers:
  also read `references/coordinated-work.md`.
- Publish a verified result into base: read `references/integration.md`.
- Pause, compact, or resume a lane: read `references/compact-handoff.md`.
- Run explicit review or a required gate: use `review`.
- Reach an external or exceptional action: use `automation-policy`.

Read only procedures relevant to the work. Native planning/tasks support steps
inside a session. The default is one ungrouped wave with one acceptance entry;
create current-work or resume records only when they preserve useful state.

## Direction And Authority

Ordinary brainstorm direction is valid input; a studio is optional. Divergent
questions return to brainstorm, or to the existing studio when its premise
changes. A studio handoff declares:

```text
design_artifact: projects/<id>/work/design/<slug>/design.md
accepted_revision: N
```

Verify current `status: accepted-for-planning`, integer `revision`, and integer
`accepted_revision`, both equal to handed-off `N`. Read explicitly adopted details
and relevant linked evidence; verify fixed contracts and premises against live
source. Use the ordinary hub acceptance checkpoint to check later adopted-content
edits, even when the overview's revision is unchanged, and inspect subsequent
relevant evidence assessments. Resolve ambiguous accepted content before relying
on it; a material change needs renewed acceptance. A missing, provisional,
superseded, or changed revision is stale; obtain explicit acceptance and reverify
before relying on it. Record the pair rather than copying canonical design.
Choices within implementation freedoms remain downstream; do not silently
redesign fixed contracts during planning or execution.

A source-edit request selects execution, then formalization; it does not skip
acceptance criteria, checkout ownership, access, risk, or review. Prior explicit
authorization and scoped L2 waivers persist; do not ask again for the same
covered boundary. External and exceptional actions retain their own policy.

## Continuity And Coordination

`STATION.md` → Lanes owns selection and paths. Flat is the default. Named
execution lanes support independent work without requiring a group; groups
exist for shared multi-wave acceptance. A studio keeps its design continuity
in its own folder and hands off to a separate execution lane. Never execute a
Ralph wave inside studio continuity.

Before dependent work, reconcile related canonical contracts and revisions.
Record consequential findings with evidence, affected work, impact, and one
resolution owner. Continue unaffected work; revalidate or pause affected work.
Delegated workers have explicit scopes and isolated writable checkouts, report
findings and actual results, and leave hub records and acceptance to the parent.
Independent sessions own their own lanes and reconcile shared decisions through
protected records. Native session handles never prove live work or completion.

Use `piper-record` for shared records, ownership publication and path-only hub
commits as defined by STATION. Ordinary sole-owned lane records may use normal
file tools. Commit completed/paused continuity at meaningful checkpoints
unless the user asks otherwise; no recurring artifact-commit approval ceremony.
A stale publication requires rereading and reconciliation, not forced overwrite.

## Completion

Operate group Entry, Execution, Closeout, and Transition from STATION. Verify
source and the combined behavior before accepting a boundary. Apply review gates,
self-verify findings, resolve confirmed in-scope issues, and record explicitly
accepted debt or deferred scope. Keep acceptance, actual integration, and pending
PR state distinct. Retain source worktrees unless deletion is explicitly approved.

At checkpoints, reconcile windows, ledger, related work, and roadmap; report hub
and source changes separately. On resume inspect live source, current design
revisions, partial publication, and actual worker status before continuing.

Do not create a daemon, global queue, session registry, or copied source tree.
Registration remains the narrow `add-project` helper. Record publication and
verified integration helpers protect concrete operations; planning, scope,
coordination, and acceptance remain Codex reasoning and native task behavior.
