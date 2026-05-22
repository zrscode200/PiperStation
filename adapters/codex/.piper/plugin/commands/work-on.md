---
description: Work on a registered project from a Piper Station hub-lite workspace.
argument-hint: [project id or repo path and task]
allowed-tools: [Read, Bash]
---

# Work On Project

Use this command from a Piper Station hub-lite directory.

The user invoked this command with: $ARGUMENTS

## Instructions

1. Read `AGENTS.md` and `STATION.md`.
2. Identify the project id or repo path from `$ARGUMENTS`.
3. If the project is not registered, ask whether to run
   `./bin/add-project --repo <path> --project-id <id>`.
4. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md`.
5. Inspect the real repo with `git status --short`, current branch, current
   HEAD, and the files relevant to the task.
6. State any user/manual changes that affect the task.
7. Classify intent, scope, and risk:
   - direct `S0/L0` work can proceed with a short plan
   - substantial work should enter Superpowers Mode first
   - a ready queue can enter Ralph Mode for one scoped task
   - review requests should enter Review Mode
8. Read `projects/<project-id>/work/context-pack.md` when it exists.
9. Implement in the real project repo only after the mode has a clear next
   action.
10. Update `projects/<project-id>/work/` only when active continuity is useful.
11. Update hub `memory.md` or `decisions.md` only when there is durable context
    worth preserving.

Do not create sessions, checkpoints, dashboards, commits, or source changes as
a side effect of registration.
