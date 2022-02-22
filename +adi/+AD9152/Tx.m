classdef Tx < adi.common.Tx & adi.AD9152.Base & adi.common.DDS & adi.common.Attribute
    % adi.AD9152.Tx Transmit data to the AD9144 high speed DAC
    %   The adi.AD9152.Tx System object is a signal source that can send
    %   complex data from the AD9144.
    %
    %   tx = adi.AD9144.Tx;
    %   tx = adi.AD9144.Tx('uri','ip:192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9144.pdf">AD9144 Datasheet</a>
    %
    %   See also adi.DAQ3.Tx
    
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
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9152-hpc';
        phyDevName = 'axi-ad9152-hpc';
        channel_names = {'voltage0','voltage1'};
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9152.Base(varargin{:});
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
        
        function bName = getDescriptiveName(~)
            bName = 'AD9152';
        end
        
    end
end

