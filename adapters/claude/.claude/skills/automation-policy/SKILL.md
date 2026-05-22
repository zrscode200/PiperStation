---
name: automation-policy
description: Use before creating commits, worktrees, pull requests, CI repair loops, dependency installs, networked commands, or other automation that mutates project or external state.
---

# Automation Policy

Use this skill before any action that mutates project or external state — commits, worktrees, pull requests, CI re-runs, dependency installs, networked commands, destructive git actions, deployments, or other external automation.

`CLAUDE.md` defines the A0/A1/A2/A3 tier system. This skill is the short execution checklist.

## Workflow

1. Read `CLAUDE.md`.
2. Classify the proposed action as `A0`, `A1`, `A2`, or `A3`.
3. Check whether the target project (`projects/<id>/decisions.md`) records an explicit opt-in for this action.
4. If approval is needed, state to the user:
   - action
   - affected branch, files, worktree, PR, CI run, or external system
   - reason
   - risk
   - rollback or recovery path
5. Record durable opt-ins or policy changes in `projects/<id>/decisions.md`.
6. Record the decision in `projects/<id>/decisions.md` when the action changes commit, PR, worktree, CI repair, dependency, network, destructive, or external-system behavior.

## Default Classifications

`A0` — allowed local assistance:
- inspect files / diffs / status
- run documented local checks
- update work records
- draft messages

`A1` — ask before acting:
- commit locally
- create/switch worktrees
- install dependencies
- run networked or long-running local commands

`A2` — explicit opt-in required:
- push
- open / update / merge PRs
- re-run CI
- enable CI repair automation
- delete branches or worktrees

`A3` — forbidden by default:
- force push
- rewrite shared history
- touch secrets
- delete user data
- deploy production
- irreversible external actions

## Guardrails

- Absence of an opt-in means the automation is not enabled.
- Do not treat a broad request like "finish this" as permission to push, merge, open a PR, or discard changes.
- For destructive or external actions, restate the action and wait for explicit user instruction.
- Do not leave automation opt-ins only in conversation history — record durable policy choices in `decisions.md`.
