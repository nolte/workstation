# Project Feature

Status: draft

## Context

Readers: repo maintainers of hobby-scale nolte projects who invoke the `feature-decompose`, `sprint-execute`, and `sprint-review` skills (the latter two read features but don't own them), plus the `feature-consistency-reviewer` agent, plus the implementing authors writing those skills and the agent against this schema.

The sibling `roadmap` spec defines what work is queued and why; the sibling `sprint` spec defines how work is grouped and shipped. Between them sits the unit of execution: a feature. A feature in the nolte portfolio is a markdown-tracked, sprint-bound, roadmap-linked piece of user-visible change. It's the smallest object that carries acceptance criteria, the smallest object that consuming Claude skills (`feature-decompose`, `sprint-execute`, the `feature-consistency-reviewer` agent) operate on, and the smallest object whose state machine is observable from the sprint level. This spec defines the on-disk shape, the schema, the lifecycle, and—uniquely on this layer—a **mandatory consistency check** against existing features and existing source code before a new feature is considered ready: hobby-scale projects accumulate latent overlap quickly, and an authoring layer that doesn't surface that overlap will let it grow unchecked.

## Goals

- Define the on-disk shape of a feature as a single markdown file at `project/features/<slug>.md`, one file per feature, with a stable frontmatter schema and required body sections so consuming skills can parse, mutate, and validate features deterministically.
- Specify the per-feature lifecycle (`draft → ready → in_progress → done`, plus `cancelled`) and the minimum gates that govern each transition so authoring, execution, and closure live in non-overlapping skill territory.
- Mandate the **consistency check**: before a feature transitions out of `draft`, it **MUST** be reviewed against the existing feature corpus and against the existing source-code surface for overlap, duplication, and drift; the check is delegated to the `feature-consistency-reviewer` agent and its findings **MUST** be recorded on the feature itself.
- Anchor every feature back to one roadmap item (`R-<n>`) and one sprint (`<NNNN>`) so traceability flows roadmap → sprint → feature → acceptance criterion → deployable artefact without gaps.
- Specify a clear acceptance-criteria contract: criteria are testable, individually checkable, and at least one criterion per sprint is required to verify the sprint's `value_statement` (the requirement is enforced sprint-side, but the **shape** of an acceptance criterion plus the **frontmatter marker** that flags the value-verifying criterion are defined here).
- Stay portfolio-reusable: every project type the portfolio supports (Claude plugin, Python application, Python library, Node / TypeScript, CLI tool, documentation-only) can adopt the schema **unmodified**: the frontmatter schema and the body sections are identical across project types, project-type-specific guidance lives only in body content (Description language, Test hook conventions), and **MUST NOT** branch the schema or section list per project type.

## Non-Goals

- Defining roadmap, sprint, or release-artefact internals. Each is owned by its own sibling spec; this spec only declares the feature-side surface and the cross-references it carries.
- Replacing test frameworks. Acceptance criteria reference tests, manual demo steps, or skill invocations; the feature spec doesn't run them, only enumerates and tracks them.
- Mandating a specific implementation language or framework. The spec is about authoring and tracking shape, not about how the feature is built.
- Substituting the `audience-identification` or audience-doc-author tooling. Feature documentation for end users belongs to the doc-author surface; the feature markdown is an internal planning artefact.
- Substituting `continuous-improvement`, `spec-drift-audit`, or `spec-readiness`. Those govern process and spec hygiene; this spec governs feature artefact hygiene.
- Replacing the `feature-consistency-reviewer` agent's logic. The agent's investigation surface (which paths to read, how to assess overlap) is its own concern; this spec only mandates **whether** the check happens and **which findings** get recorded.

## Requirements

### Directory layout and file shape

- **MUST** place every feature at `project/features/<slug>.md`, where `<slug>` is an ASCII kebab-case summary of the feature title, stable across the feature's lifetime.
- **MUST** keep exactly one markdown file per feature; feature content is never split across multiple files.
- **MUST NOT** rename a feature's slug after it leaves `draft`; renames silently break sprint and roadmap back-references.
- **SHOULD** keep `<slug>` short enough to be readable in directory listings (≤ 6 words kebab-cased is the target).

### Frontmatter schema

- **MUST** open the file with a YAML frontmatter fence carrying the following fields, in this order:
  - `id` (string, required)—pattern `F-<n>`, monotonically assigned across the project, never reused;
  - `title` (string, required)—one-line summary in the project's primary language;
  - `status` (enum, required)—one of `draft`, `ready`, `in_progress`, `done`, `cancelled`;
  - `roadmap_item` (string, required)—the `R-<n>` ID this feature decomposes; **MUST** match an entry in `project/roadmap.md`;
  - `sprint` (integer or null, required)—the sprint number this feature is scheduled for; null while the feature is `draft` and during `ready` while the feature hasn't yet been adopted by a sprint. The field transitions from null to non-null when, and only when, the feature is added to a sprint's `features` list per `spec/project/sprint/`; the canonical write authority is `sprint-plan` (when scheduling ahead of activation) or `sprint-execute` (when picking the feature up mid-active-sprint), each of which **MUST** write `feature.sprint = N` in the same operation that adds `feature.id` to `sprints/N.features`. The field **MUST NOT** be set by hand or by any other skill, and the bidirectional invariant (feature side ↔ sprint side) is the canonical check;
  - `created` (ISO date, required)—date the feature file was first written; never edited after creation;
  - `ended` (ISO date or null, required)—date the feature reached either `done` or `cancelled` (both terminal states share this field, hence the neutral name); null until the feature terminates;
  - `verifies_sprint_value` (string or null, required)—the acceptance-criterion identifier (`acceptance-<n>`) on this feature that, when checked, directly verifies the sprint's `value_statement`; non-null on at most one feature per sprint, null otherwise. The sibling `sprint` spec mandates that **at least one** feature in any closing sprint carries a non-null value here; combined with the at-most-one bound enforced feature-side (see §Acceptance-criteria contract and AC line below), the net constraint is exactly one. The write authority is `feature-decompose` (when the verifying criterion is identified at decomposition time) or `sprint-plan` (when the verifying criterion is reassigned during planning); the field **MUST** be non-null on exactly one feature per sprint **before** that sprint transitions to `review`;
  - `consistency_check` (object, required)—see §Consistency-check schema below.
- **MUST NOT** include effort estimates, points, or assignment fields beyond what's declared above; lints flag unknown keys.

### Body sections

- **MUST** carry the following level-2 sections in this order, even when empty (skills depend on stable section headings):
  - `## Description`: one to three paragraphs describing the user-visible change; written in the project's primary language; phrased from the end-user perspective when possible.
  - `## Acceptance criteria`: checklist of testable, individually checkable conditions; see §Acceptance-criteria contract for the per-item shape.
  - `## Test hooks`: explicit list of which tests, skills, or manual demo steps validate which acceptance criteria. Each entry **MUST** carry three components: (a) the `acceptance-<n>` identifier it pins to; (b) the verification mechanism (test path, skill name, CLI command, or manual procedure); (c) a status token from the closed vocabulary `pending` (not yet executed), `passing` (executed and successful), `skipped` (intentionally not executed for this run with rationale), or `failing` (executed and unsuccessful). Format: `- **acceptance-<n>** — <mechanism> — <status>`. A hook is "resolved" for the lifecycle gate (see §Lifecycle and gates) only when its status is `passing` or `skipped`.
  - `## Consistency notes`: populated by the consistency check (see §Consistency check); summarises the agent's findings and the resolution chosen for each finding.
  - `## Risks`: known unknowns, blockers, or workarounds; **MAY** be empty for low-risk features.
- **MAY** carry additional level-2 sections (`## Open questions`, `## References`) when the feature genuinely needs them; **MUST NOT** alter the order of the required sections to accommodate optional ones.

### Acceptance-criteria contract

- **MUST** state every acceptance criterion as a markdown checkbox bullet (`- [ ] …`), one criterion per bullet, atomic (a single check), testable (a reviewer can mark done/not done without ambiguity).
- **MUST** assign a stable per-feature criterion identifier visible in the bullet text using the pattern `acceptance-<n>` (for example `- [ ] **acceptance-1** Sensor reading appears within 5 s after device discovery`); the identifier is what the `verifies_sprint_value` frontmatter field references and what `## Test hooks` entries pin against.
- **MUST NOT** carry process-internal criteria ("PR approved", "merged to develop"); acceptance criteria are user-visible behaviour, not workflow gates.
- **SHOULD** target three to seven criteria per feature; one is suspicious (under-specified), more than ten suggests the feature should be split.
- **MUST NOT** rely on prose markers in bullet text to identify the value-verifying criterion; the only authoritative signal is the `verifies_sprint_value` frontmatter field. Authors **MAY** mention the verifying role in human-readable prose for reader clarity, but consuming skills **MUST** parse the frontmatter, not the bullet text.

### Consistency check

- **MUST** perform a consistency check before a feature transitions from `draft` to `ready`. The canonical performer is the `feature-consistency-reviewer` agent (per `spec/claude/agent-management/`); until that agent ships, an operator-driven manual pass following the same investigation surface and the same recording shape **MAY** satisfy this requirement, **provided** the manual pass is recorded with `agent_version: manual-<YYYY-MM-DD>` in `consistency_check` and the `## Consistency notes` section names the operator who performed it. Once the agent ships, the manual fallback **MUST** be removed and any feature that subsequently relies on the fallback constitutes a workflow-health finding. The check (whether agent or manual) reviews:
  - the existing feature corpus under `project/features/` for overlapping or contradicting features;
  - the existing source-code surface (the project's primary source roots, identified by repo conventions) for already-implemented behaviour that the new feature would re-implement; the source-code surface follows whichever primary-source layout `spec/project/project-structure/` recognises for the consuming repo, so for a Claude Code plugin repo the surface explicitly **includes** `skills/<name>/SKILL.md`, `agents/<name>.md`, and `.claude-plugin/plugin.json` (the plugin's executable behaviour lives in those files even though they're markdown), the same way it includes `src/`, `src/<component>/`, `custom_components/<name>/`, `playbooks/`, and `roles/` for repos using those layouts;
  - the spec corpus under `spec/` for prior decisions that constrain this feature.
- **MUST** record the agent's findings on the feature in the `## Consistency notes` body section and as a structured `consistency_check` frontmatter object with these fields:
  - `performed_at` (ISO date, required)—when the check ran;
  - `agent_version` (string, optional)—agent identifier so re-runs can be compared;
  - `findings` (list, required)—each finding with `kind` (`overlap`, `duplication`, `drift`, `prior-art`, `clean`), `target` (file path or feature ID it relates to), and `resolution` (`merge-into <id>`, `supersede <id>`, `split-out <ids>`, `proceed`, `revisit-after <event>`).
- **MUST** treat any finding with `kind: overlap` or `kind: duplication` as a blocker for the `draft → ready` transition unless its `resolution` is `proceed` with an explicit one-paragraph rationale in `## Consistency notes`.
- **MUST** re-run the consistency check when, while the feature is in `ready` or `in_progress`, any of the following occur: the `## Description` section is changed by more than typo-level wording, an acceptance criterion is added or its core wording (excluding the checkbox state) is altered, the `roadmap_item` or `sprint` frontmatter field is changed, or a feature with overlapping scope is added or removed elsewhere in `project/features/`. The re-run **MUST** preserve historical findings (append a new `findings` block dated by `performed_at`, don't overwrite). Cosmetic edits (typo fixes, formatting, link target normalisation, the bullet checkbox flipping for an existing acceptance criterion) **MUST NOT** trigger a re-run.
- **MUST** record findings inline on the feature (in `consistency_check` frontmatter and `## Consistency notes`), never as a separate `.audits/feature-consistency/` artefact. Unlike the transient `skill-review`/`agent-review` plans under `.audits/` (which `spec/claude/review-plan/` defines as deletable-on-completion working documents), consistency findings are durable, append-only feature metadata that gate the `draft → ready` lifecycle, so they live on the feature itself.
- **MUST** keep the `consistency_check` object inline on the feature regardless of `findings` history length; externalising it to a separate file is settled-against, because findings gate the lifecycle and have to stay diffable on the feature itself.

### Lifecycle and gates

- **MUST** transition `status` only along these paths: `draft → ready`, `ready → in_progress`, `in_progress → done`, and `cancelled` reachable from any of `draft`, `ready`, `in_progress`. Direct `draft → in_progress`, `draft → done`, and `ready → done` are forbidden because they skip the consistency-check or the execution gate.
- **MUST** require, before `draft → ready`: a non-empty `## Description`, at least one acceptance-criterion bullet, a populated `consistency_check` frontmatter, and a populated `## Consistency notes` section.
- **MUST** require, before `ready → in_progress`: a non-null `sprint` value matching either the currently `active` sprint or the lowest-numbered `planned` sprint per the sibling `sprint` spec, and the feature listed in that sprint's `features` field. When the matched sprint is `planned`, `sprint-execute` automatically promotes it to `active` as a side effect of this transition (per `sprint` §Lifecycle); when another sprint is already `active`, the transition is rejected.
- **MUST** require, before `in_progress → done`: every acceptance criterion checked, every test hook resolved (status `passing` or `skipped` per §Body sections), and the feature's sprint either `active` or `review`.
- **MAY** transition to `cancelled` at any point before `done`; the transition **MUST** carry a one-paragraph rationale, placed in `## Risks` when the feature was cancelled before the consistency check ran (status `draft` at cancellation), and in `## Consistency notes` when the feature was cancelled at or after `ready` because the consistency check or a later finding revealed the feature shouldn't be built.

### Roadmap, sprint, and source linkage

- **MUST** ensure `roadmap_item` resolves to an `R-<n>` declared in `project/roadmap.md`; a feature with no roadmap link is invalid even when the originating motivation is "internal hardening"—declare a roadmap item for the hardening intent first.
- **MUST** ensure that, when `sprint` is non-null, the referenced sprint file's `features` frontmatter list contains this feature's `id`; the back-reference is bidirectional and validated on every sprint and feature change.
- **MUST** allow `## Test hooks` to point at source paths, test paths, or skill names; the spec doesn't constrain which mechanism a hook chooses, only that the mechanism is named explicitly so the consistency check can locate prior art.
- **MAY** carry references to external issues (GitHub issues, project boards) in `## Description` or `## References`; those references are documentation, never authoritative.

### Hobby-scale variability

- **MUST NOT** require effort estimates, due dates, or velocity tracking on features; like roadmap items and sprints, features are author-paced.
- **SHOULD** tolerate long stretches between consistency check and execution; if more than two sprints pass without execution, the consistency check **SHOULD** be re-run before `ready → in_progress`.
- **MAY** mark a feature `cancelled` when the consistency check reveals that an existing feature already covers it; cancellation with `resolution: merge-into <id>` is a first-class outcome, not a failure state.
- **MUST** apply the identical schema and lifecycle to documentation-only features (a how-to page, a runbook); the no-per-type-branching rule (Goal 6) admits no doc-feature exception, and a doc feature remains an internal planning artefact carrying the same acceptance-criteria, test-hook, and consistency contract as any other feature.

## Acceptance Criteria

- [ ] Every feature exists as exactly one file at `project/features/<slug>.md` with a stable slug; no slug is renamed after the feature leaves `draft`.
- [ ] Every feature's frontmatter carries the nine schema fields (`id`, `title`, `status`, `roadmap_item`, `sprint`, `created`, `ended`, `verifies_sprint_value`, `consistency_check`) in the declared order; lints flag unknown keys and reject `closed` as a frontmatter field name (the field is named `ended`).
- [ ] Every feature's body carries the five required level-2 sections (`Description`, `Acceptance criteria`, `Test hooks`, `Consistency notes`, `Risks`) in the declared order; missing sections fail validation.
- [ ] Every acceptance-criterion bullet uses the `**acceptance-<n>**` identifier pattern and is atomic, testable, and user-visible (not a workflow gate); no bullet carries an inline value-verifier marker (the only authoritative signal is the `verifies_sprint_value` frontmatter field).
- [ ] Every `## Test hooks` entry pins to an `acceptance-<n>` identifier, names a verification mechanism, and carries a status token from the closed vocabulary (`pending`, `passing`, `skipped`, `failing`); entries lacking any of the three components fail validation.
- [ ] No feature transitions `draft → ready` without a populated `consistency_check` frontmatter object whose `findings` array is non-empty (a clean run still records `kind: clean`) and a populated `## Consistency notes` section.
- [ ] No feature transitions `ready → in_progress` while another sprint than the one referenced by its `sprint` field is `active`; the gate is enforced by `sprint-execute` and triggers the planned-to-active promotion when applicable.
- [ ] No feature transitions `in_progress → done` while any acceptance-criterion bullet remains unchecked or any test hook's status is `pending` or `failing`.
- [ ] No direct transitions occur for `draft → in_progress`, `draft → done`, or `ready → done`; transition-graph violations are rejected by the consuming skills.
- [ ] Every `consistency_check.findings` entry whose `kind` is `overlap` or `duplication` either has a non-`proceed` resolution or carries a one-paragraph rationale in `## Consistency notes` justifying the `proceed` choice.
- [ ] At most one feature per sprint carries a non-null `verifies_sprint_value`; sprints that close with zero or more than one such feature fail sprint-side validation per the sibling `sprint` spec.
- [ ] Every cancelled feature carries a one-paragraph rationale: in `## Risks` when cancelled in `draft`, in `## Consistency notes` when cancelled in `ready` or `in_progress`. Missing rationale fails validation.
- [ ] No feature schema branches per project type; the schema and the body section list are identical across Claude plugin, Python application, Python library, Node / TypeScript, CLI tool, and documentation-only repos.

## Open Questions

- Cross-feature dependencies (`F-7 needs F-3 first`) carry no schema field today; sprint membership plus the `roadmap_item` link express the only sequencing that exists. Revisit when a real feature chain appears that sprint ordering can't express—concretely, two features land where the later one's `## Acceptance criteria` or `## Test hooks` reference a behaviour the earlier one introduces, both are scheduled into the SAME `sprint` (so sprint ordering can't sequence them), AND the consistency check can't capture the ordering as a `prior-art`/`revisit-after` finding. The first such occurrence unblocks adding `depends_on` to BOTH the feature schema and the sibling `sprint` spec in lockstep (the sprint spec carries no dependency or ordering field today, so a feature-side-only addition would be a one-sided invariant).
