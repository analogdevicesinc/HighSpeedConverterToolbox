classdef DACGeneric < matlab.System
    % DACGeneric Generic DAC Model
    %
    properties(Abstract, Nontunable, Constant)
        Bits
    end
    
    properties(Abstract, Dependent)
        %ConverterNSD Converter NSD (dBFS/Hz)
        %   Specify the noise spectral density in dBc/Hz as a scalar
        ConverterNSD;
    end
    
    properties(Abstract, Nontunable)
        SampleRate
    end
    
    properties(Hidden, Nontunable)
        RMSNoiseVolts
        FullScaleOut = 2^15;
    end
    
    methods(Access = protected)
        function setupImpl(obj)           
            obj.RMSNoiseVolts = 2^15.*10.^((obj.ConverterNSD+30)/20);
        end
        
        function noise = genNoise(obj,len)
            %% Generate noise and calculate Noise Power
            noise = obj.RMSNoiseVolts.*(randn(len,1)); % Real Noise           
        end
        
        function y = stepImpl(obj,u)
            y = double(u) + genNoise(obj,length(u));
        end
        
    end
end
