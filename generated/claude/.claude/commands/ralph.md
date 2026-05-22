---
description: Enter Ralph Mode for one scoped implementation slice
argument-hint: "<project-id> [task id or description]"
---

# Ralph

Enter Ralph Mode for one scoped task.

The user invoked this command with: `$ARGUMENTS`

Ralph is prompt and skill behavior in Claude Code. It selects one task,
states the diff boundary, implements that task, verifies, drift-checks, applies
the Implementation Review Gate when required or expected, and updates
compact-safe records when active work records are in use.

## Steps

1. Read `CLAUDE.md`, `STATION.md`, and the relevant project record.
2. Read relevant files under `projects/<project-id>/work/`, especially
   `active-spec.md`, `active-plan.md`, `task-queue.md`, and
   `context-pack.md`.
3. Select one pending or active task: the task matching `$ARGUMENTS` if
   specified, otherwise the top ready task in the queue.
4. Confirm the task has acceptance criteria, a verification command or fallback,
   risk tier, and expected diff boundary.
5. State the selected task and expected diff boundary before editing.
6. Stop if the task is ambiguous, lacks verification, is `L3`, or is `L2`
   without explicit user confirmation.
7. Implement only the selected task in the real project repo.
8. Run the narrowest meaningful initial verification.
9. Run the Implementation Review Gate based on scope and change impact:
   required for `S2/S3` and queued foundational work, expected for meaningful
   behavior-changing `S1`, optional for `S0/L0`, docs-only, or trivial work.
   Risk tier controls approval before execution, not review selection.
10. Verify reviewer findings in the main session, apply valid in-scope fixes,
    turn valid out-of-scope findings into follow-up notes or queue items, and
    reverify review-driven fixes with the narrowest meaningful command for the
    fixed behavior.
11. Drift-check the diff against the selected task, active plan/spec, and user
    request.
12. Update useful active work records, including `progress.md`,
    `verification.md`, and `context-pack.md`, when they are in use.
13. If a required or expected review gate was skipped, record review debt and do
    not continue to a dependent task until it is resolved or explicitly
    accepted by the user.
14. Prepare compact-safe state at natural stopping points.
15. Continue only if the next task is safe and the user asked for continuation.

Do not commit, push, open PRs, create worktrees, install dependencies, or run
external automation unless the user explicitly asks. Ralph prepares for
compaction; it does not invoke `/compact` itself.
