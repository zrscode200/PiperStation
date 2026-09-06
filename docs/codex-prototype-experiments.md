# Codex upgrade: workflow experiments

Status: upgrade implementation committed in `97e40c9` and `242503f`; native
small-work controls, independent design, design resumption, coordinated
implementation, fixture integration and fresh execution closeout are complete. Piper
baseline: `052b7a09a47d17ddb082bf13ab8b73db6feeec7b` on
`work/piper-station-improvement`.

## Purpose and scope

Improve Piper as a station for one developer exploring, designing, implementing,
and returning to projects over time. Multiple sessions and delegated workers
are available arrangements; they should earn their coordination cost.

Codex is the target runtime for this prototype. Prompt structure, skill routing,
agent roles, workspace arrangements, and deterministic helpers may change.
Other runtime support is removed in the distribution cleanup. Preserve hub-owned
project records, project-owned source, deliberate design and execution
boundaries, review, and lightweight ordinary work. Do not add a daemon or global
queue.

The generic web-app discussion supplied examples, not product requirements.
These real cases are evaluation inputs, not new feature requests for their
source projects. Use disposable source checkouts and a separate test hub;
preserve the source projects' live workspaces. Keep project source outside the
hub. Record fixture locations and any environment limitations for each run.

## Case 1: a small maintenance change

Source: `langchain_based_agent` (`lc_factory`).

- Local repository:
  `/Users/ziruisu/Rui_Space/WorkSpace_Playground/personal_projects/langchain_based_agent`
- Starting revision: `760063769f593e56f73a46f1a17dbdcb77e3a629`.
- Historical reference: `7a7e626df77f4e8e902b01e3f2ed4e55c5aaa160`,
  **Fix multiline startup error summaries**.
- The original change touched the server graph, its tests, and upgrade notes.

User request for the replay:

> Middleware startup exceptions can contain multiple lines. The parent process
> only extracts one marked line, so its error summary loses information. Fix
> the summary while preserving the full human-readable stderr message.

Run this through one Codex session first. Observe whether Piper identifies the
producer/consumer contract, chooses a bounded implementation, verifies the
behavior, and records an economical completion checkpoint. A group, durable
queue, or delegation should have a concrete reason if introduced.

Acceptance concerns the behavior, not reproducing the historical patch:
multiline errors survive the parent extraction path, full human output remains
available, focused verification passes, and unrelated behavior stays intact.

## Case 2: recovery work and integration findings

Source: Project Mason.

- Local repository:
  `/Users/ziruisu/Rui_Space/WorkSpace_Playground/personal_projects/project-mason`
- Starting revision: `b90507e70693c78ecf1a6607f09af1e499611774`.
- Historical implementation: `e30ff51ffdd81bdde77d3c9eb7d9f8001fab9a72`,
  **fix: make recovery composition resumable**.
- Subsequent integrated review: `895e669e860bba8caf52b6f62b90fe000bf7c996`,
  **fix: close integrated recovery review**.

The recorded work made generated-state restore operations resumable after
interruption or process death, and preserved pending cancellation/signal
outcomes when subprocess cleanup also failed. Later review changed both
execution exception handling and recovery-state inspection.

Use two bounded concerns: restore/recovery state and subprocess cleanup/outcome
handling. First inspect their dependencies and determine which work can safely
proceed independently. Choosing to sequence tightly coupled work is a valid
result.

Exercise two arrangements at different stages: independently steered design
sessions, then a coordinating implementation session with explicitly delegated
workers. This is not a like-for-like comparison of implementation arrangements.
Introduce counterexamples drawn from the later integrated review during design
resumption. Observe whether Piper identifies affected assumptions and work,
assigns responsibility for resolution, and verifies the combined result before
completion. Record evaluator steering separately from autonomous discoveries.

Include a pause/resume boundary after a material finding. A fresh session must
recover what remains valid, what needs repair, and the next action from the hub
records and live source. Do not assume an earlier worker is still running.

