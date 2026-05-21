# Vision

`nolte/workstation` lets the `workstation-operator` bring up any developer
machine — laptop, VM, future replacement — to an identical, reproducible state
from a single chezmoi source tree. One `chezmoi init --apply` bootstraps the
asdf-pinned CLI toolchain, a baseline git config, a curated zsh experience,
the reusable Taskfile collection, and the pre-commit / cookiecutter / MkDocs
virtualenvs needed for everyday work; `chezmoi update` keeps that state
current as Renovate flows upstream releases through `develop`. Inside that
environment, `downstream-tooling-consumers` (cookiecutter, editors,
project-local `task` runs) find every dotfile, venv path and `$PATH` entry
exactly where they expect it, so the workstation behaves the same across
every machine that adopts it.

## Outcomes

- **O-1** — On a freshly provisioned machine, the operator runs
  `chezmoi init --apply` once and reaches a complete developer environment
  (asdf-pinned CLIs, zsh with the configured plugins, git baseline, MkDocs
  and pre-commit virtualenvs) without follow-up manual installs.
  _(audience: workstation-operator)_

- **O-2** — On an existing machine, the operator runs `chezmoi update` and
  receives the latest dotfile and tool-version state without breaking running
  shells, in-flight project work, or already-cached venv state.
  _(audience: workstation-operator)_

- **O-3** — Across every machine that runs `chezmoi apply`, the resulting
  `$HOME` layout (venv paths, the `~/.local/share/taskfile-collection/`
  includes, the asdf-managed `$PATH`) is identical, so cookiecutter, editors,
  and project-local `task` runs find what they expect without per-machine
  adjustments. _(audience: downstream-tooling-consumers)_

- **O-4** — A Renovate-driven tool, plugin or Action bump moves from
  proposed PR to merged `develop` with a single auto-mergeable change, so the
  maintainer keeps every pin current without manual CI workarounds.
  _(audience: workstation-maintainer)_
