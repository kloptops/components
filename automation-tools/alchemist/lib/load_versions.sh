#!/bin/bash

# ==============================================================================
#  VERSION LOADER
#  ----------------
#  Combines version_policy.sh and version_pins.sh (if present) into the
#  *_DESIRED_VERSION variables consumed by the Alchemist and component recipes.
#
#  Logic per component:
#    1. If a pinned version exists (*_PINNED_VERSION) -> use pin
#    2. Otherwise -> use the resolution policy (*_VERSION_POLICY)
#
#  On main: version_pins.sh provides concrete versions for all components.
#  On cooker/epicure/feature branches: no pins file exists, so every component
#  resolves dynamically using its policy value.
# ==============================================================================

if [[ ! -f "$SCRIPT_DIR/version_policy.sh" ]]; then
  log error "version_policy.sh not found in $SCRIPT_DIR"
  exit 1
fi

source "$SCRIPT_DIR/version_policy.sh"

# --------------------------------------------------------------------------
#  Source pinned versions if present
# --------------------------------------------------------------------------

if [[ -f "$SCRIPT_DIR/version_pins.sh" ]]; then
  source "$SCRIPT_DIR/version_pins.sh"
fi

# --------------------------------------------------------------------------
#  Resolve *_DESIRED_VERSION for each component
#  Pin takes precedence over policy when present
# --------------------------------------------------------------------------

load_desired_versions() {
  local component_prefix policy_var pin_var desired_var

  if [[ -n "${ALTERNATE_DESIRED_VERSIONS:-}" ]]; then
    if [[ ! -f "$ALTERNATE_DESIRED_VERSIONS" ]]; then
      log error "Alternate desired versions file not found: $ALTERNATE_DESIRED_VERSIONS"
      return 1
    fi
    source "$ALTERNATE_DESIRED_VERSIONS"
  fi

  while IFS= read -r line; do
    # Extract the component prefix from: export AZAHAR_VERSION_POLICY="latest"
    [[ "$line" =~ ^export[[:space:]]+([A-Z0-9_]+)_VERSION_POLICY= ]] || continue
    component_prefix="${BASH_REMATCH[1]}"

    policy_var="${component_prefix}_VERSION_POLICY"
    pin_var="${component_prefix}_PINNED_VERSION"
    desired_var="${component_prefix}_DESIRED_VERSION"

    # An explicit alternate version file wins, followed by branch pins and
    # finally the component's resolution policy.
    if [[ -n "${!desired_var:-}" ]]; then
      continue
    elif [[ -n "${!pin_var:-}" ]]; then
      export "$desired_var"="${!pin_var}"
    else
      export "$desired_var"="${!policy_var}"
    fi
  done < "$SCRIPT_DIR/version_policy.sh"
}
