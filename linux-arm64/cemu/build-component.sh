#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
components_root="$(git -C "$script_dir/../.." rev-parse --show-toplevel)"
retrodeck_root="$(dirname "$components_root")/RetroDECK-arm-prototype"
for command_name in jq git envsubst tar unzip; do
  command -v "$command_name" >/dev/null 2>&1 || { printf 'Missing required command: %s\n' "$command_name" >&2; exit 1; }
done
[[ -d "$retrodeck_root" ]] || { printf 'RetroDECK prototype worktree not found: %s\n' "$retrodeck_root" >&2; exit 1; }
export COMPONENT_ARTIFACTS_DIR="$script_dir/artifacts"
exec bash "$components_root/automation-tools/alchemist/alchemist.sh" \
  --file "$script_dir/component_recipe.json" \
  --versions "$script_dir/desired_versions.sh" \
  --output "$retrodeck_root/.tmp-arm-cemu-build"
