---
name: hub-workflow
description: Use when registering projects or working from a Piper Station hub-lite workspace across registered project repos.
---

# Hub Workflow

Use this skill whenever project work is coordinated from a Piper Station
hub-lite directory.

Read `AGENTS.md` and `STATION.md` first. Use the other root docs as the
canonical reference layer when product, architecture, convention, testing,
security, or automation-policy details matter.

## Register

1. Validate that the target path is a git repo.
2. Run `./bin/add-project --repo <repo> --project-id <id>` from the hub.
3. Registration only creates or updates hub project records and optional repo
   markers. It must not start implementation work.

## Work

1. Read `AGENTS.md` and `STATION.md`.
2. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md`.
3. Read `projects/<project-id>/work/context-pack.md` when it exists.
4. Inspect the real repo path with git before planning.
5. Treat uncommitted changes as user-owned unless the user says otherwise.
6. Route the request through the hub modes in `STATION.md`: Intent,
   Superpowers, Ralph, Review, and Finish.
7. Implement in the real repo using normal Codex behavior.
8. Run the narrowest meaningful verification.

## Durable Context

Update hub records only when useful:

- `memory.md`: durable facts, user preferences, stable repo conventions, and
  reusable context.
- `decisions.md`: meaningful choices, tradeoffs, accepted risks, or policy
  decisions that future work should not reopen silently.

Routine progress, command output, and transient notes should stay in the
conversation unless substantial active work needs continuity under
`projects/<project-id>/work/`.

Create `projects/<project-id>/work/` only when useful. Registration must not
create active work artifacts.

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Keep active continuity in `projects/<project-id>/work/`; add no additional
  lifecycle state unless explicitly requested.
- Do not commit, push, merge, delete, install dependencies, or run external
  automation without explicit user approval.
