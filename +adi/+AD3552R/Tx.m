classdef Tx < adi.common.Tx & adi.AD3552R.Base
    % adi.AD3552R.Tx Transmit data to the AD3552R high speed DAC
    %   The adi.AD3552R.Tx System object is a signal source that can send
    %   complex data from the AD3552R.
    %
    %   tx = adi.AD3552R.Tx;
    %   tx = adi.AD3552R.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD3552R.pdf">AD3552R Datasheet</a>
    %
    %   See also adi.CN0585.Tx

    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value is constant
        SamplingRate = 15e6;
    end

    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end

    properties (Nontunable, Hidden, Constant)
        Type = 'Tx';
    end

    properties (Nontunable, Hidden)
        devName = 'axi-ad3552r';
        phyDevName = 'axi-ad3552r';
        channel_names = {'voltage0', 'voltage1'};
    end

    properties
        StreamStatus = 'stop_stream';
    end

    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD3552R.Base(varargin{:});
        end

        %% Start or stop stream transfer
        function set.StreamStatus(obj, value)

            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('stream_status', value);
            else
                error(['StreamStatus cannot be set before initialization, ']);
            end

            obj.StreamStatus = value;

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
            bName = 'AD3552R';
        end

    end

end
