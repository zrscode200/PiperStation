---
name: hub-workflow
description: Use when registering projects or working from a Piper Station hub across registered project repos.
---

# Hub Workflow

Use this skill whenever project work is coordinated from a Piper Station
hub-lite directory.

Read `AGENTS.md` and `STATION.md` first. Use the other root docs as
the canonical reference layer when product, architecture, convention, testing,
security, or automation-policy details matter.

## Register

1. Validate that the target path is a git repo.
2. Register with `./bin/add-project` or the deterministic helper:

   ```sh
   ./bin/add-project --repo <repo-path> --project-id <project-id>
   ```

3. Registration only creates or updates hub project records and optional repo
   markers. It must not start implementation work.
4. Do not manually recreate the helper's file writes in a prompt.

## Work

1. Read `AGENTS.md` and `STATION.md`.
2. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md`.
3. Read the repo path from the `Path:` line in `project.md`'s
   `<!-- piper-project:start -->` registry block.
4. Read `projects/<project-id>/work/context-pack.md` when it exists.
5. Inspect the real repo path with `git status`, current branch, current HEAD,
   and the files relevant to the request.
6. If the project repo is outside the current workspace or sandbox, ask the user to make it accessible before editing.
7. Treat uncommitted changes as user-owned unless the user says otherwise.
8. Route the request through Intent, Superpowers, Ralph, Review, or Finish
   Mode. See `STATION.md`.
9. Implement in the real repo using normal Codex behavior.
10. Run the narrowest meaningful verification.

## Durable Context

Update hub records only when useful:

- `memory.md`: durable facts, user preferences, stable repo conventions, and
  reusable context.
- `decisions.md`: meaningful choices, tradeoffs, accepted risks, or policy
  decisions future work should not silently reopen.

Routine progress, command output, and transient notes should stay in the
conversation unless substantial active work needs continuity under
`projects/<project-id>/work/`.

Create `projects/<project-id>/work/` only when useful. Registration must not
create active work artifacts.

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Do not add sessions, checkpoints, dashboards, queue managers, or lifecycle
  shell workflows.
- Keep planning, Ralph, review, and compaction as prompt and skill behavior.
  The deterministic shell helper is for project registration.
- Do not commit, push, merge, delete, install dependencies, or run external
  automation without explicit user approval; see `automation-policy.md`.
