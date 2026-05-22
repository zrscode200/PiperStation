# Piper Station Hub

This directory is a Piper Station hub-lite workspace. It coordinates assisted
development across registered project repositories using one shared project
ledger and one or more native harness surfaces.

Installed runtime surfaces may include Codex, Claude Code, or both. Runtime
files provide native entry points; project records stay shared under
`projects/`.

## Operating Contract

- Treat this hub as lightweight coordination context, not as a source repo for
  registered projects.
- Do not copy project source code into the hub.
- Register project repos with the native command surface or `./bin/add-project`.
- Registration only updates hub project records and optional repo marker files.
- Work on project source code only in the real repo path recorded in
  `projects/<project-id>/project.md`.
- Keep behavior feedback in shared records when it applies to Piper Station;
  use runtime-specific notes only for harness mechanics.

## Runtime Surfaces

- Codex: `AGENTS.md`, `.codex/`, and `.piper/plugin/`.
- Claude Code: `CLAUDE.md` and `.claude/`.

A hub may have both surfaces installed. Use one harness actively on a project at
a time unless the user explicitly coordinates parallel work.

## Project Records

Each registered project has:

```text
projects/<project-id>/
  project.md
  memory.md
  decisions.md
  work/              # optional, created only when useful during active work
```

`work/` may contain `active-spec.md`, `active-plan.md`, `task-queue.md`,
`context-pack.md`, `progress.md`, `verification.md`, `handoff.md`, and optional
`specs/`, `plans/`, and `runs/`.

Registration must not create `work/`.

## Mode Routing

Route requests through Intent, Superpowers, Ralph, Review, or Finish Mode.
Use the smallest mode that safely handles the request.

Scope tiers: `S0` direct, `S1` short active plan, `S2` written spec and plan,
`S3` split into milestones. Risk tiers: `L0` trivial, `L1` normal, `L2` needs
explicit user confirmation before Ralph executes, `L3` forbidden inside Ralph.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial
slices are implemented and initially verified, before marking the slice complete
in active work records. Review gate selection is based on scope and change
impact. Risk tier controls approval before execution, not review selection.

The main session must verify reviewer findings before acting, apply only valid
in-scope fixes, and reverify review-driven fixes with the narrowest meaningful
command for the fixed behavior.

## Compaction

At natural stopping points, prepare compact-safe state in
`projects/<id>/work/context-pack.md` and, when pausing,
`projects/<id>/work/handoff.md`. Include next exact action, scope boundary,
files to inspect first, verification state, review state, drift result, git
state, blockers, risks, and broad-search triggers.
