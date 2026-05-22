---
description: Prepare compact-safe project work records before /compact
argument-hint: "[project-id] [current task]"
---

# Compact Handoff

Prepare prompt-driven continuity before compacting, pausing, or handing off.

The user invoked this command with: `$ARGUMENTS`

## Steps

1. Read `CLAUDE.md` and the project record: `project.md`,
   `memory.md`, and `decisions.md`.
2. Read relevant files under `projects/<project-id>/work/`, especially
   `active-spec.md`, `active-plan.md`, `task-queue.md`, `progress.md`,
   `verification.md`, and `context-pack.md`.
3. Inspect the real repo with `git status --short`,
   `git rev-parse --short HEAD`, and `git diff --stat` enough to summarize
   changed files and risks.
4. Update `projects/<project-id>/work/context-pack.md` with the required
   compact resume packet below.
5. Update `projects/<project-id>/work/handoff.md` with the same load-bearing
   continuation fields when pausing or transferring work.
6. Report that the project is compact-ready and tell the user they may run
   `/compact`.

## Required Compact Resume Packet

Include these fields or equivalent clearly labeled sections:

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

Rules:

- Do not run `/compact`; the user or runtime runs it.
- Do not say `/compact` ran. Say only that the state is compact-ready and the
  user may run `/compact`.
- Do not commit, push, open PRs, install dependencies, or run external
  automation.
- If `projects/<project-id>/work/` does not exist yet, create only the files
  needed for safe compaction.
- Use the resume packet as designed anchors, not a hard read limit. After
  compact, verify live repo state, rebuild enough task neighborhood to work
  safely, and expand deliberately when the packet is stale, incomplete,
  cross-cutting, security-sensitive, review-oriented, or contradicted by
  verification.
