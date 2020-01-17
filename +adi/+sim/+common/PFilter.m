classdef PFilter < matlab.System
    % Programmable Filter for MxFE and variants
    properties (Nontunable)
        %Mode Mode
        %   Programmable filter configuration mode. The following notation
        %   will be used to describe the filtering modes:
        %   - x1: first input
        %   - x2: second input
        %   - y1: first output
        %   - y2: second output
        %   - F1: filter 1
        %   - F2: filter 2
        %   - F3: filter 3
        %   - F4: filter 4
        %   - p: length of filters (individually)
        %   The supported configuration modes are:
        %   - NoFilter: y1 = x1, y2 = x2
        %   - SingleInphase: y1 = F1(x1), y2 = x2
        %   - SingleQuadrature: y1 = x1, y2 = F1(x2)
        %   - DualReal: y1 = F1(x1), y2 = F2(x2)
        %   - HalfComplexSumInphase: y1 = F1(x1)+F2(x1), y2 = x2*z^-p
        %   - HalfComplexSumQuadrature: y2 = F1(x1)+F2(x1), y1 = x1*z^-p
        %   - FullComplex: y1 = F1(x1)-F3(x2), y2 = F1(x1)+F3(x2)-F2(x1+x2) 
        %   - Matrix: y1 = F1(x1) - F3(x2), y2 = F2(x1) - F4(x2)
        Mode = 'SingleInphase';
        %TapsWidthsPerQuad Taps Widths Per Quad
        %   Number of bits per each set of four coefficients. This matrix
        %   must be [NxM] where N is the number of distinct filters based
        %   on the current *Mode* parameter, and M is
        %   (number of individual taps)/4
        TapsWidthsPerQuad = [...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6];
        %Taps Taps
        %   Filter coefficuents. This matrix must be [NxM] where N is the 
        %   number of distinct filters based on the current *Mode* 
        %   parameter, and M is the number of individual taps
        Taps = randn(4,192/4).*2^6;
        %Gains Gains
        %   Output gains applied to filter stages. Can be -12,-6,0,6,12
        %   Input must be a [1x4] vector where each entry is the gain for
        %   the filters 1-4 in order.
        Gains = [0,0,0,0];
    end
    
    properties(DiscreteState)
        
    end
    
    properties(Access = private, Hidden)
        TapsCast = {};
        Filters
        DelayLine
    end
    
    properties(Hidden, Constant=true)
        ModeSet = matlab.system.StringSet({'NoFilter','SingleInphase',...
            'SingleQuadrature','DualReal','HalfComplexSumInphase',...
            'HalfComplexSumQuadrature','FullComplex',...
            'Matrix'});
        MaxTaps = 192;
    end
    
    properties(Hidden, Nontunable)
        ModeNum = 0;
    end
    
    methods
        % Constructor
        function obj = PFilter(varargin)
            setProperties(obj,nargin,varargin{:});
        end
        % Property validation
        % Check TapsWidthsPerQuad
        function set.TapsWidthsPerQuad(obj, value)
            [filters,taps] = size(value);
            taps = taps*4;
            obj.checkFilterDescription(filters,taps,4);
            obj.TapsWidthsPerQuad = value;
        end
        % Check Taps
        function set.Taps(obj, value)
            [filters,taps] = size(value);
            obj.checkFilterDescription(filters,taps,1);
            obj.Taps = value;
        end
        % Check Gains
        function set.Gains(obj, value)
            options = [-12,-6,0,6,12];
            assert(isequal(size(value),[1,4]),'Gains must be a 1x4 vector');
            for k=1:length(value)
                assert(any(value(k)==options),'Gains can be -12,-6,0,6,12');
            end
            obj.Gains = value;
        end
    end
    
    methods(Access = protected)
        
        function checkFilterDescription(obj,filters,taps,N)
            switch obj.Mode
                case 'NoFilter'
                case {'SingleInphase','SingleQuadrature'}
                    if filters~=1
                        error(['In ',obj.Mode,' mode, input must be a single row array']); %#ok<*MCSUP>
                    end
                    if taps~=192 && taps~=96
                        error(['In ',obj.Mode,' mode, input must contain ',num2str(96/N),' or ',num2str(192/N),' columns']);
                    end
                case 'DualReal'
                    if filters~=2
                        error(['In ',obj.Mode,' mode, input must be a two row matrix']);
                    end
                    if taps~=96
                        error(['In ',obj.Mode,' mode, input must contain ',num2str(96/N),' columns']);
                    end
                case {'HalfComplexSumInphase','HalfComplexSumQuadrature'}
                    if filters~=2
                        error(['In ',obj.Mode,' mode, input must be a two row matrix']);
                    end
                    if obj.MaxTaps/filters~=taps
                        error(['In ',obj.Mode,' mode, input must contain ',num2str(obj.MaxTaps/filters/N),' columns']);
                    end
                case 'FullComplex'
                    if filters~=3
                        error(['In ',obj.Mode,' mode, input must be a three row matrix']);
                    end
                    if obj.MaxTaps/filters~=taps
                        error(['In ',obj.Mode,' mode, input must contain ',num2str(obj.MaxTaps/filters/N),' columns']);
                    end
                case 'Matrix'
                    if filters~=4
                        error(['In ',obj.Mode,' mode, input must be a four row matrix']);
                    end
                    if obj.MaxTaps/filters~=taps
                        error(['In ',obj.Mode,' mode, input must contain ',num2str(obj.MaxTaps/filters/N),' columns']);
                    end
            end
        end
        
        function taps = checkTaps(~,tapsOrg,allowedBits,ts,f)
            taps = tapsOrg.*2^15;
            quant = int16(fi(taps,1,allowedBits,0));
            quantRef = int16(taps);
            if abs(sum(quant-quantRef))>0
                warning('Quantization Error in tap set %d for filter %d',ts,f);
            end
            taps = double(quant)./2^15;
        end
        
        function setupImpl(obj)
            
            obj.ModeNum = obj.ModeSet.getIndex(obj.Mode);
            [filters,tapGroups] = size(obj.TapsWidthsPerQuad);
            
            % Configure taps
            if obj.ModeNum > 1
                obj.Filters = cell(1,filters);
                obj.TapsCast = cell(filters,tapGroups);
                for filter = 1:filters
                    for tapGroup = 1:tapGroups
                        
                        bits = obj.TapsWidthsPerQuad(filter,tapGroup);
                        tapIndex = (tapGroup-1)*4+1:tapGroup*4;
                        
                        taps = obj.checkTaps(obj.Taps(filter,tapIndex),bits,tapGroup,filter);
                        
                        obj.TapsCast{filter,tapGroup} = taps;
                    end
                    taps = [obj.TapsCast{filter,:}];
                    obj.Filters{filter} = dsp.FIRFilter('Numerator',taps);
                end
            end
            
            obj.DelayLine = dsp.DelayLine('Length',tapGroups*4);
        end
        
        function [z1,z2] = stepImpl(obj,u1,u2)
                        
            switch obj.ModeNum
                case 1
                    y1 = u1;
                    y2 = u2;
                case 2
                    y1 = step(obj.Filters{1},u1);
                    if obj.Gains(1)~=0
                        y1 = bitshift(y1,obj.Gains(1)/6);
                    end
                    y2 = u2;
                case 3
                    y1 = u1;                    
                    y2 = step(obj.Filters{1},u2);
                    if obj.Gains(2)~=0
                        y2 = bitshift(y2,obj.Gains(1)/6);
                    end
                case 4
                    y1 = step(obj.Filters{1},u1);
                    y2 = step(obj.Filters{2},u2);
                    if obj.Gains(1)~=0
                        y1 = bitshift(y1,obj.Gains(1)/6);
                    end
                    if obj.Gains(2)~=0
                        y2 = bitshift(y2,obj.Gains(2)/6);
                    end
                case 5
                    m1 = step(obj.Filters{1},u1);
                    m2 = step(obj.Filters{2},u2);
                    if obj.Gains(1)~=0
                        m1 = bitshift(m1,obj.Gains(1)/6);
                    end
                    if obj.Gains(2)~=0
                        m2 = bitshift(m2,obj.Gains(2)/6);
                    end
                    y1 = m1 + m2;
                    y2 = obj.DelayLine(u2);
                case 6
                    m1 = step(obj.Filters{1},u1);
                    m2 = step(obj.Filters{2},u2);
                    if obj.Gains(1)~=0
                        m1 = bitshift(m1,obj.Gains(1)/6);
                    end
                    if obj.Gains(2)~=0
                        m2 = bitshift(m2,obj.Gains(2)/6);
                    end
                    y2 = m1 + m2;
                    y1 = obj.DelayLine(u1);
                case 7
                    m1 = step(obj.Filters{1},u1);
                    m2 = step(obj.Filters{2},u2);
                    if obj.Gains(1)~=0
                        m1 = bitshift(m1,obj.Gains(1)/6);
                    end
                    if obj.Gains(2)~=0
                        m2 = bitshift(m2,obj.Gains(2)/6);
                    end
                    m3 = u1+u2;
                    m4 = step(obj.Filters{3},m3);
                    if obj.Gains(3)~=0
                        m4 = bitshift(m4,obj.Gains(3)/6);
                    end
                    y1 = m1 - m2;
                    y2 = m1 + m2 - m4;
                case 8
                    m1 = step(obj.Filters{1},u1);
                    m2 = step(obj.Filters{2},u1);
                    m3 = step(obj.Filters{3},u2);
                    m4 = step(obj.Filters{4},u2);
                    if obj.Gains(1)~=0
                        m1 = bitshift(m1,obj.Gains(1)/6);
                    end
                    if obj.Gains(2)~=0
                        m2 = bitshift(m2,obj.Gains(2)/6);
                    end
                    if obj.Gains(3)~=0
                        m3 = bitshift(m3,obj.Gains(3)/6);
                    end
                    if obj.Gains(4)~=0
                        m4 = bitshift(m4,obj.Gains(4)/6);
                    end
                    y1 = m1 + m3;
                    y2 = m2 + m4;
            end
            % Cast
            z1 = fi(y1,1,16,0);
            z2 = fi(y2,1,16,0);
        end
        
        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end
    end
end
