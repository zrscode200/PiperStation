# Piper Station And Raygent Layering Note

Status: future architecture note. This records a design direction to revisit;
it does not change the current bootstrap behavior.

## Context

Piper Station currently runs on top of mature native agent runtimes such as
Codex CLI, Claude Code, OpenCode, and potentially Gemini CLI. Those runtimes
already provide lower-level agent harness pieces: model loop, tool use, editing
behavior, native permissions, subagents or tasks where available, and session
mechanics.

Because those runtimes are external products, Piper Station can only express
its product behavior through markdown instructions, skills, commands, hooks,
and runtime config. That is appropriate for compatibility, but it means
routing, review gates, work-record updates, and subagent packets are mostly
prompt-level conventions.

Raygent is different: it is an embeddable headless agent harness kernel. It can
own structured runtime mechanics such as tools, permissions, workers,
coordinator state, memory, transcripts, compaction, task output, worktrees, and
tool discovery.

## Layering Decision

Treat Piper Station as the agent-instance and product layer, not as the
foundational agent runtime.

```text
Model
  GPT / Claude / Gemini / other model providers

Agent runtime
  Codex CLI / Claude Code / OpenCode / Gemini CLI / Raygent

Piper Station product layer
  project registry
  project memory and decisions
  active spec, active plan, task queue, verification, context pack
  scope/risk/review policy
  registration behavior
  Piper role definitions and workflow semantics

Project/domain layer
  registered repositories and project-specific records
```

## Adapter Implication

Piper should keep a runtime-independent core product contract, then adapt that
contract differently per runtime:

- Codex adapter: render product semantics as `AGENTS.md`, skills, hooks,
  `config.toml`, and Codex subagents.
- Claude adapter: render product semantics as `CLAUDE.md`, slash commands,
  skills, hooks, and Claude subagents.
- OpenCode adapter: render product semantics as `AGENTS.md`, `opencode.json`,
  skills, commands, and OpenCode subagents.
- Raygent adapter: express the same product semantics as structured services,
  workflow objects, policies, work-record stores, and `AgentDefinition`s.

For native CLIs, markdown and config are the adapter language. For Raygent,
Piper should avoid simulating orchestration only in markdown; Raygent can carry
the mechanics directly.

## What Should Move Into Raygent-Backed Structure

In a Raygent-backed Piper implementation, these should become structured
runtime behavior where practical:

- project registry and work-record store interfaces;
- scope, risk, review-gate, and automation policies;
- phase/workflow state for exploration, planning, Ralph execution, review, and
  finish;
- Piper worker profiles such as `explorer`, `planner`, `ralph`, `reviewer`,
  `verifier`, `tester`, and `docs-researcher`;
- structured task packets for worker launches;
- review-gate state and per-finding verdict handling;
- compact/resume state tied to Raygent transcript, memory, and compaction
  services.

Markdown should still exist, but mostly for role tone, user-facing summaries,
and adapter compatibility rather than as the only place workflow mechanics
live.

## Current Bootstrap Implication

The current bootstrap repo remains useful as:

- the cross-runtime adapter and generated-distribution layer;
- a behavioral prototype for Piper Station's project semantics;
- the compatibility bridge for runtimes Piper does not control.

It should avoid becoming a fake runtime. Heavy orchestration, global queues,
daemon-like lifecycle management, or prompt-only dispatcher complexity should
not be added merely to compensate for native runtime limits if the long-term
Raygent path can implement those mechanics cleanly.

