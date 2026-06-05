# Audience Identification

Status: draft

## Context
<!-- Why does this spec exist? What problem, user need, or constraint drives it? -->

Software modules and projects are consumed, operated, constrained, or observed by multiple audience groups—users, operators, downstream integrators, maintainers, security, compliance, business stakeholders, indirect end users, and more. Without a disciplined way to enumerate which audiences apply to a *bounded context* (a specific module, service, library, or project), decisions about documentation depth, API surface, release cadence, SLAs, and security posture are made against the author's private assumptions rather than against the actual audience set. This spec defines a repeatable method to identify and characterize the audiences of any scoped context so that downstream artifacts (READMEs, specs, threat models, release notes, SLAs) can reference an authoritative audience list instead of reinventing one each time.

## Goals
<!-- What this spec aims to achieve. Bullet points, outcome-oriented. -->
- Provide a consistent procedure for enumerating the audiences of a defined context
- Ensure every identified audience is characterized by its relationship to the context (consume, operate, extend, govern, …)
- Produce an artifact that other specs (`readme-structure`, `pull-request-workflow`, future threat-modeling specs, …) can point to
- Make audience identification repeatable and reviewable rather than the output of a single author's gut feel
- Surface unknown or assumed audiences explicitly so they can be validated or retired

## Non-Goals
<!-- Explicitly out of scope. Prevents creep. -->
- Defining marketing personas or demographic segmentation
- Prescribing how to engage or communicate with audiences once identified
- Producing a permanent, organization-wide master audience list (this spec is scoped per context, not per org)
- Threat modeling—audiences feed into it but aren't equivalent to threat actors
- Mandating a single artifact format for every context. The canonical default for a stand-alone bounded context is `AUDIENCES.md` at the root of that context (see Requirements §Artifact location), but small or sub-module contexts MAY embed the list in a README section or an ADR; this spec ratifies the default rather than forbidding the alternatives

## Requirements
<!-- Use RFC 2119 keywords: MUST, SHOULD, MAY. One atomic requirement per bullet. -->
- **MUST** begin with a written declaration of the bounded context: what the module or project *is*, where its boundaries run, and what's explicitly outside
- **MUST** enumerate audiences under the following relationship categories, and state "none" with a reason when a category doesn't apply:
  - **Direct consumers**: who invokes the context's interface (humans, other services, downstream libraries)
  - **Operators**: who runs, deploys, monitors, or hosts the context in production or test
  - **Contributors / maintainers**: who modifies the code or authors its content
  - **Governing parties**: legal, compliance, security, architecture review, business stakeholders with approval or constraint authority
  - **Indirect audiences**: parties affected by the context without interacting with it directly (for example end users behind a consumed service)
- **MUST** record for every listed audience:
  - a short label
  - the relationship category
  - the interaction surface (API, CLI, config, docs, dashboard, incident channel, …)
  - what the audience expects or needs from the context
  - the documentation `track` the audience maps to (one of `user-docs` or `developer-docs`, per `spec/project/docs-audience-tracks/` §Audience-to-track mapping); the portfolio-baseline default (`user` → `user-docs`; `contributor` / `operator` / `release-manager` → `developer-docs`) is the starting point and is overridable per project with a recorded one-line rationale
  - any open question or assumption where information is missing
