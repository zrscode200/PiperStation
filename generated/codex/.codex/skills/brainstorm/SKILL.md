---
name: brainstorm
description: "Codex front door for Piper Station project work — explore, understand, decide, or explicitly register rather than execute. Trigger via $brainstorm or by stating the intent. Use to orient, frame, compare, investigate, optionally suggest Design Studio for deeper durable design, and route deterministic registration. Stays read-only except explicit registration through the helper; hands to design-studio only after explicit user choice and to piper-workflow when work converges."
---

# Brainstorm (Codex)

Brainstorm is where you decide what is worth doing before the convergence engine
commits. The rest of Piper Station — registration, active work records, Ralph,
compaction — produces durable, executable work; brainstorm is the counterweight
that frames the problem, weighs options, and grounds them in reality first. It
answers "what should we build, and is it the right thing?" while `piper-workflow`
answers "how do we build it well?"

Some initiatives need more design depth and multi-session durability than
ordinary brainstorm, but are not ready for execution planning. The
`design-studio` skill is that optional deeper path inside Piper's divergent
movement. Ordinary brainstorm may still hand directly to `piper-workflow`.

Codex CLI does not surface `.codex/commands/` as slash commands; this skill is
the natural-language entry for the divergent phase. Trigger via `$brainstorm ...`
or by stating the intent directly. Read `AGENTS.md` and `STATION.md` first, then
orient using the steps below; load `references/add-project.md` when the user
wants to register.

Brainstorm is read-only by contract for orientation, exploration, and
conversational planning. Premature artifacts are the failure it exists to
prevent, so it creates no `work/` files and no project source edits. The only
durable write exception is explicit registration through the deterministic
helper, which may create or update the narrow registration records. Crossing
into any other durable work is an explicit escalation. If the user chooses
Design Studio, hand to that skill; brainstorm itself does not create the studio
artifacts.

## References

- `references/add-project.md` — register a repo in the hub ledger (the hinge
  into convergent work).

Convergent work escalates out of brainstorm: use `piper-workflow` (via
`$piper-workflow` or the named Superpowers, Ralph and compact handoff procedures) for formal
planning and Ralph execution, `review` for review gates, and `automation-policy`
before `external` or `exceptional` actions.

## Posture

