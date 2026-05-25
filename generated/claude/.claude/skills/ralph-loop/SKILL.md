---
name: ralph-loop
description: Use only after Ralph Mode is selected to execute one clear scoped task from a plan or task queue with verification, drift checks, review gate, and compact-safe updates.
---

# Ralph Loop

Ralph is prompt and skill behavior in Claude Code. It is not a shell
runner and not the initial router. Use this skill only after the user or
`/work-on` has selected Ralph Mode and a task is clear or
`projects/<id>/work/task-queue.md` is ready.

Do not use this skill for discovery, broad planning, general review, or
automation approval. Route those through the dispatch contract in `STATION.md`.

## Preflight

1. Read `CLAUDE.md`, `STATION.md`, and the active project record:
   `project.md`, `memory.md`, and `decisions.md`.
2. Read relevant files under `projects/<id>/work/` when present.
3. Select one task and confirm it has:
   - status `pending` or `active`
   - risk `L0` or `L1`, or explicit user approval for `L2`
   - acceptance criteria
   - verification command or documented fallback
   - expected diff boundary
4. Stop if the next task is `L3`, ambiguous, missing verification, or outside
   the approved spec or plan.

## One Iteration

1. State the selected task and expected diff boundary.
2. Mark the task active in `projects/<id>/work/task-queue.md` when a queue
   exists.
3. Implement only that task in the real project repo.
4. Run the narrowest meaningful initial verification.
5. Run the Implementation Review Gate when required, expected, or requested.
6. Verify reviewer findings against the code, diff, plan, and logs.
7. Fix valid in-scope issues found by verification or review.
8. Reverify review-driven fixes with the narrowest meaningful command for the
   fixed behavior. Run broader verification only when fixes touch shared,
   risky, or cross-cutting behavior.
9. Drift check the diff against the task, active plan, active spec, and user
   request:
   - None: actual changes are a subset of expected.
   - Expected expansion: required touching files outside the task list but
     clearly in scope; record the file and reason.
   - Out-of-scope work: changes include behavior the task did not ask for; stop
     and split or revert that work.
   - Wrong scope: actual changes do not satisfy the task; stop and ask.
10. Update useful files under `projects/<id>/work/`, especially `progress.md`,
    `verification.md`, and `context-pack.md`.
11. Record material decisions in `projects/<id>/decisions.md`.
12. Continue only if the next task is safe and the user asked for continuation.

## Implementation Review Gate

Use the review gate after a slice is implemented and initially verified, before
marking the slice complete in durable work records.

Review gate selection is based on scope and change impact. Risk tier controls
whether execution needs explicit user approval before Ralph edits.

- Required for `S2` and `S3` slices.
- Required for queued Ralph tasks that touch foundational behavior: bootstrap,
  install, update, registration, generated commands, hooks, settings, config,
  test harnesses, project or hub ownership, security policy, or automation
  policy.
- Expected for meaningful behavior-changing `S1` slices.
- Optional for `S0/L0`, docs-only, or trivial local work.
- If active work records are in use and the gate is skipped, record the skip
  reason in the work record update.
- If a required or expected gate is skipped, record review debt in
  `progress.md`, `verification.md`, and `context-pack.md`. Do not continue to a
  dependent task until the debt is resolved or the user explicitly accepts it.

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

The main Claude Code session stays responsible for the work. Verify each
reviewer finding before acting. Apply only valid in-scope fixes. Turn valid
out-of-scope findings into follow-up notes or tasks. Briefly record rejected
false positives when that helps future readers. After review-driven fixes, run
the narrowest meaningful verification for the fixed behavior.

If a required review gate cannot run, stop and tell the user what is missing
unless the user explicitly accepts the review debt.

## Compaction Discipline

At each natural stopping point, prepare compact-safe state before continuing or
pausing. Natural stopping points include a completed task or slice, a milestone
boundary, a failed verification stop, a blocked task, or transition to a larger
next task.

When active work records are in use:

1. Update `task-queue.md` with the current task status.
2. Update `progress.md` with completed work, blockers, and next action.
3. Update `verification.md` with commands, results, and gaps.
4. Update `context-pack.md` with last completed task, current task status, next
   exact action, scope boundary, files changed, files to inspect first after
   compact, known reference paths, branch, HEAD, `git status --short`,
   verification status, review state, drift result, blockers, risks, broad
   search triggers, and stop reason when pausing.
5. Update `handoff.md` when pausing, blocked, or handing off.

If the next task is safe and context is not a concern, continue normally. If
context is low, a milestone just finished, or the next slice needs a clean
context, pause after updates and tell the user the state is compact-ready and
they may run `/compact`.

Ralph prepares for compaction; it does not invoke `/compact` itself.

## Post-Compact Resume

After compact, resume from designed anchors first:

- `context-pack.md`
- `handoff.md`
- `task-queue.md`
- `active-plan.md`
- `verification.md`
- project `decisions.md`
- branch, HEAD, and `git status --short`

Then rebuild the active task neighborhood before editing. Inspect changed
files, explicitly named files, related tests, configs, docs, generated
surfaces, and known reference paths. Expand beyond that when there is a
concrete reason: handoff mismatch, missing acceptance criteria, failing
verification, unclear coupling, generated parity, security or permissions
behavior, or review scope. When broad search is needed, state why, bound it to
the active repo and named reference paths, and exclude dependency, build,
cache, and `.git` directories.

## Subagents

- Ralph may use read-only reviewer or tester helpers for substantial work.
- Implementation stays with the main session unless the user explicitly asks
  for implementer delegation.
- Verify all helper findings in the main session before acting on them.

## Stop Conditions

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

Never claim completion without fresh verification output. Do not commit, push,
merge, open PRs, delete branches, create worktrees, or run external automation
unless the user explicitly asks.
