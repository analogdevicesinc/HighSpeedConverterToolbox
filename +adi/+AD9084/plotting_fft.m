
function plotting_fft(rx)
% plotting_fft  Real-time FFT plot for AD9084 RX
%
%   plotting_fft(rx)
%
%   rx : adi.AD9084.Rx object (already configured and streaming)

    %% --- Get sampling rate safely ---
    Fs = double(rx.SamplingRate);
    assert(~isnan(Fs) && Fs > 0, 'Invalid SamplingRate');

    fprintf('Sampling rate: %.3f MHz\n', Fs/1e6);

    %% --- FFT parameters ---
    NFFT   = 4096;
    window = hann(NFFT, 'periodic');

    %% --- Set up plot ---
    figure('Name','AD9084 Real-Time FFT');
    h = plot(nan, nan);
    grid on;
    xlabel('Frequency (MHz)');
    ylim([-140 5]);
    ylabel('Magnitude (dBFS)');
    title('AD9084 Real-Time FFT');

    coherentGain = sum(window) / 2;

    %% --- Streaming loop ---
    while isvalid(h)
        data = rx();   % BLOCKING until frame arrives

        % Data is assumed to be complex (16384x1 complex double)
        x = data(:,1) / 32768;

        % Window + FFT
        xw = x(1:NFFT) .* window;
        X  = fftshift(fft(xw, NFFT));

        % Magnitude (dBFS)
        mag_dBFS = 20*log10((abs(X) / coherentGain) + eps);

        % Frequency axis
        f = linspace(-Fs/2, Fs/2, NFFT) / 1e6;

        % Update plot
        set(h, 'XData', f, 'YData', mag_dBFS);
        drawnow;
    end
end
