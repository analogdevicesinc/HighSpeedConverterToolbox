{% include 'header.tmpl' %}

<!-- Hide header and click button -->
<style>
  .md-typeset h1,
  .md-content__button {
    display: none;
  }
</style>

<center>
<div class="dark-logo">
<img src="https://raw.githubusercontent.com/analogdevicesinc/HighSpeedConverterToolbox/master/CI/doc/hsx_300.png" alt="HSX Toolbox" width="80%">
</div>
<div class="light-logo">
<img src="https://raw.githubusercontent.com/analogdevicesinc/HighSpeedConverterToolbox/master/CI/doc/hsx_w_300.png" alt="HSX Toolbox" width="80%">
</div>
</center>


ADI maintains a set of tools to model, interface, and target with ADI high-speed devices within MATLAB and Simulink. These are combined into single Toolbox which contains a set of Board Support Packages (BSP). The list of supported boards is provided below.

The following have device-specific implementations in MATLAB and Simulink. If a device has an IIO driver, MATLAB support is possible, but a device-specific MATLAB or Simulink interface may not exist yet.

| Evaluation Card | FPGA Board | Streaming Support | Targeting | Variants and Minimum Supported Release |
| --------- | --------- | --------- | --------- | --------- |
| DAQ2 (AD9680/AD9144)	| ZC706	| Yes	| No	| ADI (2019a) |
| | ZCU102 | Yes	| Yes	| ADI (2019a) |
| | Arria10 SoC	| Yes	| No	| ADI (2019a) |
| DAQ3 (AD9680/AD9152)	| ZC706	| Yes	| No	| ADI (2021b) |
| | ZCU102 | Yes	| No	| ADI (2021b) |
| | KCU105 | Yes	| No	| ADI (2021b) |
| | Arria10 SoC	| Yes	| No	| ADI (2021b) |
| DualAD9213	| Stratix 10	| Yes	| No	| ADI (2021b) |
| AD9081/AD9082	| ZCU102	| Yes	| Yes	| ADI (2020a) |
| | VCU118	| Yes	| No	| ADI (2020a) |
| AD9083	| ZCU102	| Yes	| No	| ADI (2021b) |
| AD9988/AD9986	| ZCU102	| Yes	| Yes	| ADI (2020a) |
| | VCU118	| Yes	| No	| ADI (2020a) |
| AD9209/AD9177	| ZCU102	| Yes	| Yes	| ADI (2020a) |
| | VCU118	| Yes	| No	| ADI (2020a) |
| QuadMxFE (AD9081 x4)	| VCU118	| Yes	| No	| ADI (2020a) |
| AD9467	| Zedboard	| Yes	| No	| ADI (2018b) |
| FMCJESDADC1	| ZC706	| Yes	| No	| ADI (2021b) |
| FMComms11	| ZC706	| Yes	| No	| ADI (2021b) |
| AD9265	| ZC706	| Yes	| No	| ADI (2021b) |
| AD9434	| ZC706	| Yes	| No	| ADI (2021b) |
| AD9656	| ZCU102	| Yes	| No	| ADI (2021b) |
| AD9695	| ZCU102	| Yes	| No	| ADI (2021b) |
| AD9739a	| ZC706	| Yes	| No	| ADI (2021b) |
| AD9162	| ZC706	| Yes	| No	| ADI (2021b) |
| AD9164	| ZC706	| Yes	| No	| ADI (2021b) |
| AD9152	| ZC706	| Yes	| No	| ADI (2021b) |
