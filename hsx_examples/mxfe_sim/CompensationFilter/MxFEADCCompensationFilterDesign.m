clear all;

%% Import data from lab measurements
MXFEADCResponse = importfile("MXFE_ADC_Response.csv");
SampleRate = 5898.24e6; % Converter rate
frequencies = MXFEADCResponse.VarName1(2:end);
mag = MXFEADCResponse.VarName6(2:end);
mag = 10.^(mag/20); % Convert from dB to linear
response = mag.';

%% Set design parameters
FilterOrder = 192; % Set filter order to design (Should be set based on PFIR config)
Bands = 2; % Set number of discrete bands/section to optimize (Should be 2)
% First band is the passband second is the stopband
passPercentStop = 0.2; % Normalized frequency stop point of first band
stopPercentStart = 0.21; % Normalized frequency start point of second band
assert(passPercentStop < stopPercentStart)

% Weight passband ripple or stopband attenuation favorability
Band1Weight = 1; % Passband weigth
Band2Weight = 0.0001; % Stopband weigth

%% Create inverse target up to a certain frequency
% Normalize frequency since required by designer
frequenciesNorm = frequencies.' ./(SampleRate/2);
N = length(mag);
passIndx = floor(N*passPercentStop);
stopIndx = floor(N*stopPercentStart);
A1 = 1./response(1:passIndx);
F1 = frequenciesNorm(1:passIndx);
A2 = zeros(1,N-stopIndx);
F2 = frequenciesNorm(stopIndx+1:N);

% Add target for non-captured bands out to ADC rate/2
step = mode(diff(frequenciesNorm));
F3 = F2(end)+step:step:1;
A3 = zeros(1,length(F3));

% Set weights for what we favor more
W1 = Band1Weight.*ones(1,length(A1));
W2 = Band2Weight.*ones(1,length(A2));
W3 = Band2Weight.*ones(1,length(A3));

figure(1);
plot(F1,A1,F2,A2,F3,A3,frequenciesNorm,response);
legend('A1','A2','A3','ADC Response');
xlabel('Frequency (Normalized)'); ylabel('Magnitude (Linear)');
grid on;
ylim([-0.1 2]);

% Design filter
d = fdesign.arbmag('N,B,F,A',FilterOrder-1,Bands,F1,A1,[F2,F3],[A2,A3]);
Hd = design(d,'firls','B1Weights',W1,'B2Weights',[W2 W3],'SystemObject',true);

%% Limit filter based on HW
% This will quantized the generated taps based on limitations of the
% hardware PFIR

% taps = Hd.Numerator;
% mode = 'SingleInphase';
% [config,tapsInt16,qt,tapError] = DesignPFilt(taps,mode,FilterOrder);
% Hd.Numerator = qt./sum(qt);

%% Calculate new filter's response
[responseComp, frequencies] = freqz(Hd,N,SampleRate);
responseComp = abs(responseComp);

%% Combine responses and view both
combined = 20*log10(responseComp.*response.');
response = 20*log10(response);
responseComp = 20*log10(responseComp);
figure(2);
plot(frequencies, response,frequencies, responseComp, frequencies,combined);

legend('ADC Response','Compensation Response','Combined');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
grid on;
