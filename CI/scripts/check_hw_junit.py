#!/usr/bin/env python3
"""Reject incomplete or empty MATLAB hardware-test JUnit reports."""

import argparse
from pathlib import Path
import sys
import xml.etree.ElementTree as ET


def validate_report(path, minimum_tests):
    root = ET.parse(path).getroot()
    cases = root.findall(".//testcase")
    failed = sum(bool(case.findall("failure") or case.findall("error")) for case in cases)
    skipped = sum(bool(case.findall("skipped")) for case in cases)
    passed = len(cases) - failed - skipped
    print(
        f"{path}: {len(cases)} tests, {passed} passed, "
        f"{failed} failed/errored, {skipped} skipped"
    )
    return len(cases) >= minimum_tests and failed == 0 and skipped == 0


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("reports", nargs="+", type=Path)
    parser.add_argument("--minimum-tests", type=int, default=1)
    args = parser.parse_args(argv)

    valid = True
    for report in args.reports:
        if not report.is_file():
            print(f"Missing hardware-test report: {report}", file=sys.stderr)
            valid = False
            continue
        try:
            valid = validate_report(report, args.minimum_tests) and valid
        except (ET.ParseError, OSError) as error:
            print(f"Invalid hardware-test report {report}: {error}", file=sys.stderr)
            valid = False
    return 0 if valid else 1


if __name__ == "__main__":
    sys.exit(main())
