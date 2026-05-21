# Audiences — workstation

<!--
Produced via the `audience-identify` skill, following
spec/project/audience-identification/.
Do not add audiences without first declaring the bounded context below.
-->

## Bounded context

The `nolte/workstation` repository is a [chezmoi](https://www.chezmoi.io/)
source tree that provisions developer workstations (`chezmoi init --apply` /
`chezmoi update`). It delivers:

- asdf-pinned CLI tool versions (`dot_tool-versions`),
- a baseline git configuration (`dot_gitconfig.tmpl`),
- zsh plugins (oh-my-zsh customs, cloned via `.chezmoiexternal.toml`),
- a reusable Taskfile collection (cloned to
  `~/.local/share/taskfile-collection/`),
- two Python virtual environments: `~/.venvs/development` (pre-commit,
  cookiecutter) and `~/.venvs/docs` (mkdocs-material).

Renovate keeps tool versions, Python requirements, GitHub Action refs and the
Vale style package in sync with upstream releases.

**Boundary:** `chezmoi_config/` — declared as the chezmoi source directory via
`.chezmoiroot` — is the content that lands in target machines via
`chezmoi apply`. Everything outside `chezmoi_config/` (`docs/`, `.github/`,
`Taskfile.yml`, `mkdocs.yml`, `.vale.ini`, `.pre-commit-config.yaml`,
`renovate.json5`) is repo-care tooling and is **not** delivered to target
machines.

**Explicitly out of scope:** application code; project-specific scaffolds
(those live in dedicated cookiecutter-template repositories); IDE-/editor-
specific configurations (VSCode, JetBrains); secrets, SSH keys and cloud
credentials; OS-level setup (package manager installs, firewall, drivers) —
chezmoi only provisions user-space dotfiles and asdf-managed CLI tools.

## Audiences

Each entry: label, relationship category, interaction surface, expectation,
documentation `track` (`user-docs` or `developer-docs` per
spec/project/docs-audience-tracks/), open questions, `confirmed` or `assumed`,
criticality (primary / secondary / peripheral). Mark a whole category as
`none — <reason>` when it does not apply.

### Direct consumers

- **`workstation-operator`** — _category_: direct-consumer · _surface_:
  chezmoi CLI on the target machine; the generated dotfiles
  (`~/.tool-versions`, `~/.gitconfig`, `~/.zshrc` with plugins,
  `~/taskfile.yaml`); zsh as the interactive shell; `task <name>` invocations
  on the provisioned machine · _expects_: idempotent setup on repeated apply,
  deterministic version pinning (reproducibility across machines),
  non-breaking incremental updates driven by Renovate · _track_: `user-docs`
  · _status_: `confirmed` (nolte personally) · _criticality_: primary
  - Open questions:
    - Is the target OS Linux only, or also macOS?
    - Is the operator audience strictly single-user (nolte only), or does any
      adjacent collaborator apply this repo directly on their own workstation?

### Operators

- **`none — chezmoi runs as a one-shot tool on the workstation-operator's
  own machine; there is no long-running service to operate separately.`**

### Contributors / maintainers

- **`workstation-maintainer`** — _category_: contributor/maintainer ·
  _surface_: GitHub (PR reviews, Release Drafter, auto-merge labels), local
  git, `task lint`, `task test`, `task docs`, `task docs:build`,
  `pre-commit`, `vale` · _expects_: `pre-commit run --all-files` and Vale
  green; `mkdocs build --strict` succeeds; Renovate PRs auto-merge for
  non-breaking bumps; Release Drafter accumulates PR titles on `develop`;
  release publish fast-forwards `main` to the release tag · _track_:
  `developer-docs` · _status_: `confirmed` · _criticality_: primary
  - Open questions:
    - Are external contributions explicitly welcome (CLA / DCO /
      contribution-guide expectations)?

### Governing parties

- **`nolte/gh-plumbing`** — _category_: governing · _surface_: `_extends:`
  references in `.github/settings.yml`, `release-drafter.yml`,
  `boring-cyborg.yml`; `uses: nolte/gh-plumbing/.github/workflows/...@v1.x.y`
  in workflow files; the `github>nolte/gh-plumbing//renovate-configs/common`
  preset in `renovate.json5` · _expects_: workstation follows the portfolio
  branching model (`develop` → `main` with fast-forward on release publish),
  label-driven auto-merge, and the pinned reusable-workflow refs · _track_:
  `developer-docs` · _status_: `confirmed` · _criticality_: primary
  - Open questions: none.

- **`nolte/vale-style`** — _category_: governing · _surface_: `.vale.ini`
  package release URL · _expects_: prose under `docs/` and `README.md`
  respects the shared vocabulary and style rules · _track_:
  `developer-docs` · _status_: `confirmed` · _criticality_: secondary
  - Open questions: none.

- **`nolte/claude-shared`** — _category_: governing · _surface_: spec corpus
  under `spec/project/...` loaded by `nolte-shared:*` skills as input for
  future `project/` artefacts (mission, roadmap, features); the local
  `spec/` directory in this repo is currently empty · _expects_: once
  `project/` artefacts exist, they conform to the shared spec corpus
  (audience, mission, roadmap, feature-decompose, project-structure) ·
  _track_: `developer-docs` · _status_: `confirmed` · _criticality_:
  secondary (rises to primary once `project/` artefacts are authored)
  - Open questions: none.

- **`chezmoi` (twpayne/chezmoi)** — _category_: governing · _surface_:
  `.chezmoiroot`, `dot_*` naming convention, `*.tmpl` Go-template suffix,
  `run_onchange_before_*` / `run_onchange_after_*` script naming,
  `.chezmoiexternal.toml` for cloned external sources, `.chezmoiignore` for
  source-tree filtering · _expects_: the source tree obeys chezmoi's layout
  conventions; template data is read from `~/.config/chezmoi/chezmoi.toml`
  (`git_email`, `git_name`); idempotent re-runs on hash change · _track_:
  `developer-docs` · _status_: `confirmed` · _criticality_: primary
  - Open questions: none.

### Indirect audiences

- **`downstream-tooling-consumers`** — _category_: indirect · _surface_:
  the generated dotfiles, virtual environments and `$PATH` entries on the
  provisioned workstation, consumed by tools that run *inside* that
  environment (cookiecutter against `~/.venvs/development`; editors and IDEs
  reading `~/.gitconfig`; project-local `task` runs that include
  `~/.local/share/taskfile-collection/` includes) · _expects_: the dotfile
  layout, venv paths and `$PATH` shape stay stable across applies; tools
  pinned in `dot_tool-versions` remain available · _track_: `user-docs` ·
  _status_: `assumed` · _criticality_: peripheral
  - Open questions:
    - Which downstream tools depend on `~/.venvs/development` vs
      `~/.venvs/docs` in practice?

## Open questions (cross-cutting)

- Target OS scope: Linux only, or also macOS? Affects every direct-consumer
  expectation and the `dot_tool-versions` selection.
- External adopters / forks: actively discouraged, tolerated, or simply not
  marketed? Determines whether a separate `external-adopter` direct-consumer
  audience needs to be added at the next revisit.
- External contributions: are PRs from outside `nolte` welcome, and if yes,
  under what contribution-guide expectations (CLA, DCO, style)?

## Revisit triggers

- A long-running service becomes part of the setup → Operators category
  turns real and needs explicit audiences.
- `project/` artefacts (mission, goals, roadmap, features) are authored →
  `nolte/claude-shared` rises from secondary to primary criticality.
- The repository is explicitly opened for external adopters / forks →
  `external-adopter` is added as a second direct-consumer audience.
- A critical asdf plugin, Python virtualenv requirement, or reusable
  workflow include is dropped or added → re-check operator and
  indirect-audience expectations.
- The boundary between repo-tooling and chezmoi-source (`chezmoi_config/`
  vs the rest) changes → both `workstation-operator` and
  `workstation-maintainer` expectations need to be re-evaluated.
