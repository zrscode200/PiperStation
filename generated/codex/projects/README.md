# Projects

Each subdirectory is a registered project ledger. Registration must create only
`project.md` and `memory.md`.

Registration must not create `work/`. Runtime sessions may create
`projects/<id>/work/` only when active continuity is useful, and one lane
folder per group under `projects/<id>/work/groups/<gid>/` only at group Entry.

## Registry Index

`registry.json` is a hub-owned index of registered projects, written by
`./bin/add-project`. Use it to resolve a `project_id` to its `repo_path` and to
list the projects this hub knows about. The per-project `project.md` remains
the canonical rich record; the index is a derived lookup. If it drifts (a
project directory is removed by hand, for example), regenerate it with
`./bin/add-project --rebuild`.
