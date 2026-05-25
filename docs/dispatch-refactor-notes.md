# Dispatch Refactor Notes

These notes capture the agreed direction for making Piper Station feel more
natural without changing the detailed behavior already designed for planning,
implementation, review, automation approval, or compaction.

## Problem

The current system has commands, skills, and named modes:

- commands such as `/work-on`, `/superpowers`, `/ralph`, and
  `/compact-handoff`
- skills such as `hub-workflow`, `superpowers-planning`, `ralph-loop`,
  `review`, and `automation-policy`
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
and follows the appropriate command or supporting skill mechanics.

## Boundary

This refactor should change:

- how normal user requests enter the system
- how skills are described and triggered
- whether `/work-on` is explicit or implicit for ambiguous project work
- how commands and skills divide dispatch responsibility
- runtime-specific trigger phrasing in Codex, Claude Code, and OpenCode

This refactor should not change:

- the planning discipline in `superpowers-planning`
- the one-slice implementation loop in `ralph-loop`
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
- Preserve the detailed behavior in `superpowers-planning`, `ralph-loop`,
  `review`, `automation-policy`, and compact handoff.
- Update runtime adapter wording for Codex, Claude Code, and OpenCode without
  changing runtime mechanics beyond rendered skill/config references.
- Update tests to assert `piper-workflow` exists, `hub-workflow` is absent, and
  generated outputs stay current.

## Possible Target Shape

One possible shape:

```text
piper-workflow
  broad router for natural project-work requests

superpowers-planning
  existing planning behavior after planning is selected

ralph-loop
  existing implementation loop after one clear task is selected

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
