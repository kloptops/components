#!/usr/bin/env bash

# Match the 0.11 Vita3K release as closely as possible while keeping the
# AArch64 AppImage, verified to require GLIBC no newer than 2.38, compatible
# with RetroDECK 0.11's KDE 6.11 runtime.
export VITA3K_DESIRED_VERSION="4103"
