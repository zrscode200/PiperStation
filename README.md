# Piper Station Unified Bootstrap

This repo renders Piper Station hub-lite templates for Codex, Claude Code, or
both. A multi-runtime hub shares one `projects/` ledger, so feedback learned
while using one harness can improve shared Piper behavior for every harness.

```sh
./bootstrap/init.sh --runtime codex /path/to/hub
./bootstrap/init.sh --runtime claude /path/to/hub
./bootstrap/init.sh --runtime codex,claude /path/to/hub
```

Use `--dry-run` to inspect planned writes and `--git-init` to initialize a hub
as a git repo when it is not already inside one.
