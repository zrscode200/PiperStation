# Repository Operating Instructions

This repository builds Piper Station for Codex. It is the source distribution
for rendering a central Piper hub; it is not itself a generated hub.

## Required Behavior

- Put Piper behavior, skills, procedures, and hub docs in `core/`.
- Put Codex configuration, agent roles, hooks, and the always-on root summary in
  `adapters/codex/`. Adapters must not shadow core skills or procedures.
- Run `./scripts/render-templates.sh` after changing `core/` or adapters.
- Do not edit `generated/` directly except to inspect output.
- Preserve the hub ownership model: generated hub files outside `projects/` are
  managed, and `projects/` records are hub-owned.
- Do not reintroduce a heavy runtime, daemon, global queue, or copied project
  source tree.
- This branch supports Codex only. Keep existing-hub migration explicit and
  preserve all project records and source workspaces.

## Verification

```sh
./tests/run.sh
sh -n bootstrap/init.sh
sh -n bootstrap/add-project.sh
sh -n scripts/render-templates.sh
python3 scripts/render_templates.py --check
git diff --check
```
