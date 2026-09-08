# Piper Station Agent Instructions

This is the central Piper hub for registered projects. Treat it as coordination
context; project source stays in its registered repository or assigned worktrees,
and durable Piper records stay under `projects/<id>/`.

## Entry And Authority

- `STATION.md` owns phase routing, lanes, artifact ownership, related work,
  checkpoints, review and resume. `automation-policy.md` owns action boundaries.
  Read relevant canonical sections before operating a project boundary.
- `brainstorm` is the read-only front door for orientation, framing, investigation,
  and route selection. Explicit registration is its narrow write exception,
  through `./bin/add-project`; registration never creates work records or starts
  source work, installs, commits, or external actions.
- `design-studio` is optional deeper durable design after explicit user choice.
  Each initiative has its own studio lane. Design does not authorize source
  edits, implementation groups, or external action.
- `piper-workflow` verifies converged direction and formalizes an execution
  boundary before Ralph edits. Ordinary brainstorm input is sufficient; a studio
  is not mandatory. A studio handoff requires its exact accepted revision.
- Existing user scope and authorization persist across phases and sessions.
  A request to implement includes required planning; do not ask again just
  because planning ended. A material change to fixed contracts or product intent
  returns upstream. Native sandbox/tool permissions still apply.

## Discover Procedures Progressively

Read `RUNTIMES.md` for the active CLI's skill directory, invocation syntax,
role files, lifecycle support and workspace-access options. Skills and natural
language select the phase; use brainstorm, design-studio or piper-workflow by
name. Codex also accepts `$brainstorm`, `$design-studio` and `$piper-workflow`;
Claude Code and Copilot CLI expose slash skill invocation.

- Brainstorm's registration procedure: `brainstorm/references/add-project.md`.
- Workflow procedures: `piper-workflow/references/superpowers.md`, `ralph.md`,
  and `compact-handoff.md`.
- Related independent sessions or authorized workers: also read
  `piper-workflow/references/coordinated-work.md`.
- Publishing source into base: read `piper-workflow/references/integration.md`.
- `review` owns explicit and implementation review; `automation-policy` owns
  external/exceptional boundary checks.

