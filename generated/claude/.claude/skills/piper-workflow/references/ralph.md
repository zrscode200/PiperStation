# Ralph

Execute one clear wave, explicit slice, or queued task in the selected execution
lane. Ralph is agent prompt behavior, not a shell workflow engine. Read
`STATION.md` for canonical lane, risk, review, and checkpoint contracts.

## Execute The Boundary

1. Resolve the registered project and read binding, memory, relevant decisions,
   and the selected lane's existing records. Select via STATION → Lanes; retain
   a clearly selected effort, ask on real ambiguity, and never select a studio
   as an execution lane. Read roadmap when group order matters.
2. Select the requested boundary or current ready wave. A pending group review
   precedes group acceptance. If the current wave is only a sketch, run Wave
   Formalization in `references/superpowers.md`, then continue; later sketches
   do not shrink the current assignment.
3. Confirm acceptance, expected diff boundary, verification command or meaningful
   fallback, risk, and necessary slice breakdown. Check exact accepted design
   revisions, explicitly adopted details and relevant later evidence or
   related-work impacts. Check later adopted-content edits against the ordinary
   acceptance checkpoint; an unchanged overview revision is insufficient.
   A stale fixed contract blocks dependent execution until revalidated;
   unaffected work can proceed.
4. Verify repo identity, assigned branch, exclusive checkout ownership, actual
   git state, and native writable access. Preserve unrelated changes. Creating
   a lane or worktree does not grant sandbox access. Never edit another lane's
   checkout or use the inherited cwd as an unverified fallback.
5. State the boundary and scope. L2 needs explicit authorization for that risk
   boundary; existing covered authorization or a scoped waiver suffices. Stop
   for L3, unresolved scope/acceptance, missing access, or an external/exceptional
   action without its required go-ahead.
6. Implement the boundary, organizing internal slices without mandatory stops.
   Use `references/coordinated-work.md` if implementation delegation is explicitly
   authorized or independent efforts share relevant behavior. Native workers
   have isolated checkouts and bounded ownership; the parent owns integration.
7. Run meaningful initial verification. Drift-check actual changes against the
   request and scope. Required in-scope expansion is explained and reverified;
   out-of-scope changes are isolated for decision without discarding user work.
8. Apply the review gate below. Give every finding a verdict before review fixes:
   `confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive`. Repair
   confirmed in-scope findings; record follow-up scope and rejected findings
   with reasons. Reverify fixes proportionally to their behavior and risk.
9. Commit a completed wave's source on its assigned branch when verification,
   drift, and review hold. This is routine and separate from hub commits; do not
   commit mid-slice or push without external authority. Worker reports and clean
   merges alone never establish acceptance.
10. For group closeout or another lane's publication into base, read and follow
    `references/integration.md`. Prepare and verify a complete candidate against
    an exact base, then use guarded publication into a clean idle target.
    Revalidation is required if base or candidate moves. Never merge into
    another open lane's checkout. Preserve explicit `pending-pr` state where
    user policy forbids local integration.
11. Publish the lane checkpoint and needed shared closeout records through
    `piper-record`. Record outcome, acceptance source commit, actual verification
    and review, drift, resolved/shared contracts, residual risk, and next step
    once in the ledger. Update active work only when its current boundary changes,
    and a queue only when one is in use. Follow the light boundary for small work.
    Fully completed flat work closes any existing active-work ownership binding
    with `status: closed` and an acceptance-ledger pointer; its packet may be idle.
    Do not create active work merely to close it. Paused or blocked work retains
    checkout ownership rather than falsely closing an unfinished boundary.
12. At resume triggers prepare compact-safe state with
    `references/compact-handoff.md`. Report source and hub artifact changes and
    actual commit/integration state separately. Continue through the next safe
    boundary when the user's goal already authorizes it, retaining all gates.

## Review Gate

Run known verification commands directly. Delegate a bounded failure analysis
or independent test-design question when separate reasoning helps; a long test
command alone does not require an LLM worker. Test-writing workers use the
implementer role with explicitly authorized test-only ownership.

Required for S2/S3 waves/groups and queued foundational changes: bootstrap,
installation/update, registration, generated commands, hooks/settings/config,
test harnesses, ownership, security or automation policy. Expected for meaningful
S1 behavior changes; optional for S0/L0, docs-only, or trivial changes. Risk tier
controls editing caution, not review selection.

Use a reviewer instructed to perform read-only work on actual changed code and
surrounding behavior, with active work, design contracts, ledger, tests, and
non-goals as context. Follow `references/coordinated-work.md` → Native Roles And
Actual Permissions: use a native role selector only when exposed; otherwise pass
the installed reviewer's behavioral brief explicitly. Verify/report actual worker
permissions, and never equate a read-only prompt with sandbox enforcement. The
same procedure's Source-Preserving Verification section governs permitted
scratch/build output and unavailable checks; never widen a reviewer's permissions
or change source/snapshots to make a check pass. Distinguish independently run
checks from supplied parent evidence. The
parent self-verifies findings. A group requires integrated cross-wave review after its
final wave, even when each individual wave passed. Coordinated workers also need
verification of their combined behavior; inspect interactions and changed shared
assumptions, not only worker-local diffs.

A skipped required/expected gate is review debt. Do not proceed to dependent
acceptance until the gate runs or the user explicitly accepts the debt. A helper
that cannot run a check honestly reports the limitation; it never substitutes
invented output or weakened acceptance.

## Stops And Recovery

Stop the affected boundary when repeated attempts produce no meaningful progress,
the plan's premise fails, scope is wrong, no meaningful verification is available,
or required records/review cannot be completed. Continue independent useful work
within the authorized goal. Replan when the problem can be resolved downstream;
return upstream when it changes a fixed contract or product intent.

At pause/resume, recover from actual lane records, git, current contract revisions,
and native task status. Do not start duplicate workers after a wait timeout or
repeat source publication solely because closeout records are incomplete.

Report the executed boundary, meaningful results and limitations, review and drift
verdicts, source/hub persistence, integration state, and next action. Never claim
completion without fresh verification evidence.
