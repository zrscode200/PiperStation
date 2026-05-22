# Add Project

Register a project repo with this Piper Station hub.

Use the deterministic command unless the user only wants an explanation:

```sh
./bin/add-project --repo /path/to/project-repo --project-id project-id
```

Rules:

- Do not manually create ad hoc project records.
- Do not start work as a side effect of registration.
- Do not create `projects/<id>/work/`.
- Do not silently drop existing `memory.md` or `decisions.md` content.
- Use `--hub-only` when repo marker files are not wanted.
