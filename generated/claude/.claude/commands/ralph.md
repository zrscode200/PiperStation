---
description: Enter Ralph Mode for the current wave, explicit slice, or queued task
argument-hint: "<project-id> [<gid> | boundary id or description]"
---

# Ralph

Enter Ralph Mode for one scoped wave, explicit slice, or queued task.

The user invoked this command with: `$ARGUMENTS`

Ralph is prompt and command behavior in Claude Code. It selects the current
execution boundary, states the diff boundary, implements it, verifies,
drift-checks, applies the Implementation Review Gate when required or expected,
and updates compact-safe records when active work records are in use.

Ralph is not a shell runner and not a general planner. Use it after a wave,
explicit slice, or queued task is clear from the user request, the selected
lane's `active-work.md`, or its optional durable `task-queue.md` (lanes are
defined in `STATION.md` → Project Records). If the selected wave is still a
sketch, Ralph formalizes it
first through the Wave Formalization pass in `/superpowers`; open-ended
planning stays out of scope. Slices are decomposition units; waves are
execution and checkpoint units. Natural-language routing can choose this
behavior through `piper-workflow`; actions that cross the active permission
profile boundary still route through `automation-policy`.

## Steps

1. Read `CLAUDE.md` and `STATION.md`. Look up the project in
   `projects/registry.json` to confirm registration and resolve `repo_path`,
   then read the relevant `projects/<project-id>/project.md`, `memory.md`, and
   optional `decisions.md` when it exists.
2. Select the lane first (`STATION.md` → Group Lifecycle → Lane selection): a
   token naming an existing `work/groups/<gid>` folder selects that group
   lane; with no token, exactly one active candidate selects itself, more than
   one means ask, never guess, and none means the flat lane. Then read the
   lane's files — `active-work.md`, `build-log.md`, `context-pack.md`, and
   optional `task-queue.md` — under `projects/<project-id>/work/` for the flat
   lane or `projects/<project-id>/work/groups/<gid>/` for a group lane, plus
   `roadmap.md` when group order matters.
3. Select one execution boundary: the wave, group review, explicit slice, or
   task matching `$ARGUMENTS` if specified, inside the selected lane;
   otherwise the current boundary from the lane's `active-work.md` or
   `context-pack.md`; otherwise the top ready item in the lane's optional
   queue. If the final wave in a group has landed and the group review
   is pending, select the group review before any acceptance task. Once a
   group's closeout completes, the next boundary is the next group's Entry:
   re-verify its sketch per the Group Lifecycle before selecting its first wave.
4. Confirm the boundary has acceptance criteria, a verification command or
   fallback, risk tier, and expected diff boundary. For implementation
   boundaries, confirm enough slice breakdown to execute safely. For group
   review boundaries, confirm the wave list, integrated diff scope, acceptance
   target, and current group review state. If the selected implementation wave
   is still a sketch — missing acceptance criteria, verification, or an
   expected diff boundary — run the Wave Formalization pass from `/superpowers`
   to formalize it, then continue. A sketched current wave is a formalization
   input, not a stop, and later waves being sketches is
   never a reason to down-scope the selected work.
5. Verify the lane's checkout — `repo_path` or the lane's recorded worktree —
   is writable in the active session; if an active group header binds
   `repo_path`, the flat lane has no checkout of its own (surface per
   `STATION.md` → One checkout per lane). If it is outside the current workspace
   or sandbox, state that writable access is required before execution instead
   of declaring the task Ralph-ready. Confirm
   the active permission profile covers `local` project source edits; if not,
   route through `automation-policy` before editing.
6. State the selected wave, group review, explicit slice, or queued task and
   its expected diff boundary before editing.
7. Mark the boundary active in the lane's `task-queue.md` only when a durable
   queue exists.
8. Stop if the boundary is ambiguous, still lacks verification after Wave
   Formalization, is `L3`, is outside the approved active work,
   lacks `local` profile coverage for source edits, or is `L2` without
   explicit user confirmation.
9. Implement only the selected boundary in the lane's checkout. Within a
   wave, use slices to organize the work; do not turn each internal slice into a
   mandatory stop unless risk, verification, or drift requires it.
