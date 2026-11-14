#!/usr/bin/env bash
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
# Match the x86 component pin; this AArch64 AppImage was checked at GLIBC 2.38.
export VITA3K_DESIRED_VERSION="4103"
