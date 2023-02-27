#!/usr/bin/env bash

set -e
set -u
set -o pipefail

asdfAddPluginIfNotExists() {
    PLUGIN_NAME=$1
    if asdf plugin list | grep -q $PLUGIN_NAME; then
        echo "$PLUGIN_NAME plugin already installed"
    else
        asdf plugin-add $PLUGIN_NAME
    fi
}

asdfAddPluginIfNotExists vault
asdfAddPluginIfNotExists terragrunt
