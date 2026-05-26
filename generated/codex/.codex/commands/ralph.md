---
description: Enter Ralph Mode for one scoped implementation slice
argument-hint: "[project id and optional task id]"
allowed-tools: [Read, Write, Bash]
---

# Ralph

Enter Ralph Mode for one scoped task.

The user invoked this command with: `$ARGUMENTS`

Ralph is prompt and command behavior in Codex. It selects one task,
states the diff boundary, implements that task, verifies, drift-checks, applies
the Implementation Review Gate when required or expected, and updates
compact-safe records when active work records are in use.

## Steps

1. Read `AGENTS.md`, `STATION.md`, and the relevant project record.
2. Read relevant files under `projects/<project-id>/work/`, especially
   `active-spec.md`, `active-plan.md`, `task-queue.md`, and
   `context-pack.md`.
3. Select one pending or active task: the task matching `$ARGUMENTS` if
   specified, otherwise the top ready task in the queue.
4. Confirm the task has acceptance criteria, a verification command or fallback,
   risk tier, and expected diff boundary.
5. Verify the real project repo is writable in the active session. If the repo
   is outside the current workspace or sandbox, state that writable access is
   required before execution instead of declaring the task Ralph-ready.
6. State the selected task and expected diff boundary before editing.
7. Stop if the task is ambiguous, lacks verification, is `L3`, or is `L2`
   without explicit user confirmation.
8. Implement only the selected task in the real project repo.
9. Run the narrowest meaningful initial verification.
10. Run the Implementation Review Gate based on scope and change impact:
   required for `S2/S3` and queued foundational work, expected for meaningful
   behavior-changing `S1`, optional for `S0/L0`, docs-only, or trivial work.
   Risk tier controls approval before execution, not review selection.
11. Verify reviewer findings in the main session, apply valid in-scope fixes,
    turn valid out-of-scope findings into follow-up notes or queue items, and
    reverify review-driven fixes with the narrowest meaningful command for the
    fixed behavior.
12. Drift-check the diff against the selected task, active plan/spec, and user
    request.
13. Update useful active work records, including `progress.md`,
    `verification.md`, and `context-pack.md`, when they are in use.
14. If a required or expected review gate was skipped, record review debt and do
    not continue to a dependent task until it is resolved or explicitly
    accepted by the user.
15. Prepare compact-safe state at natural stopping points.
16. Continue only if the next task is safe and the user asked for continuation.

Do not commit, push, open PRs, create worktrees, install dependencies, or run
external automation unless the user explicitly asks. Ralph prepares for
compaction; it does not invoke `/compact` itself.

## Drift And Stop Conditions

Drift-check the actual diff:

- None: actual changes are a subset of expected.
- Expected expansion: required touching files outside the task list but clearly
  in scope; record the file and reason.
- Out-of-scope work: changes include behavior the task did not ask for; stop
  and split or revert that work.
- Wrong scope: actual changes do not satisfy the task; stop and ask.

Stop and hand control back when the same verification fails twice without
meaningful progress, requirements are ambiguous, implementation drifts outside
the selected task, an `L2` task lacks approval, an `L3` action would be
required, tests or builds cannot run and no fallback exists, active work
records cannot be updated when needed for continuation, a required review gate
cannot run, or the plan appears wrong after repeated implementation attempts.

## Output

Report task executed, files changed, verification result, review gate status
and basis, accepted review fixes or rejected findings, review debt status,
drift result, decision ledger updates, context pack status, compaction status,
and next task or stop reason.

Never claim completion without fresh verification output.
