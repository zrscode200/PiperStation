---
name: dispatcher
description: "Use in the root hub session when deciding whether to handle phase work inline or send a bounded delegation packet to a subagent, including brainstorm, piper-workflow, and review."
---

# Dispatcher

Dispatcher is the root-session orchestration skill. It decides whether the main
hub session should do a small request inline or send a bounded delegation packet
to a subagent. It does not replace phase skills: `brainstorm` defines
exploration behavior, `piper-workflow` defines Superpowers/Ralph/compact
behavior, and `review` defines review behavior.

Use this skill before entering substantial phase work: `brainstorm`,
`piper-workflow`, or `review`. It is not a universal delegation rule for every
helper. Automation approval and compact handoff stay with the root session
because they involve user-facing approval and continuity state.

Read `AGENTS.md` and `STATION.md` first. Use `automation-policy.md`
before protected actions.

## Anti-Busy Rule

Do not spawn a subagent when the task is `S0`, factual, trivial, or one-step;
when one local read or command is enough; when the subagent would only restate
known context; or when packaging the delegation packet costs more than doing the
work inline.

Spawn only when the phase needs a distinct posture, independence, or bounded
execution context.

## Phase Gates

Use these natural gates:

| Signal | Root action | Worker behavior |
| --- | --- | --- |
| Ambiguous project-work request, orientation, exploration, comparison, or direction setting | Spawn `explorer` when the work is substantial; otherwise handle inline | `brainstorm` |
| Direction is chosen and needs durable spec, plan, or Ralph-ready queue | Spawn `planner` when formal planning is useful | `piper-workflow` / Superpowers |
| Plan or queue item is accepted and one implementation slice should start | Spawn `ralph` after checking scope, risk, approval, and writable access | `piper-workflow` / Ralph |
| Explicit repo, branch, PR, diff, file, or implemented-slice review | Spawn `reviewer` when substantial; otherwise handle inline | `review` |
| Claims or checks need read-only validation | Spawn `verifier` | existing checks only |
| Substantial test-layer files, fixtures, or test data are explicitly delegated | Spawn `tester` | test-layer edits only |
| External API, framework, or OpenAI docs behavior is uncertain | Spawn `docs-researcher` | documentation research |
| Commit, PR, dependency install, network, CI, destructive, or external mutation | Stay in root session and use `automation-policy` | no subagent |
| Pause, compact, or prepare compact-safe continuity | Stay in root session and use compact handoff guidance | no subagent |

`docs-researcher` is the human-facing cross-runtime role label. Codex uses the
concrete agent id `docs_researcher` in `[agents.docs_researcher]`, while Claude
Code and OpenCode use `docs-researcher`.

## Delegation Packet

Every spawned subagent receives a concise packet. Do not dump the full session.
Include only the context needed for the worker's role.

```md
Role:
Phase:
Objective:
User request:
Project state:
Accepted prior output:
Relevant files/context:
Allowed actions:
Forbidden actions:
Verification expectation:
Stop conditions:
Expected report:
```

### Explorer Packet

Use for substantial `brainstorm` work.

- Role: `explorer`
- Phase: `brainstorm`
- Objective: orient, investigate, frame, compare, and return a decision-ready
  hand-off brief.
- Allowed actions: read files, inspect repo state, use read-only research
  helpers when needed, and identify whether registration is needed.
- Forbidden actions: source edits, `work/` records, commits, installs,
  protected automation, registration helper execution, and any durable writes.
- Expected report: problem framing, options and tradeoffs, recommendation,
  assumptions to verify, any explicit registration request for the root
  dispatcher, and suggested next surface.

If the explorer reports a registration request, the root dispatcher owns the
follow-up. It routes through `brainstorm` and runs the deterministic
`./bin/add-project` helper when registration is accepted.

### Planner Packet

Use when direction is chosen and the next step is formal planning.

- Role: `planner`
- Phase: `piper-workflow` / Superpowers
- Objective: verify the handed-off direction against the real repo, classify
  scope and risk, create useful active work records, and prepare Ralph-ready
  tasks when appropriate.
- Allowed actions: project record updates under `projects/<id>/work/` and
  read-only project repo inspection.
- Forbidden actions: project source edits, commits, protected automation, and
  reopening broad exploration unless the plan is blocked by a concrete gap.
- Expected report: created or updated work records, accepted plan, task queue
  status, verification strategy, blockers, and the next Ralph-ready task.

### Ralph Packet

Use when one accepted implementation slice should start.

- Role: `ralph`
- Phase: `piper-workflow` / Ralph
- Objective: implement exactly one scoped task in the real project repo.
- Allowed actions: edit only the real project repo paths in scope, run local
  verification, and report work-record updates needed by the root session.
- Forbidden actions: commits, pushes, PRs, dependency installs, destructive
  git actions, external automation, scope expansion, and hub policy changes.
- Expected report: selected task, files changed, verification result, drift
  result, blockers, and review-gate recommendation.

### Reviewer Packet

Use for substantial `review` work. The same `reviewer` role handles both review
types; the packet type controls scope and report shape.

- Role: `reviewer`
- Phase: `review`
- Review type: `Ralph Review Gate` or `General Repo/Diff Review`
- Objective: independently inspect the requested code, diff, branch, PR, file
  set, or implemented slice for correctness, regressions, security,
  reliability, drift, and missing tests.
- Allowed actions: read files, inspect repo state, inspect diffs and history,
  review provided build/test logs, and report when validation requires writable
  state.
- Forbidden actions: source edits, `work/` record updates, commits, pushes,
  PRs, dependency installs, protected automation, external mutation, and
  approval decisions.
- Expected report: findings ordered by severity with file/line references when
  possible, review type, scope inspected, verdict, assumptions, test gaps,
  residual risk, and recommended next action.

## Report Handling

The root session owns the work after a subagent returns:

- Verify material findings before acting on them.
- Apply only valid in-scope fixes or route valid out-of-scope findings into
  follow-up notes or tasks.
- Decide whether to spawn the next phase, continue inline, ask the user, or
  stop.
- Do not let a subagent approve automation, commit, push, invoke compact, or
  silently expand scope.
