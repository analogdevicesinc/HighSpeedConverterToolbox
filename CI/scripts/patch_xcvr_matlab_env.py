#!/usr/bin/env python3
"""Scrub HDL-Coder MATLAB-mode env vars around the nested xcvr_wizard sub-make.

Since hdl_2026_r1, transceiver-based reference designs call adi_xcvr_project,
which shells out (`eval exec $make_command`) to build a *standalone*
xcvr_wizard Vivado project. The toolbox sets ADI_MATLAB=1 (and legacy MATLAB=1)
to make the top-level reference design reuse HDL Coder's in-memory project.
Tcl `exec` inherits ::env, so those vars leak into the nested Vivado, which then
skips create_project and dies with "No projects are currently open."

This patch wraps the exec so the nested make runs with ADI_MATLAB/MATLAB unset,
restoring them afterward. Idempotent: safe to run on every BSP stage.
"""
from __future__ import annotations

import sys
from pathlib import Path

TARGET_LINE = "  eval exec $make_command\n"
SENTINEL = "_adi_saved_matlab_env"
REPLACEMENT = (
    "  # The nested xcvr_wizard build is a standalone Vivado project and must not\n"
    "  # inherit the HDL Coder in-memory-project mode (ADI_MATLAB/MATLAB); otherwise\n"
    "  # adi_project skips create_project and the sub-build fails with\n"
    '  # "No projects are currently open".\n'
    "  set _adi_saved_matlab_env {}\n"
    "  foreach _adi_ev {ADI_MATLAB MATLAB} {\n"
    "    if {[info exists ::env($_adi_ev)]} {\n"
    "      dict set _adi_saved_matlab_env $_adi_ev $::env($_adi_ev)\n"
    "      unset ::env($_adi_ev)\n"
    "    }\n"
    "  }\n"
    "  eval exec $make_command\n"
    "  dict for {_adi_ev _adi_val} $_adi_saved_matlab_env {\n"
    "    set ::env($_adi_ev) $_adi_val\n"
    "  }\n"
)

# The cfng path adi_xcvr_project reconstructs depends on a fragile
# token-ordering (linsert/tac/MAKELEVEL) that does not match the directory the
# Makefile actually creates when ADI_PROJECT_DIR is unset (the MATLAB/BSP flow).
# Rather than predict the order, glob for the single generated cfng file under
# the xcvr_wizard project dir and use it when the reconstructed path is missing.
RETURN_LINE = (
    '  return [dict create "cfng_file_path" $adi_project_dir_path '
    '"param_file_path" $file_local_param_path]\n'
)
GLOB_SENTINEL = "_adi_xcvr_cfng_glob"
GLOB_FIX = (
    "  # Robust fallback: if the reconstructed cfng path does not exist (the\n"
    "  # xcvr_wizard output directory is named by a Makefile token order that can\n"
    "  # differ from this reconstruction when ADI_PROJECT_DIR is unset), locate\n"
    "  # the actual generated cfng file by globbing. Exactly one is produced per\n"
    "  # xcvr_wizard sub-build.\n"
    "  if {![file exists $adi_project_dir_path]} {\n"
    "    set _adi_xcvr_cfng_glob [glob -nocomplain -directory \\\n"
    "      [file join $ad_hdl_dir/projects $project_name $carrier_name] \\\n"
    "      -- \"*/${project_name}_${carrier_name}.gen/sources_1/ip/${xcvr_type}_cfng.txt\"]\n"
    "    if {[llength $_adi_xcvr_cfng_glob] >= 1} {\n"
    "      set adi_project_dir_path [lindex $_adi_xcvr_cfng_glob 0]\n"
    "      set config_dir_path [file dirname $adi_project_dir_path]\n"
    "      if {$xcvr_type == \"GTXE2\"} {\n"
    "        set file_local_param_path [file join $config_dir_path $config_parser_dir_name $file_local_param]\n"
    "      }\n"
    "    }\n"
    "  }\n"
    "  return [dict create \"cfng_file_path\" $adi_project_dir_path "
    "\"param_file_path\" $file_local_param_path]\n"
)


def main() -> int:
    path = Path(sys.argv[1])
    text = path.read_text()
    changed = False

    if SENTINEL not in text:
        count = text.count(TARGET_LINE)
        if count != 1:
            print(f"ERROR: expected exactly 1 '{TARGET_LINE.strip()}' in {path}, found {count}",
                  file=sys.stderr)
            return 1
        text = text.replace(TARGET_LINE, REPLACEMENT)
        changed = True
    else:
        print("env-scrub already present")

    if GLOB_SENTINEL not in text:
        count = text.count(RETURN_LINE)
        if count != 1:
            print(f"ERROR: expected exactly 1 xcvr return line in {path}, found {count}",
                  file=sys.stderr)
            return 1
        text = text.replace(RETURN_LINE, GLOB_FIX)
        changed = True
    else:
        print("cfng-glob fallback already present")

    if changed:
        path.write_text(text)
        print(f"patched xcvr sub-make env scrub + cfng-glob fallback into {path}")
    else:
        print(f"already fully patched: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
