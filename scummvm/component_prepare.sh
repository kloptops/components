#!/bin/bash

# Setting component name and path based on the directory name
component_name="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
component_config="/app/retrodeck/components/$component_name/rd_config"
component_path="/app/retrodeck/components/$component_name"

if [[ "$action" == "reset" ]]; then # Run reset-only commands
  log i "----------------------"
  log i "Preparing $component_name"
  log i "----------------------"

  create_dir "$XDG_CONFIG_HOME/scummvm"
  cp -f "$component_config/scummvm.ini" "$scummvm_config"
  sed -i \
    -e "s|^soundfont=.*|soundfont=$component_path/soundfonts/FluidR3_GM.sf2|" \
    -e "s|^savepath=.*|savepath=$saves_path/scummvm|" \
    -e "s|^browser_lastpath=.*|browser_lastpath=$roms_path/scummvm/|" \
    "$scummvm_config"
  create_dir "$saves_path/scummvm"
fi
