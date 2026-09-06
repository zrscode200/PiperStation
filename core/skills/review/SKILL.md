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
before reporting findings (locations are defined in STATION → Lanes). Use that `active-work.md` to identify the
selected wave, group, explicit slice, or queued task and its acceptance
criteria. For a group review, inspect the integrated cross-wave diff
(`base..group`, in the lane's checkout) and the interactions between waves,
not only the last wave's diff. For coordinated work, inspect shared assumptions,
changed contract revisions and combined verification against the exact candidate
and base. A worker-local pass or clean merge does not establish integration
correctness. Read the lane's `context-pack.md` when resume
state affects the review.

Do not use this skill for general repo orientation, planning, implementation,
or automation approval. Route orientation to `brainstorm`, execution planning and implementation to
`piper-workflow`, and studio design back to `design-studio` as appropriate. Route automation approval
directly to the root-session `automation-policy` skill.

Prioritize findings by severity. Anchor findings to concrete files, lines,
behavior, missing verification, or drift from the request or active work.

For implementation review gates, the reviewer's work is read-only: no source or
record edits, commits, or integration. Select the installed reviewer role when
the native tool supports role selection. Otherwise read its installed brief and
include those instructions in the explicit assignment through supported parameters.
Do not invent `agent_type` or claim the role's sandbox overlay was applied. Verify
actual native worker permissions when observable; otherwise report them as
unverified. Behavioral read-only scope remains binding with broader capabilities.
The main session must validate each finding before acting: give each finding an explicit verdict
— `confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive` — before
editing any code, then apply only `confirmed-in-scope` fixes, turn
`confirmed-out-of-scope` findings into follow-up notes or tasks, and reverify
review-driven fixes with the narrowest meaningful command for the fixed
behavior.
