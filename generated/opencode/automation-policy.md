# Automation Policy

Default stance: local inspection and documented verification are allowed;
actions that mutate git history, external systems, dependency state, CI, or
deployment state require approval.

This file is the canonical global policy. Project-specific automation opt-ins,
one-off approvals, accepted risks, and protected-action decisions belong in
`projects/<project-id>/decisions.md`. Change this root policy only for global
shared rules that should apply across the hub.

## Tiers

- `A0` allowed local assistance: inspect files, read diffs, run documented local
  checks, update hub work records, draft messages.
- `A1` ask before acting: commit locally, create or switch worktrees, install
  dependencies, run networked or long-running local commands.
- `A2` explicit opt-in required: push, open or update pull requests, merge,
  re-run CI, enable CI repair automation, delete branches or worktrees.
- `A3` forbidden by default: force push, rewrite shared history, touch secrets,
  delete user data, deploy production, perform irreversible external actions.

Absence of an opt-in means automation is not enabled. Do not treat broad
requests like "finish this" as permission to push, merge, open a PR, discard
changes, or run external automation.

Updating Piper artifacts under `projects/<project-id>/work/` is `A0` local
assistance. Committing those artifact updates in the Piper Station hub is `A1`
and must be approved separately from any registered project source commit.
