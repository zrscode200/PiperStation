# Architecture

`core/` owns Piper behavior, skill/procedure bodies, role briefs, shared hub docs
and deterministic registration/record/integration helpers. `adapters/<runtime>/`
owns native configuration, role headers and hook entry points for Codex, Claude
Code CLI and Copilot CLI. Adapter files cannot overwrite core output.

`scripts/render_templates.py` renders `generated/codex`, `generated/claude` and
`generated/copilot`. It owns the complete generated tree. Claude and Copilot use
identical `.claude/skills` output, a supported discovery path in both clients,
so a combined installation has one copy. Their review skill is named
`piper-review` to avoid a built-in command collision. Codex retains its native
skill paths and names. Native role wrappers embed the same `core/roles` briefs.

`bootstrap/init.sh` is the POSIX entry point for `bootstrap/install.py`. The
installer selects the union of requested and previously installed supported
runtimes, checks that overlapping templates are byte/mode identical, and
preflights all destinations before writing. New installs default to Codex;
refreshing an existing hub without flags keeps its enabled runtime set.
Managed files are refreshed and stale managed files retired. Project records,
unmanaged content and operational Git/lock files remain protected. Unsupported
runtime mixes and unmanaged configuration collisions require explicit migration.

Shared lifecycle context lives in `core/shared/.piper/lib/lifecycle.py`; native
adapters select the serializer and events. Claude hook settings are loaded only
through `bin/piper-claude` and the native `--settings` option, avoiding Copilot's
cross-discovery of `.claude/settings.json`. Copilot uses `.github/hooks/piper.json`.
The launcher only selects the hub directory/settings and execs Claude; it does
not manage a session, permissions, authentication or a workflow engine.

Registration entry points use `register.py` and the shared `piper-record` lock
around registration reads, reconciliation and writes. `piper-integrate` guards
exact verified local publication. Runtime adapters do not fork these helpers or
the project-record schema. Native agent and Git facilities perform source work.