Use local tests and fixtures, including integration into the disposable fixture's
main branch. Databricks setup, live workspaces, deployment, pushes and pull
requests are outside this experiment.

## Method and observations

Run the existing rendered Codex behavior before changing Piper's prompts or
wiring. Existing shell/template checks have passed at the baseline; they are
not evidence that these agent workflows work.

Keep the historical solution and post-change documentation as evaluator
references. The acting session receives the pre-change checkout, user request,
and appropriate project guidance. Accept equivalent correct solutions; record
any exposure to the reference solution. These are qualitative workflow
experiments, not claims about general model performance.

For each run, record:

- Runtime/model configuration, Piper revision, starting source revision, and
  available dependencies. Missing environment prerequisites are a preparation
  limitation, not an agent success or failure.
- User interventions: repeated intent, relayed information, coordination
  decisions, and repairs to misunderstood or overwritten context.
- Work boundaries and ownership: what was changed, why scope expanded, and
  whether dependent work continued with stale assumptions.
- Artifact cost: records created or updated and the useful job each performed.
- Actual verification and integration results, including unresolved findings.
- Fresh-session resumption: recovered goal, relevant decisions, outstanding
  work, and next action.

Use native session/task facilities where suitable. Short-lived worker progress
belongs to its parent; independently resumable work needs durable continuity.
Never declare a combined result accepted solely because workers report success
or branches merge cleanly.

## First implementation boundary

1. Prepare and run Case 1 with the existing Codex template. Record the observed
   behavior before making workflow changes.
2. Prepare Case 2 and identify the shared contracts, edit ownership, and
   integration responsibilities needed for the comparison.
3. Implement the smallest Piper changes justified by those observations.
   Candidate changes are related-work references, independent design
   continuity, coordinated delegation, worker isolation, and protected shared
   record updates. This list is provisional.
4. Rerun affected cases and the small-work control. Retain changes that improve
   the observed workflow without imposing unnecessary structure on Case 1.

Validate every core/adapter change through rendering and the repository checks.
Keep Codex-only distribution cleanup distinguishable from behavioral changes.
Do not expand into a generic application, a general evaluation platform, or
repairs to every sampled project.

Broader design exploration, investigation without implementation, and
long-horizon initiative continuity remain part of Piper's product scope.
Passing these first two cases will not establish that those experiences are
covered; choose further real cases as the prototype matures.

## Observations from this upgrade

All fixtures are under `/private/tmp/piper-codex-upgrade-v6mzvg5d`. Source inputs
are archives of the stated historical revisions, initialized as separate Git
repositories. They share no worktree/index metadata with the original projects
and contain no later solution history. The baseline Piper distribution was
archived before modifying its behavior. Scratch paths are local experiment
evidence, not a portable deliverable or a required runtime directory.

### Small-work baseline, September 6, 2026

The fresh actor ran Codex CLI `0.153.4` against `case1-baseline/hub`, with the
source outside that hub in `case1-baseline/source`. The baseline project config
declares `gpt-5.5` and medium reasoning, but the actual host turn metadata reports
`gpt-6-astra`, as it also does for the upgraded control. Configuration declarations
alone do not prove runtime selection. Invocation used `--ignore-user-config`,
invocation-scoped fixture trust, `--approve-for-me`, and workspace-write access
to the hub and source through `--add-dir`; it did not bypass the sandbox or hook
trust. The actor was given the symptom and completion request, not the historical
solution. Its task ID is `01a074e9-d42e-7792-bfd0-a87a66aed5d0`.

Preparation installed the existing frozen dependency set into this disposable
fixture's `.venv` (including deepagents-code 0.1.48 and deepagents 0.7.0b2).
The parent verified 26 pre-change server-graph tests. An initial sandboxed
`uv sync` hit a macOS system-configuration panic; the approved preparation retry
succeeded. That is an environment observation, not agent performance evidence.

