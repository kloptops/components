# Linux ARM64 component artifact staging

This directory is the isolated staging location for ARM64 component packaging.
It has a starter-core overlay script, but no complete component recipes or
built artifacts.

Initial prototype scope:

- `framework`
- `es-de`
- `retroarch`
- ARM64 builds of Gambatte, Snes9x, and Genesis Plus GX, after ABI and variant
  checks

Produce artifacts in the same directory structure as the existing component
repository (`<component>/artifacts/...`) so the RetroDECK artifact fetcher can
consume them. Keep ARM binaries separate from x86_64 archives; the current
component downloader does not select archives by architecture.

The ARM-specific RetroArch recipe and component preparation scripts are now
staged under `retroarch/`. ES-DE packaging is still pending. The official
RetroDECK ES-DE fork documents an AArch64 AppImage build path, and Libretro
publishes Linux AArch64 nightly RetroArch and core archives. The application
archive was inspected locally; runtime library compatibility still needs a
check inside KDE Platform 6.11.

References:

- [RetroDECK ES-DE AppImage build instructions](https://github.com/RetroDECK/ES-DE/blob/retrodeck-main/INSTALL.md)
- [ES-DE Linux AArch64 graphics notes](https://github.com/RetroDECK/ES-DE/blob/retrodeck-main/LINUX-AARCH64-DEV.md)
- [Libretro Linux AArch64 nightly directory](https://buildbot.libretro.com/nightly/linux/aarch64/)
