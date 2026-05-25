---
description: Orient to a registered project and route the request through Intent, Superpowers, Ralph, Review, or Finish modes
argument-hint: "<project-id> [request]"
---

# Work On

Orient to a registered project and route the request through the smallest safe
Piper mode.

The user invoked this command with: `$ARGUMENTS`

`/work-on` is an explicit shortcut for `piper-workflow` routing. Ordinary
natural-language project work can route through `piper-workflow` without this
command; when invoked, follow the same dispatch logic here.

## Steps

1. Read `CLAUDE.md` and `STATION.md`.
2. Identify the project id or repo path from `$ARGUMENTS`. If the project is
   not registered, ask whether to run `./bin/add-project --repo <path>
   --project-id <id>` first.
3. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md`.
   Extract the repo path from the `Path:` line inside the
   `<!-- piper-project:start -->` registry block.
4. Read `projects/<project-id>/work/context-pack.md` when present.
5. Inspect the real repo path with `git status --short`, current branch,
   current HEAD, and the files relevant to the request.
6. If the repo is outside the hub, ensure Claude Code has workspace access through `/add-dir <repo-path>` or `claude --add-dir <repo-path>` before editing.
7. State uncommitted or recent user changes that affect the task. Treat them as
   user-owned unless the user says otherwise.
8. Classify intent, scope, and risk:
   - `S0` direct work can proceed with a short plan.
   - `S1` should use a short active plan when continuity is useful.
   - `S2+` or ambiguous substantial work should enter Superpowers Mode first.
   - A ready queue can enter Ralph Mode for one scoped task.
   - Review requests should enter Review Mode.
   - Commit, PR, dependency, network, CI, destructive, or external automation
     requests should use the automation approval flow.
9. State the chosen mode and next concrete action. Proceed naturally when the
   route is clear and safe; wait for go-ahead when confirmation is required,
   risk is `L2`, the request is ambiguous, or the user asked only for
   orientation.

Rules:

- Do not create `projects/<id>/work/` unless active continuity is genuinely
  useful.
- Do not commit, push, install dependencies, or run external automation without
  explicit user approval; see `automation-policy.md`.
- Do not start implementation as a side effect of orientation.
- This command is prompt-driven routing, not a shell workflow engine.