The actor changed `server_graph.py` and its tests, preserved full stderr output,
and checked multiline/empty summary behavior. Its focused run passed 29 tests;
source commit `6e2da06fbc3bc14db6403c476a6366158a943195` contains 31 added lines
and one removed line. It created only `work/build-log.md`, committed in the hub
as `d153fcb`, with no group, queue, resume packet, or delegation. Both fixture
checkouts finished clean. The actor needed an approved retry for hub Git staging;
no product-decision intervention was required. Full-suite and live-server checks
were not run. Raw events, prompt, final response and stderr are in `runs/case1-*`.

This is a successful lightweight baseline, not evidence that the new coordination
behavior works. It sets a regression expectation for the upgraded small-work run.

### Implementation findings so far

- Six full-file Codex adapter overrides shadowed shared behavior. Distribution
  cleanup first moved the effective files into core without changing any of the
  36 baseline rendered Codex files; its isolated cleanup-only suite passed.
- Source worktree separation does not protect hub records. `piper-record` adds
  version-checked single-file publication and explicit-path commits that preserve
  unrelated staging. Registration now participates in the same lock so that
  re-registration cannot silently replace newly published notes.
- Integration needs both exact source evidence and an idle target. The new
  helper validates the registered Git repository, lane occupancy, clean candidate
  and base, and unchanged full object IDs before publishing the verified result.
  Publication and lane-binding updates share the hub record lock.
- Independent review reproduced commits that landed before inspection failed,
  configured hooks changing scope or unrelated files, byte-decoding errors after
  publication, and symlink ancestors in unrelated-file inspection. Fixes report
  actual publication/attention state and avoid following those symlinks. Git
  hooks remain enabled; the helpers cannot promise that arbitrary hooks are inert.
- A macOS concurrent first-lock-creation race reproduced outside Piper. Separating
  exclusive creation from reopening the stable lock inode resolved that probe.
- Final review reproduced a case-insensitive execution-record path that bypassed
  ownership checking. Reserved layout spellings now require their canonical form;
  filesystem identity also distinguishes an update to one's own lane from a
  competing checkout claim. The reviewer verified the exact reproducer was fixed.

These are code/test findings, not substitutes for native workflow evidence.

### Repository verification

After the final source fix, all required repository checks passed:
`./tests/run.sh`, shell syntax checks for both bootstrap entry points and the
renderer, `python3 scripts/render_templates.py --check`, and `git diff --check`.
The suite includes 29 record-helper tests and 32 integration-helper tests,
alongside distribution, contract, lifecycle, package and registration checks.
Tests use real temporary Git repositories/worktrees for stale publication,
ownership conflicts, preserved staging, hook side effects, interrupted lock
ownership, and filesystem aliases. Confirmed Piper review findings are resolved.

### Independent Mason design sessions

Project Mason's isolated starting fixture passed its 95 execution and setup
tests. Two new Codex sessions then ran concurrently in `case2-upgrade/hub`,
against the unchanged source outside it. Both used CLI 0.153.4, strict config
validation, invocation-scoped hub trust, ignored user config and automatic
approval review. The captured template still pinned gpt-5.5/medium; actual turn
metadata reports gpt-6-astra for both sessions. The later inheritance correction
was not silently applied to those running sessions.

| Studio | Native task | Observed outcome |
| --- | --- | --- |
| recovery-continuity | `01a074f9-a343-7773-a3e9-4afbbb0a60e1` | 11 selected baseline tests and four controlled interruption observations; provisional revision 1 with independent pause packet, evidence, and ledger; six records committed as `5107725`. |
| process-outcomes | `01a074f9-efea-7473-b09a-48e9217d97b4` | 34 selected baseline tests; provisional revision 1, independent pause packet and ledger; checkpoints `1b4220d` and `b7e5ecd`. |

Both source and hub checkouts finished clean. Source stayed at fixture commit
`acaeca4713d045fe7e8b8c06f0267ccfe0f84150`; neither studio accepted its design,
created an execution group, delegated, or performed external project actions.
Both started before either had durable work records. During checkpoint the
process-outcomes session discovered the other studio's active boundary, created
shared navigation, and recorded `needs-revalidation` for their recovery seam.
It correctly declined to invent the other studio's canonical revision while
that design was not yet published. No user relayed the discovery.

