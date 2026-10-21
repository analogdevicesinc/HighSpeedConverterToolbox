#!/bin/bash
set -ex

if [ -z "${HDLBRANCH}" ]; then
HDLBRANCH='hdl_2026_r1'
fi

# Script is designed to run from specific location
scriptdir=$(dirname "${BASH_SOURCE[0]}")
cd "$scriptdir"
cd ..

# Get HDL
if [ -d "hdl" ]; then
    rm -rf "hdl"
fi
for i in {1..5}
do
	if git clone --single-branch -b "$HDLBRANCH" https://github.com/analogdevicesinc/hdl.git
	then
	   break
	fi
	rm -rf hdl
done
if [ ! -d "hdl" ]; then
   echo "HDL clone failed"
   exit 1
fi

# Get required vivado version needed for HDL
# The literal release moved to adi_env.tcl; ignore variable-based overrides.
VER=""
for TARGET in hdl/scripts/adi_env.tcl hdl/library/scripts/adi_ip.tcl hdl/library/scripts/adi_ip_xilinx.tcl
do
    if [ -f "$TARGET" ]; then
        VER=$(sed -nE 's/^[[:space:]]*set[[:space:]]+required_vivado_version[[:space:]]+"?([0-9]{4}\.[0-9]+(\.[0-9]+)?)"?[[:space:]]*(#.*)?$/\1/p' "$TARGET")
        if [ -n "$VER" ]; then
            break
        fi
    fi
done
if [[ ! "$VER" =~ ^[0-9]{4}\.[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Cannot determine required Vivado version for $HDLBRANCH" >&2
    exit 1
fi
echo "Required Vivado version ${VER}"
python3 ./scripts/validate_hdl_projects.py hdl ../hdl/vendor/AnalogDevices/hdlcoder_board_customization.m

# Preparing sources does not invoke Vivado, so packaging needs no tool install.

# Pre-build IP library
# cd hdl/library
# make
# cd ../..

# Rename .prj files since MATLAB ignores then during packaging
while IFS= read -r -d '' f
do
  echo "Updating prj reference in: $f"
  sed -i "s/\.prj/\.mk/g" "$f"
done < <(grep -rlZ --include='*' --exclude=Makefile --exclude-dir=.git -e '\.prj' hdl/projects/common || test "$?" -eq 1)
while IFS= read -r -d '' f
do
  DEST="${f::-3}mk"
  echo "Renaming: $f to $DEST"
  mv "$f" "$DEST"
done < <(find hdl/projects/common -name '*.prj' -print0)

# Remove git directory move to bsp folder
rm -fr hdl/.git*
TARGET="../hdl/vendor/AnalogDevices/vivado"
if [ -d "$TARGET" ]; then
    rm -rf "$TARGET"
fi
# Increase rx_clk period to fix timing failures for Pluto designs in R2021b
sed -i 's/16.27/30/' hdl/projects/pluto/system_constr.xdc
mv hdl $TARGET

# Post-process ports.json
cp ./scripts/ports.json ./
python3 ./scripts/read_ports_json.py
cp ports.json ../hdl/vendor/AnalogDevices/+AnalogDevices/

# Updates
cp scripts/matlab_processors.tcl ../hdl/vendor/AnalogDevices/vivado/projects/scripts/matlab_processors.tcl
# Retain upstream and add only the parent/child MATLAB flag adapter.
mv ../hdl/vendor/AnalogDevices/vivado/projects/scripts/adi_project_xilinx.tcl ../hdl/vendor/AnalogDevices/vivado/projects/scripts/adi_project_xilinx_upstream.tcl
cp scripts/adi_project_xilinx.tcl ../hdl/vendor/AnalogDevices/vivado/projects/scripts/adi_project_xilinx.tcl
cp scripts/system_project_rxtx.tcl ../hdl/vendor/AnalogDevices/vivado/projects/scripts/system_project_rxtx.tcl
cp scripts/adi_build.tcl ../hdl/vendor/AnalogDevices/vivado/projects/scripts/adi_build.tcl
cp scripts/adi_build_win.tcl ../hdl/vendor/AnalogDevices/vivado/projects/scripts/adi_build_win.tcl

# Copy fsbl files
cp scripts/fsbl_build_zynq.tcl ../hdl/vendor/AnalogDevices/vivado/projects/scripts/fsbl_build_zynq.tcl
cp scripts/fsbl_build_zynqmp.tcl ../hdl/vendor/AnalogDevices/vivado/projects/scripts/fsbl_build_zynqmp.tcl
cp scripts/pmufw_zynqmp.tcl  ../hdl/vendor/AnalogDevices/vivado/projects/scripts/pmufw_zynqmp.tcl
cp scripts/fixmake.sh  ../hdl/vendor/AnalogDevices/vivado/projects/scripts/fixmake.sh

# Copy boot files
mkdir -p ../hdl/vendor/AnalogDevices/vivado/projects/common/boot/
cp -r scripts/boot/* ../hdl/vendor/AnalogDevices/vivado/projects/common/boot/

echo 'puts "Skipping"' > ../hdl/vendor/AnalogDevices/vivado/library/axi_ad9361/axi_ad9361_delay.tcl
