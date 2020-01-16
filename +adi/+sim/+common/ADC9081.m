classdef ADC9081 < adi.sim.common.ADCGeneric
    % Specific Implementation of ADC for AD9081/AD9082
    %
    properties(Nontunable, Constant)
        FullScaleVoltage = 1.4;
        Bits = 12;
        ConverterNSD = -150;
    end
    
    properties(Nontunable)
        SampleRate = 4e9;
    end
    
    methods
        % Check SampleRate
        function set.SampleRate(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 1.5e9,'<=', 4e9}, ...
                '', 'Gain');
            obj.SampleRate = value;
        end        
    end
end
