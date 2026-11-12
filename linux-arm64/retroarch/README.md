# ARM64 RetroArch component prototype

The locally inspected Libretro archive contains one executable named
`retroarch`. It is an ELF64 AArch64 dynamically linked executable. The binary
depends on ALSA and PulseAudio, FreeType and Fontconfig, Wayland and X11,
SDL2, udev, GBM/DRM, desktop OpenGL/EGL, and V4L2 libraries. `ldd` resolved
these against Arch Linux ARM. The integrated RetroArch app, including Mesen,
has launched games successfully inside KDE Platform 6.11 on the Chromebook.

The ARM config is copied from RetroDECK's current config with two target
changes: use the OpenGL video driver because the device has no Vulkan driver,
and point core downloads at Libretro's Linux AArch64 nightly directory.
`component_prepare.sh` keeps the prototype to the selected cores and avoids
the existing x86-oriented preparation steps for unrelated emulators.
The selected cores are Gambatte, Snes9x, Genesis Plus GX, Mesen for NES, and
GearColeco for ColecoVision.
Mesen is also the default NES command in the ARM ES-DE system definition,
matching the x86 ES-DE configuration.
An NES game launched successfully through Mesen in the integrated ARM app.

The app executable archive has no assets, core libraries, or component data.
The component artifact includes RetroArch assets and is built from the ARM
core binaries. The recipe now selects four cores; rebuild it after recipe
changes. `component_recipe.json` assembles the executable, menu assets,
controller profiles, core info, database data, selected cores, and RetroDECK
component files. Run `build-component.sh` to create the architecture-specific
artifact under `linux-arm64/retroarch/artifacts/`.
