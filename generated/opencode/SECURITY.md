# Security

Do not store secrets, credentials, private keys, customer data, tokens, or raw
sensitive logs in hub records.

Project repos own source code and repo-local sensitive context. The hub stores
only lightweight coordination records. If a task touches auth, permissions,
secrets, billing, deployments, destructive operations, or external systems,
classify it as higher risk and require explicit approval before execution.
