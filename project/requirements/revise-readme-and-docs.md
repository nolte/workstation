# Requirements — Revise README.md and the MkDocs docs tree

<!--
Produced via the `requirements-elicit` skill, following
spec/project/requirements-elicitation/ (canonical source read from the
upstream nolte-shared plugin at
/home/nolte/repos/github/claude-shared/spec/project/requirements-elicitation/en.md;
the spec is not yet vendored into this repo's spec/ tree — see the open risk
below and the precedent set by project/requirements/claude-json-interpreter.md).
`c_d` is an uncertainty proxy (self-consistency-derived), not a calibrated
probability. A requirement is `confirmed` only after an explicit teach-back or
an authoritative operator answer.
-->

## Bounded context

- **What:** Revise `README.md` and the MkDocs docs tree (`docs/en`, `docs/de`) so
  they are current, spec-conformant (`readme-structure`, `mkdocs-structure`),
  readable, and DE/EN-complete. Concretely: a **Quick-start command section** that
  leads with the chezmoi lifecycle, an **audience-appropriate intro**, and a
  **verified list of portfolio (related-repository) dependencies**. Approach:
  audit-first, then revise from the findings.
- **For whom:** The **operator-as-adopter** — a developer (including the future
  maintainer) who applies this repository to a fresh machine via
  `chezmoi init --apply`. The docs lead with the provisioning path and are
  self-onboarding; contributor / repo-maintenance material stays secondary.
- **Out of scope (confirmed):** Moving any content out of `chezmoi_config/`
  (the chezmoi source tree per `.chezmoiroot`); editing target-machine-delivered
  content or provisioning logic; the generated `~/taskfile.yaml`. This branch
  touches repo-level docs surfaces only (`README.md`, `docs/**`, `mkdocs.yml`
  nav) plus the GitHub repo metadata (topics + description).

## Understanding KPI

- Thresholds: `τ_low = 0.4`, `τ_high = 0.8`, self-consistency `k = 2`, question budget = `5` (spec defaults; unchanged)
- `U_gate = min_d c_d` over required dimensions = **0.82**
- Termination: `saturation` — the four binding, specification-uncertain
  decisions (audience, key-command shape/placement, DE/EN parity target, GitHub
  metadata scope) were lifted by authoritative operator answers; the remaining
  dimensions are evidence-backed by the researched plan (`.resume/revise-readme-and-docs/plan.md`),
  `CLAUDE.md`, and the verified repo sources. No remaining candidate question has
  positive net EVPI. The one item that previously held `edge_cases` at exactly
  `τ_high` (Quick-start-vs-Purpose ordering) was resolved against the
  `readme-structure` audit; the binding dimension is now `acceptance_criteria`
  (0.82), whose remaining slack is verification-time, not understanding, gap.

### Gap matrix

| Dimension | Applicable | `c_d` | Uncertainty source | Evidence event |
|---|---|---|---|---|
| `functional` | yes | 0.88 | interpretation | Operator answers (audience = adopter; Quick-start section leading with chezmoi lifecycle); plan §1/§4; teach-back on audience + Quick-start confirmed |
| `non_functional` | yes | 0.86 | specification | Plan §5 invariants (`readme-structure` order + ≤200-line budget, `mkdocs build --strict`, lektorat/Vale); `CLAUDE.md` |
| `constraints` | yes | 0.90 | interpretation | `CLAUDE.md` + plan §5: `.chezmoiroot`=`chezmoi_config`, include sentinels, requirements-file sync, Vale local-only/non-gating |
| `domain_objects` | yes | 0.88 | interpretation | Enumerated & verified: `README.md`, `docs/{en,de}`, `mkdocs.yml` nav, related repos, GitHub topics/description |
| `actors` | yes | 0.85 | specification | Authoritative operator answer "Operator-as-adopter" + teach-back confirmed |
| `acceptance_criteria` | yes | 0.82 | specification | Operator answers + plan §4 step 7: `task docs:build --strict` green, EN Vale/lektorat pass, DE structural parity, metadata aligned, PR handoff |
| `edge_cases` | yes | 0.85 | interpretation | `k=2` self-consistency: divergent break-modes (structural conflict / translation drift / sentinel breakage / req-file desync) converge to a known, enumerable set; the Quick-start-vs-Purpose conflict is now resolved against `readme-structure` (R1/R4) |
| `scope_boundaries` | yes | 0.85 | specification | Operator answer "GitHub metadata: check + align, in this PR"; out-of-scope set confirmed in bounded context |

## Requirements

- **R1** — The revised `README.md` SHALL lead with the chezmoi lifecycle
  (`init --apply` → `update`/`apply`, `diff`) by keeping `## Purpose` tight and
  placing `## Usage` (commands up front) immediately after it — before the
  optional `## Features` section. It SHALL NOT introduce a commands section above
  `## Purpose`, so the `readme-structure` required-section order is preserved.
  - _dimension_: `functional` · _status_: `confirmed` · _source_: "Purpose führt, Usage-Befehle vor" (revised from the earlier "Quick-Start-Sektion oben" after the `readme-structure` audit surfaced the ordering conflict; see R4)
