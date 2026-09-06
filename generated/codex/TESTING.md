# Testing

For hub source changes, run the source repo test suite and render freshness
check. For project work, run the narrowest meaningful verification first and
broaden only when changes touch shared, risky, or cross-cutting behavior.

When active work records are in use, record important evidence in the lane's
`build-log.md` (`projects/<id>/work/build-log.md` for the flat lane,
`projects/<id>/work/groups/<gid>/build-log.md` for a group lane): commands run,
pass/fail result, known gaps, and re-verification after review-driven fixes.

For Design Studio instruction changes, protect the contract in the generated
Codex surfaces. Cover at least: lightweight brainstorm without a studio,
suggested studio with explicit opt-in, direct studio invocation, emergent
descriptively named artifacts, multi-session resume through existing Piper
owners, conclusion without execution, exact accepted-revision handoff, and a
post-handoff revision that must be explicitly accepted and reverified. These
are static instruction-contract checks plus review, not claims of end-to-end
model behavior.

Do not claim tests or builds ran without fresh output.
