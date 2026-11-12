clear all;close all;clc
tic;
%% Initialize DUT
x = Triton('ip:192.168.2.1');
x.fsRxIQ = 400e6;
x.initialize;
%% Configuration
inputPower = 10;
freq = (8e9:100e6:12e9)';
ncoFreqRx = freq - 12.8e9;
ncoFreqTx = freq;
txPhaseOffset = zeros(length(freq), x.numChannels);
rxPhaseOffset = zeros(length(freq), x.numChannels);
%% Phase Calibration (runs once for all NCO positions)
for c = 1:numel(freq)
    x.setTxNCOFreq('Main', ncoFreqTx(c)*ones(1,x.numChannels));
    x.setRxNCOFreq('Main', ncoFreqRx(c)*ones(1,x.numChannels));
    [txPhaseOffset(c,:), rxPhaseOffset(c,:)] = x.systemCal('combine');
end
wave = x.createWaveform('cw',-1,x.basebandFreq);
x.txWaveform(wave.*zeros(1,16));
x.calBrdExternalSMA();
%% Pre-EQ Full Sweep (8–12 GHz, 41 points) — runs ONCE as baseline
freqSweepAdcData = zeros(x.samplesPerFrameRx, x.numChannels, numel(freq));
for f = 1:numel(freq)
    ncoFreqRx_f = freq(f) - 12.8e9;
    x.setRxNCOFreq('Main', ncoFreqRx_f*ones(1,x.numChannels));
    x.setRxNCOPhase('Main', rxPhaseOffset(f,:)*1e3);
    toneFreqMHz = (freq(f)+x.basebandFreq) / 1e6;
    fprintf('\n--- Pre-EQ Sweep Point %d/%d ---\n', f, numel(freq));
    fprintf('Set signal generator to %.3f MHz at %d dBm, then turn OUTPUT ON.\n', toneFreqMHz, inputPower);
    input('Press ENTER when ready...', 's');
    testADCData = x.rx();
    [~, testADCDataValdB] = x.FFT(testADCData, false, 'onetone');
    maxdBFs = max(testADCDataValdB(:));
    if maxdBFs ~= -4
        adjustedPower = inputPower - (maxdBFs - (-4));
        fprintf('Adjust power to %.1f dBm for -4 dBFS target.\n', adjustedPower);
        input('Press ENTER when ready...', 's');
    end
    freqSweepAdcData(:,:,f) = x.rx();
    fprintf('Turn signal generator OUTPUT OFF.\n');
    input('Press ENTER when done...', 's');
end
%% System Configuration
num_apollos = 4;
num_converters_per_apollo = 4;
num_channels = num_apollos * num_converters_per_apollo;
adc_sample_rate = 12.8e9;
total_decimation = 32;
decimated_Fs = adc_sample_rate / total_decimation;
Ntaps_total = 64;
Ntaps_per_cfir = 16;
cfir_gain_dB = 0;
NCO_centers_GHz = 8.2:0.3:12.1;
NCO_centers_GHz = NCO_centers_GHz(NCO_centers_GHz <= 11.9);
num_nco_positions = numel(NCO_centers_GHz);
%% Extract pre-EQ channel magnitudes from baseline sweep
num_samples = size(freqSweepAdcData, 1);
num_freqs = size(freqSweepAdcData, 3);
freq_sweep_GHz = linspace(8, 12, num_freqs);
channel_mag_preEQ = zeros(num_channels, num_freqs);
for ch = 1:num_channels
    for f_idx = 1:num_freqs
        channel_mag_preEQ(ch, f_idx) = mean(abs(freqSweepAdcData(:, ch, f_idx)));
    end
