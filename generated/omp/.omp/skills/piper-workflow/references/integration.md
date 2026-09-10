# Verified Integration

Use when publishing a lane or coordinated worker result into a project base
branch. Worker-to-candidate assembly occurs in an exclusively owned candidate
checkout first; this procedure publishes the verified result into a clean idle
base checkout. The parent owns integration and the acceptance verdict.

1. Identify the base branch and full current base commit. Select a clean target
   checkout already on that branch, belonging to the registered project and
   unreserved by an open execution lane. Inspect flat, group, and named-lane
   bindings plus `git worktree list`. Never switch, merge, or clear another
   lane's checkout. A paused lane still owns its recorded checkout. If the base
   is occupied, sequence integration or have its owner safely finish or relocate
   its work and reconcile its binding first; do not mark active work closed just
   to bypass occupancy.
2. In an exclusively assigned candidate checkout, incorporate the latest base
   and intended lane/worker commits. Resolve mechanical conflicts within scope;
   reopen fixed-contract or product-intent decisions upstream. Do not discard
   user-owned changes or rewrite pushed history.
3. Reconcile related contracts and acceptance criteria against the candidate.
   Run focused component checks and meaningful combined-behavior checks. Perform
   the applicable read-only review over the complete candidate diff from the
   exact base, including cross-wave or cross-worker interactions. Self-verify
   each finding and repair confirmed in-scope issues before acceptance. A clean
   Git merge and worker success messages are insufficient.
4. Commit the complete candidate on its assigned branch and finish verification
   and review of that exact source state. Require clean candidate and target
   checkouts. Keep the full tested base and verified candidate object IDs with
   this integration evidence; these are evidence identities, not cached current
   HEAD values. If source changed after a check, repeat affected checks before
   publication.
5. Publish with the narrow helper from the hub:

   ```sh
   ./bin/piper-integrate --project projects/<id> --target-checkout <base-checkout> --base <branch> --expected-base <full-base-oid> --verified-checkout <candidate-checkout> --verified-head <full-candidate-oid>
   ```

   The helper locks repository publication then shared hub records, so ownership
   updates through `piper-record` wait through final validation and publication.
   It checks repo identity and rejects source checkouts inside the hub, then checks
   clean/idle target ownership and unchanged base/candidate, and fast-forwards
   base to the verified descendant. It does not run tests, decide acceptance,
   switch branches, force refs, or repair conflicts. Native permissions still
   apply, and direct Git or file edits can bypass this cooperation.
6. If base or candidate changed, inspect current state, incorporate the new base,
   and reverify/review the affected combination before retrying with new evidence.
   Do not simply replace expected IDs to silence the guard. If publication was
   interrupted, inspect refs and both checkouts before retrying; determine whether
   publication occurred and reconcile any partial state without destructive repair.
   A helper attention result (exit 3) explicitly requires this inspection; never
   retry it blindly. Native Git hooks remain active and can affect the result.
7. Verify the actual result and publish the closeout through `piper-record`.
   Record acceptance, verification/review, tested base, candidate, integration
   result, and any deferred scope once in the owning ledger. Reconcile project
   ledger/roadmap and close lane windows as required by STATION. Source publication
   plus missing records is incomplete closeout, not a reason to integrate twice.

If project policy requires a PR, prepare the same verified candidate but do not
invoke local publication. Record `integrated: pending-pr` and retain the checkout.
Push/PR actions require the normal external go-ahead. Acceptance of a verified
candidate and actual integration are distinct facts; never report pending work
as merged. Deleting worktrees remains exceptional.
