#!/usr/bin/env bash

set -euo pipefail

required_commands=(jq git curl wget 7z unzip tar envsubst)
missing_commands=()
for command_name in "${required_commands[@]}"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    missing_commands+=("$command_name")
  fi
done
if [[ ${#missing_commands[@]} -gt 0 ]]; then
  printf 'Missing build tools: %s\n' "${missing_commands[*]}" >&2
  exit 1
fi

repo_root="$(git -C "$(dirname "${BASH_SOURCE[0]}")/../.." rev-parse --show-toplevel)"
export COMPONENT_ARTIFACTS_DIR="$repo_root/linux-arm64/retroarch/artifacts"

exec bash "$repo_root/automation-tools/alchemist/alchemist.sh" \
  --file "$repo_root/linux-arm64/retroarch/component_recipe.json"
