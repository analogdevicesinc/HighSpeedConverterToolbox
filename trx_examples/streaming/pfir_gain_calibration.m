%% pfir_gain_calibration.m
%
% PURPOSE
%   Determines empirically the PFIR tap value that produces the maximum
%   (loudest) hardware output, to be used as a normalization anchor.
%
% BACKGROUND
%   FIRcoeff.m scales tap values using 2^15 (Q15 format):
%       hardware_value = round(2^15 * tap_float) = round(32768 * tap_float)
%   Theoretically, a single-tap filter with tap_float = 1.0 (hardware = 32767)
%   should produce 0 dB gain. In practice, hardware path loss and ADC noise
%   mean the measured peak may be slightly below 0 dB. The maximum achievable
%   gain IS the correct normalization anchor — it represents the loudest the
%   hardware can produce, which is what we want to normalize to.
%
% METHOD
%   Phase 0 - Reference:
%     Load a disabled-mode PFIR to measure the raw ADC tone level.
%     All gains are reported relative to this.
%
%   Phase 1 - Position sweep:
%     Test 16 single-tap filters (tap_float = 1.0) to find the tap position
%     with the highest response. Confirms uniformity across positions.
%
%   Phase 2 - Value sweep:
%     At the best position, sweep tap_float across a range to find the
%     tap value producing maximum gain (the normalization anchor).
%
%   Phase 3 - Statistical validation:
%     Load the anchor tap once, then take N_REPEATS independent gain
%     measurements with no filter reload between them (fast). Build a
%     histogram to characterise measurement variance. The median is the
%     final reported anchor.
%
% OUTPUT
%   Three-subplot figure: gain vs. tap position, gain vs. tap value,
%   histogram of repeated anchor measurements.
%   Console summary with final normalization anchor and formula.
%
% USAGE
%   Edit the Configuration section below, then run the script.

clear; clc;

%% =========================================================
%  Configuration  
%  =========================================================
URI          = 'ip:192.168.2.1';   % board IP
TONE_FREQ_HZ = 10e6;               % DDS tone frequency (Hz)
                                   % With matched TX/RX NCOs the digital
                                   % baseband tone is always at this offset.
N_SAMPLES    = 16384;              % samples per RX frame
NFFT         = 4096;               % FFT size for power measurement
N_FRAMES     = 4;                  % RX frames to average per measurement
N_TAPS       = 16;                 % PFIR tap count (real_n2 mode = 16)
N_REPEATS    = 500;                % Phase 3: repeated unity-tap measurements for histogram
N_FRAMES_STAT = 4;                 % Phase 3: frames per measurement
N_SWEEP_LOG  = 15;                 % Phase 2: points in log region  (0.01 → 0.3)
N_SWEEP_LIN  = 50;                 % Phase 2: points in linear region (0.3  → 2.0)
                                   % Total sweep points ≈ N_SWEEP_LOG + N_SWEEP_LIN
                                   % Each point costs ~1-2 s; 65 pts ≈ 1-2 min for Phase 2.

% --- Diagnostic-only mode ---
% Set DIAG_ONLY = 1 to skip all sweep phases and just capture + display
% the pre/post-filter diagnostic spectra. A fresh filter file is written
% from PFIR_GAIN, PFIR_SCALAR, DIAG_TAP_POS, and DIAG_TAP_FLOAT each run,
% so you can tweak any of those and immediately see the effect on the spectrum.
% DIAG_TAP_POS   : which tap position to set non-zero (1–N_TAPS)
% DIAG_TAP_FLOAT : tap coefficient value (0 < value <= 0.9999)
DIAG_ONLY      = 1;    % 0 = full calibration run, 1 = spectrum check only
DIAG_TAP_POS   = 8;    % tap position used for the diagnostic filter
DIAG_TAP_FLOAT = 1;    % tap value used for the diagnostic filter

