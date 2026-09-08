#!/bin/bash
set -euo pipefail

HDLBRANCH="${HDLBRANCH:-hdl_2026_r1}"

# Script is designed to run from CI/scripts.
scriptdir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$scriptdir/.."

# Get HDL into a temporary directory so a failed clone cannot be mistaken for
# a usable checkout.
rm -rf hdl hdl.clone
for _ in {1..5}; do
    if git clone --depth 1 --single-branch -b "$HDLBRANCH" \
        https://github.com/analogdevicesinc/hdl.git hdl.clone; then
        mv hdl.clone hdl
        break
    fi
    rm -rf hdl.clone
    sleep 2
done
if [ ! -d hdl/.git ]; then
    echo "HDL clone failed for branch $HDLBRANCH" >&2
    exit 1
fi

# HDL moved this declaration from library/scripts/adi_ip*.tcl to
# scripts/adi_env.tcl. Keep compatibility with older branches while preferring
# the release-level source of truth used by hdl_2026_r1.
for candidate in \
    hdl/scripts/adi_env.tcl \
    hdl/library/scripts/adi_ip.tcl \
    hdl/library/scripts/adi_ip_xilinx.tcl; do
    if [ -f "$candidate" ]; then
        TARGET="$candidate"
        if VER=$(python3 scripts/get_required_vivado_version.py "$TARGET"); then
            break
        fi
    fi
done
if [ -z "${VER:-}" ]; then
    echo "Unable to determine required Vivado version from $HDLBRANCH" >&2
    exit 1
fi
echo "Required Vivado version ${VER} (from ${TARGET})"

# gtwiz_parser.pl normally obtains changed transceiver attributes through
# `git diff`. Packaged BSP snapshots omit repository metadata, so generate the
# small diff files directly instead.
python3 scripts/patch_gtwiz_parser.py hdl/projects/scripts/gtwiz_parser.pl

# Rename .prj files since MATLAB ignores them during packaging.
while IFS= read -r referring_file; do
    python3 - "$referring_file" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
p.write_text(s.replace('.prj', '.mk'))
PY
done < <(grep -rl --exclude=Makefile --exclude-dir=.git --fixed-strings '.prj' hdl/projects/common || true)
while IFS= read -r -d '' project_file; do
    mv "$project_file" "${project_file%.prj}.mk"
done < <(find hdl/projects/common -name '*.prj' -print0)

# Remove git metadata and move the reviewed release snapshot into the BSP.
rm -rf hdl/.git*
TARGET_DIR="../hdl/vendor/AnalogDevices/vivado"
rm -rf "$TARGET_DIR"
if [ -f hdl/projects/pluto/system_constr.xdc ]; then
    python3 - <<'PY'
from pathlib import Path
p = Path('hdl/projects/pluto/system_constr.xdc')
p.write_text(p.read_text().replace('16.27', '30'))
PY
fi
mv hdl "$TARGET_DIR"

# Post-process ports.json.
cp scripts/ports.json .
python3 scripts/read_ports_json.py
cp ports.json ../hdl/vendor/AnalogDevices/+AnalogDevices/

# Make every generated HDL Coder plugin advertise the Vivado release required
# by the selected HDL branch. Do not key this rewrite to historical versions:
# individual projects can lag the branch default by several releases.
python3 - "../hdl/vendor/AnalogDevices" "$VER" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
version = sys.argv[2]
pattern = re.compile(r"(?m)^(\s*[^%\r\n]*\.SupportedToolVersion\s*=\s*\{\s*')[^']+('\s*\}\s*;?\s*)$")
replacements = 0
for path in root.rglob('*.m'):
    text = path.read_text()
    updated, count = pattern.subn(rf"\g<1>{version}\g<2>", text)
    if count:
        path.write_text(updated)
        replacements += count
if replacements == 0:
    raise SystemExit('No SupportedToolVersion declarations found in generated BSP')
print(f'Updated {replacements} SupportedToolVersion declarations to {version}')
PY

# Toolbox-specific HDL Coder integration scripts.
#
# NOTE: adi_project_xilinx.tcl is intentionally NOT overwritten. It ships with
# the HDL branch and, since hdl_2026_r1, defines procs the reference-design
# system_project.tcl files depend on (e.g. adi_xcvr_project, used by the
# transceiver-based designs like daq2/ad9434/ad9265/ad9783/ad9208). The older
# toolbox fork lacked that proc and broke "Create Project" for every non-AD9081
# design. The HDL branch version already supports the MATLAB HDL Coder flow
# natively via the ADI_MATLAB env var (see system_project_rxtx.tcl), so we keep
# the branch copy and only layer the genuinely toolbox-only scripts on top.
for script in \
    matlab_processors.tcl system_project_rxtx.tcl \
    adi_build.tcl adi_build_win.tcl fsbl_build_zynq.tcl \
    fsbl_build_zynqmp.tcl pmufw_zynqmp.tcl fixmake.sh; do
    cp "scripts/$script" "../hdl/vendor/AnalogDevices/vivado/projects/scripts/$script"
done

# Guard: the HDL branch must provide adi_xcvr_project. If a future branch drops
# or renames it, fail loudly here rather than deep inside a Vivado create-project
# run that only surfaces after ~15 minutes of IP packaging.
XCVR_TCL="../hdl/vendor/AnalogDevices/vivado/projects/scripts/adi_project_xilinx.tcl"
if ! grep -q 'proc adi_xcvr_project' "$XCVR_TCL"; then
    echo "adi_project_xilinx.tcl is missing 'proc adi_xcvr_project' (HDL branch $HDLBRANCH)" >&2
    exit 1
fi

# adi_xcvr_project shells out to build a standalone xcvr_wizard Vivado project.
# The toolbox runs the top-level design in HDL Coder in-memory mode (ADI_MATLAB),
# but that mode must NOT leak into the nested build or it skips create_project.
# Patch the sub-make to run with ADI_MATLAB/MATLAB unset. Idempotent.
python3 scripts/patch_xcvr_matlab_env.py "$XCVR_TCL"

mkdir -p ../hdl/vendor/AnalogDevices/vivado/projects/common/boot
cp -r scripts/boot/. ../hdl/vendor/AnalogDevices/vivado/projects/common/boot/

DELAY_TCL=../hdl/vendor/AnalogDevices/vivado/library/axi_ad9361/axi_ad9361_delay.tcl
if [ -f "$DELAY_TCL" ]; then
    printf '%s\n' 'puts "Skipping"' > "$DELAY_TCL"
fi
