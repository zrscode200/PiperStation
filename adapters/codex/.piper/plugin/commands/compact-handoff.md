---
description: Prepare project work records for a human-triggered Codex /compact.
argument-hint: [project id and optional current task]
allowed-tools: [Read, Write, Bash]
---

# Compact Handoff

Use this command from a Piper Station hub-lite directory when the user wants
Ralph work made safe for `/compact`.

The user invoked this command with: $ARGUMENTS

## Instructions

1. Read `AGENTS.md`, `STATION.md`, and the relevant project record.
2. Read relevant files under `projects/<project-id>/work/`, especially
   `active-spec.md`, `active-plan.md`, `task-queue.md`, `progress.md`,
   `verification.md`, and `context-pack.md`.
3. Inspect the real repo status and current diff enough to summarize changed
   files and risks.
4. Update `projects/<project-id>/work/context-pack.md` with a compact resume
   packet:
   - current task id, title, status, and exact next action
   - scope boundary, including files or areas in scope and out of scope
   - files already changed and files to inspect first after compact
   - known reference paths or repos
   - branch, HEAD, and `git status --short` summary
   - verification status, review state, drift result, blockers, and risks
   - triggers that justify expanding beyond the task neighborhood
5. Update `projects/<project-id>/work/handoff.md` with the same resume packet
   when pausing or transferring work.
6. Report that the project is compact-ready and tell the user they may run
   `/compact`.

Do not execute `/compact`, commit, push, open PRs, or run external automation.

Use the resume packet as designed anchors, not a hard read limit. After compact,
the next agent should verify live repo state, rebuild enough task neighborhood
to work safely, and expand deliberately when the packet is stale, incomplete,
cross-cutting, security-sensitive, review-oriented, or contradicted by
verification.
