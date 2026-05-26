---
description: Enter Superpowers Mode for discovery, specification, and planning
argument-hint: "[project id or repo path and request]"
allowed-tools: [Read, Write, Bash]
---

# Superpowers

Enter Superpowers Mode for a registered project.

The user invoked this command with: `$ARGUMENTS`

Use Superpowers Mode for discovery, specification, planning, and Ralph-ready
task decomposition before substantial implementation.

Use this command for formal planning, not for general repo orientation,
implementation, review, or automation approval. Natural-language routing can
choose this behavior through `piper-workflow`; protected actions still route
through `automation-policy`.

## Steps

1. Read `AGENTS.md`, `STATION.md`, and the relevant project record.
2. Identify the project id or repo path from `$ARGUMENTS`.
3. Inspect the real repo enough to ground discovery in current code.
4. Classify scope as `S0`, `S1`, `S2`, or `S3`.
5. Classify risk as `L0`, `L1`, `L2`, or `L3`.
6. Ask only blocking clarification questions. If you cannot articulate what
   answer would change the design, do not ask.
7. For `S1+`, create or update only useful active work files under
   `projects/<project-id>/work/`.
8. For `S2+`, write a concise spec and implementation plan before execution.
   Prefer `projects/<project-id>/work/specs/` and
   `projects/<project-id>/work/plans/` unless the project repo has its own
   established docs location.
9. Produce a Ralph-ready `task-queue.md` only when tasks are clear and
   verifiable.
10. Update `context-pack.md` with compact-safe reload state when active work
    records are in use.
11. Stop before implementation unless the user explicitly asks to proceed.

Registration must not create `projects/<project-id>/work/`; Codex
creates these files only when useful for active work. Keep Superpowers as
Codex-native prompt and command behavior; do not introduce shell lifecycle
machinery for planning.

## Work Artifacts

Create only under `projects/<project-id>/work/`, and only when useful:

- `active-spec.md`: current problem, goals, non-goals, acceptance criteria,
  risks, and open questions for `S2+` or Ralph-bound work.
- `active-plan.md`: current approach, ordered slices, tradeoffs,
  dependencies, and verification strategy for `S1+` work that needs
  continuity.
- `task-queue.md`: Ralph-ready task list with ids, status, risk, acceptance
  criteria, verification, and expected diff boundary.
- `context-pack.md`: compact/resume anchor with the current task, next exact
  action, files to inspect first, git state, verification, review state, drift,
  blockers, and stop reason.
- `progress.md`: durable progress, completed tasks, blockers, review debt, and
  next action for multi-turn work.
- `verification.md`: commands run, results, failures, fallbacks, skipped
  checks, and remaining verification gaps.
- `handoff.md`: short handoff for a human or fresh agent when pausing,
  compacting, blocking, or transferring work.
- `specs/`, `plans/`, and `runs/`: archived or named records for substantial
  milestones, alternatives, superseded approaches, or dense Ralph iterations.

Keep stable facts in `memory.md` and durable decisions in `decisions.md`.
Registration must not create active work artifacts.

## Spec Shape

Include problem or opportunity, goals and non-goals, users and workflows,
proposed behavior, acceptance criteria, approach and tradeoffs, risks and
guardrails, verification expectations, and open questions.

## Task Shape

Each queued Ralph task should include id, title, status, risk, likely files or
areas, acceptance criteria, verification command or documented fallback,
expected diff boundary, context needed by a fresh session or reviewer, and
dependencies.

## Guardrails

- Do not implement while discovering or planning.
- Mark assumptions separately from confirmed facts.
- Keep plans concrete enough for a fresh Codex session to continue cold.
- Do not store secrets or sensitive raw logs in hub records.
- Record meaningful approach, scope, risk, or verification decisions in
  `projects/<project-id>/decisions.md`.
- "Make it better" is not an acceptance criterion; force a testable one.
