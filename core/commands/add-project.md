{{FRONTMATTER}}# Add Project

Register a project repo with this Piper Station hub. This is the registration
route the `brainstorm` front door uses when work becomes formal.

The user invoked this command with: `$ARGUMENTS`

Use the deterministic helper unless the user only wants an explanation:

```sh
./bin/add-project --repo /path/to/project-repo --project-id project-id \
  [--description "<one-line summary>"]
```

Parse the request as a repo path plus optional project id, display name, and
one-line description. If the repo path or intended project id is ambiguous,
ask before registering.

Rules:

- Use {{REGISTRATION_ENTRYPOINTS}} or the deterministic helper; do not manually
  recreate ad hoc project records.
- Registration creates or updates `project.md`, `memory.md`, `decisions.md`,
  the `projects/registry.json` index, and optional repo marker files.
- Do not start implementation work, create plans, checkpoint state, commit,
  push, install dependencies, or edit project source as a registration side
  effect.
- Do not create `projects/<id>/work/`.
- Do not silently drop existing `memory.md` or `decisions.md` content.
- Do not edit `projects/registry.json` by hand. If it drifts, regenerate it
  with `./bin/add-project --rebuild`.
- Use `--hub-only` when repo marker files are not wanted.
