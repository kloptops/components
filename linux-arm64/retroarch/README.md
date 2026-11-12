# ARM64 RetroArch component prototype

The locally inspected Libretro archive contains one executable named
`retroarch`. It is an ELF64 AArch64 dynamically linked executable. The binary
depends on ALSA and PulseAudio, FreeType and Fontconfig, Wayland and X11,
SDL2, udev, GBM/DRM, desktop OpenGL/EGL, and V4L2 libraries. `ldd` resolved
these against Arch Linux ARM; the same dependencies still need verification
inside KDE Platform 6.11 before packaging is considered complete.

The ARM config is copied from RetroDECK's current config with two target
changes: use the OpenGL video driver because the device has no Vulkan driver,
and point core downloads at Libretro's Linux AArch64 nightly directory.
`component_prepare.sh` keeps the prototype to the selected cores and avoids
the existing x86-oriented preparation steps for unrelated emulators.

The app executable archive has no assets, core libraries, or component data.
The component artifact still needs RetroArch assets and the three ARM core
binaries. `component_recipe.json` assembles the executable, menu assets,
controller profiles, core info, database data, selected cores, and RetroDECK
component files. Run `build-component.sh` to create the architecture-specific
artifact under `linux-arm64/retroarch/artifacts/`; this recipe has not been
run yet. The build helper checks for its host-side tools first; `jq` is not
installed in the current session, and no packages were installed to add it.
