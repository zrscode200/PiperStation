# Ralph

Enter Ralph Mode for one scoped task.

The `piper-workflow` skill routes here when the user asks to execute a task,
build a slice, or work through active work. Determine the selected task from
the request context, `active-work.md`, or the optional durable queue.

Ralph is prompt and skill behavior in Codex. It selects one slice, states the
diff boundary, implements that task, verifies, drift-checks, applies the
Implementation Review Gate when required or expected, and updates compact-safe
records when active work records are in use.

Ralph is not a shell runner and not a general planner. Use it after a slice is
clear from the user request, `projects/<project-id>/work/active-work.md`, or
the optional durable `task-queue.md`. Actions that cross the active permission
profile boundary still route through the `automation-policy` skill.

## Steps

1. Read `AGENTS.md` and `STATION.md`. Look up the project in
   `projects/registry.json` to confirm registration and resolve `repo_path`,
   then read the relevant `projects/<project-id>/project.md`, `memory.md`, and
   optional `decisions.md` when it exists.
2. Read relevant files under `projects/<project-id>/work/`, especially
   `active-work.md`, `build-log.md`, `context-pack.md`, and optional
   `task-queue.md`.
3. Select one pending or active task: the task matching the user's request if
   specified, otherwise the next clear slice from `active-work.md`, otherwise
   the top ready task in the optional queue.
4. Confirm the task has acceptance criteria, a verification command or fallback,
   risk tier, and expected diff boundary.
5. Verify the real project repo is writable in the active session. If the repo
   is outside the current Codex sandbox, state that writable access is
   required (e.g. start Codex with `--add-dir <project-repo>`) before
   execution instead of declaring the task Ralph-ready. Confirm the active
   permission profile covers `local` project source edits; if not, route
   through `automation-policy` before editing.
6. State the selected task and expected diff boundary before editing.
7. Mark the task active in `projects/<project-id>/work/task-queue.md` only
   when a durable queue exists.
8. Stop if the task is ambiguous, lacks verification, is `L3`, is outside the
   approved active work, lacks `local` profile coverage for source edits, or is
   `L2` without explicit user confirmation.
9. Implement only the selected task in the real project repo.
10. Run the narrowest meaningful initial verification.
11. Run the Implementation Review Gate based on scope and change impact:
   required for `S2/S3` and queued foundational work, expected for meaningful
   behavior-changing `S1`, optional for `S0/L0`, docs-only, or trivial work.
   Risk tier controls Ralph implementation confirmation before editing, not
   review selection or permission profile.
12. Validate reviewer findings before editing: give each finding an explicit
    verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or
    `false-positive` — and do not edit code until every finding has one. Then
    apply fixes only for `confirmed-in-scope` findings, turn
    `confirmed-out-of-scope` findings into follow-up notes or queue items, and
    reverify review-driven fixes with the narrowest meaningful command for the
    fixed behavior. Run broader verification only when fixes touch shared,
    risky, or cross-cutting behavior.
13. Drift-check the diff against the selected task, active work, and user
    request.
14. For ordinary slice-end bookkeeping, append `build-log.md` at checkpoint
    cadence with changed source areas, verification result, review result,
    drift, risks, and next step. Update `task-queue.md` status only when a
    durable queue is in use. Update `active-work.md` only when requirements,
    approach, slices, or verification strategy materially changed.
15. Report changed Piper artifacts separately from registered project source
    changes. At ordinary slice boundaries, do not ask to commit artifact
    updates or update `context-pack.md` unless this slice completes a
    milestone, materially changes active work, hits a blocker, leaves
    context low, or the user is about to pause, compact, switch projects, or
    finish.
16. Record project policy preferences in `project.md`, and use optional
    `decisions.md` only for substantial decision logs.
17. If a required or expected review gate was skipped, record review debt and do
    not continue to a dependent task until it is resolved or explicitly
    accepted by the user.
