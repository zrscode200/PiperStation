---
name: review
description: Use for explicit code review, piper-workflow Review Mode, implementation review, or a Ralph review gate; first check whether the work matches the request/spec/plan, then check whether it is built well.
---

# Review

Use a two-stage review:

1. Did we build the right thing?
2. Did we build it well?

Read the request, active spec or plan, task queue, verification logs, changed
code or diff, and relevant surrounding code before reporting findings.

Do not use this skill for general repo orientation, planning, implementation,
or automation approval. Route orientation, planning, and implementation through
`piper-workflow` and `STATION.md` as appropriate. Route automation approval
directly to the root-session `automation-policy` skill.

Prioritize findings by severity. Anchor findings to concrete files, lines,
behavior, missing verification, or drift from the request/spec/plan.

For implementation review gates, the reviewer is read-only. The main session
must validate each finding before acting: give each finding an explicit verdict
— `confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive` — before
editing any code, then apply only `confirmed-in-scope` fixes, turn
`confirmed-out-of-scope` findings into follow-up notes or tasks, and reverify
review-driven fixes with the narrowest meaningful command for the fixed
behavior.
