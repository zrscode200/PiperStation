# Piper Station Hub

This directory is a Piper Station hub-lite workspace. It coordinates assisted
development across registered project repositories using one shared project
ledger and one or more native harness surfaces.

Installed runtime surfaces may include Codex, Claude Code, OpenCode, or any
combination of them. Runtime files provide native entry points; project records
stay shared under `projects/`.

## Required Behavior

- Treat this hub as lightweight cross-project context, not a workflow engine.
- Do not copy project source code into the hub.
- Register project repos with the native command surface or `./bin/add-project`.
- Registration only updates hub project records and optional repo marker files.
- Do not start work, create plans, checkpoint state, commit, push, install
  dependencies, or edit project source as a side effect of registration.
- Work on project source code only in the real repo path recorded in
  `projects/<project-id>/project.md`.
- Keep behavior feedback in shared records when it applies to Piper Station;
  use runtime-specific notes only for harness mechanics.
- Do not store secrets, credentials, private keys, customer data, or raw
  sensitive logs in hub records.

## Runtime Surfaces

- Codex: `AGENTS.md` and `.codex/`.
- Claude Code: `CLAUDE.md` and `.claude/`.
- OpenCode: `opencode.json` and `.opencode/`.

A hub may have multiple runtime surfaces installed. Use one harness actively on
a project at a time unless the user explicitly coordinates parallel work.

## Dispatch Contract

`piper-workflow` owns natural-language dispatch for ordinary project work.
Slash commands are explicit shortcuts into the same behavior. Commands, narrow
skills, agents, hooks, and docs provide supporting behavior after
`piper-workflow` or a command has selected the route.

Use this dispatch table when intent is unclear:

| User intent | Route | Supporting behavior |
| --- | --- | --- |
| Register a repo | `piper-workflow`, `/add-project`, or `./bin/add-project` | deterministic registration helper |
| Orient to a repo or ambiguous request | `piper-workflow` or `/work-on` | `piper-workflow` |
| Discover, specify, or plan substantial work | Superpowers Mode or `/superpowers` | `piper-workflow`, `/superpowers`, and this guide |
| Execute one clear queued task | Ralph Mode or `/ralph` | `/ralph` and this guide |
| Review code or an implemented slice | Review Mode | `review` |
| Commit, PR, dependency, network, CI, destructive, or external action | Finish Mode or explicit approval flow | `automation-policy` |
| Pause or compact active work | `/compact-handoff` | compact handoff guidance |

If a normal project-work request arrives without a slash command, treat it as
an implicit `piper-workflow` request. Use visible mode names when they help
continuity, but do not make the user operate the mode layer. Prefer consequence
language such as "I will keep this read-only" or "I will create Ralph-ready
work records" over ceremonial mode announcements.

### Artifact Signal Policy

Infer durable artifacts from the user's intent signal and state the consequence
when it matters:

| User signal | Interpretation | Durable writes | Assistant stance |
| --- | --- | --- | --- |
| "review this repo", "understand what this does", "what is this project", or a repo path with an explanation or review request | Orientation or review | None by default | Inspect the repo in place. Say the work is read-only and that registration or hub records will wait unless asked. |
| "what would it take", "how should we approach", "compare this to", or "plan the refactor" before registration | Conversational planning | None by default | Produce a grounded plan in chat. Avoid hub records unless the user asks to formalize. |
| "register this", "track this project", or "this is formal work now" | Registration | `project.md`, `memory.md`, and `decisions.md` only | Use the registration helper. Prefer hub-only records unless repo marker files are explicitly wanted. Do not create `work/` or start implementation. |
| "make this a formal plan", "prepare for Ralph", "create the queue", "we need continuity", or "set this up for later execution" | Formal planning or Ralph preparation | Useful `projects/<id>/work/` records | Create the durable record set the scope needs, such as active spec, active plan, task queue, context pack, progress, and verification. State that source remains untouched. |
| "start Ralph", "build task X", "execute the first queue item", or "implement according to the plan" | Ralph execution | Update `work/` records as useful; edit the real project repo | Confirm the selected task, diff boundary, risk, verification, and writable repo access before editing. Execute one scoped slice. |
| "finish", "commit", "open a PR", "push", "install", "run CI repair", or external/destructive action | Finish or protected automation | Only after explicit approval where required | Summarize state, verification, and risk first. Ask for approval before protected state changes. |

