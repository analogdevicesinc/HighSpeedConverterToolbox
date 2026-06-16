%% pfir_gain_lut_study.m — Characterize PFIR gain stages and save gain LUT
% Previously: gain_study.m (renamed for PR clarity)

clear; clc;
repoRoot = fullfile(fileparts(mfilename('fullpath')), '..', '..');
addpath(genpath(repoRoot));
clear classes
rehash toolboxcache

%% Configuration
uri          = 'ip:192.168.2.1';
N_TAPS       = 16;
TAP_POS      = ceil(N_TAPS / 2);  % middle tap
NFFT         = 4096;
N_STAT       = 500;
TONE_FREQ_HZ = 10e6;
TAP_FLOAT_FIXED = 2^12;  % <-- fixed single-tap value used for filtered vs unfiltered comparison

% --- Toggles ---
DO_TAP_SWEEP       = 0;  % run gain vs tap_float sweep before live stream
DO_TAP_SWEEP_FINE  = 0;  % run fine tap sweep zoomed around the inflection region
DO_SCALAR_SWEEP    = 0;  % run gain vs scalar_gain (0-64) sweep before live stream
DO_SHIFT_GAIN_SWEEP = 1; % run gain vs shift_gain (0/6/12/18/24 dB) sweep
SHOW_SPECTRA       = 0;  % Figure 1: live spectrum
SHOW_STATS         = 0;  % Figure 2: scatter + errorbar
SHOW_HIST          = false; % Figure 3: histogram

% --- Results output ---
SAVE_RESULTS = true;   % save figures to MATLAB/gain_study_results/run_NNN/
RESULTS_ROOT = fullfile(fileparts(mfilename('fullpath')), 'gain_study_results');

% --- Tap sweep settings (only used when DO_TAP_SWEEP = true) ---
SWEEP_N_PTS    = 30;    % number of tap values to test
SWEEP_N_MEAS   = 50;    % measurements per tap value
% log-spaced from 0.1 to 2^15; reveals saturation knee
SWEEP_TAP_VALS = logspace(log10(0.1), log10(2^15), SWEEP_N_PTS);

% --- Fine tap sweep (zoomed in around inflection, only when DO_TAP_SWEEP_FINE = true) ---
SWEEP_FINE_N_PTS   = 60;    % points in fine range (linear spacing)
SWEEP_FINE_N_MEAS  = 50;    % measurements per fine tap value
% Defaults used when DO_TAP_SWEEP is false (no coarse data to auto-detect from)
SWEEP_FINE_TAP_LO  = 0.3;
SWEEP_FINE_TAP_HI  = 2.5;

% --- Scalar gain sweep settings (only used when DO_SCALAR_SWEEP = true) ---
SCALAR_N_MEAS  = 50;    % measurements per scalar value (0-64, all integers)

% --- Shift gain sweep settings (only used when DO_SHIFT_GAIN_SWEEP = true) ---
SHIFT_GAIN_N_MEAS = 50;   % measurements per shift gain value

%% Set up results folder for this run
if SAVE_RESULTS
    if ~exist(RESULTS_ROOT, 'dir'), mkdir(RESULTS_ROOT); end
    existing = dir(fullfile(RESULTS_ROOT, 'run_*'));
    run_num  = numel(existing) + 1;
    RUN_DIR  = fullfile(RESULTS_ROOT, sprintf('run_%03d', run_num));
    mkdir(RUN_DIR);
    fprintf('Results will be saved to: %s\n', RUN_DIR);
end

%% Write filter files
adi.AD9084.writeDisabledFilter(fullfile(RUN_DIR, 'gain_study_pfir_off.txt'), 'pfir');

taps = zeros(N_TAPS, 1);
taps(TAP_POS) = TAP_FLOAT_FIXED;
pf = adi.AD9084.PFilt(taps, 'mode', 'real_n2', 'gain', "0", 'scalar_gain', "63");

pf.write(fullfile(RUN_DIR, 'gain_study_filter.txt'));

%% Configure TX
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
tx.DDSScales             = [.8, .8; 0, 0];
tx.DDSPhases             = [90000, 0; 0, 0];
tx();

%% Configure RX - start with PFIR disabled (reference)
rx = adi.AD9084.Rx('uri', uri);

rx.EnabledChannels       = 1;
rx.SamplesPerFrame       = 16384;
rx.EnablePFIRs           = true;
rx.PFIRFilenames         = fullfile(RUN_DIR, 'gain_study_pfir_off.txt');
rx.EnableCFIRs           = false;
rx.MainNCOFrequencies    = [1e9 0 0 0];
rx.ChannelNCOFrequencies = [100e6 0 0 0];
rx.TestMode              = 'off';
rx();

