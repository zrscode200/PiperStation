# OMP (Oh My Pi)

Enable OMP in a new hub or add it to an existing, idle, checkpointed hub:

```sh
./bootstrap/init.sh --runtime omp /path/to/hub
cd /path/to/hub
omp
```

Run these installer commands from the Piper source distribution. Normal `omp`
at the installed hub root loads `AGENTS.md`, `.omp/skills`, `.omp/agents` and
`.omp/extensions/piper.js`. No wrapper or copied startup prompt is required.
The source distribution itself is not an installed hub. Launch at the hub root:
native extension discovery is cwd-only, even though instructions and skills can
be found in ancestors. Your CLI's discovery filters can disable these surfaces.

Use natural language or `/skill:brainstorm`, `/skill:design-studio`,
`/skill:piper-workflow`, `/skill:piper-review` and `/skill:automation-policy`.
The skills use the same canonical procedures as the other Piper adapters.
OMP reads skill references using `skill://<name>/references/<file>` or their
actual filesystem paths. Native `.omp` skills take precedence over matching
foreign-runtime names. In a hub with Codex, OMP may also discover Codex's `review`
alias; it contains the same Piper review procedure. Prefer `piper-review` in OMP.
No user skill sources, models, credentials or permission defaults are overridden.

## Continuity and compaction

On the first model turn and after a session switch, branch, tree navigation or
compaction, the extension supplies shared Piper routing and available lane
locators, with saved-record resume guidance. It does not import another CLI's
conversation, claim a worker is alive, or select a lane merely because it exists.
Read the selected project's records and verify actual source/worker state.

Before compaction, the extension displays checkpoint guidance when UI is
available and adds it to native summary context. After compaction, the next turn
receives resume context. These are reminders: no packet is written and no
compaction is cancelled. Explicitly checkpoint before switching or compacting.
The extension requires Python 3, as do Piper's existing deterministic helpers.
If it cannot load context, it reports a fallback and retries next turn; read the
root instructions and saved records directly.

## Parallel work

Read the shared `piper-workflow/references/coordinated-work.md` procedure first.
Use `piper-investigator` and `piper-reviewer` as the explicit native task agent
names, with bounded assignments and absolute hub/source/record references.
Their profiles request read/search/web tools and omit `task` and `spawns`,
using OMP 18.0.8's disabled child-spawning default. Its agent parser ignores YAML
`spawns: false` and empty lists; the child executor maps omitted spawns to an
empty policy, which the spawn guard denies. Do not replace it with the string
`"false"`, which would instead name an allowed agent. OMP
may add native reporting/collaboration tools; inspect actual tools. The bundled
OMP `reviewer` remains intact for its built-in `/review` command, which has a
different output contract. Piper's `piper-review` skill owns Piper review gates.

OMP 18.0.8 native task children normally inherit the coordinator's cwd. The task
schema has no per-task cwd, and native isolation uses disposable checkouts.
Isolated successful work can apply back automatically; native workspaces are
removed at task completion, including failed runs that may have no saved patch.
Setting `task.isolation.apply: false` is insufficient to preserve failed edits,
and eval-backed task calls have their own apply controls. **Do not use native
task writers from a Piper hub for durable project implementation.** Piper does
not install an isolation setting that would imply these guarantees.

For an explicitly authorized source-writing worker, the coordinator creates and
binds an exclusive persistent checkout/branch, verifies writable access, then
starts a separate OMP session there with the distributed plain implementer brief:

```sh
piper_hub=/absolute/path/to/hub
piper_checkout=/absolute/path/to/assigned-worktree
piper_brief="$piper_hub/.omp/roles/implementer.md"
test -f "$piper_brief" && omp --cwd "$piper_checkout" --append-system-prompt "$piper_brief"
```

Supply the concrete assignment, owned paths, fixed contracts, verification and
return expectations in that session. The existence check matters: OMP treats a
missing prompt-file path as literal prompt text. This supplement preserves the
native base prompt; it does not apply a task profile's tool restrictions or grant
permissions. Respect the host's normal approval/access settings and verify the
actual branch and cwd. The worker preserves its checkout, reports results and
leaves hub records, review acceptance and integration to the coordinator.
Native task tool allowlists are not an OS sandbox; headless task children may
use approval bypass internally. Piper neither enables bypass for the parent nor
claims native child prompts can enforce filesystem isolation. Keep checks that
need a shell in the coordinator instead of widening an observer profile.

## Validation

Target contract: installed OMP **18.0.8**, checked against matching upstream
sources on 2026-09-10. Deterministic tests exercise the installed extension with
synthetic lifecycle events and real Python context generation, all four-runtime
install combinations, refresh and unmanaged-file conflicts. Native discovery
and model-run evidence are recorded in the [capability matrix](capability-matrix.md).
No live OMP model evaluation is implied by file or event tests.

Version-matched primary references:

- [Extension loading](https://github.com/can1357/oh-my-pi/blob/v18.0.8/docs/extension-loading.md)
- [Skills](https://github.com/can1357/oh-my-pi/blob/v18.0.8/docs/skills.md)
- [Task agent discovery and dispatch](https://github.com/can1357/oh-my-pi/blob/v18.0.8/docs/task-agent-discovery.md)
- [Extension lifecycle contracts](https://github.com/can1357/oh-my-pi/blob/v18.0.8/packages/coding-agent/src/extensibility/shared-events.ts)
