classdef DAC9081 < adi.sim.common.DACGeneric
    % Specific Implementation of DAC for AD9081/AD9082
    %
    properties(Nontunable, Constant)
        Bits = 16;
        ConverterNSD = -162;
    end
    
    properties(Nontunable)
        SampleRate = 12e9;
    end
    
    methods
        % Check SampleRate
        function set.SampleRate(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 0.5e9,'<=', 12e9}, ...
                '', 'Gain');
            obj.SampleRate = value;
        end        
    end
end
