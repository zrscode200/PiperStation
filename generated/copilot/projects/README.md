# Projects

Each subdirectory is a registered project ledger. Registration must create only
`project.md` and `memory.md`.

Registration must not create `work/`. Create working records only when they
serve an actual boundary or continuity need. Ordinary execution uses the flat
`work/` lane. Explicit studios keep independent design continuity under
`work/design/<slug>/`; group Entry uses `work/groups/<gid>/`. Independent
execution can use `work/lanes/<slug>/` without requiring a group.

STATION owns lane selection, checkout ownership, related-work publication and
resume. Native session handles are optional evidence, not proof of liveness.
Shared record and ownership updates use `bin/piper-record`; registration and
registry rebuild remain owned by `bin/add-project`.

## Registry Index

`registry.json` is a hub-owned index of registered projects, written by
`./bin/add-project`. Use it to resolve a `project_id` to its `repo_path` and to
list the projects this hub knows about. The per-project `project.md` remains
the canonical rich record; the index is a derived lookup. If it drifts (a
project directory is removed by hand, for example), regenerate it with
`./bin/add-project --rebuild`.
