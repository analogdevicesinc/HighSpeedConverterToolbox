classdef Base < matlab.System & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    % AD9081 Base class
   
    properties(Hidden, NonCopyable)
        %% RX
        ADC0
        ADC1
        ADC2
        ADC3
        % Programmable filters
        PFIR1
        PFIR2
        % Coarse Digital down converters
        CDDC1
        CDDC2
        CDDC3
        CDDC4
        % Fine Digital down converters
        FDDC1
        FDDC2
        FDDC3
        FDDC4 
        FDDC5
        FDDC6
        FDDC7
        FDDC8
        %% TX
        DAC0
        DAC1
        DAC2
        DAC3
        % Tx Power detection and protection
        PDP1
        PDP2
        PDP3
        PDP4
        % Coarse Digital up converters
        CDUC1
        CDUC2
        CDUC3
        CDUC4
        % Fine Digital up converters
        FDUC1
        FDUC2
        FDUC3
        FDUC4        
        FDUC5
        FDUC6
        FDUC7
        FDUC8
    end
    
    properties(Hidden, Constant)
       RXADCs = 4;
       RXDACs = 4;
    end
    
    methods
        % Constructor
        function obj = Base(varargin)
            if isa(obj,'adi.sim.AD9081.Rx')
                obj.ADC0 = adi.sim.common.ADC9081;
                obj.ADC1 = adi.sim.common.ADC9081;
                obj.ADC2 = adi.sim.common.ADC9081;
                obj.ADC3 = adi.sim.common.ADC9081;
                % Programmable filters
                obj.PFIR1 = adi.sim.common.PFilter;
                obj.PFIR2 = adi.sim.common.PFilter;
                % Coarse Digital down converters
                obj.CDDC1 = adi.sim.common.CDDC;
                obj.CDDC2 = adi.sim.common.CDDC;
                obj.CDDC3 = adi.sim.common.CDDC;
                obj.CDDC4 = adi.sim.common.CDDC;
                % Fine Digital down converters
                obj.FDDC1 = adi.sim.common.FDDC;
                obj.FDDC2 = adi.sim.common.FDDC;
                obj.FDDC3 = adi.sim.common.FDDC;
                obj.FDDC4 = adi.sim.common.FDDC;
                obj.FDDC5 = adi.sim.common.FDDC;
                obj.FDDC6 = adi.sim.common.FDDC;
                obj.FDDC7 = adi.sim.common.FDDC;
                obj.FDDC8 = adi.sim.common.FDDC;
            else
                obj.DAC0 = adi.sim.common.DAC9081;
                obj.DAC1 = adi.sim.common.DAC9081;
                obj.DAC2 = adi.sim.common.DAC9081;
                obj.DAC3 = adi.sim.common.DAC9081;
                % Power detection and protection
                obj.PDP1 = adi.sim.common.PDP;
                obj.PDP2 = adi.sim.common.PDP;
                obj.PDP3 = adi.sim.common.PDP;
                obj.PDP4 = adi.sim.common.PDP;
                % Coarse Digital down converters
                obj.CDUC1 = adi.sim.common.CDUC;
                obj.CDUC2 = adi.sim.common.CDUC;
                obj.CDUC3 = adi.sim.common.CDUC;
                obj.CDUC4 = adi.sim.common.CDUC;
                % Fine Digital down converters
                obj.FDUC1 = adi.sim.common.FDUC;
                obj.FDUC2 = adi.sim.common.FDUC;
                obj.FDUC3 = adi.sim.common.FDUC;
                obj.FDUC4 = adi.sim.common.FDUC;
                obj.FDUC5 = adi.sim.common.FDUC;
                obj.FDUC6 = adi.sim.common.FDUC;
                obj.FDUC7 = adi.sim.common.FDUC;
                obj.FDUC8 = adi.sim.common.FDUC;
            end
            setProperties(obj,nargin,varargin{:});
        end
        
        function obj = delete(obj)
            obj.ADC0 = [];
            obj.ADC1 = [];
            obj.ADC2 = [];
            obj.ADC3 = [];
            %
            obj.PFIR1 = [];
            obj.PFIR2 = [];
            %
            obj.CDDC1 = [];
            obj.CDDC2 = [];
            obj.CDDC3 = [];
            obj.CDDC4 = [];
            %
            obj.FDDC1 = [];
            obj.FDDC2 = [];
            obj.FDDC3 = [];
            obj.FDDC4 = [];
            obj.FDDC5 = [];
            obj.FDDC6 = [];
            obj.FDDC7 = [];
            obj.FDDC8 = [];
            %
            obj.DAC0 = [];
            obj.DAC1 = [];
            obj.DAC2 = [];
            obj.DAC3 = [];
            %
            obj.PDP1 = [];
            obj.PDP2 = [];
            obj.PDP3 = [];
            obj.PDP4 = [];
            %
            obj.CDUC1 = [];
            obj.CDUC2 = [];
            obj.CDUC3 = [];
            obj.CDUC4 = [];
            %
            obj.FDUC1 = [];
            obj.FDUC2 = [];
            obj.FDUC3 = [];
            obj.FDUC4 = [];
            obj.FDUC5 = [];
            obj.FDUC6 = [];
            obj.FDUC7 = [];
            obj.FDUC8 = [];  
        end
        
        function filters = RxCascade(obj)
            %%RxCascade Get cascade filter object of RX path ignoring NCOs
            if ~isLocked(obj.CDDC1) || ~isLocked(obj.FDDC1)
               error('Model must be initialized/stepped before filters can be extracted'); 
            end
            
            if obj.FDDC1.Decimation==1 && obj.CDDC1.Decimation==1
                error('No decimation filters are enabled, no avaible response');
            elseif obj.FDDC1.Decimation>1 && obj.CDDC1.Decimation==1
                filters = obj.FDDC1.FilterPath;
            elseif obj.FDDC1.Decimation==1 && obj.CDDC1.Decimation>1
                filters = obj.CDDC1.FilterPath;
            else
                filters = cascade(obj.CDDC1.FilterPath,obj.FDDC1.FilterPath);
            end
        end

        function filters = TxCascade(obj)
            %%TxCascade Get cascade filter object of TX path ignoring NCOs
            if ~isLocked(obj.FDUC1) || ~isLocked(obj.CDUC1)
               error('Model must be initialized/stepped before filters can be extracted'); 
            end
            if obj.FDUC1.Interpolation==1 && obj.CDUC1.Interpolation==1
                error('No interpolator filters are enabled, no avaible response');
            elseif obj.FDUC1.Interpolation>1 && obj.CDUC1.Interpolation==1
                filters = obj.FDUC1.FilterPath;
            elseif obj.FDUC1.Interpolation==1 && obj.CDUC1.Interpolation>1
                filters = obj.CDUC1.FilterPath;
            else
                filters = cascade(obj.FDUC1.FilterPath,obj.CDUC1.FilterPath);
            end
        end

        
    end
    
    methods(Access = protected)
        
        % Hide unused parameters when in specific modes
        function flag = isInactivePropertyImpl(obj, prop)
            flag = false;
            if isprop(obj,'PFIREnable')
                if ~obj.PFIREnable
                    flag = flag || strcmpi(prop,'PFilter1Mode');
                    flag = flag || strcmpi(prop,'PFilter1TapsWidthsPerQuad');
                    flag = flag || strcmpi(prop,'PFilter1Taps');
                    flag = flag || strcmpi(prop,'PFilter1Gains');
                    flag = flag || strcmpi(prop,'PFilter2Mode');
                    flag = flag || strcmpi(prop,'PFilter2TapsWidthsPerQuad');
                    flag = flag || strcmpi(prop,'PFilter2Taps');
                    flag = flag || strcmpi(prop,'PFilter2Gains');
                end
            end
            
            if isprop(obj,'MainDataPathInterpolation')
                flag = flag || (obj.MainDataPathInterpolation == 1) && strcmpi(prop,'CDUCNCOFrequencies');
                flag = flag || (obj.MainDataPathInterpolation == 1) && strcmpi(prop,'CDUCNCOEnable');
                flag = flag || (obj.MainDataPathInterpolation == 1) && strcmpi(prop,'CDUCNGainAdjustDB'); 
            end
            if isprop(obj,'ChannelizerPathInterpolation')
                flag = flag || (obj.ChannelizerPathInterpolation == 1) && strcmpi(prop,'FDUCNCOFrequencies');
                flag = flag || (obj.ChannelizerPathInterpolation == 1) && strcmpi(prop,'FDUCNCOEnable');
                flag = flag || (obj.ChannelizerPathInterpolation == 1) && strcmpi(prop,'FDUCNGainAdjustDB'); 
            end
            
        end
    end
    
end