% --- Phase 2 tap sweep (optional) ---
% Set RUN_SWEEP = 1 to run the full tap value sweep (0 → 4.0) via
% pfir_sweep_study.m. Produces a separate figure showing gain vs. tap value,
% linearity check, and register overflow study.
% When RUN_SWEEP = 0 the sweep is skipped and the main figure shows placeholders
% for the Phase 2 subplots.
RUN_SWEEP = 0;   % 0 = skip, 1 = run full tap value sweep

% Gain settings held fixed during calibration.
% Using the same gain/scalar combination as the production filter (pfir_auto.txt)
% to minimize hardware-mode-switch spurs.
% NOTE: observed behaviour suggests scalar_gain may be an attenuation factor
% (lower value = more signal), which is the inverse of the N/64 interpretation
% in the UG. The absolute level does not affect which tap wins the max() — it
% only needs to be constant across all sweep points.
PFIR_GAIN    = "6";
PFIR_SCALAR  = "63";

% Temporary files written during calibration (deleted at the end)
DISABLED_FILE    = 'pfir_cal_disabled.txt';
CFIR_BYPASS_FILE = 'pfir_cal_cfir_bypass.txt';
CAL_FILE         = 'pfir_cal_single.txt';

%% =========================================================
%  Step 1 — Write "disabled" reference filter file
%  =========================================================
% mode: disabled disabled causes the AD9084 driver to bypass the PFIR
% coefficient loading entirely and set both I and Q FIR paths to disabled.
adi.AD9084.writeDisabledFilter(DISABLED_FILE, 'pfir');
adi.AD9084.writeDisabledFilter(CFIR_BYPASS_FILE, 'cfir');

%% =========================================================
%  Step 2 — Configure TX (DDS tone source)
%  =========================================================
fprintf('Connecting TX...\n');
tx = adi.AD9084.Tx('uri', URI);
tx.EnabledChannels       = 1;
tx.SamplesPerFrame       = N_SAMPLES;
tx.DataSource            = 'DDS';
tx.MainNCOFrequencies    = [1e9 0 0 0];
tx.ChannelNCOFrequencies = [0 0 0 0];
tx.MainNCOPhases         = [0 0 0 0];
tx.ChannelNCOPhases      = [0 0 0 0];
tx.NCOEnables            = [true false false false];
tx.DDSFrequencies        = [TONE_FREQ_HZ, TONE_FREQ_HZ; 0, 0];
tx.DDSScales             = [.5, .5; 0, 0];
tx.DDSPhases             = [0, 90000; 0, 0]; % In mili-degrees
tx();
fprintf('TX streaming tone at %.1f MHz.\n', TONE_FREQ_HZ/1e6);

%% =========================================================
%  Step 3 — Configure RX with PFIR enabled, disabled file
%  =========================================================
fprintf('Connecting RX...\n');
rx = adi.AD9084.Rx('uri', URI);
rx.EnabledChannels       = 1;
rx.SamplesPerFrame       = N_SAMPLES;
rx.EnablePFIRs           = true;        % stays true throughout
rx.PFIRFilenames         = DISABLED_FILE;
rx.EnableCFIRs           = true;         % push bypass:1 to override any leftover filter_demo state
rx.CFIRFilenames         = CFIR_BYPASS_FILE;
rx.MainNCOFrequencies    = [1e9 0 0 0];
rx.ChannelNCOFrequencies = [0 0 0 0];
rx.TestMode              = 'off';

fprintf('Priming RX (disabled filter reference)...\n');
rx();
Fs = double(rx.SamplingRate);
fprintf('Fs = %.3f MHz\n', Fs/1e6);

%% =========================================================
%  Phase 0 — Reference level (PFIR disabled)
%  =========================================================
fprintf('\n--- Phase 0: Reference (PFIR disabled) ---\n');

[ref_dBFS, ref_pwr_avg, f_bins] = measureTonePower(rx, TONE_FREQ_HZ, Fs, NFFT, N_FRAMES);
fprintf('  Reference level : %.2f dBFS\n', ref_dBFS);

