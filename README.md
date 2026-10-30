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

## Support and Documentation

All support questions should be posted in our [EngineerZone](https://ez.analog.com/linux-device-drivers/linux-software-drivers) forums. Documentation is included within the toolbox but additional documentation is avaible on the [ADI Wiki](https://wiki.analog.com/resources/tools-software/hsx-toolbox).

## Hardware Testing (CI)

Hardware tests run on real lab boards via [labgrid](https://github.com/labgrid-project/labgrid), using the reusable [`matlab-hw-request.yml@v3`](https://github.com/tfcollins/labgrid-plugins/blob/main/.github/workflows/matlab-hw-request.yml) workflow from [tfcollins/labgrid-plugins](https://github.com/tfcollins/labgrid-plugins).

**Triggers** — the `hw-matlab` job runs on:
- Pull requests labeled `hw-test`
- Pushes to `master`
- Manual `workflow_dispatch`
- Nightly schedule (05:30 UTC)

**Board map** — `test/hw_ci/board_map.yaml` maps coordinator place tags (`carrier`, `daughter-board`, `hdl-config`) to the board name `runHWTests(<board>)` expects. The most-specific matching row wins. Keep this file in sync with the `switch` statement in `test/runHWTests.m`.

**IIO URI** — `HardwareTests.m` picks up the booted board's URI from the `$IIO_URI` environment variable, which the workflow sets after iiod is verified reachable.

**Local reproduction** — to request a board and run the tests manually:

```bash
adi-lg request --part ad9081 --carrier zcu102 --wait 300 \
  --run "matlab -batch \"addpath(genpath('hdl')); addpath(genpath('test')); runHWTests('zynqmp-zcu102-rev10-ad9081-vm8-l4')\""
```


