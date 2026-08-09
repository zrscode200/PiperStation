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

Read `.deepagents/AGENTS.md` and `STATION.md` first. Use
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
- commits, pushes, pull requests, dependency changes, network actions, or
  external-system changes;
- destructive migration, deletion, or exceptional actions.

Route later implementation planning to `piper-workflow`, explicit code review
to `review`, and permission-gated actions to `automation-policy`.

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
runtime session.

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

Research, comparisons, diagrams, journeys, mockups, examples, and disposable
experiments are activities and emergent artifacts. Do not force them into
universal topic, aspect, research, probe, or prototype categories.

## Checkpoint Economically

At a meaningful design boundary:

- reconcile the canonical `design.md`;
- update the studio README only when its artifact map or reading paths change;
- update the project design index only when indexed design work changes;
- use `active-work.md` for the current Design Studio boundary when durable
  continuity is useful, without inventing a Ralph wave;
- append `build-log.md` only for meaningful design checkpoints;
- rewrite `context-pack.md` only at Piper's existing pause, compact, handoff,
  blocker, milestone, finish, or project-switch boundaries;
- use `task-queue.md` only when the user deliberately needs durable queued
  research, validation, prototype, review, or later execution work.

Do not create progress logs or update every artifact after every exchange.

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
Source implementation never starts from the studio, regardless of permission
profile. A failed fixed contract or core premise returns upstream to Design
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
- Do not duplicate current boundary, resume state, or checkpoint history inside
  studio files.
- Do not turn design subjects into implementation groups or waves.
- Do not copy project source or executable prototypes into the hub.
- Do not mark a design accepted without an explicit user signal.
- Do not infer implementation or external authority from Design Studio entry.
- Do not exit into direct source editing on a build or implement request; that
  signal enters Piper Workflow.
