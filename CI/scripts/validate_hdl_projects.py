"""Reject HDL bundles missing files required by registered reference designs."""

from pathlib import Path
import re
import sys


def main():
    hdl = Path(sys.argv[1])
    registry = Path(sys.argv[2])
    boards = re.findall(r"'AnalogDevices\.([\w]+)\.([\w]+)\.plugin_board'",
                        registry.read_text())
    if not boards:
        sys.exit(f'No HDL boards found in {registry}')
    missing = []
    for project, carrier in boards:
        for name in ('system_project.tcl', 'system_top.v', 'system_constr.xdc'):
            path = Path('projects') / project / carrier / name
            if not (hdl / path).is_file():
                missing.append(str(path))
    if missing:
        sys.exit('HDL branch lacks registered reference-design files:\n' + '\n'.join(missing))
    print(f'Validated {len(boards)} registered HDL project/carrier pairs')


if __name__ == '__main__':
    main()
