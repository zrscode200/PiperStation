# Piper Station Hub-Lite Compaction Prompt

Summarize the conversation so a future Codex turn can continue from the hub
without losing the user's intent, constraints, and current implementation
state.

Prioritize:

- the user's latest goal and requested project
- project id, repo path, branch, and current task
- important facts from `projects/<id>/memory.md`
- meaningful decisions from `projects/<id>/decisions.md`
- active Superpowers or Ralph state from `projects/<id>/work/context-pack.md`
  when present
- Ralph task status, last completed task, next exact action, stop reason,
  blockers, risks, verification status, and drift result when present
- files changed in the real project repo and why
- scope boundary, including files or areas in scope and out of scope
- files to inspect first after compaction and known reference paths
- commands run, verification results, and remaining test gaps
- review state, blockers, risks, required approvals, and git state
- broad-search triggers, such as handoff mismatch, missing acceptance criteria,
  failing verification, unclear generated parity, security/permissions behavior,
  or review scope

Reload on resume:

- `AGENTS.md`
- `STATION.md`
- `projects/<project-id>/project.md`
- `projects/<project-id>/memory.md`
- `projects/<project-id>/decisions.md`
- `projects/<project-id>/work/context-pack.md` when present
- `projects/<project-id>/work/handoff.md` when present
- other relevant files under `projects/<project-id>/work/` when present
- relevant task-neighborhood files in the real project repo

Rules:

- Treat hub project records as durable context, not as proof that work was
  completed.
- Treat `projects/<id>/work/` as optional active work continuity, not as a
  registration artifact.
- Treat built-in memories as supplemental recall only.
- On resume after compaction, reload the listed records when present.
- Preserve where to start after compact: designed anchors, exact next action,
  task neighborhood, and when broader exploration is justified.
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
