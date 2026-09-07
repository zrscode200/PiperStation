---
name: design-studio
description: "Use when the user explicitly asks to open, enter, start, or continue an in-depth Piper Station Design Studio for a registered project. Provides a discussion-first, multi-session divergent design practice with durable hub-owned artifacts. It does not trigger merely because a request mentions design, and it does not plan implementation or edit project source."
---

# Design Studio

Design Studio is Piper Station's optional deep-design practice. It belongs on
the divergent side of the station, between lightweight exploration and
convergent implementation planning when the work needs more modeling, evidence,
pressure testing, or multi-session continuity.

Enter only on explicit intent: the user invokes `design-studio`, asks to open or
enter a Design Studio, or asks to continue an existing studio. A generic design
question or a complex brainstorm is not enough. `brainstorm` may later suggest
this skill, but it must not enter or create studio artifacts without the user's
choice.

Design Studio is discussion-first. Durable artifacts support the conversation;
they are not a document-generation ceremony.

Read `AGENTS.md` and `STATION.md` first. Use
`references/studio-method.md` for the adaptive design practice and
`references/artifact-contracts.md` for filesystem, ownership, revision,
acceptance, and handoff rules.

## Authority Boundary

Explicit Design Studio entry authorizes creating or updating useful hub-owned
design and continuity artifacts under:

```text
projects/<project-id>/work/
```

It does not authorize:

- edits to the registered project's source repository;
- Piper Workflow groups, waves, implementation queues, or Ralph execution;
- project-source commits, pushes, pull requests, dependency changes, or
  external-system actions not separately authorized;
- destructive migration, deletion, or exceptional actions.

Useful design checkpoints and their hub artifact commits follow STATION; no
additional per-checkpoint approval is needed. Shared records and lane ownership
use `piper-record`; sole-owned studio files may use normal file tools. This does not authorize source implementation.

Route later implementation planning to `piper-workflow`, explicit code review
to `review`, and `external` or `exceptional` actions to `automation-policy`.

## Resolve The Project

1. Identify the project id or repo path from the request and current context.
2. Resolve it through `projects/registry.json`, then read
   `projects/<project-id>/project.md`, `memory.md`, optional `decisions.md`, and
   relevant existing work artifacts.
3. Inspect the live registered repository read-only: current branch, HEAD,
   status, and the source areas relevant to the design question. Treat
   uncommitted work as user-owned.
4. Inspect `projects/<project-id>/work/design/README.md`, existing studio
   folders, and lightweight design notes when present.
5. If the project is not registered, remain conversational or offer the
   existing deterministic registration path. Do not create durable studio
   records for an unregistered project.

## Create Or Reuse A Studio

One studio represents one design initiative across conversations, not one
runtime session. Its lane is `studio:<slug>` and its optional continuity files
live in `work/design/<slug>/`. Different studios can remain independently active
and resumable. One coordinating session owns a studio lane at a time; another
session may read it and propose synthesis, without rewriting its working state.

- Reuse an existing studio when its initiative matches the user's design
  question.
- For a new initiative, derive a stable lower-kebab-case slug from its name.
- If the slug already belongs to different work, choose a concise
  distinguishing suffix. Never overwrite an unrelated studio.
- Create `work/design/README.md` as the project design index
  once the design tree has two or more entries; a sole studio in an
  otherwise empty tree defers the index until a second studio or
  lightweight note appears. Keep any existing index current when indexed
  design work changes.
- Create `<studio-slug>/README.md` and `<studio-slug>/design.md`.
- Create `working-decisions.md`, `open-questions.md`, supporting artifacts, or
  `archive/` only when each does a clear job.

When promoting a lightweight note, preserve it. Create or reuse the studio,
integrate useful content into `design.md` through discussion, and add
relationship or supersession links. Do not silently move or delete the
original note.

## Work In The Studio

Use the method reference adaptively:

1. Frame the current design boundary and separate facts, assumptions, goals,
   constraints, and non-goals.
2. Investigate live source or prior art when evidence would change the design.
3. Explore credible alternatives where a real choice exists.
4. Make the design concrete with the representation appropriate to the
   problem.
5. Pressure-test failure, recovery, authority, security, usability, operations,
   reversibility, and evolution where relevant.
6. Discuss the synthesis with the user and record it after alignment.

