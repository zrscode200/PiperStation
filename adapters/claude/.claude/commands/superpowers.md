---
description: Enter Superpowers mode for a registered project — discovery, spec, plan.
argument-hint: <project-id> [request]
---

You are entering Superpowers Mode for a registered project on this Piper Station hub.

The user invoked `/superpowers $ARGUMENTS`.

Parse `$ARGUMENTS`:
- first token: `<project-id>` (required)
- remainder (optional): the request

If `<project-id>` is missing, stop with usage.

## Steps

1. **Read `CLAUDE.md`** and the project record (`projects/<project-id>/{project,memory,decisions}.md`).
2. **Inspect the real repo** at the registered path. Ground discovery in current code.
3. **Invoke the `superpowers-planning` skill.** It carries the full Superpowers discipline.
4. **Classify scope** (`S0`/`S1`/`S2`/`S3`) and **risk** (`L0`/`L1`/`L2`/`L3`).
5. Ask only blocking clarification questions, one at a time.
6. For `S1+`, create or update useful files under `projects/<project-id>/work/` (create the directory if it does not exist).
7. For `S2+`, write a concise spec and implementation plan before execution.
8. Build `projects/<project-id>/work/task-queue.md` only when tasks are clear and verifiable.
9. **Stop before implementation** unless the user explicitly asks to proceed.

## Rules

- Registration does not create `projects/<id>/work/`; this command may.
- Do not implement while planning.
- Record meaningful approach, scope, or verification decisions in `projects/<project-id>/decisions.md`.
- Do not commit, push, install, or run external automation — see `automation-policy`.
- This command is Claude-native prompt and skill behavior. Do not replace it
  with a shell workflow or generated session engine.
