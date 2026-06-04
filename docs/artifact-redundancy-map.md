# Artifact System Redundancy Map

A read-only audit of redundancy in Piper Station's artifact system: the
intent-to-writes signal policy, the scope/risk/automation tier tables, the
compact resume packet, and the `work/` artifact taxonomy.

Line references are a snapshot of branch `trim_artifact` at `b8b590c`
(2026-06-04) and will drift as files are edited; treat them as anchors, not
guarantees.

## Status

**Kind 1 (artifact taxonomy): applied.** `handoff.md` merged into
`context-pack.md` (which now also carries the handoff fields), and `progress.md`
dropped (no consumer — not a resume anchor). The active `work/` set is now 5 —
`active-spec`, `active-plan`, `task-queue`, `context-pack`, `verification` —
plus `specs/`/`plans/`/`runs/`. The continuity-cluster analysis below is
retained as the rationale.

**Kind 2 (definition redundancy): deferred.** The tier tables (scope/risk/
automation) and inline enumerations are unchanged. The audit found their copies
consistent (no conflict), so consolidation is a footprint choice, not a
correctness fix; see the cut summary for the planned approach.

## Scope

"Artifact system" here means two distinct things that got conflated:

- **The intent-to-artifact policy** — the tables that map a user signal to the
  durable writes it warrants (Artifact Signal Policy), plus the scope/risk/
  automation tiers that gate those writes.
- **The artifact taxonomy** — the files under `projects/<id>/work/` themselves
  (`active-spec`, `active-plan`, `task-queue`, `context-pack`, `progress`,
  `verification`, `handoff`, plus `specs/`/`plans/`/`runs/`).

The redundancy splits the same way:

- **Kind 2 — definition redundancy.** The same table/definition is restated in
  many surfaces. Large, low-risk to consolidate, behavior-identical.
- **Kind 1 — taxonomy overlap.** Several `work/` artifacts encode overlapping
  content. Smaller, but consolidating changes the model, so it needs a
  decision rather than a sweep.

## Structural facts that shape any fix

1. **There is no single always-on shared surface.** `STATION.md` is
   single-source (one file in `core/shared/`, rendered into every hub) but is
   only *read on demand* ("primary operating guide", required reading). The
   always-on surfaces are the three root docs (`CLAUDE.md` / `AGENTS.md`),
   auto-loaded every session — but there are three of them. So "make STATION
   canonical" trades always-in-context for single-source. Keep tier tables in
   the always-on root docs where reliable presence matters; point to STATION
   from surfaces that already instruct "read STATION first."

2. **`generated/` multiplies every `core/` occurrence by three.** Source is
   what you edit; each `core/` duplication is copied into
   `generated/{codex,claude,opencode}`. The counts below are *source* counts.

3. **Codex double-duplicates.** `adapters/codex` overrides the `brainstorm`
   and `piper-workflow` skills, so it independently restates tables that
   `core/skills` already duplicate. Consolidating `core/skills` fixes Claude
   and OpenCode; the Codex overrides need their own matching pass.

---

## Kind 2 — definition redundancy

### Element 1 · Artifact Signal Policy table

Canonical home: `core/shared/STATION.md` (§Artifact Signal Policy).

| Occurrence | Classification | Verdict |
| --- | --- | --- |
| `core/shared/STATION.md:68` | full table | KEEP — canon |
| `core/skills/brainstorm/SKILL.md:107` (+ pointer `:112`) | full table **and** pointer to STATION | CUT table → keep pointer |
| `core/skills/piper-workflow/SKILL.md:55` (+ pointer `:59`) | full table **and** pointer | CUT table → keep pointer |
| `adapters/codex/.codex/skills/brainstorm/SKILL.md:108` (+ pointer `:112`) | Codex override, full table + pointer | CUT table → keep pointer |
| `adapters/codex/.codex/skills/piper-workflow/SKILL.md:62` (+ pointer `:66`) | Codex override, full table + pointer | CUT table → keep pointer |
| `docs/dispatch-refactor-notes.md:178` | design-history doc | LEAVE (historical record) |

The skills are self-contradicting: they state *"the full intent-to-writes map
lives in STATION.md"* and then inline the table anyway. This is the cleanest
cut in the repo — 4 live copies collapse to the 4 pointers already present.

### Elements 2 & 3 · Scope tiers (S0–S3) and Risk tiers (L0–L3)

These co-occur in the same 8 source files. Canonical home:
`core/shared/STATION.md` (§Mode Routing, scope `:149`, risk `:156`).

| Occurrence | Classification | Verdict |
| --- | --- | --- |
| `core/shared/STATION.md:149–161` | full defs | KEEP — canon |
| `core/skills/brainstorm/SKILL.md:~148` | inline defs | CUT → pointer |
| `core/skills/piper-workflow/SKILL.md:72–84` | inline defs | CUT → pointer |
| `adapters/claude/CLAUDE.md:74–86` | always-on root doc | KEEP (auto-loaded; STATION is not) |
| `adapters/codex/AGENTS.md:128–140` | always-on root doc | KEEP |
| `adapters/opencode/AGENTS.md:95–107` | always-on root doc | KEEP |
| `adapters/codex/.codex/skills/brainstorm/SKILL.md:~146` | Codex override | CUT → pointer |
| `adapters/codex/.codex/skills/piper-workflow/SKILL.md:77–81` | Codex override | CUT → pointer |

Rationale: keep tiers in the always-on root docs (reliably in context) and in
STATION (canon); cut from the **skills**, which already instruct "Read
`{{INSTRUCTION_DOC}}` and STATION.md first" and so do not need their own copy.
Net: 8 copies → 4 (STATION + 3 root docs), skills point.

