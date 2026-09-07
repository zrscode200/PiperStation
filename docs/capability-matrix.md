# Codex distribution and wiring

This development branch supports Codex only. Other runtimes remain available
in repository history; no adapters or installable templates for them are
maintained here.

| Surface | Source owner | Installed path |
| --- | --- | --- |
| Always-on summary | `adapters/codex/AGENTS.md` | `AGENTS.md` |
| Operating contract and project record ownership | `core/shared/` | Hub root docs and initial `projects/` skeleton |
| Intent routing and skill behavior | `core/skills/` | `.codex/skills/<skill>/` |
| Explicit procedure bodies | `core/commands/` | Owning skill's `references/` directory |
| Native settings and role declarations (client-dependent selection) | `adapters/codex/.codex/config.toml` | `.codex/config.toml` |
| Delegated role instructions | `adapters/codex/.codex/agents/` | `.codex/agents/` |
| Lifecycle reminders and compaction guidance | `adapters/codex/.codex/` | `.codex/hooks.json`, `.codex/hooks/`, `.codex/compact-prompt.md` |
| Registration | `core/shared/.piper/lib/bootstrap/` | `bin/add-project` invokes the launcher, which shares the `piper-record` publication lock around the shell implementation |

Codex does not auto-surface `.codex/commands` as slash commands; skills route to
procedure references. The renderer rejects any adapter that shadows a core
output, so a behavioral fix has one source owner.

Installed configuration remains subject to the active Codex client's trust,
workspace permissions, and supported native features. Generated-file checks
verify wiring and syntax; fresh Codex runs supply behavior evidence. Native
memory is not the canonical project ledger.

## Runtime defaults and user choices

Piper installs behavior and native hook/skill/role wiring. It does not pin the
root or worker model, reasoning effort, review model, memory enablement, thread
count, or delegation depth. Project configuration outranks user/profile defaults,
so those pins would silently replace the user's choices. Current custom-role
model/effort settings can even override explicit spawn choices; omitting them
allows native inheritance. See the official [configuration precedence](https://learn.chatgpt.com/docs/config-file/config-basic#configuration-precedence)
and [subagent configuration](https://learn.chatgpt.com/docs/agent-configuration/subagents).

Root sandbox/approval settings and writable-worker sandbox overrides are also
omitted: permissions come from the user or host, and a missing workspace grant
must be reported rather than expanded. Read-only helper role configs retain explicit narrowing for clients that apply
those overlays; declared config alone does not prove a worker used it. Native hooks still require trust. Memory remains optional
supplemental recall; `projects/` records are the durable authority. The official
[config reference](https://learn.chatgpt.com/docs/config-file/config-reference)
describes memory choices, supported agent settings, and permission profiles.

The pre-change pinned configuration successfully started the initial strict
Codex CLI 0.153.4 design experiments. Removing its defaults is a usability and
inheritance correction, not a claim that those experiments failed to start.
A subsequent native cold-resume probe using `default_permissions = ":workspace"`
inherited the selected `gpt-6-astra` model and workspace-write permissions. Its
exposed `collaboration.spawn_agent` tool had no `agent_type` parameter. The fresh
review worker received an explicit read-only assignment, but that does not prove
`reviewer.toml` or its sandbox overlay was invoked. This establishes the observed
parent configuration and a behavioral review path; custom read-only role overlay
compatibility remains unproven in that client.

Piper therefore uses configured role selection only when the actual client exposes
it. Otherwise it passes the relevant installed role brief explicitly and reports
actual worker permissions as observed or unverified. Read-only review behavior
remains required; a prompt is not sandbox enforcement. TOML configs remain
installed for clients that support their native selection. The subsequent
[three-role evaluations](subagent-experiments.md) exercised investigator,
implementer and reviewer briefs, including source-preserving temporary-fixture
checks; they still do not establish native role-overlay enforcement.

Registration validates hub records and optional repo-marker destinations before
writing, then rechecks under the shared publication lock. `--hub-only` leaves
repo markers alone. Hub, project-record and marker symlinks are not followed by
registration; choose canonical paths or hub-only registration as appropriate.
Git metadata and `.piper/locks/` are operational state and can never be removed
through a stale template manifest, including case aliases on macOS. Project
records remain hub-owned even if an old manifest uses `./projects/` or a
differently cased spelling.

`--git-init` creates or preserves the hub's own Git root, including when the hub
is nested inside another repository. This is required for scoped hub checkpoint
commits: an enclosing repository is never used as the hub's commit destination.

## Updating an existing hub

The managed role set is `investigator`, `implementer` and `reviewer`. Refreshing
a seven-role Codex hub retires the managed architect, docs-researcher,
security-reviewer, tester and verifier files. It preserves project records,
retained assignments, source workspaces and unmanaged files. Map old assignments
using the [accepted design](subagent-design.md); an old name or handle is
historical context, not evidence that its worker stopped. Resolve actual
ownership before reassignment. Refresh at an idle boundary after affected
sessions checkpoint and no active worker depends on the old instructions.

For a Codex-only hub, run:

```sh
./bootstrap/init.sh --dry-run /path/to/hub
./bootstrap/init.sh /path/to/hub
```

The legacy `--runtime codex` argument remains valid. Other names and runtime
combinations are rejected before creating or modifying the target. Bootstrap
requires Python 3 to validate the existing manifest and destination paths.

A hub containing `.claude/`, `CLAUDE.md`, `.opencode/`, `opencode.json`, or
`.deepagents/`, or a manifest naming retired runtimes or their managed files,
is refused before any writes. `--force` does not bypass this check. This avoids
silently replacing shared policy while leaving old runtime instructions active.

To retain existing runtime workflows, leave that hub on its current release
and create a separate Codex hub. Register projects there with `--hub-only` when
you want to preserve existing repo marker bindings. Copying useful project
records is a deliberate migration: inspect repo paths, active lane checkouts,
shared decisions, and resume state before treating imported records as current.
Do not run two hubs as concurrent owners of the same active lane checkout.

For an in-place migration, first stop sessions using the hub and commit or back
up its records. Explicitly remove retired runtime surfaces and their manifest
entries, then run the Codex dry-run and refresh. Keep `projects/` and the source
repositories intact. This installer does not perform that destructive migration
or infer permission to remove user configuration.

Historical `docs/artifact-redundancy-map.md`, `docs/dispatch-refactor-notes.md`,
and `docs/piper-raygent-layering-note.md` describe earlier designs, not currently
supported runtime surfaces.