end
global_max = max(channel_mag_preEQ(:));
channel_mag_preEQ_norm = channel_mag_preEQ / global_max;
apollo_avg_preEQ = zeros(num_apollos, num_freqs);
for apollo = 1:num_apollos
    ch_start = (apollo-1)*num_converters_per_apollo + 1;
    ch_end = apollo*num_converters_per_apollo;
    apollo_avg_preEQ(apollo,:) = mean(channel_mag_preEQ_norm(ch_start:ch_end,:), 1);
end
target_level = min(apollo_avg_preEQ(:));
fprintf('Global target level (min across full X-band): %.4f (%.1f dB)\n', ...
    target_level, 20*log10(target_level));
%% Stitched post-EQ storage
stitched_postEQ_data = zeros(num_samples, num_channels, num_freqs);
tol = 1e-6;
best_nco_for_freq = zeros(1, num_freqs);
for f_idx = 1:num_freqs
    [~, best_nco_for_freq(f_idx)] = min(abs(freq_sweep_GHz(f_idx) - NCO_centers_GHz));
end
%% Main Loop: 14 NCO positions (300 MHz spacing, 100 MHz overlap)
cfir_select_order = {'cfir_a0', 'cfir_a1', 'cfir_b1', 'cfir_b0'};
output_dir = fullfile(pwd, 'cfir_filters');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
N_design = 1001;
F_norm_design = linspace(-1, 1, N_design);
gain_compensation = 10^(-cfir_gain_dB/20);
for nco_idx = 1:num_nco_positions
    NCO_center_GHz = NCO_centers_GHz(nco_idx);
    nco_low_GHz = NCO_center_GHz - 0.8*decimated_Fs/2e9;
    nco_high_GHz = NCO_center_GHz + 0.8*decimated_Fs/2e9;
    fprintf('\n===== NCO %d/%d: %.1f GHz (%.1f–%.1f GHz) =====\n', ...
        nco_idx, num_nco_positions, NCO_center_GHz, nco_low_GHz, nco_high_GHz);
    slice_idx = (freq_sweep_GHz >= nco_low_GHz - tol) & (freq_sweep_GHz <= nco_high_GHz + tol);
    freq_slice_GHz = freq_sweep_GHz(slice_idx);
    num_slice_pts = sum(slice_idx);
    apollo_responses_slice = apollo_avg_preEQ(:, slice_idx);
    %% Design 64-tap CFIR per Apollo
    apollo_cfir_coefs = zeros(num_apollos, Ntaps_total);
    for apollo = 1:num_apollos
        meas = apollo_responses_slice(apollo, :);
        meas_interp = interp1(linspace(-1, 1, num_slice_pts), meas, ...
            F_norm_design, 'pchip', 'extrap');
        eq_response = target_level ./ meas_interp;
        eq_response = min(eq_response, 10^(6/20));
        eq_response = max(eq_response, 10^(-20/20));
        eq_response = 0.99 * eq_response / max(eq_response);
        eq_response = eq_response * gain_compensation;
        eq_response = min(eq_response, 0.99 * gain_compensation);
        F_design = ((1:N_design) - 1) / N_design;
        d = exp(-1i * pi * F_design * Ntaps_total/2);
        amp = abs(eq_response .* d);
        W = ones(1, N_design);
        pb_idx = abs(F_norm_design) < 0.8;
        W(pb_idx) = 10;
        D = fdesign.arbmag('N,F,A', Ntaps_total-1, F_norm_design, amp);
        EQ_obj = design(D, 'allfir', 'weights', W, SystemObject = true);
        apollo_cfir_coefs(apollo, :) = EQ_obj{1,2}.Numerator;
    end
    %% Write 16 txt files for this NCO position
    for apollo = 1:num_apollos
        coef_full = apollo_cfir_coefs(apollo, :);
        for blk = 1:4
            tap_start = (blk-1)*Ntaps_per_cfir + 1;
            tap_end = blk*Ntaps_per_cfir;
            coef_sub = coef_full(tap_start:tap_end);
            hsel_start = (blk-1)*Ntaps_per_cfir;
            hsel_values = hsel_start + (0:Ntaps_per_cfir-1);
            scale = 2^14;
            i_coef = round(scale * real(coef_sub));
            q_coef = round(scale * imag(coef_sub));
            i_u16 = double(typecast(int16(round(i_coef)), 'uint16'));
            q_u16 = double(typecast(int16(round(q_coef)), 'uint16'));
            cfir_select = cfir_select_order{blk};
            filename = sprintf('cfir_apollo%d_%s_nco%04d.txt', ...
                apollo, cfir_select, round(NCO_center_GHz*1000));
            fid = fopen(fullfile(output_dir, filename), 'w');
            fprintf(fid, '# Sparse CFIR EQ — Apollo %d, %s (taps %d-%d)\n', ...
                apollo, cfir_select, tap_start-1, tap_end-1);
            fprintf(fid, '# NCO = %.1f GHz, slice %.1f-%.1f GHz\n', ...
                NCO_center_GHz, nco_low_GHz, nco_high_GHz);
            fprintf(fid, 'dest: rx %s profile_1 datapath_all\n', cfir_select);
            fprintf(fid, 'gain: %d\n', cfir_gain_dB);
            fprintf(fid, 'complex_scalar: 32767 0\n');
            fprintf(fid, 'bypass: 0\n');
            fprintf(fid, 'sparse_filt_en: 1\n');
            fprintf(fid, '32taps_en: 0\n');
            fprintf(fid, 'coeff_transfer: 1\n');
            fprintf(fid, 'selection_mode: direct_regmap\n');
            fprintf(fid, 'enable: 1 profile_1\n');
            for t = 1:Ntaps_per_cfir
                fprintf(fid, '0x%04X 0x%04X 0x%02X\n', i_u16(t), q_u16(t), hsel_values(t));
            end
            fclose(fid);
        end
    end
    fprintf('Written 16 CFIR files for NCO = %.1f GHz\n', NCO_center_GHz);
    %% Load CFIR files to hardware via iio_attr (4 writes per Apollo)
    iio_attr_dir = 'C:\Users\SDas14\Windows-VS-2022-x64';
    iio_uri = 'ip:192.168.2.1';
    iio_devices = {'axi-ad9084-rx-hpc', 'axi-ad9084-rx1', 'axi-ad9084-rx2', 'axi-ad9084-rx3'};
    for apollo = 1:num_apollos
        for blk = 1:4
            cfir_select = cfir_select_order{blk};
            filename = sprintf('cfir_apollo%d_%s_nco%04d.txt', ...
                apollo, cfir_select, round(NCO_center_GHz*1000));
            filepath = fullfile(output_dir, filename);
            cmd = sprintf('cd /d "%s" && iio_attr -u %s -d %s cfir_config -f "%s"', ...
                iio_attr_dir, iio_uri, iio_devices{apollo}, filepath);
            [status, result] = system(cmd);
            if status ~= 0
                warning('Failed to load %s: %s', filename, result);
            end
        end
    end
    fprintf('Loaded 16 CFIR files to hardware for NCO = %.1f GHz\n', NCO_center_GHz);
    pause(1);
    %% Post-EQ sweep — only capture points where this NCO is the closest
    keep_indices = find(slice_idx & (best_nco_for_freq == nco_idx));
    for sf = 1:numel(keep_indices)
        f = keep_indices(sf);
        ncoFreqRx_f = freq(f) - 12.8e9;
        x.setRxNCOFreq('Main', ncoFreqRx_f*ones(1,x.numChannels));
        x.setRxNCOPhase('Main', rxPhaseOffset(f,:)*1e3);
        toneFreqMHz = (freq(f)+x.basebandFreq) / 1e6;
        fprintf('\n--- Post-EQ Capture: NCO %d, Point %d/%d ---\n', nco_idx, sf, numel(keep_indices));
        fprintf('Set signal generator to %.3f MHz at %d dBm, then turn OUTPUT ON.\n', toneFreqMHz, inputPower);
        input('Press ENTER when ready...', 's');
        testADCData = x.rx();
        [~, testADCDataValdB] = x.FFT(testADCData, false, 'onetone');
        maxdBFs = max(testADCDataValdB(:));
        if maxdBFs ~= -4
            adjustedPower = inputPower - (maxdBFs - (-4));
            fprintf('Adjust power to %.1f dBm for -4 dBFS target.\n', adjustedPower);
            input('Press ENTER when ready...', 's');
        end
        stitched_postEQ_data(:,:,f) = x.rx();
        fprintf('Turn signal generator OUTPUT OFF.\n');
        input('Press ENTER when done...', 's');
    end
    fprintf('Post-EQ capture done for NCO = %.1f GHz (%d points kept)\n', ...
        NCO_center_GHz, numel(keep_indices));
