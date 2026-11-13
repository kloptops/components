#!/usr/bin/env bash

# The release archive was inspected on the ARM Chromebook and contains native
# AArch64 helper binaries. Pin the tested release instead of following latest.
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
export PORTMASTER_DESIRED_VERSION="2026.11.12-1059"
