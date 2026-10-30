# QuadApollo (Quad AD9084) MATLAB Toolbox

MATLAB toolbox for controlling and characterizing the Quad AD9084 (AD9084-based) X-band development platform. Provides hardware-in-the-loop (HIL) transmit/receive control, calibration, spectral analysis, and beamforming via IIO over Ethernet.

## Files

| File | Description |
|------|-------------|
| **Rx.m** | `adi.QuadAD9084.Rx` system object — IIO-based receiver class for the Quad AD9084 board. Exposes per-chip (A–D) Channel/Main NCO frequency and phase properties for 16 Rx channels. |
| **Tx.m** | `adi.QuadAD9084.Tx` system object — IIO-based transmitter class. Mirrors Rx with per-chip NCO frequency and phase control for 16 Tx channels. |
| **quadApollo.m** | Top-level system class that composes `Rx`, `Tx`, and `analyze`. Handles board initialization, NCO configuration, waveform generation (CW/pulsed/two-tone), Tx/Rx DMA, system calibration, filter control (ADMV8913 LPF/HPF), and channel enable/disable. Default IIO URI: `ip:192.168.2.1`. |
| **analyze.m** | Signal analysis utility class built on the **Genalyzer** library. Provides FFT computation, dB conversion, spectral metrics (SFDR, NSD), time-domain sample plotting, and overlay plotting for multi-channel data. |
| **rx_1tone_800MSPS.json** | Genalyzer FFT analysis configuration for a single-tone test at 800 MSPS data rate (12.8 GSPS ADC, 16× decimation). Defines harmonic distortion order, IMD order, and spectral component tagging. |
| **test_CFIRs.m** | Test script for CFIR (Cascaded FIR) equalizer characterization. Sweeps 8–12 GHz in 100 MHz steps, performs per-channel phase calibration, captures pre-EQ baseline data, and prepares stitched post-EQ storage for flatness correction across NCO positions. |
| **test_quadApolloBeamforming_HIL.m** | Hardware-in-the-loop beamforming test. Configures a 4×4 URA antenna model, performs system calibration, then runs a live loop transmitting combined jammer + target-of-interest signals through loopback while applying MVDR or similar nulling weights. Supports user-specified jammer angles. |
| **test_systemCal.m** | System calibration validation script. Generates a CW tone, captures loopback data before and after Tx/Rx phase calibration (`systemCal`), computes FFT metrics (SFDR, NSD), and plots time/frequency domain results for all 16 channels individually and combined. |

## Dependencies

- [Analog Devices High Speed Converter Toolbox](https://github.com/analogdevicesinc/HighSpeedConverterToolbox) (`adi.common`, `adi.QuadAD9084.Base`)
- [Genalyzer](https://github.com/analogdevicesinc/genalyzer) — spectral analysis library
- MATLAB Phased Array Toolbox (for beamforming tests)
- IIO (libiio) connectivity to the Quad AD9084 board
