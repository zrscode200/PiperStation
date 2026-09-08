# Conventions

Piper behavior changes start in `core/`. Native mechanics belong in
`adapters/<runtime>/`; adapters must not duplicate or shadow core skills and
procedures. Generate output through the renderer. Shared files must be identical
across runtime templates so compatible adapters can compose safely.

Keep model/permission defaults user-owned, distinguish tool restrictions from
sandbox enforcement, and test native discovery overlap. Native hook output must
use the receiving CLI's documented schema. Configuration/fixture checks are not
claims that a live model exercised the workflow.