%% =========================================================
%  Phase 1 — Sweep tap positions (tap_float = 1.0)
%  =========================================================
if ~DIAG_ONLY
gain_by_pos = nan(1, N_TAPS);

for pos = 1:N_TAPS
    taps = zeros(N_TAPS, 1);
    taps(pos) = 1.0;   % Q14 unity: hardware value = round(16384 * 1.0) = 16384

    pf = adi.AD9084.PFilt(taps, 'mode', 'real_n2', ...
                          'gain', PFIR_GAIN, 'scalar_gain', PFIR_SCALAR);
    pf.write(CAL_FILE);

    % Swap filter: unlock -> change file -> re-prime
    release(rx);
    rx.PFIRFilenames = CAL_FILE;
    rx();

    gain_by_pos(pos) = measureTonePower(rx, TONE_FREQ_HZ, Fs, NFFT, N_FRAMES) - ref_dBFS;
    fprintf('  Tap pos %2d/%2d : %+.2f dB\n', pos, N_TAPS, gain_by_pos(pos));
end

[max_gain_pos, best_pos] = max(gain_by_pos);
spread_dB = max(gain_by_pos) - min(gain_by_pos);
fprintf('\n  Best position : tap %d (%+.2f dB)\n', best_pos, max_gain_pos);
fprintf('  Position spread : %.2f dB (should be small if architecture is uniform)\n', spread_dB);

%% =========================================================
%  Phase 2 — Optional tap value sweep (see pfir_sweep_study.m)
%  =========================================================
if RUN_SWEEP
    pfir_sweep_study(rx, best_pos, ref_dBFS, N_TAPS, N_SWEEP_LOG, N_SWEEP_LIN, ...
                     N_FRAMES, NFFT, Fs, TONE_FREQ_HZ, CAL_FILE, PFIR_GAIN, PFIR_SCALAR);
end

% Capture tap=1.0 spectrum for the diagnostic figure regardless of RUN_SWEEP.
% This is the theoretical all-pass: a single delay at unity coefficient.
taps_anc_diag = zeros(N_TAPS, 1);
taps_anc_diag(best_pos) = 1.0;
pf_diag = adi.AD9084.PFilt(taps_anc_diag, 'mode', 'real_n2', ...
                            'gain', PFIR_GAIN, 'scalar_gain', PFIR_SCALAR);
pf_diag.write(CAL_FILE);
release(rx);
rx.PFIRFilenames = CAL_FILE;
rx();
[~, anchor_pwr_avg] = measureTonePower(rx, TONE_FREQ_HZ, Fs, NFFT, N_FRAMES);
diag_filter_label = sprintf('unity tap (1.0) pos %d, gain=%s, scalar=%s', ...
                             best_pos, PFIR_GAIN, PFIR_SCALAR);

else % DIAG_ONLY — write a fresh filter from current config and load it

fprintf('\n--- DIAG_ONLY: Writing diagnostic filter (tap %d = %.5f, gain=%s, scalar=%s) ---\n', ...
        DIAG_TAP_POS, DIAG_TAP_FLOAT, PFIR_GAIN, PFIR_SCALAR);
taps_diag = zeros(N_TAPS, 1);
taps_diag(DIAG_TAP_POS) = DIAG_TAP_FLOAT;
pf_diag_only = adi.AD9084.PFilt(taps_diag, 'mode', 'real_n2', ...
                                 'gain', PFIR_GAIN, 'scalar_gain', PFIR_SCALAR);
pf_diag_only.write(CAL_FILE);
release(rx);
rx.PFIRFilenames = CAL_FILE;
rx();
[~, anchor_pwr_avg] = measureTonePower(rx, TONE_FREQ_HZ, Fs, NFFT, N_FRAMES);
diag_filter_label = sprintf('tap %d = %.5f, gain=%s, scalar=%s', ...
                             DIAG_TAP_POS, DIAG_TAP_FLOAT, PFIR_GAIN, PFIR_SCALAR);

