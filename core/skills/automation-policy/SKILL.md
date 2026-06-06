---
name: automation-policy
description: Use when the user, piper-workflow, or a command is about to commit, use worktrees, open pull requests, run CI repair loops, install dependencies, run networked commands, take destructive git actions, or mutate external state.
---

# Automation Policy

Use this skill before commits, worktrees, pull requests, CI repair loops,
dependency installs, networked commands, destructive git actions, or other
automation that mutates project or external state.

`automation-policy.md` is the canonical global policy. This skill is the
protected-action execution checklist and approval gate.

Use this in the root session. Protected automation is not delegated to a
subagent because approval, risk, and external state changes must stay visible
to the user.

Do not use this skill for ordinary local inspection, planning, implementation,
or review unless the next action would mutate git history, dependencies, CI, an
external system, or other protected state.

## Workflow

1. Read `{{INSTRUCTION_DOC}}`, `STATION.md`, and `automation-policy.md`.
2. Classify the proposed action with the A-tier rules in
   `automation-policy.md`.
3. Check whether the target repo has an explicit opt-in for the action.
4. If approval is needed, state the action, affected branch/files/worktree/PR
   or external system, reason, risk, and rollback or recovery path.
5. Record project-specific opt-ins, one-off approvals, accepted risks, or
   protected-action decisions in `projects/<project-id>/decisions.md` when the
   action changes commit, PR, worktree, CI, dependency, network, destructive, or
   external-system behavior.
6. Change root `automation-policy.md` only when the user is updating the global
   shared policy for the hub, not for a project-specific approval.

## Guardrails

- Absence of an opt-in means the automation is not enabled.
- Do not treat a broad request like "finish this" as permission to push, merge,
  open a PR, or discard changes.
- For destructive or external actions, restate the action and wait for explicit
  user instruction.
- Do not leave automation opt-ins only in conversation history; record durable
  project decisions in `projects/<project-id>/decisions.md`.
