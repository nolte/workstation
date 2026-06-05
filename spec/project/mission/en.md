# Project Mission

Status: draft

## Context

Readers: repo maintainers of hobby-scale nolte projects who invoke the `mission-define` and `mission-revise` skills (when those exist), the operators who flip a project's `mvp_status` at stabilisation, plus the implementing authors writing those skills against this schema.

Existing portfolio specs cover what work is queued (`roadmap`), how work is grouped (`sprint`), the unit of execution (`feature`), and how releases ship (`release-artifact`, `release-automation`). What's not yet declared is **why the project exists at all, for whom, and which subset of the queued work is the minimum that genuinely fulfils that purpose**. This spec fills that gap. A mission statement in the nolte portfolio is a markdown-tracked, audience-tailored, SMART-shaped sentence that anchors the roadmap: it ties every queued item back to a stated purpose, distinguishes the **MVP** (the minimum useful surface that proves the mission) from **post-MVP** delimitation (named explicitly so the boundary stays visible), and gates post-MVP work on MVP stabilisation. The audience-tailoring requirement is load-bearing: a mission statement that doesn't resolve back to the project's audience artefact is a private goal, not a portfolio mission.

## Goals

- Define the on-disk shape of a project mission as a single markdown file at `project/mission.md`, parallel to `project/roadmap.md` and `project/goals.md`, with a stable frontmatter schema and required body sections so consuming skills can parse, mutate, and validate the mission deterministically.
- Formalise SMART for the hobby-scale portfolio: each of the five letters becomes its own checkable requirement, with the **Time-bound** anchor expressed as an outcome-or-MVP-completion reference rather than a calendar date.
- Specify the **MVP definition** as the minimum subset of roadmap items whose completion verifies the mission via the existing `verifies_sprint_value` mechanism declared in the sibling `feature` spec; no new verification mechanism is introduced here.
- Specify the **stabilisation gate**: post-MVP roadmap items (`mvp: false`) **MUST NOT** advance to `status: active` until the MVP as a whole is **stabilised**, and this spec defines the exact conditions under which the operator may flip `mvp_status` to `stabilised`.
- Mandate **audience tailoring**: for every audience listed in `audiences`, the body **MUST** explain what the MVP delivers to that audience; an audience listed without a tailored paragraph fails validation.
- Stay portfolio-reusable: every project type the portfolio supports (Claude plugin, Python application, Python library, Node / TypeScript, CLI tool, documentation-only) can adopt the schema unmodified; project-type-specific guidance lives only in body content, never in the frontmatter schema.

## Non-Goals

- Defining roadmap, goals, sprint, feature, or release-artefact internals. Each is owned by its own sibling spec; this spec only declares the mission-side surface and the cross-references it carries.
- Substituting `audience-identification`. Audience enumeration, characterisation, and confirmation are its concern; this spec consumes the resulting artefact and **MUST NOT** invent audiences inline.
- Substituting `continuous-improvement`. That spec runs event- and calendar-driven audits over the whole portfolio's process hygiene; mission-side authoring is product-shaping, not process-shaping, and the two cadences run in parallel without replacing each other.
- Mandating a calendar deadline for mission completion. Hobby-scale projects don't carry dates per the sibling `sprint` and `roadmap` specs; this spec inherits that constraint and rejects calendar-anchored Time-bound clauses.
- Replacing portfolio strategy documents (vision decks, OKR sheets, product briefs). The mission file is a markdown artefact under version control next to the code it describes; cross-references to external documents are allowed but never authoritative.
- Mandating a stakeholder sign-off ritual before mission writes are accepted. Hobby-scale projects don't carry a stakeholder process; the audience-tailoring + outcome-linkage + verifying-feature requirements together replace what an enterprise sign-off would catch.

## Requirements

### Directory layout and file shape

- **MUST** place the mission at `project/mission.md`, exactly one file per project, never split.
- **MUST NOT** nest the file under `docs/` or any other subdirectory; the mission is a top-level orientation point parallel to `spec/`, `tests/`, and the rest of the `project/` planning artefacts.
- **MAY** be absent in repositories that haven't yet adopted the planning suite; absence is permitted by the sibling `project-structure` spec. Once present, every requirement in this spec applies.

### Frontmatter schema

