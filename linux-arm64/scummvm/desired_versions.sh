#!/usr/bin/env bash

# Candidate historical AArch64 Flathub build for GLIBC compatibility testing.
# Its app ref uses Freedesktop 25.08; verify the executable's symbol versions
# against RetroDECK's KDE 6.11 runtime before treating this pin as compatible.
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
export SCUMMVM_DESIRED_VERSION="a742f597c46657508a03bd65f26349b427a14a3dbe9adfcc7ed9eb5a5dde2bad"
