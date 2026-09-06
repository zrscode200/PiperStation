# Superpowers

Verify a converged direction and formalize bounded execution on a registered
project. Use brainstorm for open exploration and Design Studio for its explicit
durable design practice. Superpowers verifies the chosen direction against code;
it does not silently redesign an upstream fixed contract.

## Structural Planning

1. Read `AGENTS.md` and relevant `STATION.md` sections. Resolve registry and
   project binding, memory, relevant decisions, and existing work. Select an
   execution lane via STATION → Lanes. A studio handoff selects a downstream
   execution lane; it does not turn studio continuity into a Ralph workbench.
2. For an ordinary brainstorm brief, verify its assumptions against live code.
   For a studio handoff read `design_artifact` and integer `accepted_revision: N`.
   Require `status: accepted-for-planning` and both current metadata revisions
   equal to N. Read significant supporting artifacts and source evidence. A
   missing, provisional, superseded, or mismatched revision returns upstream
   for explicit acceptance and revalidation. Reference the canonical design;
   do not copy it into execution records.
3. Inspect actual source, relevant call sites and tests, existing changes, and
   related open boundaries. Confirm goals, fixed contracts and core premises;
   implementation freedoms remain downstream. For a material contradiction,
   record evidence, affected work, impact and resolution owner under STATION's
   related-work rule. Ask only questions whose answer changes the work.
4. Classify scope S0–S3 and risk L0–L3. Choose one ungrouped wave by default.
   Use a group only when related waves share acceptance or cross-wave risk
   requires an integrating gate. Concurrency alone chooses a named execution
   lane (`lane:<slug>`), not a group. Keep small work lightweight.
5. When groups are needed, define each gid, boundary, acceptance target, and
   revisit triggers; retain later detail as sketches. Create roadmap only when
   long-horizon direction, order, milestones or deferred scope needs durability.
   Group folders are created at Entry, not registration or speculative planning.
6. Bind an exclusive writable checkout before execution. Inspect other writers
   and related contracts, resolve shared edit ownership, and sequence coupled
   work when appropriate. If delegation is authorized, use
   `references/coordinated-work.md` to define bounded worker assignments and
   isolated checkouts. Preparing a plan does not grant new source or tool access.

## Wave Formalization

This pass also runs alone when Ralph receives a sketched current wave.

7. Give the current wave testable acceptance criteria, expected source boundary,
   meaningful verification, review expectations, stop conditions, and useful
   slice breakdown. Detail only what current evidence supports. Record exact
   design/revision references and relevant assumed contracts.
8. Write lane `active-work.md` only when durable continuity or explicit checkout
   ownership requires it. Group work includes its target, wave list, integrating
   review, and lane binding. Optional `task-queue.md` is for pending work that
   must survive beyond native session tasks, with group review before acceptance.
9. Planning is ready when the selected boundary has an executable scope and
   verifiable acceptance, source/access/ownership are understood, related
   assumptions agree, and risk authority is satisfied. Later sketches do not
   prevent formalizing and executing the current authorized boundary.

## Planning Checkpoint

Publish meaningful planning outcomes through `piper-record`. Record a concise
ledger entry when planning changes future work; create a context packet only at
resume triggers. Commit useful completed or paused continuity per STATION unless
the user requests otherwise, without repeated artifact-commit asks. Keep hub and
source commits separate and disclose actual state.

Stop before implementation unless the user already asked to proceed. If the goal
includes execution, move into Ralph after formalization and required authority;
do not ask again simply because a planning phase ended. Registration never
creates work records, and planning never makes source edits.
