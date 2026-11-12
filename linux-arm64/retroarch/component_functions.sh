#!/usr/bin/env bash

retroarch_config="$XDG_CONFIG_HOME/retroarch/retroarch.cfg"
retroarch_config_core_options="$XDG_CONFIG_HOME/retroarch/retroarch-core-options.cfg"
retroarch_config_scummvm="$bios_path/scummvm.ini"
retroarch_cores_path="$XDG_CONFIG_HOME/retroarch/cores"
retroarch_extras_path="$rd_components/retroarch/rd_extras"
retroarch_rd_config_dir="$rd_components/retroarch/rd_config"

retroarch_updater() {
  log i "The ARM64 prototype updates cores and assets through its component artifact."
}
