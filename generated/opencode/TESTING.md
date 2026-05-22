# Testing

For hub source changes, run the source repo test suite and render freshness
check. For project work, run the narrowest meaningful verification first and
broaden only when changes touch shared, risky, or cross-cutting behavior.

When active work records are in use, record important evidence in
`projects/<id>/work/verification.md`: commands run, pass/fail result, known
gaps, and re-verification after review-driven fixes.

Do not claim tests or builds ran without fresh output.
