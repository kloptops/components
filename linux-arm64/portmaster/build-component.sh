#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
components_root="$(git -C "$script_dir/../.." rev-parse --show-toplevel)"
workdir="$(mktemp -d "${TMPDIR:-/tmp}/retrodeck-portmaster-arm.XXXXXX")"
artifact_dir="$script_dir/artifacts"
recipe_dir=""
trap 'rm -rf "$workdir"; [[ -z "$recipe_dir" ]] || rm -rf "$recipe_dir"' EXIT

for command_name in flatpak jq git envsubst tar curl sha256sum; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

native_arch="$(flatpak --default-arch)"
if [[ "$native_arch" != "aarch64" ]]; then
  printf 'Build PortMaster on an AArch64 host; Flatpak reports architecture %s.\n' "$native_arch" >&2
  exit 1
fi

cd "$components_root"
export COMPONENT_ARTIFACTS_DIR="$artifact_dir"

recipe_dir="$(mktemp -d "${TMPDIR:-/tmp}/retrodeck-portmaster-recipe.XXXXXX")"
recipe_path="$recipe_dir/component_recipe.json"

# The KDE 6.11 runtime no longer has SDL2_image or SDL2_ttf: build them and ship them in place of the copies
# the shared recipe takes from the runtime.
sdl2_dir="$recipe_dir/sdl2-libs"
bash "$script_dir/build-sdl2-libs.sh" "$sdl2_dir"
jq --arg sdl2 "$sdl2_dir" \
  '(.portmaster[0].libs) |= map(select(.library | test("^libSDL2_(image|ttf)-") | not))
   | (.portmaster[0].assets) += [{"type": "dir", "source": $sdl2, "dest": "shared-libs/org.kde.Sdk/6.11"}]' \
  "$components_root/portmaster/component_recipe.json" \
  > "$recipe_path"

if [[ -n "${PORTMASTER_ARCHIVE_PATH:-}" ]]; then
  if [[ ! -s "$PORTMASTER_ARCHIVE_PATH" ]]; then
    printf 'PortMaster archive not found or empty: %s\n' "$PORTMASTER_ARCHIVE_PATH" >&2
    exit 1
  fi

  # The recipe's file-rename asset moves its source: hand it a copy, not the caller's archive.
  archive="$recipe_dir/retrodeck.portmaster.zip"
  cp "$PORTMASTER_ARCHIVE_PATH" "$archive"
  jq --arg archive "$archive" \
    --arg version "${PORTMASTER_ARCHIVE_VERSION:-2026.11.12-1059}" \
    '.portmaster[0].source_type = "local"
     | .portmaster[0].source_url = $archive
     | (.portmaster[0].assets[] | select(.type == "file-rename").source) = $archive
     | (.portmaster[0].assets[] | select(.dest == "component_version").contents) = $version' \
    "$recipe_path" > "$recipe_path.new"
  mv "$recipe_path.new" "$recipe_path"
fi

bash "$components_root/automation-tools/alchemist/alchemist.sh" \
  --file "$recipe_path" \
  --versions "$script_dir/desired_versions.sh" \
  --output "$workdir"
