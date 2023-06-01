
classdef AD9434Test < matlab.unittest.TestCase
    properties
        uri = 'ip:10.48.65.160';%analog.local';
        author = 'ADI';
    end

    methods(Test)
        function testAD9434Rx(testCase)
            rx = adi.AD9434.Rx('uri',testCase.uri)
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();

            plot(out);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
    end
    
end