Match effort to the request; the divergent toolkit is a set of moves to apply
when they help, never a mandatory sequence. A direct factual question deserves a
direct answer. A substantial, ambiguous, or high-stakes design question deserves
the full arc. Scope is the dial: `S0` answers or routes in one step; `S2`/`S3`
warrants framing, divergence, and investigation before any recommendation.
Prefer consequence language ("I will keep this read-only and settle the
direction before writing anything") over mode announcements.

## Orient

Ground the conversation in the actual project before reasoning about it:

1. Identify the project id or repo path from the request.
2. Look up the project in `projects/registry.json` to confirm registration and
   resolve `repo_path`. If the id is ambiguous or absent, list the registered
   `project_id` entries (with `description` where present) and ask which to use.
3. If the repo is not registered and the user wants project work, ask whether to
   register it first.
4. Read `projects/<project-id>/project.md`, `memory.md`, and optional
   `decisions.md` when it exists for the canonical record; read
   relevant existing work and design entry points. Inspect open lane headers
   and packets only as needed to understand related work (STATION → Lanes).
   A clearly requested effort does not require choosing among unrelated lanes;
   stored status is continuity information, not proof of a running session.
5. Inspect `repo_path` — which may be owned by an execution lane —
   with `git status`, current branch, current HEAD,
   and the files relevant to the request.
6. If the project repo is outside the current Codex sandbox, note that Codex
   must be started with `--add-dir <checkout-path>` before any later editing.
   Treat uncommitted changes as user-owned unless the user says otherwise.

## Divergent Toolkit

Apply the moves the request needs to raise the quality of the decision:

- **Frame.** Pin the real problem before any solution: goals, non-goals, success
  criteria, constraints. Reframe when the stated problem is not the real one.
  Keep what is known separate from what is assumed.
- **Diverge.** Generate more than one candidate approach with explicit tradeoffs
  on consistent axes — complexity, risk, reversibility, blast radius, effort,
  and fit with existing patterns. Do not collapse to the first plausible plan.
- **Investigate.** Ground options in what exists: how the relevant code works
  today and prior art. Spawn the read-only `architect` subagent for design and
  boundary exploration and `docs_researcher` for prior art and official docs
  (both declared in `.codex/config.toml`). This is exploration to *generate*
  options, not verification of a chosen one — that verification is
  `piper-workflow`'s job at the convergent boundary.

## Optional Design Studio

Suggest `design-studio` when deeper work would materially help: several
substantive design tensions, source-grounded architecture or contract design,
scenario/state/interface modeling, failure or authority pressure testing,
multi-session continuity, or durable rationale before implementation planning.

The suggestion is not an automatic transition. Explain why the deeper path
would help and enter only after the user explicitly chooses it. Do not create a
studio merely because a request mentions design or is complex. If the user
declines or the current brainstorm is already decision-ready, continue here and
hand directly to `piper-workflow` when execution planning is wanted.

A direct `$design-studio ...` invocation or natural-language request to open,
enter, start, or continue Design Studio is already an explicit choice; route it
directly to that skill. Its durable hub artifacts do not authorize project
source edits or implementation planning.

## Hand-Off Brief

When direction converges, produce a decision-ready brief in the conversation —
no durable writes. It is the bridge into convergent work and becomes the first
checklist `piper-workflow` verifies. Include the problem framing (real problem,
goals, non-goals), options considered and the tradeoffs that mattered, the
recommended direction and why, a short pressure-test of that direction (failure
modes or a quick pre-mortem), open questions and assumptions to verify, and the
suggested next surface: optional Design Studio, formal planning, a Ralph task,
review, or an automation-policy boundary ask.

## Register

Registration is the hinge between deciding and doing. When the user signals
"track this", "register this", or "this is formal work now", route to the
deterministic helper:

```sh
./bin/add-project --repo <repo-path> --project-id <project-id> [--description "<one-line summary>"]
```

Registration creates or updates hub project records, upserts
`projects/registry.json`, and writes optional repo markers. It must not start
implementation work or create `work/`. Do not hand-write the helper's file
changes; if the registry has drifted, regenerate it with
`./bin/add-project --rebuild`.

## Artifact Signal Policy

Brainstorm acts on the band of signals up to and including registration. An
explicit Design Studio choice routes to a deeper divergent owner; formal
planning and execution route to convergent owners (see Escalation). The full
intent-to-writes map lives in `STATION.md`.

The front-door band covers read-only orientation and conversational planning,
plus explicit deterministic registration. Registration may create only
`project.md`, `memory.md`, `projects/registry.json`, and optional repo markers
through the helper. Explicit Design Studio intent routes to that skill, which
owns useful hub design artifacts without becoming convergent execution. Beyond
those routes, formal planning, Ralph execution, finish, and automation are
owned by `piper-workflow`, `review`, or `automation-policy`.

Ambiguous signals must not silently escalate durable writes. If intent is
unclear, state the assumption and choose the less durable action or ask.

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
| "review this change" or an implemented slice or review gate | `review` |
| "open a PR", "push", "install", "run CI", or another `external` or `exceptional` action | `automation-policy` |
| "commit" or a worktree change (routine once the workflow reaches it) | `piper-workflow` — the mode that reaches it (a meaningful checkpoint for a commit, lane/worker preparation for a worktree) |
| "pause", "hand off", or "get this compact-ready" | `piper-workflow` — compact handoff |

Wait for go-ahead when the route requires confirmation, risk is `L2`, the
request is ambiguous, or the user asked only for orientation.

## Scope And Risk

Classify enough to size the toolkit and choose the route. `STATION.md` defines
the scope and risk tiers; `piper-workflow` owns detailed application of those
tiers. Higher scope warrants more of the divergent toolkit before any
recommendation.

## Guardrails

- Read-only is the point. While deciding, do not create hub records or project
  `work/` files and do not edit project source. Crossing into durable work is an
  explicit escalation, never a side effect.
- Do not force Design Studio into ordinary brainstorming. Suggest it only when
  the benefit is material and wait for explicit user choice; preserve the
  direct brainstorm-to-Piper Workflow path.
- Registration runs only through the deterministic helper.
- Do not copy source code into the hub.
- Hand convergent work to `piper-workflow`, `review`, or `automation-policy`.
- Do not push, merge to a remote, open a pull request, install dependencies,
  or run external automation unless the selected workflow has reached that
  action and the `external` ask has a go-ahead; see `automation-policy.md`.
  Commits and worktree changes are routine once reached. Delete, force-push, rewrite pushed history, deploy to
  production, or take other exceptional actions only after explicit one-off
  approval through `automation-policy`.
