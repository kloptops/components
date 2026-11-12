#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
components_root="$(git -C "$script_dir/../.." rev-parse --show-toplevel)"
retrodeck_root="$(dirname "$components_root")/RetroDECK-arm-prototype"
manifest="$retrodeck_root/net.retrodeck.esde-gles-test.yml"
build_dir="${ESDE_BUILD_DIR:-$retrodeck_root/.build-esde-arm64-component}"
artifact_dir="$script_dir/artifacts"

for command_name in flatpak-builder tar sha256sum; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

if [[ ! -f "$manifest" ]]; then
  printf 'ES-DE smoke-test manifest not found: %s\n' "$manifest" >&2
  exit 1
fi

retroarch_archive="$script_dir/../retroarch/artifacts/retroarch.tar.gz"
if [[ ! -f "$retroarch_archive" ]]; then
  printf 'Build the ARM RetroArch component first: %s\n' "$retroarch_archive" >&2
  exit 1
fi

# Build the validated Flatpak appdir without installing the separate test app.
(
  cd "$retrodeck_root"
  flatpak-builder --user --force-clean --jobs=2 --arch=aarch64 \
    --install-deps-from=flathub "$build_dir" "$manifest"
)

app_files="$build_dir/files"
component_dir="$(mktemp -d "$retrodeck_root/.tmp-arm-esde-component.XXXXXX")"
trap 'rm -rf "$component_dir"' EXIT

if [[ ! -x "$app_files/bin/es-de" ]]; then
  printf 'Built ES-DE executable is missing: %s\n' "$app_files/bin/es-de" >&2
  exit 1
fi
if [[ ! -f "$app_files/share/es-de/resources/systems/linuxarm/es_systems.xml" || \
      ! -f "$app_files/share/es-de/resources/systems/linuxarm/es_find_rules.xml" ]]; then
  printf 'The build is missing ES-DE Linux ARM system definitions.\n' >&2
  exit 1
fi
if [[ ! -d "$app_files/share/es-de/themes/RetroDECK-theme-main" ]]; then
  printf 'RetroDECK ES-DE theme was not staged by the test manifest.\n' >&2
  exit 1
fi

install -Dm755 "$app_files/bin/es-de" "$component_dir/bin/es-de"
mkdir -p "$component_dir/share" "$component_dir/lib"
cp -a "$app_files/share/es-de" "$component_dir/share/"

# Let ES-DE resolve the launcher that executes the user's own PICO-8 copy.
python3 - "$component_dir/share/es-de/resources/systems/linuxarm/es_find_rules.xml" <<'PY'
from pathlib import Path
import sys

rules_path = Path(sys.argv[1])
rules = rules_path.read_text()
start = rules.index('<emulator name="PICO-8">')
end = rules.index('</emulator>', start)
block = rules[start:end]
static_path = '<rule type="staticpath">'
launcher = '<entry>/app/retrodeck/components/pico-8/component_launcher.sh</entry>'
if launcher not in block:
    if static_path not in block:
        raise SystemExit('PICO-8 staticpath rule was not found in ES-DE rules')
    block = block.replace(static_path, static_path + '\n            ' + launcher, 1)
    rules = rules[:start] + block + rules[end:]
    rules_path.write_text(rules)
PY

# Make the bundled standalone PPSSPP the default PSP emulator. Keep the
# RetroArch PPSSPP core available as an explicit alternative.
python3 - "$component_dir/share/es-de/resources/systems/linuxarm/es_systems.xml" <<'PY'
from pathlib import Path
import sys

systems_path = Path(sys.argv[1])
systems = systems_path.read_text()
system_name = '<name>psp</name>'
name_pos = systems.index(system_name)
start = systems.rfind('<system>', 0, name_pos)
end = systems.index('</system>', name_pos) + len('</system>')
block = systems[start:end]
core_command = '<command label="PPSSPP">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/ppsspp_libretro.so %ROM%</command>'
standalone_command = '<command label="PPSSPP (Standalone)">%EMULATOR_PPSSPP% %ROM%</command>'
if core_command not in block or standalone_command not in block:
    raise SystemExit('Expected PSP RetroArch and standalone commands were not found')