end % DIAG_ONLY

% Figure 2 — centered two-sided diagnostic spectra (IQ data).
% fftshift centers the spectrum at 0 Hz so the x-axis runs -Fs/2 to +Fs/2
% (e.g. -1.25 GHz to +1.25 GHz). With TX/RX NCOs cancelling, the 10 MHz
% DDS tone appears at exactly +10 MHz — slightly right of centre.
% Uses 10*log10(pwr_avg) to convert to dB.
f_bins_centered = (-NFFT/2 : NFFT/2-1).' * Fs / NFFT;

figure('Name', 'PFIR Diagnostic Spectra', 'NumberTitle', 'off', 'Position', [150 150 1100 700]);

% SNR: find the dominant peak (global max of ref spectrum) as the tone bin,
% then exclude ±50 bins around it for the noise floor estimate.
[~, tone_bin_raw] = max(ref_pwr_avg);
snr_mask = true(NFFT, 1);
snr_mask(max(1, tone_bin_raw-50) : min(NFFT, tone_bin_raw+50)) = false;

ref_snr_dB = 10*log10(ref_pwr_avg(tone_bin_raw)      / median(ref_pwr_avg(snr_mask)));
anc_snr_dB = 10*log10(anchor_pwr_avg(tone_bin_raw)   / median(anchor_pwr_avg(snr_mask)));

% Display spectra in dBFS. pwr_avg = |FFT(x.*window)|^2 / n_frames where
% x is normalized by /32768. Dividing by cg^2 (coherent gain squared) converts
% to true dBFS so a full-scale tone appears at 0 dBFS.
cg_diag     = sum(hann(NFFT, 'periodic')) / 2;
ref_shifted = 10*log10(fftshift(ref_pwr_avg)    / cg_diag^2);
anc_shifted = 10*log10(fftshift(anchor_pwr_avg) / cg_diag^2);

subplot(2,1,1);
plot(f_bins_centered, ref_shifted, 'k-', 'LineWidth', 0.8);
xlabel('Frequency (Hz)');
ylabel('Power (dBFS)');
title(sprintf('Diagnostic — Spectrum: PFIR disabled (pre-filter reference)  |  SNR = %.1f dB', ref_snr_dB));
grid on;

% Subplot 2: real-time streaming of post-filter spectrum (DIAG_ONLY) or
% single static snapshot (full calibration run).
ax2 = subplot(2,1,2);
h_line = plot(ax2, f_bins_centered, anc_shifted, 'b-', 'LineWidth', 0.8);
xlabel(ax2, 'Frequency (Hz)');
ylabel(ax2, 'Power (dBFS)');
title(ax2, sprintf('Diagnostic — Spectrum: %s  |  SNR = %.1f dB', diag_filter_label, anc_snr_dB));
grid(ax2, 'on');
drawnow;

if DIAG_ONLY
    fprintf('\nStreaming post-filter spectrum — close the figure to stop.\n');
    window_rt = hann(NFFT, 'periodic');
    cg_rt     = sum(window_rt) / 2;
    while ishandle(h_line)
        % Capture one averaged frame
        pwr_rt = zeros(NFFT, 1);
        for k = 1:N_FRAMES
            d  = rx();
            x  = double(d(1:NFFT, 1)) / 32768;
            X  = fft(x .* window_rt, NFFT);
            pwr_rt = pwr_rt + abs(X).^2;
        end
        pwr_rt   = pwr_rt / N_FRAMES;
        spec_rt  = 10*log10(fftshift(pwr_rt) / cg_rt^2);

        % Update SNR
        [maxp, tb]  = max(pwr_rt);
        sm       = true(NFFT,1);
        sm(max(1,tb-50):min(NFFT,tb+50)) = false;
        snr_rt   = 10*log10(pwr_rt(tb) / (median(pwr_rt(sm)) + eps));

        set(h_line, 'YData', spec_rt);
        title(ax2, sprintf('Diagnostic — Spectrum: %s  |  SNR = %.1f dB', diag_filter_label, snr_rt));
        ylim(ax2, [-120 20]);
        drawnow limitrate;
    end
    if isfile(DISABLED_FILE),    delete(DISABLED_FILE);    end
    if isfile(CFIR_BYPASS_FILE), delete(CFIR_BYPASS_FILE); end
    return;
