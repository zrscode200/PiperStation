#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
if [ -t 0 ]; then
  input=""
else
  input=$(cat 2>/dev/null || true)
fi

PIPER_HUB_ROOT="$ROOT" PIPER_HOOK_INPUT="$input" python3 - <<'PY'
import json
import os
from pathlib import Path

root = Path(os.environ['PIPER_HUB_ROOT'])
try:
    event = json.loads(os.environ.get('PIPER_HOOK_INPUT', '') or '{}')
    source = event.get('source', 'startup') if isinstance(event, dict) else 'startup'
except ValueError:
    source = 'startup'
if source not in ('startup', 'resume', 'compact'):
    source = 'startup'
project_dirs = sorted(p for p in (root / 'projects').glob('*')
                      if p.is_dir() and (p / 'project.md').is_file())
lanes = []
for project in project_dirs:
    work = project / 'work'
    if any((work / name).is_file() for name in ('active-work.md', 'context-pack.md')):
        lanes.append(f'{project.name}: flat -> projects/{project.name}/work/')
    for directory, kind in (('design', 'studio'), ('groups', 'group'), ('lanes', 'lane')):
        for lane in sorted((work / directory).glob('*')):
            if lane.is_dir() and any((lane / name).is_file() for name in
                                     ('design.md', 'active-work.md', 'context-pack.md')):
                lanes.append(f'{project.name}: {kind}:{lane.name} -> '
                             f'projects/{project.name}/work/{directory}/{lane.name}/')
context = '''Piper Station is active. Read AGENTS.md and relevant STATION sections.
Use brainstorm for orientation, explicit design-studio for durable design, and piper-workflow for converged execution. Register only through ./bin/add-project.
Select the clearly requested or already selected lane; ask on actual ambiguity. STATION -> Lanes defines flat, studio:<slug>, group:<gid>, and lane:<slug>. Lane records are available work, not proof of a live native session. Studios keep their own design and resume context without source-edit authority. Concurrent writers require exclusive assigned checkouts; group acceptance is independent of concurrency.
Use protected publication for shared records and ownership state, preserve other lanes' changes, and follow the exact-base integration procedure before publishing source.'''
if source in ('resume', 'compact'):
    context += '''
Resume guidance: read the selected lane's context-pack.md, active-work.md, build-log.md and canonical design when relevant. Verify actual source git state, related contract revisions and unresolved impacts before acting. Check native worker status and actual results; a handle or old status is only a locator and a wait timeout is not terminal. Reconcile interrupted integration/publication without duplicating work. Resume design as design; revalidate stale assumptions before dependent execution.'''
if project_dirs:
    context += '\nRegistered project records: ' + ', '.join(p.name for p in project_dirs[:40])
else:
    context += '\nNo registered project records yet; registration does not start work.'
if lanes:
    context += '\nAvailable lane records (inspect phase/status; not a liveness claim):\n' + '\n'.join(lanes[:40])
    if len(lanes) > 40:
        context += f'\n{len(lanes) - 40} additional lane records omitted; inspect the selected project.'
print(json.dumps({'hookSpecificOutput': {'hookEventName': 'SessionStart',
                                       'additionalContext': context},
                  'systemMessage': f'Piper Station ready (source={source}, projects={len(project_dirs)}).'}))
PY
