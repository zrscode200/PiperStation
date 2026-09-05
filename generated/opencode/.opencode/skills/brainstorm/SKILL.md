---
name: brainstorm
description: "Use when the user wants to explore, understand, decide, or explicitly register rather than execute on a Piper Station project: orient to a repo or registered project, compare approaches, frame a problem, think through direction, optionally suggest Design Studio for deeper durable design, or route deterministic registration. Stays read-only except explicit registration through the helper. Hand off to design-studio only after explicit user choice, piper-workflow for convergent execution, review for review, and automation-policy for external or exceptional actions."
---

# Brainstorm

Brainstorm is where you decide what is worth doing. The rest of Piper Station —
registration, active work records, Ralph, compaction — is a convergence engine
that produces durable, executable work. Brainstorm is the counterweight: the
space to frame a problem, weigh options, and ground them in reality *before*
that machinery commits. It answers "what should we build, and is it the right
thing?" while `piper-workflow` answers "how do we build it well?"

Some initiatives need more design depth and multi-session durability than
ordinary brainstorm, but are not ready for execution planning. `design-studio`
is that optional deeper path inside the divergent movement. Ordinary brainstorm
may still hand directly to `piper-workflow`.

Brainstorm is read-only by contract for orientation, exploration, and
conversational planning. Premature artifacts are the failure this skill exists
to prevent, so it creates no `work/` files and no project source edits. The
only durable write exception is explicit registration through the deterministic
helper, which may create or update the narrow registration records. When a
request converges toward other durable work, brainstorm hands off to the
appropriate surface. Even when the user chooses Design Studio, this skill does
not create studio artifacts itself; the `design-studio` skill owns those
writes.

Read `AGENTS.md` and `STATION.md` first. Use the other root docs as
canonical references when product, architecture, convention, testing, security,
or automation-policy details matter.

## Posture

Match effort to the request; the divergent toolkit below is a set of moves to
apply when they help, never a mandatory sequence. A direct factual question
deserves a direct answer. A substantial, ambiguous, or high-stakes design
question deserves the full arc. Use scope as advisory sizing (see Scope And
Risk): `S0` answers or routes in one step; `S2`/`S3` warrants framing, real
divergence, and investigation before any recommendation.

Prefer consequence language over ceremony. Say "I will keep this read-only and
we will settle the direction before writing anything" rather than announcing a
mode.

## Orient

Ground the conversation in the actual project before reasoning about it:

1. Identify the project id or repo path from the request.
2. Look up the project in `projects/registry.json` to confirm registration and
   resolve `repo_path`. If the id is ambiguous or absent, list the registered
   `project_id` entries (with `description` where present) and ask which to use.
3. If the repo is not registered and the user wants project work, ask whether to
   register it first.
4. Read `projects/<project-id>/project.md`, `memory.md`, and optional
   `decisions.md` when it exists for the canonical record. Treat the registry
   as the lookup index; treat `project.md` as authoritative.
5. Read `projects/<project-id>/work/context-pack.md` when it exists. When
   `projects/<project-id>/work/groups/` exists, also read the status line of
   every active group lane's `context-pack.md`, so orientation sees each lane
   in flight.
6. Inspect `repo_path` — which may be checked out on a group lane's branch —
   with `git status`, current branch, current HEAD,
   and the files relevant to the request.
7. If the lane's checkout (`repo_path` or its recorded worktree) is outside the current working directory, open OpenCode from that directory or adjust workspace access before editing.
8. Treat uncommitted changes as user-owned unless the user says otherwise.

## Divergent Toolkit

Apply the moves the request needs to raise the quality of the *decision*. Each
exists because it lowers the chance of converging on the wrong thing.

- **Frame.** Pin the real problem before any solution: goals, non-goals, success
  criteria, and constraints. Reframe when the stated problem is not the real one
  ("you asked how to cache this, but the real cost is the N+1 query"). Keep what
  is known separate from what is assumed.
- **Diverge.** Generate more than one candidate approach with explicit
  tradeoffs. Compare on consistent axes — complexity, risk, reversibility, blast
  radius, effort, and fit with existing patterns. Widening the option space is
  the point; do not collapse to the first plausible plan.
- **Investigate.** Ground options in what actually exists: how the relevant code
  works today, prior art, and established patterns. Use available read-only
  architecture and documentation-research helpers for design exploration and
  prior art. Investigation here is exploration to *generate* options, not
  verification of a chosen one — that verification is `piper-workflow`'s job at
  the convergent boundary.

## Optional Design Studio

Suggest `design-studio` when deeper design would materially improve the
decision: several substantive design tensions, source-grounded architecture or
contract work, scenario/state/interface modeling, failure or authority pressure
testing, multi-session continuity, or durable rationale before implementation
planning.

