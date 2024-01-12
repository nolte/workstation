# Workstation configuration


<!--intro-start-->
This project use [twpayne/chezmoi](https://github.com/twpayne/chezmoi) to set up a wide variety of developer systems.
<!--intro-end-->

## Features

### Package manager (asdf)
<!--asdf-start-->
Manage a set of extra Repositories, not managed at [asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins/tree/master/plugins)
<!--asdf-end-->

### Git

<!--git-start-->
The basic Git configurations such as default branch are pre-configured.  
<!--git-end-->

### zsh

<!--zsh-start-->
The local terminal optimised with various extensions to further increase productivity.
<!--zsh-end-->

### Taskfile

<!--taskfile-start-->
reusable [go-task/task](https://github.com/go-task/task) pool, for works with the installed tools. More Information about the Different Tasks.
<!--taskfile-end-->

## Setup

Before you can start, create a local configuration at `~/.config/chezmoi/chezmoi.toml` with some Information, required for the file generation process.

```toml
[data]
    git_email = "<EmailForGitConfig>"
    git_name  = "<NameForGitConfig>"
```
more information at [chezmoi.io](https://www.chezmoi.io/reference/configuration-file/).

Use this Repository as [dotfile](https://www.chezmoi.io/user-guide/setup/) basement.

```sh
$ chezmoi init --apply --verbose https://github.com/nolte/workstation.git
```

## Usage

Useful Commands [chezmoi.io](https://www.chezmoi.io/quick-start/#start-using-chezmoi-on-your-current-machine)

```sh
chezmoi update
```

```sh
chezmoi apply
```
