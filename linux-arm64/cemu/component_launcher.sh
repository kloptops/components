#!/bin/bash

source /app/libexec/logger.sh

component_name="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
component_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
appdir="$component_path/appdir"

export APPDIR="$appdir"

log i "RetroDECK is now launching $component_name"
log d "AppImage directory is: $appdir"

exec "$appdir/AppRun" "$@"
