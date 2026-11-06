classdef AD9088HWTests < HardwareTests

    properties
        uri = 'ip:analog.local';
        author = 'ADI';
    end

    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            % Probe disabled so configuration errors fail rather than
            % being filtered as a missing device
            disp('Skipping init test');
%             Device = @()adi.AD9088.Rx;
%             testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end

    methods (Test)

        function testAD9088Rx(testCase)
            % Test Rx DMA data output
            rx = adi.AD9088.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifySize(out,[rx.SamplesPerFrame,1]);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end

        function testAD9088RxWithTxDDS(testCase)
            % Test DDS output
            tx = adi.AD9088.Tx('uri',testCase.uri);
            tx.DataSource = 'DDS';
            toneFreq = 45e6;
            tx.DDSSingleTone(toneFreq, 0.1, 1);
            tx();
            pause(1);
            rx = adi.AD9088.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            valid = false;
            for k=1:10
                [out, valid] = rx();
            end
            sr = rx.SamplingRate;
            rx.release();
            tx.release();

            freqEst = meanfreq(double(real(out)),sr);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end

        function testAD9088RxWithTxData(testCase)
            % Test Tx DMA data output
            tx = adi.AD9088.Tx('uri',testCase.uri);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx(complex(zeros(1024,1)));
            sr = tx.SamplingRate;
            tx.release();

            amplitude = 2^15; frequency = sr/6;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = false;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = sr;
            y = swv1();

            tx = adi.AD9088.Tx('uri',testCase.uri);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx(y);
            rx = adi.AD9088.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            for k=1:10
                [out, valid] = rx();
            end
            sr = rx.SamplingRate;
            rx.release();
            tx.release();

            freqEst = meanfreq(double(real(out)),sr);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of ML tone unexpected')
        end

    end

end
