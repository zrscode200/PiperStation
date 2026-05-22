---
description: Orient to a registered project and route the request through Intent → Superpowers / Ralph / Review modes.
argument-hint: <project-id> [request]
---

You are coordinating work on this Piper Station hub.

The user invoked `/work-on $ARGUMENTS`.

Parse `$ARGUMENTS`:
- first whitespace-separated token: `<project-id>` (required)
- remainder (optional): the request

If `<project-id>` is missing, stop with usage.

## Steps

1. **Read `CLAUDE.md`** for hub operating rules, mode routing, and tier definitions.

2. **Invoke the `hub-workflow` skill** as the behavior guide for project
   context discipline.

3. **Check the project is registered.** If `projects/<project-id>/project.md` does not exist, ask whether to run `/add-project <repo-path> <project-id>` first. Stop and wait for the user.

4. **Read the project record.** `project.md`, `memory.md`, `decisions.md`.
   Extract the repo path from the `Path:` line inside the
   `<!-- piper-project:start -->` registry block in `project.md`.

5. **Inspect the real repo.** In the project's repo path:
   - `git status --short`
   - `git branch --show-current`
   - `git rev-parse --short HEAD`
   - Read files relevant to the request.

6. **Confirm workspace access.** If Claude Code was launched from the hub and
   the project repo is outside the hub, make sure the repo is available through
   `/add-dir <repo-path>` or by launching Claude with
   `claude --add-dir <repo-path>`. If it is not available for edits, ask the
   user to add it before implementation.

7. **State uncommitted or recent user changes** that affect the task. Treat them as user-owned unless the user says otherwise.

8. **Read `projects/<project-id>/work/context-pack.md`** if it exists.

9. **Classify the request (Intent Mode).** Determine:
   - scope tier (`S0`/`S1`/`S2`/`S3`)
   - risk tier (`L0`/`L1`/`L2`/`L3`)
   - safe next mode

10. **Route.** Based on the classification:
   - **`S0` + `L0`/`L1`:** make a short task-specific plan and proceed inline. No `work/` artifacts needed.
   - **`S1`:** create or update `projects/<id>/work/active-plan.md`. Proceed with implementation if approved.
   - **`S2`+ or substantial work:** enter **Superpowers Mode** — invoke the `superpowers-planning` skill. Do not implement until the spec and plan are approved.
   - **Ready task queue exists and user wants execution:** enter **Ralph Mode** — invoke the `ralph-loop` skill for one task.
   - **Request is review:** enter **Review Mode** — invoke the `review` skill.

11. **State the chosen mode and the next concrete action** to the user. Wait for go-ahead unless the routing is unambiguous (e.g., `S0`/`L0` direct work the user clearly asked for).

## Rules

- Do not create `projects/<id>/work/` unless active continuity is genuinely useful.
- Do not commit, push, install dependencies, or run external automation without explicit user approval — see `automation-policy`.
- Do not start implementation as a side effect of orientation.
- Treat uncommitted changes in the repo as user-owned unless explicitly told otherwise.
- This command is prompt-driven routing. Do not create a shell workflow helper
  for planning, implementation, review, or compaction.