Use an `investigator` when a substantial bounded question benefits from separate
context or parallel research, and a `reviewer` for independent challenge of a
particular provisional design. Supply the specific architecture, security or
other focus; keep quick questions in the main session. Follow
`../piper-workflow/references/coordinated-work.md` for assignments, source and
verification boundaries. Reading that procedure does not enter execution.
The main session synthesizes results with the user and owns design publication
and acceptance; helpers do not create an implementation handoff.

When the question relates to another studio or implementation effort, read its
canonical records and distinguish tentative ideas from accepted contracts. Use
STATION → Related Work And Changed Assumptions to record consequential
relationships and revisions. Combining designs means reconciling assumptions
and assigning one canonical home to shared behavior. Preserve useful original
material and reference the resolution from its consumers; do not concatenate
documents or treat another session's proposal as user acceptance.

A finding can conclude an investigation without implementation. Preserve the
question, evidence, limits, and resulting decision only when useful. Do not
create a group, wave, or implementation handoff to count learning as progress.

Research, comparisons, diagrams, journeys, mockups, examples, and disposable
experiments are activities and emergent artifacts. Do not force them into
universal topic, aspect, research, probe, or prototype categories.

## Checkpoint Economically

At a meaningful design boundary:

- reconcile `design.md` and material revision;
- update navigation only when artifacts, relationships, or reading paths change;
- use this studio's `active-work.md` only when its current design boundary needs
  continuity; record `lane: studio:<slug>` and no Ralph group or wave;
- append this studio's `build-log.md` for meaningful evidence, decisions or
  acceptance checkpoints, and publish project-significant conclusions to shared
  records only when useful;
- rewrite this studio's `context-pack.md` at STATION resume triggers, preserving
  open questions, related-work impacts, and the next discussion;
- use a queue only for deliberately durable pending research or validation.

Use `piper-record` for shared publication and path-only commits. Read before replacing;
a stale digest requires reconciliation. Do not update every artifact after every
exchange. Legacy flat continuity moves only when clearly owned by this studio;
preserve unrelated execution state and link the earlier project ledger.

On resume, read the studio's actual packet and canonical design, inspect relevant
live source and changed related records, and continue design without source edits.
A clearly selected studio is not blocked by other open execution lanes.

## Revision, Acceptance, And Handoff

`design.md` owns the current integer revision and design maturity.

- Material changes to the integrated design increment `revision`.
- Editorial or navigation-only changes do not.
- Only an explicit user signal may set `status: accepted-for-planning` and
  `accepted_revision` to the current revision.
- If a material change follows acceptance, increment the revision, return the
  status to `provisional`, and require explicit acceptance of the new revision.

A request to build, implement, or code the design is a Piper Workflow entry
signal, not a studio exit into direct editing. When the user asks to build the
design or to proceed to implementation planning, first resolve acceptance: if
the current revision is not explicitly accepted, ask for that decision. Then
hand Piper Workflow:

```text
design_artifact: projects/<project-id>/work/design/<studio-slug>/design.md
accepted_revision: N
```

Do not copy the full design into execution artifacts. Piper Workflow verifies
that exact revision against live source before planning.
Source implementation never starts from the studio, regardless of action
class. A failed fixed contract or core premise returns upstream to Design
Studio; choices inside recorded implementation freedoms stay downstream.

## Exit Choices

A studio may:

- continue with another design boundary;
- pause with compact-safe continuity;
- conclude as useful durable design without implementation;
- hand an explicitly accepted revision to Piper Workflow;
- treat a request to build, implement, or code as that same Piper Workflow
  entry, never as authorization to edit project source directly.

Do not manufacture an implementation handoff merely to make the studio appear
complete.

## Guardrails

- Do not force Design Studio into ordinary brainstorming.
- Do not create a studio merely because a request mentions design.
- Do not create empty optional artifacts in anticipation of future work.
- Do not treat supporting material as accepted design unless `design.md`
  integrates or adopts it.
- Keep design content in `design.md` and continuity in the studio lane's
  standard work records; READMEs never duplicate the packet or ledger.
- Do not turn design subjects into implementation groups or waves.
- Do not copy project source or executable prototypes into the hub.
- Do not mark a design accepted without an explicit user signal.
- Do not infer implementation or external authority from Design Studio entry.
- Never overwrite another studio's working context or accept its proposals on
  the user's behalf.
- Do not exit into direct source editing on a build or implement request; that
  signal enters Piper Workflow.
