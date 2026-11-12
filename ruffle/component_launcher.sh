#!/bin/bash

# Setting component name and path based on the directory name
component_name="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
component_path="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

log i "RetroDECK is now launching $component_name"
log i "Ruffle arguments: $*"

# The ARM Chromebook target has Panfrost OpenGL but no Vulkan driver.
exec "$component_path/bin/ruffle" \
  --graphics gl \
  --config "$XDG_CONFIG_HOME/ruffle" \
  --save-directory "$saves_path/flash/ruffle" \
  "$@"
