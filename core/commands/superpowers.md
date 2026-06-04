{{FRONTMATTER}}# Superpowers

Enter Superpowers Mode for a registered project.

The user invoked this command with: `$ARGUMENTS`

Use Superpowers Mode to verify a direction, specify, plan, and decompose
Ralph-ready tasks before substantial implementation.

Use this command for formal planning, not for divergent exploration or general
repo orientation (those belong to `brainstorm`), implementation, review, or
automation approval. Natural-language routing reaches this behavior through
`piper-workflow`; protected actions still route through `automation-policy`.

## Steps

1. Read `{{INSTRUCTION_DOC}}` and `STATION.md`.
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
   Prefer `projects/<project-id>/work/specs/` and
   `projects/<project-id>/work/plans/` unless the project repo has its own
   established docs location.
9. Produce a Ralph-ready `task-queue.md` only when tasks are clear and
   verifiable.
10. Update `context-pack.md` with compact-safe reload state when active work
    records are in use.
11. Stop before implementation unless the user explicitly asks to proceed.

Registration must not create `projects/<project-id>/work/`; {{RUNTIME_NAME}}
creates these files only when useful for active work. Keep Superpowers as
{{RUNTIME_NATIVE}} prompt and command behavior; do not introduce shell lifecycle
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
- Keep plans concrete enough for a fresh {{RUNTIME_SESSION}} to continue cold.
- Do not store secrets or sensitive raw logs in hub records.
- Record meaningful approach, scope, risk, or verification decisions in
  `projects/<project-id>/decisions.md`.
- "Make it better" is not an acceptance criterion; force a testable one.
