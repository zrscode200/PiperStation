# Piper Station Agent Instructions (Codex)

This directory is a Piper Station hub-lite workspace. It is the central launch
point for Codex work across registered project repositories.

Codex auto-loads this `AGENTS.md` at every session. Treat it as the always-on
operating contract for project work in this hub.

## Operating Contract

- Treat this hub as coordination context, not as a source repo for registered
  projects.
- Do not copy project source code into the hub.
- Register project repos with `./bin/add-project` or via the `piper-workflow`
  skill.
- Registration only updates hub project records and optional repo marker files.
  It must not start implementation work, create plans, checkpoint state,
  commit, push, install dependencies, or edit project source files.
- Work on project source code only in the real repo path recorded in
  `projects/<project-id>/project.md`.
- When a registered project repo is outside the current Codex sandbox, start
  Codex with `--add-dir <project-repo>` (or otherwise grant writable workspace
  access) before Ralph executes. Registration can record an outside path, but
  edits require writable access in the active session.
- Use Codex-native behavior for planning, implementation, review, testing,
  subagents, handoff, and git operations.

## Codex Discovery Surfaces

Codex CLI discovers Piper Station behavior through these surfaces. Codex does
not auto-surface a `.codex/commands/` directory as slash commands; the
`piper-workflow` skill is the entry point instead.

- `AGENTS.md` (this file) — always loaded.
- `.codex/skills/piper-workflow/SKILL.md` — natural-language dispatch entry.
  Trigger via `$piper-workflow ...` or by stating the intent.
- `.codex/skills/piper-workflow/references/` — detailed procedure bodies
  (register, work-on, superpowers, ralph, compact-handoff) cited by the skill.
- `.codex/skills/review/SKILL.md` — explicit review and Ralph review-gate
  behavior.
- `.codex/skills/automation-policy/SKILL.md` — protected-action approval gate.
- `.codex/agents/*.toml` declared in `config.toml`'s `[agents.X]` blocks —
  `reviewer`, `architect`, `security_reviewer`, `docs_researcher`, `tester`,
  `implementer` (role names match the `name = "..."` field in each `.toml`).
- `.codex/hooks/*.sh` wired in `hooks.json` — `SessionStart` (with
  `startup|resume|compact` matcher), `PreCompact`, `PostCompact`.
- `.codex/compact-prompt.md` referenced by `experimental_compact_prompt_file`.

## Required Reading

When working in this hub, use these docs as the canonical references:

- `STATION.md`: primary operating guide.
- `PRODUCT.md`: product intent and non-goals.
- `ARCHITECTURE.md`: hub and project record structure.
- `CONVENTIONS.md`: naming, context, and work style conventions.
- `TESTING.md`: verification expectations.
- `SECURITY.md`: sensitive-data and boundary rules.
- `automation-policy.md`: approvals required for automation and external
  actions.

## Project Records

Each registered project has:

```text
projects/<project-id>/
  project.md
  memory.md
  decisions.md
  work/              # optional, created by Codex only when useful
```

- `project.md` binds the project id to the real repo path and stores a small
  project overview.
- `memory.md` stores durable facts, preferences, stable conventions, and
  reusable context.
- `decisions.md` stores meaningful choices, tradeoffs, accepted risks, and
  policies future work should not silently reopen.
- `work/` stores optional active work continuity such as specs, plans, task
  queues, progress, verification, handoff notes, and context packs.

Do not put routine progress logs, command output, temporary plans, secrets, or
raw sensitive logs into `memory.md` or `decisions.md`.

Registration must not create `work/`. Codex may create it during active work
when continuity is useful.

## Mode Routing

`piper-workflow` owns natural-language dispatch for ordinary project work in
Codex. State the intent (or invoke `$piper-workflow ...`); the skill body
covers register, orient, plan, implement, review, finish, and compact paths.
The detailed procedures for each path live as references under
`.codex/skills/piper-workflow/references/`.

Route each request through the smallest mode that fits:

- Intent Mode: classify the request, project, scope tier, risk tier, and
  whether direct work is safe.
- Superpowers Mode: discover, specify, and plan before substantial
  implementation.
- Ralph Mode: execute one scoped task at a time from a clear plan or task
  queue, with an implementation review gate for substantial slices.
- Review Mode: first check whether the work matches the request/spec/plan,
  then check code quality.
- Finish Mode: verify, summarize, and present commit or PR options without
  mutating git automatically.

