---
description: Enter Superpowers Mode for discovery, specification, and planning
argument-hint: "<project-id> [request]"
---

# Superpowers

Enter Superpowers Mode for a registered project.

The user invoked this command with: `$ARGUMENTS`

Use Superpowers Mode for discovery, specification, planning, and Ralph-ready
task decomposition before substantial implementation.

## Steps

1. Read `CLAUDE.md`, `STATION.md`, and the relevant project record.
2. Identify the project id or repo path from `$ARGUMENTS`.
3. Inspect the real repo enough to ground discovery in current code.
4. Classify scope as `S0`, `S1`, `S2`, or `S3`.
5. Classify risk as `L0`, `L1`, `L2`, or `L3`.
6. Ask only blocking clarification questions.
7. For `S1+`, create or update only useful active work files under
   `projects/<project-id>/work/`.
8. For `S2+`, write a concise spec and implementation plan before execution.
9. Produce a Ralph-ready `task-queue.md` only when tasks are clear and
   verifiable.
10. Update `context-pack.md` with compact-safe reload state when active work
    records are in use.
11. Stop before implementation unless the user explicitly asks to proceed.

Registration must not create `projects/<project-id>/work/`; Claude Code
creates these files only when useful for active work. Keep Superpowers as
Claude Code-native prompt and command behavior; do not introduce shell lifecycle
machinery for planning.

## Work Artifacts

Create only when useful:

- `active-spec.md`
- `active-plan.md`
- `task-queue.md`
- `context-pack.md`
- `progress.md`
- `verification.md`
- `handoff.md`
- `specs/`, `plans/`, and `runs/` for substantial work

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
- Keep plans concrete enough for a fresh Claude Code session to continue cold.
- Do not store secrets or sensitive raw logs in hub records.
- Record meaningful approach, scope, risk, or verification decisions in
  `projects/<project-id>/decisions.md`.
- "Make it better" is not an acceptance criterion; force a testable one.
