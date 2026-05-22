# Architecture

A generated Piper Station hub contains shared docs, shared project records, and
one or more runtime surfaces. `projects/` is never overwritten or pruned by
bootstrap.

## Hub Shape

```text
piper-station-hub/
  STATION.md
  PRODUCT.md
  ARCHITECTURE.md
  CONVENTIONS.md
  TESTING.md
  SECURITY.md
  automation-policy.md
  AGENTS.md              # Codex runtime, when installed
  CLAUDE.md              # Claude Code runtime, when installed
  .codex/                # Codex config, hooks, agents
  .piper/plugin/         # Codex plugin commands and skills
  .claude/               # Claude commands, skills, agents, hooks
  .piper/lib/            # shared deterministic helpers
  bin/add-project
  projects/
```

## Ownership

Bootstrap manages generated hub files outside `projects/`. Project records
under `projects/` are hub-owned and preserved across refreshes. Registered
project repos own source code, tests, repo-local docs, and optional marker
files.

## Runtime Boundary

The hub is not a workflow engine. It provides project records, prompt commands,
skills, hooks, and optional active work artifacts. Planning, implementation,
review, testing, subagents, handoff, and git operations stay native to the
active runtime.

Optional active artifacts may be created under `projects/<id>/work/` only when
useful: `active-spec.md`, `active-plan.md`, `task-queue.md`, `context-pack.md`,
`progress.md`, `verification.md`, `handoff.md`, and optional `specs/`, `plans/`,
and `runs/`.

Registration must not create active work artifacts.
