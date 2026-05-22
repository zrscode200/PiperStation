---
name: superpowers-planning
description: Use when a registered project request needs discovery, scope/risk classification, a spec, an implementation plan, or a Ralph-ready task queue before implementation.
---

# Superpowers Planning

Use this skill before substantial implementation. It carries the Superpowers
discipline as hub-lite agent behavior: discover the request, classify scope and
risk, write a spec when warranted, and turn the spec into a Ralph-executable
plan.

## Workflow

1. Read `CLAUDE.md`, `STATION.md`, and the active project record.
2. Inspect the real project repo enough to ground the request in current code.
3. Classify scope:
   - `S0`: direct small task; no artifact needed
   - `S1`: short active plan in `projects/<id>/work/active-plan.md`
   - `S2`: written spec and plan required before implementation
   - `S3`: split into milestones or sub-specs
4. Classify risk:
   - `L0`: trivial or local
   - `L1`: normal implementation
   - `L2`: needs explicit user confirmation before Ralph executes
   - `L3`: forbidden inside Ralph; stop and ask
5. Ask only blocking clarification questions. If you cannot articulate what
   answer would change the design, do not ask.
6. For `S1+`, create or update useful files under `projects/<id>/work/`.
7. For `S2+`, write a concise spec and implementation plan before execution.
   Prefer `projects/<id>/work/specs/` and `projects/<id>/work/plans/` unless
   the project repo has its own established docs location.
8. Build `projects/<id>/work/task-queue.md` only when there is a ready Ralph
   execution queue.
9. Update `projects/<id>/work/context-pack.md` with compact reload state.
10. Stop before implementation unless the user explicitly asks to proceed.

## Work Artifacts

Create only when useful:

- `active-spec.md`
- `active-plan.md`
- `task-queue.md`
- `context-pack.md`
- `progress.md`
- `verification.md`
- `handoff.md`
- `specs/`, `plans/`, and `runs/` for substantial work

Registration must not create these files. Keep stable facts in `memory.md` and
durable decisions in `decisions.md`.

## Spec Shape

Include problem or opportunity, goals and non-goals, users and workflows,
proposed behavior, acceptance criteria, approach and tradeoffs, risks and
guardrails, verification expectations, and open questions.

## Task Shape

Each queued Ralph task should include id, title, status, risk, likely files or
areas, acceptance criteria, verification command or documented fallback,
expected diff boundary, context needed by a fresh session or reviewer, and
dependencies.

## Guardrails

- Do not implement while discovering or planning.
- Keep Superpowers as Claude Code-native prompt and skill behavior. Do not
  introduce shell lifecycle machinery for planning.
- Mark assumptions separately from confirmed facts.
- Keep plans concrete enough for a fresh Claude Code session to continue cold.
- Do not store secrets or sensitive raw logs in hub records.
- Record meaningful approach, scope, risk, or verification decisions in
  `projects/<id>/decisions.md`.
- "Make it better" is not an acceptance criterion; force a testable one.
