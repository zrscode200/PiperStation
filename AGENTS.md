# Repository Operating Instructions

This repository builds Piper Station Unified Bootstrap. It is the upstream
source for rendering Codex, Claude Code, and OpenCode hub surfaces from one
shared Piper behavior core.

## Required Behavior

- Treat this repo as the source distribution, not as a generated hub.
- Put shared behavior and docs in `core/`.
- Put harness mechanics in `adapters/codex/`, `adapters/claude/`, and
  `adapters/opencode/`.
- Run `./scripts/render-templates.sh` after changing `core/` or adapters.
- Do not edit `generated/` directly except to inspect output.
- Preserve the hub ownership model: generated hub files outside `projects/` are
  managed, and `projects/` records are hub-owned.
- Do not reintroduce a heavy runtime, daemon, global queue, or copied project
  source tree.

## Verification

```sh
./tests/run.sh
sh -n bootstrap/init.sh
sh -n bootstrap/add-project.sh
sh -n scripts/render-templates.sh
python3 scripts/render_templates.py --check
git diff --check
```
