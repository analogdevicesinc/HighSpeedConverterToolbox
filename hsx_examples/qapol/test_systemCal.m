% Test for System Calibration 
clear all;
close all;
%
x = quadApollo('ip:192.168.2.1'); % create quadApollo Object
x.initialize; % Initialize quadApollo
 
%% Create Waveform
wave = x.createWaveform('cw',-1,x.basebandFreq); %create DMA waveform
x.setTxNCOFreq('Main', 10e9*ones(1,16))
x.setRxNCOFreq('Main', -2.8e9*ones(1,16))
 
 
x.txWaveform(wave); % all DACs
allDAC = x.rx(); %ADC data capture
[allDACFFTMetrics, allDACFFTValdB] = x.FFT(allDAC,false,'onetone');
figure;
x.plotFFT(allDACFFTValdB,true)
title('All DACs Combined Loopback to All ADCs, Individual ADCs')
figure;
x.plotSamples(allDAC,true,[0 300],[-1*round(max(real(allDAC),[],'all'),-1),round(max(real(allDAC),[],'all'),-1)])
title('All DACs Combined Loopback to All ADCs, Individual ADCs')
 
%% Calibrate
 
%phase
[txPhaseOffset, rxPhaseOffset] = x.systemCal; %calibrate
 
x.setTxNCOPhase('Main',(wrapTo180(txPhaseOffset))*1e3);
x.setRxNCOPhase('Main',rxPhaseOffset*1e3);
% 
% %% Combined Loopback
x.calBrdCombinedLoopback;
% x.txWaveform(wave,1); % single DAC
% singleDAC = x.rx(); %ADC data capture
% 
x.txWaveform(wave); % all DACs
allDAC = x.rx(); %ADC data capture
% 
% %amplitude cal
% testAmp = max(real(allDAC));
% testAmpMin = min(testAmp);
% testAmpOffset = testAmpMin./testAmp;
% testWave = testAmpOffset.*wave;
 
% 
% %% Adjacent Loopback
% x.calBrdAdjacentLoopback;
% adjData = x.rx();
% 
% %% Post Process & Plot
% 
% [singleDACFFTMetrics, singleDACFFTValdB] = x.FFT(singleDAC,false,'onetone');
[allDACFFTMetrics, allDACFFTValdB] = x.FFT(allDAC,false,'onetone');
SFDR_NSD = x.metricsFFT(allDACFFTMetrics,'matrix','onetone');
 
[combineFFTMetrics, combineFFTValdB] = x.FFT(sum(allDAC,2),true,'onetone');
SFDR_NSD_combine = x.metricsFFT(combineFFTMetrics,'matrix', 'onetone');
% 
% [adjFFTMetrics, adjFFTValdB] = x.FFT(adjData,false,'onetone');
% [combineAdjFFTMetrics, combineAdjFFTValdB] = x.FFT(sum(adjData,2),true,'onetone');
% 
% x.plotFFT(singleDACFFTValdB,true)
% title('DAC0 Combined Loopback to All ADCs')
figure;
x.plotFFT(allDACFFTValdB,true)
title('All DACs Combined Loopback to All ADCs, Individual ADCs')
% x.plotFFT(combineFFTValdB,true)
% title('All DACs Combined Loopback to All ADCs, Combined ADCs')
% x.plotFFT(adjFFTValdB,true)
% title('All DACs Adjacent Loopback, Individual ADCs')
% x.plotFFT(combineAdjFFTValdB,true)
% title('All DACs Adjacent Loopback, Combined ADCs')
% 
figure;
x.plotSamples(allDAC,true,[0 300],[-1*round(max(real(allDAC),[],'all'),-1),round(max(real(allDAC),[],'all'),-1)])
title('All DACs Combined Loopback to All ADCs, Individual ADCs')
 
ADCCodesallDAC = real(allDAC)
for i = 1:16
    [minValueallDAC(i), idx(i)] = min(ADCCodesallDAC(:,i));
end
[mostmin,finidx] = min(minValueallDAC)
compidx = idx(finidx)
for q = 1:16 
    scalingfactor(q) = ADCCodesallDAC(compidx,q)/ADCCodesallDAC(compidx,finidx);
end
for h = 1:16
    normalizedADCCodesallDAC(:,h) =  ADCCodesallDAC(:,h)/scalingfactor(h);
end
 
figure; 
x.plotSamples(normalizedADCCodesallDAC,true,[0 300],[-1*round(max(real(normalizedADCCodesallDAC),[],'all'),-1),round(max(real(normalizedADCCodesallDAC),[],'all'),-1)])
title('All DACs Combined Loopback to All ADCs, Individual ADCs')
 
% 
% figure()
% ch_values = zeros(16, 3);
% for i = 1:16
%     ch_values(i, :) = [GHz8_DAC(i), GHz10_DAC(i), GHz12_DAC(i)];
%     
% end
% 
% figure()
% xticks(1:16:1);
% yticks(-5:10:0.5);
% grid on
% title('DAC Tone Power vs quadApollo Channel Number')
% legend('8 GHz Tone', '10 GHz Tone', '12 GHz Tone')
% plot(ch_values)
