# Conventions

Keep project records small. Put active continuity under
`projects/<id>/work/` only when useful. Prefer project repo conventions when
editing source.

Use `project.md` for repo binding, overview, and project policy preferences;
use `memory.md` for durable facts and preferences. Use optional `decisions.md`
only for substantial decision logs future work should not reopen silently.

Routine progress, raw command output, temporary plans, secrets, and sensitive
logs do not belong in durable hub records.

Groups bundle related waves under a shared acceptance target and one
integrating review gate. Use a group when multiple waves land before the larger
boundary is accepted, or when cross-wave interaction risk matters. A group has
its own boundary in `active-work.md`, its own checkpoint in `build-log.md`, and
its own review gate over the integrated cross-wave diff before acceptance.

Use Ralph review gates for substantial waves, high-impact slices, and queued
foundational work. Risk tier controls Ralph implementation caution; permission
profiles control action boundaries. Review gate selection comes from scope and
change impact.
