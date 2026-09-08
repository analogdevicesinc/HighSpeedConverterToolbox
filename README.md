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
| 2026_R1            | R2025b         | Development build from the `master` branch |

If you use it, and like it - please let us know. If you use it, and hate it - please let us know that too.

## Supported Tools and Releases

We provide support for certain releases of MATLAB. This does not mean older releases will not work but they are not maintained. Currently supported tools are:
- MATLAB R2025b
- Analog Devices HDL branch `hdl_2026_r1`
- AMD Vivado 2025.1

## Hardware Validation

The `MATLAB Hardware Tests` workflow reserves compatible hardware through the
labgrid coordinator at `10.0.0.41:20408`, provisions it, exports `IIO_URI`, and
runs `runHWTests` with MATLAB R2025b. Set the `MATLAB_BIN` repository variable
to the discovered R2025b executable on the selected hardware runner. Hardware
validation requires at least five tests with no failures, errors, or skipped
tests before the workflow passes.

The current board map supports DAQ3 on VCU118. AD9081 `m8_l4` support is also
defined and becomes active when a matching ZCU102 place is available.

## Support and Documentation

All support questions should be posted in our [EngineerZone](https://ez.analog.com/linux-device-drivers/linux-software-drivers) forums. Documentation is included within the toolbox but additional documentation is avaible on the [ADI Wiki](https://wiki.analog.com/resources/tools-software/hsx-toolbox).

