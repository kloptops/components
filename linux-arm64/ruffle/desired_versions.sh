#!/usr/bin/env bash

# AArch64 Flathub commit using Freedesktop 25.08; its GLIBC requirement
# (2.39) is compatible with RetroDECK's KDE 6.11 runtime (GLIBC 2.42).
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
export RUFFLE_DESIRED_VERSION="da3f38eab890a15d9ab9b4284fd1d5a0da7a68ed50d6e0a82c23b4685ff63152"
