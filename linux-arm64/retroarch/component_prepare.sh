#!/usr/bin/env bash

# Preparation for the ARM64 RetroArch component and its supported core set.

component_name="$(basename "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
component_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
component_config="$component_path/rd_config"

set_retroarch_paths() {
  set_setting_value "$retroarch_config" "assets_directory" "$component_path/assets" "retroarch"
  set_setting_value "$retroarch_config" "joypad_autoconfig_dir" "$component_path/autoconfig" "retroarch"
  set_setting_value "$retroarch_config" "cursor_directory" "$component_path/database/cursors" "retroarch"
  set_setting_value "$retroarch_config" "content_database_path" "$component_path/database/rdb" "retroarch"
  set_setting_value "$retroarch_config" "libretro_directory" "$retroarch_extras_path/cores" "retroarch"
  set_setting_value "$retroarch_config" "libretro_info_path" "$retroarch_extras_path/cores" "retroarch"
  set_setting_value "$retroarch_config" "savefile_directory" "$saves_path" "retroarch"
  set_setting_value "$retroarch_config" "savestate_directory" "$states_path" "retroarch"
  set_setting_value "$retroarch_config" "screenshot_directory" "$screenshots_path/retroarch" "retroarch"
  set_setting_value "$retroarch_config" "recording_output_directory" "$videos_path/retroarch" "retroarch"
  set_setting_value "$retroarch_config" "log_dir" "$logs_path" "retroarch"
  set_setting_value "$retroarch_config" "rgui_browser_directory" "$roms_path" "retroarch"
  set_setting_value "$retroarch_config" "system_directory" "$bios_path" "retroarch"
  set_setting_value "$retroarch_config" "audio_filter_dir" "$shaders_path/retroarch/filters/audio" "retroarch"
  set_setting_value "$retroarch_config" "video_filter_dir" "$shaders_path/retroarch/filters/video" "retroarch"
  set_setting_value "$retroarch_config" "video_shader_dir" "$shaders_path/retroarch/shaders" "retroarch"
  set_setting_value "$retroarch_config" "overlay_directory" "$borders_path/retroarch" "retroarch"
}

if [[ "$action" == "reset" ]]; then
  log i "Preparing the ARM64 RetroArch prototype"
  create_dir -d "$XDG_CONFIG_HOME/retroarch"
  create_dir "$retroarch_extras_path/cores"
  create_dir "$component_path/assets"
  create_dir "$component_path/autoconfig"
  create_dir "$component_path/database/cursors"
  create_dir "$component_path/database/rdb"
  dir_prep "$logs_path/retroarch" "$XDG_CONFIG_HOME/retroarch/logs"

  cp -f "$component_config/retroarch.cfg" "$retroarch_config"
  cp -f "$component_config/retroarch-core-options.cfg" "$retroarch_config_core_options"
  rsync -rlD --mkpath "$component_config/core-overrides/" "$XDG_CONFIG_HOME/retroarch/config/"
  rsync -rlD --mkpath "$component_config/remaps/" "$XDG_CONFIG_HOME/retroarch/config/remaps/"

  create_dir "$videos_path/retroarch"
  create_dir "$screenshots_path/retroarch"
  create_dir "$bios_path"
  create_dir "$saves_path"
  create_dir "$states_path"
  create_dir "$cheats_path/retroarch"
  create_dir "$borders_path/retroarch"
  create_dir "$shaders_path/retroarch/filters/audio"
  create_dir "$shaders_path/retroarch/filters/video"
  create_dir "$shaders_path/retroarch/shaders"

  set_retroarch_paths

  if [[ ! -e "$XDG_CONFIG_HOME/retroarch/cores" ]]; then
    ln -s "$retroarch_extras_path/cores" "$XDG_CONFIG_HOME/retroarch/cores"
  fi
fi

if [[ "$action" == "postmove" ]]; then
  set_retroarch_paths
fi
