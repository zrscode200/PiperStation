---
name: hub-workflow
description: Use when registering projects or working from a Piper Station hub across registered project repos. Routes requests through the hub modes.
---

# Hub Workflow

Use this skill whenever project work is coordinated from this Piper Station hub.

Read `CLAUDE.md` first. It is the canonical reference for hub guardrails, project record shape, mode routing, scope/risk/automation tiers, and parallel-session rules.

## Register

1. Validate the target path is a git repo.
2. Run `/add-project <repo-path> [project-id]` from the hub, or run the
   deterministic helper directly:

   ```sh
   ./bin/add-project --repo <repo-path> --project-id <project-id>
   ```

3. Registration only creates or updates hub project records. It must not start implementation work.
4. Do not manually recreate the helper's file writes in a prompt.

## Work

1. Read `CLAUDE.md`.
2. Read `projects/<project-id>/{project,memory,decisions}.md`.
3. Read the repo path from the `Path:` line in `project.md`'s
   `<!-- piper-project:start -->` registry block.
4. Read `projects/<project-id>/work/context-pack.md` if it exists.
5. Inspect the real repo path with `git status`, current branch, current HEAD, and the files relevant to the request.
6. If the repo is outside the hub, ensure Claude Code has workspace access
   through `/add-dir <repo-path>` or `claude --add-dir <repo-path>` before
   editing.
7. Treat uncommitted changes as user-owned unless the user says otherwise.
8. Route the request through the hub modes (Intent → Superpowers / Ralph / Review / Finish). See `CLAUDE.md`.
9. Implement in the real repo using normal Claude Code behavior.
10. Run the narrowest meaningful verification.

## Durable Context

Update hub records only when useful:

- `memory.md` — durable facts, user preferences, stable repo conventions, reusable context.
- `decisions.md` — meaningful choices, tradeoffs, accepted risks, policy decisions future work should not silently reopen.

Routine progress, command output, and transient notes stay in the conversation unless substantial active work needs continuity under `projects/<project-id>/work/`.

Create `projects/<project-id>/work/` only when useful. Registration must not create active work artifacts.

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Do not add sessions, checkpoints, dashboards, queue managers, or lifecycle shell workflows.
- Keep planning, Ralph, review, and compaction as prompt and skill behavior.
  The deterministic shell helper is for project registration.
- Do not commit, push, merge, delete, install dependencies, or run external automation without explicit user approval — see `automation-policy`.
