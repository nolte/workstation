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
        asdf plugin-add $PLUGIN_NAME $PLUGIN_REPO
    fi
}

asdfAddPluginIfNotExists argo
asdfAddPluginIfNotExists argocd
asdfAddPluginIfNotExists shellcheck
asdfAddPluginIfNotExists talhelper
asdfAddPluginIfNotExists talosctl
asdfAddPluginIfNotExists terragrunt
asdfAddPluginIfNotExists vale
asdfAddPluginIfNotExists vault
asdfAddPluginIfNotExists k9s