end
%% Compute stitched post-EQ magnitudes
stitched_postEQ_mag = zeros(num_channels, num_freqs);
for ch = 1:num_channels
    for f_idx = 1:num_freqs
        stitched_postEQ_mag(ch, f_idx) = mean(abs(stitched_postEQ_data(:, ch, f_idx)));
    end
end
stitched_postEQ_norm = stitched_postEQ_mag / global_max;
stitched_combined = zeros(num_apollos, num_freqs);
for apollo = 1:num_apollos
    ch_start = (apollo-1)*num_converters_per_apollo + 1;
    ch_end = apollo*num_converters_per_apollo;
    for f_idx = 1:num_freqs
        combined_data = zeros(num_samples, 1);
        for conv = 1:num_converters_per_apollo
            ch = ch_start + conv - 1;
            combined_data = combined_data + stitched_postEQ_data(:, ch, f_idx);
        end
        stitched_combined(apollo, f_idx) = mean(abs(combined_data));
    end
end
all_combined = zeros(1, num_freqs);
for f_idx = 1:num_freqs
    all_data = zeros(num_samples, 1);
    for ch = 1:num_channels
        all_data = all_data + stitched_postEQ_data(:, ch, f_idx);
    end
    all_combined(f_idx) = mean(abs(all_data));
