# Piper Station for Codex

Piper Station is a central workspace for one developer designing, building,
reviewing, and returning to projects with Codex. Registered project source stays
in its own repository; the hub preserves project understanding and work records.

This repository is the source distribution. It renders Codex instructions,
skills, agent roles, hooks, and deterministic helpers into `generated/codex`.

```sh
./bootstrap/init.sh --git-init /path/to/hub
./bootstrap/add-project.sh --hub /path/to/hub --repo /path/to/project --project-id my-project
```

Python 3 and a POSIX shell are required. Git is required for project registration
and `--git-init`. Use `--dry-run` to inspect planned changes. Existing callers may
continue to pass `--runtime codex`. `--git-init` creates the hub’s own Git root,
including when the hub is inside an existing repository; checkpoint commits
then remain local to the hub.

Bootstrap refreshes managed hub files outside `projects/` and preserves all
hub-owned project records. This branch supports Codex only. It refuses mixed or
retired-runtime hubs before writing; see [Codex wiring and migration](docs/capability-matrix.md)
for the supported upgrade path. Removing runtime support here never uninstalls
anything from an existing hub.

Read [PRODUCT.md](PRODUCT.md) for scope and [ARCHITECTURE.md](ARCHITECTURE.md) for
source ownership. See [Codex prototype experiments](docs/codex-prototype-experiments.md)
for real-project cases and evidence, [working across Codex tasks](docs/codex-workflows.md)
for practical workflows, and [TESTING.md](TESTING.md) for verification.
