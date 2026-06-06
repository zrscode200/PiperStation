---
description: Enter Ralph Mode for one scoped implementation slice
argument-hint: "<project-id> [task id or description]"
---

# Ralph

Enter Ralph Mode for one scoped task.

The user invoked this command with: `$ARGUMENTS`

Ralph is prompt and command behavior in Claude Code. It selects one task,
states the diff boundary, implements that task, verifies, drift-checks, applies
the Implementation Review Gate when required or expected, and updates
compact-safe records when active work records are in use.

Ralph is not a shell runner and not a general planner. Use it after a task is
clear or `projects/<project-id>/work/task-queue.md` is ready. Natural-language
routing can choose this behavior through `piper-workflow`; protected actions
still route through `automation-policy`.

## Steps

1. Read `CLAUDE.md` and `STATION.md`. Look up the project in
   `projects/registry.json` to confirm registration and resolve `repo_path`,
   then read the relevant `projects/<project-id>/project.md`, `memory.md`, and
   `decisions.md`.
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
7. Mark the task active in `projects/<project-id>/work/task-queue.md` when a
   queue exists and active work records are in use.
8. Stop if the task is ambiguous, lacks verification, is `L3`, is outside the
   approved spec or plan, or is `L2` without explicit user confirmation.
9. Implement only the selected task in the real project repo.
10. Run the narrowest meaningful initial verification.
11. Run the Implementation Review Gate based on scope and change impact:
   required for `S2/S3` and queued foundational work, expected for meaningful
   behavior-changing `S1`, optional for `S0/L0`, docs-only, or trivial work.
   Risk tier controls approval before execution, not review selection.
12. Validate reviewer findings before editing: give each finding an explicit
    verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or
    `false-positive` — and do not edit code until every finding has one. Then
    apply fixes only for `confirmed-in-scope` findings, turn
    `confirmed-out-of-scope` findings into follow-up notes or queue items, and
    reverify review-driven fixes with the narrowest meaningful command for the
    fixed behavior. Run broader verification only when fixes touch shared,
    risky, or cross-cutting behavior.
13. Drift-check the diff against the selected task, active plan/spec, and user
    request.
14. For ordinary slice-end bookkeeping, update `task-queue.md` status and
    `verification.md` results when they are in use. Update `active-spec.md` or
    `active-plan.md` only when requirements, strategy, or scope materially
    changed.
15. Report changed Piper artifacts separately from registered project source
    changes. At ordinary slice boundaries, do not ask to commit artifact
    updates or update `context-pack.md` unless this slice completes a
    milestone, materially changes the active plan/spec, hits a blocker, leaves
    context low, or the user is about to pause, compact, switch projects, or
    finish.
16. Record material decisions in `projects/<project-id>/decisions.md`.
17. If a required or expected review gate was skipped, record review debt and do
    not continue to a dependent task until it is resolved or explicitly
    accepted by the user.
18. Prepare compact-safe state at natural stopping points.
19. Continue only if the next task is safe and the user asked for continuation.

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

## Review Gate Details

Use the review gate after a slice is implemented and initially verified, before
marking the slice complete in durable work records.

Review gate examples:

- `S0/L0` typo fix or docs wording tweak: gate optional.
- Meaningful `S1` behavior change: gate expected.
- Queued bootstrap, registration, hook/config, or test-harness slice: gate
  required.
- `L2` dependency or CI action: get approval before execution; choose the gate
  from scope and impact.

When the gate runs, use the read-only reviewer agent. The reviewer inspects the actual
changed code or diff and relevant surrounding code first, using the active
spec, plan, task queue, build or test logs, and known non-goals as supporting
context. The reviewer reports correctness, regression, security, reliability,
missing-test, convention, and drift findings ordered by severity with file and
line references when possible.

The main Claude Code session stays responsible for the work. Validate each
reviewer finding before acting: record a one-line verdict per finding —
`confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive` — before
editing any code. Apply fixes only for `confirmed-in-scope` findings. Turn
`confirmed-out-of-scope` findings into follow-up notes or tasks. Briefly record
why a finding was rejected as a `false-positive` when that helps future readers.
If a required review gate cannot run, stop and tell the user what is missing
unless the user explicitly accepts the review debt.

## Compaction Discipline

At each natural stopping point, prepare compact-safe state before continuing or
pausing. Natural stopping points include a completed task or slice, a milestone
boundary, a failed verification stop, a blocked task, or transition to a larger
next task.

When active work records are in use:

1. Update `task-queue.md` with the current task status.
2. Update `verification.md` with commands, results, and gaps.
3. Update `context-pack.md` only when pausing, preparing for compact, finishing,
   blocked, crossing a milestone, context is low, switching projects, or
   materially changing the plan/spec. When updated, include last completed
   task, current task status, next exact action, scope boundary, files changed,
   files to inspect first after compact, known reference paths, branch, HEAD,
   `git status --short`, verification status, review state, drift result,
   blockers, risks, broad search triggers, stop reason, and what to hand a
   human or fresh agent.
4. Report artifact files updated in the Piper Station hub and whether they are
   committed. If the stop is a milestone boundary, compact preparation, finish
   mode, project switch, or material plan/spec change, ask once whether to
   commit the Piper artifact updates through `automation-policy`.

If the next task is safe and context is not a concern, continue normally. If
context is low, a milestone just finished, or the next slice needs a clean
context, pause after updates and tell the user the state is compact-ready and
they may run `/compact`.

## Post-Compact Resume

After compact, resume from designed anchors first:

- `context-pack.md`
- `task-queue.md`
- `active-plan.md`
- `verification.md`
- project `decisions.md`
- branch, HEAD, and `git status --short`

Then rebuild the active task neighborhood before editing. Inspect changed
files, explicitly named files, related tests, configs, docs, generated
surfaces, and known reference paths. Expand beyond that when there is a
concrete reason: a stale resume packet, missing acceptance criteria, failing
verification, unclear coupling, generated parity, security or permissions
behavior, or review scope. When broad search is needed, state why, bound it to
the active repo and named reference paths, and exclude dependency, build,
cache, and `.git` directories.

## Helper Use

- Ralph may use read-only reviewer or verifier helpers for substantial work.
- Use the tester helper only when explicitly delegating test-layer files,
  fixtures, or test data for creation or update.
- Implementation stays with the main session unless the user explicitly asks
  for implementer delegation.
- Validate all helper findings in the main session before acting on them.

## Output

Report task executed, files changed, verification result, review gate status
and basis, per-finding verdicts, accepted review fixes or rejected findings,
review debt status, drift result, decision ledger updates, context pack status,
artifact changes and persistence status, compaction status, and next task or
stop reason.

Never claim completion without fresh verification output.
