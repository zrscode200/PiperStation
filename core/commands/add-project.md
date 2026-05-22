{{FRONTMATTER}}# Add Project

Register a project repo with this Piper Station hub.

The user invoked this command with: `$ARGUMENTS`

Use the deterministic helper unless the user only wants an explanation:

```sh
./bin/add-project --repo /path/to/project-repo --project-id project-id
```

Parse the request as a repo path plus optional project id and display name. If
the repo path or intended project id is ambiguous, ask before registering.

Rules:

- Use {{REGISTRATION_ENTRYPOINTS}} or the deterministic helper; do not manually
  recreate ad hoc project records.
- Registration only creates or updates `project.md`, `memory.md`,
  `decisions.md`, and optional repo marker files.
- Do not start implementation work, create plans, checkpoint state, commit,
  push, install dependencies, or edit project source as a registration side
  effect.
- Do not create `projects/<id>/work/`.
- Do not silently drop existing `memory.md` or `decisions.md` content.
- Use `--hub-only` when repo marker files are not wanted.