The useful shared question is whether an unconfirmed child-process cleanup
permits safe restoration; preserving cancellation and restoring filesystem state
are separate facts. The proposals also explored broader public diagnostic/schema
changes. Those ideas are unaccepted exploration, not added requirements for the
bounded implementation replay.

The next fresh session explicitly resumed recovery-continuity, read the other
proposal, narrowed the experiment to existing public behavior, and received two
evaluator counterexamples: retained failed-attempt staging after prior trees
are placed, and invocation while the caller handles an unrelated exception.
It requested a fresh read-only reviewer and another pause checkpoint. Its launch
used the refreshed configuration with inherited model/effort choices and the
modern `default_permissions = ":workspace"` profile; it does not reuse either
design conversation. Task `01a07501-fec1-7902-a196-e4956b5cc88a` completed with
provisional revision 2, independently checked four review findings, and committed
seven related hub records as `c3f8ac1`. Source stayed unchanged. A before/after
hash comparison confirmed every process-outcomes studio file remained identical.
Shared navigation points to the new canonical recommendation so its future owner
can reconcile that studio's consumers.

The host exposed `collaboration.spawn_agent` without a selectable `agent_type`.
The read-only reviewer assignment succeeded, but that does not establish that
`reviewer.toml` narrowed its sandbox. The adapter now distinguishes role briefs
and behavioral requirements from actual native role selection and permissions.
No native worker handle from an earlier conversation was presumed live.

### Upgraded small-work control

Task `01a07510-20e8-7322-8469-f21b19df5e3c` used the exact baseline prompt and
the same historical source tree, with its own frozen-dependency environment.
The modern workspace profile, on-request/automatic approval review and an added
source directory were explicit invocation choices. Actual baseline and upgraded
turn metadata both report `gpt-6-astra`.

The actor reproduced the regression before fixing it. Source commit `3f2cd7e`
changes only `server_graph.py` and its focused tests. Hub commit `d27cd66` changes
only `work/build-log.md`: one work artifact, as in the baseline; no group, named
lane, queue, packet or delegation. It used `piper-record` for guarded publication
and the explicit-path commit, retried a denied hub Git write through approved
scope, and left all managed template files unchanged. Both checkouts finished
clean. The actor's 28 tests passed; a separate rerun also passed all 28 tests.

Evidence is in `runs/case1-upgrade-*`, including exact invocation, template
fingerprints, runtime metadata, result, source diff and independent verification.
This single control supports preserved lightweight completion and functioning
guarded publication. It is not a general productivity comparison; the actors
chose different but valid test cases (baseline 29, upgraded 28).

### Coordinated implementation and combined review

The evaluator explicitly narrowed and authorized a bounded implementation replay
from the reconciled design, preserving the existing public envelope and native
signal behavior. It permits private restore evidence and local outcome handling,
while deferring power-loss guarantees, final breadcrumb deletion, persistent
process-liveness machinery and broader diagnostic schemas. That steering is an
experiment decision, not acceptance or deployment in the real Mason project.

Fresh task `01a0750d-f662-7d92-829b-66cc8c202e14` used the inherited Astra model
and explicit fixture workspace permissions. It published accepted-for-planning
design revision 3, then created one execution group, `recovery-replay`, with a
candidate checkout and two isolated worker checkouts outside the hub. Restore
and runner workers had separate file ownership and fixed shared contracts. The
coordinator owned the combined regression, source assembly, hub records and
acceptance. Workers changed only their assigned files; no durable lane was
created for each worker.

Review and coordinator inspection found four defects despite intermediate test
passes: selector cleanup masking a runner failure; creating a skills parent
before refusing invalid restore evidence; hiding a late native signal behind an
ordinary error; and refusing a complete, provable temporary restore record after
process death. Each finding was independently checked, assigned back to the
relevant worker, repaired and reverified. The signal finding explicitly corrected
an earlier downstream assumption while retaining the accepted native-signal
contract. Passing separate worker tests did not count as combined acceptance.

