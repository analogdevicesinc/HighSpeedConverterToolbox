#!/bin/bash
set -euo pipefail

BOARD=${1:-}
MLRELEASE=${MLRELEASE:-R2025b}
MATLAB_BIN=${MATLAB_BIN:-/opt/MATLAB/$MLRELEASE/bin/matlab}
VIVADO_BIN=${VIVADO_BIN:-/opt/Xilinx/Vivado/2025.1/bin/vivado}
export VIVADO_BIN
[[ -x "$MATLAB_BIN" ]] || { echo "MATLAB executable not found: $MATLAB_BIN" >&2; exit 1; }
[[ -x "$VIVADO_BIN" ]] || { echo "Vivado executable not found: $VIVADO_BIN" >&2; exit 1; }
export PATH="$(dirname "$VIVADO_BIN"):$PATH"
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
cp hdl/vendor/AnalogDevices/hdlcoder_board_customization.m test/hdlcoder_board_customization_local.m
sed -i 's/hdlcoder_board_customization/hdlcoder_board_customization_local/g' test/hdlcoder_board_customization_local.m
export HSX_TEST_BOARD="$BOARD"
export SWT_GTK3=0
if [[ -z "${DISPLAY:-}" ]]; then
    exec xvfb-run -a "$MATLAB_BIN" -batch "cd('test');runSynthTests(getenv('HSX_TEST_BOARD'));"
fi
exec "$MATLAB_BIN" -batch "cd('test');runSynthTests(getenv('HSX_TEST_BOARD'));"