10. Run the narrowest meaningful initial verification.
11. Run the Implementation Review Gate based on boundary, scope, and change
   impact: required for `S2/S3` wave or group boundaries and queued
   foundational work, expected for meaningful behavior-changing `S1`, optional
   for `S0/L0`, docs-only, or trivial work. Risk tier controls Ralph
   implementation confirmation before editing, not review selection or
   permission profile. After the final wave in a group lands, sync the group
   branch with base and re-verify, then run a
   group-level review gate over the integrated diff before the slice, group, or
   acceptance task is marked complete, even if every per-wave gate already
   passed. Per-wave gates inspect one wave; the group gate inspects cross-wave
   interactions over `base..group` in the lane's checkout. When the group gate
   passes, complete closeout in the order `STATION.md` → Group Lifecycle
   defines: integrate the group branch into base (or record
   `integrated: pending-pr`), write the group-closeout entry in the project
   `build-log.md`, mark the acceptance target met and tick the group in
   `roadmap.md`, capture contracts later groups depend on, and roll the
   group off the windows — condense the group ledger into that closeout entry
   and rewrite the lane's `active-work.md`, `context-pack.md`, and
   `task-queue.md` to a short `closed` pointer.
12. Validate reviewer findings before editing: give each finding an explicit
    verdict — `confirmed-in-scope`, `confirmed-out-of-scope`, or
    `false-positive` — and do not edit code until every finding has one. Then
    apply fixes only for `confirmed-in-scope` findings, turn
    `confirmed-out-of-scope` findings into follow-up notes or queue items, and
    reverify review-driven fixes with the narrowest meaningful command for the
    fixed behavior. Run broader verification only when fixes touch shared,
    risky, or cross-cutting behavior.
13. Drift-check the diff against the selected boundary, active work, and user
    request. Once the drift-check passes, commit the wave's project source on
    the lane's branch when the active profile covers `local` — commit and report, without a per-wave
    confirmation, separate from any Piper artifact commit; route through
    `automation-policy` when `local` coverage is absent; never commit mid-slice;
    and do not push or open PRs. At group closeout, commit any remaining group
    source.
14. For boundary bookkeeping, append the lane's `build-log.md` at checkpoint
    cadence with
    changed source areas, verification result, review result, drift, risks, and
    next step. Update `task-queue.md` status only when a durable queue is in
    use, including explicit group review gate status for multi-wave groups.
    Update `active-work.md` only when the group boundary, current wave, slice
    breakdown, requirements, approach, verification strategy, or group review
    state materially changed.
15. Satisfy the checkpoint invariant (`STATION.md` → Artifact Persistence) at
    each boundary trigger and nothing more: report changed Piper artifacts
    separately from registered project source changes with their hub commit
    state. During internal slice progress, do not ask to commit artifact
    updates or update `context-pack.md`. An ungrouped wave pays the
    light boundary only.
16. Record project policy preferences in `project.md`, and use optional
    `decisions.md` only for substantial decision logs.
17. If a required or expected review gate was skipped, record review debt and do
    not continue to a dependent task until it is resolved or explicitly
    accepted by the user.
18. Prepare compact-safe state at the resume triggers (`STATION.md` →
    Artifact Persistence → Boundary triggers).
19. Continue only if the next boundary is safe and the user asked for
    continuation.

Do not commit, push, open PRs, create or switch worktrees, install dependencies,
or run external automation unless the selected workflow has reached that action
and the active permission profile allows it. Delete, force-push, rewrite
history, deploy to production, or take other exceptional actions only after
explicit one-off approval through `automation-policy`. Ralph prepares for
compaction; it does not invoke `/compact` itself.

## Drift And Stop Conditions

Drift-check the actual diff:

- None: actual changes are a subset of expected.
- Expected expansion: required touching files outside the selected boundary but
  still clearly in scope; record the file and reason.
- Out-of-scope work: changes include behavior outside the selected boundary;
  stop and split or revert that work.
- Wrong scope: actual changes do not satisfy the task; stop and ask.

