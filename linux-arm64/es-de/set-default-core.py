#!/usr/bin/env python3

from pathlib import Path
import sys


def main() -> None:
    if len(sys.argv) not in (4, 5):
        raise SystemExit(
            f"Usage: {sys.argv[0]} SYSTEMS_XML SYSTEM_NAME COMMAND_LABEL [COMMAND]"
        )

    systems_path = Path(sys.argv[1])
    system_name, command_label = sys.argv[2:4]
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
        if len(sys.argv) == 4:
            raise SystemExit(
                f"Command {command_label!r} missing from system {system_name!r}"
            )
        first_command = next(
            (index for index, line in enumerate(lines) if '<command label=' in line),
            None,
        )
        if first_command is None:
            raise SystemExit(f"No commands found for system {system_name!r}")
        command_line = lines[first_command]
        indent = command_line[: len(command_line) - len(command_line.lstrip())]
        target = (
            f'{indent}<command label="{command_label}">{sys.argv[4]}</command>\n'
        )
    else:
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
