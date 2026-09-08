# Piper Station

Piper Station is a central workspace for one developer designing, building,
reviewing and returning to projects with Codex, Claude Code CLI or GitHub
Copilot CLI. Registered source stays in its repository; the hub preserves
project understanding and work records shared by its enabled runtimes.

This repository is the source distribution. It renders shared Piper behavior
and native adapters into `generated/`.

**Runtime validation status — 2026-09-08:** Claude Code and Copilot adapters have
passed local distribution tests and independent implementation review. Live
Claude/Copilot sessions have **not yet been validated** for this change. The
local Copilot CLI check encountered `SecItemCopyMatching -50` in the verification
sandbox; this is an observed environment limitation, not an established failure
on every installation. See [evidence and limits](docs/capability-matrix.md#evidence-and-limits--2026-09-08)
for checked versions and the scope of the evidence.

```sh
# New hub, defaulting to Codex
./bootstrap/init.sh --git-init /path/to/hub

# Any supported runtime or combination
./bootstrap/init.sh --runtime claude --git-init /path/to/claude-hub
./bootstrap/init.sh --runtime copilot --git-init /path/to/copilot-hub
./bootstrap/init.sh --runtime codex,claude,copilot --git-init /path/to/shared-hub

./bootstrap/add-project.sh --hub /path/to/hub --repo /path/to/project --project-id my-project
```

Python 3, a POSIX shell and Git are required. Use `--dry-run` to inspect changes.
`--git-init` creates the hub's own Git root even under an existing repository,
so hub checkpoint commits cannot land in an enclosing project repository.

At the hub, launch `codex`, `./bin/piper-claude`, or `copilot`. The thin Claude
launcher selects the hub and its hook settings, then execs the native CLI with
all supplied arguments. Bare `claude` still loads instructions, skills and roles,
but omits Piper lifecycle hooks. Explicit loading prevents Copilot from also
executing Claude's hooks. See [runtime wiring and differences](docs/capability-matrix.md).

Hooks provide reminders and context; they do not save checkpoints. Explicitly
checkpoint before compaction or switching sessions. Copilot has no documented
post-compaction hook equivalent. Native role tool restrictions also do not
establish an OS sandbox; verify actual tools and workspace access before
assigning source work.

A refresh retains previously enabled supported runtimes. Passing `--runtime`
adds adapters; it never disables another installed runtime. Refresh at an idle
boundary after affected sessions checkpoint. Managed files are updated and stale
managed files retired; project records, source workspaces and unmanaged content
are preserved. Unsupported old runtime surfaces require explicit migration.
Updating this source checkout does not refresh an existing hub: rerun the
installer for that hub at the checkpointed boundary described above.

Read [PRODUCT.md](PRODUCT.md), [ARCHITECTURE.md](ARCHITECTURE.md) and
[TESTING.md](TESTING.md) for scope, ownership and verification. Piper provides
three bounded roles: investigator, implementer and reviewer. Their shared
behavior follows the [subagent design](docs/subagent-design.md); native tool and
permission differences are documented in the runtime matrix.

Historical [Codex workflow evaluations](docs/codex-prototype-experiments.md) and
[three-role evaluations](docs/subagent-experiments.md) remain evidence for their
recorded versions and runtime. They do not establish Claude/Copilot behavior.
