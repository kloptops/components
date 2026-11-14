#!/usr/bin/env bash

set -euo pipefail

repo_root="$(git -C "$(dirname "${BASH_SOURCE[0]}")/../.." rev-parse --show-toplevel)"
export COMPONENT_ARTIFACTS_DIR="$repo_root/linux-arm64/retroarch/artifacts"
build_workdir="$(mktemp -d)"

exec bash "$repo_root/automation-tools/alchemist/alchemist.sh" \
  --file "$repo_root/linux-arm64/retroarch/component_recipe.json" \
  --output "$build_workdir"
