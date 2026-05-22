---
name: superpowers-planning
description: Use when a registered project request needs Superpowers-style discovery, scope/risk classification, a spec, an implementation plan, or a Ralph-ready task queue before implementation.
---

# Superpowers Planning

Use this skill before substantial implementation. It guides discovery, specs,
plans, and Ralph-ready task queues from the hub.

## Workflow

1. Read `AGENTS.md`, `STATION.md`, and the active project record.
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
5. Ask only blocking clarification questions.
6. For `S1+`, create or update only the useful files under
   `projects/<id>/work/`.
7. For `S2+`, write a concise spec and implementation plan before execution.
   Prefer `projects/<id>/work/specs/` and `projects/<id>/work/plans/` unless
   the project repo has its own established docs location.
8. Build `projects/<id>/work/task-queue.md` only when there is a ready Ralph
   execution queue.
9. Update `projects/<id>/work/context-pack.md` with compact reload state.
10. Stop before implementation unless the user explicitly asks to proceed.

## Work Artifacts

Create these only when useful:

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

## Artifact Examples

- Small direct fix: no `work/` artifact is needed.
- Short multi-step change: use `active-plan.md` and `context-pack.md`.
- Substantial feature or refactor: use `active-spec.md`, `active-plan.md`,
  `task-queue.md`, and `context-pack.md`.

## Spec Shape

Include:

- problem or opportunity
- goals and non-goals
- users and workflows
- proposed behavior
- acceptance criteria
- approach and tradeoffs
- risks and guardrails
- verification expectations
- open questions

## Task Shape

Each queued Ralph task should include:

- id
- title
- status
- risk: `L0`, `L1`, `L2`, or `L3`
- files or areas likely to change
- acceptance criteria
- verification command or fallback
- expected diff boundary
- context needed by a fresh session or reviewer
- dependencies

## Guardrails

- Do not implement while discovering or planning.
- Mark assumptions separately from confirmed facts.
- Keep plans concrete enough for a fresh Codex session to continue.
- Do not store secrets or sensitive raw logs in hub records.
- Record meaningful approach, scope, risk, or verification decisions in
  `projects/<id>/decisions.md`.
