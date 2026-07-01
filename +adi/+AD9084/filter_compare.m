function filter_compare(rx, filterObj, filterType, filterFile)
% filter_compare  Before/after comparison with theoretical overlay.
%
%   filter_compare(rx, filterObj, 'pfir', 'pfir_auto.txt')
%   filter_compare(rx, filterObj, 'cfir', 'cfir_auto.txt')
%
%   rx         - AD9084.Rx object (must already be primed/streaming)
%   filterObj  - PFilt or CFIR object used for .response() overlay
%   filterType - 'pfir' or 'cfir'
%   filterFile - filename of the active filter to restore after reference

arguments
    rx
    filterObj
    filterType (1,1) string {mustBeMember(filterType, ["pfir","cfir"])}
    filterFile (1,1) string
end

Fs_rx = double(rx.SamplingRate);
NFFT  = rx.SamplesPerFrame;
window = hann(NFFT, 'periodic');
cg = sum(window) / 2;
f_axis = linspace(-Fs_rx/2, Fs_rx/2, NFFT) / 1e6;

% --- Capture WITH filter active (current state) ---
for k = 1:5, data = rx(); end
x_filt = double(data(1:NFFT, 1)) / 32768;
X_filt = fftshift(fft(x_filt .* window, NFFT));
mag_filt = 20*log10(abs(X_filt) / cg + eps);

% --- Load reference and capture ---
if filterType == "pfir"
    adi.AD9084.writeDisabledFilter('pfir_disabled_ref.txt', 'pfir');
    release(rx);
    rx.PFIRFilenames = 'pfir_disabled_ref.txt';
    rx();
    refLabel = 'Disabled';
else
    ap_taps_ref = zeros(16, 1); ap_taps_ref(ceil(16/2)) = 1.0;
    cf_ap = adi.AD9084.CFIR(ap_taps_ref, 'gain', "0", 'complex_scalar', 32767+0i);
    cf_ap.write('cfir_allpass_ref.txt');
    release(rx);
    rx.CFIRFilenames = 'cfir_allpass_ref.txt';
    rx();
    refLabel = 'All-Pass';
end

for k = 1:5, data = rx(); end
x_ref = double(data(1:NFFT, 1)) / 32768;
X_ref = fftshift(fft(x_ref .* window, NFFT));
mag_ref = 20*log10(abs(X_ref) / cg + eps);

% --- Restore original filter ---
release(rx);
if filterType == "pfir"
    rx.PFIRFilenames = filterFile;
else
    rx.CFIRFilenames = filterFile;
end
rx();

% --- Theoretical response ---
% PFIR operates at full ADC rate (20 GHz), CFIR at decimated rate.
% The observable window is centered at (MainNCO + ChannelNCO) in the
% PFIR's 20 GHz domain, not at DC.
if filterType == "pfir"
    Fs_filter = 20e9;
    nco_center = rx.MainNCOFrequencies(1) + rx.ChannelNCOFrequencies(1);
else
    Fs_filter = Fs_rx;
    nco_center = 0;
end
N_theory = 8192;
[H, f] = filterObj.response(Fs_filter, N=N_theory);
mag_theory = 20*log10(abs(H) / max(abs(H)) + eps);

% Crop theoretical to the observable window centered at NCO offset
obs_lo = nco_center - Fs_rx/2;
obs_hi = nco_center + Fs_rx/2;
obs_mask = (f >= obs_lo) & (f <= obs_hi);
f_obs = f(obs_mask) - nco_center;  % shift to baseband for overlay
mag_theory_obs = mag_theory(obs_mask);

% --- Plot ---
typeUpper = upper(filterType);
measured_delta = mag_filt - mag_ref;

figure('Name', sprintf('%s Before/After Comparison', typeUpper), ...
       'Position', [100 100 1000 550]);

subplot(2,1,1);
plot(f_axis, mag_ref, 'k-', 'LineWidth', 0.8); hold on;
plot(f_axis, mag_filt, 'b-', 'LineWidth', 1.0);
legend(refLabel, sprintf('With %s', typeUpper)); grid on;
xlabel('Frequency (MHz)'); ylabel('Magnitude (dBFS)');
title(sprintf('Spectrum: Before vs After %s', typeUpper));

subplot(2,1,2);
plot(f_axis, measured_delta, 'r-', 'LineWidth', 0.8); hold on;
plot(f_obs/1e6, mag_theory_obs + max(measured_delta) - max(mag_theory_obs), 'm--', 'LineWidth', 1.2);
grid on; yline(0, 'k--');
legend('Measured \Delta', 'Theoretical (.response)');
xlabel('Frequency (MHz)'); ylabel('\Delta (dB)');
title(sprintf('%s: Measured vs Theoretical (observable BW)', typeUpper));

end
