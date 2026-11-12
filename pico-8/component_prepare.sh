#!/bin/bash

# Setting component name and path based on the directory name
component_name="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
component_config="/app/retrodeck/components/$component_name/rd_config"

if [[ ("$action" == "reset") || ("$action" == "postmove") ]]; then
  log i "----------------------"
  log i "Resetting/post-moving $component_name"
  log i "----------------------"

  create_dir "$bios_path/pico-8"
  create_dir "$roms_path/pico8"
  create_dir "$saves_path/pico-8"

  # Keep the user's licensed PICO-8 copy intact; only manage its carts and saves.
  dir_prep "$roms_path/pico8" "$bios_path/pico-8/carts"
  dir_prep "$saves_path/pico-8" "$bios_path/pico-8/cdata"

  create_dir "$XDG_CONFIG_HOME/pico-8/"
  if [[ ! -f "$pico8_config" ]]; then
    cp -f "$component_config/config.txt" "$pico8_config"
  fi
  if [[ ! -f "$pico8_config_sdl_controllers" ]]; then
    cp -f "$component_config/sdl_controllers.txt" "$pico8_config_sdl_controllers"
  fi

  # Set paths each setup/reset while preserving other user PICO-8 settings.
  sed -i \
    -e "s|^root_path .*|root_path $bios_path/pico-8/carts/|" \
    -e "s|^cdata_path .*|cdata_path $bios_path/pico-8/cdata/|" \
    "$pico8_config"
fi