Use `piper-workflow` as the only broad natural-language project-work router.
Use the `review` skill for explicit review work or review gates, and
`automation-policy` before protected automation or external actions. Prefer
consequence language such as "I will keep this read-only" or "I will create
Ralph-ready work records" over ceremonial mode announcements.

Scope tiers:

- `S0`: direct small task; no artifact needed.
- `S1`: short active plan in `projects/<project-id>/work/active-plan.md`.
- `S2`: written spec and plan required before implementation.
- `S3`: split into milestones or sub-specs.

Risk tiers:

- `L0`: trivial or local.
- `L1`: normal implementation.
- `L2`: needs explicit user confirmation before Ralph executes.
- `L3`: forbidden inside Ralph; stop and ask.

## Working On A Project

Before editing a registered project:

1. Read this file and `STATION.md`.
2. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md`.
3. Read `projects/<project-id>/work/context-pack.md` when present.
4. Inspect the real repo path with git status, current branch, current HEAD,
   and the files relevant to the user request.
5. State any uncommitted or recent user changes that affect the task.
6. Make a short task-specific plan unless the user has asked only for review or
   explanation.
7. Before Ralph execution or source edits, verify the real project repo is
   writable in the active session. If it is outside the current Codex
   sandbox, ensure Codex was started with `--add-dir <project-repo>` or that
   the sandbox otherwise grants writable access.
8. Implement in the real project repo, using the repo's own conventions and
   verification commands.
9. Update `projects/<project-id>/work/` only when active continuity is useful.
10. Update hub `memory.md` or `decisions.md` only when durable context changed.

## Subagents

The hub declares six Codex subagent roles in `config.toml` and provides their
`.toml` configs under `.codex/agents/`:

- `reviewer` — read-only implementation review for Ralph review gates.
- `implementer` — scoped implementation when the user explicitly delegates.
- `tester` — focused regression and verification support.
- `architect` — read-only architecture review for broad design and boundary
  risk.
- `docs_researcher` — documentation research through official docs and MCP
  tools.
- `security_reviewer` — read-only security review for auth, permissions,
  data, networking, secrets, and dependency trust.

Spawn a subagent with the matching `agent_type` when its specific role
applies. Implementation stays with the main session unless the user explicitly
asks for `implementer` delegation. Verify all subagent findings in the main
session before acting on them.

## Ralph Review Gate

During Ralph Mode, run a read-only implementation review after substantial
slices are implemented and initially verified, before marking the slice
complete in active work records. The reviewer subagent inspects the actual
code or diff with the plan, spec, task queue, and verification logs as
context.

Review gate selection is based on scope and change impact. Risk tier determines
whether execution needs explicit user approval. Review gates are required for
`S2/S3` slices and queued tasks that touch foundational behavior such as
bootstrap, install, update, registration, generated commands, hooks, settings,
config, test harnesses, project or hub ownership, security policy, or automation
policy.

The main agent must verify reviewer findings before acting, apply only valid
in-scope fixes, and reverify review-driven fixes with the narrowest meaningful
command for the fixed behavior. Record the gate status or skip reason when
active work records are in use. If a required or expected gate is skipped,
record review debt in active work records and do not continue to dependent
tasks until the debt is resolved or explicitly accepted by the user.

## Compaction Discipline

Codex CLI fires `PreCompact` and `PostCompact` hooks around compaction, and
`SessionStart` with `source=compact` after a compact completes. The
`PreCompact` hook surfaces a user-facing reminder; the model-visible
post-compact context arrives via the `SessionStart` hook (with
`hookSpecificOutput.additionalContext`). The hooks must not edit work
records, commit, push, or invoke `/compact`.

During Ralph Mode, prepare compact-safe state at natural stopping points by
updating `projects/<project-id>/work/context-pack.md`, plus `handoff.md` when
pausing or handing off. If context is low or the next slice needs a clean
context, pause and tell the user the state is compact-ready and they may run
`/compact`.

Do not claim `/compact` was run unless the user or Codex actually ran it.

After compact, start from the designed resume anchors: `context-pack.md`,
`handoff.md`, `task-queue.md`, `active-plan.md`, `verification.md`, project
`decisions.md`, and live branch/HEAD/status. Then rebuild enough of the active
task neighborhood to work safely. Expand beyond that for concrete triggers
such as mismatched handoff state, missing acceptance criteria, failing
verification, generated parity, security or permissions behavior, or review
scope.

## Approval Boundaries

Ask before commits, pushes, merges, pull requests, dependency installs,
worktree changes, long-running commands, networked commands, destructive git
actions, CI changes, deployments, or external automation. See
`automation-policy.md` for the full classification.
