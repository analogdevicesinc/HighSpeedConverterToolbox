close all; clear all;

% Create an example 192 length filter and generate filter file for hardware
pfir = adi.sim.AD9081.PFIRDesigner;
pfir.Mode = 'DualReal';
pfir.ADCTarget = 'adc_pair_all';
N = 96;

%% Generic HPF
stopPercentStart = 0.2; % Normalized frequency stop point of first band
passPercentStop = 0.4; % Normalized frequency start point of second band
assert(stopPercentStart < passPercentStop)
d = fdesign.highpass('N,Fst,Fp',N-1,stopPercentStart,passPercentStop);
Hdfp = design(d,'firls');

%% Generic LPF
passPercentStop = 0.1; % Normalized frequency stop point of first band
stopPercentStart = 0.2; % Normalized frequency start point of second band
assert(passPercentStop < stopPercentStart)
d = fdesign.lowpass('N,Fp,Fst',N-1,passPercentStop,stopPercentStart);
Hdlp = design(d,'equiripple');
Hd = Hdlp;

%% Limit filter based on HW
% This will quantized the generated taps based on limitations of the
% hardware PFIR
taps = Hd.Numerator;
[config,tapsInt16,qt,tapError] = adi.AD9081.utils.DesignPFilt(taps,pfir.Mode,N);
Hd.Numerator = qt./2^15;
freqz(Hd,8192,4e6);
% Update model
qt = int16(qt/8);
pfir.Taps = [qt;qt];
pfir.TapsWidthsPerQuad = [config;config];
% Create filter file
pfir.ToFile();

%%
uri = 'ip:analog';

%% TX
tx = adi.AD9081.Tx();
tx.uri = uri;
tx.DataSource = 'DDS';
tx.ChannelNCOGainScales = [1,1,1,1].*0.5;
tx.NCOEnables = [1,0,0,0];
toneFreq = 60e6;
tx.DDSFrequencies = repmat(toneFreq,2,4);
tx.DDSScales = 0.5.*ones(2,4);
tx.DDSPhases = zeros(2,4);
tx();

%% RX
rx = adi.AD9081.Rx();
rx.EnabledChannels = [1,2,3,4];
rx.uri = uri;
rx.EnablePFIRs = true;
% rx.PFIRFilenames = pfir.OutputFilename;
rx.PFIRFilenames = {'disable.cfg','reference.ftr'};
for k = 1:20 % Flush
    rx();
end

%%
fs = rx.SamplingRate;
data = rx();
nSamp = length(data);
FFTRxData  = fftshift(10*log10(abs(fft(data))));
df = fs/nSamp;  freqRangeRx = (0:df:fs/2-df).'/1000;
figure(1);plot(freqRangeRx, FFTRxData(end-length(freqRangeRx)+1:end,:));
legend('Channe1','Channe2','Channe3','Channe4');
xlabel('Hz');ylabel('Magnitude (dB)');

rx.release();
tx.release();