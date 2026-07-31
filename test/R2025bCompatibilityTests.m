classdef R2025bCompatibilityTests < matlab.unittest.TestCase
    methods (Test)
        function delayLinePreservesStateAcrossFrames(testCase)
            delay = adi.sim.common.DelayLine('Length', 3);
            first = delay((1:2).');
            second = delay((3:5).');
            testCase.verifyEqual(first, zeros(2, 1));
            testCase.verifyEqual(second, [0; 1; 2]);
        end

        function delayLineSupportsZeroDelay(testCase)
            delay = adi.sim.common.DelayLine('Length', 0);
            input = (1:4).';
            testCase.verifyEqual(delay(input), input);
        end


        function delayLinePreservesComplexMultichannelTypeAndResets(testCase)
            delay = adi.sim.common.DelayLine('Length', 2);
            input = complex(fi([1 2; 3 4], 1, 16, 0), ...
                fi([5 6; 7 8], 1, 16, 0));
            first = delay(input);
            second = delay(input);
            testCase.verifyClass(first, class(input));
            testCase.verifySize(first, size(input));
            testCase.verifyEqual(first, zeros(size(input), 'like', input));
            testCase.verifyEqual(second, input);
            reset(delay);
            testCase.verifyEqual(delay(input), zeros(size(input), 'like', input));
        end

        function pFilterHalfComplexUsesStreamingDelay(testCase)
            taps = zeros(2, 96);
            widths = 16 .* ones(2, 24);
            filter = adi.sim.common.PFilter( ...
                'Mode', 'HalfComplexSumInphase', ...
                'Taps', taps, ...
                'TapsWidthsPerQuad', widths);
            firstInput = int16((1:64).');
            secondInput = int16((65:128).');
            [~, firstDelayed] = filter(firstInput, firstInput);
            [~, secondDelayed] = filter(secondInput, secondInput);
            testCase.verifyEqual(int16(firstDelayed), zeros(64, 1, 'int16'));
            testCase.verifyEqual(int16(secondDelayed), ...
                [zeros(32, 1, 'int16'); int16((1:32).')]);
            reset(filter);
            [~, resetDelayed] = filter(firstInput, firstInput);
            testCase.verifyEqual(int16(resetDelayed), zeros(64, 1, 'int16'));
        end
    end
end
