# Containerised Provisioning Tests

Status: draft

## Context

This repository is a [chezmoi](https://www.chezmoi.io/) source tree that provisions developer workstations. Its real "build artefact" is the state produced on a target machine by `chezmoi init --apply https://github.com/nolte/workstation.git`: a populated `~/.tool-versions` with asdf-managed CLIs, templated dotfiles (`~/.gitconfig`, `~/taskfile.yaml`), two Python virtualenvs under `~/.venvs/`, three zsh plugins under `~/.oh-my-zsh/custom/plugins/`, and a checkout of the shared taskfile collection under `~/.local/share/taskfile-collection/`.

The existing CI pipeline (`.github/workflows/build-static-tests.yaml`) covers prose linting (Vale), pre-commit, Trivy, and chain-bench. None of these exercise the actual provisioning path — they validate the *sources*, not the *result*. As a consequence, three classes of regression can land unnoticed on `develop` today:

- A bumped tool version in `chezmoi_config/dot_tool-versions` no longer has a working asdf plugin or release artefact.
- A change to one of the `run_onchange_*` scripts breaks installation on a clean machine, even though the rendered file still passes `check-yaml`.
- A change to `.chezmoiexternal.toml` references a moved or renamed upstream repo, breaking new-machine bootstraps without affecting machines that already have the external cached.

Because the only safe place to exercise this end-to-end is a throwaway environment, the test path must live inside a container. The container is the boundary that protects the developer's host `$HOME` and the GitHub-hosted runner's user FS from being mutated by a chezmoi run intended only as a test.

## Goals

- Verify that `chezmoi apply` against the contents of this repo produces the expected on-disk state on a clean Linux environment — not just that the templates render.
- Make the verification automatic on every change that can plausibly affect the provisioning path (push/PR to `develop`, push to `main`).
- Catch upstream drift (asdf plugins, release artefacts, external repos) on a fixed weekly cadence without code changes.
- Give a developer the exact same verification locally via a single `task` invocation, with no extra setup beyond having Docker.
- Keep all side effects of a test run inside the container; nothing on the host or runner is mutated.
- Assert idempotency: a second `chezmoi apply` on an already-provisioned state must be a no-op.

## Non-Goals

- macOS provisioning verification. The repo is Linux-focused today; a macOS path would need a separate spec and a non-container runner.
- Performance, throughput, or wall-clock benchmarks of the apply process.
- Verifying the *contents* of the `nolte/taskfiles` collection that `.chezmoiexternal.toml` clones. That repo owns its own tests.
- Verifying the `release-cd-deliver-docs.yml` or `release-cd-refresh-master.yml` workflows. Those concern documentation delivery and release fast-forwarding, not provisioning.
- Prescribing concrete Dockerfile contents, exact shell scripts, or assertion-tool choices. This spec defines *what* must be verified and *under which constraints*; the implementation PR makes those concrete.
- Replacing `build-static-tests.yaml`. The new pipeline is additive — pre-commit, Vale, Trivy, and chain-bench remain their own jobs.

## Requirements

- **MUST**
  - All test execution MUST happen inside a container built from a `Dockerfile` checked into this repo (proposed path: `tests/Dockerfile`). The base image MUST be a pinned Ubuntu LTS tag (or a digest), and the pin MUST be discoverable by Renovate so it is bumped together with the rest of the toolchain.
  - The container MUST install only the minimal system prerequisites needed to run `chezmoi`, `asdf`, and `python`. Every other tool listed in `chezmoi_config/dot_tool-versions` MUST be installed *by the provisioning run itself*, not pre-baked into the image — otherwise the test would not exercise the path it claims to cover.
  - The test entrypoint MUST run `chezmoi init` against the local working tree of this repo (not a remote clone of GitHub) so a PR's changes are tested before they exist on `develop`.
  - The test entrypoint MUST run `chezmoi apply` a first time, assert the post-conditions in §"Provisioning post-conditions", then run `chezmoi apply` a *second* time and assert that no `run_onchange_*` script fired again and that exit status is zero.
  - The `chezmoi.toml` consumed by the container MUST be a test fixture stored under `tests/` with dummy values for `git_email` and `git_name`. The container MUST NOT read `~/.config/chezmoi/chezmoi.toml` from the host or runner.
  - The container MUST run without `--privileged`, without mounting the Docker socket, and without bind-mounting the developer's `$HOME` or any user-owned directory outside the repo checkout. The repo checkout itself MAY be mounted read-only or `COPY`'d in at build time, but the container's `$HOME` MUST be a fresh directory created inside the image.
  - The new pipeline MUST be wired into `.github/workflows/` so it runs on push to `develop`, push to `main`, pull requests targeting `develop`, and a weekly schedule matching the existing static-tests cron (`cron: '16 0 * * 1'`).
  - The root `Taskfile.yml` MUST gain a `test:container` target that builds and runs the *same* image with the *same* entrypoint as the workflow uses. Local and CI runs MUST share that single code path; a regression in one MUST be reproducible in the other without changes.
  - The placeholder `tests/.gitkeep` MUST be removed in the same PR that introduces real test artefacts under `tests/`.
  - The assertion layer MUST be written in [Bats](https://github.com/bats-core/bats-core). Each `MUST`-level post-condition in §"Provisioning post-conditions" MUST correspond to its own `@test` block, so failures are reported one-per-assertion rather than as a single shell exit. The Bats version MUST be pinned in the repo in a Renovate-discoverable form (either as an asdf-managed plugin used only inside the test image, or as a distro-package version pin in the Dockerfile), so the test-engine version is bumped in lockstep with the rest of the toolchain.
  - Test failure modes MUST be distinguishable from infrastructure failure. A failed `@test` block (assertion: `asdf which kubectl` doesn't resolve, `~/.venvs/docs` missing) surfaces as a Bats test failure with a non-zero overall exit and per-test diagnostics; a failed image build, a network error pulling an asdf plugin, or a chezmoi crash inside the entrypoint MUST surface separately (e.g. via a distinct exit code, a distinct workflow step boundary, or a clearly tagged log marker) so a red pipeline immediately tells the operator which failure class to triage.

- **SHOULD**
  - The Dockerfile SHOULD live under `tests/` alongside the fixtures and entrypoint script so the whole test surface is one folder.
  - The base image pin SHOULD be a digest, not a floating tag, so an upstream image rebuild cannot silently change behaviour between two runs of the same commit.
  - The pipeline SHOULD emit Bats' TAP output (or the equivalent Bats-native pretty format) into the CI log and SHOULD upload the TAP stream as a workflow artefact, so a failure is debuggable from CI alone — every `@test` and the artefacts it inspected (tool list, dotfile list, venv contents sample) appear by name in the log without rerunning locally.
  - Each `MUST`-level assertion in §"Provisioning post-conditions" SHOULD be exercised independently so a single failure does not mask the rest.
  - The container SHOULD be runnable on `linux/amd64`. Additional architectures MAY be added later but are not required by this spec.
  - The weekly cron run SHOULD post its result through the same notification path as other scheduled jobs in this repo (no special-case alerting).

- **MAY**
  - The pipeline MAY cache the container image layers in the GitHub Actions cache, provided the cache key incorporates the Dockerfile hash so a Dockerfile change forces a rebuild.
  - The pipeline MAY include a smoke step that runs a representative `task` from `~/taskfile.yaml` after apply, to verify that the templated Taskfile resolves its includes against `~/.local/share/taskfile-collection/`.
  - Future PRs MAY extend the spec with a distro matrix (e.g. Ubuntu LTS + Fedora) — out of scope here, but the implementation SHOULD NOT make a matrix harder than swapping the base image.

## Provisioning post-conditions

The following on-disk state inside the container is what a successful run asserts. The implementation PR turns this into concrete checks; the spec fixes the contract.

- For every tool listed in `chezmoi_config/dot_tool-versions`, `asdf which <tool>` MUST resolve to a path that exists and is executable. The list of tools to assert is read from the file, not hard-coded in the test — drift in `dot_tool-versions` must not require a parallel update of the assertions.
- `~/.gitconfig` MUST exist and MUST contain the dummy `git_email` / `git_name` values from the test `chezmoi.toml` fixture (proving template substitution actually ran).
- `~/.tool-versions` MUST exist and MUST match the bytes of `chezmoi_config/dot_tool-versions`.
- `~/taskfile.yaml` MUST exist and MUST reference `~/.local/share/taskfile-collection/` somewhere in its include graph.
- `~/.venvs/development/` and `~/.venvs/docs/` MUST exist as valid Python virtualenvs. Each MUST contain at least one sample package from its respective `requirements-*.txt`: `pre-commit` for development, `mkdocs-material` for docs.
- The three external zsh plugin directories declared in `.chezmoiexternal.toml` MUST exist as non-empty git checkouts under `~/.oh-my-zsh/custom/plugins/`.
- `~/.local/share/taskfile-collection/` MUST exist as a non-empty git checkout.
- Each `run_onchange_*` script in `chezmoi_config/` MUST have left an observable side effect on the first apply (asdf plugins added, asdf install completed, venvs created). The second apply MUST NOT re-run them, which the test verifies via the `chezmoi apply --verbose` output or an equivalent chezmoi-native signal.

## Relationship to existing repository conventions

- `CLAUDE.md` calls out two structural facts that this spec inherits without restating them: the `.chezmoiroot = chezmoi_config` indirection, and the deliberate duplication of `requirements-development.txt` / `requirements-mkdocs.txt` between `docs/` (used by the docs-delivery workflow) and `chezmoi_config/` (used at apply time). The test MUST consume the `chezmoi_config/` copies, since those are what `chezmoi apply` actually installs.
- All `.github/workflows/` files in this repo are thin wrappers over `nolte/gh-plumbing` reusable workflows, pinned to immutable release tags and bumped by Renovate together. The new provisioning-test workflow SHOULD follow the same pattern *only if* a suitable reusable workflow exists upstream; otherwise it MAY be a self-contained workflow, with the explicit acknowledgement that it is the first non-reusable workflow in this repo.

## Acceptance Criteria

- [ ] `tests/` contains a `Dockerfile`, a test `chezmoi.toml` fixture, and an entrypoint script. `tests/.gitkeep` is removed.
- [ ] A new workflow under `.github/workflows/` runs the container on push/PR to `develop`, push to `main`, and the cron schedule `16 0 * * 1`.
- [ ] The root `Taskfile.yml` exposes `task test:container`, which builds and runs the same image and entrypoint as the workflow.
- [ ] A clean local invocation of `task test:container` exits 0 on the current `develop` tip.
- [ ] During a green run, `asdf which <tool>` succeeds for every tool listed in `chezmoi_config/dot_tool-versions`.
- [ ] During a green run, `~/.gitconfig`, `~/.tool-versions`, and `~/taskfile.yaml` exist; `~/.gitconfig` contains the dummy fixture values; `~/.tool-versions` is byte-identical to `chezmoi_config/dot_tool-versions`.
- [ ] During a green run, `~/.venvs/development/` contains `pre-commit` and `~/.venvs/docs/` contains `mkdocs-material`.
- [ ] During a green run, the three zsh plugin directories under `~/.oh-my-zsh/custom/plugins/` and `~/.local/share/taskfile-collection/` exist as non-empty git checkouts.
- [ ] The assertion suite lives under `tests/*.bats`, every `MUST`-level entry in §"Provisioning post-conditions" maps to exactly one `@test` block, and a single failing `@test` does not skip the remaining assertions.
- [ ] A second consecutive `chezmoi apply` exits 0 and triggers no `run_onchange_*` re-execution.
- [ ] The container run does not bind-mount the host `$HOME`, does not require `--privileged`, and does not mount the Docker socket.
- [ ] `build-static-tests.yaml` still runs unchanged on the same triggers; nothing in the new pipeline replaces or short-circuits its jobs.
- [ ] A deliberate breaking change in `chezmoi_config/dot_tool-versions` (e.g. a non-existent tool version) makes the new pipeline fail; reverting it makes it green again.
- [ ] The base image pin and the Bats version pin both appear in Renovate's dashboard, and update PRs for either can be opened by Renovate without manual config tweaks.

## Open Questions

- Should the image be built and pushed to GHCR for sharing between the cron job and the per-PR job, or rebuilt from scratch in each job? The trade-off is registry maintenance versus build time.
- For the second apply, is `chezmoi apply --verbose` parsing reliable enough to detect re-execution of `run_onchange_*` scripts, or do we need a chezmoi-native marker (e.g. comparing state hashes)? This influences whether the test depends on a CLI output format that could change between chezmoi releases.
- Is a single-distro (Ubuntu LTS) baseline enough, or should the first iteration already include a second distro to prevent ubuntu-specific drift? Current decision: single-distro now, matrix later — revisit after the first three months of green runs.
