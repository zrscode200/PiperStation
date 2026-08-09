# Piper Station Unified Bootstrap

This repo renders Piper Station hub-lite templates for Codex, Claude Code,
OpenCode, or any combination of them. A multi-runtime hub shares one
`projects/` ledger, so feedback learned while using one harness can improve
shared Piper behavior for every harness.

```sh
./bootstrap/init.sh --runtime codex /path/to/hub
./bootstrap/init.sh --runtime claude /path/to/hub
./bootstrap/init.sh --runtime opencode /path/to/hub
./bootstrap/init.sh --runtime deepagent --git-init /path/to/hub
./bootstrap/init.sh --runtime codex,claude /path/to/hub
./bootstrap/init.sh --runtime codex,claude,opencode /path/to/hub
```

Use `--dry-run` to inspect planned writes and `--git-init` to initialize a hub
as a git repo when it is not already inside one.

The `deepagent` runtime targets Deep Agents Code clients (`dcode` and
compatible launchers). Its hub must be its own git repository root — Deep
Agents discovers hub surfaces through git metadata, so bootstrap it with
`--git-init`. Deepagent hubs are validated as single-runtime hubs; combining
them with other runtime surfaces prints an advisory (see
`docs/capability-matrix.md`).