%% Capture unfiltered reference snapshot
window   = hann(NFFT, 'periodic');
cg       = sum(window) / 2;
Fs       = double(rx.SamplingRate);

data     = rx();
x        = double(data(1:NFFT, 1)) / 32768;
X        = fftshift(fft(x .* window, NFFT));
ref_mag  = 20*log10(abs(X) / cg + eps);
ref_peak = max(ref_mag);
f_bins   = linspace(-Fs/2, Fs/2, NFFT) / 1e6;
[~, ref_peak_idx] = max(ref_mag);
ref_peak_freq_MHz = f_bins(ref_peak_idx);

fprintf('Reference peak: %.2f dBFS\n', ref_peak);

%% Tap sweep (optional)
if DO_TAP_SWEEP
    fprintf('\nTap sweep: %d values from %.2f to %.0f ...\n', ...
            SWEEP_N_PTS, SWEEP_TAP_VALS(1), SWEEP_TAP_VALS(end));
    sweep_gains = nan(SWEEP_N_PTS, 1);
    sweep_stds  = nan(SWEEP_N_PTS, 1);

    for si = 1:SWEEP_N_PTS
        tv = SWEEP_TAP_VALS(si);
        t  = zeros(N_TAPS, 1);  t(TAP_POS) = tv;
        pf_sw = adi.AD9084.PFilt(t, 'mode', 'real_n2', 'gain', "0", 'scalar_gain', "63");
        pf_sw.write(fullfile(RUN_DIR, 'gain_study_sweep_tmp.txt'));

        release(rx);
        rx.PFIRFilenames = fullfile(RUN_DIR, 'gain_study_sweep_tmp.txt');
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

    fig_sweep = figure('Name', 'Gain Study - Tap Sweep', 'NumberTitle', 'off', 'Position', [800 350 750 420]);
    errorbar(SWEEP_TAP_VALS, sweep_gains, sweep_stds, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 12, 'CapSize', 4);
    set(gca, 'XScale', 'log');
    xlabel('tap\_float (log scale)'); ylabel('\Deltapeak re: disabled (dB)');
    title('Gain vs tap\_float  (middle tap, real\_n2)');
    grid on;
    xline(1.0, 'r--', 'tap=1.0 (full scale)', 'LineWidth', 1.2, 'LabelVerticalAlignment', 'bottom');
    drawnow;
    if SAVE_RESULTS
        saveFig(RUN_DIR, 'sweep', fig_sweep);
        fprintf('Sweep figure saved.\n');
    end
end

%% Fine tap sweep (optional) — zoomed in around the inflection
if DO_TAP_SWEEP_FINE
    % Auto-detect inflection region from coarse sweep if available
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

    fprintf('\nFine tap sweep: %.3f to %.3f (%d pts, %d meas each) ...\n', ...
            SWEEP_FINE_TAP_LO, SWEEP_FINE_TAP_HI, SWEEP_FINE_N_PTS, SWEEP_FINE_N_MEAS);

    for si = 1:SWEEP_FINE_N_PTS
        tv = fine_tap_vals(si);
        t  = zeros(N_TAPS, 1);  t(TAP_POS) = tv;
        pf_fn = adi.AD9084.PFilt(t, 'mode', 'real_n2', 'gain', "0", 'scalar_gain', "63");
        pf_fn.write(fullfile(RUN_DIR, 'gain_study_fine_tmp.txt'));

        release(rx);
        rx.PFIRFilenames = fullfile(RUN_DIR, 'gain_study_fine_tmp.txt');
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

    fig_fine = figure('Name', 'Gain Study - Fine Tap Sweep', 'NumberTitle', 'off', 'Position', [800 350 750 420]);
    errorbar(fine_tap_vals, fine_gains, fine_stds, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 10, 'CapSize', 4);
    hold on;
    % yline(0, 'r--', '0 dB (all-pass ideal)', 'LineWidth', 1.2, 'LabelVerticalAlignment', 'bottom');
    xline(1.0, 'r:', 'tap=1.0 (2^{15} full scale)', 'LineWidth', 1.0, 'LabelVerticalAlignment', 'bottom');
    xlabel('tap\_float (linear)'); ylabel('\Deltapeak re: disabled (dB)');
    title(sprintf('Gain vs tap\\_float  [%.2f – %.2f]  (middle tap, real\\_n2)', ...
                  SWEEP_FINE_TAP_LO, SWEEP_FINE_TAP_HI));
    grid on;
    drawnow;

    if SAVE_RESULTS
        saveFig(RUN_DIR, 'sweep_fine', fig_fine);
        fprintf('Fine sweep figure saved.\n');
    end
