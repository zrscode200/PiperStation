# Design Studio Artifact Contracts

These contracts organize durable design without creating a second Piper
Station work-tracking system.

## Filesystem

Piper continues to support lightweight topical notes:

```text
projects/<project-id>/work/design/<topic>.md
```

A full studio uses:

```text
projects/<project-id>/work/
  design/
    README.md
    <lightweight-topic>.md

    <studio-slug>/
      README.md
      design.md
      working-decisions.md             # optional
      open-questions.md                 # optional
      <descriptive-artifact>.md         # optional
      <diagram-or-mockup>.<format>      # optional
      <naturally-named-artifact>/       # optional
      archive/                          # exceptional
```

Do not create optional files or directories until they have a clear role.

## Where Material Goes

While an initiative has a non-superseded studio, its durable design content
belongs inside that studio folder — do not create sibling lightweight notes
for the same initiative.

| Material | Destination |
| --- | --- |
| New durable design content for an initiative with a studio | Inside that studio folder, never a sibling lightweight note |
| Session narrative or log | Not durable — git history plus `build-log.md` checkpoints |
| Raw subagent reports and research dumps | Not persisted — distill findings into `design.md` or a named supporting artifact |
| Post-compact resume guidance | `context-pack.md`, never a studio file |
| Scratch and tmp work | Session scratch space outside the hub — no `tmp/` inside a studio |
| Decision rationale | `design.md`, or `working-decisions.md` when split |
| Longer direction and revisit triggers | `roadmap.md` |

### Worked Example

A realistic mid-life studio, with the optional files it deliberately does not
have:

```text
projects/acme-webapp/work/design/
  README.md                    # index — exists because a note and a studio coexist
  2026-03-02-caching-note.md   # earlier lightweight note; links to the studio
  checkout-redesign/
    README.md                  # navigation: start here, artifact map
    design.md                  # canonical design; revision 6, accepted_revision 5
    working-decisions.md       # split out once rationale outgrew design.md
    payment-flow-states.md     # supporting artifact, linked from design.md
```

No `open-questions.md` (still a section inside `design.md`), no `archive/`
(nothing materially superseded), no session log, and no `tmp/` anywhere.

## Project Design Index

`work/design/README.md` answers what design work exists and where to begin. It
is required once the design tree has two or more entries — a second studio, or
a studio coexisting with lightweight notes. A sole studio in an otherwise
empty tree may defer it; creating the second entry creates the index. Its
minimum headings are:

```text
# Project Design
## Purpose
## Current Piper Work
## Studios
## Lightweight Notes
## Relationships
## Authority
```

It links to existing `active-work.md`, `build-log.md`, and `context-pack.md`
when useful; indexes studios and lightweight notes; and records concise
relationship or supersession pointers.

It does not own the current design revision, acceptance state, current boundary,
checkpoint history, branch, or HEAD. Update it when indexed design work is
created, renamed, removed, materially re-scoped, or superseded—not after every
design edit.

## Studio README

`work/design/<studio-slug>/README.md` is the local navigation entry. Its minimum
headings are:

```text
# <Studio Name>
## Purpose And Scope
## Start Here
## Current Piper Work
## Artifact Map
## Reading Paths
## Relationships
## Authority
```

It starts with a link to `design.md`, explains significant artifacts and
reading paths, and links to current Piper continuity records when present.

It does not own the integrated design, lifecycle state, resume packet, or
checkpoint history. Update it when the artifact map or reading paths change.

## Canonical Design

`design.md` is required and owns the current integrated design and revision.
Start it with:

```yaml
---
status: exploring
revision: 1
accepted_revision: null
updated: YYYY-MM-DD
---
```

Allowed `status` values:

```text
exploring | provisional | accepted-for-planning | superseded
```

Minimum headings:

```text
# <Design Name>
## Frame
## Evidence And Assumptions
## Goals And Non-Goals
## Current Design
## Fixed Contracts
## Implementation Freedoms
## Open Questions
```

Add `## Alternatives And Rationale`, `## Supporting Artifacts`, and
`## Handoff Readiness` when they earn their place; smaller studios fold that
content into the core sections. The content may add problem-appropriate
sections for actors, scenarios, flows, responsibilities, interfaces, state,
data, failure, recovery, authority, security, operations, and evolution.

## Conditional Ledgers

Create `working-decisions.md` only when initiative-local alternatives,
rationale, consequences, or revisit triggers would make `design.md` hard to
read. Promote a decision to project-level `decisions.md` only when future
initiatives should not silently reopen it.

Create `open-questions.md` only when unresolved questions form a meaningful
multi-session register. `active-work.md` keeps only the current boundary and
immediate blockers.

For smaller studios, both remain sections inside `design.md`.

## Emergent Supporting Artifacts

Create a separate artifact when it deserves independent depth, review, reuse,
or a format that does not fit `design.md`. Use descriptive names such as:

```text
registration-flow.md
current-bootstrap-findings.md
cold-resume-walkthrough.md
registration-wireframe.png
api-sketch/
```

