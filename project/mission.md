---
mission_statement: nolte/workstation lets the workstation-operator bring any developer machine to an identical, reproducible state from a single chezmoi source tree, so every machine and the downstream tooling running on it behave the same.
relevant_outcomes: [O-1, O-2, O-3]
audiences: [workstation-operator, downstream-tooling-consumers, workstation-maintainer]
verifies_via: F-1:acceptance-1
time_bound:
  kind: mvp_completion
mvp_status: defining
created: 2026-06-06
revised_at: null
---

## Statement

nolte/workstation lets the `workstation-operator` bring any developer machine to
an identical, reproducible state from a single chezmoi source tree, so every
machine — and the downstream tooling running on it — behaves the same.

- **Specific** — a chezmoi source tree that provisions a complete developer
  workstation (asdf-pinned CLIs, zsh, git baseline, reusable Taskfiles, and the
  pre-commit / cookiecutter / MkDocs virtualenvs) for the audiences below.
- **Measurable** — anchored in `verifies_via: F-1:acceptance-1`; when one
  `chezmoi init --apply` on a fresh machine yields a working environment with no
  follow-up manual install, the mission is observably achieved.
- **Achievable** — the MVP is roadmap item `R-1` (one-command provisioning),
  one sprint of hobby-scale work, building on the chezmoi source that already
  exists in the repository.
- **Relevant** — anchored in `relevant_outcomes: [O-1, O-2, O-3]` from
  `project/goals.md`: one-command provisioning (O-1), non-breaking updates
  (O-2), and an identical `$HOME` layout across machines (O-3). O-4
  (Renovate-driven auto-merge) is a maintainer concern, supported but not
  mission-bearing.
- **Time-bound** — anchored in `time_bound: { kind: mvp_completion }`; the
  mission is bound to the moment `mvp_status` reaches `achieved`, not a calendar
  date.

## Audiences

### workstation-operator

The operator runs `chezmoi init --apply` on a fresh machine and `chezmoi update`
on an existing one. The MVP delivers them a single-command path from a bare
machine to a complete, working developer environment, and a non-breaking update
path that preserves running shells and in-flight work.

### downstream-tooling-consumers

Cookiecutter, editors, and project-local `task` runs expect every dotfile, venv
path, and `$PATH` entry exactly where the source tree places it. The MVP
delivers them an identical `$HOME` layout across every machine provisioned from
the same source, so tooling behaves the same everywhere.

### workstation-maintainer

The maintainer keeps the source tree and its pins current. The MVP delivers them
a reproducible provisioning path they can validate on a fresh machine; the
Renovate-driven auto-merge loop (O-4) that further eases pin maintenance is
supported but explicitly post-MVP.

## Verification

The mission is verified by feature [F-1 `one-command-provisioning`](features/one-command-provisioning.md),
acceptance criterion **acceptance-1**, which reads verbatim:

> On a freshly provisioned machine, `chezmoi init --apply` completes and yields
> a working developer environment (asdf-pinned CLIs on `$PATH`, zsh with the
> configured plugins, a baseline git config, and the MkDocs and pre-commit
> virtualenvs) with no follow-up manual install.

The feature carries `verifies_sprint_value: acceptance-1`, so Sprint 0001 — the
sprint that contains F-1 — is the sprint that closes the mission's MVP. When that
checkbox flips to checked (observed manually on a freshly provisioned machine),
the mission's Measurable letter is satisfied.

## Source

- **Audience artefact:** [`AUDIENCES.md`](../AUDIENCES.md).
- **Outcomes source:** [`project/goals.md`](goals.md), outcomes O-1, O-2, O-3.
- **Verifying-feature source:** [`project/features/one-command-provisioning.md`](features/one-command-provisioning.md),
  feature ID `F-1`, criterion `acceptance-1`.
- **Author:** operator `nolte` via a manual `mission-define` pass, 2026-06-06.