end

%% Scalar gain sweep (optional) — find which scalar_gain gives closest to all-pass
if DO_SCALAR_SWEEP
    scalar_vals  = 0:64;
    n_scalar     = numel(scalar_vals);
    scalar_gains = nan(n_scalar, 1);
    scalar_stds  = nan(n_scalar, 1);

    fprintf('\nScalar gain sweep: 0 to 64 (%d values, %d meas each) ...\n', n_scalar, SCALAR_N_MEAS);

    taps_sg = zeros(N_TAPS, 1);  taps_sg(TAP_POS) = TAP_FLOAT_FIXED;

    for si = 1:n_scalar
        sg = scalar_vals(si);
        pf_sg = adi.AD9084.PFilt(taps_sg, 'mode', 'real_n2', 'gain', "0", ...
                                  'scalar_gain', string(sg));
        pf_sg.write(fullfile(RUN_DIR, 'gain_study_scalar_tmp.txt'));

        release(rx);
        rx.PFIRFilenames = fullfile(RUN_DIR, 'gain_study_scalar_tmp.txt');
        rx();

        peaks_sg = nan(SCALAR_N_MEAS, 1);
        for m = 1:SCALAR_N_MEAS
            d = rx();
            xm = double(d(1:NFFT,1)) / 32768;
            Xm = fftshift(fft(xm .* window, NFFT));
            peaks_sg(m) = max(20*log10(abs(Xm) / cg + eps));
        end
        scalar_gains(si) = mean(peaks_sg) - ref_peak;
        scalar_stds(si)  = std(peaks_sg);
        fprintf('  scalar=%2d  gain=%+.3f dB  std=%.3f dB\n', sg, scalar_gains(si), scalar_stds(si));
    end

    % find the scalar closest to 0 dB delta (all-pass)
    [~, best_scalar_idx] = min(abs(scalar_gains));
    best_scalar = scalar_vals(best_scalar_idx);
    fprintf('\n  Best scalar_gain = %d  (delta = %+.3f dB)\n', best_scalar, scalar_gains(best_scalar_idx));

    fig_scalar = figure('Name', 'Gain Study - Scalar Sweep', 'NumberTitle', 'off', 'Position', [800 100 750 420]);
    errorbar(scalar_vals, scalar_gains, scalar_stds, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 10, 'CapSize', 3);
    hold on;
    yline(0, 'r--', '0 dB (all-pass)', 'LineWidth', 1.2, 'LabelVerticalAlignment', 'bottom');
    xlabel('scalar\_gain'); ylabel('\Deltapeak re: disabled (dB)');
    title(sprintf('Gain vs scalar\\_gain  (tap\\_float=%.1f, middle tap)  |  best = %d', TAP_FLOAT_FIXED, best_scalar));
    grid on;
    drawnow;

    if SAVE_RESULTS
        saveFig(RUN_DIR, 'scalar_sweep', fig_scalar);
        fprintf('Scalar sweep figure saved.\n');
    end
end

%% Shift gain sweep (optional) — measure actual gain at each shift gain setting
if DO_SHIFT_GAIN_SWEEP
    shift_gain_vals = [0, 6, 12, 18, 24];
    n_shift = numel(shift_gain_vals);
    shift_gains = nan(n_shift, 1);
    shift_stds  = nan(n_shift, 1);

    fprintf('\nShift gain sweep: [0, 9, 12, 18, 24] dB (%d values, %d meas each) ...\n', ...
            n_shift, SHIFT_GAIN_N_MEAS);

    taps_shg = zeros(N_TAPS, 1);  taps_shg(TAP_POS) = TAP_FLOAT_FIXED;

    for si = 1:n_shift
        sg_dB = shift_gain_vals(si);
        pf_shg = adi.AD9084.PFilt(taps_shg, 'mode', 'real_n2', ...
                                   'gain', string(sg_dB), 'scalar_gain', "62");
        pf_shg.write(fullfile(RUN_DIR, 'gain_study_shift_tmp.txt'));

        release(rx);
        rx.PFIRFilenames = fullfile(RUN_DIR, 'gain_study_shift_tmp.txt');
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
        fprintf('  shift_gain=%2d dB  measured=%+.3f dB  std=%.3f dB\n', ...
                sg_dB, shift_gains(si), shift_stds(si));
    end

    fig_shift = figure('Name', 'Gain Study - Shift Gain Sweep', 'NumberTitle', 'off', 'Position', [800 100 750 420]);
    errorbar(shift_gain_vals, shift_gains, shift_stds, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 10, 'CapSize', 3);
    hold on;
    plot(shift_gain_vals, shift_gain_vals, 'r--', 'LineWidth', 1.2);
    xlabel('Programmed Shift Gain (dB)'); ylabel('Measured \Deltapeak (dB)');
    title(sprintf('Measured vs Programmed Shift Gain  (tap\\_float=%.1f, scalar=63)', TAP_FLOAT_FIXED));
    legend('Measured', 'Ideal (1:1)', 'Location', 'NorthWest');
    grid on;
    drawnow;

    if SAVE_RESULTS
        saveFig(RUN_DIR, 'shift_gain_sweep', fig_shift);
        fprintf('Shift gain sweep figure saved.\n');
    end