### Element 4 · Automation tiers (A0–A3)

Canonical home: `core/shared/automation-policy.md`. Notable asymmetry.

| Occurrence | Classification | Verdict |
| --- | --- | --- |
| `core/shared/automation-policy.md` | full defs | KEEP — canon |
| `core/skills/automation-policy/SKILL.md` | inline defs | borderline — the skill *is* the A-tier surface; KEEP or thin to pointer |
| `adapters/claude/CLAUDE.md` (§Automation Tiers) | always-on root doc | KEEP, but see asymmetry |

Only **Claude** inlines A-tiers. `adapters/codex/AGENTS.md` and
`adapters/opencode/AGENTS.md` only say *"Ask before… See `automation-policy.md`"*
without enumerating A0–A3. So `CLAUDE.md` is heavier than its peers for no
behavioral reason. This is a **consistency decision** (raise the other two to
match, or thin Claude down), not pure dedup.

### Element 5 · Compact resume-packet field list

The full field list (goal / next exact action / scope boundary / verification /
drift / git state / …) is restated in 5 source files.

| Occurrence | Classification | Verdict |
| --- | --- | --- |
| `core/shared/STATION.md` (§Compaction) | canon | KEEP |
| `core/commands/compact-handoff.md` | the command that writes the packet | KEEP (operational; needs the list inline) |
| `adapters/claude/CLAUDE.md` (§Compaction) | always-on root doc prose | thinnable → pointer |
| `adapters/claude/.claude/hooks/pre-compact-protection.sh` | hook emits the fields to the user | KEEP (runtime output, not docs) |
| `adapters/codex/.codex/hooks/pre-compact-protection.sh` + `.codex/compact-prompt.md` | hook/prompt emit the fields | KEEP (runtime output) |

Most are load-bearing (a hook must print the list). The only soft target is the
`CLAUDE.md` prose copy.

---

## Kind 1 — artifact taxonomy overlap

### Where the taxonomy is *defined* (vs merely referenced)

| Surface | Location | Role |
| --- | --- | --- |
| STATION §Work Artifact Reference | `core/shared/STATION.md:114` | canonical 8-file + 3-dir table |
| Superpowers §Work Artifacts | `core/commands/superpowers.md:48` | re-enumerates the same set |
| Superpowers (Codex override) | `adapters/codex/.codex/skills/piper-workflow/references/superpowers.md:46` | re-enumerates again |

The taxonomy is defined 3× (STATION + 2 superpowers variants). The high raw
reference counts below are mostly *operational* ("update X when pausing"), which
is necessary, not redundant:

| Artifact | Source files referencing it |
| --- | --- |
| `context-pack` | 19 |
| `handoff` | 18 |
| `active-plan` | 12 |
| `verification` | 12 |
| `task-queue` | 11 |
| `active-spec` | 8 |
| `progress` | 8 |

### The continuity-cluster overlap (the real model redundancy)

Per STATION's own definitions:

| Artifact | Definition | Overlap |
| --- | --- | --- |
| `context-pack.md` | goal, current task, next action, key files, git state, verification state, review state, drift, blockers, stop reason | the superset |
| `handoff.md` | "current state, what to inspect first, what to do next" | ⊂ context-pack. `compact-handoff.md` directs writing it with *"the same load-bearing continuation fields"* → **merge candidate** |
| `progress.md` | chronological progress, completed tasks, blockers, review debt, next action | overlaps context-pack (blockers/next action); adds the *log* axis |
| `verification.md` | commands, results, failures, gaps | overlaps context-pack's "verification state"; adds *detail*. **fold-into-progress candidate** for hub-lite |

`active-spec` / `active-plan` / `task-queue` are a clean what / how / queue
split — no cut.

### Counter-arguments (why not to over-cut Kind 1)

- The `work/` files are **opt-in** ("create only when useful"). An unused
  artifact type costs nothing at runtime; the cost is documentation weight.
- Independent skill/command loading means **some** duplication is load-bearing —
  a surface that runs without STATION in context needs enough inline to act.

---

## Cut summary

| Target | Live copies now | After | Mechanism |
| --- | --- | --- | --- |
| Artifact Signal Policy table | 4 (+1 historical) | 1 canon + 4 pointers | pointer wording already present |
| Scope + Risk tiers | 8 | 4 (STATION + 3 root docs); skills point | skills already say "read STATION first" |
| Automation tiers | 3, asymmetric | decide symmetry | consistency call, not pure dedup |
| Resume-packet fields | 5 | 4 (1 prose copy thinnable) | rest are load-bearing |
| Work-artifact enumeration | 3 | 1 canon + 2 pointers | superpowers points to STATION table |
| Continuity files | 4 | 2 (applied) | handoff merged into context-pack; progress dropped; verification kept |

## Recommended sequencing

1. **Low-risk block (do first):** Elements 1–3. Pure dedup, behavior-identical,
   pointers already exist. Validate with a re-render and
   `python3 scripts/render_templates.py --check`, then `./tests/run.sh`.
2. **Consistency decision:** Element 4 (automation-tier symmetry across the
   three root docs).
3. **Model decision (separate):** Kind 1 — merging `handoff` into
   `context-pack`, and whether `verification` folds into `progress` for
   hub-lite. Changes the artifact model, so decide deliberately.

## Related

- `docs/dispatch-refactor-notes.md` — origin of the Artifact Signal Policy and
  the brainstorm/piper-workflow split.
- `core/behavior/README.md` — the core-vs-adapter authoring rule that the
  consolidation must respect.
