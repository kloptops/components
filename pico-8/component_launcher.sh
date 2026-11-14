#!/bin/bash

source /app/libexec/launcher_functions.sh

if [[ "$(uname -m)" == "aarch64" ]]; then
  pico8_binary="$bios_path/pico-8/pico8_64"
  if [[ ! -x "$pico8_binary" ]]; then
    printf 'PICO-8 AArch64 executable not found or not executable: %s\n' "$pico8_binary" >&2
    exit 127
  fi
  exec "$pico8_binary" -home "$XDG_CONFIG_HOME/pico-8" -desktop_path "$screenshots_path" "$@"
fi

pico8_binary="$bios_path/pico-8/pico8"
if [[ ! -x "$pico8_binary" ]]; then
  printf 'PICO-8 executable not found or not executable: %s\n' "$pico8_binary" >&2
  exit 127
fi

exec "$pico8_binary" -desktop_path "$screenshots_path" "$@"
