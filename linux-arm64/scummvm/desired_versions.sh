#!/usr/bin/env bash

# Historical AArch64 Flathub build using Freedesktop 25.08. The packaged
# executable and ELF libraries were checked and require GLIBC up to 2.38,
# compatible with RetroDECK's KDE 6.11 runtime (GLIBC 2.42).
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
export SCUMMVM_DESIRED_VERSION="a742f597c46657508a03bd65f26349b427a14a3dbe9adfcc7ed9eb5a5dde2bad"
