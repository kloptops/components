#!/usr/bin/env python3

from pathlib import Path
import sys


def main() -> None:
    if len(sys.argv) != 4:
        raise SystemExit(f"Usage: {sys.argv[0]} SYSTEMS_XML SYSTEM_NAME COMMAND_LABEL")

    systems_path = Path(sys.argv[1])
    system_name, command_label = sys.argv[2:]
    contents = systems_path.read_text()
    start = contents.index(f"<name>{system_name}</name>")
    end = contents.index("</system>", start)
    block = contents[start:end]
    lines = block.splitlines(keepends=True)
    target_index = next(
        (index for index, line in enumerate(lines) if f'<command label="{command_label}">' in line),
        None,
    )
    if target_index is None:
        raise SystemExit(f"Command {command_label!r} missing from system {system_name!r}")

    target = lines.pop(target_index)
    first_command = next(
        (index for index, line in enumerate(lines) if '<command label=' in line),
        None,
    )
    if first_command is None:
        raise SystemExit(f"No commands found for system {system_name!r}")
    lines.insert(first_command, target)
    updated_block = "".join(lines)
    systems_path.write_text(contents[:start] + updated_block + contents[end:])


if __name__ == "__main__":
    main()
