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

asdfAddPluginIfNotExists vault
asdfAddPluginIfNotExists terragrunt
asdfAddPluginIfNotExists shellcheck
asdfAddPluginIfNotExists argocd
asdfAddPluginIfNotExists argo https://github.com/sudermanjr/asdf-argo.git
asdfAddPluginIfNotExists talosctl https://github.com/nolte/asdf-talosctl.git
asdfAddPluginIfNotExists talhelper https://github.com/nolte/asdf-talhelper.git
