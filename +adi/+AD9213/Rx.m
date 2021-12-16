classdef Rx < adi.common.Rx & adi.AD9213.Base
    % adi.AD9213.Rx Receive data from the AD9213 high speed ADC
    %   The adi.AD9213.Rx System object is a signal source that can receive
    %   complex data from the AD9213.
    %
    %   rx = adi.AD9213.Rx;
    %   rx = adi.AD9213.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9213.pdf">AD9213 Datasheet</a>
    %
    %   See also adi.DAQ2.Rx
    
    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value is constant
        % SamplingRate = 1e9;
    end
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9213-rx-hpc';
        channel_names = {'voltage0','voltage1'};
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9213.Base(varargin{:});
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
            bName = 'AD9213';
        end
        
    end
end