- **MUST** open the file with a YAML frontmatter fence carrying the following fields, in this order:
  - `mission_statement` (string, required, non-empty): the actual SMART-shaped sentence in the project's primary language; one sentence, no markdown formatting beyond inline punctuation.
  - `relevant_outcomes` (list of outcome IDs, required, non-empty): every entry **MUST** match an `O-<n>` defined in `project/goals.md` per the sibling `roadmap` spec.
  - `audiences` (list of audience identifiers, required, non-empty): every entry **MUST** match an audience entry in the project's audience artefact (`AUDIENCES.md` or the location declared by the consuming repo per `audience-identification`).
  - `verifies_via` (string, required): pattern `<feature-id>:acceptance-<n>` (for example `F-3:acceptance-2`), naming the feature whose `verifies_sprint_value` frontmatter field points at the acceptance criterion that proves the mission is achieved; the named feature **MUST** exist under `project/features/` and the named acceptance identifier **MUST** exist on that feature.
  - `time_bound` (object, required): one of two shapes, `{ kind: outcome, ref: O-<n> }` (Time-bound to a specific outcome from `goals.md`) or `{ kind: mvp_completion }` (Time-bound to the moment `mvp_status` reaches `achieved`); calendar-date forms are forbidden.
  - `mvp_status` (enum, required): one of `defining` (the MVP scope is being shaped), `in_progress` (at least one MVP item is `active` or `done`), `achieved` (every MVP item is `done` and the verifying acceptance criterion is checked), `stabilised` (the achieved state has held across one full subsequent sprint per §Stabilisation gate).
  - `created` (ISO date, required): the date the mission file was first written; never edited after creation.
  - `revised_at` (ISO date or null, required): the date of the most recent meaningful revision (a change to the statement, the audiences, the verification, or the time-bound clause); null while the mission file is in its original-write state.
- **MUST NOT** include calendar deadlines, OKR scores, KPI fields, or stakeholder-assignment fields beyond what's declared above; lints flag unknown keys.

### Body sections

- **MUST** carry the following level-2 sections in this order, even when content is sparse (skills depend on stable section headings):
  - `## Statement`: the mission statement repeated as prose, immediately followed by a SMART decomposition (one short paragraph per letter, naming which frontmatter field anchors that letter—see §SMART contract).
  - `## Audiences`: one paragraph per audience listed in the `audiences` frontmatter field, naming the audience and stating what the MVP delivers to that audience specifically; no audience may be listed in frontmatter without a paragraph here, and no paragraph may name an audience that isn't in the frontmatter list.
  - `## Verification`: a short prose pointer to the feature and acceptance criterion named by `verifies_via`, repeating the criterion text verbatim so the mission file is readable without walking the feature corpus.
  - `## Source`: the audit trail—which audience artefact was consulted (path plus its last-commit SHA at the time of writing), which `goals.md` outcomes were referenced, who or what authored the mission (operator name, skill version, or commit SHA of the mission-defining change).
- **MAY** carry an additional `## Open questions` section for unresolved authoring decisions; **MUST NOT** alter the order of the four required sections to accommodate optional ones.

### SMART contract

The mission statement **MUST** satisfy each of the following five constraints, individually checkable from the artefacts named:

- **Specific**: the `mission_statement` names both **what** the project does and **for whom**; the **for whom** **MUST** resolve to one or more entries in the `audiences` frontmatter list. A mission whose audience is implicit ("for users") fails this constraint; the audience identifier is explicit.
- **Measurable**: the `verifies_via` frontmatter field names a single feature and a single acceptance criterion on that feature. When that acceptance criterion is checked (per the sibling `feature` spec), the mission is measurably achieved. No other verification mechanism is introduced.
- **Achievable**: every roadmap item with `mvp: true` carries `detail: fine` and a non-null `target_sprint` per the sibling `roadmap` spec, and the count of MVP items **SHOULD** be roughly two-to-five sprints' worth of capacity. An unbounded MVP scope (every roadmap item flagged `mvp: true`) defeats achievability and **MUST** be rejected by consuming skills with a verbatim error.
- **Relevant**: the `relevant_outcomes` frontmatter list is non-empty and every entry resolves to an outcome in `project/goals.md`. A mission that doesn't tie back to at least one declared outcome fails this constraint.
- **Time-bound**: the `time_bound` frontmatter object is one of `{ kind: outcome, ref: O-<n> }` or `{ kind: mvp_completion }`. Calendar dates and free-text deadlines are rejected. The bound is intentionally outcome-shaped because hobby-scale sprint duration is variable per the sibling `sprint` spec; this spec inherits that constraint.

### MVP definition and delimitation

- **MUST** define the MVP as the set of roadmap items in `project/roadmap.md` whose YAML block carries `mvp: true`. The flag's authoritative location is the roadmap; the mission spec is the authority for the flag's semantics.
- **MUST** treat any roadmap item with `mvp: false` as **post-MVP** and therefore optional for fulfilling the mission. Post-MVP items remain in the roadmap explicitly so the boundary between minimum and additional scope stays visible: naming an item but flagging it `mvp: false` is the canonical way to mark that the team knows about the item, that the item isn't part of MVP, and that the item waits.
- **MUST** require, for every roadmap item with `mvp: true`, that at least one of its features (per the sibling `feature` spec) declares `verifies_sprint_value` non-null when that feature ships in the sprint that closes the MVP. Across the full MVP scope, exactly one feature **MUST** be the one named in the mission's `verifies_via` field; that feature is the **mission-verifying feature**.
- **MUST NOT** allow a roadmap item to flip its `mvp` flag from `true` to `false` after the item has reached `status: active`; once an item enters MVP execution, removing it from MVP scope retroactively is forbidden because it would break the achievability bound the SMART contract relies on. Items **MAY** flip from `mvp: false` to `mvp: true` at any time before stabilisation.

