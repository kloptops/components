#!/bin/bash

source /app/libexec/launcher_functions.sh

# Setting component name and path based on the directory name
component_name="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
component_path="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

# The ARM component carries ES-DE's GLES-only build dependencies locally.
export LD_LIBRARY_PATH="$component_path/lib:${rd_shared_libs:-}:${DEFAULT_LD_LIBRARY_PATH:-}"

log i "RetroDECK is now launching $component_name"
log d "Library path is: $LD_LIBRARY_PATH"

exec "$component_path/bin/es-de" --home "${XDG_CONFIG_HOME}" "$@"
