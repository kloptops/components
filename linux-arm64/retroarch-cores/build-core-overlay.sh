#!/usr/bin/env bash

# Stage the three starter ARM64 cores as a RetroArch component overlay.
# Usage: build-core-overlay.sh <retroarch-component-root>

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <retroarch-component-root>" >&2
  exit 2
fi

if [[ ! -d "$1" ]]; then
  echo "RetroArch component root must already exist: $1" >&2
  exit 2
fi

component_root=$(realpath "$1")
core_dir="$component_root/rd_extras/cores"
source_base="https://buildbot.libretro.com/nightly/linux/aarch64/latest"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

if ! command -v readelf >/dev/null 2>&1; then
  echo "readelf is required to verify that downloaded cores are AArch64 ELF files." >&2
  exit 1
fi

mkdir -p "$core_dir"

cores=(
  gambatte_libretro
  snes9x_libretro
  genesis_plus_gx_libretro
)

for core in "${cores[@]}"; do
  archive="$tmp_dir/$core.so.zip"
  url="$source_base/$core.so.zip"
  echo "Downloading $url"
  curl --fail --location --silent --show-error "$url" --output "$archive"

  member=$(unzip -Z1 "$archive" | awk -v name="$core.so" '$0 == name || $0 ~ "/" name "$" { print; exit }')
  if [[ -z "$member" ]]; then
    echo "Archive does not contain $core.so: $archive" >&2
    exit 1
  fi

  staged_core="$tmp_dir/$core.so"
  unzip -p "$archive" "$member" > "$staged_core"
  machine=$(readelf -h "$staged_core" | awk -F: '/Machine:/ {gsub(/^[[:space:]]+/, "", $2); print $2}')
  if [[ "$machine" != "AArch64" ]]; then
    echo "Unexpected ELF machine for $core.so: $machine" >&2
    exit 1
  fi

  install -m 0644 "$staged_core" "$core_dir/$core.so"
done

cat > "$component_root/arm64-core-sources.txt" <<EOF
Architecture: aarch64
Source: $source_base
Retrieved: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Core files:
  gambatte_libretro.so
  snes9x_libretro.so
  genesis_plus_gx_libretro.so
EOF

echo "Core overlay staged in $component_root"
