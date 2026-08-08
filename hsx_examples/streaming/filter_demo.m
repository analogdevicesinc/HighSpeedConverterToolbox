
%% AD9084 Real-Time FFT

% Walkthrough of creating filters, analyzing the filters, using the filter
% classes in the HSCT toolbox, creating an RX object and looking at the
% filter on the Washington hardware. For ease of use, the filtView switch have been
% added to turn off/on the filter analysis tool (fvtool).

clear; clc;

%% Configuration
uri = 'ip:192.168.2.1';

%% Switches
filtView = 0;
pfirCompare = 0;  % 1 = show before/after PFIR comparison plot
cfirCompare = 1;  % 1 = show before/after CFIR comparison plot
pfirAllPass = 1;  % 1 = load all-pass instead of designed filter for PFIR
cfirAllPass = 0;  % 1 = load all-pass instead of designed filter for CFIR
PFilt_Fs = 20E9;
CFIR_Fs = 2.5E9;

%% Creating Filters (complex, one-sided using arbmag)
Ntaps = 15;
F_norm = linspace(-1, 1, 501);  % normalized frequency grid [-Fs/2, +Fs/2]

% Low-Pass Filter: passes +0 to +cutoff
amp_LP = double(F_norm < .45 );
D_LP = fdesign.arbmag('N,F,A', Ntaps, F_norm, amp_LP);
EQ_LP = design(D_LP, 'allfir', SystemObject=true);
LPFtaps = EQ_LP{1,2}.Numerator(:);

% Band-Pass Filter: passes +f1 to +f2
amp_BP = double(F_norm > 0.35 & F_norm < 0.7);
D_BP = fdesign.arbmag('N,F,A', Ntaps, F_norm, amp_BP);
EQ_BP = design(D_BP, 'allfir', SystemObject=true);
BPFtaps = EQ_BP{1,2}.Numerator(:);

% High-Pass Filter: passes +cutoff to +Fs/2
amp_HP = double(F_norm > 0.45);
D_HP = fdesign.arbmag('N,F,A', Ntaps, F_norm, amp_HP);
EQ_HP = design(D_HP, 'allfir', SystemObject=true);
HPFtaps = EQ_HP{1,2}.Numerator(:);

%% Viewing Filters
if filtView
    h = fvtool(LPFtaps, 1);
    h.Fs = 2500e6;

    h2 = fvtool(BPFtaps,1);
    h2.Fs = 2500e6;

    h3 = fvtool(HPFtaps,1);
    h3.Fs = 2500e6;
end

%% Using new Filter Classes
% PFilt
if pfirAllPass
    ap_taps = zeros(16, 1); ap_taps(ceil(16/2)) = 1.0;
    pf = adi.AD9084.PFilt(ap_taps, 'mode', 'real_n2', 'gain', "0", 'scalar_gain', "63");
else
    pf = adi.AD9084.PFilt(LPFtaps, "mode", 'real_n2', 'gain', "18", 'scalar_gain', "63");
end
pf.write('pfir_auto.txt');

% CFIR
if cfirAllPass
    ap_taps = zeros(16, 1); ap_taps(ceil(16/2)) = 1.0;
    cf = adi.AD9084.CFIR(ap_taps, 'gain', "0", 'complex_scalar', 32767+0i);
else
    cf = adi.AD9084.CFIR(BPFtaps, "gain", "12");
end
cf.write('cfir_auto.txt');

%% View theoretical filter response (comment out if not needed)
% pf.response(PFilt_Fs, useLUT=true);
cf.response(CFIR_Fs, useLUT=true);

%% --- TX mode selection ---
% TX mode: 'noise'       = wideband white noise via DMA (flat excitation)
%          'chirp'       = linear frequency sweep via DMA (deterministic)
%          'sweep'       = stepped DDS tone sweep (real-time, captures per-freq)
%          'xband_sweep' = stepped DDS sweep with NCOs at 10 GHz (X-band)
%          'dds'         = single DDS tone
txMode = 'dds';

%% --- Create RX object ---
rx = adi.AD9084.Rx('uri', uri);

% Basic RX configuration
rx.EnabledChannels  = 1;
rx.SamplesPerFrame = 16384;

% Enable PFilt
rx.EnablePFIRs     = true;       
rx.PFIRFilenames = 'pfir_auto.txt';

% Enable CFIR
rx.EnableCFIRs    = true;
% rx.CFIRFilenames = 'sparse_test.txt';
rx.CFIRFilenames = 'cfir_auto.txt';

    % Tune NCOs (set to 10 GHz for xband_sweep, 0 otherwise)
    if strcmp(txMode, 'xband_sweep')
        rx.MainNCOFrequencies = [10e9 0 0 0];
    else
        rx.MainNCOFrequencies = [1e9 0 0 0];
    end
    
    rx.ChannelNCOFrequencies = [100e6 0 0 0];

% Turn test mode off
rx.TestMode        = 'off';