18. Prepare compact-safe state at natural stopping points.
19. Continue only if the next task is safe and the user asked for continuation.

Do not commit, push, open PRs, create or switch worktrees, install dependencies,
or run external automation unless the selected workflow reached that action and
the active permission profile allows it. Delete, force-push, rewrite history,
deploy to production, or take other exceptional actions only after explicit
one-off approval through `automation-policy`. Ralph prepares for compaction; it
does not invoke `/compact` itself.

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
the selected task, an `L2` task lacks confirmation, `L3` implementation risk
would be required, the next action crosses the active permission profile
boundary without sufficient profile coverage, tests or builds cannot run and
no fallback exists, active work records cannot be updated when needed for
continuation, a required review gate cannot run, or the plan appears wrong
after repeated implementation attempts.

## Review Gate Details

Use the review gate after a slice is implemented and initially verified, before
marking the slice complete in durable work records.

Review gate examples:

- `S0/L0` typo fix or docs wording tweak: gate optional.
- Meaningful `S1` behavior change: gate expected.
- Queued bootstrap, registration, hook/config, or test-harness slice: gate
  required.
- Dependency install, network, pull request, CI, or other external action:
  route the action through `automation-policy`; choose the gate from scope and
  impact.

When the gate runs, spawn the `reviewer` subagent (declared in
`.codex/config.toml`). The reviewer inspects the actual changed code or diff
and relevant surrounding code first, using the active work record, build log,
optional task queue, test output, and known non-goals as supporting context.
The reviewer reports correctness, regression, security, reliability,
missing-test, convention, and drift findings ordered by severity with file and
line references when possible.

The main Codex session stays responsible for the work. Validate each reviewer
finding before acting: record a one-line verdict per finding —
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

1. Append `build-log.md` with the current checkpoint, including commands,
   results, review state, drift, risks, and next step.
2. Update `task-queue.md` with the current task status only when a durable
   queue exists.
3. Update `context-pack.md` only when pausing, preparing for compact, finishing,
   blocked, crossing a milestone, context is low, switching projects, or
   materially changing active work. When updated, include last completed
   task, current task status, next exact action, scope boundary, files changed,
   files to inspect first after compact, known reference paths, branch, HEAD,
   `git status --short`, verification status, review state, drift result,
   blockers, risks, broad search triggers, stop reason, and what to hand a
   human or fresh agent.
4. Report artifact files updated in the Piper Station hub and whether they are
   committed. If the stop is a milestone boundary, compact preparation, finish
   mode, project switch, or material active-work change, ask once whether to
   commit the Piper artifact updates; route through `automation-policy` if the
   active profile does not cover local git.

If the next task is safe and context is not a concern, continue normally. If
context is low, a milestone just finished, or the next slice needs a clean
context, pause after updates and tell the user the state is compact-ready and
they may run `/compact`.

## Post-Compact Resume

After compact, resume from designed anchors first:

- `context-pack.md`
- `active-work.md`
- `build-log.md`
- optional `task-queue.md`
- `roadmap.md` when long-horizon direction matters
- project `project.md` and `memory.md`
- optional `decisions.md` when present
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

- Ralph may spawn the `reviewer`, `tester`, `security_reviewer`,
  `verifier`, `security_reviewer`, `docs_researcher`, or `architect` subagents
  for substantial work. `verifier`, `reviewer`, `security_reviewer`,
  `docs_researcher`, and `architect` are read-only roles defined in
  `.codex/agents/`; use `tester` only when explicitly delegating test-layer
  file, fixture, or test-data edits.
- Implementation stays with the main session unless the user explicitly asks
  for `implementer` delegation.
- Validate all helper findings in the main session before acting on them.

## Output

Report task executed, files changed, verification result, review gate status
and basis, per-finding verdicts, accepted review fixes or rejected findings,
review debt status, drift result, durable record updates, context pack status,
artifact changes and persistence status, compaction status, and next task or
stop reason.

Never claim completion without fresh verification output.
