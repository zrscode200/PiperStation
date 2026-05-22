---
name: ralph-loop
description: Use to execute one scoped task at a time from a plan or task queue with verification, drift checks, review gate, and compact-safe updates.
---

# Ralph Loop

Ralph is prompt and skill behavior in {{RUNTIME_NAME}}. It is not a shell runner.

For each slice:

1. Select exactly one task from the active plan or task queue.
2. State the expected diff boundary.
3. Implement only that task in the registered project repo.
4. Run the narrowest meaningful verification.
5. Check drift against the request, spec, and plan.
6. Run the Implementation Review Gate when required by scope and impact.
7. Verify reviewer findings before acting on them.
8. Apply only valid in-scope fixes.
9. Reverify review-driven fixes with the narrowest meaningful command for the fixed behavior.
10. Update active work records when they are in use.

Review gate selection is based on scope and change impact. Risk tier controls approval before execution, not review selection. Review gates are required for `S2/S3` slices and queued foundational work such as bootstrap, install, update, registration, generated commands, hooks, settings, config, test harnesses, project or hub ownership, security policy, or automation policy.

If a required or expected gate is skipped, record review debt and do not continue to dependent tasks until the debt is resolved or explicitly accepted by the user.

## Compaction Discipline

At natural stopping points, update `context-pack.md` and, when pausing, `handoff.md`. Include the next exact action, scope boundary, files to inspect first after compact, verification state, review state, drift result, git state, blockers, risks, and broad-search triggers.

After compact, start from designed anchors and rebuild only enough of the active task neighborhood to work safely.
