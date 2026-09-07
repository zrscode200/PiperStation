# Three-role implementation: validation evidence

September 7, 2026. Implements the accepted [subagent design](subagent-design.md)
on `codex/subagent-design`, starting from proposal commit `8312fa4`.
The seven-role [earlier experiments](codex-prototype-experiments.md) remain
historical evidence; the results below exercise the new distribution.

## Environment and isolation

Piper's source repository is not a hub. Its root `AGENTS.md` contains maintainer
instructions. Reading or editing the templates does not enter a Piper phase.
These evaluations deliberately rendered separate hubs, registered disposable
source copies, and launched fresh Codex processes with explicit test requests.
Mason workers below belong to a test workload, not Piper implementation or the
live Mason project. No original project source or global configuration changed.

Retained local evidence root:
`/private/tmp/piper-three-role-_u6mqwh6/`.
`preparation.json` records source identities, seeded faults and generated-template
SHA256 fingerprints. `runs/` holds prompts, invocation metadata, JSONL output,
final reports, and extracted runtime metadata. The case directories retain their
hubs, source repositories, worktrees and scratch output. These are local fixture
paths, not required installation assets or a new Piper worker registry.

Codex CLI **0.153.4** ran with `--ignore-user-config --strict-config`, explicitly
trusted fixture directories, `default_permissions=":workspace"`, on-request
approval and automatic approval review. No model or effort override was supplied;
parent runtime metadata reported `gpt-6-astra`, workspace-write and restricted
network. Authorized local Git metadata writes sometimes required native approval.
No dependency installation, external project actions or permission-policy edits
were performed. The small case used an existing cached Python environment, with
imports explicitly verified against its new source copy.

## Results

| Case | Observed result |
| --- | --- |
| Small-work control | Multiline startup error fix in copied `lc_factory`; reproduced failure, 28 focused tests passed, no workers, one acceptance record. |
| Open investigation | One investigator returned four source-grounded options for discovering relevant recorded work; uncertainty about native session visibility remained explicit. |
| Provisional design review | One fresh reviewer challenged an on-demand overview and returned five design constraints; no design acceptance, implementation or durable hub publication. |
| Worker entry outside the hub | The design parent and helpers used supplied absolute hub/source context from a source checkout, without registration, phase-entry artifacts or source changes. |
| Coordinated implementation | Two isolated implementers fixed distinct seeded Mason regressions; parent assembly exposed both failures in the combined path, then all 288 tests passed. |
| Independent verification | Reviewer inspected the exact Mason base/candidate and independently passed the combined test plus 170 focused tests using temporary fixtures; validation source remained clean. |
| Incomplete assignment | An explicitly briefed implementer reported missing acceptance, ownership, branch assignment and fixed contracts; no edits, commits or invented checkout binding. |
| Fresh-session recovery | Detected already-completed integration, reran 288 tests, closed stale hub records, preserved retained worker changes and did not merge again. |
| Seven-role upgrade | Disposable migration test removes five retired managed roles, installs the three current roles, and preserves project records, historical assignments, custom unmanaged role files and retained source. |

### Small-work control

The source copy starts at `0543f0a41639e64ca30c80effbe7f606ad3e8195`, archived from
the historical pre-fix `lc_factory` snapshot used in the baseline experiments.
The actor received the behavioral request, not the historical solution or an
instruction to avoid delegation. It repaired the marked one-line summary while
preserving the full human-readable stderr. Focused verification: **28 passed**.
Source result `6de16b0`; hub acceptance checkpoint `460185b`; both clean.
Native telemetry records zero worker launches. No group, queue or worker roster
was introduced for this small change.

### Investigation and design challenge

The fixture source at `d9de1cb7785a4ebd23240754cfaac32e5683bdd6` contains the Piper
candidate. The question asked how one developer could notice relevant work in
another session without treating saved status or handles as liveness evidence.
The investigator explored conversational readout, focused startup context,
on-demand overview, and native discovery/notifications. A fresh reviewer
challenged the provisional overview's coverage, authority, relevance, freshness
and artifact cost. The parent synthesized those as design constraints and kept
implementation undecided. Source and hub stayed clean and unchanged.

Native telemetry confirms two launches with `fork_turns: "none"`. The parent
reports explicitly supplied investigator/reviewer briefs and absolute context;
assignment text is encrypted in session telemetry, so this report does not claim
independent inspection of its full plaintext through that telemetry.

An evaluator typo named absent `tests/test_record.py`. The actor inspected the
actual `tests/test_records.py`, explained its disposable writes and corrected
invocation, and did not claim a test pass or silently broaden the narrowly named
check. Parent hook and record-reader probes were attributed separately from the
helpers' file, Git and source-inspection probes. Direct hook execution does not
establish automatic hook activation.

### Two implementers and combined review

The Mason fixture was archived from the completed earlier evaluation candidate,
with no repair history exposed. The evaluator deliberately seeded two faults:
subprocess cleanup discarded the pending primary exception, and cleanup recovery
reported a completed fresh-install rollback as false. This is a bounded regression
replay, not discovery of two new bugs in live Mason.

