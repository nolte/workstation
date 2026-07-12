#!/usr/bin/env bash

set -e
set -u
set -o pipefail

asdfAddPluginIfNotExists() {
    PLUGIN_NAME=$1
    PLUGIN_REPO=${2:-''}
    if asdf plugin list | grep -q $PLUGIN_NAME; then
        echo "$PLUGIN_NAME plugin already installed"
    else
        asdf plugin add $PLUGIN_NAME $PLUGIN_REPO
    fi
}

asdfAddPluginIfNotExists act
asdfAddPluginIfNotExists argo
asdfAddPluginIfNotExists argocd
asdfAddPluginIfNotExists direnv
asdfAddPluginIfNotExists github-cli https://github.com/bartlomiejdanek/asdf-github-cli.git
asdfAddPluginIfNotExists golang
asdfAddPluginIfNotExists gopass
asdfAddPluginIfNotExists hadolint https://github.com/looztra/asdf-hadolint.git
asdfAddPluginIfNotExists helm
asdfAddPluginIfNotExists hugo
asdfAddPluginIfNotExists jq
asdfAddPluginIfNotExists k9s
asdfAddPluginIfNotExists kind
asdfAddPluginIfNotExists kubectl
asdfAddPluginIfNotExists kustomize
asdfAddPluginIfNotExists mc
asdfAddPluginIfNotExists packer
asdfAddPluginIfNotExists python
asdfAddPluginIfNotExists shellcheck
asdfAddPluginIfNotExists shfmt
asdfAddPluginIfNotExists skaffold
asdfAddPluginIfNotExists talhelper
asdfAddPluginIfNotExists talosctl
asdfAddPluginIfNotExists task
asdfAddPluginIfNotExists terraform
asdfAddPluginIfNotExists terragrunt
asdfAddPluginIfNotExists vale
asdfAddPluginIfNotExists vault
asdfAddPluginIfNotExists vendir
asdfAddPluginIfNotExists yq
