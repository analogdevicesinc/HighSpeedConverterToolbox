%% cfir_gain_lut_study.m — Characterize CFIR gain stages and save gain LUT
% Previously: cfir_gain_study.m (renamed for PR clarity)

clear; clc;
repoRoot = fullfile(fileparts(mfilename('fullpath')), '..', '..');
addpath(genpath(repoRoot));
clear classes
rehash toolboxcache

%% Configuration
uri          = 'ip:192.168.2.1';
N_TAPS       = 16;
TAP_POS      = ceil(N_TAPS / 2);
NFFT         = 4096;
TONE_FREQ_HZ = 10e6;
TAP_FLOAT_FIXED = 2^12;

% --- Toggles ---
DO_TAP_SWEEP        = 1;
DO_TAP_SWEEP_FINE   = 1;
DO_SHIFT_GAIN_SWEEP = 1;

% --- Results output ---
SAVE_RESULTS = true;
RESULTS_ROOT = fullfile(fileparts(mfilename('fullpath')), 'cfir_gain_study_results');

% --- Tap sweep settings ---
SWEEP_N_PTS    = 30;
SWEEP_N_MEAS   = 50;
SWEEP_TAP_VALS = logspace(log10(0.1), log10(2^15), SWEEP_N_PTS);

% --- Fine tap sweep ---
SWEEP_FINE_N_PTS   = 60;
SWEEP_FINE_N_MEAS  = 50;
SWEEP_FINE_TAP_LO  = 0.3;
SWEEP_FINE_TAP_HI  = 2.5;

% --- Shift gain sweep settings ---
SHIFT_GAIN_N_MEAS = 50;

%% Set up results folder
if SAVE_RESULTS
    if ~exist(RESULTS_ROOT, 'dir'), mkdir(RESULTS_ROOT); end
    existing = dir(fullfile(RESULTS_ROOT, 'run_*'));
    run_num  = numel(existing) + 1;
    RUN_DIR  = fullfile(RESULTS_ROOT, sprintf('run_%03d', run_num));
    mkdir(RUN_DIR);
    fprintf('Results will be saved to: %s\n', RUN_DIR);
end

%% Write reference CFIR all-pass filter file
% All-pass = unity center tap, gain=0, complex_scalar=[32767 0]
allpass_taps = zeros(N_TAPS, 1);
allpass_taps(TAP_POS) = 1.0;
cf_ref = adi.AD9084.CFIR(allpass_taps, 'gain', "0", 'complex_scalar', [32767 0]);
cf_ref.write(fullfile(RUN_DIR, 'cfir_gain_study_allpass.txt'));

% Disable PFIR so it doesn't color the measurement
adi.AD9084.writeDisabledFilter(fullfile(RUN_DIR, 'cfir_gain_study_pfir_off.txt'), 'pfir');

%% Configure TX (identical to PFIR gain_study)
tx = adi.AD9084.Tx('uri', uri);

tx.EnabledChannels       = 1;
tx.SamplesPerFrame       = 16384;
tx.DataSource            = 'DDS';
tx.MainNCOFrequencies    = [1e9 0 0 0];
tx.ChannelNCOFrequencies = [100e6 0 0 0];
tx.MainNCOPhases         = [0 0 0 0];
tx.ChannelNCOPhases      = [0 0 0 0];
tx.NCOEnables            = [true false false false];
tx.DDSFrequencies        = [TONE_FREQ_HZ, TONE_FREQ_HZ; 0, 0];
tx.DDSScales             = [.5, .5; 0, 0];
tx.DDSPhases             = [0, 90000; 0, 0];
tx();

%% Configure RX — start with CFIR all-pass (reference)
rx = adi.AD9084.Rx('uri', uri);

rx.EnabledChannels       = 1;
rx.SamplesPerFrame       = 16384;
rx.EnablePFIRs           = true;
rx.PFIRFilenames         = fullfile(RUN_DIR, 'cfir_gain_study_pfir_off.txt');
rx.EnableCFIRs           = true;
rx.CFIRFilenames         = fullfile(RUN_DIR, 'cfir_gain_study_allpass.txt');
rx.MainNCOFrequencies    = [1e9 0 0 0];
rx.ChannelNCOFrequencies = [100e6 0 0 0];
rx.TestMode              = 'off';
rx();

