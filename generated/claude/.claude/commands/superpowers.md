---
description: Enter Superpowers Mode for direction verification and planning
argument-hint: "<project-id> [request]"
---

# Superpowers

Enter Superpowers Mode for a registered project.

The user invoked this command with: `$ARGUMENTS`

Use Superpowers Mode to verify a direction, define the group or milestone
structure, and formalize the current wave into Ralph-ready detail before
substantial implementation. The work runs as two named passes:

- Structural Planning verifies the direction and defines the group or
  milestone structure.
- Wave Formalization details the current wave enough to execute safely.

A full `/superpowers` invocation runs both passes in order. Wave Formalization
also stands alone: Ralph runs it at a wave boundary when the selected wave is
still a sketch, without re-running Structural Planning. Structural Planning also
runs scoped to a single group at that group's Entry, re-verifying its sketch
against current code before its first wave (see `STATION.md` → Group Lifecycle).

Use this command for formal planning, not for divergent exploration or general
repo orientation (those belong to `brainstorm`), implementation, review, or
automation approval. Natural-language routing reaches this behavior through
`piper-workflow`; actions that cross the active permission profile boundary
still route through `automation-policy`.

## Pass 1: Structural Planning

1. Read `CLAUDE.md` and `STATION.md`.
2. Identify the project id or repo path from `$ARGUMENTS`. Look up the project
   in `projects/registry.json` to confirm registration and resolve `repo_path`,
   then read `projects/<project-id>/project.md`, `memory.md`, and optional
   `decisions.md` when it exists.
   If upstream provides a Design Studio handoff, require the exact pair:

   ```text
   design_artifact: projects/<project-id>/work/design/<studio-slug>/design.md
   accepted_revision: N
   ```

   Resolve and read that current artifact before continuing. Require
   `status: accepted-for-planning`, integer `revision`, and integer
   `accepted_revision`, with both metadata revisions equal to the handed-off
   integer `N`. Read significant supporting artifacts linked by `design.md`.
   Missing, provisional, superseded, non-integer, or mismatched metadata makes
   the handoff stale: return to Design Studio for explicit acceptance of the
   current revision. An ordinary brainstorm brief with no studio remains valid.
   If `design.md` changes materially after handoff, treat the prior pair as
   stale. Require explicit acceptance of the current revision, then repeat this
   metadata and live-source verification before planning resumes.
3. Verify the chosen upstream direction against the real code: confirm the
   ordinary brief's or accepted design's flagged assumptions, inspect the
   specific files and call sites the work will touch, and check that acceptance
   criteria are testable.
   Open exploration belongs to `brainstorm`; this step grounds the chosen
   direction, it does not re-open it. For an accepted studio revision, verify
   its goals, assumptions, fixed contracts, and core premises against live
   source. Make choices inside recorded implementation freedoms; if a fixed
   contract or core premise fails, return upstream to Design Studio rather than
   silently redesigning it here.
4. Classify scope as `S0`, `S1`, `S2`, or `S3` for sizing only.
5. Classify risk as `L0`, `L1`, `L2`, or `L3`.
6. Ask only blocking clarification questions. If you cannot articulate what
   answer would change the design, do not ask.
7. Create or update active work files under `projects/<project-id>/work/` only
   when they do a clear job: preserve long-horizon direction, stabilize current
   active work, create durable queued execution, record a checkpoint, or prepare
   compact/resume continuity.
8. Define the group or milestone structure: give each in-scope group a
   boundary, an acceptance target, and risks or revisit triggers. Update
   `roadmap.md` only when long-term direction, milestones, deferred work,
   risks, or revisit triggers change.
9. Decide explicitly whether the work needs a group: only when multiple waves
   share one acceptance target, cross-wave interaction risk matters, or the
   work will run alongside other work on the project. Otherwise keep it one
   ungrouped wave with a light boundary (`STATION.md` → Project Records). When
   a group is entered, write the group header in `active-work.md` with the
   goal, wave list, required gates, group review state, and acceptance target.
10. Check structural readiness: the structure is complete when every in-scope
    group has a boundary, an acceptance target, and revisit triggers.
    Wave-level detail is not part of this bar; later waves and groups may stay
    sketches and are formalized at their own boundaries.
11. Close the pass by reporting the structure and stating which wave Wave
    Formalization will detail next.

## Pass 2: Wave Formalization

Formalize one wave into Ralph-ready detail. Inputs are the group or milestone
structure from Structural Planning and the current state of the real code.
This pass stands alone: Ralph runs it at a wave boundary when the selected
wave is still a sketch.

12. Write `active-work.md` as the live group and wave workbench only when the
    work needs durable execution continuity. Detail the current wave enough to
    act safely: acceptance criteria, expected diff boundary, verification,
    review expectations, stop conditions, and useful slice breakdown. Sketch
    later waves only when the current code, context, and prior results make
    them reliable; this economy rule scopes artifact detail, not execution
    readiness — a sketched wave is formalized through this pass when its
    boundary arrives. Keep work artifacts in `projects/<project-id>/work/`
    unless the user explicitly asks for a project-local copy. When input is an
    accepted studio revision, record its `design_artifact` and exact
    `accepted_revision` but reference rather than copy the canonical design.