Final candidate `c0b8910a768cbfd5b500863908abc0de7ef9b7da` passed all **287 tests**;
the independent final reviewer passed 170 relevant tests and cleared all four
findings. Coverage includes actual abrupt process exits during Mason restore and
private recovery-record publication, conservative refusal of changed or incomplete
evidence, composed runner/rollback behavior, and isolated SIGTERM/SIGHUP outcomes. These finite
probes support the bounded contracts, not an every-byte or power-loss guarantee.
Known-unconfirmed external-writer safety and broader transaction-wrapper interrupt
masking remain outside this candidate's acceptance. The reviewer performed
read-only work while inheriting workspace-write capabilities; native sandbox
narrowing remained unverified.

The coordinator stopped before integration with main still at `acaeca4`, all
checkouts clean, and both implementation workers plus the reviewer observed
completed. Hub checkpoint `5927293` contains three group records: ownership,
an evidence ledger, and a pause packet. Exact tested revisions and the next
guarded integration command have one ledger owner. Managed template files and
the unrelated process-outcomes studio were unchanged. The evaluator separately
checked worker file scope and those preserved hashes. Raw events, prompt, final
response and the checked result are in `runs/case2-implementation*`.

### Publication/checkpoint gap and fresh resumption

After the coordinator and workers finished, the evaluator refreshed only managed
Piper files to `242503f` and verified all project records remained identical.
The evaluator then used `piper-integrate` to publish the exact reviewed candidate
from `acaeca4` to fixture main. It returned `published`, with target and candidate
both at `c0b8910`; source and hub stayed clean. Project records remained unchanged,
so the committed pause packet still said integration was next.

This deliberately simulates publication succeeding before its completion record
is saved. It does not claim that a process was killed during Git publication;
the helper suite separately exercises interrupted commands and inherited locks.
The publication result is retained outside the hub in
`runs/case2-publication-gap.json`, and was not supplied to the new actor.

Fresh task `01a07535-3f75-7b72-99e2-6afd231bbf33` received the resumption and
closeout request without prior conversation or a hint that main was already
published. It independently recognized main at the reviewed candidate and checked
the fast-forward reflog. It treated the old packet as stale, ran all **287 tests**
on main, and completed the accepted boundary without another integration or worker
restart. Historical native handles were unavailable; it inspected retained clean
results and did not infer that old workers were still running.

Hub closeout `38d96eaf2cdc81b9dc95c8489b1fa5e49205edde` updated only the three
group records and a project completion entry. The group is closed, its execution
binding removed, and historical assignments retained in the ledger. The evaluator
verified all four source checkouts and the hub were clean, main and candidate
remained at `c0b8910`, all other project records (including both studios) and all
managed files were unchanged, and main's reflog contained just the original
snapshot and the single evaluator fast-forward. Invocation, raw events, runtime
metadata, checked result and final response are in `runs/case2-integration-resume*`.

## Evidence limits and deliberately deferred work

The runs demonstrate lightweight completion, independent design continuity,
related-work reconciliation, delegated implementation with shared acceptance,
review-driven repair, guarded local integration and fresh-session closeout after
a publication/checkpoint gap. Helper tests additionally exercise competing
ownership claims, stale record/base evidence and interrupted publication locks.
The experiments required explicit evaluator setup, bounded acceptance and the
documented counterexamples; they are not a general productivity benchmark.

Further evaluation is deferred for independently steered concurrent implementation,
broader project/stakeholder exploration, longer unattended work, other Codex client
versions and enforced native read-only role selection. Cooperation remains scoped
to one hub; direct writes can bypass helpers, separate hubs do not share ownership,
and multi-file checkpoints are not database transactions. The Mason exclusions
above remain project design questions, not hidden Piper implementation debt.
