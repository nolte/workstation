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

_(empty — items are added via `nolte-shared:roadmap-planner`)_