- **MUST** tag every audience as `confirmed` (validated with a real representative or an authoritative source) or `assumed` (inferred by the author)
- **MUST** produce the audience list before downstream artifacts that claim an audience are written (READMEs, specs, threat models, release notes, SLAs, documentation tracks per `spec/project/docs-audience-tracks/`, …), so those artifacts can reference it rather than restate it; the documentation-tracks artefact is one of the downstream consumers and the per-audience `track` field is the consuming surface
- **MUST** apply this spec portfolio-wide: any repository that produces an audience-claiming downstream artifact (README, mission, roadmap, docs tracks, release notes, SLAs) MUST have an audience artifact. There is no per-repository opt-in or opt-out; opt-out is per relationship category only (record "none" with a reason). The artifact's *format* scales with context size (see §Artifact location), but the method itself is never skipped
- **SHOULD** rank audiences by criticality to the success of the context (primary / secondary / peripheral)
- **SHOULD** store the audience artifact at `AUDIENCES.md` at the root of the bounded context as the canonical default; for small modules or sub-contexts where a stand-alone file is overkill, a README section ("## Audiences" or "## Intended consumers") or an ADR is an acceptable alternative. Whichever location is chosen, the artifact lives **alongside** the context it describes—not in a central registry—so consuming specs (for example `mission`, `roadmap`, `release-notes-audience-analysis`, `release-skill-layer`, and tooling like `github-issue-templates-apply`) can locate it deterministically; the list isn't exhaustive, and `spec-drift-audit` is the canonical detector for newly-added consumers that cite the artefact. There is no minimum size below which the method is skipped; for contexts too small to warrant their own artifact, fold the audience list into the parent context's artifact or a README section. The format scales with size, the method doesn't
- **SHOULD** revisit the audience list whenever the context's scope materially changes—new public API, new deployment target, new regulated data class, new stakeholder
- **SHOULD** version the audience artifact through the repository's git history; there is no separate version field or per-release snapshot. The revision cadence is event-driven per the §revisit-triggers bullet above, and `spec-drift-audit` detects when the artifact has drifted from the actual interaction surface
- **MAY** link each audience entry to the specs, docs, or SLAs produced for it, so coverage is visible
- **MAY** subdivide audiences further by geography, organizational unit, or tenancy when such distinctions change the expected deliverable

## Acceptance Criteria
<!-- Testable, checkable conditions. A reviewer should be able to mark each as done/not done. -->
- [ ] A worked example exists applying the method to one concrete artifact in this repository (for example the `nolte-shared` plugin or one of its skills)
- [ ] The `readme-structure` spec references this spec where it speaks of "intended consumers"
- [ ] An audience list produced under this spec contains at least one audience per applicable relationship category, or records "none" with a reason for any category it omits
- [ ] Every audience entry distinguishes `confirmed` from `assumed`
- [ ] Every audience entry carries a `track` field whose value is `user-docs` or `developer-docs` (or an extension value declared by a project-type-specific spec); the portfolio-baseline default is applied unless a one-line override rationale is recorded inline
- [ ] The bounded context is declared in writing before any audience is listed
- [ ] The `spec-drift-audit` skill can flag a module whose documented audiences no longer match its actual interaction surface
- [ ] Every stand-alone bounded context that has produced an audience artifact ships it as `AUDIENCES.md` at the context root, OR the chosen alternative location (a README section "## Audiences" / "## Intended consumers" or an ADR) is justified by the context's small size or by pre-existing repo precedent. Verifiable by `find . -name AUDIENCES.md -not -path './node_modules/*' -not -path './.venv/*'` plus a grep of README files for the section headings

## Open Questions
<!-- Unresolved decisions, known unknowns, things that need a stakeholder answer. -->
- How does this spec interact with future threat-modeling, privacy-impact, or SLA specs that will also consume the same audience list? Unblock when the first spec on the security/privacy/SLA axis that consumes the audience artifact is drafted under `spec/project/` (for example `spec/project/threat-modeling/`, `spec/project/privacy-impact/`, or `spec/project/sla/` whose Requirements cite the audience artifact). Measurable: `grep -rl 'audience' spec/project/{threat-modeling,privacy-impact,sla}/` returns a hit. Then wire the concrete bidirectional cross-reference; the `spec-drift-audit` "newly-added consumers that cite the artefact" clause (see the §Artifact-location requirement) surfaces the dependency. No external upstream link applies—this is an internal portfolio authoring event, not a Claude Code platform dependency.
