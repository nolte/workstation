# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A [chezmoi](https://www.chezmoi.io/) source tree that provisions developer workstations: asdf-managed CLI tool versions, git config, zsh plugins, a reusable Taskfile collection, and Python venvs. It does not ship application code — edits here change the *generated* dotfiles on machines that run `chezmoi apply` against this repo.

`.chezmoiroot` is set to `chezmoi_config`, so **`chezmoi_config/` is the actual chezmoi source directory**. Everything outside it (`docs/`, `.github/`, `README.md`, `mkdocs.yml`, `.vale.ini`, `.pre-commit-config.yaml`, `renovate.json5`) is repo-level tooling, not content delivered to target machines.

## Common commands

Chezmoi (applied on a target machine after `chezmoi init --apply https://github.com/nolte/workstation.git`):

- `chezmoi apply` — render templates and write files into `$HOME`
- `chezmoi update` — pull latest from this repo, then apply
- `chezmoi diff` — preview changes before applying

Repo-level checks (run from the workstation repo root via the root `Taskfile.yml`):

- `task lint` → `pre-commit run --all-files` (`check-yaml`, `end-of-file-fixer`, `trailing-whitespace`; see `.pre-commit-config.yaml`)
- `task test` → `vale .` (prose linting against the upstream `nolte/vale-style` package pinned in `.vale.ini`)
- `task docs` → `mkdocs serve` (requires the `docs` venv; see below)
- `task docs:build` → `mkdocs build --strict` (used by CI on release)

The root `Taskfile.yml` is the CI entry point — do not conflate it with the *generated* `~/taskfile.yaml` that a user gets after `chezmoi apply`, which pulls task includes from `~/.local/share/taskfile-collection/src` (the `nolte/taskfiles` repo, fetched via `.chezmoiexternal.toml`). Tasks like `task mkdocs:serve` and `task pre-commit:run` come from that target-machine Taskfile, not from this repo.

The MkDocs requirements exist in two places and must stay in sync: `docs/requirements.txt` (used by the docs-delivery CI workflow) and `chezmoi_config/requirements-mkdocs.txt` (installed into `~/.venvs/docs` on provisioned workstations). Renovate bumps both.

## Architecture

### chezmoi naming conventions used here

- `dot_<name>` → `~/.<name>` (e.g. `dot_gitconfig.tmpl` → `~/.gitconfig`, `dot_tool-versions` → `~/.tool-versions`)
- `*.tmpl` → Go-template rendered with data from `~/.config/chezmoi/chezmoi.toml` (required keys: `git_email`, `git_name`)
- `run_onchange_before_*` / `run_onchange_after_*` → scripts chezmoi re-runs whenever their rendered content changes. The convention for gating on *another* file is an embedded `{{ include "<file>" | sha256sum }}` comment — changing the referenced file changes the script's hash and triggers re-execution.

### Provisioning order (executed by `chezmoi apply`)

1. `run_onchange_before_install-add-plugins.sh` — idempotently adds the asdf plugins this workstation needs.
2. `run_onchange_after_install-asdf-packages.sh.tmpl` — runs `asdf install`; gated on `dot_tool-versions` via embedded hash, so tool-version bumps re-trigger it.
3. `run_onchange_prepare-py-virtual-envs.sh.tmpl` — creates `~/.venvs/development` (pre-commit, cookiecutter) and `~/.venvs/docs` (mkdocs-material); gated on both `requirements-*.txt` files.

The `requirements-*.txt` files are listed in `chezmoi_config/.chezmoiignore` so they are bundled into the source tree (and readable via chezmoi's `include`) but are not deposited into `$HOME`.

### External sources pulled at apply time

`.chezmoiexternal.toml` clones three zsh plugins under `~/.oh-my-zsh/custom/plugins/` and the taskfile collection under `~/.local/share/taskfile-collection/`. These are *not* vendored — removing them here doesn't remove them from users until they delete them locally.

### Renovate and upstream pins

- Dependencies (tool versions, Python reqs, GitHub Action refs, Vale style package) are bumped by Renovate, which extends the shared config `github>nolte/gh-plumbing//renovate-configs/common` (see `renovate.json5`).
- `renovate.json5` also teaches the asdf manager to look at `chezmoi_config/dot_tool-versions` — if you add another `*tool-versions` file, extend `asdf.managerFilePatterns` there or Renovate will not see it.
- Vale styles come from a GitHub release URL in `.vale.ini`, not from local files — do not commit to `.github/styles/` other than `Vocab/Technical` (enforced via `.gitignore`).

### CI

All workflows in `.github/workflows/` are thin wrappers that delegate to reusable workflows in `nolte/gh-plumbing`, each pinned to an immutable release tag (Renovate bumps them together):

- `build-static-tests.yaml` — pre-commit + Trivy + chain-bench on push/PR to `develop`/`main`
- `automerge.yaml` — label-driven auto-merge
- `release-drafter.yml` / `release-cd-refresh-master.yml` — drafts releases from `develop`; on publish, fast-forwards `main` to the release tag
- `release-cd-deliver-docs.yml` — on release publish, rebuilds MkDocs via `reusable-mkdocs.yaml` against `docs/requirements.txt`

The repo intentionally does **not** follow the `src/` / `custom_components/` / `.claude-plugin/` source-layout convention from the project-structure spec — `.chezmoiroot` forces the source tree into `chezmoi_config/`, and that is a deliberate, documented exception.

Similarly, `.github/settings.yml`, `release-drafter.yml`, and `boring-cyborg.yml` are single-line `_extends: gh-plumbing:...` references — repo-specific overrides go in those files, portfolio-wide defaults live in `gh-plumbing`.

## Editing guidance specific to this repo

- To add a new CLI tool: add a plugin in `run_onchange_before_install-add-plugins.sh` **and** a version in `dot_tool-versions`. Renovate keeps the version current after that.
- To add a new templated dotfile: place it under `chezmoi_config/` with a `dot_` prefix and `.tmpl` suffix if it needs `chezmoi.toml` data; otherwise no suffix.
- MkDocs pages under `docs/configurations/` pull snippets out of `README.md` and `chezmoi_config/*` via `include-markdown` / `include`. When editing README sections wrapped in `<!--X-start-->` / `<!--X-end-->` sentinels, keep the sentinels intact — they are the include boundaries.
- The `develop` branch is the integration branch; `main` is fast-forwarded only on release publish.
