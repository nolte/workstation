---
mission_statement: >-
  nolte/workstation provisions a complete, reproducible developer environment
  for the workstation-operator from a single `chezmoi init --apply`, so that the
  operator — and the downstream-tooling-consumers running inside the resulting
  $HOME — find every CLI, dotfile, virtualenv and $PATH entry in place with no
  manual follow-up.
relevant_outcomes: [O-1]
audiences: [workstation-operator, downstream-tooling-consumers]
verifies_via: F-1:acceptance-5
time_bound:
  kind: outcome
  ref: O-1
mvp_status: defining
created: 2026-06-05
revised_at: null
---

## Statement

nolte/workstation provisions a complete, reproducible developer environment for
the `workstation-operator` from a single `chezmoi init --apply`, so that the
operator — and the `downstream-tooling-consumers` running inside the resulting
`$HOME` — find every CLI, dotfile, virtualenv and `$PATH` entry in place with no
manual follow-up.

SMART decomposition:

- **Specific** — the `mission_statement` frontmatter field: one-shot provisioning
  of a complete developer environment for the named `workstation-operator` and
  `downstream-tooling-consumers`.
- **Measurable** — the `verifies_via` field (`F-1:acceptance-5`): when that
  acceptance criterion is checked, the mission is measurably achieved.
- **Achievable** — the MVP scope is being shaped (`mvp_status: defining`) around
  roadmap item `R-1`, which decomposes into the mission-verifying feature `F-1`;
  no roadmap item is flagged `mvp: true` yet, so the achievability bound is not
  yet asserted on the queue.
- **Relevant** — the `relevant_outcomes` field (`O-1`): the foundational
  one-shot-provisioning outcome from `goals.md`.
- **Time-bound** — the `time_bound` field (`{ kind: outcome, ref: O-1 }`): the
  mission is bound to the achievement of outcome `O-1`, per the outcome-shaped
  bound the mission spec inherits from the sibling sprint spec.

## Audiences

- **`workstation-operator`** — The operator brings up any developer machine —
  laptop, VM, or a future replacement — to an identical, ready-to-work state by
  running `chezmoi init --apply` exactly once. The MVP delivers the asdf-pinned
  CLI toolchain on `$PATH`, the configured zsh experience, a rendered baseline
  git config, the reusable Taskfile collection, and the pre-commit / cookiecutter
  and MkDocs virtualenvs, with no second command and no manual install step. A
  re-applied machine converges with no changes, so the operator trusts the setup
  to be reproducible across every machine that adopts it.

- **`downstream-tooling-consumers`** — Tools that run *inside* the provisioned
  environment — cookiecutter against `~/.venvs/development`, editors reading
  `~/.gitconfig`, and project-local `task` runs that include
  `~/.local/share/taskfile-collection/` — inherit a stable `$HOME` layout from
  the same single provisioning run. The MVP guarantees that the venv paths, the
  dotfile locations, and the asdf-managed `$PATH` are present and identical right
  after the operator's first apply, so these consumers find what they expect
  without any per-machine adjustment.

## Verification

The mission is verified by feature `F-1`
(`project/features/clean-machine-provisioning.md`), whose `verifies_sprint_value`
points at `acceptance-5`. Criterion text, verbatim:

> **acceptance-5** The environment is ready for work after that single run with
> no follow-up manual install, and a second `chezmoi apply` is a no-op (no
> `run_onchange_*` script re-fires, exit status zero).

When that criterion is checked — exercised by the containerised provisioning
tests specified in `spec/containerised-provisioning-tests/` — the mission is
measurably achieved.

## Source

- **Audience artefact:** `AUDIENCES.md` (last-commit SHA
  `459dc6a2fede8ce7e04dd8c8b9b5ecdebe066370` at time of writing).
- **Goals consulted:** `project/goals.md` — outcome `O-1` (one-shot provisioning
  reaches a complete developer environment).
- **Authored by:** operator `nolte` via the `mission-define` skill, commit-pending
  (P3 of the planning cascade tracked in `nolte/workstation#80`).
