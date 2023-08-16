classdef FMCOMMS11Test < HardwareTests
    properties
        uri ='ip:analog.local';
        author = 'ADI';
    end

    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.FMCOMMS11.Rx;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Static)
        function estFrequency(data,fs)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
%             df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1000;
%             plot(freqRangeRx, FFTRxData);
            df = fs/nSamp;  freqRangeRx = (0:df:fs/2-df).'/1000;
            plot(freqRangeRx, FFTRxData(end-length(freqRangeRx)+1:end,:));
        end
        
        function freq = estFrequencyMax(data,fs)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
            df = fs/nSamp;  freqRangeRx = (0:df:fs/2-df).';
            [~,ind] = max(FFTRxData(end-length(freqRangeRx)+1:end,:));
            freq = freqRangeRx(ind);
        end
        
    end

    methods(Test)
        function testFMCOMMS11Rx(testCase)
            rx = adi.FMCOMMS11.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end


        function testFMCOMMS11RxWithTxDDS(testCase)
            % Test DDS output
            tx = adi.FMCOMMS11.Tx('uri',testCase.uri);
            tx.DataSource = 'DDS';
            toneFreq = 45e6;
            tx.DDSFrequencies = repmat(toneFreq,2,2);
            tx();
            pause(1);
            rx = adi.FMCOMMS11.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            valid = false;
            for k=1:10
                [out, valid] = rx();
            end
%             freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            freqEst = testCase.estFrequencyMax(out(:,1),rx.SamplingRate);
            rx.release();

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(double(freqEst),toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
    end
end


