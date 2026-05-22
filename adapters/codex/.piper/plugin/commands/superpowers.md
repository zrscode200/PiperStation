---
description: Enter Superpowers discovery, specification, and planning for a registered project.
argument-hint: [project id or repo path and request]
allowed-tools: [Read, Write, Bash]
---

# Superpowers Mode

Use this command from a Piper Station hub-lite directory.

The user invoked this command with: $ARGUMENTS

## Instructions

1. Read `AGENTS.md`, `STATION.md`, and the relevant project record.
2. Identify the project id or repo path from `$ARGUMENTS`.
3. Inspect the real repo enough to ground discovery in current code.
4. Classify scope as `S0`, `S1`, `S2`, or `S3`.
5. Classify risk as `L0`, `L1`, `L2`, or `L3`.
6. For `S1+`, create or update useful active work files under
   `projects/<project-id>/work/`.
7. For `S2+`, write a concise spec and implementation plan before execution.
8. Produce a Ralph-ready `task-queue.md` only when tasks are clear and
   verifiable.
9. Stop before implementation unless the user explicitly asks to proceed.

Registration must not create `projects/<project-id>/work/`; Codex creates
these files only when useful for active work.