The suggestion is not an automatic transition. Explain why the deeper path
would help and enter only after the user explicitly chooses it. Do not create a
studio merely because a request mentions design, is complex, or could benefit
from more discussion. If the user declines or the ordinary brainstorm is
already decision-ready, continue here and hand directly to `piper-workflow`
when execution planning is wanted.

A direct request to open, enter, start, or continue Design Studio is already an
explicit choice; route it directly to the `design-studio` skill. That skill may
create or reuse hub-owned studio artifacts, but it still does not authorize
project-source edits or implementation planning.

## Hand-Off Brief

When direction converges, produce a decision-ready brief **in the conversation**
— no durable writes. It is the bridge into convergent work and becomes the first
checklist `piper-workflow` verifies. Include:

- Problem framing: the real problem, goals, and non-goals.
- Options considered and the tradeoffs that mattered.
- Recommended direction and why.
- A short pressure-test of that direction: likely failure modes or a quick
  pre-mortem — try to break it before committing.
- Open questions and assumptions that should be verified before durable work.
- Suggested next surface: optional Design Studio, formal planning, a single
  Ralph task, review, or an automation-policy boundary ask.

## Register

Registration is the hinge between deciding and doing. When the user signals
"track this", "register this", or "this is formal work now", route to the
deterministic helper:

```sh
./bin/add-project --repo <repo-path> --project-id <project-id> [--description "<one-line summary>"]
```

Use `./bin/add-project` or the helper. Registration creates or updates
hub project records, upserts `projects/registry.json`, and writes optional repo
markers. It must not start implementation work or create `work/`. Do not
hand-write the helper's file changes in a prompt; if the registry has drifted,
regenerate it with `./bin/add-project --rebuild`.

## Artifact Signal Policy

Brainstorm acts on the band of signals up to and including registration. An
explicit Design Studio choice routes to a deeper divergent owner; formal
planning and execution route to convergent owners (see Escalation). State the
consequence when adjacent requests imply different writes. The full
intent-to-writes map lives in `STATION.md`.

The front-door band covers read-only orientation and conversational planning,
plus explicit deterministic registration. Registration may create only
`project.md`, `memory.md`, `projects/registry.json`, and optional repo markers
through the helper. Explicit Design Studio intent routes to that skill, which
owns useful hub design artifacts without becoming convergent execution. Beyond
those routes — formal planning, Ralph execution, finish, or automation — the
signal is convergent: escalate per the table below rather than writing here.

Ambiguous signals must not silently escalate durable writes. If the next step
would create hub work records, edit project source, or take an `external`
action and intent is unclear, state the assumption and choose the less
durable action or ask.

## Escalation

When the request is ready to leave ordinary brainstorm, hand it to the smallest
surface that fits. The Design Studio route remains divergent; the other routes
below are convergent. Brainstorm states the consequence and passes the brief or
current frame; it does not perform the destination's durable work itself.

| Exit signal | Hand off to |
| --- | --- |
| "open a design studio", "enter design studio", "continue the studio", or acceptance of a brainstorm suggestion | `design-studio` — optional deep divergent design |
| "make this a formal plan", "prepare for Ralph", "create the queue", "set this up for later" | `piper-workflow` — formal planning |
| "start Ralph", "build task X", "execute the queue item", "implement the plan" | `piper-workflow` — Ralph execution |
| "review this change" or an implemented wave, slice, or review gate | `review` |
| "open a PR", "push", "install", "run CI", or another `external` or `exceptional` action | `automation-policy` |
| "commit" or a worktree change (routine once the workflow reaches it) | `piper-workflow` — the mode that reaches it (Finish for a commit, group Entry for a worktree) |
| "pause", "hand off", or "get this compact-ready" | `piper-workflow` — `/compact-handoff` |

Wait for go-ahead when the route requires confirmation, risk is `L2`, the
request is ambiguous, or the user asked only for orientation.

## Scope And Risk

Classify enough to size the toolkit and choose the route. `STATION.md` defines
scope as advisory sizing and risk as implementation caution; `piper-workflow`
owns detailed application. Higher scope warrants more of the divergent toolkit
before any recommendation.

## Guardrails

- Read-only is the point. While deciding, do not create hub records or project
  `work/` files and do not edit project source. Crossing into durable work is an
  explicit escalation, never a side effect.
- Do not force Design Studio into ordinary brainstorming. Suggest it only when
  the benefit is material and wait for explicit user choice; preserve the
  direct brainstorm-to-Piper Workflow path.
- Registration runs only through the deterministic helper; do not hand-write its
  records.
- Do not copy source code into the hub.
- Hand convergent work to `piper-workflow`, `review`, or `automation-policy`
  rather than executing durable changes here.
- Do not push, merge to a remote, open a pull request, install dependencies,
  or run external automation unless the selected workflow has reached that
  action and the `external` ask has a go-ahead; see `automation-policy.md`.
  Commits and worktree changes are routine once reached. Delete, force-push, rewrite pushed history, deploy to
  production, or take other exceptional actions only after explicit one-off
  approval through `automation-policy`.
