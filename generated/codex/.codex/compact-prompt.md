# Piper Station Hub-Lite Compaction Prompt

Summarize the conversation so a future Codex turn can continue from the hub
without losing the user's intent, constraints, and current implementation
state.

Prioritize:

- the user's latest goal and requested project
- project id, the selected lane (flat or `<gid>`), and the current boundary:
  the wave or group and its status
- important facts from `projects/<id>/memory.md`
- project policy preferences from `projects/<id>/project.md`
- substantial decision logs from optional `projects/<id>/decisions.md`
- the non-derivable resume fields from `projects/<id>/work/context-pack.md`
  when present (defined once in `STATION.md` → Compaction): goal, boundary and
  status, next exact action, verification and review state not yet in
  `build-log.md`, blockers, risks, open questions, stop reason, and any
  broad-search triggers or resume note
- active work, build-log checkpoints, optional durable queue, and roadmap
  direction when relevant
- files changed in the real project repo and why, and commands run with their
  results, as a summary only — branch, HEAD, status, and the diff are derived
  live from git on resume and never trusted from the summary
- required approvals and permission decisions still pending
- what to hand a human or fresh agent when pausing or transferring work

Reload on resume:

- `AGENTS.md`
- `STATION.md`
- `projects/registry.json` (project lookup index)
- `projects/<project-id>/project.md`
- `projects/<project-id>/memory.md`
- optional `projects/<project-id>/decisions.md` when present
- the selected lane's `context-pack.md`, `active-work.md`, `build-log.md`,
  and optional `task-queue.md` when present — under
  `projects/<project-id>/work/` for the flat lane or
  `projects/<project-id>/work/groups/<gid>/` for a group lane
- `projects/<project-id>/work/roadmap.md` when relevant
- relevant active-boundary-neighborhood files in the real project repo

Rules:

- Treat hub project records as durable context, not as proof that work was
  completed.
- Treat `projects/<id>/work/` as optional active work continuity, not as a
  registration artifact.
- Treat built-in memories as supplemental recall only.
- On resume after compaction, reload the listed records when present, and
  derive branch, HEAD, git status, and changed files live from the real project
  repo; treat any such values in the summary as hints to verify.
- Preserve where to start after compact: designed anchors, exact next action,
  active boundary neighborhood, and when broader exploration is justified.
- Do not invent completed work, approvals, test results, commits, branches, or
  user decisions.
- Mark uncertain details as unknown instead of filling gaps.
- Do not include secrets, private keys, credentials, or sensitive raw logs.

Future design note:

- A stronger auto-compact protection layer could snapshot minimal active state
  into `projects/<id>/work/` before automatic compaction. Codex CLI currently
  relies on this compact prompt and resume hooks rather than pre-compact or
  post-compact hooks, so any mutating snapshot design would require external
  runtime/app-server support, active-project/session-state tracking, and
  explicit ownership rules for generated work records.
