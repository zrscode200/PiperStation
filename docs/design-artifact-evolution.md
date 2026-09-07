# Modular design and temporal evidence

The agreed direction keeps existing studio folders, README/design headings and
continuity files. It adds no formal artifact types, relationship-label schema,
snapshot registry, compatibility layer or separate acceptance stage.

## Intended experience

A developer can recover what the design is, which details were accepted, why
those choices were made, and what later changed their applicability.

One studio remains one initiative across sessions. Separate initiatives, such
as coordination and multiplayer, normally have separate folders. Supporting
filenames are descriptive examples, not registered artifact types:

```text
work/design/coordination/
  README.md                     # navigation
  design.md                     # integrated direction and acceptance
  ownership-model.md            # detailed contract, if explicitly adopted
  recovery-states.md            # another detailed contract
  interaction-flow.svg          # useful visual
  coordination-comparison.md    # evidence and alternatives
  recovery-experiment.md        # observations and later reassessments
  active-work.md                # current boundary, when needed
  context-pack.md               # resumption, when needed
  build-log.md                  # meaningful checkpoints
```

## Explicit adoption in ordinary prose

`design.md` owns the overview, revision and acceptance. It can say:

> The recovery contract is defined in recovery-states.md.
> The comparison in coordination-comparison.md explains why we chose it.

The first statement, with a link to the file, adopts a detailed contract; the
second supplies rationale. A bare link never adopts all the linked content.
Prefer focused artifacts, or name the adopted section when mixed content would
otherwise make scope unclear. There is no classification pass for every artifact
and no duplicate inventory.

Adopted details are reviewed with the overview and participate in its revision.
A material change to one of those contracts or its adoption scope changes the
design revision and needs renewed acceptance. New research does not automatically
change accepted obligations. Cross-studio dependencies retain their canonical
owner and accepted revision; a link never grants write authority over that studio.

## Ordinary acceptance checkpoints

Use the existing user acceptance step, `build-log.md` entry and scoped hub commit.
Include the reviewed overview, adopted local details and relevant evidence in
that checkpoint. Git preserves the accepted content without a separate snapshot
receipt or a second commit merely to record the first commit's ID.

The handoff still identifies `design_artifact` and `accepted_revision`. It may
reference the ordinary acceptance commit when useful. Otherwise recover it from
the acceptance entry in Git history, rather than assume the latest files were
accepted. Inspect the actual publication result and reconcile interrupted work;
respect a request to leave records uncommitted and disclose that persistence limit.

Execution and resume include adopted details and later relevant findings. Compare
adopted content with acceptance history when checking subsequent edits, even if
someone failed to bump the overview revision. Git reveals changed bytes; reasoning
determines whether they materially change a contract. Ambiguous accepted content
must be resolved before relying on it. No new snapshot checker or acceptance CLI.

## Temporal history where it changes decisions

For consequential evidence, retain what was observed, when, against which
source/version or conditions, and which decision relied on it. Observation time,
source publication/event time, artifact edit time and later revalidation have
different meanings. Use dates when adequate and timezone timestamps when order
matters; unknown stays unknown.

When understanding changes, add a dated reassessment alongside or linked to the
earlier observation: what changed, why, and which decision or work is affected.
Preserve the original observation and explain corrections. A current summary
can point to the history. Age alone does not invalidate a finding; a recent
edit does not prove it has been revalidated.

For example, a recovery probe supports revision 4. A dependency later changes,
and a reassessment marks the recovery premise as needing revalidation. A second
probe changes the contract; revision 5 explains that change and receives its
own explicit acceptance. A returning session can reconstruct both the original
choice and its replacement, while continuing work unaffected by the finding.

Use the existing evidence artifact and checkpoint ledger, with semantic
milestones rather than per-edit logs. No mandatory evidence template, metadata
on every sketch, event registry or background monitor. Prototypes stay outside
the hub; retain source identity, relevant conditions, method and results for
important experiments. A temporary path alone cannot promise reproducibility.

## Source wiring

- Artifact contracts own adoption, evidence history and ordinary acceptance.
- Design Studio method and skill apply those contracts without new folder rules.
- STATION, planning, execution, resume and review include adopted details and
  subsequent relevant evidence; worker assignments supply that context.
- Investigator guidance distinguishes observation time and source context;
  reviewer guidance considers adopted scope and later applicability.
- `piper-record commit` publishes non-executable design assets under
  `work/design/` alongside Markdown, preserving byte content, path boundaries,
  symlink checks, hooks and unrelated staged/unstaged work. Supported formats are
  listed by `commit --help`; `read` and `replace` remain Markdown-only.

This targets one consistent contract and preserves existing project records.
It adds no legacy acceptance format or migration machinery.

## Verification scope

Real Git helper tests cover mixed Markdown/binary acceptance checkpoints,
recovery of accepted details and observations after later edits, preservation
of another studio's staged/unstaged changes, rejected unsafe assets, unchanged
Markdown mutation boundaries, and hook changes reported after publication.

Run the required distribution, record and integration tests, shell syntax and
render freshness checks after source changes. These establish mechanics and
instruction consistency, not end-to-end model judgment of design drift or
evidence quality. Any future native behavioral evaluation must be identified as
an evaluation in a disposable hub.

Implementation validation passed: distribution/structural checks, 35 record
tests (including six new cases), 32 integration tests, the three required shell
syntax checks, render freshness, changed role TOML parsing, changed skill
validation and Git whitespace checks. No new native model evaluation was run
for this update.
