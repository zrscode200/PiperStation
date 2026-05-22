---
name: review
description: Use when reviewing a plan, diff, branch, pull request, architecture choice, security-sensitive change, or implementation against project context.
---

# Review

Use this skill when the user asks for review or when an implementation loop
needs a focused quality pass. Review has two stages: first check whether the
work builds the right thing, then check whether it is built well.

## Review Stance

Lead with findings. Prioritize correctness bugs, behavioral regressions,
security issues, missing verification, and mismatches with the user's request
or project context.

## Workflow

1. Read `AGENTS.md`, `STATION.md`, and the active project record.
2. Read relevant `projects/<id>/work/` files when present, especially
   `active-spec.md`, `active-plan.md`, `task-queue.md`, and
   `context-pack.md`.
3. Inspect the real repo state, changed files, and relevant docs.
4. Stage 1: compare the work against the user request, approved spec, active
   plan, task queue, non-goals, decisions, and verification evidence.
5. Stage 2: review correctness, regressions, security, test coverage,
   maintainability, reliability, and project conventions.
6. Report findings ordered by severity with file and line references when
   available.
7. If there are no findings, say so and note remaining test gaps or residual
   risk.

Use `SECURITY.md` for security-sensitive work and `automation-policy.md` before
any review follow-up that mutates git, remotes, CI, or external systems.
