#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
components_root="$(git -C "$script_dir/../.." rev-parse --show-toplevel)"
retrodeck_root="$(dirname "$components_root")/RetroDECK-arm-prototype"
workdir="$retrodeck_root/.tmp-arm-portmaster-build"

for command_name in jq git flatpak envsubst tar; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

if [[ ! -d "$retrodeck_root" ]]; then
  printf 'RetroDECK prototype worktree not found: %s\n' "$retrodeck_root" >&2
  exit 1
fi

export COMPONENT_ARTIFACTS_DIR="$script_dir/artifacts"

if [[ -n "${PORTMASTER_ARCHIVE_PATH:-}" ]]; then
  if [[ ! -s "$PORTMASTER_ARCHIVE_PATH" ]]; then
    printf 'PortMaster archive not found or empty: %s\n' "$PORTMASTER_ARCHIVE_PATH" >&2
    exit 1
  fi

  # Allow reproducible offline builds from an inspected upstream archive while
  # keeping the tracked recipe pointed at the official release URL.
  recipe_dir="$(mktemp -d)"
  trap 'rm -rf "$recipe_dir"' EXIT
  jq --arg archive "$PORTMASTER_ARCHIVE_PATH" \
    --arg version "2026.11.12-1059" \
    '.portmaster[0].source_type = "local"
     | .portmaster[0].source_url = $archive
     | (.portmaster[0].assets[] | select(.type == "file-rename").source) = $archive
     | (.portmaster[0].assets[] | select(.dest == "component_version").contents) = $version' \
    "$components_root/portmaster/component_recipe.json" \
    > "$recipe_dir/component_recipe.json"
  recipe_path="$recipe_dir/component_recipe.json"
else
  recipe_path="$components_root/portmaster/component_recipe.json"
fi

bash "$components_root/automation-tools/alchemist/alchemist.sh" \
  --file "$recipe_path" \
  --versions "$script_dir/desired_versions.sh" \
  --output "$workdir"