13. Produce a Ralph-ready `task-queue.md` only when waves, slices, or group
    gates are clear, verifiable, and must survive the current session or move
    across agents. For a multi-wave group, list the group review gate as an
    explicit acceptance criterion before the acceptance task.

## Closeout

14. Append `build-log.md` at formal planning completion when the plan
    materially changes future execution.
15. Defer `context-pack.md` unless a resume trigger applies (`STATION.md` →
    Artifact Persistence → Boundary triggers); when written, it holds only the
    non-derivable fields defined under Compaction.
16. At the planning checkpoint, satisfy the checkpoint invariant (`STATION.md`
    → Artifact Persistence): report changed Piper artifacts separately from
    source changes and state whether they are uncommitted in the hub.
17. Offer one Piper artifact commit at planning finish only when the changed
    artifacts matter for future continuity. Do not commit unless the checkpoint
    decision is made and the active permission profile covers local git actions;
    otherwise route through `automation-policy`.
18. Stop before implementation unless the user explicitly asks to proceed.

Registration must not create `projects/<project-id>/work/`; Claude Code
creates these files only when useful for active work. Keep Superpowers as
Claude Code-native prompt and command behavior; do not introduce shell lifecycle
machinery for planning.

## Work Artifacts

Create only under `projects/<project-id>/work/`, and only when useful:

- `roadmap.md`: longer-horizon direction, groups, milestones, deferred work,
  risks, and revisit triggers.
- `active-work.md`: live group and wave workbench: group boundary, current wave
  details, reliable later-wave sketches, slice breakdown, required gates, group
  review state, risks, verification strategy, and open questions.
- `build-log.md`: primary durable checkpoint ledger for planning outcomes,
  implemented contracts, implementation summaries, review and verification
  results, risks, next steps, and commits.
- `context-pack.md`: compact/resume and handoff anchor holding only the
  non-derivable fields defined once in `STATION.md` → Compaction; git state
  and files to inspect first are derived at resume.
- `task-queue.md`: optional durable Ralph wave, slice, or group gate list with
  ids, status, risk, acceptance criteria, verification, and expected diff
  boundary.
- `work/design/<topic>.md`: optional lightweight topical design note,
  superseded in place and preserved during any later promotion.
- `work/design/<studio-slug>/`: optional full Design Studio after explicit
  user choice; its two README layers navigate, `design.md` owns the integrated
  design and revision, and optional artifacts emerge only when useful.

Keep artifacts lean: `context-pack.md` is the only fully self-contained resume
packet, rewritten in full when updated. Git is the source of truth for branch,
HEAD, commit, and diff history — derive it live and let the owning artifact record
what it needs (build-log's acceptance commit) rather than repeating it across
context-pack, roadmap, active-work, queue, or project records.
See `STATION.md` for the temporal roles (sinks vs windows vs topical references)
and fact ownership.

Keep stable facts in `memory.md`, project policy preferences in `project.md`,
and substantial decision logs in optional `decisions.md`. Registration must not
create active work artifacts.

## Artifact Persistence

Superpowers is a natural artifact checkpoint. Updating work artifacts is part
of planning, but committing them is not automatic. At the end of planning,
summarize the artifact files touched, their role in the next Ralph wave,
explicit slice, or future session, and whether they remain uncommitted in the
Piper Station hub.
Offer a single artifact commit only when the artifact checkpoint matters for
future continuity; permission profiles gate whether that local git action can
proceed, not whether the checkpoint exists.

## Spec Shape

`active-work.md` should include the group or milestone boundary, goals and
non-goals, current assumptions, current wave details, acceptance criteria,
expected diff boundary, slice breakdown for the current wave, risks and
guardrails, verification strategy, review expectations, stop conditions, and
open questions. When a group exists, include a `Group` section with goal,
waves, required gates, group review state, and acceptance target. The group
section is Structural Planning output; current-wave detail is Wave
Formalization output. Later waves are optional; include only reliable
sketches, dependencies, and revisit triggers.

## Task Shape

Each queued Ralph wave, slice, or group gate should include id, title, status,
risk, likely files or areas, acceptance criteria, verification command or
documented fallback, expected diff boundary, context needed by a fresh session
or reviewer, and dependencies. Multi-wave groups should include an explicit
group review gate before the acceptance task.

## Guardrails

- Do not implement while discovering or planning.
- Do not require Design Studio for ordinary planning. For a studio handoff, do
  not proceed on a revision mismatch, copy its canonical design into execution
  records, or redesign a failed fixed contract inside Superpowers.
- Mark assumptions separately from confirmed facts.
- Keep plans concrete enough for a fresh Claude Code session to continue cold.
- Do not store secrets or sensitive raw logs in hub records.
- Record project policy preferences in `project.md`; use optional
  `decisions.md` only for substantial decision logs.
- "Make it better" is not an acceptance criterion; force a testable one.
