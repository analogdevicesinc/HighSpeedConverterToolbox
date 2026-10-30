classdef Tx < adi.AD9088.Base & adi.common.Tx
    % adi.AD9088.Tx Transmit data from the AD9088 high speed DAC
    %   The adi.AD9088.Tx System object is a signal sink that can transmit
    %   complex data from the AD9088.
    %
    %   tx = adi.AD9088.Tx;
    %   tx = adi.AD9088.Tx('uri','ip:192.168.2.1');
    %
    %   <a href="https://www.analog.com/media/en/technical-documentation/data-sheets/ad9088.pdf">AD9088 Datasheet</a>
    %
    %   See also adi.AD9088.Rx

    properties
        %ChannelNCOFrequencies Channel NCO Frequencies
        %   Frequency of NCO in fine interpolators in transmit path.
        %   Property must be a [1,N] vector where each value is the
        %   frequency of an NCO in hertz.
        ChannelNCOFrequencies = zeros(1,8);
        %MainNCOFrequencies Main NCO Frequencies
        %   Frequency of NCO in coarse interpolators in transmit path.
        %   Property must be a [1,N] vector where each value is the
        %   frequency of an NCO in hertz.
        MainNCOFrequencies = zeros(1,8);
        %ChannelNCOPhases Channel NCO Phases
        %   Phase of NCO in fine interpolators in transmit path. Property
        %   must be a [1,N] vector where each value is the phase of an
        %   NCO in millidegrees.
        ChannelNCOPhases = zeros(1,8);
        %MainNCOPhases Main NCO Phases
        %   Phase of NCO in coarse interpolators in transmit path.
        %   Property must be a [1,N] vector where each value is the phase
        %   of an NCO in millidegrees.
        MainNCOPhases = zeros(1,8);
        %ChannelNCOGainScales Channel NCO Gain Scales
        %   Digital gain of fine interpolators in transmit path. Property
        %   must be a [1,N] vector where each value is a linear gain
        %   scale.
        ChannelNCOGainScales = 0.5.*ones(1,8);
        %NCOEnables NCO Enables
        %   Vector of logicals which enabled individual NCOs in channel
        %   interpolators
        NCOEnables = true(1,8);
    end

    properties(Logical)
        %DDROffloadEnable DDR Offload Enable
        %   Enable use of BRAM in Tx datapath to offload from DDR. This is
        %   necessary for highspeed configurations when DDR is not fast
        %   enough for datapath
        DDROffloadEnable = false;
    end

    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end

    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
    end

    properties (Hidden, Constant)
        ComplexData = true;
    end

    properties (Nontunable, Hidden)
        channel_names;
        % Data channels are the scan elements of devName (one side).
        % Attribute channels are output channels on phyDevName and cover
        % both sides.
        num_data_channels = 4;
        num_coarse_attr_channels = 8;
        num_fine_attr_channels = 8;
        % Four DDS tones (I/Q x two tones) per data channel
        num_dds_channels = 16;
        devName = 'axi-ad9084-tx-hpc';
        phyDev
    end

    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9088.Base(varargin{:});
            obj.channel_names = {};
            for k = 0:(obj.num_data_channels-1)
                obj.channel_names = [obj.channel_names(:)', ...
                    {sprintf('voltage%d_i',k)},{sprintf('voltage%d_q',k)}];
            end

            obj.dds_channel_names = {};
            for k=0:obj.num_dds_channels-1
                obj.dds_channel_names = [...
                    obj.dds_channel_names(:)',...
                    {sprintf('altvoltage%d',k)}];
            end
            l = obj.num_dds_channels/2;
            obj.DDSFrequencies = zeros(2,l);
            obj.DDSPhases = zeros(2,l);
            obj.DDSScales = zeros(2,l);

            obj.ChannelNCOFrequencies = zeros(1,obj.num_fine_attr_channels);
            obj.MainNCOFrequencies = zeros(1,obj.num_coarse_attr_channels);
            obj.ChannelNCOPhases = zeros(1,obj.num_fine_attr_channels);
            obj.MainNCOPhases = zeros(1,obj.num_coarse_attr_channels);
            obj.ChannelNCOGainScales = 0.5.*ones(1,obj.num_fine_attr_channels);
            obj.NCOEnables = ones(1,obj.num_fine_attr_channels) > 0;
        end
        % Check ChannelNCOFrequencies
        function set.ChannelNCOFrequencies(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequencies',...
                'channel_nco_frequency', obj.phyDev, true); %#ok<*MCSUP>
            obj.ChannelNCOFrequencies = value;
        end
        %%
        % Check MainNCOFrequencies
        function set.MainNCOFrequencies(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequencies',...
                'main_nco_frequency', obj.phyDev, true);
            obj.MainNCOFrequencies = value;
        end
        %%
        % Check ChannelNCOPhases
        function set.ChannelNCOPhases(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhases',...
                'channel_nco_phase', obj.phyDev, true);
            obj.ChannelNCOPhases = value;
        end
        %%
        % Check MainNCOPhases
        function set.MainNCOPhases(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhases',...
                'main_nco_phase', obj.phyDev, true);
            obj.MainNCOPhases = value;
        end
        %%
        % Check ChannelNCOGainScales
        function set.ChannelNCOGainScales(obj, value)
            obj.CheckAndUpdateHWFloat(value,'ChannelNCOGainScales',...
                'channel_nco_gain_scale', obj.phyDev, true);
            obj.ChannelNCOGainScales = value;
        end
        %%
        % Check NCOEnables
        function set.NCOEnables(obj, value)
            obj.CheckAndUpdateHWBool(value,'NCOEnables',...
                'en', obj.phyDev, true);
            obj.NCOEnables = value;
        end
        %%
        % Check DDROffloadEnable
        function set.DDROffloadEnable(obj, value)
            obj.DDROffloadEnable = value;
            if obj.ConnectedToDevice
                obj.setDebugAttributeBool('pl_ddr_fifo_enable',value, true, obj.iioDev);
            end
        end
    end

    %% API Functions
    methods (Hidden, Access = protected)

        function setupImpl(obj, data)
            if strcmp(obj.DataSource,'DMA')
                setupImpl@adi.common.Tx(obj, data);
            else
                setupImpl@adi.common.Tx(obj);
            end
            if obj.SkipInit
                obj.phyDev = getDev(obj, obj.phyDevName);
            end
        end

        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required since Simulink support doesn't support
            % modification to nontunable variables at SetupImpl

            % Set main PHY
            obj.phyDev = getDev(obj, obj.phyDevName);

            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequencies,...
                'ChannelNCOFrequencies','channel_nco_frequency', ...
                obj.phyDev, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFrequencies,...
                'MainNCOFrequencies','main_nco_frequency', ...
                obj.phyDev, true);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOPhases,...
                'ChannelNCOPhases','channel_nco_phase', ...
                obj.phyDev, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOPhases,...
                'MainNCOPhases','main_nco_phase', ...
                obj.phyDev, true);
            %%
            obj.CheckAndUpdateHWFloat(obj.ChannelNCOGainScales,...
                'ChannelNCOGainScales','channel_nco_gain_scale', ...
                obj.phyDev, true);
            %%
            obj.CheckAndUpdateHWBool(obj.NCOEnables,...
                'NCOEnables','en', ...
                obj.phyDev, true);
            %% DDS
            obj.ToggleDDS(strcmp(obj.DataSource,'DDS'));
            if strcmp(obj.DataSource,'DDS')
                obj.DDSUpdate();
            else
                obj.setDebugAttributeBool('pl_ddr_fifo_enable',...
                    obj.DDROffloadEnable, false, obj.iioDev);
            end
        end

    end

end
