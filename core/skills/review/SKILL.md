---
name: review
description: Use only for explicit code review, implementation review, or a Ralph review gate; first check whether the work matches the request/spec/plan, then check whether it is built well.
---

# Review

Use a two-stage review:

1. Did we build the right thing?
2. Did we build it well?

Read the request, active spec or plan, task queue, verification logs, changed
code or diff, and relevant surrounding code before reporting findings.

Do not use this skill for general repo orientation, planning, implementation,
or automation approval. Route those through the dispatch contract in
`STATION.md`.

Prioritize findings by severity. Anchor findings to concrete files, lines,
behavior, missing verification, or drift from the request/spec/plan.

For implementation review gates, the reviewer is read-only. The main session
must verify each finding before acting, apply only valid in-scope fixes, turn
valid out-of-scope findings into follow-up notes or tasks, and reverify
review-driven fixes with the narrowest meaningful command for the fixed
behavior.
