# workstation

[![Build](https://github.com/nolte/workstation/actions/workflows/build-static-tests.yaml/badge.svg)](https://github.com/nolte/workstation/actions/workflows/build-static-tests.yaml)
[![Release Drafter](https://github.com/nolte/workstation/actions/workflows/release-drafter.yml/badge.svg)](https://github.com/nolte/workstation/actions/workflows/release-drafter.yml)
[![Auto-merge](https://github.com/nolte/workstation/actions/workflows/automerge.yaml/badge.svg)](https://github.com/nolte/workstation/actions/workflows/automerge.yaml)

<!--intro-start-->
This project uses [chezmoi](https://www.chezmoi.io/) to provision developer workstations from a single source tree: asdf-pinned command-line interface (CLI) tool versions, a baseline git configuration, zsh plugins, and a reusable Taskfile collection. It targets developers who want a reproducible, idempotent setup across machines.
<!--intro-end-->

## Purpose

- Provision a developer workstation deterministically with [chezmoi](https://www.chezmoi.io/): one `chezmoi init --apply` brings a fresh machine to a known state.
- Pin CLI tool versions through [asdf](https://asdf-vm.com/) so every machine resolves the same versions, kept current by Renovate.
- Ship a baseline git configuration, zsh plugins, and a reusable [Taskfile](https://taskfile.dev/) collection without per-machine hand-editing.
- This repository targets the workstation operator applying it to their own machine — not application code or project scaffolding.

## Features

### Package manager (asdf)
<!--asdf-start-->
Manage a set of extra repositories, not managed at [asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins/tree/master/plugins)
<!--asdf-end-->

### Git

<!--git-start-->
The basic Git configurations such as default branch are pre-configured.
<!--git-end-->

### zsh

<!--zsh-start-->
The local terminal is optimized with various extensions to further increase productivity.
<!--zsh-end-->

### Taskfile

<!--taskfile-start-->
A reusable [go-task/task](https://github.com/go-task/task) collection for working with the installed tools.
<!--taskfile-end-->

### GitHub MCP server

<!--github-mcp-start-->
A global GitHub [MCP](https://modelcontextprotocol.io/) server is registered for every [Claude Code](https://www.claude.com/product/claude-code) project by merging a `github` entry into `~/.claude.json`. It authenticates with a GitHub Personal Access Token read from the `GITHUB_MCP_PAT` environment variable, so no secret is stored in this repository.

Export the token **before** starting Claude Code — if the variable is unset, Claude Code fails to parse the configuration:

```sh
export GITHUB_MCP_PAT="$(gh auth token)"
```

Add that line to your shell startup file (for example `~/.zshrc`) so every session has it. The browser-based OAuth login (`claude mcp login`) is not usable here: the remote endpoint does not support OAuth dynamic client registration, which that flow requires.
<!--github-mcp-end-->

## Usage

### Initial setup

Requires [chezmoi](https://www.chezmoi.io/install/) installed on the target machine.

Before you can start, create a local configuration at `~/.config/chezmoi/chezmoi.toml` with the information required for file generation:

```toml
[data]
    git_email = "<EmailForGitConfig>"
    git_name  = "<NameForGitConfig>"
```

See the [chezmoi configuration reference](https://www.chezmoi.io/reference/configuration-file/) for details. Use this repository as your [dotfile](https://www.chezmoi.io/user-guide/setup/) source:

```sh
chezmoi init --apply --verbose https://github.com/nolte/workstation.git
```

### Day-to-day

Pull the latest changes and apply them, or preview and apply local edits:

```sh
chezmoi update
chezmoi apply
```

See the [chezmoi quick-start guide](https://www.chezmoi.io/quick-start/#start-using-chezmoi-on-your-current-machine) for more commands.

## Structure

```text
.chezmoiroot            # points chezmoi at chezmoi_config/ as the source dir
chezmoi_config/         # the chezmoi source tree applied to target machines
  dot_tool-versions     # asdf tool versions (-> ~/.tool-versions)
  dot_gitconfig.tmpl    # templated git config (-> ~/.gitconfig)
  run_onchange_*.sh     # provisioning hooks (plugins, asdf install, venvs)
  .chezmoiexternal.toml # external sources (zsh plugins, taskfile collection)
docs/                   # MkDocs documentation source
.github/                # CI workflows and repository configuration
```

Everything outside `chezmoi_config/` is repository tooling and is not delivered to target machines.

## Related repositories

- [nolte/gh-plumbing](https://github.com/nolte/gh-plumbing) — reusable GitHub workflows and Probot/Renovate presets this repository extends.
- [nolte/taskfiles](https://github.com/nolte/taskfiles) — the reusable Taskfile collection fetched onto provisioned machines.
- [nolte/vale-style](https://github.com/nolte/vale-style) — the Vale prose-style package used to lint this repository's docs.

## Development

Repo-level checks run from the repository root via the root `Taskfile.yml`:

- `task lint` — run `pre-commit` across all files.
- `task test` — lint prose with Vale against the shared `nolte/vale-style` rules.
- `task docs:build` — build the documentation site with `mkdocs build --strict`.

The `develop` branch is the integration branch; `main` is fast-forwarded only on release publish.

## Status

Early stage, personal-use. Actively maintained for a single operator's Linux workstation; interfaces may change without notice.

## License

[MIT](LICENSE) © 2026 nolte