end

drawnow;

%% =========================================================
%  Phase 3 — Unity tap repeatability: how close is tap_float=1.0 to 0 dB offset?
%  =========================================================
% Writes a single-tap filter at tap_float=1.0 (theoretical all-pass) and
% measures it N_REPEATS times. The distribution of measured dBFS values
% relative to the bypass reference shows the hardware offset and its stability.
fprintf('\n--- Phase 3: Unity-tap repeatability (%d measurements) ---\n', N_REPEATS);

taps_unity = zeros(N_TAPS, 1);
taps_unity(best_pos) = 1.0;
pf_unity = adi.AD9084.PFilt(taps_unity, 'mode', 'real_n2', ...
                             'gain', PFIR_GAIN, 'scalar_gain', PFIR_SCALAR);
pf_unity.write(CAL_FILE);
release(rx);
rx.PFIRFilenames = CAL_FILE;
rx();

unity_meas_dBFS = nan(N_REPEATS, 1);
for r = 1:N_REPEATS
    unity_meas_dBFS(r) = measureTonePower(rx, TONE_FREQ_HZ, Fs, NFFT, N_FRAMES_STAT);
    fprintf('  Run %2d/%2d : %.2f dBFS  (offset = %+.2f dB re bypass)\n', ...
            r, N_REPEATS, unity_meas_dBFS(r), unity_meas_dBFS(r) - ref_dBFS);
end

unity_offset_dB  = unity_meas_dBFS - ref_dBFS;   % dB re: bypass (0 = perfect all-pass)
offset_mean      = mean(unity_offset_dB);
offset_median    = median(unity_offset_dB);
offset_std       = std(unity_offset_dB);

fprintf('\n  tap_float=1.0 offset from bypass — Mean : %+.3f dB\n', offset_mean);
fprintf('  tap_float=1.0 offset from bypass — Median : %+.3f dB\n', offset_median);
fprintf('  tap_float=1.0 offset from bypass — Std  :  %.3f dB\n',  offset_std);

%% =========================================================
%  Plots
%  =========================================================
figure('Name', 'PFIR Gain Calibration', 'NumberTitle', 'off', 'Position', [100 100 1100 500]);

