#!/bin/bash

portmaster_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
portmaster_install_dir="$portmaster_data_home/PortMaster"

# Setting component name and path based on the directory name
component_name="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
component_config="/app/retrodeck/components/$component_name/rd_config"

if [[ "$action" == "reset" ]]; then # Run reset-only commands
  log i "----------------------"
  log i "Resetting $component_name"
  log i "----------------------"

  # Refresh the bundled application files in place. Do not erase the user's
  # PortMaster data, settings, logs, installed runtimes, or autoinstall queue.
  mkdir -p "$portmaster_install_dir"
  unzip -oq "/app/retrodeck/components/portmaster/PortMaster.zip" -d "$portmaster_data_home"

  # RetroDECK runs in a Flatpak, where /var/data is not the PortMaster data
  # location. PortMaster's RetroDECK hook is copied to control.txt at launch.
  for control_file in \
    "$portmaster_install_dir/control.txt" \
    "$portmaster_install_dir/retrodeck/control.txt"; do
    if [[ -f "$control_file" ]]; then
      sed -i \
        's|export controlfolder="/var/data/PortMaster"|export controlfolder="${XDG_DATA_HOME:-$HOME/.local/share}/PortMaster"|g' \
        "$control_file"
      sed -i \
        's|^export LD_LIBRARY_PATH=.*|export LD_LIBRARY_PATH="/usr/lib:/lib:/app/retrodeck/components/shared-libs/org.kde.Sdk/6.7/:/app/retrodeck/components/shared-libs/org.kde.Platform/6.7/:/app/retrodeck/components/shared-libs/org.freedesktop.Platform/25.08/:$LD_LIBRARY_PATH"|' \
        "$control_file"
    fi
  done

  # The launch hook runs from ES-DE/Configurator working directories, so use
  # an absolute path to the embedded control file.
  if [[ -f "$portmaster_install_dir/retrodeck/PortMaster.txt" ]]; then
    sed -i \
      's|cp retrodeck/control.txt \$controlfolder|cp "$controlfolder/retrodeck/control.txt" "$controlfolder/control.txt"|' \
      "$portmaster_install_dir/retrodeck/PortMaster.txt"
  fi

  cp -f "$portmaster_install_dir/retrodeck/PortMaster.txt" "$portmaster_install_dir/PortMaster.sh"
  chmod +x "$portmaster_install_dir/PortMaster.sh"
  rm -f "$roms_path/portmaster/PortMaster.sh"
  install -Dm755 "$portmaster_install_dir/PortMaster.sh" "$roms_path/portmaster/PortMaster.sh"
  create_dir "$portmaster_install_dir/config/"
  if [[ ! -f "$portmaster_install_dir/config/config.json" ]]; then
    cp "$component_config/config.json" "$portmaster_install_dir/config/config.json"
  fi
  install -Dm755 "/app/retrodeck/components/portmaster/harbourmaster" "$portmaster_install_dir/harbourmaster"
  set_setting_value "$rd_conf" "portmaster_path" "$rd_home_path/PortMaster" "retrodeck" "paths"
  create_dir "$portmaster_path"
fi
