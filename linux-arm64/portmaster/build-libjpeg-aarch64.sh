#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
output_dir="${1:-$script_dir/artifacts/libjpeg-aarch64}"
build_root="$(mktemp -d "${TMPDIR:-/tmp}/retrodeck-libjpeg-aarch64.XXXXXX")"
trap 'rm -rf "$build_root"' EXIT

source_version="3.2.1"
source_archive="libjpeg-turbo-${source_version}.tar.gz"
source_url="https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/${source_version}/${source_archive}"
source_sha256="c27ad72a68da151177929aa969ae773a2da5ac2af9ce946079314fdac8cece7f"

for command_name in cmake curl sha256sum tar readelf; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

if [[ "$(uname -m)" == "aarch64" ]]; then
  target_cc="${CC:-gcc}"
else
  target_cc="${CC:-aarch64-linux-gnu-gcc}"
fi
if ! command -v "$target_cc" >/dev/null 2>&1; then
  printf 'Missing AArch64 C compiler: %s\n' "$target_cc" >&2
  exit 1
fi

mkdir -p "$output_dir"
curl --fail --location --silent --show-error "$source_url" -o "$build_root/$source_archive"
printf '%s  %s\n' "$source_sha256" "$build_root/$source_archive" | sha256sum --check --status
tar -xzf "$build_root/$source_archive" -C "$build_root"

source_dir="$build_root/libjpeg-turbo-${source_version}"
install_dir="$build_root/install"
cmake -S "$source_dir" -B "$build_root/build" \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER="$target_cc" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$install_dir" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DWITH_JPEG8=ON \
  -DWITH_SIMD=OFF \
  -DWITH_TURBOJPEG=OFF \
  -DWITH_TOOLS=OFF \
  -DWITH_TESTS=OFF \
  -DENABLE_SHARED=ON \
  -DENABLE_STATIC=OFF
cmake --build "$build_root/build" --parallel "${BUILD_JOBS:-2}"
cmake --install "$build_root/build"

install -D -m 755 -T "$install_dir/lib/libjpeg.so.8" "$output_dir/libjpeg.so.8"
install -D -m 644 -T "$source_dir/LICENSE.md" "$output_dir/LICENSE.md"

machine="$(readelf -h "$output_dir/libjpeg.so.8" | awk -F: '/Machine:/ {gsub(/^[[:space:]]+/, "", $2); print $2}')"
soname="$(readelf -d "$output_dir/libjpeg.so.8" | sed -n 's/.*SONAME.*\[\(.*\)\].*/\1/p')"
if [[ "$machine" != "AArch64" || "$soname" != "libjpeg.so.8" ]]; then
  printf 'Unexpected libjpeg artifact: machine=%s soname=%s\n' "$machine" "$soname" >&2
  exit 1
fi

printf 'Built %s (%s, SONAME %s)\n' "$output_dir/libjpeg.so.8" "$machine" "$soname"
