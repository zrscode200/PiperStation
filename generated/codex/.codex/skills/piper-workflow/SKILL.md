---
name: piper-workflow
description: "Use for natural-language Piper Station project work: register or orient to projects, resolve repo context, infer artifact needs, choose Intent/Superpowers/Ralph/Review/Finish behavior, and route to commands or narrow skills when needed."
---

# Piper Workflow

Piper Workflow owns natural-language dispatch for Piper Station project work.
Slash commands are explicit shortcuts into the same behavior. Use this skill
when the user asks to register a repo, work on a registered project, plan,
implement, review, finish, compact, or perform protected automation.

This skill routes ordinary project work. Superpowers and Ralph are disciplines
implemented through `STATION.md`, `/superpowers`, and `/ralph`, not competing
broad natural-language skills. Use narrow skills only when their specific
consequence applies: `review` for explicit review or review gates and
`automation-policy` before protected automation or external state changes.

Read `AGENTS.md` and `STATION.md` first. Use the other root docs as
canonical references when product, architecture, convention, testing, security,
or automation-policy details matter.

## Register

1. Validate that the target path is a git repo.
2. Register with `./bin/add-project` or the deterministic helper:

   ```sh
   ./bin/add-project --repo <repo-path> --project-id <project-id>
   ```

3. Registration only creates or updates hub project records and optional repo
   markers. It must not start implementation work.
4. Do not manually recreate the helper's file writes in a prompt.

## Orient

1. Identify the project id or repo path from the user request.
2. If the repo is not registered and the user wants project work, ask whether
   to register it first.
3. Read `projects/<project-id>/project.md`, `memory.md`, and `decisions.md`.
4. Read the repo path from the `Path:` line in `project.md`'s
   `<!-- piper-project:start -->` registry block.
5. Read `projects/<project-id>/work/context-pack.md` when it exists.
6. Inspect the real repo path with `git status`, current branch, current HEAD,
   and the files relevant to the request.
7. If the project repo is outside the current workspace or sandbox, ask the user to make it accessible before editing.
8. Treat uncommitted changes as user-owned unless the user says otherwise.

## Route

Choose the smallest safe path that fits:

| User intent | Route | Supporting behavior |
| --- | --- | --- |
| Register a repo | registration | helper described above |
| Orient to a repo or ambiguous request | Intent Mode | this skill; keep it read-only unless the user asks for durable work |
| Discover, specify, or plan substantial work | Superpowers discipline | this skill and `/superpowers` behavior |
| Execute one clear queued task | Ralph discipline | `/ralph` behavior and Ralph sections in `STATION.md` |
| Review code or an implemented slice | Review Mode | `review` |
| Commit, PR, dependency, network, CI, destructive, or external action | Finish Mode or approval flow | `automation-policy` |
| Pause or compact active work | compact handoff | `/compact-handoff` and compact sections in `STATION.md` |

When routing into Superpowers, Ralph, or compact handoff from natural language,
read and follow the matching command file before acting; those commands hold
the detailed operating procedure.

Use visible mode names only when they help continuity. Prefer consequence
language such as "I will keep this read-only" or "I will create Ralph-ready
work records" over ceremonial mode announcements. If the route is clear and
safe, proceed naturally. Wait for go-ahead when the selected path requires
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

Before Ralph execution, verify the real project repo is writable in the active
session. If it is outside the current workspace or sandbox, tell the user that
writable access is required before execution instead of declaring the task
Ralph-ready.

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Do not add sessions, checkpoints, dashboards, queue managers, or lifecycle
  shell workflows.
- Keep planning, Ralph, review, and compaction as prompt, command, and narrow
  consequence-specific behavior. The deterministic shell helper is for project
  registration.
- Do not commit, push, merge, delete, install dependencies, or run external
  automation without explicit user approval; see `automation-policy.md`.
