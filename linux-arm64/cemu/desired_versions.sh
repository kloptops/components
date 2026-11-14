#!/usr/bin/env bash
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
# Cemu's official AArch64 AppImage is currently published as a moving CI artifact.
export CEMU_DESIRED_VERSION="latest"
