#!/bin/bash

source /app/libexec/launcher_functions.sh

component_name="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
component_path="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

log i "RetroDECK is now launching $component_name"
log i "Ruffle arguments: $*"

# The ARM target uses OpenGL and follows the 0.11 standalone config/save paths.
exec "$component_path/bin/ruffle" \
  --graphics gl \
  --config "$XDG_CONFIG_HOME/ruffle" \
  --save-directory "$saves_path/Ruffle-SA/SharedObjects" \
  "$@"
