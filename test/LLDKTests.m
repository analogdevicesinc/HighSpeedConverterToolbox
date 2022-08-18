classdef LLDKTests < HardwareTests
    
    properties
        uri = 'ip:analog';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.lldk.Rx;
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
    
    methods (Test)
        
        function testLLDKRx(testCase)    
            % Test Rx DMA data output
            rx = adi.LLDK.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            rx.release();

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
        
        function testDAQ2RxWithTxDDSTwoChan(testCase)
            % Test DDS output
            tx = adi.DAQ2.Tx('uri',testCase.uri);
            tx.DataSource = 'DDS';
            toneFreq1 = 160e6;
            toneFreq2 = 300e6;
            tx.DDSFrequencies = [toneFreq1,toneFreq2;toneFreq1,toneFreq2];
            tx.DDSScales = [1,1;0,0].*0.029;
            tx();
            pause(1);
            rx = adi.DAQ2.Rx('uri',testCase.uri);
            rx.EnabledChannels = [1 2];
            valid = false;
            for k=1:10
                [out, valid] = rx();
            end
            
%             plot(real(out));
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst1 = testCase.estFrequencyMax(out(:,1),rx.SamplingRate);
            freqEst2 = testCase.estFrequencyMax(out(:,2),rx.SamplingRate);
%             freqEst1 = meanfreq(double(real(out(:,1))),rx.SamplingRate);
%             freqEst2 = meanfreq(double(real(out(:,2))),rx.SamplingRate);
            rx.release();

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(double(freqEst1),toneFreq1,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            testCase.verifyEqual(double(freqEst2),toneFreq2,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            rx.release();
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of ML tone unexpected')
        
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst1 = testCase.estFrequencyMax(out(:,1),rx.SamplingRate);
            freqEst2 = testCase.estFrequencyMax(out(:,2),rx.SamplingRate);
%             freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            rx.release();
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(double(freqEst1),toneFreq1,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            testCase.verifyEqual(double(freqEst2),toneFreq2,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
        
    end
    
end

