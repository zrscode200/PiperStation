# Security

Do not store secrets, credentials, private keys, customer data, tokens, or raw
sensitive logs in hub records.

Project repos own source code and repo-local sensitive context. The hub stores
only lightweight coordination records. If a task touches auth, permissions,
secrets, billing, deployments, destructive operations, or external systems,
classify implementation as higher risk. Route external or destructive actions
through the permission profile gate before execution; exceptional actions
require explicit one-off approval through `automation-policy`.
