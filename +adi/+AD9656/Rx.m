classdef Rx < adi.common.Rx & adi.AD9656.Base & adi.common.Attribute
    % adi.AD9656.Rx Receive data from the AD9656 high speed ADC
    %   The adi.AD9656.Rx System object is a signal source that can receive
    %   complex data from the AD9656.
    %
    %   rx = adi.AD9656.Rx;
    %   rx = adi.AD9656.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/ad9656.pdf">AD9656 Datasheet</a>
    %

    
    properties (Dependent)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value is constant
        SamplingRate
    end
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9656-hpc';
        phyDevName = 'axi-ad9656-hpc';
        channel_names = {'voltage0','voltage1'};
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9656.Base(varargin{:});
        end
        function value = get.SamplingRate(obj)
            if obj.ConnectedToDevice
                value= obj.getAttributeLongLong('voltage0','sampling_frequency',false);
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
        
        function bName = getDescriptiveName(~)
            bName = 'AD9656';
        end
        
    end
end