### Stabilisation gate

- **MUST** treat the MVP as **stabilised** when, and only when, every condition below holds simultaneously:
  - every roadmap item with `mvp: true` carries `status: done`;
  - the sprint that closed the last MVP item is itself `status: closed` per the sibling `sprint` spec;
  - one full subsequent sprint has reached `status: closed` (or `cancelled` due to no-fault-of-MVP reasons) without re-opening any MVP item to `status: active`;
  - no defect-fix work targeting an MVP item is currently in `status: in_progress` per the sibling `feature` spec.
- **MUST NOT** allow any post-MVP roadmap item (`mvp: false`) to transition `proposed → active` while `mvp_status` is any of `defining`, `in_progress`, or `achieved`. The transition is permitted only when `mvp_status: stabilised`.
- **MUST** require the operator (or a future automation skill) to flip `mvp_status` to `stabilised` explicitly; the flip **MUST NOT** be inferred silently from satisfying the conditions above. The flip records the decision; the conditions justify it.
- **MUST** revert `mvp_status: stabilised → in_progress` when an MVP item re-opens to `status: active` (for example because a defect surfaced after stabilisation); the gate then re-applies and post-MVP items already in `status: active` at the time of the revert **MAY** continue to completion but no new post-MVP item **MUST** be allowed to start until stabilisation is restored.
- **MAY** record the stabilisation evidence (the sprint number that satisfied the one-full-subsequent-sprint condition, the date of the operator decision) in `## Source` for the audit trail.

### Audience tailoring

- **MUST** require, for every audience listed in `audiences`, a paragraph in `## Audiences` that names the audience identifier and states what the MVP delivers to that audience specifically. A bare list of audience names without per-audience paragraphs fails validation.
- **MUST NOT** name an audience in `## Audiences` that isn't also in the `audiences` frontmatter list, and vice versa; the two surfaces are bidirectionally validated.
- **SHOULD** keep each per-audience paragraph short (three to five sentences); when a single audience needs more, the audience itself is probably under-specified and `audience-identification` should be re-run rather than padding the mission file.
- **MAY** group audiences when their MVP-deliverable is identical (one paragraph naming the two audiences and stating the shared deliverable), but each audience identifier **MUST** still appear by name and the grouping rationale **MUST** be stated in the same paragraph.

### Cross-spec linkage

- **MUST** treat `audience-identification` as the authority for the audience artefact's form and content. When the project has no audience artefact, mission authoring is blocked; the `audience-identify` skill **MUST** be dispatched first, identical to the rule that already applies to outcome authoring in the sibling `roadmap` spec.
- **MUST** treat the sibling `roadmap` spec as the authority for the `mvp` field's location in the roadmap-item YAML schema; this spec is the authority for the field's semantics. The two surfaces refer to each other explicitly, and the cross-reference is one-way for each concern (location → roadmap, semantics → mission).
- **MUST** treat the sibling `feature` spec as the authority for `verifies_sprint_value`; this spec consumes the mechanism and **MUST NOT** redefine it.
- **MUST** treat `goals.md` (governed by `roadmap`) as the authority for outcome IDs; this spec only references them.

### Hobby-scale variability

- **MUST NOT** require effort estimates, calendar deadlines, velocity metrics, or stakeholder-sign-off fields on the mission file; the SMART contract above already substitutes for what those would catch in an enterprise context.
- **SHOULD** tolerate long stretches between mission revision and MVP completion; an unchanged `mission_statement` is the correct state when the mission still describes what the project is doing.
- **MAY** revise the mission statement at any time before `mvp_status: stabilised`; revisions after stabilisation **MUST** carry a one-paragraph rationale in `## Source` because they redefine what the stabilised MVP was for.

## Acceptance Criteria