Starting source: `0d3304085172ba8c51d4b22032739317852bbe71`.
Accepted candidate: `01329b7712d1f6163c0d134b5570499d5fc64188`.
The implementers owned execution source/tests and maintenance source/tests in
separate worktrees. They retained their uncommitted changes as assigned; the
parent compared them with the assembled candidate and preserved the patches.
The combined regression first failed on exception identity; with the execution
repair alone it failed on rollback reporting. Both fixes together passed.

The execution worker passed **51** focused tests; maintenance passed **119**.
The parent passed **288** full-suite tests. A fresh independent reviewer inspected
the complete base/candidate in a separate detached validation worktree and passed
**1** combined test plus **170** focused tests. No findings remained and the
reviewer made no source/test/record/config edits. Parent full-suite evidence was
not misrepresented as independently rerun by the reviewer. Initial acceptance
checkpoint `0fbc4c2` left main unchanged and retained a precise pause packet.

Telemetry confirms two implementation launches and one fresh review launch.
The implementers inherited parent context (`fork_turns: "all"`); the reviewer
used `"none"`. This validates assignment isolation and fresh review context,
not reduced implementation context size. Both seed symptoms and the two-worker
split were supplied by the evaluator; they were not autonomous discoveries.

### Incomplete assignment and interruption

The source-maintenance task launched a separate fresh native worker through
`collaboration.spawn_agent`, supplying the installed implementer brief plus an
intentionally incomplete task-discovery assignment against the design fixture.
`runs/assignment-probe-evidence.json` is the labeled evaluator record of that
dispatch and returned report; this case has no separate CLI invocation.
It was interrupted by the user's discussion, then resumed without supplying new
bindings. It inspected partial state, distinguished observed `main` from an
assigned branch, reported the missing contract, and returned an empty diff.
The fixture source and hub remained clean. This checks one incomplete-assignment
and interruption path; it does not exhaust every stale-contract or process-death
scenario.

### Fresh-session publication recovery

The evaluator used `piper-integrate` to publish the already verified candidate
into the disposable Mason main, deliberately leaving the old hub checkpoint
unchanged. Both checkouts remained clean at the accepted candidate; project-record
hashes before and after publication were identical. The fresh actor receives only
an instruction to finish local closeout with current integration authorization,
not a description of the injected gap or an expected answer.

The fresh session found main already at the accepted candidate, reported old
worker liveness as unknown, and preserved the dirty worker results already
included in that candidate. It reran **288 tests**, kept the existing exact-source
independent review evidence, and closed the lane at hub commit
`02ac7fd5b7c67356c487062aa593e5ab17454dad`. No worker was restarted and no second
integration ran. Evaluator inspection confirmed one main fast-forward, clean
main/candidate/validation/hub, a closed active-work record, and both retained
worker file pairs byte-identical to the candidate.

## What is established, and what is not

The installed role set is investigator, implementer and reviewer. All three TOMLs
parse, and strict Codex startup succeeds with the rendered hub configuration.
Observed tools expose no native role selector. Explicit briefing worked in these
runs; observer behavior preserved inputs, and permitted temporary-file checks
ran successfully. Workers reported inherited workspace-write permissions.

These results **do not establish native custom-role selection or enforcement of
the observer TOMLs' read-only sandbox setting**. The runtime rules retain those
declarations for clients that apply them and require reporting actual capabilities
separately. They do not suggest relaxing permissions when a check is blocked.
There was no new forced read-only-denial experiment in this client.

The role simplification preserves existing ownership and recovery helpers.
Repository checks cover stale revisions, conflicting ownership, unsafe paths and
publication guards. Broader independent-session coordination and process-death
cases retain the earlier evidence; this update does not claim to rerun them all.
Fewer role names are not evidence of lower latency or cost. The small-work
control avoided launches; the coordinated and design tests deliberately requested
their workers and therefore do not measure spontaneous delegation selection.

## Repository review and checks

Independent review found one inherited authority exception permitting worker hub
publication, integration or recursive delegation. It was confirmed in scope and
removed from the common procedure. Follow-up review found the fix consistent in
core and rendered output and no material issue in the migration test. This was
static review, separate from the native behavioral evaluations above.

Verification passed: `./tests/run.sh` (distribution/lifecycle/migration checks,
**29 record tests**, **32 integration tests**), required shell syntax checks,
renderer freshness, TOML parsing and `git diff --check`. Skill Creator's validator
passed for the three modified skill entry files using the cached interpreter
with PyYAML; system Python lacked that optional validator dependency.

## Stamped-hub rollout

The authorized hub at
`/Users/ziruisu/Rui_Space/personal_agent_space/peronsal_assistants/gas_town/piper_station_parallel`
was refreshed after validation and review. Preflight found a clean hub, an empty
registry, no matching task in the recent native task inventory, and no observed
process command or working directory using that hub. This was an idle rollout;
the disposable-hub tests do not establish safe hot replacement for live workers.

Bootstrap changed **17 managed files**, retired the five obsolete role files,
and installed the three-role set. All **40 managed template files** matched the
evaluated generated bytes. Existing project files and unmanaged files were
preserved; the hub remained clean after scoped local commit
`dc9a81dfd9f017a456f17d38a3bfb4a74521c231`. The retained
`runs/stamped-hub-refresh.json` records before/after hashes and the exact delta.
No project source was registered or changed by this refresh.
