classdef PDP < matlab.system
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
    
    properties (Hidden, NonCopyable)
        Pdet;   % Power detector
    end
    
    methods
        function obj = set.BE_GAIN_RAMP_RATE(obj, val)
            obj.BE_GAIN_RAMP_RATE = val;
            obj.updateRampTime;
        end
    end
    
    methods(Access = private)
        function obj = updateRampTime(obj)
            obj.RampTime = 2^(obj.BE_GAIN_RAMP_RATE+5);
        end
    end
    
    methods(Access = protected)
        function setupImpl(obj)
            obj.Pdet = adi.sim.common.Pdet;
            obj.Pdet.SHORT_PA_ENABLE = SHORT_PA_ENABLE;
            obj.Pdet.SHORT_PA_AVG_TIME = SHORT_PA_AVG_TIME;
            obj.Pdet.SHORT_PA_THRESHOLD = SHORT_PA_THRESHOLD;
            obj.Pdet.LONG_PA_ENABLE = LONG_PA_ENABLE;
            obj.Pdet.LONG_PA_AVG_TIME = LONG_PA_AVG_TIME;
            obj.Pdet.LONG_PA_THRESHOLD = LONG_PA_THRESHOLD;
        end
        
        function [SHORT_PA_POWER, LONG_PA_POWER, PAOff, ] = stepImpl(obj, CDUCout, FDUCout)
            u = u.^2;   % instantanuous power
            SHORT_PA_POWER = obj.ShortWinMovAvg(u);
            LONG_PA_POWER = obj.LONGWinMovAvg(u);
            PAErr = (obj.ShortWinMovAvg(u) > obj.SHORT_PA_THRESHOLD)|...
                (LONG_PA_POWER > obj.LONG_PA_THRESHOLD);
            % interpolate to output data rate by inserting zeros
            InterpArray = zeros(obj.InterpX,1); InterpArray(1)=1;
            PAErrOut = reshape(InterpArray*PAErr, obj.InterpX*length(u), 1);
            % find start of ramp-down and ramp-up
            PAOff = conv(PAErrOut,ones(obj.RampTime+obj.PA_OFF_TIME,1));
            PAOff = logical(PAOff);
            RampUpDown = conv(PAOff-[0; PAOff(2:end)],ones(obj.RampTime,1));
            u = u.*(1 - cumsum(RampUpDown)/obj.RampTime);
        end
    end
end
            
            
            