%% --- Create TX object ---
tx = adi.AD9084.Tx('uri', uri);
tx.EnabledChannels  = 1;
tx.SamplesPerFrame = 16384;

% Tune NCOs
tx.MainNCOFrequencies    = [1e9 0 0 0];
tx.ChannelNCOFrequencies = [100e6 0 0 0];
tx.MainNCOPhases         = [0 0 0 0];
tx.ChannelNCOPhases      = [0 0 0 0];
tx.NCOEnables            = [true false false false];


switch txMode
    case 'noise'
        % Wideband complex noise — excites all frequencies for filter observation
        tx.DataSource          = 'DMA';
        tx.EnableCyclicBuffers = true;
        N = 16384;
        noise = complex(randn(N,1), randn(N,1));
        noise = int16((2^14) * noise / max(abs(noise)));
        tx(noise);

    case 'chirp'
        % Linear chirp — sweeps from -BW/2 to +BW/2 in one DMA buffer
        tx.DataSource          = 'DMA';
        tx.EnableCyclicBuffers = true;
        Fs_tx = 2.5e9;
        N = 16384;
        t = (0:N-1).' / Fs_tx;
        BW = Fs_tx * 0.8;  % sweep 80% of Nyquist
        chirpSig = exp(1i * pi * BW * (t - t(end)/2).^2 / t(end));
        tx(int16(2^14 * chirpSig));

    case 'sweep'
        % Stepped DDS sweep — configure DDS, sweep happens after RX prime
        tx.DataSource = 'DDS';
        tx.DDSFrequencies = [10e6, 10e6; 0, 0];
        tx.DDSScales      = [0.5, 0.5; 0, 0];
        tx.DDSPhases      = [0, 90000; 0, 0];
        tx();

    case 'xband_sweep'
        % X-band swept DDS — NCO at 10 GHz, DDS sweeps baseband offsets
        tx.MainNCOFrequencies = [10e9 0 0 0];
        tx.DataSource = 'DDS';
        tx.DDSFrequencies = [10e6, 10e6; 0, 0];
        tx.DDSScales      = [0.5, 0.5; 0, 0];
        tx.DDSPhases      = [0, 90000; 0, 0];
        tx();

    case 'dds'
        % Single DDS tone
        tx.DataSource = 'DDS';
        toneFreq = 650e6;
        tx.DDSFrequencies = [toneFreq, toneFreq; 0, 0];
        tx.DDSScales      = [0.8, 0.8; 0, 0];
        tx.DDSPhases      = [90000, 0; 0, 0];
        tx();
end


%% --- Prime RX (this is CRITICAL) ---
% This call will cause an error if Rx is not configured
fprintf('Priming RX...\n');
data = rx();   
fprintf('RX streaming.\n');


%% --- Stepped DDS sweep (runs in 'sweep' or 'xband_sweep' mode) ---
if strcmp(txMode, 'sweep') || strcmp(txMode, 'xband_sweep')
    Fs_rx = double(rx.SamplingRate);
    sweepFreqs = linspace(10e6, Fs_rx/2 * 0.9, 50);
    sweepPower = nan(size(sweepFreqs));
    NFFT = rx.SamplesPerFrame;

    if strcmp(txMode, 'xband_sweep')
        ncoFreq = 10e9;
        rfFreqs = ncoFreq + sweepFreqs;
        plotLabel = sprintf('CFIR Response — X-band Sweep (NCO = %.0f GHz)', ncoFreq/1e9);
    else
        ncoFreq = 0;
        rfFreqs = sweepFreqs;
        plotLabel = 'CFIR Response — Baseband Sweep';
    end

    figure('Name', plotLabel);
    for si = 1:numel(sweepFreqs)
        f = sweepFreqs(si);
        tx.DDSFrequencies = [f, f; 0, 0];
        pause(0.05);
        for k = 1:5, data = rx(); end
        X = fftshift(fft(double(data(:,1)), NFFT));
        sweepPower(si) = max(20*log10(abs(X)/NFFT + eps));
        fprintf('  RF=%.1f MHz  DDS=%.1f MHz -> %.1f dB\n', ...
            rfFreqs(si)/1e6, f/1e6, sweepPower(si));
    end

    plot(rfFreqs/1e9, sweepPower, 'b.-', 'LineWidth', 1.2);
    xlabel('RF Frequency (GHz)'); ylabel('Peak Power (dB)');
    title(plotLabel); grid on;
    fprintf('Sweep complete.\n');
end

%% --- Before/After PFIR comparison ---
if pfirCompare
    adi.AD9084.filter_compare(rx, pf, 'pfir', 'pfir_auto.txt');
end

%% --- Before/After CFIR comparison ---
if cfirCompare
    adi.AD9084.filter_compare(rx, cf, 'cfir', 'cfir_auto.txt');
end

%% --- Start real-time FFT plotting ---
plotting_fft(rx);