end
%% Wideband Plots
figure(1);
hold on; grid on;
colors = lines(num_channels);
for ch = 1:num_channels
    plot(freq_sweep_GHz, 20*log10(abs(channel_mag_preEQ_norm(ch,:))), '-o', ...
        'Color', colors(ch,:), 'MarkerSize', 2);
end
xlabel('Frequency (GHz)'); ylabel('Gain (dB)');
title('Raw Channel Responses Before EQ (Full X-Band)');
legend(arrayfun(@(c) sprintf('Ch %d', c), 1:num_channels, 'UniformOutput', false), ...
    'Location', 'EastOutside', 'FontSize', 7);
figure(2);
hold on; grid on;
for ch = 1:num_channels
    plot(freq_sweep_GHz, 20*log10(abs(stitched_postEQ_norm(ch,:))), '-o', ...
        'Color', colors(ch,:), 'MarkerSize', 2);
end
xlabel('Frequency (GHz)'); ylabel('Gain (dB)');
title('Stitched Post-EQ Channel Responses (Full X-Band)');
legend(arrayfun(@(c) sprintf('Ch %d', c), 1:num_channels, 'UniformOutput', false), ...
    'Location', 'EastOutside', 'FontSize', 7);
figure(3);
hold on; grid on;
apollo_colors = {'b', 'r', 'g', 'm'};
ref_level_combined = mean(stitched_combined(:));
for apollo = 1:num_apollos
    plot(freq_sweep_GHz, 20*log10(stitched_combined(apollo,:) / ref_level_combined), '-o', ...
        'Color', apollo_colors{apollo}, 'MarkerSize', 3, 'LineWidth', 1.5);
