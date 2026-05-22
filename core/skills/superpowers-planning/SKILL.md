---
name: superpowers-planning
description: Use before substantial implementation when discovery, a written spec, a plan, or task decomposition is needed.
---

# Superpowers Planning

Use Superpowers Mode when the request is larger than a direct `S0` task, has ambiguous acceptance criteria, touches shared behavior, or needs a task queue.

Produce the minimum useful artifacts under `projects/<id>/work/`:

- `active-spec.md` for desired behavior and acceptance criteria.
- `active-plan.md` for implementation shape.
- `task-queue.md` for scoped Ralph slices.
- `context-pack.md` for compact-safe continuity.

Artifact examples:

- Small direct fix: no artifact or a short active plan.
- Normal feature: active plan and focused verification notes.
- Cross-cutting change: written spec, task queue, context pack, and review gate.
