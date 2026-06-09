---
name: brainstorm
description: "Use when the user wants to explore, understand, decide, or explicitly register rather than execute on a Piper Station project: orient to a repo or registered project, ask what it does or what a change would take, compare approaches, frame a problem, think through direction in conversation, or route deterministic registration. Stays read-only except explicit registration through the helper. Hand off to piper-workflow for formal planning or Ralph execution, review for review, and automation-policy for permission-gated actions."
---

# Brainstorm

Brainstorm is where you decide what is worth doing. The rest of Piper Station —
registration, active work records, Ralph, compaction — is a convergence engine
that produces durable, executable work. Brainstorm is the counterweight: the
space to frame a problem, weigh options, and ground them in reality *before*
that machinery commits. It answers "what should we build, and is it the right
thing?" while `piper-workflow` answers "how do we build it well?"

Brainstorm is read-only by contract for orientation, exploration, and
conversational planning. Premature artifacts are the failure this skill exists
to prevent, so it creates no `work/` files and no project source edits. The
only durable write exception is explicit registration through the deterministic
helper, which may create or update the narrow registration records. When a
request converges toward other durable work, brainstorm hands off to the
convergent surfaces.

Read `CLAUDE.md` and `STATION.md` first. Use the other root docs as
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
5. Read `projects/<project-id>/work/context-pack.md` when it exists.
6. Inspect the real repo path with `git status`, current branch, current HEAD,
   and the files relevant to the request.
7. If the repo is outside the hub, ensure Claude Code has workspace access through `/add-dir <repo-path>` or `claude --add-dir <repo-path>` before editing.
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
- Suggested next surface: formal planning, a single Ralph task, review, or an
  automation-policy permission flow.

## Register

Registration is the hinge between deciding and doing. When the user signals
"track this", "register this", or "this is formal work now", route to the
deterministic helper:

```sh
./bin/add-project --repo <repo-path> --project-id <project-id> [--description "<one-line summary>"]
```

Use `/add-project` or `./bin/add-project` or the helper. Registration creates or updates
hub project records, upserts `projects/registry.json`, and writes optional repo
markers. It must not start implementation work or create `work/`. Do not
hand-write the helper's file changes in a prompt; if the registry has drifted,
regenerate it with `./bin/add-project --rebuild`.

## Artifact Signal Policy

Brainstorm acts on the band of signals up to and including registration;
everything beyond it is a convergent escalation (see Escalation). State the
consequence when adjacent requests imply different writes. The full
intent-to-writes map lives in `STATION.md`.

The front-door band covers read-only orientation and conversational planning,
plus explicit deterministic registration. Registration may create only
`project.md`, `memory.md`, `projects/registry.json`, and optional repo markers
through the helper. Beyond registration — formal planning, Ralph execution,
finish, or automation — the signal is convergent: escalate per the table below
rather than writing here.

Ambiguous signals must not silently escalate durable writes. If the next step
would create hub work records, edit project source, or cross the active
permission profile boundary and intent is unclear, state the assumption and
choose the less durable action or ask.

## Escalation

When the request converges, hand it to the smallest convergent surface that
fits. Escalation is one-way: brainstorm states the consequence and passes the
brief; it does not perform durable execution itself.

| Converged signal | Hand off to |
| --- | --- |
| "make this a formal plan", "prepare for Ralph", "create the queue", "set this up for later" | `piper-workflow` — formal planning |
| "start Ralph", "build task X", "execute the queue item", "implement the plan" | `piper-workflow` — Ralph execution |
| "review this change" or an implemented wave, slice, or review gate | `review` |
| "commit", "open a PR", "push", "install", "run CI", worktree change, or external/exceptional action | `automation-policy` |
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
- Registration runs only through the deterministic helper; do not hand-write its
  records.
- Do not copy source code into the hub.
- Hand convergent work to `piper-workflow`, `review`, or `automation-policy`
  rather than executing durable changes here.
- Do not commit, push, merge, create or switch worktrees, install dependencies,
  or run external automation unless the selected workflow has reached that
  action and the active permission profile allows it; see
  `automation-policy.md`. Delete, force-push, rewrite history, deploy to
  production, or take other exceptional actions only after explicit one-off
  approval through `automation-policy`.