Stop and hand control back when the same verification fails twice without
meaningful progress, requirements are ambiguous, implementation drifts outside
the selected boundary, an `L2` boundary lacks confirmation, `L3`
implementation risk would be required, the next action crosses the active
permission profile
boundary, tests or builds cannot run and no fallback exists, active work
records cannot be updated when needed for continuation, a required review gate
cannot run, or the plan appears wrong after repeated implementation attempts.

## Review Gate Details

Use the review gate after the selected boundary is implemented and initially
verified, before marking it complete in durable work records.

For groups, run a separate gate after the final wave lands and before the
group or slice acceptance task. The reviewer must inspect the integrated
cross-wave diff and the interactions between waves, not only the last wave's
diff.

Review gate examples:

- `S0/L0` typo fix or docs wording tweak: gate optional.
- Meaningful `S1` behavior-changing wave or explicit slice: gate expected.
- Queued bootstrap, registration, hook/config, or test-harness wave or task:
  gate required.
- Dependency install, network, pull request, CI, or other external action:
  route the action through `automation-policy`; choose the review gate from
  scope and impact.

When the gate runs, use the read-only reviewer agent. The reviewer inspects the actual
changed code or diff and relevant surrounding code first, using the active
work record, build log, optional task queue, test output, and known non-goals
as supporting context. The reviewer reports correctness, regression, security,
reliability, missing-test, convention, and drift findings ordered by severity
with file and line references when possible.

The main Claude Code session stays responsible for the work. Validate each
reviewer finding before acting: record a one-line verdict per finding —
`confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive` — before
editing any code. Apply fixes only for `confirmed-in-scope` findings. Turn
`confirmed-out-of-scope` findings into follow-up notes or tasks. Briefly record
why a finding was rejected as a `false-positive` when that helps future readers.
If a required review gate cannot run, stop and tell the user what is missing
unless the user explicitly accepts the review debt.

## Compaction Discipline

At each boundary trigger (`STATION.md` → Artifact Persistence), prepare
compact-safe state before continuing or pausing. Natural stopping points include a completed wave, group closeout,
queued task, milestone boundary, failed verification stop, blocked task, or
transition to a larger next boundary.

When active work records are in use:

1. Append `build-log.md` with the current checkpoint, including commands,
   results, review state, group-level review state when relevant, drift, risks,
   and next step.
2. Update `task-queue.md` with the current boundary status only when a durable
   queue exists.
3. Rewrite `context-pack.md` in full only when a resume trigger fires
   (`STATION.md` → Artifact Persistence → Boundary triggers) — regenerate the
   whole packet to reflect
   only the current boundary rather than section-editing it, but first read the
   existing packet and reconcile against it and live git so the rewrite drops
   nothing still relevant. The packet holds only the non-derivable fields
   defined once in `STATION.md` → Compaction; derive branch, HEAD, status,
   changed files, and what to inspect first from live git and the build-log at
   resume rather than writing them into the packet.
4. Report artifact files updated in the Piper Station hub and whether they are
   committed. If the stop is a resume trigger, ask once whether to commit the
   Piper artifact updates (path-scoped to the lane); route through `automation-policy` if the
   active permission profile does not already cover local git actions.

If the next boundary is safe and context is not a concern, continue normally. If
context is low, a milestone just finished, or the next wave needs a clean
context, pause after updates and tell the user the state is compact-ready and
they may run `/compact`.

## Post-Compact Resume

After compact, resume from designed anchors first:

- the selected lane's `context-pack.md`, `active-work.md`, `build-log.md`, and
  optional `task-queue.md` (`work/` for the flat lane, `work/groups/<gid>/`
  for a group lane)
- `roadmap.md` when long-horizon direction matters
- project `project.md` and `memory.md`
- optional `decisions.md` when present
- branch, HEAD, and `git status --short` in the lane's checkout

Then rebuild the active boundary neighborhood before editing. Inspect changed
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

Report boundary executed, files changed, verification result, review gate
status and basis, per-finding verdicts, accepted review fixes or rejected
findings, review debt status, drift result, durable record updates, context pack
status, artifact changes and persistence status, compaction status, and next
boundary or stop reason.

Never claim completion without fresh verification output.
