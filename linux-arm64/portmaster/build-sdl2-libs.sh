#!/usr/bin/env bash
#
# Build SDL2_image and SDL2_ttf for PortMaster inside the KDE SDK 6.11.
#
# The 6.11 runtime moved to SDL3: it ships SDL2 only as sdl2-compat, plus SDL3_image and SDL3_ttf, so the
# libSDL2_image-2.0.so and libSDL2_ttf-2.0.so.0 that PortMaster's GUI (PySDL2) loads are no longer there to copy.
# Building them in the SDK links them against the runtime's own SDL2, freetype and harfbuzz.
#
#   build-sdl2-libs.sh DEST_DIR
#
# Writes the libraries and their licences to DEST_DIR.

set -euo pipefail

dest="${1:?usage: build-sdl2-libs.sh DEST_DIR}"
sdk="org.kde.Sdk//6.11"

sdl2_image_version="2.8.12"
sdl2_image_sha256="393f5efb50536ec13ca4f4affb69cc9966d3c3f969e6c5e701faddf9f9785381"
sdl2_ttf_version="2.24.0"
sdl2_ttf_sha256="0b2bf1e7b6568adbdbc9bb924643f79d9dedafe061fa1ed687d1d9ac4e453bfd"

for command_name in flatpak curl sha256sum tar; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

if ! flatpak info --user "$sdk" >/dev/null 2>&1 && ! flatpak info --system "$sdk" >/dev/null 2>&1; then
  flatpak install --user -y --noninteractive flathub "$sdk"
fi

build_dir="$(mktemp -d "${TMPDIR:-/tmp}/retrodeck-portmaster-sdl2.XXXXXX")"
trap 'rm -rf "$build_dir"' EXIT

fetch() { # NAME VERSION SHA256
  local archive="$build_dir/$1-$2.tar.gz"
  curl -fsSL -o "$archive" \
    "https://github.com/libsdl-org/${1/SDL2_/SDL_}/releases/download/release-$2/$1-$2.tar.gz"
  printf '%s  %s\n' "$3" "$archive" | sha256sum -c -
  tar -xzf "$archive" -C "$build_dir"
}

fetch SDL2_image "$sdl2_image_version" "$sdl2_image_sha256"
fetch SDL2_ttf "$sdl2_ttf_version" "$sdl2_ttf_sha256"

# SDL2_image: PNG and JPEG through its built-in stb backend, SVG built in, WebP and TIFF loaded from the
# runtime when first used. SDL2_ttf: the runtime's freetype and harfbuzz.
flatpak run --filesystem="$build_dir" --command=bash "$sdk" -c '
  set -euo pipefail
  cd "$1"
  cmake -S "SDL2_image-$2" -B image-build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$1/install" \
    -DSDL2IMAGE_VENDORED=OFF -DSDL2IMAGE_DEPS_SHARED=ON -DSDL2IMAGE_BACKEND_STB=ON \
    -DSDL2IMAGE_AVIF=OFF -DSDL2IMAGE_JXL=OFF -DSDL2IMAGE_WEBP=ON -DSDL2IMAGE_TIF=ON \
    -DSDL2IMAGE_SAMPLES=OFF -DSDL2IMAGE_TESTS=OFF
  cmake --build image-build -j"$(nproc)"
  cmake --install image-build
  cmake -S "SDL2_ttf-$3" -B ttf-build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$1/install" \
    -DSDL2TTF_VENDORED=OFF -DSDL2TTF_HARFBUZZ=ON -DSDL2TTF_SAMPLES=OFF
  cmake --build ttf-build -j"$(nproc)"
  cmake --install ttf-build
' bash "$build_dir" "$sdl2_image_version" "$sdl2_ttf_version"

lib_dir="$(dirname "$(find "$build_dir/install" -name 'libSDL2_image-2.0.so.0' -print -quit)")"
mkdir -p "$dest"
# PortMaster's recipe listed libSDL2_image-2.0.so, so install it under both names.
cp -L "$lib_dir/libSDL2_image-2.0.so.0" "$dest/libSDL2_image-2.0.so.0"
cp -L "$lib_dir/libSDL2_image-2.0.so.0" "$dest/libSDL2_image-2.0.so"
cp -L "$lib_dir/libSDL2_ttf-2.0.so.0" "$dest/libSDL2_ttf-2.0.so.0"
cp "$build_dir/install/share/licenses/SDL2_image/LICENSE.txt" "$dest/LICENSE-SDL2_image.txt"
cp "$build_dir/install/share/licenses/SDL2_ttf/LICENSE.txt" "$dest/LICENSE-SDL2_ttf.txt"
