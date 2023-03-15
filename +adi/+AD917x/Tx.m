classdef Tx < adi.common.Tx & adi.AD917x.Base & adi.common.DDS
    % adi.AD917x.Tx Transmit data to the AD9162 high speed DAC
    %
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/software/AD917x-API.html#software-overview">AD917x </a>
    %
    
    
    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   in samples per second. This value is constant
        SamplingRate = 1e9;
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
            obj = obj@adi.AD917x.Base(varargin{:});
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

