classdef Rx < adi.common.Rx & adi.AD9208.Base
    % adi.AD9208.Rx Receive data from the AD9208 high speed multi-channel ADC
    %   The adi.AD9208.Rx System object is a signal source that can receive
    %   data from the AD9208.
    %
    %   rx = adi.AD9208.Rx;
    %   rx = adi.AD9208.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9208.pdf">AD9208 Datasheet</a>
    %
    
    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value is constant
        SamplingRate = 125e6;
    end
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-AD9208-rx-hpc';
        channel_names = {...
		'voltage0',...
		'voltage1',...
		};
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9208.Base(varargin{:});
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
            bName = 'AD9208';
        end
        
    end
end

