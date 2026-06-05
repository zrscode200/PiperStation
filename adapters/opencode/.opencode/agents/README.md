# OpenCode Agents

This hub installs the same helper role set as the Codex and Claude Code
surfaces, expressed as native OpenCode subagents:

- `reviewer`: read-only implementation review for Ralph review gates.
- `implementer`: scoped implementation when the user explicitly asks to delegate.
- `tester`: test-layer writer for explicit test, fixture, or test-data changes.
- `verifier`: strict read-only helper for existing checks and failure analysis.
- `architect`: read-only architecture review for broad design and boundary risk.
- `docs-researcher`: documentation research through official docs and MCP/web
  tools.
- `security-reviewer`: read-only security review for auth, permissions, data,
  networking, secrets, and dependency trust.

These agents cover the recurring Ralph loop roles without turning the hub into
an orchestration runtime. Planning, Ralph, review, and compaction remain prompt
and skill behavior in the main OpenCode session. Read-only helper roles are
constrained by their permission sets and explicit no-edit instructions. The
verifier role is the no-edit runtime checker; the tester role is writable only
when the coordinator explicitly delegates test-layer files.
