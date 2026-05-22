---
description: Prepare a project's work records so the user can safely run /compact without losing Ralph state.
argument-hint: [project-id] [current task]
---

You are preparing a Piper Station project for safe compaction.

The user invoked `/compact-handoff $ARGUMENTS`.

Parse `$ARGUMENTS`:
- first token (optional): `<project-id>` — if omitted, infer from the most recently modified `projects/<id>/` or ask the user which project
- remainder (optional): current task description, to inform the context-pack update

## Steps

1. **Read `CLAUDE.md`** and the project record (`project.md`, `memory.md`, `decisions.md`).
2. **Read relevant files under `projects/<project-id>/work/`** — especially `active-spec.md`, `active-plan.md`, `task-queue.md`, `progress.md`, `verification.md`, `context-pack.md`.
3. **Inspect the real repo** with `git status --short`, `git rev-parse --short HEAD`, and `git diff --stat` enough to summarize changed files and risks.
4. **Update `projects/<project-id>/work/context-pack.md`** with the required compact resume packet below.
5. **Update `projects/<project-id>/work/handoff.md`** with the same compact resume packet when pausing or transferring work.
6. **Report** that the project is compact-ready and tell the user they may run `/compact`.

## Required Compact Resume Packet

`context-pack.md` must include these sections or equivalent clearly labeled
fields:

- Goal
- Last completed task
- Current task status
- Next exact action: a file to open, command to run, or question to answer,
  specific enough to do cold
- Scope boundary: files or areas in scope and out of scope
- Files already changed and files to inspect first after compact
- Known reference paths or repos
- Verification status: commands run, pass/fail result, and known gaps
- Review state
- Drift result: none, expected expansion, out-of-scope, or unknown
- Blockers and risks
- Git state: repo path, branch, HEAD, changed tracked files, untracked files,
  and whether a commit was made
- Broad-search triggers: concrete reasons a future session should expand
  beyond the task neighborhood
- Stop reason: why work is pausing, handing off, or compacting

Compact summary priorities are the load-bearing resume fields: next exact
action, scope boundary, files to inspect first, verification state, review
state, drift result, git state, blockers, risks, and broad-search triggers.
Keep them concise and specific enough for a fresh session to continue without
wide exploration by default.

`handoff.md` should repeat the load-bearing continuation fields when the
session is pausing or transferring work: goal, status, completed work, open
next action, blockers, decisions, files touched, verification state, drift
result, git state, and stop reason.

## Rules

- Do not run `/compact` yourself — the user runs it.
- Do not commit, push, open PRs, install dependencies, or run external automation.
- If `projects/<project-id>/work/` does not exist yet, create only the files needed for safe compaction (`context-pack.md` at minimum, `handoff.md` if pausing).
- The `Next exact action` field in `context-pack.md` is the most load-bearing field; vague entries defeat the purpose of compaction.
- This command is prompt-driven continuity work. It prepares records for the
  human-triggered `/compact`; it does not delegate to a shell compaction
  helper or claim compaction happened.
- Do not say `/compact` ran. Say only that the state is compact-ready and the
  user may run `/compact`.
- Use the resume packet as designed anchors, not a hard read limit. After
  compact, verify live repo state, rebuild enough task neighborhood to work
  safely, and expand deliberately when the packet is stale, incomplete,
  cross-cutting, security-sensitive, review-oriented, or contradicted by
  verification.
