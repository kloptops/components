#!/usr/bin/env python3

"""Add RetroDECK's PortMaster system to ES-DE's Linux ARM definitions."""

from pathlib import Path
import sys


systems_path = Path(sys.argv[1])
rules_path = Path(sys.argv[2])
systems = systems_path.read_text()
rules = rules_path.read_text()

if '<name>portmaster</name>' not in systems:
    name_pos = systems.index('<name>ports</name>')
    block_end = systems.index('</system>', name_pos) + len('</system>')
    portmaster_system = '''
    <system>
        <name>portmaster</name>
        <fullname>PortMaster</fullname>
        <path>%ROMPATH%/portmaster</path>
        <extension>.sh</extension>
        <command label="PortMaster">%ENABLESHORTCUTS% %EMULATOR_PORTMASTER% %ROM%</command>
        <platform>portmaster</platform>
        <theme>portmaster</theme>
    </system>'''
    systems = systems[:block_end] + portmaster_system + systems[block_end:]
    systems_path.write_text(systems)

if '<emulator name="PORTMASTER">' not in rules:
    portmaster_rule = '''
    <emulator name="PORTMASTER">
        <!-- RetroDECK PortMaster launcher -->
        <rule type="staticpath">
            <entry>/app/retrodeck/components/portmaster/component_launcher.sh</entry>
        </rule>
    </emulator>
'''
    if '</ruleList>' not in rules:
        raise SystemExit('ES-DE ruleList closing tag was not found')
    rules = rules.replace('</ruleList>', portmaster_rule + '</ruleList>', 1)
    rules_path.write_text(rules)
