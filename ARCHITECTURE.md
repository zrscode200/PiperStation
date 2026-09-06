# Architecture

`core/` owns Piper behavior, skills, procedure references, hub docs, and
registration. `adapters/codex/` owns Codex configuration, agent roles, hooks, and
its always-on `AGENTS.md` summary. Adapter files cannot overwrite core output.

`scripts/render_templates.py` renders only `generated/codex/`. The renderer owns
the whole `generated/` tree and removes retired output during regeneration.
Skills and their references come from one source each; the adapter no longer
contains whole-file skill overrides.

`bootstrap/init.sh` installs or refreshes a Codex hub. Managed files outside
`projects/` are refreshed and stale managed files removed. Hub-owned project
records and untracked local files are preserved. Existing mixed-runtime hubs
are refused before changes; see `docs/capability-matrix.md` for migration.

`core/shared/.piper/lib/bootstrap/registration-body.sh` owns registration.
All public entry points use `register.py`, which shares `piper-record`'s
process-owned publication lock across registration reads, reconciliation and
writes. `bootstrap/add-project.sh` supplies an explicit hub; a generated hub's
`bin/add-project` infers its hub. The compatibility shell helper also routes
through the launcher. Help and dry-run create no lock or project state.

Project source remains outside the hub. Worktree creation, development,
verification, review, and agent delegation use Codex and Git facilities.