end
plot(freq_sweep_GHz, 20*log10(all_combined / ref_level_combined), '-sk', ...
    'MarkerSize', 5, 'LineWidth', 2, 'MarkerFaceColor', 'k');
yline(12, 'k--', '12 dB theoretical', 'LineWidth', 1);
xlabel('Frequency (GHz)'); ylabel('Gain relative to avg Apollo (dB)');
title('Array Combining Gain (Full X-Band, Stitched)');
legend([arrayfun(@(a) sprintf('Apollo %d', a), 1:num_apollos, 'UniformOutput', false), ...
    {'All 4 combined'}], 'Location', 'Best');
figure(4);
postEQ_dB = 20*log10(abs(stitched_postEQ_norm));
mag_variation = max(postEQ_dB, [], 1) - min(postEQ_dB, [], 1);
plot(freq_sweep_GHz, mag_variation, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
grid on;
xlabel('Frequency (GHz)'); ylabel('Maximum Magnitude Variation (dB)');
title('Max Channel-to-Channel Variation After EQ (Full X-Band)');
xlim([8 12]);
figure(5);
hold on; grid on;
preEQ_avg = mean(20*log10(abs(channel_mag_preEQ_norm)), 1);
preEQ_spread = max(20*log10(abs(channel_mag_preEQ_norm)),[],1) - ...
               min(20*log10(abs(channel_mag_preEQ_norm)),[],1);
postEQ_spread = mag_variation;
plot(freq_sweep_GHz, preEQ_spread, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 3);
plot(freq_sweep_GHz, postEQ_spread, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 3);
xlabel('Frequency (GHz)'); ylabel('Channel Spread (dB)');
title('Channel-to-Channel Spread: Before vs After EQ');
legend('Pre-EQ spread', 'Post-EQ spread', 'Location', 'Best');
grid on; xlim([8 12]);
fprintf('\n===== WIDEBAND EQ COMPLETE =====\n');
fprintf('Processed %d NCO positions (300 MHz spacing, 100 MHz overlap) covering 8–12 GHz\n', num_nco_positions);
toc;
%% Reset all CFIRs to passthrough
reset_filename = fullfile(output_dir, 'cfir_passthrough.txt');
fid = fopen(reset_filename, 'w');
fprintf(fid, '# Passthrough CFIR — no filtering (unity at center tap)\n');
fprintf(fid, 'dest: rx cfir_all profile_1 datapath_all\n');
fprintf(fid, 'gain: 0\n');
fprintf(fid, 'complex_scalar: 32767 0\n');
fprintf(fid, 'bypass: 0\n');
fprintf(fid, 'sparse_filt_en: 1\n');
fprintf(fid, '32taps_en: 0\n');
fprintf(fid, 'coeff_transfer: 1\n');
fprintf(fid, 'selection_mode: direct_regmap\n');
fprintf(fid, 'enable: 1 profile_1\n');
for t = 1:16
    if t == 8
        fprintf(fid, '0x7FFF 0x0000 0x%02X\n', (t-1));
    else
        fprintf(fid, '0x0000 0x0000 0x%02X\n', (t-1));
    end
end
fclose(fid);
iio_attr_dir = 'C:\Users\SDas14\Windows-VS-2022-x64';
iio_uri = 'ip:192.168.2.1';
iio_devices = {'axi-ad9084-rx-hpc', 'axi-ad9084-rx1', 'axi-ad9084-rx2', 'axi-ad9084-rx3'};
fprintf('\nResetting all CFIRs to passthrough...\n');
for apollo = 1:num_apollos
    cmd = sprintf('cd /d "%s" && iio_attr -u %s -d %s cfir_config -f "%s"', ...
        iio_attr_dir, iio_uri, iio_devices{apollo}, reset_filename);
    [status, result] = system(cmd);
    if status ~= 0
        warning('Failed to reset Apollo %d: %s', apollo, result);
    end
end
fprintf('All CFIRs reset to passthrough.\n');