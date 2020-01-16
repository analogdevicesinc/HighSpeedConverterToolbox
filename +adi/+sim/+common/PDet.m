classdef PDet < matlab.system
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
        SHORT_PA_THRESHOLD {mustBeInteger,...
            mustBeGreaterThanOrEqual(SHORT_PA_THRESHOLD,0),...
            mustBeLessThan(SHORT_PA_THRESHOLD,8192)} = 0;
        LONG_PA_ENABLE {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_ENABLE,0),...
            mustBeLessThanOrEqual(LONG_PA_ENABLE,1)} = 0;
        LONG_PA_AVG_TIME {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_AVG_TIME,0),...
            mustBeLessThanOrEqual(LONG_PA_AVG_TIME,15)} = 0;
        LONG_PA_THRESHOLD {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_THRESHOLD,0),...
            mustBeLessThan(LONG_PA_THRESHOLD,8192)} = 0;
    end
    
    properties (SetAccess = private)
        ShortWindowLength = 1;    % 2^SHORT_PA_AVG_TIME
        LongWindowLength = 2^9;   % 2^(LONG_PA_AVG_TIME+9)
        RampTime = 1024;    % 32*2^(BE_GAIN_RAMP_RATE+5)@DAC rate
    end
    
    properties (Hidden, NonCopyable)
        ShortWinMovAvg;     % short window moving average
        LongWinMovAvg;      % long window moving average
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
    end
    
    methods(Access = private)
        function obj = updateShortWindowLength(obj)
            obj.ShortWindowLength = 2^obj.SHORT_PA_AVG_TIME;
        end
        
        function obj = updateLongWindowLength(obj)
            obj.LongWindowLength = 2^(obj.LONG_PA_AVG_TIME+9);
        end
    end
    
    methods(Access = protected)
        function setupImpl(obj)
            obj.ShortWinMovAvg = dsp.movingAverage('Method', 'Sliding window',...
                'SpecifyWindowLength', true,...
                'WindowLength', obj.ShortWindowLength);
            obj.LongWinMovAvg = dsp.movingAverage('Method', 'Sliding window',...
                'SpecifyWindowLength', true,...
                'WindowLength', obj.LongWindowLength);
        end
        
        function u = stepImpl(obj, u)
            u = u.^2;   % instantanuous power
            u = (obj.ShortWinMovAvg(u) > obj.SHORT_PA_THRESHOLD)|...
                (obj.LONGWinMovAvg(u) > obj.LONG_PA_THRESHOLD);
        end
    end
end
            
            
            