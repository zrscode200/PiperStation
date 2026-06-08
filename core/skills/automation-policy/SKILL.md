---
name: automation-policy
description: Use when the user, piper-workflow, or a command needs to choose, record, apply, or check a permission profile, or when the next action crosses the active profile boundary through project source edits, commit, local git mutation, worktree changes, dependency install, network, pull request, CI, destructive git, or external state.
---

# Automation Policy

Use this skill to manage permission profiles and action-boundary checks. It
does not choose Piper phases, create work artifacts, run Ralph, or change when
commits, pull requests, installs, or CI actions should happen.

`automation-policy.md` is the canonical global policy. This skill is the
permission-profile manager and action-boundary gate.

Use this in the root session. Permission decisions and exceptional actions are
not delegated to a subagent because approval, risk, and external state changes
must stay visible to the user.

Do not use this skill for ordinary local inspection, planning, implementation,
or review unless the next action crosses the active profile boundary.

Registered project source edits are `local` permission actions. When the active
project has no recorded profile preference, the default is `strict`, so Ralph
must use this skill before editing source.

Piper artifact updates under `projects/<project-id>/work/` are ordinary local
assistance while active work is in progress. A commit that saves those artifact
updates in the Piper Station hub is a `local` permission action: keep it at the
normal artifact checkpoint, name the project id and artifact files, and keep it
distinct from any registered project source commit.

Non-destructive worktree creation or switching is `local`; deleting worktrees
is `exceptional`.

## Workflow

1. Read `{{INSTRUCTION_DOC}}`, `STATION.md`, and `automation-policy.md`.
2. Identify the active project and read
   `projects/<project-id>/project.md` for a recorded profile preference.
3. Classify the next action as `strict`, `local`, `external`, or
   `exceptional` using `automation-policy.md`.
4. Compare the action category with the active or requested profile. If the
   profile is insufficient, state the action, affected branch/files/worktree,
   pull request, CI target, dependency, network destination, or external
   system, plus the reason, risk, and rollback or recovery path.
5. Record project-specific profile preferences, one-off approvals, accepted
   risks, or permission decisions in `projects/<project-id>/project.md`.
6. For v1, do not edit bootstrap-managed runtime config files and do not add
   hooks as the profile gate. If the active runtime needs a session permission
   change, state the runtime-level change needed and wait for it to be applied.
7. Change root `automation-policy.md` only when the user is updating the global
   shared policy for the hub, not for a project-specific preference.

## Guardrails

- Absence of a recorded project preference means `strict`.
- Do not treat a broad request like "finish this" as permission to push, merge,
  open a pull request, discard changes, install dependencies, or run external
  automation.
- Permission profiles gate action categories; they do not change Piper's phase
  routing, artifact checkpoints, Ralph review gates, or finish behavior.
- `exceptional` is outside standing profiles. For `exceptional` actions,
  restate the action and wait for explicit one-off user instruction.
- Do not leave profile preferences only in conversation history; record durable
  project policy preferences in `projects/<project-id>/project.md`.