Ambiguous signals must not silently escalate durable writes. If the next step
would create hub records, edit project source, or take protected action and the
user's intent is unclear, state the assumption and ask or choose the less
durable action.

## Project Records

Each registered project has:

```text
projects/<project-id>/
  project.md
  memory.md
  decisions.md
  work/              # optional, created only when useful during active work
```

`work/` may contain `active-spec.md`, `active-plan.md`, `task-queue.md`,
`context-pack.md`, `progress.md`, `verification.md`, `handoff.md`, and optional
`specs/`, `plans/`, and `runs/`.

Registration must not create `work/`.

## Mode Routing

Route requests through `piper-workflow`, command shortcuts, and the smallest
mode that fits:

- Intent Mode: identify the project, user goal, scope tier, risk tier, and next
  safe mode.
- Superpowers Mode: discover, specify, and plan before substantial
  implementation.
- Ralph Mode: execute one scoped task at a time, verify, drift-check, and use
  an implementation review gate for substantial slices.
- Review Mode: first check whether the work matches the request/spec/plan, then
  check code quality.
- Finish Mode: report verification, residual risk, changed files, and commit or
  pull request options without mutating git automatically.

Scope tiers:

- `S0`: direct small task; no artifact needed.
- `S1`: short active plan in `projects/<id>/work/active-plan.md`.
- `S2`: written spec and plan required before implementation.
- `S3`: split into milestones or sub-specs.

Risk tiers:

- `L0`: trivial or local.
- `L1`: normal implementation.
- `L2`: explicit user confirmation required before Ralph executes.
- `L3`: forbidden inside Ralph; stop and ask.

## Ralph Review Gate

Before Ralph edits project source, verify the real project repo is writable in
the active session. If the repo is outside the current workspace or sandbox,
state that writable access is required before execution instead of declaring
the task Ralph-ready.

During Ralph Mode, run a read-only implementation review after substantial
slices are implemented and initially verified, before marking the slice
complete in active work records. The reviewer inspects the actual code or diff
with the active spec, plan, task queue, and verification logs as context.

Review gate selection is based on scope and change impact. Risk tier controls
approval before execution, not review selection. Review gates are required for
`S2/S3` slices and queued tasks that touch foundational behavior such as
bootstrap, install, update, registration, generated commands, hooks, settings,
config, test harnesses, project or hub ownership, security policy, or automation
policy.

The main session must verify reviewer findings before acting, apply only valid
in-scope fixes, turn valid out-of-scope findings into follow-up notes or tasks,
and reverify review-driven fixes with the narrowest meaningful command for the
fixed behavior. If a required or expected gate is skipped, record review debt
and do not continue to dependent tasks until the debt is resolved or explicitly
accepted by the user.

## Compaction

At natural stopping points, prepare compact-safe state in
`projects/<id>/work/context-pack.md` and, when pausing,
`projects/<id>/work/handoff.md`.

Compact-safe state must include goal, last completed task, current task status,
next exact action, scope boundary, files to inspect first after compact, known
reference paths, verification status, review state, drift result, blockers and
risks, git state, broad-search triggers, and stop reason.

`/compact` is human-triggered. Ralph may pause and say the state is
compact-ready when context is low, a milestone just finished, or the next slice
needs a clean context. Do not claim `/compact` ran unless the user or runtime
actually ran it.

After compact, start from the designed resume anchors: `context-pack.md`,
`handoff.md`, `task-queue.md`, `active-plan.md`, `verification.md`, project
`decisions.md`, and live branch/HEAD/status. Then rebuild enough of the active
task neighborhood to work safely. Expand beyond that for concrete triggers such
as mismatched handoff state, missing acceptance criteria, failing verification,
generated parity, security or permissions behavior, or review scope.

Future runtime-style auto-compact protection could snapshot minimal active
state to `projects/<id>/work/` immediately before automatic compaction. Keep
this as future design work, not current hub-lite behavior.

## Project Repos

Project repos keep source code. Registration may add `.piper/project.json` and
`PIPER.md`, but those markers do not make the repo a Piper runtime.
