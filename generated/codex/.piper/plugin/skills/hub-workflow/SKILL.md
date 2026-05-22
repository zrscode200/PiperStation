---
name: hub-workflow
description: Use when orienting inside a Piper Station hub, registering projects, routing work, or deciding which mode should handle a request.
---

# Hub Workflow

Use this skill when the user asks to work from a Piper Station hub.

1. Read `AGENTS.md` and `STATION.md`.
2. Identify the registered project and read `projects/<id>/project.md`, `memory.md`, and `decisions.md`.
3. Read `projects/<id>/work/context-pack.md` when present.
4. Inspect the real project repo path before editing.
5. Route through Intent, Superpowers, Ralph, Review, or Finish Mode.

Register projects with `./bin/add-project`. Registration is deterministic and must not create `work/` or edit project source beyond optional repo marker files.

For Claude Code, ensure workspace access with `/add-dir <repo-path>` or an equivalent launch option before editing repos outside the hub.
