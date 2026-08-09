# Adapter Capability Matrix

| Capability | Codex | Claude Code | OpenCode | Deep Agents | Raygent |
| --- | --- | --- | --- | --- | --- |
| Root instructions | `AGENTS.md` | `CLAUDE.md` | `AGENTS.md` | `.deepagents/AGENTS.md` (loaded into agent memory; hub must be a git repository root) | Future |
| Commands | Skill references under `.codex/skills` (Codex does not use `.codex/commands`) | `.claude/commands` | `.opencode/commands` | Skill references under `.deepagents/skills` (no custom slash commands; the runtime's `/skill:<name>` loads a skill) | Future |
| Skills | `.codex/skills` | `.claude/skills` | `.opencode/skills` | `.deepagents/skills` | Future |
| Subagents | `.codex/agents` | `.claude/agents` | `.opencode/agents` | `.deepagents/agents` (instruction-constrained; the runtime has no per-agent tool restriction) | Future |
| Compact hooks | Prompt/session guidance | Pre/Post compact hooks | Auto-compaction config | `SessionStart`/`PreCompact` hooks in `.deepagents/hooks.json` plus automatic runtime compaction | Possible runtime feature |
| Shared project ledger | Supported | Supported | Supported | Supported | Future |

v1 supports Codex, Claude Code, OpenCode, and Deep Agents. Deepagent hubs are
validated as single-runtime hubs and must be their own git repository root
(`--git-init`); composing deepagent with other runtime surfaces is
advisory-warned, not blocked, because Deep Agents sessions also read the hub
root `AGENTS.md` and `.claude/skills`. Raygent is a documented future adapter
target; see `docs/piper-raygent-layering-note.md` for the intended
Piper-as-product-layer / Raygent-as-kernel split.
