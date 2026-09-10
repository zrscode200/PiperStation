# Runtime distribution and native wiring

Piper supports `codex`, `claude` (Claude Code CLI), `copilot` (GitHub Copilot
CLI) and `omp` (Oh My Pi), individually or together. All receive the current shared workflow:
brainstorm and optional Design Studio, accepted revisions/adopted details and
later evidence, planning/Ralph/review, independent lanes, exclusive source
checkouts, three bounded roles, protected records/integration, action boundaries
and durable resume. Native capabilities remain distinct.

| Surface | Codex | Claude Code CLI | Copilot CLI |
| --- | --- | --- | --- |
| Entry | `codex` | `./bin/piper-claude` | `copilot` |
| Shared summary | `AGENTS.md` | `CLAUDE.md` imports `AGENTS.md` | `AGENTS.md`, plus `.github/copilot-instructions.md` pointer |
| Skills | `.codex/skills` | `.claude/skills` | `.claude/skills`, a supported discovery path |
| Explicit review skill | `$review` | `/piper-review` | `/piper-review` |
| Three native role profiles | `.codex/agents/*.toml` | `.claude/agents/*.md` | `.github/agents/*.agent.md` |
| Observer tools | read-only sandbox requested when overlay applies | read/search/web only | read/search/web only |
| Startup/resume context | native SessionStart JSON | native SessionStart nested additionalContext | native sessionStart top-level additionalContext |
| Compaction | native hooks and compact prompt | PreCompact reminder; SessionStart restores context after compaction | preCompact notification only; no documented postCompact equivalent |

The renderer rejects adapter files that shadow core output, embeds common
`core/roles` briefs into native wrappers and produces identical shared files in
every output. The installer rejects conflicting overlap before writing. Shared
record formats and deterministic helpers are never forked by runtime.

## Discovery and lifecycle isolation

Claude and Copilot discover `.claude/skills`, so their templates intentionally
use the same paths and bytes. This avoids installing duplicate same-name skills.
The `/piper-review` name avoids built-in review command ambiguity. Copilot's
`.github/agents` profiles take precedence over `.claude/agents` at the same
project level; inspect the loaded profile rather than relying on personal/project
precedence, about which current documentation differs.

Copilot reads both `CLAUDE.md` and `AGENTS.md` and can also read Claude hook
settings. The root summary is therefore runtime-neutral, with native details
in `RUNTIMES.md` scoped to the active CLI. Claude hook settings stay outside its
automatically discovered settings files, at `.piper/runtime/claude-settings.json`.
The thin `bin/piper-claude` helper changes to the hub and execs the native
`claude --settings <absolute-file>` with user arguments unchanged. It does not
manage authentication, sessions, permissions or models. Bare `claude` loads
Piper instructions/skills/roles but omits these lifecycle hooks; use the launcher
for full wiring. A user-supplied `--settings` argument follows native precedence.

Copilot uses `.github/hooks/piper.json` independently. The explicit separation
avoids relying on undocumented tolerance for the other CLI's output schema or
on environment-variable guesses about which client invoked a hook. User-added
Claude settings/hooks remain user-owned and may still be read by Copilot.
Claude hooks use native exec-form arguments so hub paths need no shell quoting.
Copilot 1.0.34 uses a shell command with a quoted project-directory environment
variable; its installed hook schema does not yet support exec-form arguments.

All hooks are read-only reminders. They neither persist a packet nor assert
that a checkpoint happened. Copilot's documented preCompact event does not
process output; explicit checkpoint/resume instructions therefore remain the
reliable cross-runtime procedure. No fabricated postCompact event or compaction
blocking policy is installed.

## Permissions and native choices

Piper does not pin models, reasoning effort, root permissions, sandbox bypass,
trust or authentication. Claude/Copilot observer profiles restrict tools to
reading, searching and web research; shell-based checks must be parent-run or
reported unavailable. Implementers have editing/shell tools but need explicit
Piper source ownership and native access. These tool allowlists are not an OS
sandbox. Codex role sandbox narrowing remains conditional on the client actually
selecting/applying its overlay. Report observed permissions or mark them unknown.

All four CLI surfaces document `--add-dir`; verify effective access at runtime.
Claude normally does not load CLAUDE.md from added directories. Copilot may load
trusted skills/agents there. Workers receive absolute hub/source/record references
and must not infer their assignment from an inherited directory or role name.

## Installation and refresh

