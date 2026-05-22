---
name: automation-policy
description: Use before commits, worktrees, pull requests, CI repair loops, dependency installs, networked commands, or other automation that mutates project or external state.
---

# Automation Policy

Use this skill before commits, worktrees, pull requests, CI repair loops,
dependency installs, networked commands, destructive git actions, or other
automation that mutates project or external state.

`automation-policy.md` is the canonical policy. This skill is the short
execution checklist.

## Workflow

1. Read `CLAUDE.md`, `STATION.md`, and `automation-policy.md`.
2. Classify the proposed action:
   - `A0`: allowed local assistance
   - `A1`: ask before acting
   - `A2`: explicit opt-in required
   - `A3`: forbidden by default
3. Check whether the target repo has an explicit opt-in for the action.
4. If approval is needed, state the action, affected branch/files/worktree/PR
   or external system, reason, risk, and rollback or recovery path.
5. Record durable opt-ins or policy changes in `automation-policy.md`.
6. Record the decision in `projects/<project-id>/decisions.md` when the action
   changes commit, PR, worktree, CI, dependency, network, destructive, or
   external-system behavior.

## Default Classifications

`A0`: inspect files/diffs/status, run documented local checks, update work
records, draft messages.

`A1`: commit locally, create or switch worktrees, install dependencies, run
networked or long-running local commands.

`A2`: push, open or update PRs, merge, re-run CI, enable CI repair automation,
delete branches or worktrees.

`A3`: force push, rewrite shared history, touch secrets, delete user data,
deploy production, perform irreversible external actions.

## Guardrails

- Absence of an opt-in means the automation is not enabled.
- Do not treat a broad request like "finish this" as permission to push, merge,
  open a PR, or discard changes.
- For destructive or external actions, restate the action and wait for explicit
  user instruction.
- Do not leave automation opt-ins only in conversation history; record durable
  policy choices in the decision ledger.