%% Capture all-pass reference snapshot
window   = hann(NFFT, 'periodic');
cg       = sum(window) / 2;
Fs       = double(rx.SamplingRate);

data     = rx();
x        = double(data(1:NFFT, 1)) / 32768;
X        = fftshift(fft(x .* window, NFFT));
ref_mag  = 20*log10(abs(X) / cg + eps);
ref_peak = max(ref_mag);
f_bins   = linspace(-Fs/2, Fs/2, NFFT) / 1e6;

fprintf('CFIR all-pass reference peak: %.2f dBFS\n', ref_peak);

%% Tap sweep
if DO_TAP_SWEEP
    fprintf('\nCFIR Tap sweep: %d values from %.2f to %.0f ...\n', ...
            SWEEP_N_PTS, SWEEP_TAP_VALS(1), SWEEP_TAP_VALS(end));
    sweep_gains = nan(SWEEP_N_PTS, 1);
    sweep_stds  = nan(SWEEP_N_PTS, 1);

    for si = 1:SWEEP_N_PTS
        tv = SWEEP_TAP_VALS(si);
        t  = zeros(N_TAPS, 1);  t(TAP_POS) = tv;
        cf_sw = adi.AD9084.CFIR(t, 'gain', "0", 'complex_scalar', [32767 0]);
        cf_sw.write(fullfile(RUN_DIR, 'cfir_gain_study_sweep_tmp.txt'));

        release(rx);
        rx.CFIRFilenames = fullfile(RUN_DIR, 'cfir_gain_study_sweep_tmp.txt');
        rx();

        peaks = nan(SWEEP_N_MEAS, 1);
        for m = 1:SWEEP_N_MEAS
            d = rx();
            xm = double(d(1:NFFT,1)) / 32768;
            Xm = fftshift(fft(xm .* window, NFFT));
            peaks(m) = max(20*log10(abs(Xm) / cg + eps));
        end
        sweep_gains(si) = mean(peaks) - ref_peak;
        sweep_stds(si)  = std(peaks);
        fprintf('  tap=%.4f  gain=%+.2f dB  std=%.3f dB\n', tv, sweep_gains(si), sweep_stds(si));
    end

    fig_sweep = figure('Name', 'CFIR Gain Study - Tap Sweep', 'NumberTitle', 'off', 'Position', [800 350 750 420]);
    errorbar(SWEEP_TAP_VALS, sweep_gains, sweep_stds, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 12, 'CapSize', 4);
    set(gca, 'XScale', 'log');
    xlabel('tap\_float (log scale)'); ylabel('\Deltapeak re: all-pass (dB)');
    title('CFIR Gain vs tap\_float  (middle tap)');
    grid on;
    xline(1.0, 'r--', 'tap=1.0', 'LineWidth', 1.2, 'LabelVerticalAlignment', 'bottom');
    drawnow;
    if SAVE_RESULTS
        saveFig(RUN_DIR, 'cfir_tap_sweep', fig_sweep);
        fprintf('CFIR tap sweep figure saved.\n');
    end
end