end

%% Save gain lookup table as .m function (includes all sweeps that were run)
if SAVE_RESULTS
    lut_path = fullfile(RUN_DIR, 'gain_lut.m');
    fid = fopen(lut_path, 'w');

    fprintf(fid, 'function lut = gain_lut()\n');
    fprintf(fid, '%%%% Gain lookup table generated by gain_study.m\n');
    fprintf(fid, '%%%% Timestamp: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid, '%%%% Board URI: %s\n\n', uri);
    fprintf(fid, 'lut.board_uri = ''%s'';\n', uri);
    fprintf(fid, 'lut.tone_hz = %g;\n', TONE_FREQ_HZ);
    fprintf(fid, 'lut.adc_sample_rate_hz = %g;\n\n', Fs);

    if DO_TAP_SWEEP
        fprintf(fid, '%%%% Tap sweep (gain vs tap_float)\n');
        fprintf(fid, 'lut.tap_sweep.tap_values = %s;\n', mat2str(SWEEP_TAP_VALS, 6));
        fprintf(fid, 'lut.tap_sweep.gain_dB = %s;\n', mat2str(sweep_gains(:).', 6));
        fprintf(fid, 'lut.tap_sweep.std_dB = %s;\n', mat2str(sweep_stds(:).', 6));
        fprintf(fid, 'lut.tap_sweep.config.n_taps = %d;\n', N_TAPS);
        fprintf(fid, 'lut.tap_sweep.config.tap_pos = %d;\n', TAP_POS);
        fprintf(fid, 'lut.tap_sweep.config.scalar_gain = 63;\n');
        fprintf(fid, 'lut.tap_sweep.config.shift_gain_dB = 0;\n');
        fprintf(fid, 'lut.tap_sweep.config.n_meas = %d;\n\n', SWEEP_N_MEAS);
    end

    if DO_SCALAR_SWEEP
        fprintf(fid, '%%%% Scalar gain sweep (gain vs scalar_gain)\n');
        fprintf(fid, 'lut.scalar_sweep.scalar_values = %s;\n', mat2str(scalar_vals));
        fprintf(fid, 'lut.scalar_sweep.gain_dB = %s;\n', mat2str(scalar_gains(:).', 6));
        fprintf(fid, 'lut.scalar_sweep.std_dB = %s;\n', mat2str(scalar_stds(:).', 6));
        fprintf(fid, 'lut.scalar_sweep.config.tap_float_fixed = %g;\n', TAP_FLOAT_FIXED);
        fprintf(fid, 'lut.scalar_sweep.config.shift_gain_dB = 0;\n');
        fprintf(fid, 'lut.scalar_sweep.config.n_meas = %d;\n\n', SCALAR_N_MEAS);
    end

    if DO_SHIFT_GAIN_SWEEP
        fprintf(fid, '%%%% Shift gain sweep (gain vs shift_gain setting)\n');
        fprintf(fid, 'lut.shift_gain_sweep.shift_gain_values_dB = %s;\n', mat2str(shift_gain_vals));
        fprintf(fid, 'lut.shift_gain_sweep.gain_dB = %s;\n', mat2str(shift_gains(:).', 6));
        fprintf(fid, 'lut.shift_gain_sweep.std_dB = %s;\n', mat2str(shift_stds(:).', 6));
        fprintf(fid, 'lut.shift_gain_sweep.config.tap_float_fixed = %g;\n', TAP_FLOAT_FIXED);
        fprintf(fid, 'lut.shift_gain_sweep.config.scalar_gain = 60;\n');
        fprintf(fid, 'lut.shift_gain_sweep.config.n_meas = %d;\n\n', SHIFT_GAIN_N_MEAS);
    end

    fprintf(fid, 'end\n');
    fclose(fid);
    fprintf('Gain LUT function saved to: %s\n', lut_path);
end

%% Load single-tap filter (fixed tap = TAP_FLOAT_FIXED for live stream)
release(rx);
rx.PFIRFilenames = fullfile(RUN_DIR, 'gain_study_filter.txt');
rx();

fig1 = []; fig2 = []; fig3 = [];

%% Figure 1 - Spectra
if SHOW_SPECTRA
fig1 = figure('Name', 'Gain Study - Spectra', 'NumberTitle', 'off', 'Position', [100 350 1100 580]);

ax1 = subplot(2,1,1);
plot(ax1, f_bins, ref_mag, 'k-', 'LineWidth', 0.8);
xlabel(ax1, 'Frequency (MHz)'); ylabel(ax1, 'Magnitude (dBFS)');
title(ax1, sprintf('Unfiltered reference  |  peak = %.2f dBFS', ref_peak));
grid(ax1, 'on'); ylim(ax1, [-140 5]);

ax2 = subplot(2,1,2);
h_spec = plot(ax2, f_bins, ref_mag, 'b-', 'LineWidth', 0.8);
hold(ax2, 'on');
% errorbar fixed at reference peak frequency; y updated as stats accumulate
h_eb_fft = errorbar(ax2, ref_peak_freq_MHz, ref_peak, 0, 'r^', ...
                    'MarkerSize', 8, 'LineWidth', 1.5, 'CapSize', 8, 'Visible', 'off');
xlabel(ax2, 'Frequency (MHz)'); ylabel(ax2, 'Magnitude (dBFS)');
title(ax2, 'Filtered (live)');
grid(ax2, 'on'); ylim(ax2, [-140 5]);
end % SHOW_SPECTRA

%% Figure 2 - Statistics (scatter + errorbar)
if SHOW_STATS
fig2 = figure('Name', 'Gain Study - Peak Statistics', 'NumberTitle', 'off', 'Position', [100 50 900 280]);

ax3 = subplot(1,2,1);
h_scatter   = plot(ax3, NaN, NaN, 'b.', 'MarkerSize', 6);
hold(ax3, 'on');
h_mean_line = yline(ax3, 0, 'r--', 'LineWidth', 1.2);
xlabel(ax3, 'Measurement #'); ylabel(ax3, '\Deltapeak (dB)');
title(ax3, sprintf('Peak delta  (n = 0 / %d)', N_STAT));
grid(ax3, 'on');

ax4 = subplot(1,2,2);
h_err = errorbar(ax4, 1, 0, 0, 'rs', 'MarkerSize', 10, 'LineWidth', 1.5, 'CapSize', 12);
ylabel(ax4, '\Deltapeak (dB)');
title(ax4, 'Mean \pm 1\sigma');
grid(ax4, 'on'); xlim(ax4, [0.5 1.5]); set(ax4, 'XTick', []);
end % SHOW_STATS

%% Figure 3 - Histogram
if SHOW_HIST
fig3 = figure('Name', 'Gain Study - Delta Distribution', 'NumberTitle', 'off', 'Position', [1050 350 700 420]);
ax5  = axes(fig3);
ylabel(ax5, 'Count'); xlabel(ax5, '\Deltapeak (dB)');
title(ax5, 'Gain delta distribution  (n = 0)');
grid(ax5, 'on');
end % SHOW_HIST

drawnow;

%% Stream - collect N_STAT measurements, then keep live spectrum going
if SHOW_SPECTRA
fprintf('Streaming - close figure to stop.\n');
diff_log      = [];
filt_peak_log = [];

while ishandle(h_spec)
    data  = rx();
    x     = double(data(1:NFFT, 1)) / 32768;
    X     = fftshift(fft(x .* window, NFFT));
    mag   = 20*log10(abs(X) / cg + eps);
    peak  = max(mag);

    set(h_spec, 'YData', mag);
    title(ax2, sprintf('Filtered (live)  |  peak = %.2f dBFS', peak));

    if numel(diff_log) < N_STAT
        diff_log(end+1)      = peak - ref_peak; %#ok<AGROW>
        filt_peak_log(end+1) = peak;            %#ok<AGROW>
        n      = numel(diff_log);
        d_mean = mean(diff_log);
        d_std  = std(diff_log);
        p_mean = mean(filt_peak_log);
        p_std  = std(filt_peak_log);

        if SHOW_STATS
            set(h_scatter, 'XData', 1:n, 'YData', diff_log);
            h_mean_line.Value = d_mean;
            set(h_err, 'YData', d_mean, 'YNegativeDelta', d_std, 'YPositiveDelta', d_std);
            title(ax3, sprintf('Peak delta  (n = %d / %d)', n, N_STAT));
            title(ax4, sprintf('Mean \\pm 1\\sigma = %.3f \\pm %.3f dB', d_mean, d_std));
        end

        % FFT errorbar: fixed x at ref peak freq, y = filtered peak mean +/- std
        set(h_eb_fft, 'YData', p_mean, 'YNegativeDelta', p_std, 'YPositiveDelta', p_std, 'Visible', 'on');

        if SHOW_HIST && (mod(n, 25) == 0 || n == N_STAT)
            [counts, edges] = histcounts(diff_log, 30);
            centers = (edges(1:end-1) + edges(2:end)) / 2;
            cla(ax5);
            bar(ax5, centers, counts, 1.0, 'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'none');
            ylabel(ax5, 'Count'); xlabel(ax5, '\Deltapeak (dB)');
            grid(ax5, 'on');
            if d_std > 0
                pad = max(4 * d_std, 0.5);
                xlim(ax5, [d_mean - pad, d_mean + pad]);
            end
            title(ax5, sprintf('Gain delta distribution  (n = %d)  |  std = %.3f dB', n, d_std));
        end

        if n == N_STAT
            fprintf('Done - mean: %.4f dB  std: %.4f dB\n', d_mean, d_std);

            % Recommended linear scaling to drive mean Δpeak toward 0 dB:
            % If mean Δpeak is +X dB (filtered is hotter), scale should be < 1.
            scale_lin = 10.^(-d_mean/20);
            tap_recommended = TAP_FLOAT_FIXED * scale_lin;
            fprintf('Recommended linear scale (to target 0 dB mean): %.6f\n', scale_lin);
            fprintf('Suggested TAP_FLOAT_FIXED next run: %.4f (current %.4f)\n', tap_recommended, TAP_FLOAT_FIXED);

            if SAVE_RESULTS
                saveRun(RUN_DIR, 'stats', {fig1, fig2, fig3}, ...
                        {SHOW_SPECTRA, SHOW_STATS, SHOW_HIST}, ...
                        N_TAPS, TAP_POS, N_STAT, TONE_FREQ_HZ, TAP_FLOAT_FIXED, d_mean, d_std, scale_lin, tap_recommended);
            end
        end
    end

    drawnow limitrate;
end
end % SHOW_SPECTRA

%% =========================================================
%  Local helpers
%  =========================================================
function saveFig(run_dir, name, fig)
    if ~ishandle(fig), return; end
    base = fullfile(run_dir, name);
    exportgraphics(fig, [base '.png'], 'Resolution', 150);
    savefig(fig, [base '.fig']);
end

function saveRun(run_dir, tag, figs, flags, n_taps, tap_pos, n_stat, tone_hz, tap_fixed, d_mean, d_std, scale_lin, tap_recommended)
    names = {'spectra', 'stats', 'histogram'};
    for k = 1:numel(figs)
        if flags{k} && ishandle(figs{k})
            saveFig(run_dir, sprintf('%s_%s', tag, names{k}), figs{k});
        end
    end
    % write a small summary text file
    fid = fopen(fullfile(run_dir, 'run_info.txt'), 'w');
    fprintf(fid, 'timestamp        : %s\n', datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
    fprintf(fid, 'tone_hz          : %.0f\n', tone_hz);
    fprintf(fid, 'tap_float_fixed  : %.4f\n', tap_fixed);
    fprintf(fid, 'n_taps           : %d\n',  n_taps);
    fprintf(fid, 'tap_pos          : %d\n',  tap_pos);
    fprintf(fid, 'n_stat           : %d\n',  n_stat);
    fprintf(fid, 'delta_mean       : %.4f dB\n', d_mean);
    fprintf(fid, 'delta_std        : %.4f dB\n', d_std);
    fprintf(fid, 'scale_lin_reco   : %.8f\n', scale_lin);
    fprintf(fid, 'tap_float_reco   : %.4f\n', tap_recommended);
    fclose(fid);
    fprintf('Run saved to: %s\n', run_dir);
end
