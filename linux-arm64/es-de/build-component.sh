#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
components_root="$(git -C "$script_dir/../.." rev-parse --show-toplevel)"
retrodeck_root="$(dirname "$components_root")/RetroDECK-arm-0.11.0"
manifest="$retrodeck_root/net.retrodeck.esde-arm64-build.yml"
build_dir="${ESDE_BUILD_DIR:-$retrodeck_root/.flatpak-builder/esde-arm64-component}"
artifact_dir="$script_dir/artifacts"

for command_name in flatpak-builder tar sha256sum; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

if [[ ! -f "$manifest" ]]; then
  printf 'ES-DE ARM build manifest not found: %s\n' "$manifest" >&2
  exit 1
fi

mkdir -p "$(dirname "$build_dir")"
(
  cd "$retrodeck_root"
  flatpak-builder --user --force-clean --jobs="${ESDE_BUILD_JOBS:-2}" --arch=aarch64 \
    --install-deps-from=flathub "$build_dir" "$manifest"
)

app_files="$build_dir/files"
component_dir="$(mktemp -d "${TMPDIR:-/tmp}/retrodeck-esde-arm.XXXXXX")"
trap 'rm -rf "$component_dir"' EXIT

if [[ ! -x "$app_files/bin/es-de" ]]; then
  printf 'Built ES-DE executable is missing: %s\n' "$app_files/bin/es-de" >&2
  exit 1
fi
if [[ ! -f "$app_files/share/es-de/resources/systems/linuxarm/es_systems.xml" || \
      ! -f "$app_files/share/es-de/resources/systems/linuxarm/es_find_rules.xml" ]]; then
  printf 'The build is missing ES-DE Linux ARM system definitions.\n' >&2
  exit 1
fi
if [[ ! -d "$app_files/share/es-de/themes/RetroDECK-theme-main" ]]; then
  printf 'RetroDECK ES-DE theme was not staged by the build manifest.\n' >&2
  exit 1
fi

install -Dm755 "$app_files/bin/es-de" "$component_dir/bin/es-de"
mkdir -p "$component_dir/share" "$component_dir/lib"
cp -a "$app_files/share/es-de" "$component_dir/share/"

# Keep the private shared-library dependencies next to the ES-DE component.
for library in "$app_files"/lib/libfreeimage* "$app_files"/lib/libgit2* "$app_files"/lib/libpugixml*; do
  if [[ -e "$library" || -L "$library" ]]; then
    cp -a "$library" "$component_dir/lib/"
  fi
done

for asset in component_functions.sh component_launcher.sh component_manifest.json component_recipe.json; do
  cp -a "$components_root/es-de/$asset" "$component_dir/"
done
cp -a "$components_root/es-de/rd_assets/rd_config" "$component_dir/rd_config"
cp -a "$components_root/es-de/rd_assets/helper_files" "$component_dir/helper_files"
cp -a "$components_root/es-de/rd_assets/res" "$component_dir/res"

# Prefer the bundled AArch64 GearColeco core for ColecoVision.
python3 "$script_dir/set-default-core.py" \
  "$component_dir/share/es-de/resources/systems/linuxarm/es_systems.xml" \
  colecovision Gearcoleco
python3 "$script_dir/set-default-core.py" \
  "$component_dir/share/es-de/resources/systems/linuxarm/es_systems.xml" \
  nds DeSmuME
python3 "$script_dir/set-default-core.py" \
  "$component_dir/share/es-de/resources/systems/linuxarm/es_systems.xml" \
  psx SwanStation

printf '3.5.0\n' > "$component_dir/component_version"

mkdir -p "$artifact_dir"
archive_tmp="$artifact_dir/es-de.tar.gz.tmp"
trap 'rm -rf "$component_dir"; rm -f "$archive_tmp"' EXIT
tar -czf "$archive_tmp" -C "$component_dir" .
mv -f "$archive_tmp" "$artifact_dir/es-de.tar.gz"
sha256sum "$artifact_dir/es-de.tar.gz" | awk '{print $1}' > "$artifact_dir/es-de.tar.gz.sha"

printf 'Created ARM ES-DE component archive:\n%s\n' "$artifact_dir/es-de.tar.gz"
