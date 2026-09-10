# Testing

Run `./tests/run.sh` after changes to behavior, rendering, bootstrap, registration
or adapters. It covers shared instruction contracts and helper behavior plus
fresh installs of all fifteen supported runtime combinations, incremental adapter
enablement, refresh and legacy supported-role migration, collision rejection,
record preservation, native hook payload/output fixtures, launcher argument
handling, OMP extension lifecycle behavior and observer tool restrictions. It uses disposable local directories,
requires Python 3, Node.js 18+ (extension tests), a POSIX shell and Git, and needs
no network or model access. OMP itself is not required for the deterministic suite.

Run the remaining source checks from `AGENTS.md`: shell syntax, render freshness
and `git diff --check`. Static/generated checks establish what is distributed;
executing hook commands against synthetic input tests serialization, not native
CLI discovery or model judgment. The launcher test uses a stub native binary.

Native evaluations use disposable hubs and source fixtures, clearly labeled as
evaluations. Preserve user projects and host configuration, obtain any required
external authority, and report runtime versions, actual loaded instructions,
skills/roles, permissions, hook behavior, commands/results and unavailable checks.
Do not relax permissions to run a probe or reuse earlier Codex results as evidence
for another runtime. The shared source instructions are in `AGENTS.md` and the
runtime contracts/known limitations in `docs/capability-matrix.md`.
