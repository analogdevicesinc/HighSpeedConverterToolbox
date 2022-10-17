classdef Tx < adi.common.Tx & adi.AD9783.Base & adi.common.DDS
    % adi.AD9783.Tx Transmit data to the AD9783 DAC
    %   The adi.AD9783.Tx contains 2 DACs
    %
    %   tx = adi.AD9783.Tx;
    %   tx = adi.AD9783.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9780_9781_9783.pdf">AD9783 Datasheet</a>
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
    
    properties (Nontunable, Hidden)
        devName = 'ad9783_core_dds';
        channel_names = {'voltage0'};
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9783.Base(varargin{:});
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
            bName = 'AD9783';
        end
        
    end
end

