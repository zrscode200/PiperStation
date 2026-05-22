---
name: review
description: Use when reviewing a plan, diff, branch, pull request, architecture choice, security-sensitive change, or implementation against project context.
---

# Review

Use this skill when the user asks for review or when an implementation loop needs a focused quality pass. Review has two stages: first check whether the work builds the right thing, then check whether it is built well.

## Review Stance

Lead with findings. Prioritize correctness bugs, behavioral regressions, security issues, missing verification, and mismatches with the user's request or project context. Be specific, not generic.

## Workflow

1. Read `CLAUDE.md` and the active project record (`project.md`, `memory.md`, `decisions.md`).
2. Read relevant `projects/<id>/work/` files when present, especially `active-spec.md`, `active-plan.md`, `task-queue.md`, and `context-pack.md`.
3. Inspect the real repo state, changed files, and relevant docs.
4. **Stage 1 — Spec compliance.** Compare the work against the user request, approved spec, active plan, task queue, non-goals, decisions, and verification evidence. Did we build the right thing, and nothing material outside it?
5. **Stage 2 — Code quality.** Review correctness, regressions, security, test coverage, maintainability, reliability, and project conventions. Is the implementation good?
6. Report findings ordered by severity with file and line references when available.
7. If there are no findings, say so — and note remaining test gaps or residual risk.

## Output

A list of findings with the two stages labeled separately, plus a verdict: `pass`, `pass-with-notes`, or `revise`. For each `revise` finding, name the specific change you want and where (file + line).

## Rules

- Do not edit files. Reviewers report; implementers fix.
- Review is Claude-native prompt behavior. Do not create shell review
  orchestrators or mutate git state as part of review.
- Do not invent issues to look thorough — empty `pass` is a valid verdict.
- Use the `automation-policy` skill before any review follow-up that mutates git, remotes, CI, or external systems.
