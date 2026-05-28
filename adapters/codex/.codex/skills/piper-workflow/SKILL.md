---
name: piper-workflow
description: "Codex natural-language dispatch for Piper Station project work. Use when the user asks to register a project repo, work on a registered project, plan, implement, review, finish, compact, or run protected automation. Routes to the matching procedure under references/."
---

# Piper Workflow (Codex)

Piper Workflow owns natural-language dispatch for Piper Station project work in
Codex. Codex CLI does not surface `.codex/commands/` as slash commands; this
skill is the entry point. Detailed procedures live as reference files in this
skill directory.

Trigger this skill by invoking `$piper-workflow ...` or by stating the project
intent directly. Read `AGENTS.md` and `STATION.md` first, then the matching
reference below.

## References

- `references/add-project.md` — register a repo in the hub ledger.
- `references/work-on.md` — orient to a project and choose the smallest safe
  route.
- `references/superpowers.md` — discover, specify, plan, and prepare
  Ralph-ready work.
- `references/ralph.md` — execute one scoped implementation slice with review
  discipline.
- `references/compact-handoff.md` — prepare compact-safe continuity records
  before pause or compaction.

Use the narrow skills only when their specific consequence applies: `review`
for explicit review or review gates, `automation-policy` before protected
automation or external state changes.

## Dispatch

Choose the smallest safe path that fits the request:

| User intent | Route | Procedure |
| --- | --- | --- |
| Register a repo | registration | `references/add-project.md` and `./bin/add-project` |
| Orient to a repo or ambiguous request | Intent Mode | `references/work-on.md`; stay read-only unless the user asks for durable work |
| Discover, specify, or plan substantial work | Superpowers Mode | `references/superpowers.md` |
| Execute one clear queued task | Ralph Mode | `references/ralph.md` and Ralph sections in `STATION.md` |
| Review code or an implemented slice | Review Mode | the `review` skill |
| Commit, PR, dependency, network, CI, destructive, or external action | Finish Mode or approval flow | the `automation-policy` skill |
| Pause or compact active work | compact handoff | `references/compact-handoff.md` and compact sections in `STATION.md` |

Use visible mode names only when they help continuity. Prefer consequence
language such as "I will keep this read-only" or "I will create Ralph-ready
work records" over ceremonial mode announcements. Proceed naturally when the
route is clear and safe; wait for go-ahead when the route requires
confirmation, risk is `L2`, the request is ambiguous, or the user asked only
for orientation.

## Artifact Signal Policy

Infer durable artifacts from the user's intent signal. Adjacent requests can
sound similar but imply different writes, so state the consequence when it
matters.

| User signal | Interpretation | Durable writes | Assistant stance |
| --- | --- | --- | --- |
| "review this repo", "understand what this does", "what is this project", or a repo path with an explanation or review request | Orientation or review | None by default | Inspect the repo in place. Say the work is read-only and that registration or hub records will wait unless asked. |
| "what would it take", "how should we approach", "compare this to", or "plan the refactor" before registration | Conversational planning | None by default | Produce a grounded plan in chat. Use references and live repo inspection, but avoid hub records unless the user asks to formalize. |
| "register this", "track this project", or "this is formal work now" | Registration | `project.md`, `memory.md`, and `decisions.md` only | Use the registration helper. Prefer hub-only records unless repo marker files are explicitly wanted. Do not create `work/` or start implementation. |
| "make this a formal plan", "prepare for Ralph", "create the queue", "we need continuity", or "set this up for later execution" | Formal planning or Ralph preparation | Useful `projects/<id>/work/` records | Create the durable record set the scope needs, such as active spec, active plan, task queue, context pack, progress, and verification. State that this is durable prep and that project source remains untouched. |
| "start Ralph", "build task X", "execute the first queue item", or "implement according to the plan" | Ralph execution | Update `work/` records as useful; edit the real project repo | Confirm the selected task, diff boundary, risk, verification, and writable repo access before editing. Execute one scoped slice. |
| "finish", "commit", "open a PR", "push", "install", "run CI repair", or external/destructive action | Finish or protected automation | Only after explicit approval where required | Summarize state, verification, and risk first. Ask for approval before protected state changes. |

Ambiguous signals must not silently escalate durable writes. If the next step
would create hub records, edit project source, or take protected action and the
user's intent is unclear, state the assumption and ask or choose the less
durable action. Read-only inspection and conversational planning can proceed
when clearly safe.

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
`security_reviewer` for auth/permissions changes.

The main session stays responsible for the work. Verify each subagent finding
before acting; apply only valid in-scope fixes; turn valid out-of-scope
findings into follow-up notes or queue items.

## Durable Context

Update hub records only when useful:

- `memory.md`: durable facts, user preferences, stable repo conventions, and
  reusable context.
- `decisions.md`: meaningful choices, tradeoffs, accepted risks, or policy
  decisions future work should not silently reopen.

Routine progress, command output, and transient notes should stay in the
conversation unless substantial active work needs continuity under
`projects/<project-id>/work/`.

Create `projects/<project-id>/work/` only when useful. Registration must not
create active work artifacts.

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Do not add sessions, checkpoints, dashboards, queue managers, or lifecycle
  shell workflows.
- Keep planning, Ralph, review, and compaction as prompt, skill, reference,
  and narrow consequence-specific behavior. The deterministic shell helper is
  for project registration only.
- Do not commit, push, merge, delete, install dependencies, or run external
  automation without explicit user approval; see `automation-policy.md`.
