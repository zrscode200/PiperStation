---
name: piper-workflow
description: "Use for natural-language Piper Station project work: register or orient to projects, resolve repo context, choose Intent/Superpowers/Ralph/Review/Finish, and route to the right supporting behavior."
---

# Piper Workflow

Piper Workflow owns natural-language dispatch for Piper Station project work.
Slash commands are explicit shortcuts into the same behavior. Use this skill
when the user asks to register a repo, work on a registered project, plan,
implement, review, finish, compact, or perform protected automation.

This skill routes. It does not replace the detailed behavior in
`superpowers-planning`, `ralph-loop`, `review`, or `automation-policy`.

Read `{{INSTRUCTION_DOC}}` and `STATION.md` first. Use the other root docs as
canonical references when product, architecture, convention, testing, security,
or automation-policy details matter.

## Register

1. Validate that the target path is a git repo.
2. Register with {{REGISTRATION_ENTRYPOINTS}} or the deterministic helper:

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
7. {{WORKSPACE_ACCESS}}
8. Treat uncommitted changes as user-owned unless the user says otherwise.

## Route

Choose the smallest safe path that fits:

| User intent | Route | Supporting behavior |
| --- | --- | --- |
| Register a repo | registration | helper described above |
| Orient to a repo or ambiguous request | Intent Mode | this skill |
| Discover, specify, or plan substantial work | Superpowers Mode | `superpowers-planning` |
| Execute one clear queued task | Ralph Mode | `ralph-loop` |
| Review code or an implemented slice | Review Mode | `review` |
| Commit, PR, dependency, network, CI, destructive, or external action | Finish Mode or approval flow | `automation-policy` |
| Pause or compact active work | compact handoff | `/compact-handoff`; `ralph-loop` when Ralph work is active |

Use visible mode names when they help continuity, but do not make the user
operate the mode layer. If the route is clear and safe, proceed naturally.
Wait for go-ahead when the selected path requires confirmation, risk is `L2`,
the request is ambiguous, or the user asked only for orientation.

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

## Guardrails

- Do not copy source code into the hub.
- Do not write hub active work records into registered project repos.
- Do not add sessions, checkpoints, dashboards, queue managers, or lifecycle
  shell workflows.
- Keep planning, Ralph, review, and compaction as prompt and skill behavior.
  The deterministic shell helper is for project registration.
- Do not commit, push, merge, delete, install dependencies, or run external
  automation without explicit user approval; see `automation-policy.md`.
