---
id: F-1
title: One-command provisioning to a complete developer environment
status: ready
roadmap_item: R-1
sprint: 1
created: 2026-06-06
ended: null
verifies_sprint_value: acceptance-1
consistency_check:
  agent_version: manual-2026-06-06
  findings:
    - kind: clean
      target: project/features/
      resolution: proceed
---

## Description

A `workstation-operator` provisions a fresh developer machine to a complete,
ready-to-use state from the chezmoi source tree with a single command. After
`chezmoi init --apply`, the operator has the asdf-pinned CLI toolchain on
`$PATH`, the curated zsh experience, a baseline git configuration, and the
MkDocs and pre-commit Python virtualenvs — without any follow-up manual install.
A later `chezmoi update` keeps that state current, and the resulting `$HOME`
layout is identical across every machine provisioned from the same source.

## Acceptance criteria

- [ ] **acceptance-1** On a freshly provisioned machine, `chezmoi init --apply` completes and yields a working developer environment (asdf-pinned CLIs on `$PATH`, zsh with the configured plugins, a baseline git config, and the MkDocs and pre-commit virtualenvs) with no follow-up manual install.
- [ ] **acceptance-2** Re-running `chezmoi update` on an existing machine applies the latest dotfile and tool-version state without breaking running shells or in-flight project work.
- [ ] **acceptance-3** Across two machines provisioned from the same source tree, the resulting `$HOME` layout (venv paths, the taskfile-collection includes, the asdf-managed `$PATH`) is identical.

## Test hooks

- **acceptance-1** — manual: provision a fresh VM, run `chezmoi init --apply nolte`, then verify the toolchain, zsh, git, and venvs — pending
- **acceptance-2** — manual: run `chezmoi update` on a configured machine and confirm running shells and in-flight work survive — pending
- **acceptance-3** — manual: diff the `$HOME` layout across two freshly provisioned machines — pending

## Consistency notes

Manual consistency pass performed by operator `nolte` on 2026-06-06 (the
`feature-consistency-reviewer` agent fallback per the feature spec). This is the
first feature under `project/features/`, so there is no overlapping or
contradicting feature; the chezmoi source tree carries no already-implemented
behaviour this feature would re-implement; and no spec decision constrains it.
Finding recorded as `clean` / `proceed`.

## Risks

- The acceptance criteria are verified manually; there is no automated
  provisioning smoke test yet. A container-image CI smoke test for acceptance-1
  would harden the verification.
