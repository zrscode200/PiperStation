# Testing

Run `./tests/run.sh` after changing render, bootstrap, registration, or adapter
behavior. It checks Codex instruction contracts, wiring, bootstrap and refresh,
registration ownership, rejected migrations without mutation, and render
freshness. Python 3, a POSIX shell, and Git are required; it uses disposable
local directories and does not need network access.

The source verification commands are listed in `AGENTS.md`. Static instruction
checks establish what is distributed, not what an agent actually does. Record
fresh-session workflow evidence separately in
`docs/codex-prototype-experiments.md`, `docs/subagent-experiments.md` and their
linked run records. This source repository does not activate the hub workflow:
behavioral evaluations explicitly create disposable hubs and registered source
fixtures. Label those runs as evaluations when reporting their workers and work;
keep original project workspaces unchanged.
