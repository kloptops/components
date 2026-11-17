# ARM 0.11 Component Build Overview

The ARM 0.11 build creates AArch64 component archives, then stages them in the RetroDECK Flatpak.

## Typical component

Each component has an ARM recipe and a `build-component.sh` wrapper under `linux-arm64/<component>/`. The wrapper handles any ARM-specific setup, then usually calls the shared Alchemist:

```text
build-component.sh -> Alchemist + component_recipe.json -> artifacts/<component>.tar.gz
```

Alchemist downloads or fetches the recipe sources, extracts them, gathers the selected files and libraries, and creates an archive plus checksum. It assembles packages; it does not compile source code. Artifacts go under that component's `linux-arm64` directory.

## ES-DE exception

The 0.11 ES-DE binary is x86, so ARM needs an AArch64 build. Its wrapper uses `flatpak-builder` with the ARM manifest and KDE SDK/runtime to compile ES-DE, then stages its files and adjusts system definitions to launch ARM components. It packages the result directly instead of using Alchemist, because this path builds and customizes the application before packaging it.

## Other wrapper differences

Most other wrappers call Alchemist, with small ARM-specific checks or setup:

- Azahar, Dolphin, MAME, melonDS, PPSSPP, Ruffle, ScummVM, xemu, and PortMaster check for an AArch64 host.
- DuckStation, RPCS3, and Vita3K check the host before extracting ARM64 AppImages.
- PortMaster can use a supplied local archive and make a temporary recipe for it.
- Cemu and Steam ROM Manager expect the separate ARM RetroDECK worktree.

These wrappers still use Alchemist to assemble their artifacts. ES-DE is the exception: its wrapper builds, adjusts, and packages the app directly.

## App build

After component archives are built, the ARM RetroDECK Flatpak manifest stages them into the application. `RetroDECK-arm-0.11.0/BUILD_AARCH64.md` documents the component and app build commands.
