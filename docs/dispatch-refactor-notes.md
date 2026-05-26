# Dispatch Refactor Notes

These notes capture the agreed direction for making Piper Station feel more
natural without changing the detailed behavior already designed for planning,
implementation, review, automation approval, or compaction.

## Problem

The current system has commands, skills, and named modes:

- commands such as `/work-on`, `/superpowers`, `/ralph`, and
  `/compact-handoff`
- skills such as the old `hub-workflow`, broad planning/Ralph skills, `review`,
  and `automation-policy`
- modes such as Intent, Superpowers, Ralph, Review, and Finish

This creates a useful frame, but it can feel mechanical in use. A user who says
"work on project X and fix Y" should not have to understand the mode layer or
manually choose a workflow command before the assistant can behave naturally.

## Agreed Direction

Refactor dispatch and triggering, not the detailed behavior.

The system should have a broad Piper workflow router that handles natural
project-work requests and routes to the existing specialized behaviors:

```text
natural request
  -> piper-workflow router
  -> supporting behavior:
       hub orientation or registration
       planning
       one-slice implementation loop
       review
       automation approval
       compact handoff
```

The router should behave more like the `project-manager` skill in the
office-work assistant design: it identifies intent, resolves the right path,
and follows the appropriate command, root-guide, or narrow-skill mechanics.

## Boundary

This refactor should change:

- how normal user requests enter the system
- how skills are described and triggered
- whether `/work-on` is explicit or implicit for ambiguous project work
- how commands and skills divide dispatch responsibility
- runtime-specific trigger phrasing in Codex, Claude Code, and OpenCode

This refactor should not change:

- the planning discipline preserved in `/superpowers` and shared docs
- the one-slice implementation loop preserved in `/ralph` and shared docs
- review gate rules
- automation approval tiers
- hub/project ownership boundaries
- compact handoff requirements
- the rule that project source stays in registered project repos
- generated adapter mechanics except where wording must change

## Runtime Constraint

Piper Station supports Codex, Claude Code, and OpenCode. These runtimes do not
necessarily trigger skills, commands, agents, and hooks in the same way.

The shared core should define behavior semantics:

- router chooses the path
- planning plans
- Ralph loop implements one scoped slice
- review reviews
- automation policy gates protected actions
- piper workflow handles lookup, registration, orientation, and routing

Adapters should map that shared model onto each runtime's native mechanisms:

- Codex: `AGENTS.md`, `.codex/commands`, `.codex/skills`, `.codex/agents`,
  hooks, and skill descriptions
- Claude Code: `CLAUDE.md`, `.claude/commands`, `.claude/skills`,
  `.claude/agents`, and hooks
- OpenCode: `AGENTS.md`, `opencode.json`, `.opencode/commands`,
  `.opencode/skills`, `.opencode/agents`, permissions, and config

Keep the behavior contract shared, but let each adapter expose and phrase it in
the way that runtime naturally responds to.

## Implementation Plan

Implement the refactor with low compatibility churn:

- Add `piper-workflow` as the broad natural-language router skill.
- Remove `hub-workflow` as a rendered skill and fold its registration,
  project-record lookup, and repo-orientation mechanics into `piper-workflow`
  and `STATION.md`.
- Keep existing command filenames and visible mode names.
- Treat slash commands as explicit shortcuts; ordinary natural-language project
  work routes through `piper-workflow`.
- Preserve the detailed planning and Ralph behavior in commands and shared
  docs, while keeping `review`, `automation-policy`, and compact handoff as
  narrow supporting behavior.
- Update runtime adapter wording for Codex, Claude Code, and OpenCode without
  changing runtime mechanics beyond rendered skill/config references.
- Update tests to assert `piper-workflow` exists, `hub-workflow` is absent, and
  generated outputs stay current.

## Possible Target Shape

Current target shape:

```text
piper-workflow
  broad router for natural project-work requests

/superpowers
  explicit planning command after formal planning is selected

/ralph
  explicit implementation command after one clear task is selected

review
  existing explicit review and implementation review gate behavior

automation-policy
  existing protected-action approval behavior
```

Named modes can remain as internal phase labels, but they should not be the
primary user-facing control plane.

## Design Aim

The assistant should feel like:

```text
User asks for project work
Assistant resolves project and repo
Assistant inspects current state
Assistant decides whether this is direct work, planning, implementation,
review, finish, or protected automation
Assistant proceeds naturally when safe
```

The goal is to preserve Piper Station's rigor while removing the feeling that
the user is operating a workflow machine.

## Session Review Decisions

After testing `piper-workflow` in a real Piper Station hub session, the
observed behavior was directionally correct: natural-language project requests
entered through the Piper workflow, registration happened only after the user
made the work formal, and Ralph preparation wrote hub records without touching
project source.

The next refinement should focus on making the routing less visible while
keeping the behavior predictable.

Agreed refinements:

- `piper-workflow` should be the only broad natural-language workflow trigger.
  Supporting behavior for planning, Ralph execution, review, and automation
  should not compete as independent broad entry points.
- Routing decisions should be visible only when they clarify consequences. For
  example, say "I will keep this read-only" or "I will create Ralph-ready work
  records", not "entering mode X" unless the user asked for that mode.
- Add an artifact policy instead of a new user-facing formality ladder. The
  policy should describe when the assistant creates durable hub records.
- Before declaring Ralph execution ready, verify whether the real project repo
  is writable in the current session, or state that writable access will be
  required for the next execution turn.

The artifact policy is internal routing guidance, not another mode taxonomy
for users to operate.

### Artifact Signal Policy

The assistant should infer the artifact level from the user's intent signal and
state the consequence when it matters. The signal needs more detail than a
single label because adjacent requests can sound similar but imply different
durable writes.

| User signal | Interpretation | Durable writes | Assistant stance |
| --- | --- | --- | --- |
| "review this repo", "understand what this does", "what is this project", or a repo path with an explanation/review request | Orientation or review | None by default | Inspect the repo in place. Say the work is read-only and that registration or hub records will wait unless asked. |
| "what would it take", "how should we approach", "compare this to", "plan the refactor" before registration | Conversational planning | None by default | Produce a grounded plan in chat. Use references and live repo inspection, but avoid hub records unless the user asks to formalize. |
| "register this", "track this project", "this is formal work now" | Registration | `project.md`, `memory.md`, and `decisions.md` only | Use the registration helper. Prefer hub-only records unless repo marker files are explicitly wanted. Do not create `work/` or start implementation. |
| "make this a formal plan", "prepare for Ralph", "create the queue", "we need continuity", or "set this up for later execution" | Formal planning or Ralph preparation | `projects/<id>/work/` records | Create the useful durable record set for the scope, such as active spec, active plan, task queue, context pack, progress, and verification. State that this is durable prep and that project source remains untouched. |
| "start Ralph", "build task X", "execute the first queue item", or "implement according to the plan" | Ralph execution | Update `work/` records as useful; edit the real project repo | Confirm the selected task, diff boundary, risk, verification, and writable repo access before editing. Execute one scoped slice. |
| "finish", "commit", "open a PR", "push", "install", "run CI repair", or any external/destructive action | Finish or protected automation | Only after explicit approval where required | Summarize state, verification, and risk first. Ask for approval before protected state changes. |

Ambiguous signals should not silently escalate durable writes. If the next step
would create hub records, edit project source, or take protected action and the
user's intent is unclear, state the assumption and ask or choose the less
durable action. Read-only inspection and conversational planning can proceed
when they are clearly safe.
