# Linux AArch64 component artifacts

This directory holds architecture-specific component recipes and generated
archives for the RetroDECK ARM prototype. Keep these artifacts separate from
x86_64 because the existing component downloader does not select payloads by
architecture.

The ARM manifest is configured for 16 components: `framework`, `es-de`,
`retroarch`, `pico-8`, `ppsspp`, `ruffle`, `scummvm`, `azahar`, `dolphin`,
`melonds`, `mame`, `xemu`, `duckstation`, `vita3k`, `rpcs3`, and `portmaster`.
The DuckStation, Vita3K, and RPCS3 ARM recipes use their upstream AArch64
AppImages and package them with ARM-specific launchers where needed. Their
archive builders are in `duckstation/`, `vita3k/`, and `rpcs3/`. Generated
archives live in each component's `artifacts/` directory and are Git-ignored;
all three archives have been built, but Chromebook launch testing is pending. See
`RetroDECK-arm-prototype/ARM_CHROMEBOOK_ARCH_BUILD.md` for the Chromebook test
status and components not yet ported. PPSSPP is assembled from the
native-architecture Flathub app; build its archive on the AArch64 host with
`ppsspp/build-component.sh`.

The ARM RetroArch recipe bundles the 194 cores in RetroDECK's x86 core inventory
that have a same-name Linux AArch64 build in Libretro's nightly index. It omits
14 x86 cores without a matching ARM binary, including RetroDECK's custom
Genesis Plus GX Paprium variant. The recipe includes core metadata and nightly
archives and can be rebuilt with `retroarch/build-component.sh`.

The nightly URLs are mutable. Pin core archive URLs and checksums when preparing
a reproducible release.

References:

- [Libretro Linux AArch64 nightly cores](https://buildbot.libretro.com/nightly/linux/aarch64/latest/)
- [ES-DE Linux AArch64 graphics notes](https://github.com/RetroDECK/ES-DE/blob/retrodeck-main/LINUX-AARCH64-DEV.md)