% --- Phase 1: Gain vs. tap position ---
subplot(1,2,1);
bar(1:N_TAPS, gain_by_pos, 'FaceColor', [0.2 0.5 0.8]);
hold on;
yline(0, 'r--', '0 dB ref', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
xlabel('Tap Position');
ylabel('Gain (dB, re: disabled filter)');
title(sprintf('Phase 1 — Gain vs. Tap Position  (tap\\_float = 1.0,  gain = %s dB,  scalar = %s)', ...
              PFIR_GAIN, PFIR_SCALAR));
grid on;
ylim([min(gain_by_pos)-2, max(gain_by_pos)+2]);

% --- Phase 3: Histogram of unity-tap offset ---
subplot(1,2,2);
histogram(unity_offset_dB, min(15, N_REPEATS), ...
          'FaceColor', [0.2 0.7 0.4], 'EdgeColor', 'w', 'Normalization', 'count');
hold on;
xline(offset_median, 'r-',  sprintf('Median = %+.3f dB', offset_median), ...
      'LineWidth', 2, 'LabelVerticalAlignment', 'bottom');
xline(offset_mean,   'b--', sprintf('Mean = %+.3f dB',   offset_mean), ...
      'LineWidth', 1.5, 'LabelVerticalAlignment', 'top');
xline(0, 'k:', '0 dB (ideal)', 'LineWidth', 1, 'LabelVerticalAlignment', 'bottom');
xlabel('Offset from bypass (dB)');
ylabel('Count');
title(sprintf('Phase 3 — Unity tap offset over %d runs  |  std = %.3f dB', ...
              N_REPEATS, offset_std));
grid on;

%% =========================================================
%  Summary
%  =========================================================
fprintf('\n========================================================\n');
fprintf('  PFIR Gain Calibration Summary\n');
fprintf('========================================================\n');
fprintf('  Tone          : %.1f MHz (digital baseband)\n', TONE_FREQ_HZ/1e6);
fprintf('  gain setting  : %s dB\n', PFIR_GAIN);
fprintf('  scalar_gain   : %s  (N/64 = %.4f; NOTE: hardware may be inverse)\n', PFIR_SCALAR, str2double(PFIR_SCALAR)/64);
fprintf('  PFIR mode     : real_n2 (%d taps)\n', N_TAPS);
fprintf('\n  Tap position uniformity:\n');
fprintf('    Best pos    : %d (%+.2f dB)\n', best_pos, max_gain_pos);
fprintf('    Spread      : %.2f dB across all positions\n', spread_dB);
fprintf('\n  Phase 3 — Unity tap (tap_float=1.0) offset from bypass (%d runs):\n', N_REPEATS);
fprintf('    Mean   : %+.3f dB\n', offset_mean);
fprintf('    Median : %+.3f dB\n', offset_median);
fprintf('    Std    :  %.3f dB\n', offset_std);
fprintf('    95%% CI : [%+.3f, %+.3f] dB\n', offset_median - 2*offset_std, offset_median + 2*offset_std);
fprintf('\n  Hardware calibration offset: %+.3f dB\n', offset_mean);
fprintf('  Correction factor (linear) : %.5f\n', 10^(-offset_mean/20));
fprintf('========================================================\n');

%% =========================================================
%  Cleanup
%  =========================================================
if isfile(DISABLED_FILE),    delete(DISABLED_FILE);    end
if isfile(CFIR_BYPASS_FILE), delete(CFIR_BYPASS_FILE); end
% CAL_FILE is intentionally kept so you can inspect the anchor tap filter
% that was loaded during Phase 2. Open it to verify the coefficients.
fprintf('\n  Anchor filter file preserved for inspection: %s\n', CAL_FILE);
fprintf('  (Delete manually when done)\n');

% =========================================================
%  Local helper functions
% =========================================================
function [peak_dBFS, pwr_avg, f_bins] = measureTonePower(rx, tone_hz, Fs, nfft, n_frames)
% measureTonePower  Return the peak power at tone_hz in dBFS.
%   peak_dBFS = measureTonePower(...)            — scalar peak only
%   [~, pwr_avg, f_bins] = measureTonePower(...) — also return raw averaged
%     power spectrum and frequency axis (Hz). To plot exactly as a manual
%     breakpoint would: plot(f_bins, 10*log10(pwr_avg))
%   Averages n_frames FFT periodograms with a Hann window.

    window = hann(nfft, 'periodic');
    cg     = sum(window) / 2;   % coherent gain normalises amplitude

    pwr_sum = zeros(nfft, 1);
    for k = 1:n_frames
        data = rx();
        x    = double(data(1:nfft, 1)) / 32768;   % normalise to FS
        X    = fft(x .* window, nfft);
        pwr_sum = pwr_sum + abs(X).^2;
    end
    pwr_avg = pwr_sum / n_frames;

    f_bins = (0:nfft-1).' * Fs / nfft;

    % Use global max — tone is not at TONE_FREQ_HZ in the captured baseband
    % due to NCO mixing offsets. Hardcoded bin search finds noise, not signal.
    [peak_pwr, ~] = max(pwr_avg);
    peak_dBFS = 10*log10(peak_pwr / cg^2 + eps);
end
