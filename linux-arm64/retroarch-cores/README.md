# ARM64 RetroArch starter-core overlay

This helper was used for the initial ARM RetroArch prototype. The complete
ARM component now stages all matching AArch64 cores through
`../retroarch/component_recipe.json`; this three-core overlay is not part of
that build path.

`build-core-overlay.sh` stages the prototype's Gambatte, Snes9x, and Genesis
Plus GX shared libraries from [Libretro's Linux AArch64 nightly core
directory](https://buildbot.libretro.com/nightly/linux/aarch64/latest/) into an
existing RetroArch component root, under `rd_extras/cores/`, matching the
path consumed by RetroDECK's RetroArch component scripts.

The upstream directory currently contains all three binaries. It is a mutable
nightly endpoint, so the script writes a retrieval timestamp and source URL
into `arm64-core-sources.txt`. Archive checksums/signatures are not published
in the directory listing; the files still need an ELF architecture and
RetroArch ABI check when the overlay is assembled.

The upstream binaries provide standard core names. RetroDECK's custom
Genesis-Plus-GX Paprium core is not included in this overlay and must remain
disabled on ARM until an ARM build is produced. Gambatte's existing GB/GBC
metadata can share the standard upstream core binary.

This overlay does not provide the RetroArch application, its assets, info
files, custom core configuration, or the remaining RetroDECK RetroArch
component payload. It is one input to the component package, not a complete
component archive.
