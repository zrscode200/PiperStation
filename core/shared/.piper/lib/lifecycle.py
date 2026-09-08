#!/usr/bin/env python3
"""Read-only lifecycle context with explicitly selected native serialization."""
from pathlib import Path
import argparse
import json
import sys

sys.dont_write_bytecode = True
parser = argparse.ArgumentParser()
parser.add_argument('--runtime', choices=('codex', 'claude', 'copilot'), required=True)
parser.add_argument('--event', choices=('session-start', 'pre-compact', 'post-compact'), required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
try:
    event = json.loads(sys.stdin.read() or '{}') if not sys.stdin.isatty() else {}
    source = event.get('source', 'startup') if isinstance(event, dict) else 'startup'
except ValueError:
    source = 'startup'
if source not in ('startup', 'resume', 'compact', 'new', 'clear', 'fork'):
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

if args.event == 'session-start':
    if args.runtime == 'copilot':
        print(json.dumps({'additionalContext': context}))
    else:
        print(json.dumps({'hookSpecificOutput': {'hookEventName': 'SessionStart',
                         'additionalContext': context},
                         'systemMessage': f'Piper Station ready (source={source}, projects={len(project_dirs)}).'}))
elif args.event == 'pre-compact':
    if args.runtime == 'copilot':
        # Copilot documents this event as notification-only; stdout is not a
        # checkpoint, model instruction or blocking mechanism.
        print("Piper Station compact reminder: prepare the selected lane's context-pack.md using STATION -> Lanes and Compaction. Read the old packet and canonical records before a full rewrite; preserve goal, phase/boundary, next exact action, unrecorded verification/review, blockers/risks/questions, stop reason, related-contract impacts and unresolved worker locators. Derive source git and native worker status live at resume. Studios keep packets in their studio folders. Protect shared publication and preserve other lanes' state. This hook reminds; it does not write a snapshot or block compaction.", file=sys.stderr)
    else:
        print(json.dumps({'systemMessage': "Piper Station compact reminder: prepare the selected lane's context-pack.md using STATION -> Lanes and Compaction. Read the old packet and canonical records before a full rewrite; preserve goal, phase/boundary, next exact action, unrecorded verification/review, blockers/risks/questions, stop reason, related-contract impacts and unresolved worker locators. Derive source git and native worker status live at resume. Studios keep packets in their studio folders. Protect shared publication and preserve other lanes' state. This hook reminds; it does not write a snapshot or block compaction."}))
else:
    if args.runtime == 'copilot':
        parser.error('Copilot CLI has no documented postCompact event')
    print(json.dumps({'systemMessage': "Piper Station post-compact: reload AGENTS.md, relevant STATION sections, project binding/memory/decisions and the selected lane's packet, active work, ledger and canonical design when relevant. Verify live git, changed related contracts, incomplete integration/publication and actual native worker status before editing. Stored handles and status are hints, not liveness evidence. Resume the selected phase and preserve ownership; never duplicate work after a wait timeout. SessionStart supplies model-visible resume guidance."}))
