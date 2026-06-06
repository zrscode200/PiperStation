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
`piper-workflow`; protected actions still route through `automation-policy`.

## Steps

1. Read `AGENTS.md` and `STATION.md`.
2. Identify the project id or repo path from `$ARGUMENTS`. Look up the project
   in `projects/registry.json` to confirm registration and resolve `repo_path`,
   then read `projects/<project-id>/project.md`, `memory.md`, and
   `decisions.md` for the rich record.
3. Verify the direction handed off from `brainstorm` against the real code:
   confirm the brief's flagged assumptions, inspect the specific files and call
   sites the work will touch, and check that acceptance criteria are testable.
   Open exploration belongs to `brainstorm`; this step grounds the chosen
   direction, it does not re-open it.
4. Classify scope as `S0`, `S1`, `S2`, or `S3`.
5. Classify risk as `L0`, `L1`, `L2`, or `L3`.
6. Ask only blocking clarification questions. If you cannot articulate what
   answer would change the design, do not ask.
7. For `S1+`, create or update only useful active work files under
   `projects/<project-id>/work/`.
8. For `S2+`, write a concise spec and implementation plan before execution.
   Keep active and archived planning artifacts in
   `projects/<project-id>/work/` unless the user explicitly asks for a
   project-local copy.
9. Produce a Ralph-ready `task-queue.md` only when tasks are clear and
   verifiable.
10. Update `context-pack.md` with compact-safe reload state when active work
    records are in use.
11. At the planning checkpoint, report changed Piper artifacts separately from
    source changes, inspect the Piper Station hub git state when artifacts
    changed, and state whether those artifact changes are uncommitted.
12. For `S2+`, offer one Piper artifact commit at planning finish; for `S1`,
    ask only if the active plan matters for future continuity. Do not commit
    unless the user approves through `automation-policy`.
13. Stop before implementation unless the user explicitly asks to proceed.

Registration must not create `projects/<project-id>/work/`; OpenCode
creates these files only when useful for active work. Keep Superpowers as
OpenCode-native prompt and command behavior; do not introduce shell lifecycle
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
- `context-pack.md`: compact/resume and handoff anchor with the current task,
  next exact action, files to inspect first, git state, verification, review
  state, drift, blockers, stop reason, and what to hand a human or fresh agent.
- `verification.md`: commands run, results, failures, fallbacks, skipped
  checks, and remaining verification gaps.
- `specs/`, `plans/`, and `runs/`: archived or named records for substantial
  milestones, alternatives, superseded approaches, or dense Ralph iterations.

Keep stable facts in `memory.md` and durable decisions in `decisions.md`.
Registration must not create active work artifacts.

## Artifact Persistence

Superpowers is a natural artifact checkpoint. Updating work artifacts is part
of planning, but committing them is not automatic. At the end of planning,
summarize the artifact files touched, their role in the next Ralph slice or
future session, and whether they remain uncommitted in the Piper Station hub.
Offer a single artifact commit only at the scope-appropriate boundary described
in `STATION.md`.

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
- Keep plans concrete enough for a fresh OpenCode session to continue cold.
- Do not store secrets or sensitive raw logs in hub records.
- Record meaningful approach, scope, risk, or verification decisions in
  `projects/<project-id>/decisions.md`.
- "Make it better" is not an acceptance criterion; force a testable one.
