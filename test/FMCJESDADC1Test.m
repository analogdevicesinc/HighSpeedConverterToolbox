classdef FMCJESDADC1Test < matlab.unittest.TestCase
    properties
        uri = 'ip:10.48.65.110';%'ip:analog.local';
        author = 'ADI';
    end


    methods(Test)
        function testFMCJESDADC1Rx(testCase)
            rx = adi.FMCJESDADC1.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
    end
    
end


