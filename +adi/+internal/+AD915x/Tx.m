classdef Tx < adi.common.Tx & adi.AD915x.Base & adi.common.DDS & adi.common.Attribute
    % adi.AD915x.Tx Transmit data to the AD9144 high speed DAC
    %   
    %
    
    properties (Dependent)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   in samples per second. This value is constant
        SamplingRate
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
    end
   
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD915x.Base(varargin{:});
        end
        
        function value = get.SamplingRate(obj)
            if obj.ConnectedToDevice
                value= obj.getAttributeLongLong('voltage0','sampling_frequency',true);
            else
                value = NaN;
            end
        end
    end
    
    %% External Dependency Methods
    methods (Hidden, Static)
        
        function tf = isSupportedContext(bldCfg)
            tf = matlabshared.libiio.ExternalDependency.isSupportedContext(bldCfg);
        end
        
        function updateBuildInfo(buildInfo, bldCfg)
            % Call the matlabshared.libiio.method first
            matlabshared.libiio.ExternalDependency.updateBuildInfo(buildInfo, bldCfg);
        end
    end
end