- **R2** — The `README.md` and docs SHALL be written for the operator-as-adopter (a
  developer, including the future maintainer, applying this repo to a fresh
  machine), leading with the provisioning path and staying self-onboarding, WHILE
  contributor / repo-maintenance material remains secondary.
  - _dimension_: `actors` · _status_: `confirmed` · _source_: "Operator-as-adopter"
- **R3** — The `Related repositories` list SHALL enumerate exactly the nolte-portfolio
  dependencies actually referenced by the repo — `nolte/gh-plumbing`,
  `nolte/taskfiles`, `nolte/vale-style` — verified against `.chezmoiexternal.toml`,
  the `renovate.json5` `extends`, and `.vale.ini`; third-party zsh plugins SHALL be
  excluded from that list.
  - _dimension_: `domain_objects` · _status_: `confirmed` · _source_: operator goal §1 "verified, up-to-date list of portfolio dependencies" + verified sources
- **R4** — The revised `README.md` SHALL conform to `readme-structure`: required
  sections in order (`Purpose` → `Usage` → `Structure` → `Related repositories` →
  `Status` → `License`), `Purpose` as the first `##`, the ≤200-line budget, absolute
  portfolio links, and a relative `LICENSE` link. The ordering conflict raised by
  R1's earlier form was resolved in favour of the spec (see R1) — no deviation
  remains.
  - _dimension_: `non_functional` · _status_: `confirmed` · _source_: `readme-structure` en.md audit + operator decision "Purpose führt, Usage-Befehle vor"
- **R5** — EN SHALL be canonical: WHEN `docs/en` is revised, `docs/de` SHALL be brought
  to a faithful translation preserving structural parity (same pages, same nav),
  and Vale SHALL NOT be chased to green on `de.md` at the cost of correct German.
  - _dimension_: `functional` / `edge_cases` · _status_: `confirmed` · _source_: "EN kanonisch, DE als Übersetzung"
- **R6** — The pass SHALL check the GitHub repo **topics** and **description** against
  the revised tagline/scope and align them, landing the change at the correct owner
  (`.github/settings.yml` `_extends` target, or directly on the repo if set there),
  as part of this PR.
  - _dimension_: `scope_boundaries` · _status_: `confirmed` · _source_: "Ja, prüfen + angleichen"
- **R7** — WHEN the revision is complete, `task docs:build` (`--strict`) SHALL pass, a
  lektorat + Vale pass SHALL be run on the revised EN prose, and the work SHALL hand
  off to `pull-request-create`.
  - _dimension_: `acceptance_criteria` · _status_: `confirmed` · _source_: plan §4 step 7–8 (adopted approach)
- **R8** — The revision SHALL keep every `<!--X-start-->`/`<!--X-end-->` include
  sentinel intact, SHALL NOT move content out of `chezmoi_config/`, and SHALL keep
  `docs/requirements.txt` and `chezmoi_config/requirements-mkdocs.txt` in sync if
  either is touched.
  - _dimension_: `constraints` · _status_: `confirmed` · _source_: `CLAUDE.md` + plan §5 invariants
- **R9** — Before editing, the pass SHALL run the read-only audits (`readme-structure`
  audit, `docs-freshness-checker`, an audience check, then `lektorat`/Vale on the
  revised text) and collect findings under `.audits/`.
  - _dimension_: `acceptance_criteria` (approach) · _status_: `assumed` · _source_: plan §3/§4 (audit-first design; not separately re-confirmed in interview)

## Surviving assumptions / open risks

- **Spec not vendored locally.** The requirements-elicitation methodology spec is
  read from the upstream nolte-shared plugin, not from this repo's `spec/` tree
  (only `spec/containerised-provisioning-tests/` exists). Same caveat the prior
  `claude-json-interpreter.md` artifact recorded; see memory
  `workstation-planning-vale-caveats`.
- **R1/R4 resolved (was an open risk).** The `readme-structure` audit confirmed a
  `## Quick start` heading above `## Purpose` would break the required-section
  order; the operator chose the spec-conformant realisation ("Purpose führt,
  Usage-Befehle vor" — tight `Purpose`, `Usage` with commands up front directly
  after it). No deviation remains.
- **R9 is `assumed`.** The audit-first sequence and exact auditor set come from the
  plan, not an explicit operator confirmation; safe to proceed but re-openable.
- **GitHub metadata ownership (R6).** Topics/description may be owned by the
  `.github/settings.yml` `_extends: gh-plumbing:` pointer (Probot settings app) or
  set directly on the repo — the correct write location is only determined during
  execution (`gh repo view` + inspecting the extends target).
- **DE Vale (R5).** `de.md` content can trip the local, non-gating Vale run; German
  correctness wins over Vale-green (see `workstation-planning-vale-caveats`).
