classdef DAC9081 < adi.sim.common.DACGeneric
    % Specific Implementation of DAC for AD9081/AD9082
    %
    properties(Nontunable, Constant)
        Bits = 16;
        SNRFS = 64.2185;
%         ConverterNSD = -162;
    end
    
    properties(Dependent)
        ConverterNSD;
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
        
        function value = get.ConverterNSD(obj)
            NoisePowerPerBin = -10*log10(obj.SampleRate/2);
            value = NoisePowerPerBin-obj.SNRFS;
        end
        
    end
end
