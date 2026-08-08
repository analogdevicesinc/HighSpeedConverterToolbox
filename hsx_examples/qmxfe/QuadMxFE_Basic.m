% Basic example of looping back Quad-MxFE (AD9081) using FPGA DDSs
uri = 'ip:192.168.2.1';

%% Tx set up
tx = adi.QuadMxFE.Tx('uri',uri);
tx.DataSource = 'DDS';
toneFreq = 45e6;
tx.DDSFrequencies = repmat(toneFreq,2,64);
tx();

%% Rx set up
rx = adi.QuadMxFE.Rx('uri',uri);
rx.SamplesPerFrame = 1024;

%% Set NCOs to be the same between TX/RX
mainNCOFrequency = 1e6*ones(1,4);
channelNCOFrequency = 2e6*ones(1,4);
for chip = {'A','B','C','D'}
    rx.(['MainNCOFrequenciesChip',chip{:}]) = mainNCOFrequency;
    rx.(['ChannelNCOFrequenciesChip',chip{:}]) = channelNCOFrequency;
    tx.(['MainNCOFrequenciesChip',chip{:}]) = mainNCOFrequency;
    tx.(['ChannelNCOFrequenciesChip',chip{:}]) = channelNCOFrequency;
end

%% Run
for k=1:10
    valid = false;
    while ~valid
        [out, valid] = rx();
    end
end
rx.release();
tx.release();

%% Plot
nSamp = length(out);
fs = tx.SamplingRate;
FFTRxData  = fftshift(10*log10(abs(fft(out))));
df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1000;
plot(freqRangeRx, FFTRxData);
xlabel('Frequency (kHz)');ylabel('Amplitude (dB)');grid on;
