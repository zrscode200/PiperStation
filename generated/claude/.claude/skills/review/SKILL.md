---
name: review
description: Use for explicit code review, piper-workflow Review Mode, implementation review, or a Ralph review gate for an implemented wave, group, explicit slice, or queued task; first check whether the work matches the request or active work, then check whether it is built well.
---

# Review

Use a two-stage review:

1. Did we build the right thing?
2. Did we build it well?

Read the request, the selected lane's `active-work.md`, `build-log.md`,
optional `task-queue.md`, changed code or diff, and relevant surrounding code
before reporting findings (the flat lane's files live under `work/`, a group
lane's under `work/groups/<gid>/`). Use that `active-work.md` to identify the
selected wave, group, explicit slice, or queued task and its acceptance
criteria. For a group review, inspect the integrated cross-wave diff
(`base..group`, in the lane's checkout) and the interactions between waves,
not only the last wave's diff. Read the lane's `context-pack.md` when resume
state affects the review.

Do not use this skill for general repo orientation, planning, implementation,
or automation approval. Route orientation, planning, and implementation through
`piper-workflow` and `STATION.md` as appropriate. Route automation approval
directly to the root-session `automation-policy` skill.

Prioritize findings by severity. Anchor findings to concrete files, lines,
behavior, missing verification, or drift from the request or active work.

For implementation review gates, the reviewer is read-only. The main session
must validate each finding before acting: give each finding an explicit verdict
— `confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive` — before
editing any code, then apply only `confirmed-in-scope` fixes, turn
`confirmed-out-of-scope` findings into follow-up notes or tasks, and reverify
review-driven fixes with the narrowest meaningful command for the fixed
behavior.
