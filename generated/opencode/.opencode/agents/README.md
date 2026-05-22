# OpenCode Agents

This hub installs the same helper role set as the Codex and Claude Code
surfaces, expressed as native OpenCode subagents:

- `reviewer`: read-only implementation review for Ralph review gates.
- `implementer`: scoped implementation when the user explicitly asks to delegate.
- `tester`: focused regression and verification support.
- `architect`: read-only architecture review for broad design and boundary risk.
- `docs-researcher`: documentation research through official docs and MCP/web
  tools.
- `security-reviewer`: read-only security review for auth, permissions, data,
  networking, secrets, and dependency trust.

These agents cover the recurring Ralph loop roles without turning the hub into
an orchestration runtime. Planning, Ralph, review, and compaction remain prompt
and skill behavior in the main OpenCode session. Read-only helper roles are
constrained by their permission sets and explicit no-edit instructions.
