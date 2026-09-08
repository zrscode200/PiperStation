# Repository Operating Instructions

This repository builds Piper Station for Codex, Claude Code CLI and GitHub Copilot CLI. It is the source distribution
for rendering a central Piper hub; it is not itself a generated hub.

## Required Behavior

- Put Piper behavior, skills, procedures, and hub docs in `core/`.
- Put runtime configuration, native role headers and hook wiring in
  `adapters/<runtime>/`. Shared instructions and role briefs belong in `core/`.
  Adapters must not shadow core skills or procedures.
- Run `./scripts/render-templates.sh` after changing `core/` or adapters.
- Do not edit `generated/` directly except to inspect output.
- Preserve the hub ownership model: generated hub files outside `projects/` are
  managed, and `projects/` records are hub-owned.
- Do not reintroduce a heavy runtime, daemon, global queue, or copied project
  source tree.
- Support `codex`, `claude` and `copilot`, individually and together. Preserve
  project records and source workspaces on refresh. Keep unsupported-runtime
  migration explicit, and test overlapping native discovery paths.

## Verification

```sh
./tests/run.sh
sh -n bootstrap/init.sh
sh -n bootstrap/add-project.sh
sh -n scripts/render-templates.sh
python3 scripts/render_templates.py --check
git diff --check
```
