classdef Rx < adi.common.Rx & adi.AD9250.Base & adi.common.Attribute
    % adi.AD9250.Rx Receive data from the AD9250 ADC
    %
    %   rx = adi.AD9250.Rx;
    %   rx = adi.AD9250.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9250.pdf">AD9250 Datasheet</a>
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
        devName = 'axi-ad9250-hpc-0';
        channel_names = {'voltage0','voltage1','voltage2','voltage3'};
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9250.Base(varargin{:});
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
            bName = 'AD9250';
        end
        
    end
end

