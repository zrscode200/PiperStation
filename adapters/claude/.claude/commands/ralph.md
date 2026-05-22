---
description: Enter Ralph mode for a registered project — execute one scoped task with initial verification, Implementation Review Gate, and compact-safe updates.
argument-hint: <project-id> [task id or description]
---

You are entering Ralph Mode for a registered project on this Piper Station hub.

The user invoked `/ralph $ARGUMENTS`.

Parse `$ARGUMENTS`:
- first token: `<project-id>` (required)
- remainder (optional): task id or task description

If `<project-id>` is missing, stop with usage.

## Steps

1. **Read `CLAUDE.md`** and the project record.
2. **Read relevant files under `projects/<project-id>/work/`** — especially `active-spec.md`, `active-plan.md`, `task-queue.md`, `context-pack.md`.
3. **Invoke the `ralph-loop` skill** for one iteration.
4. **Select one task** — the one matching `$ARGUMENTS` if specified, else the top pending or active task in the queue.
5. **State the expected diff boundary** before editing.
6. **Stop if** the task is ambiguous, lacks verification, is `L3`, or is `L2` without explicit user confirmation.
7. **Implement only the selected task** in the real project repo.
8. **Run initial verification** appropriate for the slice.
9. **Run the Implementation Review Gate** based on scope and change impact: required for `S2`/`S3` and queued foundational work, expected for meaningful behavior-changing `S1`, optional for `S0/L0`, docs-only, or trivial work. Risk tier controls approval before execution, not review selection.
10. **Verify reviewer findings** in the main session. Apply valid in-scope fixes. Turn out-of-scope findings into follow-up notes or new queue items. Reverify with the narrowest meaningful command for the fixed behavior.
11. **Drift-check** the diff against the task, active plan/spec, and user request.
12. **Update active work records** (`progress.md`, `verification.md`, `context-pack.md`) when in use.
13. **Record material decisions** in `projects/<project-id>/decisions.md`.
14. **Prepare compact-safe state** at natural stopping points.
15. **Pause** and tell the user they may run `/compact` only when context is low, a milestone just finished, or the next slice needs a clean context.
16. **Continue only if** the next task is safe and the user asked for continuation.

## Rules

- One task per invocation unless the user explicitly authorizes continuation.
- Do not commit, push, open PRs, create worktrees, install dependencies, or run external automation unless the user explicitly asks — see `automation-policy`.
- Stop on out-of-scope drift, repeated verification failure, a required review gate that cannot run, or `L3` requirements.
- Ralph prepares for compaction; it does not invoke `/compact` itself.
- Ralph is prompt and skill behavior. Use deterministic shell only for local
  verification commands or helpers named by the selected task; do not add
  lifecycle shell orchestration for Ralph itself.
- Queued foundational work includes bootstrap, install, update, registration,
  generated commands, hooks, settings, config, test harnesses, project or hub
  ownership, security policy, and automation policy.
- If a required or expected review gate is skipped, record review debt and do
  not continue to dependent tasks until it is resolved or explicitly accepted
  by the user.
