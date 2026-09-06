# Working across Codex tasks

Piper keeps a developer's project understanding, decisions and unfinished work
available across conversations. Source remains in its own Git repository. The
hub adds continuity and explicit boundaries to the Codex tools actually present
in a session; it does not run a background scheduler or decide project priorities.

The [experiment record](codex-prototype-experiments.md) separates demonstrated
behavior from work still being verified. The examples here explain the current
operating contract. A quoted request selects intent, not a new slash-command API.

## Ordinary work stays small

“Fix the multiline startup summary” selects a small execution boundary. Piper
checks the producer/consumer contract, changes the source, verifies it, and
records one useful completion entry. A finished fix needs no group, roadmap,
queue or resume packet. The lc_factory baseline experiment followed that pattern.

More structure appears when it serves a real need:

| Work | Continuity location | What it adds |
| --- | --- | --- |
| Ordinary execution | `work/` (`flat`) | Default current boundary and economical checkpoint history. |
| Explicit durable design | `work/design/<slug>/` (`studio:<slug>`) | Independent questions, design revisions and pause/resume context. |
| Several waves with shared acceptance | `work/groups/<gid>/` (`group:<gid>`) | Group acceptance and an integrating review across its waves. |
| Independent concurrent execution | `work/lanes/<slug>/` (`lane:<slug>`) | Separate ownership and resumption without requiring a group. |

These paths are inside a registered project's hub records. Natural language can
identify an existing effort; the developer does not have to recite a locator.
Piper asks when the intended boundary is ambiguous, not merely because other
work exists in the hub. A paused execution binding remains reserved. Completed
work closes an existing binding, without creating a file solely to close it.

## Two designs can develop independently

In the Mason experiment, one task explored returning after interrupted restore.
Another explored how cancellation and cleanup failure should be reported. Each
studio kept its own provisional design and pause packet. Neither acquired a
writable source checkout or silently approved implementation.

The process-outcomes task discovered the recovery task's published boundary
during checkpoint. It recorded a specific dependency: preserving an interrupt
does not prove process cleanup succeeded or restoration is safe. It linked the
other effort and marked the affected recommendation for revalidation. It did not
invent a design revision while the other canonical design was still unpublished.

“Continue recovery-continuity and reconcile the process-outcomes proposal” then
selected a fresh design continuation. The fresh task read both designs, checked
review findings against source, narrowed the shared recommendation, and gave it
one canonical owner. The other studio remained byte-for-byte unchanged. Its next
owner can read the shared resolution and reconcile its own work.

A related-work note earns its place when it identifies the artifact/revision,
the relied-on assumption, why it matters, and who will resolve a material change.
An observation can leave work unaffected, require revalidation, or block dependent
work. Independent work may continue. A proposal or supporting note does not become
an accepted contract through repetition in several conversations.

## Execution can use workers without becoming a new project manager

After direction and acceptance are clear, the coordinator formalizes the current
boundary and decides whether work can proceed independently. The Mason concerns
provide a concrete split: runner outcome handling and retained-state restoration.
Their files can differ while their behavior still needs a combined review.

Each source-writing worker receives an explicit goal, acceptance, checkout and
branch, owned files, fixed contracts, verification and return expectations. It
works in an isolated project worktree outside the hub. Native subagents do not
automatically supply that isolation or writable access. The coordinator prepares
and verifies those arrangements or sequences the work.

Workers return actual diffs/commits, verification, unresolved findings and dirty
state. They do not own shared hub records or acceptance. The coordinator inspects
their work, assembles a candidate, tests interactions and resolves independently
reviewed findings. A short-lived worker need not become a durable group or lane;
only unfinished assignments need to survive in the parent's continuity records.

The active client determines the available delegation API. Where named roles are
selectable, Piper supplies configured roles. Otherwise the coordinator includes
the relevant role brief in an assignment using supported tool parameters.
Read-only review remains a behavioral requirement; a prompt alone does not prove
that the worker has a narrower sandbox. See [Codex wiring](capability-matrix.md).

## Conflicts have different resolutions

| Situation | Piper's response |
| --- | --- |
| Two efforts rely on incompatible behavior | Record the conflicting assumptions; one coordinator proposes a shared resolution. Reopen fixed product decisions for alignment. |
| Two execution records claim one checkout | Protected ownership publication rejects the competing claim. Use another verified worktree or finish/release the existing binding. |
| Two sessions update the same shared record | A stale digest is rejected. Reread and reconcile both contributions before replacing the record. |
| Source changes conflict mechanically | Resolve in the owned candidate checkout, then reverify the affected behavior. |
| Base advances after candidate verification | Incorporate the new base and repeat affected verification/review; changing the expected ID alone is insufficient. |
| Base checkout belongs to paused work | It remains occupied. Finish, explicitly relocate, or sequence that work; do not infer absence from a saved native handle. |
| A hook or interrupted command may have published already | Inspect actual HEAD, commit scope and working/index state. Reconcile records instead of blindly repeating publication. |

`piper-record` protects cooperating shared-record writes, execution bindings and
explicit-path hub commits. Registration takes the same hub lock. `piper-integrate`
holds the repository publication lock and the hub record lock while checking an
exact verified candidate and idle base, then fast-forwards that candidate. Both
preserve configured Git hooks and report attention states after uncertain or
unexpected publication. Neither helper decides that tests passed or the user
accepted a design.

## Resume from records and actual state

A fresh task selects the intended lane and reads its packet, canonical artifacts
and relevant related work. It verifies source state and native worker status
before acting. A recorded handle, “running” note or wait timeout does not prove a
worker is live or finished. Unknown ownership must be resolved before starting a
replacement writer.

The resume packet owns the next action and what cannot be reconstructed from
Git. Source evidence belongs with its test/review or integration record; it is
not copied into every file as a supposed current HEAD. If publication happened
before the closeout records were saved, source and hub are temporarily out of
step. Resume reconciles that fact and finishes the records. It must not merge
again just because the old packet says integration is next.

## Practical limits

These are cooperative operations in one shared hub. Direct filesystem/Git edits
can bypass them, and separate hubs do not form a global ownership registry. A
missing flat-lane record does not prove no native writer exists; publish its
ownership binding before introducing concurrent source writers. A multi-file
checkpoint is reconciled on resume rather than committed as a database transaction.

Piper inherits the user's model, reasoning, memory and root permission choices.
It supplies behavior and current-work records, while the client controls native
tools, sandbox access, lifecycle hooks and live tasks. Explicit checkpoints remain
necessary when hooks are unavailable. Long-horizon work can use the same boundaries
and resumption model; these finite experiments do not establish unattended
reliability for every project or runtime version.
