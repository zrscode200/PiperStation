---
name: automation-policy
description: Use when the next action is `external` (push, pull request, dependency install or update, networked command with effects, CI) or `exceptional` (force push, history rewrite, deleting branches, worktrees, or user data, discarding changes, secrets, production deploys) — the one action-boundary check that asks, checks standing policy notes, and records the go-ahead. Routine work never routes here.
---

# Automation Policy

Use this skill for one thing: the action-boundary check before an `external`
or `exceptional` action. It does not choose Piper phases, create work
artifacts, run Ralph, or change when commits, pull requests, installs, or CI
actions should happen.

`automation-policy.md` is the canonical global policy. This skill is the
action-boundary check that applies it.

Use this in the root session. Permission decisions and exceptional actions are
not delegated to a subagent because approval, risk, and external state changes
must stay visible to the user.

Do not use this skill for ordinary local inspection, planning, implementation,
or review. Registered project source edits are routine, and so are local
checks, local commits on the lane's branch, and path-scoped hub artifact
commits — never `git add -A` or `commit -a` in the shared hub checkout.
Non-destructive worktree creation or switching is routine; deleting worktrees
is `exceptional`. Routine actions proceed when the workflow reaches them;
nothing routes here for them.

## Workflow

1. Classify the next action as routine, `external`, or `exceptional` using
   `automation-policy.md`. Routine: proceed.
2. For `external`, read `projects/<project-id>/project.md` for a standing
   policy note that names this action class and target. If one exists, state
   it and proceed. Otherwise ask once: name the action, the target (remote and
   branch, pull request, dependency, or network destination), the risk, and
   the rollback or recovery path, then wait. A broad request such as "finish
   this" is never a go-ahead; a user instruction that names the action and
   target is.
3. For `exceptional`, restate the action and wait for a fresh explicit
   instruction every time. `exceptional` actions can never be pre-approved.
4. Record the go-ahead and the action in the lane's `build-log.md`, in the
   next entry the lane writes; an `external` action outside any open wave
   writes a one-line finish entry in the project `build-log.md`. Never record
   approvals in `project.md`.
5. Write a standing policy note in `projects/<project-id>/project.md` only
   when the user says so, verbatim and dated; never infer one from a one-off
   go-ahead.
6. If the harness blocks a routine action, state the access needed and wait
   for the user to grant it; do not edit bootstrap-managed runtime config files
   and do not add hooks as a Piper gate.
7. Change root `automation-policy.md` only when the user is updating the
   global shared policy for the hub, not for a project-specific note.

## Guardrails

- Action classes decide whether an action needs an ask; risk tiers decide
  whether Ralph confirms before editing. Neither changes Piper's phase
  routing, artifact checkpoints, Ralph review gates, or finish behavior.
- "finish this" is never a go-ahead for a push, merge to a remote, pull
  request, install, discard, or external automation.
- A standing grant removes the ask, not the step.
- Where the harness gate is disabled, the asks here are the only gate.
