# Coordinated Work

Read for related independent sessions or authorized delegation. Ordinary
single-session fixes do not need worker plans or relationship registers.
`STATION.md` owns lanes, related-work semantics, and shared publication.

## Native Roles And Actual Permissions

Inspect the active spawn tool's supported parameters. Where native role selection
is exposed, select the matching installed role. Where it is absent, read the
matching `.codex/agents/<role>.toml` and pass its behavioral brief explicitly with
the assignment; never manufacture an `agent_type` parameter or imply that naming
a role applied its configuration. Keep scope and authorization unchanged.

Verify actual worker permissions from native metadata or its observed runtime
context, and state unknown when they cannot be established. A prompt instructing
read-only review does not enforce a read-only sandbox. The review assignment
still forbids source/record edits, commits and integration even if the worker
inherits broader capabilities. Report whether narrowing was observed or only
instructed, without treating unavailable role selection as authority to write.

## Independent Sessions

Select an independently resumable lane for each effort. Read related canonical
designs and open boundaries before setting edit ownership. Record only meaningful
dependencies: artifact/revision, assumed contract, and the reason it matters.
Two file-disjoint efforts can still disagree about behavior. Before adding a
concurrent source writer, inspect actual native activity and publish a lightweight
flat ownership binding for any existing flat execution. Missing records do not
prove a checkout is idle. Publish execution bindings through `piper-record`, which
rejects duplicate checkout claims across flat, group, and named lanes under the
shared record lock. Read-only studios do not claim source checkouts.

When one effort discovers a changed premise, its owner records the evidence,
affected boundary, impact, and resolution owner. Gather the relevant perspectives
into one recommendation. Native messages may notify another session when that
communication is authorized; do not depend on messages to reach a paused session.
The records must suffice at resume. Do not change another session's instructions,
current-work files, or source checkout to force it to adopt a proposal.

After alignment, update the canonical shared decision once through protected
publication. Each affected owner reconciles its own boundary and exact accepted
design revision before continuing dependent work. Continue unaffected work.

## Delegated Implementation

Use writable helpers only when the user authorizes implementation delegation.
Keep the parent as coordinator and single owner of hub records and acceptance.
Delegation changes how authorized work is carried out, not its product scope,
source-edit authority, or external/exceptional permission.

Before spawning a source-writing worker:

1. Choose a bounded task that can proceed independently. Sequence tightly
   coupled work; do not manufacture parallelism.
2. Prepare a separate project worktree outside the hub, on a distinct branch,
   based on the source state the assignment needs. Confirm branch, clean initial
   status, repo identity, and writable native workspace access. Do not assume a
   Codex subagent automatically receives a separate checkout or writable access.
3. Give the worker the project/parent lane, goal and acceptance, assigned checkout
   and branch, owned files/areas, fixed contracts with canonical revision
   references, prohibited changes, verification, and return requirements.
4. State whether the worker should commit its own completed source. A worker
   never integrates into base, publishes hub records, spawns additional workers,
   or takes external/exceptional actions unless separately explicitly delegated
   and permitted by the parent workflow. Keep exceptional actions in the parent.

A worker missing checkout, ownership, acceptance, or access reports the gap and
edits nothing. No worker writes its inherited parent checkout as a fallback.
Read-only helpers may inspect shared source, with observed source state made
clear. A worker finding a changed fixed contract or necessary ownership overlap
reports evidence and proposed impact; it does not silently widen its assignment.

Worker return includes actual changed files and commit/diff locator, verification
commands and results, unverified claims, unresolved findings, and any dirty state.
Treat these as evidence to inspect, not an acceptance verdict. The coordinator
validates the diff, integrates worker contributions into its own candidate in a
controlled order, runs combined checks and the applicable independent review,
and records the final outcome. Use `integration.md` for publication to base.

Worker worktrees remain outside hub records and are retained unless deletion is
explicitly authorized. A short-lived worker is not automatically a new lane or
group. If unresolved work must survive the parent, record its assignment,
checkout and branch, result locator, and native handle when available in parent
active work; reference it from the resume packet. Do not copy transcripts.

## Pause, Resume, And Ownership

Before restarting or reassigning a worker, inspect its actual native status when
available and its checkout. A wait timeout is not terminal status; wait again on
the same live handle. A saved handle or an old "running" note is not proof of
liveness. If status is unavailable, say unknown and resolve ownership before
starting another writer. Preserve uncommitted results and original assignments.

A resumed coordinator reads affected contracts and any resolution before sending
more work. Reconcile partial integration or checkpoint publication from actual
git state. Never repeat a merge or accept a stale worker report just because the
last conversation ended before a final response.
