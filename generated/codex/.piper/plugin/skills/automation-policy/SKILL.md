---
name: automation-policy
description: Use when classifying whether an action is allowed, needs approval, requires explicit opt-in, or is forbidden by default.
---

# Automation Policy

Use `automation-policy.md` as the canonical policy.

- `A0`: allowed local assistance.
- `A1`: ask before acting.
- `A2`: explicit opt-in required.
- `A3`: forbidden by default.

Ask before commits, pushes, merges, pull requests, dependency installs, worktree changes, long-running or networked commands, destructive git actions, CI changes, deployments, or external automation.
