classdef ADC9081 < adi.sim.common.ADCGeneric
    % Specific Implementation of ADC for AD9081/AD9082
    %
    properties(Nontunable, Constant)
        FullScaleVoltage = 1.4;
        Bits = 12;
        SNRFS = 56.9897;
    end
    
    properties(Dependent)
        ConverterNSD;
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
        
        function value = get.ConverterNSD(obj)
            NoisePowerPerBin = -10*log10(obj.SampleRate/2);
            value = NoisePowerPerBin-obj.SNRFS;
        end
    end
end
