{{FRONTMATTER}}# Compact Handoff

Prepare prompt-driven continuity before compacting, pausing, or handing off.

The user invoked this command with: `$ARGUMENTS`

## Steps

1. Read `{{INSTRUCTION_DOC}}`. Look up the project in `projects/registry.json`
   to confirm registration and resolve `repo_path`, then read the project
   record: `project.md`, `memory.md`, and optional `decisions.md` when it
   exists.
2. Read relevant files under `projects/<project-id>/work/`, especially
   `roadmap.md`, `active-work.md`, `build-log.md`, `context-pack.md`, and
   optional `task-queue.md`.
3. Inspect the real repo with `git status --short`,
   `git rev-parse --short HEAD`, and `git diff --stat` enough to summarize
   changed files and risks.
4. Inspect the Piper Station hub git state when `projects/<project-id>/work/`
   exists or will be updated, so the packet can distinguish hub artifact
   changes from registered project source changes.
5. Update `projects/<project-id>/work/context-pack.md` with the required
   compact resume packet below; it also carries the handoff fields when pausing
   or transferring work.
6. Report changed Piper artifacts separately from registered project source
   changes. State whether artifact changes are uncommitted in the hub.
7. Ask once whether to commit Piper artifact updates before compacting only when
   those artifacts matter for future continuity; do not commit unless the
   checkpoint decision is made and the active permission profile covers local
   git actions; otherwise route through `automation-policy`.
8. Report that the project is compact-ready and tell the user they may run
   `/compact`.

## Required Compact Resume Packet

Include these fields or equivalent clearly labeled sections:

- Goal
- Last completed boundary
- Current boundary status: wave, group review, explicit slice, queued task, or
  blocker
- Next exact action: a file to open, command to run, or question to answer,
  specific enough to do cold
- Scope boundary: files or areas in scope and out of scope
- Files already changed and files to inspect first after compact
- Known reference paths or repos
- Verification status: commands run, pass/fail result, and known gaps
- Review state
- Group-level review state when a group exists
- Drift result: none, expected expansion, out-of-scope, or unknown
- Blockers and risks
- Git state: repo path, branch, HEAD, changed tracked files, untracked files,
  and whether a commit was made
- Piper artifact state: changed `projects/<project-id>/work/` files, Piper
  Station hub branch/HEAD/status, and whether artifact changes are committed
- Broad-search triggers: concrete reasons a future session should expand
  beyond the active boundary neighborhood
- Stop reason: why work is pausing, handing off, or compacting
- What to hand a human or fresh agent

Rules:

- Do not run `/compact`; the user or runtime runs it.
- Do not say `/compact` ran. Say only that the state is compact-ready and the
  user may run `/compact`.
- Do not commit, push, open PRs, install dependencies, or run external
  automation unless the selected workflow has reached that action and the
  active permission profile allows it; see `automation-policy`.
- If `projects/<project-id>/work/` does not exist yet, create only the files
  needed for safe compaction.
- Treat `context-pack.md` as the only fully self-contained resume packet; do
  not backfill full resume metadata into roadmap, active-work, queue, or
  build-log artifacts during compact prep.
- Use the resume packet as designed anchors, not a hard read limit. After
  compact, verify live repo state, rebuild enough active boundary neighborhood
  to work safely, and expand deliberately when the packet is stale, incomplete,
  cross-cutting, security-sensitive, review-oriented, or contradicted by
  verification.
