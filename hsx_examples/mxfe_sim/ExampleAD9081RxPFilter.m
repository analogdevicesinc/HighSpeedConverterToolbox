%% Example design and usage of PFilter
clear all;

mode = 'SingleInphase';

d = fdesign.lowpass('N,Fc,Ap,Ast',192-1,0.3,0.1,80);
fir = design(d,'equiripple','SystemObject',true);
taps = fir .Numerator;

if length(taps)<97
    N = 96;
else
    N = 192;
end
taps = [taps, zeros(1,N-length(taps))];

% Find best tap quantization for given filter
[config,tapsInt16,qt] = DesignPFilt(taps,mode,N);
%% Plots
close all;
figure(1);
subplot(3,1,1);
yyaxis left
stem(abs(tapsInt16));
xlabel('Tap index');
ylabel('Tap magnitude');
yyaxis right
c = reshape(repmat(config.',1,4).',1,length(config)*4);
stem(c)
ylabel('Bits Per Tap');
grid on;

subplot(3,1,2);
stem(tapsInt16);
xlabel('Tap index');
ylabel('Tap magnitude');
hold on;
stem(qt,'r');
hold off
grid on;

subplot(3,1,3);
stem(abs(tapsInt16-qt));
xlabel('Tap index');
ylabel('Tap magnitude Error');
grid on;

%% Set up AD9081
rx = adi.sim.AD9081.Rx;
rx.PFIREnable = true;

% PFilt configure
rx.PFilter1Mode = 'SingleInphase';
rx.PFilter2Mode = 'SingleInphase';
rx.PFilter1TapsWidthsPerQuad = config;
rx.PFilter2TapsWidthsPerQuad = config;
rx.PFilter1Taps = qt./2^15;
rx.PFilter2Taps = qt./2^15;
rx.PFilter1Gains = [-12,-12,-12,-12];

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
sa.NumInputPorts = 2;
sa.FullScaleSource = 'Property';
sa.FullScale = 2^11;

%% View output
for k=1:30
    % Pass through chip
    [o1,o2,o3,o4,o5,o6,o7,o8] = rx(sw(),sw(),sw(),sw());
    sa(int16(o1),int16(o2));
end
