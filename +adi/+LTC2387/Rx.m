classdef Rx < adi.common.Rx & adi.LTC2387.Base & adi.common.Attribute
    % adi.LTC2387.Rx Receive data from the LTC2387 high speed ADC
    %   The adi.LTC2387.Rx System object is a signal source that can receive
    %   complex data from the LTC2387.
    %
    %   rx = adi.LTC2387.Rx;
    %   rx = adi.LTC2387.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/LTC2387.pdf">LTC2387 Datasheet</a>
    %
    %   See also adi.LLDK.Rx

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
        devName = 'ltc2387';
        phyDevName = 'ltc2387';
        channel_names = {'voltage0','voltage1','voltage2','voltage3'};
    end

    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.LTC2387.Base(varargin{:});
        end
        function value = get.SamplingRate(obj)
            if obj.ConnectedToDevice
                value= obj.getAttributeLongLong('voltage0','sampling_frequency',false);
            else
                value = NaN;
            end
        end
    end

    %% API Functions
    methods (Hidden, Access = protected)
        function setupInit(~)
            %unused
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
            bName = 'LTC2387';
        end

    end
end

