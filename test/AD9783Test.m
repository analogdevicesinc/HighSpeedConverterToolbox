classdef AD9783Test < matlab.unittest.TestCase
    properties
        uri = 'ip:analog.local';
        author = 'ADI';
    end


    methods(Test)
        function testAD9783Tx(testCase)
            tx = adi.AD9783.Tx('uri',testCase.uri);
            tx.EnableCyclicBuffers = true;
            x = linspace(-pi,pi,2^15).';

            b1 = sin(x);
            tx(b1);
            tx.step(b1);
        end
    end

end


