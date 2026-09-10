# Native runtime entry points

Piper's phase, ownership, design, review and action contracts live in `STATION.md`
and shared skills. Use only the row for the CLI actually running this session.
An installed adapter or old session handle does not identify the active runtime.

**Validation status — 2026-09-08:** Claude Code and Copilot adapter wiring has
passed local synthetic/distribution checks and independent implementation
review. Live model sessions have not yet been validated for this change.
Verify native instruction/skill discovery, selected roles and effective tools
in your installed CLI; generated files alone do not establish these behaviors.

| CLI | Launch from the hub | Instructions | Skills | Native roles |
| --- | --- | --- | --- | --- |
| Codex | `codex` | `AGENTS.md` | `.codex/skills/` | `.codex/agents/<role>.toml` |
| Claude Code | `./bin/piper-claude` | `CLAUDE.md` imports `AGENTS.md` | `.claude/skills/` | `.claude/agents/<role>.md` |
| OMP (Oh My Pi) | `omp` at hub root | `AGENTS.md` | `.omp/skills/` | `.omp/agents/{investigator,reviewer}.md`; standalone `.omp/roles/implementer.md` |
| GitHub Copilot CLI | `copilot` | `AGENTS.md` and `.github/copilot-instructions.md` | `.claude/skills/` (a documented Copilot discovery path) | `.github/agents/<role>.agent.md` |

Use skills by intent or name. Codex supports `$brainstorm`, `$design-studio`,
`$piper-workflow` and `$review`; Claude Code and Copilot CLI use `/brainstorm`,
`/design-studio`, `/piper-workflow` and `/piper-review`. The last name avoids
collision with a built-in `/review` command. Superpowers, Ralph, registration
and compact handoff procedures remain references inside their owning skills.
OMP uses `/skill:brainstorm`, `/skill:design-studio`, `/skill:piper-workflow`
and `/skill:piper-review`. There is no additional Piper command engine.

Claude Code and Copilot intentionally share identical files under `.claude/skills`
so a combined installation has one copy of each shared skill. Copilot also
discovers Claude role profiles; its `.github/agents` profiles take precedence at
the same project level. Inspect the actual loaded native role when dispatching,
and use the matching brief explicitly if role selection is unavailable.

## Lifecycle behavior

Codex loads `.codex/hooks.json` and its compact prompt through native settings.
Claude's thin launcher changes to this hub and execs the native CLI with
`.piper/runtime/claude-settings.json`; all supplied CLI arguments are passed
through. It sets no model, permission, authentication or sandbox defaults.
Running bare `claude` still loads Piper instructions, skills and roles, but does
not load these Piper lifecycle hooks. An explicit user `--settings` option may
override the launcher's hook settings according to native CLI precedence.

Claude hook settings intentionally stay outside `.claude/settings.json` because
Copilot reads that file too. Copilot's own hooks live in `.github/hooks/piper.json`.
This isolates Piper's registrations; user-added hooks remain the user's own
configuration and may be shared by their CLIs.

Codex and Claude SessionStart hooks restore model-facing context on startup,
resume and compaction. Copilot's sessionStart restores startup/resume context;
its preCompact event is notification-only and has no documented postCompact
counterpart. The shared explicit checkpoint/resume procedure remains required
in every runtime. Hooks are reminders: none writes records, asserts a checkpoint
happened, blocks compaction or changes permissions. A prompt or status message
is not evidence of a persisted packet.

## Roles and workspace access

Each runtime supplies investigator, implementer and reviewer with the same
behavioral briefs; OMP uses a standalone implementer supplement as described below. Claude and Copilot observers have read/search/web tools only;
they cannot run shell-based checks through those profiles. The parent may run
checks and supply evidence, or report a check as unavailable. Do not broaden an
observer's tools to work around this limit. An implementer has editing and shell
tools, but still needs an explicitly assigned exclusive checkout and branch.

Codex observer configs request read-only sandbox narrowing when the client
applies their overlays. Claude/Copilot tool allowlists are not equivalent to an
OS sandbox. Report observed worker tools/permissions or mark them unverified;
native selection and prompt compliance never prove stronger enforcement.

All four CLIs support `--add-dir <checkout-path>` in current documented CLI
surfaces. Verify actual writable access before editing; host policy can still
deny it. Claude does not normally load CLAUDE.md from an added directory, while
Copilot may load trusted skills/agents there. Pass absolute hub/record references
with worker assignments and inspect the resolved role. Do not change the active
runtime's managed settings, enable bypass modes, or install dependencies to gain
access. Native user/host model, effort, trust and permission choices remain in
effect.

Source distribution compatibility evidence and official documentation references
are recorded in its `docs/capability-matrix.md`; generated-file tests establish
wiring, not end-to-end model behavior.

## OMP native behavior

Launch ordinary `omp` at the installed hub root. Native `.omp/extensions/piper.js`
discovery is cwd-only; launching in a nested source directory may load ancestor
skills/instructions without the extension. OMP `.omp/skills` wins matching names
from foreign runtimes; in a Codex combination the `review` alias may also appear
with the same canonical procedure. Prefer `piper-review`. User discovery filters
can disable Piper surfaces; no settings, models or permissions are overwritten.

OMP restores context on the first turn and after switches, branches, tree
navigation and compaction. Initial resume guidance also covers `--continue` and
`--resume`. Compaction adds a reminder to summary context and UI, not a persisted
checkpoint. Records supply continuity; earlier CLI conversations are not imported.

Native task agents `piper-investigator` and `piper-reviewer` request read/search/web
tools with nested spawning disabled. OMP may add reporting/collaboration tools;
inspect the actual tool set and do not assume an OS sandbox. Headless children
may bypass interactive approvals internally. Shell checks remain with the parent.
The bundled `reviewer` and `/review` are separate from Piper's review gate.

For authorized source writers, use a separate OMP session in an explicitly
assigned persistent checkout/branch. Verify `.omp/roles/implementer.md` exists,
then pass its absolute path with `--append-system-prompt` to `omp --cwd <checkout>`.
Provide the bounded assignment, source instructions and absolute hub references;
the plain brief does not configure permissions or tools. Verify actual writable
access; keep records, acceptance and integration with the coordinator.

Do not dispatch durable source writers through native `task` from the hub:
OMP 18.0.8 has no per-task cwd and isolated tasks autoapply by default, then remove
their temporary workspaces. Failed runs can lose edits without a retained patch.
Disabling apply alone does not preserve a checkout, and eval-backed invocation
has separate controls. No Piper setting pretends to repair those constraints.
OMP 18.0.8 is the checked contract; live model behavior remains unvalidated.
