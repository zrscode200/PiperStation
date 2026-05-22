# Automation Policy

Default stance: local inspection and documented verification are allowed;
actions that mutate git history, external systems, dependency state, CI, or
deployment state require approval.

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
