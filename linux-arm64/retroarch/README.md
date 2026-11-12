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
The recipe bundles every x86 RetroDECK RetroArch core for which the AArch64
nightly index has a matching binary: 194 cores in total. Fourteen x86 cores
without a matching ARM build are omitted. `component_prepare.sh` avoids the
existing x86-oriented preparation steps for unrelated emulators.

The ARM ES-DE defaults include Gambatte for Game Boy, Snes9x for SNES,
Genesis Plus GX for Sega systems, Mesen for NES, GearColeco for ColecoVision,
DOSBox Pure for DOS, mGBA for GBA, DeSmuME for Nintendo DS,
Mupen64Plus-Next for Nintendo 64, and SwanStation for PlayStation. The last
system defaults for ColecoVision, Nintendo DS, Nintendo 64, and PlayStation
were adjusted to match the x86 defaults where needed.
Mesen is also the default NES command in the ARM ES-DE system definition,
matching the x86 ES-DE configuration.
An NES game launched successfully through Mesen in the integrated ARM app.

The app executable archive has no assets, core libraries, or component data.
The component artifact includes RetroArch assets and is built from ARM core
binaries. `component_recipe.json` assembles the executable, menu assets,
controller profiles, core info, database data, supported cores, and RetroDECK
component files. Run `build-component.sh` to create the architecture-specific
artifact under `linux-arm64/retroarch/artifacts/`.
