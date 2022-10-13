classdef AD9739aTest < matlab.unittest.TestCase
    properties
        uri = 'ip:analog.local';
        author = 'ADI';
    end


    methods(Test)
        function testAD9739aTx(testCase)
            tx = adi.AD9739a.Tx('uri',testCase.uri);
            tx.EnableCyclicBuffers = true;
            x = linspace(-pi,pi,2^15).';

            b1 = sin(x);
            % subplot(2,1,1);
            % plot(b1);
            tx(b1);
            tx.step(b1);

%             testCase.verifyTrue(valid);
%             testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
    end

end


