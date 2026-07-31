#!/usr/bin/env python3
"""Read required_vivado_version from an ADI HDL Tcl source file."""
from __future__ import annotations

import re
import sys
from pathlib import Path

_PATTERN = re.compile(
    r'^\s*set\s+required_vivado_version\s+["{]?([^"}\s]+)["}]?\s*(?:#.*)?$'
)


def get_required_vivado_version(path: Path) -> str:
    for line in path.read_text(encoding="utf-8").splitlines():
        match = _PATTERN.match(line)
        if match:
            return match.group(1)
    raise ValueError(f"required_vivado_version not found in {path}")


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print(f"usage: {argv[0]} TCL_FILE", file=sys.stderr)
        return 2
    try:
        print(get_required_vivado_version(Path(argv[1])))
    except (OSError, ValueError) as exc:
        print(exc, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
