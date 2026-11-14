#!/usr/bin/env bash

# The 0.11 x86 build is build-b2e52d6358f746662d118aacf28264918df950e3.
# That tag is not listed in RPCS3's separate AArch64 release index; pin its
# nearest listed AArch64 build instead of requesting a missing matching tag.
export RPCS3_DESIRED_VERSION="build-ffba2bf09ef3980638f9327b25240d81414034ab"
