classdef ADCGeneric < matlab.System
    % ADCGeneric Generic ADC Model
    %
    properties(Abstract, Nontunable, Constant)
        FullScaleVoltage
        Bits
        SNRFS
    end
    
    properties(Abstract, Dependent)
        %ConverterNSD Converter NSD (dBFS/Hz)
        %   Specify the noise spectral density in dBFS/Hz as a scalar
        ConverterNSD;
    end
    
    properties(Abstract, Nontunable)
        SampleRate
    end
    
    properties(Hidden, Nontunable)
        FSR
        LSB
        MAX_Voltage
        MIN_Voltage
        MAX_dBFS
        MIN_dBFS
        RMSNoiseVolts
    end
    
    methods(Access = protected)
        function setupImpl(obj)
            obj.FSR = 2^(obj.Bits-1);
            obj.LSB = obj.FullScaleVoltage/obj.FSR;
            obj.MAX_Voltage = obj.FullScaleVoltage-obj.LSB;
            obj.MIN_Voltage =-obj.FullScaleVoltage+obj.LSB;
            obj.MAX_dBFS = obj.FSR-1;
            obj.MIN_dBFS = -obj.FSR;
            
            % NSD = 20*log10(RMSNoiseVolts/FullScale) - 10*log10(FS/2)
            k = (obj.ConverterNSD + 10*log10(obj.SampleRate/2))/20;
            obj.RMSNoiseVolts = obj.FullScaleVoltage*10^k;
        end
        
        function noise = genNoise(obj,len)
            %% Generate noise and calculate Noise Power
            noise = obj.RMSNoiseVolts.*(randn(len,1)); % Real Noise           
        end
        
        function dataQ = quantize(obj,data)
            %% Quantize and limit
            % data = bsxfun(@plus,fix(data)+floor(rem(data,1)/LSB)*LSB,[0 LSB]);
            data = round(data .* 1/obj.LSB);
            data(data>obj.FSR) = obj.FSR;
            data(data<-obj.FSR+1) = -obj.FSR+1;
                        
            %% Convert to correct data type
            dataQ = fi(data,1,obj.Bits,0);
        end
        
        function y = stepImpl(obj,u)
            u = u + genNoise(obj,length(u));
            y = quantize(obj,u);
        end
        
    end
end