- [ ] `project/mission.md` exists at the repo root of every adopting project; nested or alternative locations fail validation.
- [ ] The mission frontmatter carries the eight required fields (`mission_statement`, `relevant_outcomes`, `audiences`, `verifies_via`, `time_bound`, `mvp_status`, `created`, `revised_at`) in the declared order; lints flag unknown keys and reject any calendar-date deadline field beyond `created` and `revised_at`.
- [ ] The mission body carries the four required level-2 sections (`Statement`, `Audiences`, `Verification`, `Source`) in the declared order; missing sections fail validation.
- [ ] Every audience in `audiences` resolves to an entry in the project's audience artefact and has a tailored paragraph in `## Audiences`; bare audience lists or orphaned paragraphs fail validation.
- [ ] Every outcome in `relevant_outcomes` resolves to an `O-<n>` in `project/goals.md`; an empty list or an unresolved entry fails validation.
- [ ] `verifies_via` resolves to a feature file under `project/features/` whose frontmatter declares `verifies_sprint_value` matching the named acceptance identifier; broken references fail validation.
- [ ] `time_bound` is one of `{ kind: outcome, ref: O-<n> }` or `{ kind: mvp_completion }`; any other shape fails validation, and calendar-date forms are rejected with a verbatim error.
- [ ] No post-MVP roadmap item (`mvp: false`) is in `status: active` while `mvp_status` is `defining`, `in_progress`, or `achieved`; the consuming skill rejects the transition with a verbatim error citing this spec.
- [ ] Every roadmap item with `mvp: true` carries `detail: fine` and a non-null `target_sprint`; lints fail otherwise.
- [ ] No roadmap item flips its `mvp` flag from `true` to `false` after entering `status: active`; the reverse direction (`false → true`) is permitted only before stabilisation.
- [ ] `mvp_status` only transitions along the legal path `defining → in_progress → achieved → stabilised`, with the reverse `stabilised → in_progress` permitted when an MVP item re-opens; any other transition fails validation.
- [ ] When `mvp_status: stabilised`, every roadmap item with `mvp: true` is in `status: done` and one full subsequent sprint has closed without re-opening any MVP item; the consuming skill verifies the conditions before accepting the operator's flip.
- [ ] `audience-identification` is dispatched before mission authoring on a fresh repo with no audience artefact; missing audiences block mission writes the same way they block outcome writes per the sibling `roadmap` spec.
- [ ] No mission revision after `mvp_status: stabilised` lacks a one-paragraph rationale in `## Source`; missing rationale fails validation.

## Open Questions

- Should the `verifies_via` field eventually allow multiple feature-plus-criterion pairs (a list rather than a single string), so that compound missions whose verification genuinely splits across two features remain expressible? Default: keep `verifies_via` a single `<feature-id>:acceptance-<n>` string (this repo's own `project/mission.md` ran a complete `defining → in_progress → achieved → stabilised` cycle on a single pair, so the single-pair default is validated, not merely hypothetical). Revisit when: an actual `project/mission.md` is authored whose MVP scope spans roadmap items that genuinely close in different sprints, so no single sprint can carry the one value-verifying feature, AND the operator can show the value can't collapse onto one acceptance criterion—concretely, a `mission-define` or `mission-revise` run is blocked because two distinct `verifies_sprint_value` features in two different closed sprints are both load-bearing for the same mission.
- Should the stabilisation gate's "one full subsequent sprint" condition be tunable per project (some projects might want two)? Default: keep the fixed constant of one full subsequent sprint and add no `stabilisation_soak_sprints` field (this repo's Sprint 0002 satisfied the soak for the MVP closed in Sprint 0001 with no regression, so the default has positive usage data behind it). Revisit when: a real `project/mission.md` shows a post-stabilisation regression that a single subsequent soak sprint demonstrably failed to catch—an MVP item re-opening to `status: active` in the second post-MVP sprint after `stabilised` was flipped—establishing that one sprint was too short for that project.
- Should `mvp_status: stabilised → in_progress` reversion automatically halt every post-MVP item already in `status: active`, or only block new starts? Default: keep the softer rule at §Stabilisation gate—a revert blocks new post-MVP starts but lets in-flight post-MVP items finish, with no automation to forcibly halt active items. Revisit when: a real post-stabilisation revert occurs (`stabilised → in_progress` recorded in some `project/mission.md` §Source) AND a defect post-mortem shows that letting an in-flight post-MVP item run to completion during the revert masked or amplified the regression. No revert has been observed in the portfolio so far.
- Should the spec eventually carry a machine-readable mission-coverage report (which audiences the MVP serves, with verification status per audience)? Default: continue to defer the report, and build it as a generated artefact rather than authored frontmatter when it lands (the "at least one project has run a full mission cycle" condition is already met, so the deferral rests solely on the missing downstream consumer). Revisit when: a named downstream consumer requires per-audience MVP-verification status keyed off the mission rather than the release audience artefact—concretely, when `release-skill-layer` Skill A's `## Audiences served` subsection or a future `audience-doc-author` step is changed to read `project/mission.md`'s `## Audiences` and `verifies_via` for per-audience verification status. Today no spec consumes the mission for coverage; `release-skill-layer` maps audiences from the release audience artefact, not the mission.
