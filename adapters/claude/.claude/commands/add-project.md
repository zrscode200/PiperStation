---
description: Register a git repo as a project with this Piper Station hub. Creates projects/<id>/{project,memory,decisions}.md.
argument-hint: <repo-path> [project-id]
---

You are registering a project repo with this Piper Station hub.

The user invoked `/add-project $ARGUMENTS`.

This slash command supports only the short positional form. Parse `$ARGUMENTS`:
- first token: `<repo-path>` (required, absolute or expandable)
- second token (optional): `<project-id>` — defaults to a slugified basename of the repo path

Preserve quoted paths when parsing. If the arguments are ambiguous, include
flags, or include more than two positional tokens, stop without running the
helper and tell the user to run the deterministic helper directly, for example:

```sh
./bin/add-project --repo <repo-path> --project-id <project-id> --hub-only
```

Do not silently drop `--hub-only`, `--dry-run`, `--display-name`, or any other
helper flag.

If `<repo-path>` is missing, stop with the correct usage.

## Steps

1. If only `<repo-path>` is present, run:

   ```sh
   ./bin/add-project --repo <repo-path>
   ```

2. If `<project-id>` is present, run:

   ```sh
   ./bin/add-project --repo <repo-path> --project-id <project-id>
   ```

3. Report the created or updated hub project folder and the next command:
   `/work-on <project-id> "<request>"`.

## Rules

- Registration is deterministic through `./bin/add-project`; do not manually
  recreate its file-writing behavior in the conversation.
- The only shell command this prompt should run for registration is
  `./bin/add-project` with explicit flags. Do not use ad hoc `mkdir`, `mv`, or
  inline file generation to create project records.
- By default, registration may write minimal repo marker files:
  `.piper/project.json` and `PIPER.md`. Use the direct helper command with
  `--hub-only` when marker files are not wanted.
- Do not start implementation, run verification, commit, push, or install dependencies as a side effect of registration.
- Do not create `projects/<project-id>/work/`; that directory is created lazily
  by `/superpowers` or `/ralph` only when active continuity is needed.
