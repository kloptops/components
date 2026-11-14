#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
components_root="$(git -C "$script_dir/../.." rev-parse --show-toplevel)"
workdir="$(mktemp -d "${TMPDIR:-/tmp}/retrodeck-xemu-arm.XXXXXX")"
artifact_dir="$script_dir/artifacts"
trap 'rm -rf "$workdir"' EXIT

for command_name in flatpak jq git envsubst; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

native_arch="$(flatpak --default-arch)"
if [[ "$native_arch" != "aarch64" ]]; then
  printf 'Build xemu on an AArch64 host; Flatpak reports architecture %s.\n' "$native_arch" >&2
  exit 1
fi

cd "$components_root"
export COMPONENT_ARTIFACTS_DIR="$artifact_dir"
bash "$components_root/automation-tools/alchemist/alchemist.sh" \
  --file "$components_root/xemu/component_recipe.json" \
  --versions "$script_dir/desired_versions.sh" \
  --output "$workdir"
