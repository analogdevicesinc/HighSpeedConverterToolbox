function pfir_sweep_study(rx, best_pos, ref_dBFS, N_TAPS, N_SWEEP_LOG, N_SWEEP_LIN, ...
                          N_FRAMES, NFFT, Fs, TONE_FREQ_HZ, CAL_FILE, PFIR_GAIN, PFIR_SCALAR)
% pfir_sweep_study  Sweep tap_float from 0 → 4 at the given tap position and
%   plot gain vs. tap value + linearity check.
%
%   Called from pfir_gain_calibration.m when RUN_SWEEP = 1. Produces a
%   standalone figure — does not modify any workspace variables in the caller.
%
%   Inputs:
%     rx            — configured adi.AD9084.Rx System object
%     best_pos      — tap position to set non-zero (from Phase 1)
%     ref_dBFS      — bypass (PFIR disabled) tone power in dBFS
%     N_TAPS        — PFIR tap count
%     N_SWEEP_LOG   — number of log-spaced points (0.01 → 0.3)
%     N_SWEEP_LIN   — number of linear-spaced points (0.3 → 4.0)
%     N_FRAMES      — FFT frames to average per measurement
%     NFFT          — FFT size
%     Fs            — sample rate (Hz)
%     TONE_FREQ_HZ  — DDS tone frequency (Hz)
%     CAL_FILE      — filename for temporary filter file
%     PFIR_GAIN     — gain string passed to PFilt
%     PFIR_SCALAR   — scalar_gain string passed to PFilt

fprintf('\n--- Phase 2 (sweep study): tap position %d, ref = %.2f dBFS ---\n', ...
        best_pos, ref_dBFS);

sweep_vals  = sort(unique([ ...
    logspace(-2, log10(0.3), N_SWEEP_LOG), ...
    linspace(0.3, 4.0, N_SWEEP_LIN),      ...
    ]));
sweep_gains = nan(size(sweep_vals));

for k = 1:numel(sweep_vals)
    v    = sweep_vals(k);
    taps = zeros(N_TAPS, 1);
    taps(best_pos) = v;

    pf = adi.AD9084.PFilt(taps, 'mode', 'real_n2', ...
                          'gain', PFIR_GAIN, 'scalar_gain', PFIR_SCALAR);
    pf.write(CAL_FILE);

    release(rx);
    rx.PFIRFilenames = CAL_FILE;
    rx();

    sweep_gains(k) = measureTonePower(rx, TONE_FREQ_HZ, Fs, NFFT, N_FRAMES) - ref_dBFS;
    fprintf('  tap_float = %.5f  (hw = %5d) : %+.2f dB\n', ...
            v, round(16384*v), sweep_gains(k));
end

[peak_gain, best_val_idx] = max(sweep_gains);
unity_float = sweep_vals(best_val_idx);
unity_hw    = round(16384 * unity_float);

fprintf('  Peak gain : %+.2f dB at tap_float = %.5f (hw = %d)\n', ...
        peak_gain, unity_float, unity_hw);

% Noise floor and signal region masks
gain_min_p2      = min(sweep_gains);
plateau_mask     = sweep_gains < (gain_min_p2 + 3);
noise_floor_est  = median(sweep_gains(plateau_mask));
noise_floor_mask = sweep_gains < (noise_floor_est + 3);

sweep_dBFS = sweep_gains + ref_dBFS;

% ---- Figure ----
figure('Name', 'Phase 2 — Tap Value Sweep Study', 'NumberTitle', 'off', ...
       'Position', [200 200 1100 500]);

% --- Gain vs. tap value ---
subplot(1,2,1);
plot(sweep_vals(~noise_floor_mask), sweep_dBFS(~noise_floor_mask), ...
     'b.-', 'MarkerSize', 12, 'LineWidth', 1.5, 'DisplayName', 'Measurable signal');
hold on;
if any(noise_floor_mask)
    plot(sweep_vals(noise_floor_mask), sweep_dBFS(noise_floor_mask), ...
         'Color', [0.6 0.6 0.6], 'Marker', '.', 'MarkerSize', 10, 'LineStyle', 'none', ...
         'DisplayName', sprintf('Near noise floor (~%.0f dBFS)', noise_floor_est + ref_dBFS));
end
yline(ref_dBFS, 'r--', sprintf('Bypass = %.1f dBFS', ref_dBFS), ...
      'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
yline(noise_floor_est + ref_dBFS, 'k:', ...
      sprintf('Noise ~%.0f dBFS', noise_floor_est + ref_dBFS), ...
      'LineWidth', 1, 'LabelHorizontalAlignment', 'right');
xline(unity_float, 'g--', ...
      sprintf('Peak = %.4f  (hw %d,  %.1f dBFS)', unity_float, unity_hw, peak_gain + ref_dBFS), ...
      'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
legend('Location', 'southeast');
xlabel('tap\_float (Q14 scale)');
ylabel('Power (dBFS)');
title(sprintf('Gain vs. Tap Value  (pos %d)  |  Peak tap = %.4f', best_pos, unity_float));
grid on;

% --- Linearity check: amplitude ratio vs. tap value ---
subplot(1,2,2);
sig_vals  = sweep_vals(~noise_floor_mask);
sig_gains = sweep_gains(~noise_floor_mask);
amp_ratio = sqrt(10.^(sig_gains / 10));

[~, anc_k]    = min(abs(sig_vals - unity_float));
amp_at_anchor = amp_ratio(anc_k);
amp_norm      = amp_ratio * (unity_float / amp_at_anchor);

plot(sig_vals, amp_norm, 'b.-', 'MarkerSize', 12, 'LineWidth', 1.5, ...
     'DisplayName', 'Measured (normalised)');
hold on;
plot([0, max(sig_vals)], [0, max(sig_vals)], 'r--', 'LineWidth', 1.5, ...
     'DisplayName', 'Ideal: amp = tap\_float');
xline(unity_float, 'g--', sprintf('Peak = %.4f', unity_float), ...
      'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
legend('Location', 'northwest');
xlabel('tap\_float');
ylabel('Amplitude ratio (normalised)');
title('Linearity check: amplitude ratio vs. tap value');
grid on;

end % pfir_sweep_study


% =========================================================
%  Local helper (mirrors measureTonePower in main script)
% =========================================================
function [peak_dBFS, pwr_avg, f_bins] = measureTonePower(rx, tone_hz, Fs, nfft, n_frames)
    window = hann(nfft, 'periodic');
    cg     = sum(window) / 2;

    pwr_sum = zeros(nfft, 1);
    for k = 1:n_frames
        data = rx();
        x    = double(data(1:nfft, 1)) / 32768;
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
