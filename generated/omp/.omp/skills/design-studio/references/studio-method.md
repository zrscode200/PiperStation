# Design Studio Method

Use this method as an adaptive repertoire, not a mandatory sequence. A focused
contract question may need only framing and a concrete model. A broad
multi-session initiative may cycle through every move several times.

## Start From The Current Boundary

Resolve the smallest design boundary that would materially advance the
initiative now. Useful boundaries include:

- a user or operator journey;
- a component responsibility;
- an interface or contract;
- a state transition;
- a data or authority boundary;
- a failure or recovery scenario;
- a decision whose alternatives have meaningfully different consequences.

Name what is confirmed, inferred, assumed, constrained, undecided, and out of
scope. Do not let an implementation idea silently become a design requirement.

## Ground The Discussion

Read the project record, relevant prior design, and the live repository before
making source-supported claims. Inspect the code paths, call sites, tests,
configuration, generated surfaces, or runtime seams that can validate or
invalidate the current model.

Use external research or disposable experiments only when the evidence is
needed and the action is routine or has a recorded go-ahead. Record
findings and implications; do not confuse research material with current design
authority.

## Research To Expand The Options

Use research when an unfamiliar domain, uncertain feasibility, or approaches
beyond the current repository could materially change the design. Start with a
bounded problem area and learning goals; a preferred solution is not required.
Handle quick questions directly and use an `investigator` when separate context
or parallel investigation would help the discussion.

Frame the assignment with the relevant users or scenarios, project constraints,
known facts, assumptions still open to challenge, and what we need to learn.
Set useful breadth and a return point. For example, a coordination question may
need alternative ownership and recovery models plus their failure cases, before
we know which mechanism fits our project. The common coordinated-work procedure
owns assignment and action boundaries.

Ask for findings that help the next design conversation:

- Credible approaches from relevant prior art, original implementations,
  documentation or research, including useful ideas from adjacent domains.
- Evidence quality: primary source anchors, relevant dates or versions,
  documented behavior versus claims or inference, and contradictory evidence.
- Applicability: the assumptions behind each approach, how our users and
  constraints differ, and what could be adopted, adapted or rejected.
- Implications for the alternatives, remaining uncertainty, and what evidence
  would change the recommendation. Missing access or inconclusive evidence
  remains a stated limit.

Stop the inquiry when it can materially advance the discussion, or return to
the parent when further progress requires new scope or unavailable evidence.
Let the question determine the output's size and form; no source quota, required
research document, or automatic design acceptance. The main session synthesizes
findings with the user and preserves useful evidence through the existing studio
artifact and checkpoint rules. Preserve observation time, source context and
decision impact for consequential findings; later reassessments explain changed
applicability without erasing the earlier result. See artifact-contracts.md →
Evidence Over Time for recording ownership and temporal distinctions.

## Diverge Where A Real Choice Exists

Generate multiple credible approaches when their tradeoffs matter. Compare
them on consistent dimensions such as:

- fit with the product intent and existing architecture;
- user or operator experience;
- complexity and coupling;
- authority and security;
- failure and recovery behavior;
- reversibility and migration;
- operational burden;
- future evolution.

Do not generate alternatives as ceremony when one path is already constrained
by accepted contracts or live source.

## Make The Design Concrete

Choose representations that reduce ambiguity:

- narratives and scenario walkthroughs;
- user, operator, or system flows;
- responsibility and boundary maps;
- state machines and transition tables;
- interface, API, event, or data sketches;
- sequence or architecture diagrams;
- wireframes and interaction examples;
- evaluation cases and representative payloads.

Artifacts emerge from the question. Their filenames should describe their
content rather than place them into universal categories. Keep the overview
readable by explicitly adopting detailed contracts where useful; linking research
or alternatives does not adopt them. No classification pass is required.

## Pressure-Test The Synthesis

Use only the lenses relevant to the initiative, but do not ignore material
risks:

- happy path and degraded path;
- partial failure, retry, rollback, and recovery;
- ownership, permission, trust, and escalation;
- security and sensitive-data boundaries;
- concurrency, ordering, idempotency, and stale state;
- usability, discoverability, and error explanation;
- observability and operational support;
- compatibility, migration, and reversibility;
- future extension without premature abstraction.

Ask what evidence would overturn the current design. Keep unresolved evidence
gaps visible.

## Align Before Recording

Present the current synthesis, tensions, and remaining questions to the user.
Record durable design after provisional alignment rather than presenting a
prewritten architecture as accepted.

In `design.md`, distinguish:

- confirmed facts and source anchors;
- assumptions and inferences;
- fixed contracts;
- implementation freedoms;
- unresolved questions;
- rejected alternatives and their rationale.

Only the user can accept a revision for Piper Workflow planning.
Present the adopted details with the overview so acceptance has a clear scope.
Use the ordinary checkpoint to retain the reviewed files and acceptance entry,
following artifact-contracts.md → Revision And Acceptance.

## Checkpoint At Meaningful Boundaries

A useful checkpoint records the integrated design and the next design
discussion. It is not a transcript and does not need one entry per session.

Checkpoint when:

- a material synthesis becomes durable;
- an important contract is accepted or superseded;
- source evidence corrects the model;
- a pressure test changes the design;
- the studio pauses, hands off, or concludes.

Use Piper's existing active-work, build-log, context-pack, roadmap, queue,
decision, memory, and git owners. Do not construct a parallel studio lifecycle.

## Know When To Exit

Continue when a design question remains valuable and bounded. Pause when the
next useful discussion requires missing evidence or a fresh session. Conclude
when the design is useful but no implementation is desired. Hand off only when
the user explicitly accepts the current revision and its fixed contracts are
clear enough for source verification.
