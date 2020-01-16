classdef CDDC < matlab.System
    % CDDC Coarse Digital Down Converter
    %
    properties(Nontunable)
        % SampleRate Sample Rate of Input data
        %   Scalar in Hz
        SampleRate = 1e9;
        % NCODesiredFrequency NCO Desired Frequency
        %   Frequency of NCO complex output in Hz. Since this value is
        %   limited by the NCO word with, check the NCONCOActualFrequency
        NCODesiredFrequency = 1e6;
        % NCODesiredPhase NCO Desired Phase
        %   Phase of NCO complex output in radians. Since this value is
        %   limited by the NCO word with, check the NCONCOActualPhase
        %NCODesiredPhase = 0;
        % NCOEnable NCO Enable
        %   Enable use of NCO. If false NCO is bypassed
        NCOEnable = false;
        % Decimation
        %   Decimation factor
        Decimation = 1;
        %OutputGainEnable Output Gain Enable
        %   Add 6dB gain at output
        OutputGainEnable = false;
    end
    
    properties(Dependent)
       NCOActualFrequency
       NCOActualPhase
    end
    
    properties(Hidden, Constant)
       NCOFTWWidth = 48; % Bits
       NCOFTWPhaseWidth = 16; % Bits
    end
    
    properties(NonCopyable, Hidden)
        NCO
        HB2
        HB1
        TB1
    end
    
    properties(Access = private, Hidden)
        FilterPath
    end

    methods
        % Constructor
        function obj = CDDC(varargin)
            setProperties(obj,nargin,varargin{:});
        end
        % Check Decimation
        function set.Decimation(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 1,'<=', 6}, ...
                '', 'Decimation');
            options = [1,2,3,4,6];
            assert(any(value==options),'Decimation can be 1,2,3,4,6');
            obj.Decimation = value;
        end
        % Dependent parameters
        function value = get.NCOActualFrequency(obj)
            % Determine closest frequency tuning word
            FTW = obj.getDDSCounterModulus();
            value = int64(FTW*obj.SampleRate/(2^obj.NCOFTWWidth));
        end
        function FTW = getDDSCounterModulus(obj)
            FTW = floor((2^obj.NCOFTWWidth)*obj.NCODesiredFrequency/obj.SampleRate);
        end
        function value = get.NCOActualPhase(obj)
            % Determine closest frequency tuning word
            FTW = obj.getDDSCounterModulus();
            value = int64(FTW*obj.SampleRate/(2^obj.NCOFTWWidth));
        end
    end
    
    methods(Access = protected)
        
        function ConfigureNCO(obj,data)
            obj.NCO.SamplesPerFrame = length(data);

            minSFDR = 102; % >= Spurious free dynamic range in dBc
            phOffset = 0;
            % Calculate number of quantized accumulator bits
            % required from the SFDR requirement
            Nqacc = ceil((minSFDR-12)/6);

%             Nacc = ceil(log2(1/(df*Ts)));
%             phOffset = 2^Nacc*dphi/(2*pi);
            
            obj.NCO.PhaseOffset = phOffset;
            obj.NCO.NumDitherBits = 4; %% FIXME
            obj.NCO.NumQuantizerAccumulatorBits = Nqacc;
            obj.NCO.Waveform = 'Complex exponential';
            obj.NCO.CustomAccumulatorDataType =  numerictype([],obj.NCOFTWWidth);
            obj.NCO.PhaseIncrementSource = 'Property';
            obj.NCO.PhaseIncrement = int64(getDDSCounterModulus(obj));
            obj.NCO.CustomOutputDataType =  numerictype([],17,16);
        end
        
        function setupImpl(obj,data)
            obj.NCO = adi.sim.common.NCO;
            obj.HB2 = adi.sim.common.HB2;
            obj.HB1 = adi.sim.common.HB1;
            obj.TB1 = adi.sim.common.TB1;
        
            % Build filter cascade based on mode
            switch obj.Decimation
                case 6
                    obj.FilterPath = cascade(obj.HB2,obj.TB1);
                case 4
                    obj.FilterPath = cascade(obj.HB2,obj.HB1);
                case 3
                    obj.FilterPath = cascade(obj.TB1);
                case 2
                    obj.FilterPath = cascade(obj.HB1);
                otherwise
                    obj.FilterPath = [];
            end
            % Setup NCO
            ConfigureNCO(obj,data);
        end
        
        function u = stepImpl(obj,u)
            % Runtime calls           
            u = complex(u);
            if obj.NCOEnable
                u = u.*obj.NCO();
            end
            u = fi(u,1,16,0);
            
            if obj.Decimation~=1
                u = obj.FilterPath(u);
                u = fi(u,1,16,0);
            end
            
            if obj.OutputGainEnable
                u = bitshift(u,1);
                u = fi(u,1,16,0);
            end
        end
        
    end
end
