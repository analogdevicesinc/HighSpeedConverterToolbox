classdef AD9084HWTests < HardwareTests

    properties
        uri = 'ip:192.168.2.1';
        author = 'ADI';
    end

    methods(TestClassSetup)
        function CheckForHardware(~)
            disp('Skipping init test');
        end
    end

    methods (Static)
        function estFrequency(data, fs, saveNoShow, figname)
            nSamp = length(data);
            FFTRxData = fftshift(10*log10(abs(fft(data))));
            df = fs/nSamp; freqRangeRx = (0:df:fs/2-df).'/1000;
            if nargin < 3
                saveNoShow = false;
            end
            if nargin < 4
                figname = 'freq_plot';
            end
            if saveNoShow
                f = figure('visible', 'off');
            end
            plot(freqRangeRx, FFTRxData(end-length(freqRangeRx)+1:end, :));
            if saveNoShow
                saveas(f, figname, 'png')
                saveas(f, figname, 'fig')
            end
        end

        function freq = estFrequencyMax(data, fs, saveNoShow, figname)
            % Peak frequency estimation for complex I/Q data.
            % Returns the absolute frequency of the strongest bin
            % in the full [-Fs/2, Fs/2] spectrum.
            nSamp = length(data);
            fs = double(fs);
            freqRange = linspace(-fs/2, fs/2, nSamp).';
            FFTRxData = fftshift(20*log10(abs(fft(data)) + eps));
            [~, ind] = max(FFTRxData(:,1));
            freq = abs(freqRange(ind));
            if nargin >= 3 && saveNoShow
                if nargin < 4
                    figname = 'freq_plot';
                end
                f = figure('visible', 'off');
                plot(freqRange/1e6, FFTRxData(:,1));
                xlabel('Frequency (MHz)'); ylabel('Magnitude (dB)');
                saveas(f, figname, 'png')
                saveas(f, figname, 'fig')
            end
        end
    end

    methods (Test)

        function testAD9084Rx(testCase)
            % Test Rx DMA data output
            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))), 0);
            rx.release();
        end

        function testAD9084DDSFrequencySweep(testCase)
            % Diagnostic: sweep DDS frequencies and report measured values
            testFreqs = [10e6, 20e6, 45e6, 100e6, 200e6];
            for fi = 1:numel(testFreqs)
                toneFreq = testFreqs(fi);
                tx = adi.AD9084.Tx('uri', testCase.uri);
                tx.EnabledChannels       = 1;
                tx.DataSource            = 'DDS';
                tx.MainNCOFrequencies    = [1e9 0 0 0];
                tx.ChannelNCOFrequencies = [100e6 0 0 0];
                tx.MainNCOPhases         = [0 0 0 0];
                tx.ChannelNCOPhases      = [0 0 0 0];
                tx.NCOEnables            = [true false false false];
                tx.DDSFrequencies        = [toneFreq, toneFreq; 0, 0];
                tx.DDSScales             = [0.9, 0.9; 0, 0];
                tx.DDSPhases             = [0, 90000; 0, 0];
                tx();
                pause(1);

                rx = adi.AD9084.Rx('uri', testCase.uri);
                rx.EnabledChannels       = 1;
                rx.MainNCOFrequencies    = [1e9 0 0 0];
                rx.ChannelNCOFrequencies = [100e6 0 0 0];
                for k = 1:10
                    [out, ~] = rx();
                end
                sr = rx.SamplingRate;
                freqEst = testCase.estFrequencyMax(double(out), sr);
                fprintf('DDS=%.0f MHz  Measured=%.2f MHz  Offset=%.2f MHz\n', ...
                    toneFreq/1e6, freqEst/1e6, (freqEst - toneFreq)/1e6);
                rx.release();
                tx.release();
            end
        end

        function testAD9084RxWithTxDDS(testCase)
            % Test DDS output — single channel
            toneFreq = 45e6;
            tx = adi.AD9084.Tx('uri', testCase.uri);
            tx.EnabledChannels       = 1;
            tx.DataSource            = 'DDS';
            tx.MainNCOFrequencies    = [1e9 0 0 0];
            tx.ChannelNCOFrequencies = [100e6 0 0 0];
            tx.MainNCOPhases         = [0 0 0 0];
            tx.ChannelNCOPhases      = [0 0 0 0];
            tx.NCOEnables            = [true false false false];
            tx.DDSFrequencies        = [toneFreq, toneFreq; 0, 0];
            tx.DDSScales             = [0.9, 0.9; 0, 0];
            tx.DDSPhases             = [0, 90000; 0, 0];
            tx();
            pause(1);

            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels       = 1;
            rx.MainNCOFrequencies    = [1e9 0 0 0];
            rx.ChannelNCOFrequencies = [100e6 0 0 0];
            valid = false;
            for k = 1:10
                [out, valid] = rx();
            end
            sr = rx.SamplingRate;

            freqEst = testCase.estFrequencyMax(double(out), sr);
            relError = (freqEst - toneFreq) / toneFreq;
            fprintf('Expected: %.3f MHz  Actual: %.3f MHz  RelError: %.5f\n', ...
                toneFreq/1e6, freqEst/1e6, relError);
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))), 0);
            testCase.verifyEqual(freqEst, toneFreq, 'RelTol', 0.01, ...
                'Frequency of DDS tone unexpected');
            rx.release();
            tx.release();
        end

        function testAD9084RxWithTxDDSTwoChan(testCase)
            % Test DDS output — two channels at different frequencies
            toneFreq1 = 45e6;
            toneFreq2 = 90e6;
            tx = adi.AD9084.Tx('uri', testCase.uri);
            tx.EnabledChannels       = [1 2];
            tx.DataSource            = 'DDS';
            tx.MainNCOFrequencies    = [1e9 1e9 0 0];
            tx.ChannelNCOFrequencies = [100e6 100e6 0 0];
            tx.MainNCOPhases         = [0 0 0 0];
            tx.ChannelNCOPhases      = [0 0 0 0];
            tx.NCOEnables            = [true true false false];
            tx.DDSFrequencies        = [toneFreq1, toneFreq1, toneFreq2, toneFreq2; 0, 0, 0, 0];
            tx.DDSScales             = [0.9, 0.9, 0.9, 0.9; 0, 0, 0, 0];
            tx.DDSPhases             = [0, 90000, 0, 90000; 0, 0, 0, 0];
            tx();
            pause(1);

            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels       = [1 2];
            rx.MainNCOFrequencies    = [1e9 1e9 0 0];
            rx.ChannelNCOFrequencies = [100e6 100e6 0 0];
            valid = false;
            for k = 1:10
                [out, valid] = rx();
            end
            sr = rx.SamplingRate;

            freqEst1 = testCase.estFrequencyMax(double(out(:,1)), sr);
            freqEst2 = testCase.estFrequencyMax(double(out(:,2)), sr);
            relError1 = (freqEst1 - toneFreq1) / toneFreq1;
            relError2 = (freqEst2 - toneFreq2) / toneFreq2;
            fprintf('Ch1  Expected: %.3f MHz  Actual: %.3f MHz  RelError: %.3f\n', ...
                toneFreq1/1e6, freqEst1/1e6, relError1);
            fprintf('Ch2  Expected: %.3f MHz  Actual: %.3f MHz  RelError: %.3f\n', ...
                toneFreq2/1e6, freqEst2/1e6, relError2);
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))), 0);
            testCase.verifyEqual(freqEst1, toneFreq1, 'RelTol', 0.01, ...
                'Frequency of DDS tone Ch1 unexpected');
            testCase.verifyEqual(freqEst2, toneFreq2, 'RelTol', 0.01, ...
                'Frequency of DDS tone Ch2 unexpected');
            rx.release();
            tx.release();
        end

        function testAD9084RxWithTxData(testCase)
            % Test Tx DMA data output — single channel
            rx_probe = adi.AD9084.Rx('uri', testCase.uri);
            rx_probe.EnabledChannels = 1;
            rx_probe();
            sr = double(rx_probe.SamplingRate);
            rx_probe.release();

            amplitude = 2^15; frequency = sr/6;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = true;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = sr;
            y = swv1();

            tx = adi.AD9084.Tx('uri', testCase.uri);
            tx.EnabledChannels       = 1;
            tx.DataSource            = 'DMA';
            tx.MainNCOFrequencies    = [1e9 0 0 0];
            tx.ChannelNCOFrequencies = [100e6 0 0 0];
            tx.NCOEnables            = [true false false false];
            tx.EnableCyclicBuffers   = true;
            tx(y);

            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels       = 1;
            rx.MainNCOFrequencies    = [1e9 0 0 0];
            rx.ChannelNCOFrequencies = [100e6 0 0 0];
            for k = 1:10
                [out, valid] = rx();
            end
            sr = rx.SamplingRate;
           

            freqEst = testCase.estFrequencyMax(double(out), sr);
            relError = (freqEst - frequency) / frequency;
            fprintf('Expected: %.3f MHz  Actual: %.3f MHz  RelError: %.3f\n', ...
                frequency/1e6, freqEst/1e6, relError);
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))), 0);
            testCase.verifyEqual(freqEst, frequency, 'RelTol', 0.01, ...
                'Frequency of DMA tone unexpected');
            rx.release();
            tx.release();
        end

        function testAD9084RxWithTxDataTwoChan(testCase)
            % Test Tx DMA data output — two channels
            rx_probe = adi.AD9084.Rx('uri', testCase.uri);
            rx_probe.EnabledChannels = 1;
            rx_probe();
            sr = double(rx_probe.SamplingRate);
            rx_probe.release();

            amplitude = 2^15; toneFreq1 = sr/5;
            swv1 = dsp.SineWave(amplitude, toneFreq1);
            swv1.ComplexOutput = true;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = sr;
            y1 = swv1();

            amplitude = 2^15; toneFreq2 = sr/8;
            swv2 = dsp.SineWave(amplitude, toneFreq2);
            swv2.ComplexOutput = true;
            swv2.SamplesPerFrame = 2^20;
            swv2.SampleRate = sr;
            y2 = swv2();

            tx = adi.AD9084.Tx('uri', testCase.uri);
            tx.EnabledChannels       = [1 2];
            tx.DataSource            = 'DMA';
            tx.MainNCOFrequencies    = [1e9 1e9 0 0];
            tx.ChannelNCOFrequencies = [100e6 100e6 0 0];
            tx.NCOEnables            = [true true false false];
            tx.EnableCyclicBuffers   = true;
            tx([y1, y2]);

            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels       = [1 2];
            rx.MainNCOFrequencies    = [1e9 1e9 0 0];
            rx.ChannelNCOFrequencies = [100e6 100e6 0 0];
            for k = 1:10
                [out, valid] = rx();
            end
            sr = rx.SamplingRate;
            

            freqEst1 = testCase.estFrequencyMax(double(out(:,1)), sr);
            freqEst2 = testCase.estFrequencyMax(double(out(:,2)), sr);
            relError1 = (freqEst1 - toneFreq1) / toneFreq1;
            relError2 = (freqEst2 - toneFreq2) / toneFreq2;
            fprintf('Ch1  Expected: %.3f MHz  Actual: %.3f MHz  RelError: %.3f\n', ...
                toneFreq1/1e6, freqEst1/1e6, relError1);
            fprintf('Ch2  Expected: %.3f MHz  Actual: %.3f MHz  RelError: %.3f\n', ...
                toneFreq2/1e6, freqEst2/1e6, relError2);
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))), 0);
            testCase.verifyEqual(freqEst1, toneFreq1, 'RelTol', 0.01, ...
                'Frequency of DMA tone Ch1 unexpected');
            testCase.verifyEqual(freqEst2, toneFreq2, 'RelTol', 0.01, ...
                'Frequency of DMA tone Ch2 unexpected');
            rx.release();
            tx.release();
        end

        function testAD9084RxWithPFIR(testCase)
            % Test PFIR filter loading on Rx with DDS loopback
            toneFreq = 45e6;

            % Create a unity passthrough PFIR filter file (impulse at center tap)
            pfirTaps = zeros(16, 1);
            pfirTaps(8) = 1;
            pf = adi.AD9084.PFilt(pfirTaps);
            pfirFile = [tempname, '.txt'];
            cleanFile = onCleanup(@() delete(pfirFile));
            pf.write(pfirFile);

            % Configure Tx DDS
            tx = adi.AD9084.Tx('uri', testCase.uri);
            tx.EnabledChannels       = 1;
            tx.DataSource            = 'DDS';
            tx.MainNCOFrequencies    = [1e9 0 0 0];
            tx.ChannelNCOFrequencies = [100e6 0 0 0];
            tx.MainNCOPhases         = [0 0 0 0];
            tx.ChannelNCOPhases      = [0 0 0 0];
            tx.NCOEnables            = [true false false false];
            tx.DDSFrequencies        = [toneFreq, toneFreq; 0, 0];
            tx.DDSScales             = [0.9, 0.9; 0, 0];
            tx.DDSPhases             = [0, 90000; 0, 0];
            tx();
            pause(1);

            % Configure Rx with PFIR enabled
            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels       = 1;
            rx.MainNCOFrequencies    = [1e9 0 0 0];
            rx.ChannelNCOFrequencies = [100e6 0 0 0];
            rx.EnablePFIRs           = true;
            rx.PFIRFilenames         = pfirFile;
            valid = false;
            for k = 1:10
                [out, valid] = rx();
            end
            sr = rx.SamplingRate;
            

            freqEst = testCase.estFrequencyMax(double(out), sr);
            relError = (freqEst - toneFreq) / toneFreq;
            fprintf('PFIR  Expected: %.3f MHz  Actual: %.3f MHz  RelError: %.3f\n', ...
                toneFreq/1e6, freqEst/1e6, relError);
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))), 0);
            testCase.verifyEqual(freqEst, toneFreq, 'RelTol', 0.01, ...
                'Frequency with PFIR enabled unexpected');
            rx.release();
            tx.release();
        end

        function testAD9084RxWithCFIR(testCase)
            % Test CFIR filter loading on Rx with DDS loopback
            toneFreq = 45e6;

            % Create a unity passthrough CFIR filter file (impulse at center tap)
            cfirTaps = zeros(16, 1);
            cfirTaps(8) = 1;
            cf = adi.AD9084.CFIR(cfirTaps);
            cfirFile = [tempname, '.txt'];
            cleanFile = onCleanup(@() delete(cfirFile));
            cf.write(cfirFile);

            % Configure Tx DDS
            tx = adi.AD9084.Tx('uri', testCase.uri);
            tx.EnabledChannels       = 1;
            tx.DataSource            = 'DDS';
            tx.MainNCOFrequencies    = [1e9 0 0 0];
            tx.ChannelNCOFrequencies = [100e6 0 0 0];
            tx.MainNCOPhases         = [0 0 0 0];
            tx.ChannelNCOPhases      = [0 0 0 0];
            tx.NCOEnables            = [true false false false];
            tx.DDSFrequencies        = [toneFreq, toneFreq; 0, 0];
            tx.DDSScales             = [0.5, 0.5; 0, 0];
            tx.DDSPhases             = [0, 90000; 0, 0];
            tx();
            pause(1);

            % Configure Rx with CFIR enabled
            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels       = 1;
            rx.MainNCOFrequencies    = [1e9 0 0 0];
            rx.ChannelNCOFrequencies = [100e6 0 0 0];
            rx.EnableCFIRs           = true;
            rx.CFIRFilenames         = cfirFile;
            valid = false;
            for k = 1:10
                [out, valid] = rx();
            end
            sr = rx.SamplingRate;
            rx.release();
            tx.release();

            freqEst = testCase.estFrequencyMax(double(out), sr);
            relError = (freqEst - toneFreq) / toneFreq;
            fprintf('CFIR  Expected: %.3f MHz  Actual: %.3f MHz  RelError: %.3f\n', ...
                toneFreq/1e6, freqEst/1e6, relError);
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))), 0);
            testCase.verifyEqual(freqEst, toneFreq, 'RelTol', 0.01, ...
                'Frequency with CFIR enabled unexpected');
        end

        function testAD9084RxPFIRAttenuation(testCase)
            % Verify PFIR attenuates a tone in the filter stopband.
            % Uses a HP filter (passband > 0.5 norm = 5 GHz at 20 GHz).
            % DDS tone at 45 MHz → lands at ~1.145 GHz in the PFIR domain,
            % deep in the HP stopband. Compares tone power with all-pass
            % vs HP filter and verifies attenuation exceeds threshold.
            toneFreq = 45e6;
            ATTN_THRESHOLD_DB = 6;

            % Design HP filter: passes above 0.5 normalized (5 GHz at 20 GHz)
            Ntaps = 15;
            F_norm = linspace(-1, 1, 501);
            amp_HP = double(F_norm > 0.5);
            D_HP = fdesign.arbmag('N,F,A', Ntaps, F_norm, amp_HP);
            EQ_HP = design(D_HP, 'allfir', SystemObject=true);
            hpTaps = EQ_HP{1,2}.Numerator(:);

            % Create all-pass and HP filter files
            apTaps = zeros(16, 1); apTaps(8) = 1.0;
            pfAP = adi.AD9084.PFilt(apTaps, 'mode', 'real_n2', 'gain', "0", 'scalar_gain', "63");
            pfHP = adi.AD9084.PFilt(hpTaps, 'mode', 'real_n2', 'gain', "0", 'scalar_gain', "63");
            apFile = [tempname, '.txt']; pfAP.write(apFile);
            hpFile = [tempname, '.txt']; pfHP.write(hpFile);
            cleanAP = onCleanup(@() delete(apFile));
            cleanHP = onCleanup(@() delete(hpFile));

            % Configure TX DDS
            tx = adi.AD9084.Tx('uri', testCase.uri);
            tx.EnabledChannels       = 1;
            tx.DataSource            = 'DDS';
            tx.MainNCOFrequencies    = [1e9 0 0 0];
            tx.ChannelNCOFrequencies = [100e6 0 0 0];
            tx.MainNCOPhases         = [0 0 0 0];
            tx.ChannelNCOPhases      = [0 0 0 0];
            tx.NCOEnables            = [true false false false];
            tx.DDSFrequencies        = [toneFreq, toneFreq; 0, 0];
            tx.DDSScales             = [0.9, 0.9; 0, 0];
            tx.DDSPhases             = [90000, 0; 0, 0];
            tx();
            pause(1);

            % RX with all-pass PFIR — reference capture
            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels       = 1;
            rx.MainNCOFrequencies    = [1e9 0 0 0];
            rx.ChannelNCOFrequencies = [100e6 0 0 0];
            rx.EnablePFIRs           = true;
            rx.PFIRFilenames         = apFile;
            for k = 1:10, out = rx(); end
            refPower = max(20*log10(abs(fft(double(out(:,1)))) + eps));

            % Reload with HP PFIR — filtered capture
            release(rx);
            rx.PFIRFilenames = hpFile;
            for k = 1:10, out = rx(); end
            filtPower = max(20*log10(abs(fft(double(out(:,1)))) + eps));

            attenuation = refPower - filtPower;
            fprintf('PFIR Attenuation: %.2f dB (threshold: %d dB)\n', attenuation, ATTN_THRESHOLD_DB);
            testCase.verifyGreaterThan(attenuation, ATTN_THRESHOLD_DB, ...
                'PFIR did not attenuate stopband tone sufficiently');
            rx.release();
            tx.release();
        end

        function testAD9084RxCFIRAttenuation(testCase)
            % Verify CFIR attenuates a tone in the filter stopband.
            % Uses a LP filter (passband < 0.2 norm = 250 MHz at 2.5 GHz).
            % DDS tone at 900 MHz → appears at 900 MHz in the CFIR domain,
            % well above the LP cutoff. Compares tone power with all-pass
            % vs LP filter and verifies attenuation exceeds threshold.
            toneFreq = 900e6;
            ATTN_THRESHOLD_DB = 6;

            % Design LP filter: passes below 0.2 normalized (250 MHz at 2.5 GHz)
            Ntaps = 15;
            F_norm = linspace(-1, 1, 501);
            amp_LP = double(abs(F_norm) < 0.2);
            D_LP = fdesign.arbmag('N,F,A', Ntaps, F_norm, amp_LP);
            EQ_LP = design(D_LP, 'allfir', SystemObject=true);
            lpTaps = EQ_LP{1,2}.Numerator(:);

            % Create all-pass and LP filter files
            apTaps = zeros(16, 1); apTaps(8) = 1.0;
            cfAP = adi.AD9084.CFIR(apTaps, 'gain', "0", 'complex_scalar', [32767 0]);
            cfLP = adi.AD9084.CFIR(lpTaps, 'gain', "0", 'complex_scalar', [32767 0]);
            apFile = [tempname, '.txt']; cfAP.write(apFile);
            lpFile = [tempname, '.txt']; cfLP.write(lpFile);
            cleanAP = onCleanup(@() delete(apFile));
            cleanLP = onCleanup(@() delete(lpFile));

            % Configure TX DDS
            tx = adi.AD9084.Tx('uri', testCase.uri);
            tx.EnabledChannels       = 1;
            tx.DataSource            = 'DDS';
            tx.MainNCOFrequencies    = [1e9 0 0 0];
            tx.ChannelNCOFrequencies = [100e6 0 0 0];
            tx.MainNCOPhases         = [0 0 0 0];
            tx.ChannelNCOPhases      = [0 0 0 0];
            tx.NCOEnables            = [true false false false];
            tx.DDSFrequencies        = [toneFreq, toneFreq; 0, 0];
            tx.DDSScales             = [0.9, 0.9; 0, 0];
            tx.DDSPhases             = [90000, 0; 0, 0];
            tx();
            pause(1);

            % RX with all-pass CFIR — reference capture
            rx = adi.AD9084.Rx('uri', testCase.uri);
            rx.EnabledChannels       = 1;
            rx.MainNCOFrequencies    = [1e9 0 0 0];
            rx.ChannelNCOFrequencies = [100e6 0 0 0];
            rx.EnableCFIRs           = true;
            rx.CFIRFilenames         = apFile;
            for k = 1:10, out = rx(); end
            refPower = max(20*log10(abs(fft(double(out(:,1)))) + eps));

            % Reload with LP CFIR — filtered capture
            release(rx);
            rx.CFIRFilenames = lpFile;
            for k = 1:10, out = rx(); end
            filtPower = max(20*log10(abs(fft(double(out(:,1)))) + eps));

            attenuation = refPower - filtPower;
            fprintf('CFIR Attenuation: %.2f dB (threshold: %d dB)\n', attenuation, ATTN_THRESHOLD_DB);
            testCase.verifyGreaterThan(attenuation, ATTN_THRESHOLD_DB, ...
                'CFIR did not attenuate stopband tone sufficiently');
            rx.release();
            tx.release();
        end

    end

end
