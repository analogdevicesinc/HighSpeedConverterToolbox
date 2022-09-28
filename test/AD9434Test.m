classdef AD9434Test < matlab.unittest.TestCase
    properties
        uri = 'ip:analog.local';
        author = 'ADI';
    end


    methods(Test)
        function testAD9434Rx(testCase)
            rx = adi.AD9434.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
    end
    
end