`PRODUCT.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `TESTING.md`, and `SECURITY.md`
provide supporting context when relevant. Roles and hooks are narrow mechanics;
they do not override canonical policy or user instructions.

## Project And Lane Ownership

Resolve projects from `projects/registry.json` and their canonical `project.md`.
The registry is derived; rebuild it with `./bin/add-project --rebuild` if needed.
Keep stable facts in `memory.md`, significant rationale in optional `decisions.md`,
and standing policy only in `project.md` at the user's word.

STATION defines four lane locators: default `flat`, `studio:<slug>`,
`group:<gid>`, and optional `lane:<slug>` for independent execution. One active
coordinating session owns a lane at a time. Select a clearly requested or already
selected effort without asking about unrelated lanes; ask when the intended
boundary is ambiguous. Design and execution candidates are phase-specific.

The default small fix stays one ungrouped wave with one acceptance entry. A group
is for shared multi-wave acceptance, never forced by concurrency alone. Standard
work windows, resume packet and ledger live with their lane; READMEs remain
navigation and canonical design retains revision/acceptance ownership.

Each source writer needs an exclusive assigned checkout and branch. Inspect open
bindings and worktrees before claiming one. Concurrent implementation workers need
separate worktrees; never assume native subagents receive them automatically.
Verify native writable access, using the active CLI's documented workspace controls (including
`--add-dir <checkout-path>` where supported). Registration and worktree creation do
not grant access. Do not switch branches, merge, or discard in another lane's
checkout. Read-only source observation does not reserve a writable checkout.

## Related Work And Publication

For meaningful dependencies, record canonical artifact/revision references and
assumed contracts. At start/resume, wave formalization, shared-contract change,
and integration, inspect relevant related work for semantic as well as file
conflicts. Record consequential proposals with evidence, impact and a resolution
owner. Continue unaffected work; pause or revalidate affected work. Each lane
reconciles its own current state against the shared decision.

Use `./bin/piper-record` for shared records and lane ownership publication.
Ordinary edits inside a sole-owned lane may use normal file tools. Read current
content/digest, prepare replacement, publish with expected digest, and reconcile
on conflict. Use its path-only commit operation to preserve other sessions'
staged and unstaged work. Never make an unscoped hub commit. Helpers are
cooperative protections, not permission enforcement or a global work manager.
Commit useful completed or paused continuity at checkpoints unless instructed
otherwise; no repeated artifact-commit ask. Report hub and source changes and
actual persistence separately.

Use `./bin/piper-integrate` only after preparing, verifying and reviewing the
exact candidate against an exact base through the integration procedure. The
target must be clean and unoccupied by an open lane. Changed base or candidate
requires renewed verification; a clean merge is not proof of compatible behavior.
Keep acceptance, actual integration, and `pending-pr` state explicit.

## Delegation And Review

Three installed role briefs/configs are available: `investigator` for bounded
questions and options, `implementer` for authorized source or test changes, and
`reviewer` for independent design or implementation challenge. Keep quick
lookups, small understood fixes and known check commands in the parent. Read the active skill's
`piper-workflow/references/coordinated-work.md` when delegating in any phase; reading it does not change phase. Use native
role selection only when the active client's actual spawn tool exposes it. Some
Codex clients expose `collaboration.spawn_agent` without an `agent_type` selector;
do not invent that argument or assume a role TOML was applied. In that case locate
the active runtime's role file through `RUNTIMES.md` and include its behavioral
brief in the explicit assignment using the supported tool parameters.

Implementation and test writing require explicit user delegation; honor existing
scoped grants. Observer assignments preserve source, tracked tests, designs,
records and active runtime configuration. Checks may write declared scratch/build
outputs only within actual permissions and user scope; see the common procedure.
Do not relax permissions to run a check. Verify actual worker permissions from native
metadata or the worker's observed runtime context; when unavailable, report them
as unverified. A read-only instruction is not proof of read-only sandbox enforcement,
and installing or citing a TOML file does not prove its overlay was selected.
Wider inherited capabilities never authorize work outside the assignment.

Workers receive intent, scope, source state, fixed contracts and freedoms,
verification, and return expectations. Writers also need isolated checkout/branch,
owned paths and writable access. Missing ownership or access means report and
edit nothing. Supply absolute hub/record references or extracts: a worker outside
the hub follows its assignment and source instructions without rerunning hub
registration, project selection, phase entry or lane creation.
Workers report actual results and changed
assumptions; the parent owns hub records, shared resolutions, integration, and
acceptance. A short-lived worker does not automatically become a group or lane.

Apply STATION's review gates: required for S2/S3 waves/groups and queued
foundational work; proportional for smaller changes. After the final wave, review
the integrated group result even if every wave passed. Inspect cross-worker
behavior when work was delegated. Self-verify findings as `confirmed-in-scope`,
`confirmed-out-of-scope`, or `false-positive`; repair in-scope findings and reverify.
Do not proceed to dependent acceptance with unresolved required review debt
unless the user explicitly accepts it.

## Resume And Action Boundaries

At resume triggers, rewrite the lane's packet in full from the old packet,
canonical records and actual source, using the fields owned by STATION. Preserve
open questions and related-work impacts. On resume verify current git, accepted
revisions, partial integration/publication, and native worker status before acting.
A saved handle or status note is not proof of liveness or completion; a wait
timeout is not a failed worker. Resolve unknown ownership before starting another
writer. Studios resume design without source edits.

Hooks and the compact prompt supply reminders. They do not make snapshots,
guarantee writes, claim `/compact` ran, or enforce ownership. Complete explicit
checkpoints even if hooks are unavailable.

Routine local work proceeds when reached, including authorized source edits,
checks, scoped commits and safe worktree/integration operations. External actions
(push/PR, dependencies, effects on remote systems) use the normal boundary ask or
an existing exact grant. Exceptional actions (deletion/discard, force push, pushed
history rewriting, secrets, production) need explicit one-off authority. L2 scope
confirmation and review remain separate; existing covered authorization suffices.
Do not widen permissions by rewriting managed config while working on a project.
