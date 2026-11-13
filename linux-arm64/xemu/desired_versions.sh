#!/usr/bin/env bash
# Historical AArch64 Flathub commit on Freedesktop 25.08. The xemu executable
# was checked at GLIBC 2.42, compatible with RetroDECK's KDE 6.11 baseline.
# Current xemu switched to Freedesktop 26.08 and needs GLIBC 2.44.
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
export XEMU_DESIRED_VERSION="56e940a8b2ec81291df431867bf082f94068f1856beb231e4ee2225a4bb1274c"
