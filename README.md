# workstation

[![Build](https://github.com/nolte/workstation/actions/workflows/build-static-tests.yaml/badge.svg)](https://github.com/nolte/workstation/actions/workflows/build-static-tests.yaml)
[![Release Drafter](https://github.com/nolte/workstation/actions/workflows/release-drafter.yml/badge.svg)](https://github.com/nolte/workstation/actions/workflows/release-drafter.yml)
[![Auto-merge](https://github.com/nolte/workstation/actions/workflows/automerge.yaml/badge.svg)](https://github.com/nolte/workstation/actions/workflows/automerge.yaml)

<!--intro-start-->
A [chezmoi](https://www.chezmoi.io/) source tree that provisions a developer workstation from a single `chezmoi init --apply`: asdf-pinned command-line interface (CLI) tool versions, a baseline git configuration, zsh plugins, and a reusable Taskfile collection. For developers who want a reproducible, idempotent setup across machines.
<!--intro-end-->

## Purpose

- Provision a developer workstation deterministically with [chezmoi](https://www.chezmoi.io/): one `chezmoi init --apply` brings a fresh machine to a known state.
- Pin CLI tool versions through [asdf](https://asdf-vm.com/) so every machine resolves the same versions, kept current by [Renovate](https://docs.renovatebot.com/).
- Ship a baseline git configuration, zsh plugins, and a reusable [Taskfile](https://taskfile.dev/) collection without per-machine hand-editing.
- Intended for the workstation operator applying it to their own machine — not application code or project scaffolding.

## Usage

Requires [chezmoi](https://www.chezmoi.io/install/) installed on the target machine.

### Initial setup

Create a local configuration at `~/.config/chezmoi/chezmoi.toml` with the data required for file generation:

```toml
[data]
    git_email = "<EmailForGitConfig>"
    git_name  = "<NameForGitConfig>"
```

See the [chezmoi configuration reference](https://www.chezmoi.io/reference/configuration-file/) for details. Then use this repository as your [dotfile](https://www.chezmoi.io/user-guide/setup/) source:

```sh
chezmoi init --apply --verbose https://github.com/nolte/workstation.git
```

### Day-to-day

Pull the latest changes and apply them, or preview local edits before applying:

```sh
chezmoi update   # pull latest from this repo, then apply
chezmoi apply    # render templates and write files into $HOME
chezmoi diff     # preview changes before applying
```

See the [chezmoi quick-start guide](https://www.chezmoi.io/quick-start/#start-using-chezmoi-on-your-current-machine) for more commands.

### Local development

Repo-level checks run from the repository root via the root `Taskfile.yml` (needs the [go-task](https://taskfile.dev/) CLI on your `PATH`):

```sh
task lint        # run pre-commit across all files
task test        # lint prose with Vale (nolte/vale-style)
task docs:build  # build the documentation site (mkdocs build --strict)
```

## Features

### Package manager (asdf)
<!--asdf-start-->
Adds asdf plugin repositories that aren't listed in the official [asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins/tree/master/plugins) index.
<!--asdf-end-->

### Git

<!--git-start-->
Sets basic Git defaults, such as the default branch, out of the box.
<!--git-end-->

### zsh

<!--zsh-start-->
Adds zsh plugins that make the interactive shell faster to work in.
<!--zsh-end-->

### Taskfile

<!--taskfile-start-->
A reusable [go-task/task](https://github.com/go-task/task) collection for working with the installed tools.
<!--taskfile-end-->

### GitHub MCP server

<!--github-mcp-start-->
Registers a global GitHub [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server for every [Claude Code](https://www.claude.com/product/claude-code) project by merging a `github` entry into `~/.claude.json`. It authenticates with a GitHub Personal Access Token read from the `GITHUB_MCP_PAT` environment variable, so no secret is stored in this repository.

Export the token **before** starting Claude Code — if the variable is unset, Claude Code fails to parse the configuration. The snippet below reads it from the authenticated [GitHub CLI](https://cli.github.com/) (run `gh auth login` first):

```sh
export GITHUB_MCP_PAT="$(gh auth token)"
```

Add that line to your shell startup file (for example `~/.zshrc`) so every session has it. The browser-based OAuth login (`claude mcp login`) is not usable here, because that flow requires OAuth dynamic client registration, which the remote endpoint doesn't support.
<!--github-mcp-end-->

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

## Status

Early stage, personal-use. Actively maintained for a single operator's Linux workstation; interfaces may change without notice.

## License

[MIT](LICENSE) © 2026 nolte