```sh
./bootstrap/init.sh --runtime codex,claude,copilot,omp --dry-run /path/to/hub
./bootstrap/init.sh --runtime codex,claude,copilot,omp /path/to/hub
```

New installations default to Codex. An existing supported runtime set is retained
on refresh; `--runtime` adds to that set. All enabled adapters are refreshed
together so shared policy cannot advance while leaving an old supported adapter
active. Disabling/removing a runtime is a deliberate migration, not an installer
side effect. Refresh only at an idle, checkpointed boundary.

The installer preserves `projects/`, source checkouts and unmanaged files. It
preflights manifests, symlink/path collisions, operational Git/lock paths and
runtime compatibility before mutation. Overlapping templates must have identical
bytes and modes. Conflicting unmanaged files, including roles and skills, are
refused before mutation. Existing files can be adopted only when their bytes and
modes already match the template. `--force` is a legacy no-op.

A legacy managed Claude settings file is retired during refresh in favor of the
explicit hook settings/launcher; stale managed role files are also retired.
User-owned settings.local.json, custom roles and retained work records remain.
Supported older Codex/Claude manifests can upgrade together. OpenCode, Deep
Agents and unknown runtimes require explicit migration; no adapter for them is
added by this change. Preserve original hubs while inspecting any imported
project bindings, active checkouts and worker status.

`--git-init` creates the hub's own Git root, including under another repository.
Registration retains `--hub-only` and its shared publication lock. No runtime
adapter expands checkout permissions or changes a registered source repository.

## Evidence and limits — 2026-09-08

Official native contracts were retrieved on 2026-09-08. Local Claude
`--version`/`--help` reported **2.1.260**. Installed Copilot package metadata
reports **1.0.34**, build **18e1ba7**; its `--version`/`--help` could not run in
this sandbox (`SecItemCopyMatching -50`). No credential access or permission
relaxation was attempted. Static inspection confirmed Copilot consumes top-level
SessionStart additionalContext and sets both Claude/Copilot project-directory
environment variables.

The source suite exercises generated wiring, all runtime combinations, refresh,
record preservation, native hook command serialization with synthetic payloads,
launcher arguments using a stub binary and role restrictions. These checks do
not establish native model discovery, trust, role selection or end-to-end model
behavior. No live Claude/Copilot model evaluation has yet been performed for
this change. Existing [Codex-only observations](codex-distribution-history.md),
[workflow experiments](codex-prototype-experiments.md) and
[role experiments](subagent-experiments.md) retain their original scope.

Primary references:

- [Claude instructions and memory](https://code.claude.com/docs/en/memory)
- [Claude skills](https://code.claude.com/docs/en/skills)
- [Claude subagents](https://code.claude.com/docs/en/sub-agents)
- [Claude hooks](https://code.claude.com/docs/en/hooks)
- [Claude CLI settings option](https://code.claude.com/docs/en/cli-reference)
- [Copilot custom instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)
- [Copilot skills](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills)
- [Copilot custom agents](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [Copilot hooks](https://docs.github.com/en/copilot/reference/hooks-reference)
- [Copilot CLI reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference)

## OMP — 2026-09-10

OMP 18.0.8 adds normal `omp` hub startup, native `.omp/skills`, two namespaced
native observer agents, a plain standalone implementer supplement and a native
lifecycle extension. Shared instructions and project/lane formats are unchanged.
See [OMP setup, parallel work and runtime limits](omp.md) before delegating.
Native isolated task autoapply and disposable-checkout behavior are unsuitable
for Piper's durable source-writing contract; separate assigned OMP sessions
preserve that contract. OMP child tool lists do not establish OS sandboxing.

The complete source suite passed: 9 runtime tests (15 combinations, 24 adapter
enablement orders), 35 record tests and 32 integration tests, plus distribution,
canonical, shell, render-freshness and whitespace checks. The installed extension
was exercised with synthetic events and real Python context generation, covering
resume/branch/tree/compaction, headless fallback, retry and record preservation.

OMP 18.0.8 help/version worked. An offline RPC startup query failed with sandbox
`EPERM` while creating its own `~/.omp/run/daemons` state, before returning native
context. A separate `omp read skill://piper-workflow` query returned no available
skills; that command is not accepted as successful discovery evidence. These
are recorded probe limits, not proof that full native startup works or fails
outside this sandbox. No model prompt was sent, no permissions were relaxed,
and no live OMP model evaluation has been performed.
