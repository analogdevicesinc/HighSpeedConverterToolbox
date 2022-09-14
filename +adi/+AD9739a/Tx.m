classdef Tx < adi.common.Tx & adi.AD9739a.Base & adi.common.DDS
    % adi.AD9739a.Tx Transmit data to the AD9739a high speed DAC
    %   The adi.AD9739a.Tx System object is a signal source that can send
    %   complex data from the AD9739a.
    %
    %   tx = adi.AD9739a.Tx;
    %   tx = adi.AD9739a.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9737A_9739A.pdf">AD9739a Datasheet</a>
    %
    
    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   in samples per second. This value is constant
        SamplingRat=1e9; 
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9739a-hpc';
        channel_names = {'voltage0'};
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9739a.Base(varargin{:});
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
        
        function bName = getDescriptiveName(~)
            bName = 'AD9739a';
        end
        
    end
end

