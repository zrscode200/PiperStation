# Conventions

Keep project records small. Put active continuity under
`projects/<id>/work/` only when useful. Prefer project repo conventions when
editing source.

Use `project.md` for repo binding, overview, and project policy preferences;
use `memory.md` for durable facts and preferences. Use optional `decisions.md`
only for substantial decision logs future work should not reopen silently.

Routine progress, raw command output, temporary plans, secrets, and sensitive
logs do not belong in durable hub records.

Keep lightweight `work/design/<topic>.md` notes available. A full Design Studio
uses `work/design/<studio-slug>/` only after explicit user choice: the project
README indexes design work, the studio README navigates its files, and
`design.md` alone owns the integrated design, integer revision, and explicit
revision-specific acceptance. Create optional artifacts with descriptive names
only when useful; do not impose topic, aspect, research, probe, or prototype
directories. Promotion from an existing note or ad hoc folder is
discussion-led and non-destructive.

The default unit of work is one ungrouped wave with a light boundary. Groups
bundle related waves under a shared acceptance target and one integrating
review gate and are entered by an explicit planning decision. Each group is
its own lane under `work/groups/<gid>/`, with its own windows, ledger, branch,
and checkout; hub artifact commits are path-scoped to the lane. `STATION.md`
(Project Records, Group Lifecycle) owns the rules.

Use Ralph review gates for substantial waves, high-impact slices, and queued
foundational work. Risk tier controls Ralph implementation caution;
action classes (`external`, `exceptional`) control asks. Review gate
selection comes from scope and change impact.
