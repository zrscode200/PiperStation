# Conventions

Piper behavior changes start in `core/`. Codex mechanics belong in
`adapters/codex/`; adapters must not duplicate or shadow core skills and
procedures. Generate output through the renderer and keep distribution cleanup
separate from behavioral changes when reviewing evidence.
