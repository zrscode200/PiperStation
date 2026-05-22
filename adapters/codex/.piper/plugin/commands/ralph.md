---
description: Run one Ralph iteration or continue a ready task queue for a registered project.
argument-hint: [project id and optional task id]
allowed-tools: [Read, Write, Bash]
---

# Ralph Mode

Use this command from a Piper Station hub-lite directory.

The user invoked this command with: $ARGUMENTS

## Instructions

1. Read `AGENTS.md`, `STATION.md`, and the relevant project record.
2. Read relevant files under `projects/<project-id>/work/`, especially
   `active-spec.md`, `active-plan.md`, `task-queue.md`, and
   `context-pack.md`.
3. Select one pending or active task.
4. State the expected diff boundary before editing.
5. Stop if the task is ambiguous, lacks verification, is `L3`, or is `L2`
   without explicit user confirmation.
6. Implement only the selected task in the real project repo.
7. Run the initial verification appropriate for the slice.
8. Run the Implementation Review Gate when required, expected, or requested:
   required for `S2/S3`, required for queued tasks touching foundational
   behavior, expected for meaningful behavior-changing `S1`, and optional for
   `S0/L0`, docs-only, or trivial local work. Review gate selection is based on
   scope and change impact. Risk tier determines whether execution needs
   explicit user approval.
9. Verify reviewer findings in the main session, apply valid in-scope fixes,
   and reverify review-driven fixes with the narrowest meaningful command for
   the fixed behavior.
10. Drift-check against the active plan/spec, then update useful active work
   records. If active work records are in use and the review gate was skipped,
   record the skip reason. If a required or expected gate was skipped, record
   review debt and do not continue to a dependent task until the debt is
   resolved or the user explicitly accepts it.
11. At natural stopping points, make `context-pack.md` compact-safe.
12. Pause and tell the user they may run `/compact` only when context is low, a
   milestone just finished, or the next slice needs a clean context.
13. Continue only if the next task is safe and the user asked for continuation.

Do not commit, push, open PRs, create worktrees, install dependencies, or run
external automation unless the user explicitly asks.
