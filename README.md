# Analog Devices, Inc. High Speed Converter Toolbox

Toolbox created by ADI to be used with MATLAB and Simulink with ADI high speed converters.

License : [![License](https://img.shields.io/badge/license-ADI_BSD-blue.svg)](https://github.com/analogdevicesinc/HighSpeedConverterToolbox/blob/master/LICENSE)
Latest Release : [![GitHub release](https://img.shields.io/github/release/analogdevicesinc/HighSpeedConverterToolbox.svg)](https://github.com/analogdevicesinc/HighSpeedConverterToolbox/releases/latest)
Downloads :  [![Github All Releases](https://img.shields.io/github/downloads/analogdevicesinc/HighSpeedConverterToolbox/total.svg)](https://github.com/analogdevicesinc/HighSpeedConverterToolbox/releases/latest) Direct Installer: [![View Analog Devices, Inc. High Speed Converter Toolbox on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/73080-analog-devices-inc-high-speed-converter-toolbox)

As with many open source packages, we use [GitHub](https://github.com/analogdevicesinc/HighSpeedConverterToolbox) to do develop and maintain the source, and [Jenkins](https://jenkins.io/) for continuous integration.
  - If you want to just use HighSpeedConverterToolbox, we suggest using the [latest release](https://github.com/analogdevicesinc/HighSpeedConverterToolbox/releases/latest).
  - If you think you have found a bug in the release, or need a feature which isn't in the release, try the latest **untested** builds from the master branch.

| HDL Branch         | MATLAB Release |  Installer Package  |
|:------------------:|:--------------:|:-------------------:|
| hdl_2026_r1        | R2025b         | Build from source (development) |
| hdl_2022_r2        | R2023b         | <a href="http://swdownloads.analog.com/cse/toolboxes/hsx/master/AnalogDevicesHighSpeedConverterToolbox_v23.2.1.mltbx"><img src="https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png" data-canonical-src="https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png" height="40" /></a>|

If you use it, and like it - please let us know. If you use it, and hate it - please let us know that too.

## Supported Tools and Releases

The development branch targets the following toolchain. Older MATLAB releases may work, but are not maintained:
- Development target: MATLAB R2025b, HDL `hdl_2026_r1`, and Vivado 2025.1.
- [MathWorks tests R2025b HDL Workflow Advisor with Vivado 2024.1](https://www.mathworks.com/help/releases/R2025b/hdlcoder/gs/language-and-tool-version-support.html). Vivado 2025.1 is required by this HDL branch, so this combination needs validation with the toolbox reference designs. The synthesis test workflow allows the unsupported tool version and reports a warning; this is not a MathWorks-supported tool pairing.

The published installer above uses the previous toolchain. Updating the development target does not publish a new installer or change the package version.

HDL targeting includes DAQ2/ZCU102, AD9081/ZCU102, AD9434/ZC706, AD9783/ZCU102, and AD9208/VCU118. AD9739A/ZC706, FMCJESDADC1/ZC706, and AD9265/ZC706 targeting was removed because those projects are unavailable in `hdl_2026_r1`. Their MATLAB streaming interfaces remain available.

## Verifying a source build

Initialize submodules with `git submodule update --init --recursive`, then prepare
the HDL sources with `make -C CI/scripts build`. The prepared bundle records the
upstream HDL revision in `hdl/vendor/AnalogDevices/vivado/HSX_UPSTREAM_COMMIT`.

Set `MATLAB_BIN` and `VIVADO_BIN` when the tools are installed outside the CI
defaults (`/opt/MATLAB/R2025b/bin/matlab` and
`/opt/Xilinx/Vivado/2025.1/bin/vivado`). For example:

```sh
export MATLAB_BIN=/path/to/R2025b/bin/matlab
export VIVADO_BIN=/path/to/Vivado/2025.1/bin/vivado
python3 -m unittest discover -s CI/scripts/tests -v
make -C CI/scripts run_NonHWTests
make -C CI/scripts test_synth BOARD=daq2
```

Repeat synthesis for `ad9081`, `ad9434`, `ad9783`, and `ad9208`, or omit `BOARD`
to run all nine registered variants. Headless synthesis requires `xvfb-run`.
Use a full registered name, such as
`BOARD=AnalogDevices.daq2.zcu102.plugin_rd_rx`, to rerun one synthesis variant.
Build outputs remain in separate directories under `test`, including failed
builds. Success requires completed implementation, passing setup/hold timing,
nonempty bitstream/XSA artifacts, and a boot image for Zynq/ZynqMP targets.
Inspect `hsx_timing_summary.rpt` and `hsx_check_timing.rpt` for unconstrained
paths; an artifact-only check does not establish board-level operation.
AD9208/VCU118 also requires a bitstream-capable Tri Mode Ethernet MAC license;
a `Design_Linking` license is insufficient.

Build documentation with `make -C CI/gen_doc doc` after installing its Python
requirements, then package with `make -C CI/scripts gen_tlbx`. Use
`make -C CI/scripts test_installer` to verify installed reference designs.
For local installer testing, set `MATLAB_PREFDIR` and `HSX_ADDON_ROOT` to fresh,
absolute directories outside the source tree. Installer tests refuse to use
source classes in place of packaged classes and do not uninstall existing
user toolboxes.

## Support and Documentation

All support questions should be posted in our [EngineerZone](https://ez.analog.com/linux-device-drivers/linux-software-drivers) forums. Documentation is included within the toolbox but additional documentation is avaible on the [ADI Wiki](https://wiki.analog.com/resources/tools-software/hsx-toolbox).


