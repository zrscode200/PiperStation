# Shared Piper behavior

`core/` is the canonical source for Piper skills, procedures, roles and shared
hub instructions. Update it for behavior that every runtime must receive.
`adapters/codex`, `adapters/claude` and `adapters/copilot` hold native configuration
and wiring. Adapters must not shadow shared skills or procedures.

Render through `scripts/render_templates.py`; never edit `generated/` directly.
