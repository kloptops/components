#!/usr/bin/env bash

# Flathub's native AArch64 ScummVM build, using the Freedesktop 25.08 runtime.
# The runtime generation matches the x86 component and is compatible with the
# KDE 6.11 runtime used by the ARM RetroDECK prototype.
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
export SCUMMVM_DESIRED_VERSION="f1fcccc1433fc8ea77d8adff40946d3083055d5eec5facb50a8f262d7a362dcc"
