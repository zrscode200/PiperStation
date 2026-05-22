---
description: Enter Ralph Mode for one scoped implementation slice
allowed-tools: [Read, Write, Bash]
---

# Ralph

Enter Ralph Mode for one scoped task.

Ralph is prompt and skill behavior in Codex. It selects one task, states the diff boundary, implements that task, verifies, drift-checks, applies the Implementation Review Gate when required, and updates compact-safe records when active work records are in use.

Review gate selection is based on scope and change impact. Risk tier controls approval before execution, not review selection. Queued foundational work should not proceed to dependent tasks with unresolved review debt.
