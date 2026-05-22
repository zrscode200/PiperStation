---
name: superpowers-planning
description: Use when a registered project request needs Superpowers-style discovery, scope/risk classification, a spec, an implementation plan, or a Ralph-ready task queue before implementation.
---

# Superpowers Planning

Use this skill before substantial implementation. It carries the Superpowers discipline as hub-lite agent behavior: discover the request, classify scope and risk, write a spec when warranted, and turn the spec into a Ralph-executable plan.

## Workflow

1. Read `CLAUDE.md` and the active project record (`project.md`, `memory.md`, `decisions.md`).
2. Inspect the real project repo enough to ground the request in current code.
3. Classify scope (S0–S3) and risk (L0–L3). See `CLAUDE.md` for tier definitions.
4. Ask only blocking clarification questions, one at a time. If you cannot articulate what answer would change the design, do not ask.
5. For `S1+`, create or update useful files under `projects/<id>/work/`.
6. For `S2+`, write a concise spec and implementation plan before execution. Prefer `projects/<id>/work/specs/` and `projects/<id>/work/plans/` unless the project repo has its own established docs location.
7. Build `projects/<id>/work/task-queue.md` only when there is a ready Ralph execution queue.
8. Update `projects/<id>/work/context-pack.md` with compact reload state.
9. Stop before implementation unless the user explicitly asks to proceed.

## Work Artifacts

Create only when useful (on demand, not at registration):

- `active-spec.md`
- `active-plan.md`
- `task-queue.md`
- `context-pack.md`
- `progress.md`
- `verification.md`
- `handoff.md`
- `specs/`, `plans/`, `runs/` for substantial work

Keep stable facts in `memory.md` and durable decisions in `decisions.md`.

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

## Task Shape (for Ralph)

Each queued task should include:

- id
- title
- status (`pending` | `active` | `blocked` | `done`)
- risk: `L0`, `L1`, `L2`, or `L3`
- files or areas likely to change
- acceptance criteria
- verification command or documented fallback
- expected diff boundary
- context needed by a fresh session or reviewer
- dependencies

## Guardrails

- Do not implement while discovering or planning.
- Keep Superpowers as Claude-native prompt and skill behavior. Do not introduce
  shell lifecycle machinery for planning.
- Mark assumptions separately from confirmed facts.
- Keep plans concrete enough for a fresh Claude Code session to continue cold.
- Do not store secrets or sensitive raw logs in hub records.
- Record meaningful approach, scope, risk, or verification decisions in `projects/<id>/decisions.md`.
- "Make it better" is not an acceptance criterion — force a testable one.