%% Fine tap sweep
if DO_TAP_SWEEP_FINE
    if DO_TAP_SWEEP
        gain_range = max(sweep_gains) - min(sweep_gains);
        lo_thresh  = min(sweep_gains) + 0.10 * gain_range;
        hi_thresh  = min(sweep_gains) + 0.90 * gain_range;
        lo_idx = find(sweep_gains >= lo_thresh, 1, 'first');
        hi_idx = find(sweep_gains >= hi_thresh, 1, 'first');
        if ~isempty(lo_idx) && ~isempty(hi_idx) && hi_idx > lo_idx
            lo_idx = max(1, lo_idx - 1);
            hi_idx = min(SWEEP_N_PTS, hi_idx + 2);
            SWEEP_FINE_TAP_LO = SWEEP_TAP_VALS(lo_idx);
            SWEEP_FINE_TAP_HI = SWEEP_TAP_VALS(hi_idx);
            fprintf('\n  Auto-detected inflection region: [%.3f, %.3f]\n', ...
                    SWEEP_FINE_TAP_LO, SWEEP_FINE_TAP_HI);
        end
    end

    fine_tap_vals  = linspace(SWEEP_FINE_TAP_LO, SWEEP_FINE_TAP_HI, SWEEP_FINE_N_PTS);
    fine_gains     = nan(SWEEP_FINE_N_PTS, 1);
    fine_stds      = nan(SWEEP_FINE_N_PTS, 1);

    fprintf('\nCFIR Fine tap sweep: %.3f to %.3f (%d pts, %d meas each) ...\n', ...
            SWEEP_FINE_TAP_LO, SWEEP_FINE_TAP_HI, SWEEP_FINE_N_PTS, SWEEP_FINE_N_MEAS);

    for si = 1:SWEEP_FINE_N_PTS
        tv = fine_tap_vals(si);
        t  = zeros(N_TAPS, 1);  t(TAP_POS) = tv;
        cf_fn = adi.AD9084.CFIR(t, 'gain', "0", 'complex_scalar', [32767 0]);
        cf_fn.write(fullfile(RUN_DIR, 'cfir_gain_study_fine_tmp.txt'));

        release(rx);
        rx.CFIRFilenames = fullfile(RUN_DIR, 'cfir_gain_study_fine_tmp.txt');
        rx();

        peaks_fn = nan(SWEEP_FINE_N_MEAS, 1);
        for m = 1:SWEEP_FINE_N_MEAS
            d = rx();
            xm = double(d(1:NFFT,1)) / 32768;
            Xm = fftshift(fft(xm .* window, NFFT));
            peaks_fn(m) = max(20*log10(abs(Xm) / cg + eps));
        end
        fine_gains(si) = mean(peaks_fn) - ref_peak;
        fine_stds(si)  = std(peaks_fn);
        fprintf('  tap=%.4f  gain=%+.2f dB  std=%.3f dB\n', tv, fine_gains(si), fine_stds(si));
    end

    fig_fine = figure('Name', 'CFIR Gain Study - Fine Tap Sweep', 'NumberTitle', 'off', 'Position', [800 350 750 420]);
    errorbar(fine_tap_vals, fine_gains, fine_stds, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 10, 'CapSize', 4);
    hold on;
    xline(1.0, 'r:', 'tap=1.0', 'LineWidth', 1.0, 'LabelVerticalAlignment', 'bottom');
    xlabel('tap\_float (linear)'); ylabel('\Deltapeak re: all-pass (dB)');
    title(sprintf('CFIR Gain vs tap\\_float  [%.2f – %.2f]', ...
                  SWEEP_FINE_TAP_LO, SWEEP_FINE_TAP_HI));
    grid on;
    drawnow;

    if SAVE_RESULTS
        saveFig(RUN_DIR, 'cfir_tap_sweep_fine', fig_fine);
        fprintf('CFIR fine sweep figure saved.\n');
    end
end

%% Shift gain sweep
if DO_SHIFT_GAIN_SWEEP
    shift_gain_vals = [-18, -12, -6, 0, 6, 12];
    n_shift = numel(shift_gain_vals);
    shift_gains = nan(n_shift, 1);
    shift_stds  = nan(n_shift, 1);

    fprintf('\nCFIR Shift gain sweep: [-18, -12, -6, 0, 6, 12] dB (%d values, %d meas each) ...\n', ...
            n_shift, SHIFT_GAIN_N_MEAS);

    taps_shg = zeros(N_TAPS, 1);  taps_shg(TAP_POS) = TAP_FLOAT_FIXED;

    for si = 1:n_shift
        sg_dB = shift_gain_vals(si);
        cf_shg = adi.AD9084.CFIR(taps_shg, 'gain', string(sg_dB), 'complex_scalar', [32767 0]);
        cf_shg.write(fullfile(RUN_DIR, 'cfir_gain_study_shift_tmp.txt'));

        release(rx);
        rx.CFIRFilenames = fullfile(RUN_DIR, 'cfir_gain_study_shift_tmp.txt');
        rx();

        peaks_shg = nan(SHIFT_GAIN_N_MEAS, 1);
        for m = 1:SHIFT_GAIN_N_MEAS
            d = rx();
            xm = double(d(1:NFFT,1)) / 32768;
            Xm = fftshift(fft(xm .* window, NFFT));
            peaks_shg(m) = max(20*log10(abs(Xm) / cg + eps));
        end
        shift_gains(si) = mean(peaks_shg) - ref_peak;
        shift_stds(si)  = std(peaks_shg);
        fprintf('  shift_gain=%3d dB  measured=%+.3f dB  std=%.3f dB\n', ...
                sg_dB, shift_gains(si), shift_stds(si));
    end

    fig_shift = figure('Name', 'CFIR Gain Study - Shift Gain Sweep', 'NumberTitle', 'off', 'Position', [800 100 750 420]);
    errorbar(shift_gain_vals, shift_gains, shift_stds, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 10, 'CapSize', 3);
    hold on;
    plot(shift_gain_vals, shift_gain_vals, 'r--', 'LineWidth', 1.2);
    xlabel('Programmed Shift Gain (dB)'); ylabel('Measured \Deltapeak (dB)');
    title(sprintf('CFIR: Measured vs Programmed Shift Gain  (tap\\_float=%.0f)', TAP_FLOAT_FIXED));
    legend('Measured', 'Ideal (1:1)', 'Location', 'NorthWest');
    grid on;
    drawnow;

    if SAVE_RESULTS
        saveFig(RUN_DIR, 'cfir_shift_gain_sweep', fig_shift);
        fprintf('CFIR shift gain sweep figure saved.\n');
    end
