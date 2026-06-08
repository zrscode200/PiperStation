---
description: Enter Superpowers Mode for discovery, specification, and planning
argument-hint: "[project id or repo path and request]"
---

# Superpowers

Enter Superpowers Mode for a registered project.

The user invoked this command with: `$ARGUMENTS`

Use Superpowers Mode to verify a direction, specify, plan, and decompose
Ralph-ready tasks before substantial implementation.

Use this command for formal planning, not for divergent exploration or general
repo orientation (those belong to `brainstorm`), implementation, review, or
automation approval. Natural-language routing reaches this behavior through
`piper-workflow`; actions that cross the active permission profile boundary
still route through `automation-policy`.

## Steps

1. Read `AGENTS.md` and `STATION.md`.
2. Identify the project id or repo path from `$ARGUMENTS`. Look up the project
   in `projects/registry.json` to confirm registration and resolve `repo_path`,
   then read `projects/<project-id>/project.md`, `memory.md`, and optional
   `decisions.md` when it exists.
3. Verify the direction handed off from `brainstorm` against the real code:
   confirm the brief's flagged assumptions, inspect the specific files and call
   sites the work will touch, and check that acceptance criteria are testable.
   Open exploration belongs to `brainstorm`; this step grounds the chosen
   direction, it does not re-open it.
4. Classify scope as `S0`, `S1`, `S2`, or `S3` for sizing only.
5. Classify risk as `L0`, `L1`, `L2`, or `L3`.
6. Ask only blocking clarification questions. If you cannot articulate what
   answer would change the design, do not ask.
7. Create or update active work files under `projects/<project-id>/work/` only
   when they do a clear job: preserve long-horizon direction, stabilize current
   active work, create durable queued execution, record a checkpoint, or prepare
   compact/resume continuity.
8. Write `active-work.md` only when requirements, acceptance criteria,
   strategy, tradeoffs, sequence, or verification strategy need a durable target
   before execution. Keep work artifacts in `projects/<project-id>/work/`
   unless the user explicitly asks for a project-local copy.
9. Update `roadmap.md` only when long-term direction, milestones, deferred
   work, risks, or revisit triggers change.
10. Produce a Ralph-ready `task-queue.md` only when tasks are clear,
    verifiable, and must survive the current session or move across agents.
11. Append `build-log.md` at formal planning completion when the plan
    materially changes future execution.
12. Defer `context-pack.md` unless planning is stopping, pausing, preparing
    for compact, handing off, blocked, or crossing a milestone boundary.
13. At the planning checkpoint, report changed Piper artifacts separately from
    source changes, inspect the Piper Station hub git state when artifacts
    changed, and state whether those artifact changes are uncommitted.
14. Offer one Piper artifact commit at planning finish only when the changed
    artifacts matter for future continuity. Do not commit unless the checkpoint
    decision is made and the active permission profile covers local git actions;
    otherwise route through `automation-policy`.
15. Stop before implementation unless the user explicitly asks to proceed.

Registration must not create `projects/<project-id>/work/`; OpenCode
creates these files only when useful for active work. Keep Superpowers as
OpenCode-native prompt and command behavior; do not introduce shell lifecycle
machinery for planning.

## Work Artifacts

Create only under `projects/<project-id>/work/`, and only when useful:

- `roadmap.md`: longer-horizon direction, milestones, deferred work, risks,
  and revisit triggers.
- `active-work.md`: current goal, requirements, acceptance criteria, approach,
  slices, risks, verification strategy, and open questions.
- `build-log.md`: concise checkpoint ledger for planning outcomes,
  implementation summaries, review and verification results, risks, next
  steps, and commits.
- `context-pack.md`: compact/resume and handoff anchor with the current task,
  next exact action, files to inspect first, git state, verification, review
  state, drift, blockers, stop reason, and what to hand a human or fresh agent.
- `task-queue.md`: optional durable Ralph task list with ids, status, risk,
  acceptance criteria, verification, and expected diff boundary.

Keep artifacts lean: `context-pack.md` is the only fully self-contained resume
packet. Do not duplicate branch, HEAD, full git state, review state, blockers,
or next action across every roadmap, active-work, queue, or build-log record.

Keep stable facts in `memory.md`, project policy preferences in `project.md`,
and substantial decision logs in optional `decisions.md`. Registration must not
create active work artifacts.

## Artifact Persistence

Superpowers is a natural artifact checkpoint. Updating work artifacts is part
of planning, but committing them is not automatic. At the end of planning,
summarize the artifact files touched, their role in the next Ralph slice or
future session, and whether they remain uncommitted in the Piper Station hub.
Offer a single artifact commit only when the artifact checkpoint matters for
future continuity; permission profiles gate whether that local git action can
proceed, not whether the checkpoint exists.

## Spec Shape

`active-work.md` should include problem or opportunity, goals and non-goals,
users and workflows, proposed behavior, acceptance criteria, approach and
tradeoffs, risks and guardrails, verification strategy, and open questions.

## Task Shape

Each queued Ralph task should include id, title, status, risk, likely files or
areas, acceptance criteria, verification command or documented fallback,
expected diff boundary, context needed by a fresh session or reviewer, and
dependencies.

## Guardrails

- Do not implement while discovering or planning.
- Mark assumptions separately from confirmed facts.
- Keep plans concrete enough for a fresh OpenCode session to continue cold.
- Do not store secrets or sensitive raw logs in hub records.
- Record project policy preferences in `project.md`; use optional
  `decisions.md` only for substantial decision logs.
- "Make it better" is not an acceptance criterion; force a testable one.
