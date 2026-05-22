---
name: ralph-loop
description: Use to run one Ralph iteration or continue a ready project task queue with scoped implementation, verification, drift checks, active work records, and explicit stop conditions.
---

# Ralph Loop

Use this skill after a task is clear or
`projects/<id>/work/task-queue.md` is ready. Ralph Mode executes one scoped
task at a time from the hub while editing only the real project repo.

## Preflight

1. Read `AGENTS.md`, `STATION.md`, and the active project record.
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
4. Run the initial verification appropriate for the slice.
5. Run the Implementation Review Gate when required, expected, or requested.
6. Verify reviewer findings against the code, diff, plan, and logs.
7. Fix valid in-scope issues found by verification or review.
8. Reverify review-driven fixes with the narrowest meaningful command for the
   fixed behavior.
9. Compare the diff against the task, active plan, active spec, and user
   request.
10. Update useful files under `projects/<id>/work/`, especially
   `progress.md`, `verification.md`, and `context-pack.md`.
11. Record material decisions in `projects/<id>/decisions.md`.
12. Continue only if the next task is safe and the user asked for continuation.

## Implementation Review Gate

Use the review gate after a slice is implemented and initially verified, before
marking the slice complete in durable work records.

Review gate selection is based on scope and change impact. Risk tier determines
whether execution needs explicit user approval before Ralph edits.

- Required for `S2` and `S3` slices.
- Required for queued Ralph tasks that touch foundational behavior:
  bootstrap, install, update, registration, generated commands, hooks,
  settings, config, test harnesses, project or hub ownership, security policy,
  or automation policy.
- Expected for meaningful behavior-changing `S1` slices.
- Optional for `S0/L0`, docs-only, or trivial local work.
- If active work records are in use and the gate is skipped, record the skip
  reason in the useful work record update.
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

When the gate runs, spawn the existing read-only reviewer subagent. The
reviewer should inspect the actual changed code or diff and relevant
surrounding code first, using the active spec, plan, task queue, build or test
logs, and known non-goals as supporting context. The reviewer reports
correctness, regression, security, reliability, missing-test, convention, and
drift findings ordered by severity with file and line references when possible.

The main agent stays responsible for the work. Verify each reviewer finding
against the implementation and project context before acting. Apply only valid
in-scope fixes. Turn valid out-of-scope findings into follow-up notes or tasks.
Briefly record rejected false positives when that helps future readers. After
review-driven fixes, run the narrowest meaningful verification for the fixed
behavior; run broader verification only when the fixes touch shared, risky, or
cross-cutting behavior.

If a required review gate cannot run, stop and tell the user what is missing
unless the user explicitly accepts the review debt.

## Compaction Discipline

At each natural stopping point, prepare compact-safe state before continuing or
pausing. Natural stopping points include a completed task, completed slice,
milestone boundary, failed verification stop, blocked task, or transition to a
larger next task.

When active work records are in use:

1. Update `task-queue.md` with the current task status.
2. Update `progress.md` with completed work, blockers, and next action.
3. Update `verification.md` with commands, results, and gaps.
4. Update `context-pack.md` with:
   - last completed task
   - current task status
   - next exact action
   - scope boundary, including in-scope and out-of-scope files or areas
   - files already changed and files to inspect first after compact
   - known reference paths or repos
   - branch, HEAD, and `git status --short` summary
   - verification status
   - review state
   - drift result
   - blockers and risks
   - triggers that justify expanding beyond the task neighborhood
   - stop reason when pausing
5. Update `handoff.md` when pausing, blocked, or handing off.

If the next task is safe and context is not a concern, continue normally. If
context is low, a milestone just finished, or the next slice needs a clean
context, pause after the updates and tell the user the state is compact-ready
and they may run `/compact`.

Ralph prepares for compaction; it does not invoke `/compact` itself.

## Post-Compact Resume

After compact, resume from the designed anchors first:

- `context-pack.md`
- `handoff.md`
- `task-queue.md`
- `active-plan.md`
- `verification.md`
- project `decisions.md`
- branch, HEAD, and `git status --short`

Then rebuild the active task neighborhood before editing. Inspect changed files,
explicitly named files, related tests, configs, docs, generated surfaces, and
known reference paths. Expand beyond that when there is a concrete reason:
handoff mismatch, missing acceptance criteria, failing verification, unclear
coupling, generated parity, security or permissions behavior, or review scope.
When broad search is needed, state why, bound it to the active repo and named
reference paths, and exclude dependency, build, cache, and `.git` directories.

## Subagents

- Ralph may use read-only reviewer or tester subagents for substantial work.
- Implementation stays with the main agent unless the user explicitly asks for
  implementer subagents.
- Verify subagent findings in the main session before acting on them.

## Stop Conditions

Stop and hand control back to the user when:

- the same verification fails twice without meaningful progress
- requirements are ambiguous
- implementation drifts outside the selected task
- an `L2` task lacks explicit approval
- an `L3` action would be required
- tests or builds cannot run and no acceptable fallback exists
- active work records cannot be updated when they are needed for continuation
- the plan appears wrong after repeated implementation attempts

## Output

Report:

- task executed
- files changed
- verification result, including re-verification after review fixes when run
- review gate status: required | expected | optional | skipped
- review gate basis, such as `required: queued foundational tooling`
- accepted review fixes, rejected findings, or `none`
- review debt status: none | open | accepted
- drift result
- decision ledger updates, or `none`
- context pack status
- compaction status: continuing | compact-ready
- next task or stop reason

Do not commit, push, merge, open PRs, delete branches, create worktrees, or run
external automation unless the user explicitly asks.
