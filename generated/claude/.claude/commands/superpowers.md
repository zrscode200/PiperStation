---
description: Enter Superpowers Mode for discovery, specification, and planning
argument-hint: "<project-id> [request]"
---

# Superpowers

Enter Superpowers Mode for a registered project.

The user invoked this command with: `$ARGUMENTS`

Use Superpowers Mode for discovery, specification, planning, and Ralph-ready
task decomposition before substantial implementation.

## Steps

1. Read `CLAUDE.md`, `STATION.md`, and the relevant project record.
2. Identify the project id or repo path from `$ARGUMENTS`.
3. Inspect the real repo enough to ground discovery in current code.
4. Classify scope as `S0`, `S1`, `S2`, or `S3`.
5. Classify risk as `L0`, `L1`, `L2`, or `L3`.
6. Ask only blocking clarification questions.
7. For `S1+`, create or update only useful active work files under
   `projects/<project-id>/work/`.
8. For `S2+`, write a concise spec and implementation plan before execution.
9. Produce a Ralph-ready `task-queue.md` only when tasks are clear and
   verifiable.
10. Update `context-pack.md` with compact-safe reload state when active work
    records are in use.
11. Stop before implementation unless the user explicitly asks to proceed.

Registration must not create `projects/<project-id>/work/`; Claude Code
creates these files only when useful for active work. Keep Superpowers as
Claude Code-native prompt and skill behavior; do not introduce shell lifecycle
machinery for planning.
