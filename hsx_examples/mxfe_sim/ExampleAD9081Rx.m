clear all; clc;

%% Set up AD9081
rx = adi.sim.AD9081.Rx;
% rx.CDDCNCOFrequencies = [0.1e9, -0.2e9, 0.3e9, -0.4e9];
% rx.CDDCNCOEnable = [1,0,0,0];
% rx.MainDataPathDecimation = 2;
% rx.ChannelizerPathDecimation = 6;

%% Generate sinwave
sw = dsp.SineWave;
sw.Amplitude = 1.0; % Full scale is 1.4 Volts
sw.Frequency = 100e6;
sw.SampleRate = rx.SampleRate;
sw.SamplesPerFrame = 12e3;

%% Set up visuals
sa = dsp.SpectrumAnalyzer;
sa.SampleRate = ...
    sw.SampleRate/...
    (rx.MainDataPathDecimation*rx.ChannelizerPathDecimation);
sa.YLimits = [-180 10];
sa.SpectralAverages = 100;
sa.SpectrumType = 'Power density';
sa.SpectrumUnits = 'dBFS';
sa.NumInputPorts = 1;
sa.FullScaleSource = 'Property';
sa.FullScale = 2^11;

%% View output
for k=1:30
    % Pass through chip
    [o1,o2,o3,o4,o5,o6,o7,o8] = rx(sw(),sw(),sw(),sw());
    sa(int16(o1));
end