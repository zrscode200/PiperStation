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

Use the dispatcher contract when review work is substantial. Tiny factual
review can stay inline in the root session; repo, branch, PR, diff, file-set,
or implemented-slice review should usually receive a bounded `reviewer`
delegation packet with a `Review type:` field.

## Review Types

`General Repo/Diff Review` applies when the user asks to review a repo, branch,
PR, diff, selected files, or broad codebase surface. Inspect the requested scope
and surrounding code before reporting. Lead with findings, then report the
scope inspected, assumptions, test gaps, residual risk, and recommended next
action.

`Ralph Review Gate` applies after one implemented slice has been initially
verified. Compare the actual code or diff against the accepted task, spec, plan,
task queue, and verification logs. Report correctness findings, drift, missing
tests, verdict, required fixes, and any review debt.

Do not use this skill for general repo orientation, planning, implementation,
or automation approval. Route orientation, planning, and implementation through
the `dispatcher` skill, `piper-workflow`, and the dispatch contract in
`STATION.md` as appropriate. Route automation approval directly to the root-session `automation-policy` skill.

Prioritize findings by severity. Anchor findings to concrete files, lines,
behavior, missing verification, or drift from the request/spec/plan.

For implementation review gates, the reviewer is read-only. The dispatcher or
main session must verify each finding before acting, apply only valid in-scope
fixes, turn valid out-of-scope findings into follow-up notes or tasks, and
reverify review-driven fixes with the narrowest meaningful command for the
fixed behavior.
