# Automation Policy

Default stance: permission profiles gate action categories only. They do not
change Piper Station's phase routing, artifact checkpoints, Ralph review gates,
or when a workflow should perform an action.

This file is the canonical global policy. Project-specific profile preferences,
one-off approvals, accepted risks, and permission decisions belong in
`projects/<project-id>/project.md`. Change this root policy only for global
shared rules that should apply across the hub.

## Permission Profiles

- `strict`: read-only inspection, planning, review, safe git status/log/diff
  style commands, deterministic registration, and drafting messages.
- `local`: `strict` plus registered project source edits, Piper artifact
  updates, local checks/build/test, non-destructive worktree create or switch
  operations, and non-destructive local git actions such as add or commit when
  the workflow has reached that action.
- `external`: `local` plus dependency install or update, networked commands,
  push, pull request creation or update, CI reruns or repair, and other
  non-destructive external-system actions.
- `exceptional`: outside profiles. Force push, shared-history rewrite, secret
  handling, deleting branches, worktrees, or user data, production deploys, and
  irreversible external actions always require explicit one-off approval.

Absence of a recorded project preference means use `strict`. Do not treat broad
requests like "finish this" as permission to push, merge, open a pull request,
discard changes, install dependencies, or run external automation.

## Application

The active permission profile is a gate, not a trigger. A profile can allow an
action category, but Piper still follows the existing workflow checkpoint
before taking that action.

Ralph implementation edits are `local` permission actions. If no project
preference records `local` or stronger profile coverage, Ralph must route
through `automation-policy` before editing project source.

Record durable project preferences in `projects/<project-id>/project.md`.
For v1, applying a profile is session-level guidance plus the active runtime's
own permission controls; do not edit bootstrap-managed runtime config files or
add hooks as the profile gate. If a runtime permission mode must change, state
the needed session-level change and wait for the runtime or user to apply it.

Piper artifact updates under `projects/<project-id>/work/` are local
assistance while work is active. Committing those artifact updates in the Piper
Station hub is a `local` permission action and stays separate from any
registered project source commit.

Non-destructive worktree creation or switching is `local`; deleting worktrees
is `exceptional`.
