---
name: brainstorm
description: "Codex front door for Piper Station project work — explore, understand, decide, or explicitly register rather than execute. Trigger via $brainstorm or by stating the intent. Use to orient to a repo or registered project, frame a problem, compare approaches, investigate how things work, and route deterministic registration. Stays read-only except explicit registration through the helper; routes to piper-workflow, review, or automation-policy when work converges."
---

# Brainstorm (Codex)

Brainstorm is where you decide what is worth doing before the convergence engine
commits. The rest of Piper Station — registration, specs, task queues, Ralph,
compaction — produces durable, executable work; brainstorm is the counterweight
that frames the problem, weighs options, and grounds them in reality first. It
answers "what should we build, and is it the right thing?" while `piper-workflow`
answers "how do we build it well?"

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
into any other durable work is an explicit escalation.

## References

- `references/add-project.md` — register a repo in the hub ledger (the hinge
  into convergent work).

Convergent work escalates out of brainstorm: use `piper-workflow` (via
`$piper-workflow` or `/superpowers`, `/ralph`, `/compact-handoff`) for formal
planning and Ralph execution, `review` for review gates, and `automation-policy`
before protected actions.

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
4. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md` for
   the canonical record; read `projects/<project-id>/work/context-pack.md` when
   it exists.
5. Inspect the real repo path with `git status`, current branch, current HEAD,
   and the files relevant to the request.
6. If the project repo is outside the current Codex sandbox, note that Codex
   must be started with `--add-dir <project-repo>` before any later editing.
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

## Hand-Off Brief

When direction converges, produce a decision-ready brief in the conversation —
no durable writes. It is the bridge into convergent work and becomes the first
checklist `piper-workflow` verifies. Include the problem framing (real problem,
goals, non-goals), options considered and the tradeoffs that mattered, the
recommended direction and why, a short pressure-test of that direction (failure
modes or a quick pre-mortem), open questions and assumptions to verify, and the
suggested next surface.

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

Brainstorm acts on the band of signals up to and including registration;
everything beyond it is a convergent escalation (see Escalation). The full
intent-to-writes map lives in `STATION.md`.

The front-door band covers read-only orientation and conversational planning,
plus explicit deterministic registration. Registration may create only
`project.md`, `memory.md`, `decisions.md`, `projects/registry.json`, and
optional repo markers through the helper. Beyond registration, formal planning,
Ralph execution, finish, and automation are convergent routes owned by
`piper-workflow`, `review`, or `automation-policy`.

Ambiguous signals must not silently escalate durable writes. If intent is
unclear, state the assumption and choose the less durable action or ask.

## Escalation

When the request converges, hand it to the smallest convergent surface that
fits. Escalation is one-way: brainstorm states the consequence and passes the
brief.

| Converged signal | Hand off to |
| --- | --- |
| "make this a formal plan", "prepare for Ralph", "create the queue", "set this up for later" | `piper-workflow` — formal planning |
| "start Ralph", "build task X", "execute the queue item", "implement the plan" | `piper-workflow` — Ralph execution |
| "review this change" or an implemented slice or review gate | `review` |
| "commit", "open a PR", "push", "install", "run CI", or external/destructive action | `automation-policy` |
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
- Registration runs only through the deterministic helper.
- Do not copy source code into the hub.
- Hand convergent work to `piper-workflow`, `review`, or `automation-policy`.
- Do not commit, push, merge, delete, install dependencies, or run external
  automation without explicit user approval; see `automation-policy.md`.
