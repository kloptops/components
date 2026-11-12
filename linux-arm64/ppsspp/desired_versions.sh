#!/usr/bin/env bash

# Flatpak commit IDs are architecture-specific. Pin the AArch64 build using
# Freedesktop 25.08; its GLIBC requirements fit RetroDECK's KDE 6.11 runtime.
source "$REPO_ROOT/automation-tools/alchemist/desired_versions.sh"
export PPSSPP_DESIRED_VERSION="678bf845ac9679ddf5d2be24ed39bc21b269a573b7ba07a1795175aaf4a57040"
