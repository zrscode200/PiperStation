---
name: piper-workflow
description: "Codex convergent execution for Piper Station project work — use when executing rather than exploring. Trigger via $piper-workflow or by stating the intent once direction is set: write a formal spec and plan, prepare a Ralph-ready queue, execute one scoped Ralph slice, prepare compact-safe handoff, or route a protected finish action. Routes to the matching procedure under references/."
---

# Piper Workflow (Codex)

Piper Workflow owns convergent execution for Piper Station project work in
Codex: formal planning, Ralph preparation, Ralph execution, compaction handoff,
and finish routing. It is entered from the `brainstorm` front door once a
request has converged on a direction, or directly by invoking
`$piper-workflow ...` or stating the intent.

Codex CLI does not surface `.codex/commands/` as slash commands; the detailed
procedures live as reference files in this skill directory. The divergent phase
— orientation, framing, exploration, and registration — belongs to `brainstorm`;
if a request is actually still divergent, hand it back. Read `AGENTS.md` and
`STATION.md` first, resolve the project in `projects/registry.json` to its
`repo_path`, and read `projects/<project-id>/project.md`, `memory.md`, and
`decisions.md` before executing.

## References

- `references/superpowers.md` — verify the handed-off direction, then specify
  and plan Ralph-ready work.
- `references/ralph.md` — execute one scoped implementation slice with review
  discipline.
- `references/compact-handoff.md` — prepare compact-safe continuity records
  before pause or compaction.

Use the narrow skills when their specific consequence applies: `review` for
explicit review or review gates, `automation-policy` before protected automation
or external state changes. Orientation and registration route through the
`brainstorm` skill.

## Dispatch

Choose the smallest convergent path that fits:

| User intent | Route | Procedure |
| --- | --- | --- |
| Verify direction, specify, or plan substantial work | Superpowers Mode | `references/superpowers.md` |
| Execute one clear queued task | Ralph Mode | `references/ralph.md` and Ralph sections in `STATION.md` |
| Review code or an implemented slice | Review Mode | the `review` skill |
| Commit, PR, dependency, network, CI, destructive, or external action | Finish Mode or approval flow | the `automation-policy` skill |
| Pause or compact active work | compact handoff | `references/compact-handoff.md` and compact sections in `STATION.md` |
| Orient, explore, or decide what to do | hand back | the `brainstorm` skill |

Prefer consequence language such as "I will create Ralph-ready work records"
over ceremonial mode announcements. Proceed when the route is clear and safe;
wait for go-ahead when confirmation is required, risk is `L2`, or the request is
ambiguous.

## Superpowers Entry

Superpowers begins where `brainstorm` ended. Its lead step is verification, not
open exploration: take the direction from brainstorm's hand-off brief and
confirm it against the real code — validate the brief's flagged assumptions,
check the files and call sites the work will touch, and confirm acceptance
criteria are testable — before locking a durable spec and plan.

## Artifact Signal Policy

This skill handles the convergent signals; `brainstorm` owns the read-only band.
When intent reaches these rows, durable writes are expected. The full
intent-to-writes map lives in `STATION.md`.

| User signal | Interpretation | Durable writes | Assistant stance |
| --- | --- | --- | --- |
| "make this a formal plan", "prepare for Ralph", "create the queue", or "set this up for later execution" | Formal planning or Ralph preparation | Useful `projects/<id>/work/` records | Verify the handed-off direction, then create the durable record set the scope needs. State that project source remains untouched. |
| "start Ralph", "build task X", "execute the first queue item", or "implement according to the plan" | Ralph execution | Update `work/` records; edit the real project repo | Confirm the selected task, diff boundary, risk, verification, and writable repo access before editing. Execute one scoped slice. |
| "finish", "commit", "open a PR", "push", "install", "run CI repair", or external/destructive action | Finish or protected automation | Only after explicit approval where required | Summarize state, verification, and risk first; route through `automation-policy`. |

## Scope And Risk

Classify scope:

- `S0`: direct small task; no artifact needed.
- `S1`: short active plan when continuity is useful.
- `S2`: written spec and plan required before implementation.
- `S3`: split into milestones or sub-specs.

Classify risk:

- `L0`: trivial or local.
- `L1`: normal implementation.
- `L2`: explicit user confirmation required before Ralph executes.
- `L3`: forbidden inside Ralph; stop and ask.

## Workspace Access

Before Ralph execution, verify the real project repo is writable in the active
Codex session. If it is outside the current sandbox, tell the user that Codex
must be started with `--add-dir <project-repo>` or that sandbox access must
otherwise be granted before execution — do not declare the task Ralph-ready
until writable access exists.

## Subagent Helpers

The hub declares six Codex subagent roles in `.codex/config.toml`:
`reviewer`, `implementer`, `tester`, `architect`, `docs_researcher`,
`security_reviewer`. Spawn the matching role when its specific responsibility
applies — for example, `reviewer` during a Ralph review gate, or
`security_reviewer` for auth/permissions changes. (`architect` and
`docs_researcher` also support `brainstorm`'s read-only investigation.)

The main session stays responsible for the work. Verify each subagent finding
before acting; apply only valid in-scope fixes; turn valid out-of-scope findings
into follow-up notes or queue items.

## Durable Context

Update hub records only when useful:

- `memory.md`: durable facts, user preferences, stable repo conventions, and
  reusable context.
- `decisions.md`: meaningful choices, tradeoffs, accepted risks, or policy
  decisions future work should not silently reopen.

Routine progress, command output, and transient notes should stay in the
conversation unless substantial active work needs continuity under
`projects/<project-id>/work/`.

Create `projects/<project-id>/work/` only when useful. Registration (in
`brainstorm`) must not create active work artifacts.

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Do not add sessions, checkpoints, dashboards, queue managers, or lifecycle
  shell workflows.
- Keep planning, Ralph, review, and compaction as prompt, skill, reference, and
  narrow consequence-specific behavior. The deterministic shell helper is for
  project registration only.
- Orientation and registration belong to `brainstorm`; this skill assumes a
  registered, converged target.
- Do not commit, push, merge, delete, install dependencies, or run external
  automation without explicit user approval; see `automation-policy.md`.
