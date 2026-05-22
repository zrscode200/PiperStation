---
description: Register a git repo with Piper Station hub-lite.
argument-hint: /path/to/repo [project id]
allowed-tools: [Read, Bash]
---

# Add Project

Use this command from a Piper Station hub-lite directory.

The user invoked this command with: $ARGUMENTS

## Instructions

1. Read `AGENTS.md` and `STATION.md`.
2. Parse the repo path and optional project id from `$ARGUMENTS`.
3. If project id is missing, derive it from the repo directory name.
4. Run:

```sh
./bin/add-project --repo <repo-path> --project-id <project-id>
```

5. Report the created or updated hub project folder.

Registration must not start implementation work, create
`projects/<project-id>/work/`, create sessions, checkpoint, commit, or edit
project source files.
