# Conventions

Keep project records small and source in its registered repository or assigned
worktrees. Hub records live under `projects/<id>/`; create `work/` only when useful.
`project.md` owns binding and standing policy, `memory.md` durable facts, and
optional `decisions.md` significant rationale. Raw output, secrets, transcripts,
and routine step logs do not belong in durable context.

The default is one ungrouped wave with one useful acceptance entry. A named lane
provides independent continuity and checkout ownership; a group provides shared
multi-wave acceptance and integrating review. Concurrency alone does not force a
group. Studio lanes preserve design context in their own folders without source
edit authority. STATION owns canonical locators, artifact semantics, and selection.

Keep lightweight topical notes supported. Explicit Design Studio entry creates
or reuses an initiative: README navigation, canonical `design.md`, and optional
standard lane continuity. Design revision and acceptance remain distinct from
session activity. Promote notes non-destructively and create supporting artifacts
only when each performs a useful job.

Reference accepted contracts, evidence and related work when a real dependency
exists. Keep tentative proposals distinct from aligned decisions. One artifact
owns each shared fact; affected lanes refer to it and reconcile their own state.
Continue unaffected work while changed assumptions are resolved.

Publish shared records, ownership state and path-only hub commits through
`piper-record`; ordinary sole-owned lane edits may use normal file tools.
Keep source and artifact commits separate. Integrate only verified candidates into
clean idle target checkouts through `piper-integrate`; STATION and the integration
procedure own the checks. Helpers protect cooperating operations, not arbitrary
edits or permission boundaries.

Use native tasks for short-lived steps. Authorized writable workers receive
isolated checkouts and bounded assignments; their parent owns hub records and
acceptance. At resume, check actual git and native task state; handles and stored
status are only hints. Apply proportional verification and required review gates.
