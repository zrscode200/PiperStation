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
  opencode.json          # OpenCode runtime, when installed
  .codex/                # Codex skills, command references, config, hooks, agents
  .claude/               # Claude commands, skills, agents, hooks
  .opencode/             # OpenCode commands, skills, agents
  .piper/lib/            # shared deterministic helpers
  bin/add-project
  projects/
    <project-id>/work/design/
      README.md          # project design index, when design work exists
      <topic>.md         # optional lightweight design note
      <studio-slug>/     # optional full Design Studio
        README.md        # studio navigation
        design.md        # canonical design and accepted revision
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
useful: `roadmap.md`, `active-work.md`, `build-log.md`, `context-pack.md`,
optional `task-queue.md`, lightweight design notes under
`work/design/<topic>.md`, and full studios under
`work/design/<studio-slug>/`. A full studio reuses those existing Piper work
owners rather than creating a parallel lifecycle: `design.md` owns only the
integrated design and revision, while the two README layers are navigation.
See `STATION.md` for temporal roles (accumulative sinks vs current windows vs
topical references), fact ownership, and the rule that git is the source of
truth for commit and HEAD history.

Registration must not create active work artifacts.
