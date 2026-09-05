# Compact Handoff

Prepare prompt-driven continuity before compacting, pausing, or handing off.

The `piper-workflow` skill routes here when the user signals a pause,
handoff, or compact-ready state on a registered project.

## Steps

1. Read `AGENTS.md`. Look up the project in `projects/registry.json` to
   confirm registration and resolve `repo_path`, then read the project
   record: `project.md`, `memory.md`, and optional `decisions.md` when it
   exists.
2. Select the lane (`STATION.md` → Group Lifecycle → Lane selection), then
   read its files — `active-work.md`, `build-log.md`, `context-pack.md`, and
   optional `task-queue.md` — under `projects/<project-id>/work/` for the flat
   lane or `projects/<project-id>/work/groups/<gid>/` for a group lane, plus
   `roadmap.md`.
3. Inspect the lane's checkout with `git status --short`,
   `git rev-parse --short HEAD`, and `git diff --stat` enough to summarize
   changed files and risks.
4. Inspect the Piper Station hub git state when `projects/<project-id>/work/`
   exists or will be updated, so the packet can distinguish hub artifact
   changes from registered project source changes.
5. Rewrite the lane's `context-pack.md` in full with the
   required fields defined once in `STATION.md` → Compaction — regenerate the
   whole packet to reflect only the current boundary; do not section-edit or
   append. It also carries the handoff fields when pausing or transferring work.
6. Satisfy the checkpoint invariant (`STATION.md` → Artifact Persistence):
   report changed Piper artifacts separately from registered project source
   changes and state whether they are uncommitted in the hub.
7. Ask once whether to commit Piper artifact updates before compacting only
   when those artifacts matter for future continuity; do not commit unless the
   checkpoint decision is made; the commit itself is routine. Stage only the
   lane's paths plus touched project-level files — never `git add -A` in the
   shared hub checkout.
8. Report that the project is compact-ready and tell the user they may run
   `/compact`.

## Required Compact Resume Packet

The fields are defined once in `STATION.md` → Compaction; this list only names
them. Label each clearly:

- Goal
- Current boundary status: the wave or group and its status (`idle`,
  `mid-wave`, `accepted`, `group-review`, `closeout`, `between-groups`, or
  `blocked`); the scope boundary when no `active-work.md` carries it; the
  branch when it is not the repo's default
- Next exact action: a file to open, command to run, or question to answer,
  specific enough to do cold
- Verification and review state not yet recorded in `build-log.md`: unverified
  claims, open findings with their verdicts, and drift when it is not none
- Blockers, risks, and open questions
- Stop reason: why work is pausing, handing off, or compacting
- Optional: Broad-search triggers (concrete reasons a future session should
  expand beyond the active boundary neighborhood) and a short resume note for
  a human or fresh agent

Derived at resume, never authored into the packet: repo path, branch, HEAD,
and status; files changed and commits since the last acceptance commit; what
to inspect first; hub artifact commit state; and group or transition state
(read from `roadmap.md` and the closeout entries). When the status is
`between-groups`, the next group candidate and the transition decision are the
next exact action, not a separate field.

Rules:

- Do not run `/compact`; the user or runtime runs it.
- Do not say `/compact` ran. Say only that the state is compact-ready and the
  user may run `/compact`.
- Do not push, open PRs, install dependencies, or run external automation
  unless the selected workflow has reached that action and the `external` ask
  has a go-ahead; a commit is routine once the checkpoint decides it; see
  `automation-policy`.
- If `projects/<project-id>/work/` does not exist yet, create only the files
  needed for safe compaction.
- Treat `context-pack.md` as the only fully self-contained resume packet; do
  not backfill full resume metadata into roadmap, active-work, queue, or
  build-log artifacts during compact prep. Regenerate it in full rather than
  section-editing, but first read the existing packet and reconcile against it
  and live git so the rewrite never drops a still-relevant field; derive
  branch/HEAD/status live from git rather than copying a value that can age.
- Use the resume packet as designed anchors, not a hard read limit. After
  compact, verify live repo state, rebuild enough active boundary neighborhood
  to work safely, and expand deliberately when the packet is stale, incomplete,
  cross-cutting, security-sensitive, review-oriented, or contradicted by
  verification.
