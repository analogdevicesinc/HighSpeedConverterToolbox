classdef FMCOMMS11Test < matlab.unittest.TestCase
    properties
        uri ='ip:analog.local';
        author = 'ADI';
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
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            rx.release();

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
    end
end


