classdef CDUC < matlab.System
    % CDDC Coarse Digital Up Converter
    %
    properties(Nontunable)
        % SampleRate Sample Rate of Input data
        %   Scalar in Hz
        SampleRate = 1e9;
        % NCODesiredFrequency NCO Desired Frequency
        %   Frequency of NCO complex output in Hz. Since this value is
        %   limited by the NCO word with, check the NCONCOActualFrequency
        NCODesiredFrequency = 1e6;
        % NCOEnable NCO Enable
        %   Enable use of NCO. If false NCO is bypassed
        NCOEnable = false;
        % Interpolation
        %   Interpolation factor
        Interpolation = 1;
        %GainAdjustDB Gain Adjust DB
        %   Input gain adjust in dB
        GainAdjustDB = 0;
    end
    
    properties(Dependent)
        NCOActualFrequency
        GainAdjust
    end
    
    properties(Hidden, Constant)
        NCOFTWWidth = 48; % Bits
    end
    
    properties(Hidden)
        DataPathWidth = 16; % Bits
    end
    
    properties(NonCopyable, Hidden)
        NCO
        HB5_TX
        HB4_TX
        HB3_TX
        TB1_TX
    end
    
    properties(Hidden)
        FilterPath
    end
    
    methods
        % Constructor
        function obj = CDUC(varargin)
            setProperties(obj,nargin,varargin{:});
        end
        % Check Interpolation
        function set.Interpolation(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 1,'<=', 12}, ...
                '', 'Interpolation');
            options = [1,2,4,6,8,12];
            assert(any(value==options),'Interpolation can be 1,2,4,6,8,12');
            obj.Interpolation = value;
        end
        % Check NCODesiredFrequency
        function set.NCODesiredFrequency(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'finite', 'nonnan', 'nonempty',...
                '>=',-obj.SampleRate/2,...
                '<=', obj.SampleRate/2}, ...
                '', 'NCODesiredFrequency'); %#ok<MCSUP>
            obj.NCODesiredFrequency = value;
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
        function value = get.GainAdjust(obj)
            gainCode = 2^11*10^(obj.GainAdjustDB/20);
            value = gainCode/2048;
        end
    end
    
    methods(Access = protected)
        
        function ConfigureNCO(obj,data)
            obj.NCO.SamplesPerFrame = length(data)*obj.Interpolation;
            
            minSFDR = 102; % >= Spurious free dynamic range in dBc
            phOffset = 0;
            % Calculate number of quantized accumulator bits
            % required from the SFDR requirement
            Nqacc = ceil((minSFDR-12)/6);
            
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
            obj.HB5_TX = adi.sim.common.HB5_TX;
            obj.HB4_TX = adi.sim.common.HB4_TX;
            obj.HB3_TX = adi.sim.common.HB3_TX;
            obj.TB1_TX = adi.sim.common.TB1_TX;
            
            % Build filter cascade based on mode
            switch obj.Interpolation
                case 12
                    obj.FilterPath = cascade(obj.HB3_TX,obj.TB1_TX,obj.HB5_TX);
                case 8
                    obj.FilterPath = cascade(obj.HB3_TX,obj.HB4_TX,obj.HB5_TX);
                case 6
                    obj.FilterPath = cascade(obj.HB3_TX,obj.TB1_TX);
                case 4
                    obj.FilterPath = cascade(obj.HB3_TX,obj.HB4_TX);
                case 2
                    obj.FilterPath = cascade(obj.HB3_TX);
                otherwise
                    obj.FilterPath = [];
            end
            % Setup NCO
            ConfigureNCO(obj,data);
        end
        
        function u = stepImpl(obj,u)
            % Runtime calls
            u = complex(u);
            
            if obj.Interpolation~=1
                u = u.*obj.GainAdjust;
                u = fi(u,1,obj.DataPathWidth,0);
                
                u = obj.FilterPath(u);
                u = fi(u,1,obj.DataPathWidth,0);
                
                if obj.NCOEnable                   
                    u = u.*obj.NCO();
                    u = fi(u,1,obj.DataPathWidth,0);
                end
            else
                u = fi(u,1,obj.DataPathWidth,0);
            end
        end
        
    end
end
