# Automation Policy

Default stance: action classes decide whether an action needs an ask, and
an ask is a gate, not a trigger — the workflow still has to reach the action.
Action classes do not change Piper Station's phase routing, artifact
checkpoints, Ralph review gates, or when a workflow should perform an action.

This file is the canonical global policy. Project-specific standing policy
notes belong in `projects/<project-id>/project.md`. Change this root policy
only for global shared rules that should apply across the hub.

## Action Boundaries

- **Routine** — no ask, no record. Reading and inspection; planning, review,
  and drafting; deterministic registration; registered project source edits
  in the lane's checkout; local checks, builds, and tests; Piper artifact
  updates and their path-scoped hub commits; non-destructive local git such as
  add or commit on the lane's branch; worktree creation or switching; rebasing
  an unpushed lane branch; the local merge into base at group closeout;
  read-only network reads such as documentation lookups. Routine actions
  proceed when the workflow reaches them; Piper never simulates a gate for
  them.
- `external` — ask once at the boundary where the workflow reaches it.
  Anything that changes an external system, a remote, or the dependency tree:
  push, pull request creation or update, dependency install or update,
  networked commands with effects, CI reruns or repair, and other
  non-destructive external-system actions.
- `exceptional` — a fresh explicit one-off instruction every time, restated
  before execution: force push, rewriting pushed history, deleting branches,
  worktrees, or user data, discarding changes the current boundary did not
  make (`reset --hard`, `checkout --`, `clean`), secret handling, production
  deploys, and irreversible external actions.
  `exceptional` actions can never be pre-approved.

A broad request like "finish this", "ship it", or "wrap up" is never a go-ahead
for a push, merge to a remote, pull request, dependency install, discard, or
external automation.

Routine does not waive Ralph's `L2` confirmation, Wave Formalization, or a
required review gate; those are implementation caution under `STATION.md` →
Mode Routing, not action classes. A class says whether an action needs an
ask; the phase says whether the action is reached at all: brainstorm and
Design Studio never reach source edits, Superpowers stops before
implementation, and Ralph reaches only the selected boundary.

## Asks And Records

An `external` ask names the action, the target (remote and branch, pull
request, dependency, or network destination), the risk, and the rollback or
recovery path, then waits. One go-ahead covers repeats of the same action to
the same target within the same boundary; a new target or a new boundary asks
again. A user instruction that already names the action and target is itself
the go-ahead: restate target, risk, and rollback in one line and proceed.

The go-ahead and the action are recorded in the lane's `build-log.md`, in the
next entry the lane writes (acceptance, blocker, compact, or finish) — the
record may follow the action but never skips a boundary. A group push or pull
request lands in the closeout entry next to `integrated:`. An `external`
action outside any open wave writes a one-line finish entry in the project
`build-log.md` (created if absent) naming the action, target, and go-ahead
source. Approvals are never recorded in `project.md`. Pushes of the hub
repository itself are go-ahead-in-chat only.

## Standing Policy Notes

`projects/<project-id>/project.md` may hold standing policy notes, each one
line, dated, written verbatim from the user's words, and revoked by deleting
the line. Only the user creates one, by saying so; never infer a standing
policy note from a one-off go-ahead. Four kinds:

- a read-only note ("do not edit source in this project"): attempt no writes
  and report what you would change;
- a standing grant for a named `external` class with a target ("pushes to
  `origin/main` are pre-approved"); a grant without a target is a note, not a
  grant. A standing grant removes the ask, not the step: the workflow still
  has to reach the action, and "finish this" still ends at Finish Mode's
  report and options;
- a closeout constraint ("no local merge to base; integrate via pull
  request"), the trigger for `integrated: pending-pr` at group closeout;
- accepted risks or scoped gate waivers ("L2 confirmations pre-approved for
  group G1").

A legacy profile-preference line written by the older registration template
carries no standing policy: "strict" is not a read-only note, and "local" or
"external" is not a grant. Leave such lines in place and ignore them.

## Enforcement

Enforcement belongs to the active harness's own permission system — session
permission modes and allowlists, sandbox and approval policy, permission
config, or manual approval — where it has a gate. Where the user has disabled
that gate (headless, YOLO, or bypass modes, or an approval policy of never),
the Piper asks above are the only gate, so gate-free execution never widens
the action classes. If the harness blocks a routine action, state what access
is needed and wait; do not edit bootstrap-managed runtime config files and do
not add hooks as a Piper gate.

Ralph implementation edits are routine. Committing Piper artifact updates in
the Piper Station hub is routine and stays separate from any registered
project source commit. Hub artifact commits are path-scoped: the hub checkout
is shared by every session, so stage only the lane's paths plus the
project-level files touched — never `git add -A` or `commit -a` in the hub.

Non-destructive worktree creation or switching is routine, including creating
a group lane's worktree at group Entry; deleting worktrees is `exceptional`.