block = block.replace(core_command, '<command label="PPSSPP">%EMULATOR_PPSSPP% %ROM%</command>')
block = block.replace(standalone_command, '<command label="PPSSPP (RetroArch Core)">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/ppsspp_libretro.so %ROM%</command>')
systems_path.write_text(systems[:start] + block + systems[end:])
PY

# Let ES-DE resolve the bundled standalone PPSSPP launcher.
python3 - "$component_dir/share/es-de/resources/systems/linuxarm/es_find_rules.xml" <<'PY'
from pathlib import Path
import sys

rules_path = Path(sys.argv[1])
rules = rules_path.read_text()
start = rules.index('<emulator name="PPSSPP">')
end = rules.index('</emulator>', start)
block = rules[start:end]
static_path = '<rule type="staticpath">'
launcher = '<entry>/app/retrodeck/components/ppsspp/component_launcher.sh</entry>'
if launcher not in block:
    if static_path not in block:
        raise SystemExit('PPSSPP staticpath rule was not found in ES-DE rules')
    block = block.replace(static_path, static_path + '\n            ' + launcher, 1)
    rules = rules[:start] + block + rules[end:]
    rules_path.write_text(rules)
PY

# Let ES-DE resolve the bundled standalone Ruffle launcher.
python3 - "$component_dir/share/es-de/resources/systems/linuxarm/es_find_rules.xml" <<'PY'
from pathlib import Path
import sys

rules_path = Path(sys.argv[1])
rules = rules_path.read_text()
start = rules.index('<emulator name="RUFFLE">')
end = rules.index('</emulator>', start)
block = rules[start:end]
static_path = '<rule type="staticpath">'
launcher = '<entry>/app/retrodeck/components/ruffle/component_launcher.sh</entry>'
if launcher not in block:
    if static_path not in block:
        raise SystemExit('Ruffle staticpath rule was not found in ES-DE rules')
    block = block.replace(static_path, static_path + '\n            ' + launcher, 1)
    rules_path.write_text(rules[:start] + block + rules[end:])
PY

# Use the bundled GearColeco core as the ARM ColecoVision default.
python3 "$script_dir/set-default-core.py" \
  "$component_dir/share/es-de/resources/systems/linuxarm/es_systems.xml" \
  colecovision Gearcoleco
python3 "$script_dir/set-default-core.py" \
  "$component_dir/share/es-de/resources/systems/linuxarm/es_systems.xml" \
  nds DeSmuME
python3 "$script_dir/set-default-core.py" \
  "$component_dir/share/es-de/resources/systems/linuxarm/es_systems.xml" \
  n64 Mupen64Plus-Next \
  "%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/mupen64plus_next_libretro.so %ROM%"
python3 "$script_dir/set-default-core.py" \
  "$component_dir/share/es-de/resources/systems/linuxarm/es_systems.xml" \
  psx SwanStation

# ES-DE is linked against these three libraries built by the smoke-test
# manifest. Keep their symlinks with the versioned library files.
for library in "$app_files"/lib/libfreeimage* "$app_files"/lib/libgit2* "$app_files"/lib/libpugixml*; do
  if [[ -e "$library" || -L "$library" ]]; then
    cp -a "$library" "$component_dir/lib/"
  fi
done

for asset in component_functions.sh component_launcher.sh component_manifest.json component_prepare.sh component_update.sh; do
  cp -a "$components_root/es-de/$asset" "$component_dir/"
done
cp -a "$components_root/es-de/rd_assets/rd_config" "$component_dir/rd_config"
printf '3.5.0\n' > "$component_dir/component_version"

mkdir -p "$artifact_dir"
archive_tmp="$artifact_dir/es-de.tar.gz.tmp"
tar -czf "$archive_tmp" -C "$component_dir" .
mv -f "$archive_tmp" "$artifact_dir/es-de.tar.gz"
sha256sum "$artifact_dir/es-de.tar.gz" | awk '{print $1}' > "$artifact_dir/es-de.tar.gz.sha"

printf 'Created ARM ES-DE component archive:\n%s\n' "$artifact_dir/es-de.tar.gz"
