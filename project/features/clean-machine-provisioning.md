---
id: F-1
title: Clean-machine provisioning reaches the complete developer environment
status: draft
roadmap_item: R-1
sprint: null
created: 2026-06-05
ended: null
verifies_sprint_value: acceptance-5
consistency_check:
  performed_at: 2026-06-05
  agent_version: feature-consistency-reviewer@542b93f
  findings:
    - kind: prior-art
      target: spec/containerised-provisioning-tests/en.md
      resolution: proceed
    - kind: clean
      target: n/a
      resolution: proceed
---

## Description

On a freshly provisioned Linux machine, the `workstation-operator` runs
`chezmoi init --apply https://github.com/nolte/workstation.git` exactly once and
is left with a complete, ready-to-work developer environment: the asdf-pinned
CLI toolchain on `$PATH`, the configured zsh experience, a rendered baseline git
config, the reusable Taskfile collection, and the pre-commit / cookiecutter and
MkDocs Python virtualenvs.

No second command and no manual install step are needed to reach a working
state. Re-running `chezmoi apply` on the already-provisioned machine changes
nothing — the environment converges in a single run and stays converged.

This feature asserts that user-visible end state. The mechanism that proves it
inside a throwaway container is owned by `spec/containerised-provisioning-tests/`;
this feature references that mechanism rather than redefining it.

## Acceptance criteria

- [ ] **acceptance-1** After a single `chezmoi init --apply` on a clean Linux
  machine, every CLI pinned in `~/.tool-versions` resolves via
  `asdf which <tool>` to an existing, executable path.
- [ ] **acceptance-2** `~/.gitconfig`, `~/.tool-versions`, and `~/taskfile.yaml`
  exist with rendered template values — the operator's git name/email
  substituted, `~/.tool-versions` byte-matching
  `chezmoi_config/dot_tool-versions`, and `~/taskfile.yaml` referencing the
  `~/.local/share/taskfile-collection/` include path.
- [ ] **acceptance-3** The `~/.venvs/development` and `~/.venvs/docs` virtualenvs
  exist and contain at least `pre-commit` and `mkdocs-material` respectively.
- [ ] **acceptance-4** The three external zsh plugins under
  `~/.oh-my-zsh/custom/plugins/` and the `~/.local/share/taskfile-collection/`
  checkout exist as non-empty git checkouts.
- [ ] **acceptance-5** The environment is ready for work after that single run
  with no follow-up manual install, and a second `chezmoi apply` is a no-op (no
  `run_onchange_*` script re-fires, exit status zero).

## Test hooks

- **acceptance-1** — containerised provisioning Bats `@test` asserting
  `asdf which <tool>` for every tool read from `chezmoi_config/dot_tool-versions`
  (per `spec/containerised-provisioning-tests/`) — pending
- **acceptance-2** — containerised provisioning Bats `@test` asserting the three
  dotfiles exist with rendered values — pending
- **acceptance-3** — containerised provisioning Bats `@test` asserting both
  venvs contain their sample packages — pending
- **acceptance-4** — containerised provisioning Bats `@test` asserting the
  zsh-plugin and taskfile-collection checkouts are non-empty — pending
- **acceptance-5** — containerised provisioning Bats `@test` asserting the second
  `chezmoi apply` re-fires no `run_onchange_*` script — pending

## Consistency notes

The `feature-consistency-reviewer` agent (`@542b93f`, 2026-06-05) reviewed this
feature against the three mandated surfaces and surfaced two findings, both
resolved `proceed`. Neither is a `draft → ready` blocker (no `overlap` /
`duplication`).

**prior-art — `spec/containerised-provisioning-tests/en.md` — proceed.** The
acceptance criteria restate that spec's §"Provisioning post-conditions" and every
test hook cites it as the verification mechanism. This is the intended direction
of dependency: the feature describes the user-visible "what the operator gets",
the spec defines "how the container proves it". They are different artefact kinds
on different layers and cannot subsume one another, so `merge-into` / `supersede`
are wrong; the spec is a committed draft the feature deliberately builds on, so
`revisit-after` does not apply. Recorded for audit completeness.

**clean — proceed.** The feature corpus is empty (F-1 is the first feature), so
no feature-corpus overlap is possible. The `chezmoi_config/` source surface was
scanned for all five criteria — the `run_onchange_*` scripts, `dot_tool-versions`,
`dot_gitconfig.tmpl`, the venv-prepare script, and `.chezmoiexternal.toml` are the
provisioning *implementation* the feature legitimately asserts the end state of,
not behaviour the feature re-implements. No spec MUST is contradicted.

Soft observation (not a finding, not a `draft → ready` concern): the test hooks
are all `pending` and reference Bats `@test` blocks that the container-test spec
mandates but that do not yet exist under `tests/`. That is an `in_progress → done`
hook-status concern, tracked by the containerised-provisioning-tests work, not a
consistency concern.

## Risks

- The verification mechanism (containerised provisioning Bats tests) is specified
  but not yet implemented, so all test hooks are `pending`. The feature cannot
  reach `done` until that test surface exists; this couples F-1's closure to the
  delivery of `spec/containerised-provisioning-tests/`.
- `spec/project/project-structure/` is absent from this repo, so the source-root
  resolution for the consistency check fell back to the `CLAUDE.md` convention
  (`.chezmoiroot = chezmoi_config`). Sound for this repo today, but a future
  project-structure spec would be the authoritative source-layout oracle.
