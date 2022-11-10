classdef AD9695Test < HardwareTests
    
    properties
        uri = 'ip:analog.local';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.AD9695.Rx;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Static)
        function estFrequency(data,fs)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
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
        
        function testAD9695Rx(testCase) 
            rx = adi.AD9695.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
    end
    
end