Do not force artifacts into `topics/`, `aspects/`, `research/`, `probes/`, or
`prototypes/`. Link every artifact outside `archive/` from `design.md` or the
studio README at creation and explain its role. Supporting material never
silently becomes current design authority.

Executable prototypes belong in an authorized registered or scratch repository,
not the hub. The studio may record a locator, findings, limits, and design
implications.

## Exceptional Archive

Use `archive/` only for materially superseded content whose prior model remains
important to understanding the design. Do not archive every revision or create
a session log; git preserves ordinary history.

## Artifact Authority

Each mutable fact has one owner:

| Fact | Owner |
| --- | --- |
| Available project design work and entry points | `work/design/README.md` |
| Studio files and navigation | studio `README.md` |
| Integrated design, current revision, and acceptance | studio `design.md` |
| Detailed initiative-local rationale, when split | `working-decisions.md` |
| Broader design questions, when split | `open-questions.md` |
| Current design or execution boundary | the lane's `active-work.md` (the flat lane for studio work) |
| Meaningful checkpoint history | the lane's `build-log.md` |
| Full pause, compact, and resume state | the lane's `context-pack.md` |
| Longer direction and revisit triggers | `roadmap.md`, when useful |
| Deliberate durable queued work | `task-queue.md`, when useful |
| Project-significant decisions | project `decisions.md` |
| Stable facts and preferences | project `memory.md` |
| Project binding and standing policy notes | project `project.md` |
| Branch, HEAD, commit list, and raw diff | live project git |

If records disagree, `design.md` wins for design content and revision,
`active-work.md` for the current boundary, `context-pack.md` for cold resume,
and `build-log.md` for checkpoint history. READMEs remain navigation.

## Create, Reuse, And Slugs

- Resolve existing design work before creating anything.
- One initiative reuses one studio across sessions.
- Derive a stable lower-kebab-case slug from the initiative name.
- If the slug matches the same initiative, reuse it.
- If it belongs to different work, choose a concise distinguishing suffix.
- Never overwrite or merge unrelated studios merely to avoid a new folder.
- While an initiative's studio exists and is not superseded, keep its new
  durable content inside that studio folder rather than as sibling notes.

For an existing lightweight note or ad hoc folder, preserve original content.
Promotion is discussion-led and non-destructive: create or reuse the compliant
studio, integrate useful content into `design.md`, and add relationship or
supersession links. Never silently move or delete the original.

## Revision And Acceptance

- Begin a new studio at `revision: 1`.
- Increment the integer revision for a material change to the integrated
  design.
- Do not increment for editorial fixes or navigation-only changes.
- Writing or revising content does not imply user acceptance.
- Only an explicit user signal may set:

  ```yaml
  status: accepted-for-planning
  accepted_revision: <current revision>
  ```

- After a material post-acceptance change, increment `revision`, set
  `status: provisional`, and retain the prior acceptance as checkpoint history
  in `build-log.md`. Do not treat the new revision as accepted until the user
  explicitly accepts it.
- Mark `status: superseded` only when another design artifact replaces this
  design, and link the replacement.

Design maturity does not duplicate whether the studio is currently active,
paused, or handed off. Existing Piper work artifacts own that lifecycle state.

## Piper Work Tracking

Reuse Piper's existing artifacts:

- `active-work.md`: current Design Studio boundary, provisional alignment,
  immediate blockers, next discussion, and explicit `no Ralph group or wave`
  state when multi-session continuity is useful;
- `build-log.md`: meaningful design checkpoints, accepted or superseded
  contracts, important evidence, design review, and readiness for planning;
- `context-pack.md`: full pause, compact, handoff, and cold-resume packet that
  points to canonical `design.md`;
- `roadmap.md`: optional longer design direction and revisit triggers;
- `task-queue.md`: only deliberate durable research, validation, prototype,
  review, or later execution work.

A studio README never replaces `context-pack.md`, and studio files never become
a parallel work tracker.

## Piper Workflow Handoff

Piper Workflow consumes:

```text
design_artifact: projects/<project-id>/work/design/<studio-slug>/design.md
accepted_revision: N
```

The exact integer revision must be explicitly accepted. The design should make
goals, non-goals, fixed contracts, implementation freedoms, assumptions,
evidence gaps, and deliberately delegated unknowns visible.

If the user wants to build but declines to accept the current revision, the
studio pauses or concludes without a handoff pair. Piper Workflow may still
proceed from ordinary brainstorm direction — a studio is never a blocker.
The unaccepted design remains reference material, not a verified input.

Piper Workflow reads linked supporting artifacts, verifies the accepted
revision against live source, and references rather than copies the design.
Choices inside implementation freedoms stay downstream. If source verification
invalidates a fixed contract or core premise, return upstream to Design Studio.

A material change after handoff creates a revision mismatch. Piper Workflow
must reverify the new revision after explicit acceptance before relying on it.
