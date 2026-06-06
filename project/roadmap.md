# Roadmap

This file is the queue governed by `spec/project/roadmap/` (canonical-language
spec at `spec/project/roadmap/en.md` in `nolte/claude-shared`). It lists every
planned, in-flight or accepted change to `nolte/workstation`.

- Detail-level invariants (`fine` vs `coarse`) are enforced by
  `nolte-shared:roadmap-refine`.
- Lifecycle changes — adds, retargets, status flips, MVP-flag flips — go
  through `nolte-shared:roadmap-planner`; do not hand-edit items below in
  another context.
- Item IDs follow the monotonic `R-<n>` shape and are never reused, even
  after deletion. The next ID for an addition is `R-1`; do not reset the
  counter when items are removed.

Phase headings (`## Phase 1 — …`) are documentation, not schema. The queue
starts without phases; add them here when phases become useful.

## Queue

<!-- Items are added by `roadmap-planner`. Do not edit by hand. -->

### R-1 — One-command provisioning of a complete developer workstation

```yaml
id: R-1
title: One-command provisioning of a complete developer workstation
detail: fine
outcomes: [O-1]
target_sprint: 1
mvp: true
status: proposed
```

The first end-to-end provisioning path: a `workstation-operator` runs a single
`chezmoi init --apply` on a fresh machine and reaches a complete, ready-to-use
developer environment (asdf-pinned CLI toolchain, the curated zsh setup, a git
baseline, and the MkDocs / pre-commit virtualenvs) without any follow-up manual
install. This item carries the sprint-1 value-verifying feature.

Intended features:

- [ ] One-command provisioning to a complete developer environment