end

%% Save CFIR gain lookup table
if SAVE_RESULTS
    lut_path = fullfile(RUN_DIR, 'cfir_gain_lut.m');
    fid = fopen(lut_path, 'w');

    fprintf(fid, 'function lut = cfir_gain_lut()\n');
    fprintf(fid, '%%%% CFIR Gain lookup table generated by cfir_gain_study.m\n');
    fprintf(fid, '%%%% Timestamp: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid, '%%%% Board URI: %s\n\n', uri);
    fprintf(fid, 'lut.board_uri = ''%s'';\n', uri);
    fprintf(fid, 'lut.tone_hz = %g;\n', TONE_FREQ_HZ);
    fprintf(fid, 'lut.adc_sample_rate_hz = %g;\n', Fs);
    fprintf(fid, 'lut.filter_block = ''cfir'';\n\n');

    if DO_TAP_SWEEP
        fprintf(fid, '%%%% Tap sweep (gain vs tap_float)\n');
        fprintf(fid, 'lut.tap_sweep.tap_values = %s;\n', mat2str(SWEEP_TAP_VALS, 6));
        fprintf(fid, 'lut.tap_sweep.gain_dB = %s;\n', mat2str(sweep_gains(:).', 6));
        fprintf(fid, 'lut.tap_sweep.std_dB = %s;\n', mat2str(sweep_stds(:).', 6));
        fprintf(fid, 'lut.tap_sweep.config.n_taps = %d;\n', N_TAPS);
        fprintf(fid, 'lut.tap_sweep.config.tap_pos = %d;\n', TAP_POS);
        fprintf(fid, 'lut.tap_sweep.config.shift_gain_dB = 0;\n');
        fprintf(fid, 'lut.tap_sweep.config.complex_scalar = [32767 0];\n');
        fprintf(fid, 'lut.tap_sweep.config.n_meas = %d;\n\n', SWEEP_N_MEAS);
    end

    if DO_SHIFT_GAIN_SWEEP
        fprintf(fid, '%%%% Shift gain sweep (gain vs shift_gain setting)\n');
        fprintf(fid, 'lut.shift_gain_sweep.shift_gain_values_dB = %s;\n', mat2str(shift_gain_vals));
        fprintf(fid, 'lut.shift_gain_sweep.gain_dB = %s;\n', mat2str(shift_gains(:).', 6));
        fprintf(fid, 'lut.shift_gain_sweep.std_dB = %s;\n', mat2str(shift_stds(:).', 6));
        fprintf(fid, 'lut.shift_gain_sweep.config.tap_float_fixed = %g;\n', TAP_FLOAT_FIXED);
        fprintf(fid, 'lut.shift_gain_sweep.config.complex_scalar = [32767 0];\n');
        fprintf(fid, 'lut.shift_gain_sweep.config.n_meas = %d;\n\n', SHIFT_GAIN_N_MEAS);
    end

    fprintf(fid, 'end\n');
    fclose(fid);
    fprintf('CFIR Gain LUT function saved to: %s\n', lut_path);
end

fprintf('\nCFIR gain study complete.\n');

%% =========================================================
%  Local helpers
%  =========================================================
function saveFig(run_dir, name, fig)
    if ~ishandle(fig), return; end
    base = fullfile(run_dir, name);
    exportgraphics(fig, [base '.png'], 'Resolution', 150);
    savefig(fig, [base '.fig']);
end
