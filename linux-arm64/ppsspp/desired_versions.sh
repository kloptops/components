#!/usr/bin/env bash

# Flatpak commit IDs are architecture-specific. Resolve the stable AArch64
# commit from Flathub when building this component on the ARM host.
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
export PPSSPP_DESIRED_VERSION="latest"
