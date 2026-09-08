#!/bin/bash
set -euo pipefail
set -x

BOARD=$1
MLFLAGS="-nodisplay -nodesktop -nosplash"
VIVADO_VERSION_REQUIRED=2025.1

MLRELEASE="${MLRELEASE:-R2025b}"

MATLAB_BIN="${MATLAB_BIN:-$(command -v matlab || true)}"
if [ ! -x "$MATLAB_BIN" ]; then
	echo "MATLAB executable not found; set MATLAB_BIN or add matlab to PATH" >&2
	exit 1
fi

if [ -n "${VIVADO_SETTINGS:-}" ]; then
	if [ ! -f "$VIVADO_SETTINGS" ]; then
		echo "Vivado settings file not found: $VIVADO_SETTINGS" >&2
		exit 1
	fi
	set +u
	source "$VIVADO_SETTINGS"
	set -u
else
	VIVADO_BIN="${VIVADO_BIN:-$(command -v vivado || true)}"
	if [ ! -x "$VIVADO_BIN" ]; then
		echo "Vivado executable not found; set VIVADO_BIN or add vivado to PATH" >&2
		exit 1
	fi
	VIVADO_BIN="$(readlink -f "$VIVADO_BIN")"
	VIVADO_SETTINGS="$(dirname "$(dirname "$VIVADO_BIN")")/settings64.sh"
	if [ ! -f "$VIVADO_SETTINGS" ]; then
		echo "Vivado settings file not found: $VIVADO_SETTINGS" >&2
		exit 1
	fi
	set +u
	source "$VIVADO_SETTINGS"
	set -u
fi
VIVADO_BIN="${VIVADO_BIN:-$(command -v vivado || true)}"
if [ ! -x "$VIVADO_BIN" ]; then
	echo "Vivado executable not found after loading $VIVADO_SETTINGS" >&2
	exit 1
fi
vivado_output="$("$VIVADO_BIN" -version 2>&1)"
case "${vivado_output,,}" in
	*"vivado v${VIVADO_VERSION_REQUIRED,,}"*) ;;
	*) echo "Expected Vivado $VIVADO_VERSION_REQUIRED at $VIVADO_BIN" >&2; exit 1 ;;
esac

cd ../.. 
cp hdl/vendor/AnalogDevices/hdlcoder_board_customization.m test/hdlcoder_board_customization_local.m
sed -i "s/hdlcoder_board_customization/hdlcoder_board_customization_local/g" test/hdlcoder_board_customization_local.m
# Randomize DISPLAY number to avoid conflicts
export DISPLAY_ID=:$(shuf -i 10-1000 -n 1)
Xvfb $DISPLAY_ID &
XVFB_PID=$!
trap 'kill "$XVFB_PID" 2>/dev/null || true' EXIT
export DISPLAY=$DISPLAY_ID
export SWT_GTK3=0
"$MATLAB_BIN" $MLFLAGS -batch "actual=regexprep(version('-release'),'^R',''); expected=regexprep('$MLRELEASE','^R',''); assert(strcmpi(actual,expected),'Expected MATLAB %s, found %s',expected,actual); cd('test');runSynthTests('$BOARD');"
