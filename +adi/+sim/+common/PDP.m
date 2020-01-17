classdef PDP < matlab.System
    % Power Detection and Protection (PDP) for MxFE Tx to protect PA
    %
    % It detects two types of potential PA failure, over-voltage and
    % thermal, and ramp down the digital output. It can either remain off
    % until turned back on throug SPI (not modeled); or automatically ramp
    % back up after a set time.
    %
    % Over-voltage protection compares the average power over
    % 2^SHORT_PA_AVG_TIME(1:0) samples to SHORT_PA_THRESHOLD[12:0]; while
    % thermal protection compares the average power over
    % 2^(LONG_PA_AVG_TIME(3:0)+9) samples to LONG_PA_THRESHOLD[12:0]. It
    % will trigger a ramp-down when either one is over threshold.
    
    properties (Nontunable)
        % Below are SPI registers
        SHORT_PA_ENABLE {mustBeInteger,...
            mustBeGreaterThanOrEqual(SHORT_PA_ENABLE,0),...
            mustBeLessThanOrEqual(SHORT_PA_ENABLE,1)} = 0;
        SHORT_PA_AVG_TIME {mustBeInteger,...
            mustBeGreaterThanOrEqual(SHORT_PA_AVG_TIME,0),...
            mustBeLessThanOrEqual(SHORT_PA_AVG_TIME,3)} = 0;
%        SHORT_PA_POWER {mustBeInteger,...
%            mustBeGreaterThanOrEqual(SHORT_PA_POWER,0),...
%            mustBeLessThan(SHORT_PA_POWER,8192)} = 0;
        SHORT_PA_THRESHOLD {mustBeInteger,...
            mustBeGreaterThanOrEqual(SHORT_PA_THRESHOLD,0),...
            mustBeLessThan(SHORT_PA_THRESHOLD,8192)} = 0;
        LONG_PA_ENABLE {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_ENABLE,0),...
            mustBeLessThanOrEqual(LONG_PA_ENABLE,1)} = 0;
        LONG_PA_AVG_TIME {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_AVG_TIME,0),...
            mustBeLessThanOrEqual(LONG_PA_AVG_TIME,15)} = 0;
%        LONG_PA_POWER {mustBeInteger,...
%            mustBeGreaterThanOrEqual(LONG_PA_POWER,0),...
%            mustBeLessThan(LONG_PA_POWER,8192)} = 0;
        LONG_PA_THRESHOLD {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_THRESHOLD,0),...
            mustBeLessThan(LONG_PA_THRESHOLD,8192)} = 0;
        BE_GAIN_RAMP_RATE {mustBeInteger,...
            mustBeGreaterThanOrEqual(BE_GAIN_RAMP_RATE,0),...
            mustBeLessThan(BE_GAIN_RAMP_RATE,8)} = 0;
        %This variable is uncertain
        PA_OFF_TIME {mustBeInteger,...
            mustBeGreaterThanOrEqual(PA_OFF_TIME,0),...
            mustBeLessThan(PA_OFF_TIME,1024)} = 0;
        %Interpolation factor from PA detector to output
        InterpX {mustBeInteger,...
            mustBeGreaterThan(InterpX,0),...
            mustBeMember(InterpX,[1 2 4 6 8 12])} = 1;
    end
    
    properties (SetAccess = private)
        ShortWindowLength = 1;    % 2^SHORT_PA_AVG_TIME
        LongWindowLength = 2^9;   % 2^(LONG_PA_AVG_TIME+9)
        RampTime = 1024;    % 32*2^(BE_GAIN_RAMP_RATE+5)@DAC rate
    end
    
    properties (Hidden, NonCopyable)
        ShortWinMovAvg;     % short window moving average
        LongWinMovAvg;      % long window moving average
        OffWindow;          % LP filter for PA off window
        RampWindow;         % LP filter for ramping
    end

    methods
        function set.SHORT_PA_AVG_TIME(obj, val)
            obj.SHORT_PA_AVG_TIME = val;
            obj.updateShortWindowLength;
        end
        
        function set.LONG_PA_AVG_TIME(obj, val)
            obj.LONG_PA_AVG_TIME = val;
            obj.updateLongWindowLength;
        end
        
        function set.BE_GAIN_RAMP_RATE(obj, val)
            obj.BE_GAIN_RAMP_RATE = val;
            obj.updateRampTime;
        end
    end
    
    methods(Access = private)
        function obj = updateShortWindowLength(obj)
            obj.ShortWindowLength = 2^obj.SHORT_PA_AVG_TIME;
        end
        
        function obj = updateLongWindowLength(obj)
            obj.LongWindowLength = 2^(obj.LONG_PA_AVG_TIME+9);
        end
        
        function obj = updateRampTime(obj)
            obj.RampTime = 2^(obj.BE_GAIN_RAMP_RATE+5);
        end
    end
    
    methods(Access = protected)
        function setupImpl(obj)
            obj.ShortWinMovAvg = dsp.MovingAverage('Method', 'Sliding window',...
                'SpecifyWindowLength', true,...
                'WindowLength', obj.ShortWindowLength);
            obj.LongWinMovAvg = dsp.MovingAverage('Method', 'Sliding window',...
                'SpecifyWindowLength', true,...
                'WindowLength', obj.LongWindowLength);
            obj.OffWindow = dsp.FIRFilter(ones(1,obj.RampTime+obj.PA_OFF_TIME));
            obj.RampWindow = dsp.FIRFilter(ones(1,obj.RampTime));
        end
        
        function out = stepImpl(obj, u)
            u = u/2^9;
            u=fi(u,1,7,0);  % recast to 7bit (sign+6MSBs)
            u = u.*conj(u);   % instantanuous power
            u = ((obj.ShortWinMovAvg(double(u)) > obj.SHORT_PA_THRESHOLD) & obj.SHORT_PA_ENABLE)|...
                ((obj.LongWinMovAvg(double(u)) > obj.LONG_PA_THRESHOLD) & obj.LONG_PA_ENABLE);
            % interpolate to output data rate by inserting zeros
            InterpArray = ones(1,obj.InterpX);
            PAErrOut = reshape((u*InterpArray).', obj.InterpX*length(u), 1);
            % find start of ramp-down and ramp-up
            PAOff = obj.OffWindow(PAErrOut);
            PAOff = logical(PAOff);
            RampUpDown = obj.RampWindow(PAOff-[0; PAOff(1:end-1)]);
            out = 1 - cumsum(RampUpDown)/obj.RampTime;
        end
    end
end
            
            
            