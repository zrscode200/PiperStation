#!/usr/bin/env sh
set -eu
cat <<'JSON'
{
  "systemMessage": "Piper Station compact reminder: prepare the selected lane's context-pack.md using STATION -> Lanes and Compaction. Read the old packet and canonical records before a full rewrite; preserve goal, phase/boundary, next exact action, unrecorded verification/review, blockers/risks/questions, stop reason, related-contract impacts and unresolved worker locators. Derive source git and native worker status live at resume. Studios keep packets in their studio folders. Protect shared publication and preserve other lanes' state. This hook reminds; it does not write a snapshot or block compaction."
}
JSON
