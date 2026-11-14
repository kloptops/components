#!/usr/bin/env python3

from pathlib import Path
import sys


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit(f"Usage: {sys.argv[0]} SYSTEMS_XML")

    systems_path = Path(sys.argv[1])
    contents = systems_path.read_text()
    system_name = "<name>psp</name>"
    name_pos = contents.index(system_name)
    start = contents.rfind("<system>", 0, name_pos)
    end = contents.index("</system>", name_pos) + len("</system>")
    block = contents[start:end]

    core_command = '<command label="PPSSPP">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/ppsspp_libretro.so %ROM%</command>'
    standalone_command = '<command label="PPSSPP (Standalone)">%EMULATOR_PPSSPP% %ROM%</command>'
    if core_command not in block or standalone_command not in block:
        raise SystemExit("Expected PSP RetroArch core and standalone commands were not found")

    block = block.replace(
        core_command,
        '<command label="PPSSPP">%EMULATOR_PPSSPP% %ROM%</command>',
        1,
    )
    block = block.replace(
        standalone_command,
        '<command label="PPSSPP (RetroArch Core)">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/ppsspp_libretro.so %ROM%</command>',
        1,
    )
    systems_path.write_text(contents[:start] + block + contents[end:])


if __name__ == "__main__":
    main()
