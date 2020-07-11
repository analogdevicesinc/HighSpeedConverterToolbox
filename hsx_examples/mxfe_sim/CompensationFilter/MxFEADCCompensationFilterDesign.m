clear all;
%% Import data
MXFEADCResponse = importfile("MXFE_ADC_Response.csv");
 
SampleRate = 5898.24e6;
freq = MXFEADCResponse.VarName1(2:end);
mag = MXFEADCResponse.VarName6(2:end);
mag = 10.^(mag/20);

%% Design compensation filter
FilterOrder = 192; % Make odd to force linear phase
Bands = 2;
N = length(mag);

response = mag.';
frequenciesNorm = freq.'./(SampleRate/2);

% Create inverse target up to a certain frequency
passPercent = 0.9;
passPercentStart = 0.91;
passIndx = floor(N*passPercent);
stopIndx = floor(N*passPercentStart);
A1 = 1./response(1:passIndx);
F1 = frequenciesNorm(1:passIndx);
A2 = zeros(1,N-stopIndx);
F2 = frequenciesNorm(stopIndx+1:N);

% Add target for non-captured bands out to ADC rate
step = mode(diff(frequenciesNorm));
F3 = F2(end)+step:step:1;
A3 = zeros(1,length(F3));

% Set weight for what we favor more
W1 = 1.1      .*ones(1,length(A1));
W2 = 0.00001  .*ones(1,length(A2));
W3 = 0.00001  .*ones(1,length(A3));

figure(1);
plot(F1,A1,F2,A2,F3,A3,frequenciesNorm,response);
legend('A1','A2','A3','ADC Response');
xlabel('Frequency (Normalized)'); ylabel('Magnitude (Linear)');
grid on;
ylim([-0.1 2]);
cd 
% Design filter
d = fdesign.arbmag('N,B,F,A',FilterOrder-1,Bands,F1,A1,[F2,F3],[A2,A3]);
Hd = design(d,'firls','B1Weights',W1,'B2Weights',[W2 W3],'SystemObject',true);

%% Limit filter based on HW
taps = Hd.Numerator;
mode = 'SingleInphase';
[config,tapsInt16,qt,tapError] = DesignPFilt(taps,mode,FilterOrder);
Hd.Numerator = qt./sum(qt);

%% Calculate new filter's response
[responseComp, frequencies] = freqz(Hd,N,SampleRate);

%% Combine responses and view both
combined = 20*log10(responseComp.*response.');
response = 20*log10(response);
responseComp = 20*log10(responseComp);
figure(2);
plot(frequencies, response,frequencies, responseComp, frequencies,combined);

% ylim([ -50 5 ]);
legend('ADC Response','Compensation Response','Combined');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
grid on;

%% 
