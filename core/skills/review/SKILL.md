---
name: review
description: Use for code review or implementation review; first check whether the work matches the request/spec/plan, then check whether it is built well.
---

# Review

Use a two-stage review:

1. Did we build the right thing?
2. Did we build it well?

Read the request, active spec or plan, task queue, verification logs, changed
code or diff, and relevant surrounding code before reporting findings.

Prioritize findings by severity. Anchor findings to concrete files, lines,
behavior, missing verification, or drift from the request/spec/plan.

For implementation review gates, the reviewer is read-only. The main session
must verify each finding before acting, apply only valid in-scope fixes, turn
valid out-of-scope findings into follow-up notes or tasks, and reverify
review-driven fixes with the narrowest meaningful command for the fixed
behavior.
