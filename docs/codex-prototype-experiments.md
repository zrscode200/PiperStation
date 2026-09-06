# Codex prototype: first experiments

Status: upgrade and experiments in progress. The first native baseline run is
complete; larger coordination and resume demonstrations remain pending. Piper
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

Compare independently steered sessions with a main session and explicitly
delegated workers. Give both arrangements the same starting state, acceptance
requirements, and evidence. Introduce counterexamples drawn from the later
integrated review after the initial work appears ready. Observe whether Piper
identifies the affected assumptions and work, assigns responsibility for the
resolution, and verifies the combined result before completion.

Include a pause/resume boundary after a material finding. A fresh session must
recover what remains valid, what needs repair, and the next action from the hub
records and live source. Do not assume an earlier worker is still running.

Use local tests and fixtures. Databricks setup, live workspaces, deployment, and
publication are outside this experiment.

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
pins `gpt-5.5` and medium reasoning. Invocation used `--ignore-user-config`,
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

These are code/test findings, not substitutes for native workflow evidence.

### Independent Mason design sessions

Project Mason's isolated starting fixture passed its 95 execution and setup
tests. Two new Codex sessions then ran concurrently in `case2-upgrade/hub`,
against the unchanged source outside it. Both used CLI 0.153.4, strict config
validation, invocation-scoped hub trust, ignored user config and automatic
approval review. The captured template still pinned gpt-5.5/medium; the later
inheritance correction was not silently applied to those running sessions.

| Studio | Native task | Observed outcome |
| --- | --- | --- |
| recovery-continuity | `01a074f9-a343-7773-a3e9-4afbbb0a60e1` | 11 selected baseline tests and four controlled interruption observations; provisional revision 1 with independent pause packet, evidence, and ledger; six records committed as `5107725`. |
| process-outcomes | See `runs/case2-design-outcomes.jsonl` | 34 selected baseline tests; provisional revision 1, independent pause packet and ledger; checkpoints `1b4220d` and `b7e5ecd`. |

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

The next fresh session explicitly resumes recovery-continuity, reads the other
proposal, narrows the experiment to existing public behavior, and receives two
evaluator counterexamples: retained failed-attempt staging after prior trees
are placed, and invocation while the caller handles an unrelated exception.
It requests a fresh read-only reviewer and another pause checkpoint. Its launch
uses the refreshed configuration with inherited model/effort choices and the
modern `default_permissions = ":workspace"` profile; it does not reuse either
design conversation. Source implementation, combined review, integration and
execution resumption remain pending.
