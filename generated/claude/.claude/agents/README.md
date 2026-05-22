# Claude Agents

This hub intentionally installs three Claude Code subagents:

- `reviewer`: read-only implementation review for Ralph review gates.
- `implementer`: scoped implementation when the user explicitly asks to delegate.
- `tester`: focused regression and verification support.

These agents cover the recurring Ralph loop roles without turning the hub into
an orchestration runtime. Planning, Ralph, review, and compaction remain prompt
and skill behavior in the main Claude Code session.

Not installed by default:

- architect
- docs researcher
- security reviewer

Use normal Claude-native review for those cases, or add dedicated agents only
after the hub owner decides those roles are worth maintaining as durable local
definitions.
