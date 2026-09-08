classdef DelayLine < matlab.System
    %DelayLine Frame-based streaming delay independent of dsp.DelayLine.
    properties (Nontunable)
        Length (1,1) {mustBeInteger,mustBeNonnegative} = 1
    end

    properties (DiscreteState, Hidden)
        State
    end

    methods
        function obj = DelayLine(varargin)
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj, input)
            obj.State = zeros(obj.Length, size(input, 2), 'like', input);
        end

        function output = stepImpl(obj, input)
            if obj.Length == 0
                output = input;
                return;
            end
            buffered = [obj.State; input];
            output = buffered(1:size(input, 1), :);
            obj.State = buffered(end-obj.Length+1:end, :);
        end

        function resetImpl(obj)
            obj.State(:) = 0;
        end
    end
end
