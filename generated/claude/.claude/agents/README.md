# Claude Agents

This hub installs the same helper role set as the Codex surface, expressed as
native Claude Code subagents:

- `explorer`: brainstorm-phase orientation, investigation, and hand-off brief.
- `planner`: Superpowers-phase planning and Ralph-ready task preparation.
- `ralph`: one accepted implementation slice from a delegation packet.
- `reviewer`: read-only implementation review for Ralph review gates.
- `verifier`: strict read-only helper for existing checks and failure analysis.
- `tester`: test-layer writer for explicit test, fixture, or test-data changes.
- `docs-researcher`: documentation research through official docs and MCP/web
  tools.

These agents cover the recurring Ralph loop roles without turning the hub into
an orchestration runtime. The root session uses the dispatcher skill to decide
when to spawn, then sends a bounded delegation packet. Phase behavior still
lives in `brainstorm`, `piper-workflow`, and `review`; compaction and protected
automation remain root-session work. Claude Code does not use the Codex
`sandbox_mode` field; read-only helper roles are constrained by their tool lists
and by explicit no-edit instructions. The verifier role is the no-edit runtime
checker; the tester role is writable only when the coordinator explicitly
delegates test-layer files.
