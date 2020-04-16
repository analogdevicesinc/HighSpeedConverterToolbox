classdef Tx < adi.QuadMxFE.Base & adi.common.Tx
    % adi.QuadMxFE.Tx Transmit data from the QuadMxFE development board
    %   The adi.QuadMxFE.Tx System object is a signal sink that can tranmsit
    %   complex data from the QuadMxFE.
    %
    %   tx = adi.QuadMxFE.Tx;
    %   tx = adi.QuadMxFE.Tx('uri','ip:192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9081.pdf">AD9081 Datasheet</a>

    properties
        %ChannelNCOFrequenciesChipA Channel NCO Frequencies Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequenciesChipA = [0,0,0,0];
        %ChannelNCOFrequenciesChipB Channel NCO Frequencies Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequenciesChipB = [0,0,0,0];
        %ChannelNCOFrequenciesChipC Channel NCO Frequencies Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequenciesChipC = [0,0,0,0];
        %ChannelNCOFrequenciesChipD Channel NCO Frequencies Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequenciesChipD = [0,0,0,0];
    end
    
    properties
        %MainNCOFrequenciesChipA Main NCO Frequencies Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequenciesChipA = [0,0,0,0];
        %MainNCOFrequenciesChipB Main NCO Frequencies Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequenciesChipB = [0,0,0,0];
        %MainNCOFrequenciesChipC Main NCO Frequencies Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequenciesChipC = [0,0,0,0];
        %MainNCOFrequenciesChipD Main NCO Frequencies Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequenciesChipD = [0,0,0,0];
    end
    
    properties
        %ChannelNCOPhasesChipA Channel NCO Phases Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhasesChipA = [0,0,0,0];
        %ChannelNCOPhasesChipB Channel NCO Phases Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhasesChipB = [0,0,0,0];
        %ChannelNCOPhasesChipC Channel NCO Phases Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhasesChipC = [0,0,0,0];
        %ChannelNCOPhasesChipD Channel NCO Phases Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhasesChipD = [0,0,0,0];
    end
    
    properties
        %MainNCOPhasesChipA Main NCO Phases Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhasesChipA = [0,0,0,0];
        %MainNCOPhasesChipB Main NCO Phases Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhasesChipB = [0,0,0,0];
        %MainNCOPhasesChipC Main NCO Phases Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhasesChipC = [0,0,0,0];
        %MainNCOPhasesChipD Main NCO Phases Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhasesChipD = [0,0,0,0];
    end
    
    properties
        %ChannelNCOGainScalesChipA Channel NCO Gain Scales Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOGainScalesChipA = [0,0,0,0];
        %ChannelNCOGainScalesChipB Channel NCO Gain Scales Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOGainScalesChipB = [0,0,0,0];
        %ChannelNCOGainScalesChipC Channel NCO Gain Scales Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOGainScalesChipC = [0,0,0,0];
        %ChannelNCOGainScalesChipD Channel NCO Gain Scales Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOGainScalesChipD = [0,0,0,0];
    end
    
    properties
        %NCOEnablesChipA NCO Enables Chip A
        %   Vector of logicals which enabled individual NCOs in channel
        %   interpolators
        NCOEnablesChipA = [false,false,false,false];
        %NCOEnablesChipB NCO Enables Chip B
        %   Vector of logicals which enabled individual NCOs in channel
        %   interpolators
        NCOEnablesChipB = [false,false,false,false];
        %NCOEnablesChipC NCO Enables Chip C
        %   Vector of logicals which enabled individual NCOs in channel
        %   interpolators
        NCOEnablesChipC = [false,false,false,false];
        %NCOEnablesChipD NCO Enables Chip D
        %   Vector of logicals which enabled individual NCOs in channel
        %   interpolators
        NCOEnablesChipD = [false,false,false,false];
    end
       
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
    end
    
    properties (Nontunable, Hidden)
        channel_names;
        num_data_channels = 32;
        num_coarse_attr_channels = 4;
        num_fine_attr_channels = 8;
        num_dds_channels = 128;
        devName = 'axi-ad9081-tx-3';
        devName0 = 'axi-ad9081-rx-0';
        devName1 = 'axi-ad9081-rx-1';
        devName2 = 'axi-ad9081-rx-2';
        devName3 = 'axi-ad9081-rx-3';
    end
    
    properties (Hidden)
       iioDev0;
       iioDev1;
       iioDev2;
       iioDev3;
       iioDevADF4371_0;
       iioDevADF4371_1;
       iioDevADF4371_2;
       iioDevADF4371_3;
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.QuadMxFE.Base(varargin{:});
            obj.uri = 'ip:analog';
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
            
            obj.ChannelNCOFrequenciesChipA = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOFrequenciesChipB = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOFrequenciesChipC = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOFrequenciesChipD = zeros(1,obj.num_fine_attr_channels);
            obj.MainNCOFrequenciesChipA = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFrequenciesChipB = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFrequenciesChipC = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFrequenciesChipD = zeros(1,obj.num_coarse_attr_channels);
            obj.ChannelNCOPhasesChipA = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOPhasesChipB = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOPhasesChipC = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOPhasesChipD = zeros(1,obj.num_fine_attr_channels);
            obj.MainNCOPhasesChipA = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOPhasesChipB = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOPhasesChipC = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOPhasesChipD = zeros(1,obj.num_coarse_attr_channels);
            obj.ChannelNCOGainScalesChipA = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOGainScalesChipB = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOGainScalesChipC = zeros(1,obj.num_fine_attr_channels);
            obj.ChannelNCOGainScalesChipD = zeros(1,obj.num_fine_attr_channels);
            obj.NCOEnablesChipA = zeros(1,obj.num_fine_attr_channels) > 0;
            obj.NCOEnablesChipB = zeros(1,obj.num_fine_attr_channels) > 0;
            obj.NCOEnablesChipC = zeros(1,obj.num_fine_attr_channels) > 0;
            obj.NCOEnablesChipD = zeros(1,obj.num_fine_attr_channels) > 0;
        end
        % Check ChannelNCOFrequenciesChipA
        function set.ChannelNCOFrequenciesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipA',...
                'channel_nco_frequency', obj.iioDev0, true); %#ok<*MCSUP>
            obj.ChannelNCOFrequenciesChipA = value;
        end
        % Check ChannelNCOFrequenciesChipB
        function set.ChannelNCOFrequenciesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipA',...
                'channel_nco_frequency', obj.iioDev1, true);
            obj.ChannelNCOFrequenciesChipB = value;
        end
        % Check ChannelNCOFrequenciesChipC
        function set.ChannelNCOFrequenciesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipC',...
                'channel_nco_frequency', obj.iioDev2, true);
            obj.ChannelNCOFrequenciesChipC = value;
        end
        % Check ChannelNCOFrequenciesChipD
        function set.ChannelNCOFrequenciesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipD',...
                'channel_nco_frequency', obj.iioDev3, true);
            obj.ChannelNCOFrequenciesChipD = value;
        end
        %%
        % Check MainNCOFrequenciesChipA
        function set.MainNCOFrequenciesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipA',...
                'main_nco_frequency', obj.iioDev0, true);
            obj.MainNCOFrequenciesChipA = value;
        end
        % Check MainNCOFrequenciesChipB
        function set.MainNCOFrequenciesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipA',...
                'main_nco_frequency', obj.iioDev1, true);
            obj.MainNCOFrequenciesChipB = value;
        end
        % Check MainNCOFrequenciesChipC
        function set.MainNCOFrequenciesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipC',...
                'main_nco_frequency', obj.iioDev2, true);
            obj.MainNCOFrequenciesChipC = value;
        end
        % Check MainNCOFrequenciesChipD
        function set.MainNCOFrequenciesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipD',...
                'main_nco_frequency', obj.iioDev3, true);
            obj.MainNCOFrequenciesChipD = value;
        end
        %%
        % Check ChannelNCOPhasesChipA
        function set.ChannelNCOPhasesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipA',...
                'channel_nco_phase', obj.iioDev0, true);
            obj.ChannelNCOPhasesChipA = value;
        end
        % Check ChannelNCOPhasesChipB
        function set.ChannelNCOPhasesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipA',...
                'channel_nco_phase', obj.iioDev1, true);
            obj.ChannelNCOPhasesChipB = value;
        end
        % Check ChannelNCOPhasesChipC
        function set.ChannelNCOPhasesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipC',...
                'channel_nco_phase', obj.iioDev2, true);
            obj.ChannelNCOPhasesChipC = value;
        end
        % Check ChannelNCOPhasesChipD
        function set.ChannelNCOPhasesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipD',...
                'channel_nco_phase', obj.iioDev3, true);
            obj.ChannelNCOPhasesChipD = value;
        end
        %%
        % Check MainNCOPhasesChipA
        function set.MainNCOPhasesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipA',...
                'main_nco_phase', obj.iioDev0, true);
            obj.MainNCOPhasesChipA = value;
        end
        % Check MainNCOPhasesChipB
        function set.MainNCOPhasesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipA',...
                'main_nco_phase', obj.iioDev1, true);
            obj.MainNCOPhasesChipB = value;
        end
        % Check MainNCOPhasesChipC
        function set.MainNCOPhasesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipC',...
                'main_nco_phase', obj.iioDev2, true);
            obj.MainNCOPhasesChipC = value;
        end
        % Check MainNCOPhasesChipD
        function set.MainNCOPhasesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipD',...
                'main_nco_phase', obj.iioDev3, true);
            obj.MainNCOPhasesChipD = value;
        end
        %%
        % Check ChannelNCOGainScalesChipA
        function set.ChannelNCOGainScalesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOGainScalesChipA',...
                'channel_nco_gain_scale', obj.iioDev0, true);
            obj.ChannelNCOGainScalesChipA = value;
        end
        % Check ChannelNCOGainScalesChipB
        function set.ChannelNCOGainScalesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOGainScalesChipA',...
                'channel_nco_gain_scale', obj.iioDev1, true);
            obj.ChannelNCOGainScalesChipB = value;
        end
        % Check ChannelNCOGainScalesChipC
        function set.ChannelNCOGainScalesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOGainScalesChipC',...
                'channel_nco_gain_scale', obj.iioDev2, true);
            obj.ChannelNCOGainScalesChipC = value;
        end
        % Check ChannelNCOGainScalesChipD
        function set.ChannelNCOGainScalesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOGainScalesChipD',...
                'channel_nco_gain_scale', obj.iioDev3, true);
            obj.ChannelNCOGainScalesChipD = value;
        end
        %%
        % Check NCOEnablesChipA
        function set.NCOEnablesChipA(obj, value)
            obj.CheckAndUpdateHWBool(value,'NCOEnablesChipA',...
                'en', obj.iioDev0, true);
            obj.NCOEnablesChipA = value;
        end
        % Check NCOEnablesChipB
        function set.NCOEnablesChipB(obj, value)
            obj.CheckAndUpdateHWBool(value,'NCOEnablesChipB',...
                'en', obj.iioDev1, true);
            obj.NCOEnablesChipB = value;
        end
        % Check NCOEnablesChipC
        function set.NCOEnablesChipC(obj, value)
            obj.CheckAndUpdateHWBool(value,'NCOEnablesChipC',...
                'en', obj.iioDev2, true);
            obj.NCOEnablesChipC = value;
        end
        % Check NCOEnablesChipD
        function set.NCOEnablesChipD(obj, value)
            obj.CheckAndUpdateHWBool(value,'NCOEnablesChipD',...
                'en', obj.iioDev3, true);
            obj.NCOEnablesChipD = value;
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function setupImpl(obj,data)
            if strcmp(obj.DataSource,'DMA')
                obj.SamplesPerFrame = ...
                    (1+obj.EnableResampleFilters)*size(data,1);
            end
            % Call the superclass method
             setupImpl@adi.common.RxTx(obj);
        end
        
        function valid = stepImpl(obj,varargin)
            if strcmp(obj.DataSource,'DMA')
                if nargin < 2
                   error('In DMA mode, data must be passed to operator'); 
                end
                % Interpolate
                data = varargin{1};
                if obj.EnableResampleFilters
                    data = resample(data,2,1);
                end
                valid = stepImpl@adi.common.Tx(obj,data);
            else
                valid = stepImpl@adi.common.Tx(obj,varargin);
            end
        end
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl

            % Enable TX DMA offload
            obj.setDebugAttributeBool('pl_ddr_fifo_enable', 1, getDev(obj, obj.devName));

            % Get SPI connected dev
            obj.iioDev0 = getDev(obj, obj.devName0);
            obj.iioDev1 = getDev(obj, obj.devName1);
            obj.iioDev2 = getDev(obj, obj.devName2);
            obj.iioDev3 = getDev(obj, obj.devName3);
            obj.iioDevADF4371_0 = getDev(obj, 'adf4371-0');
            obj.iioDevADF4371_1 = getDev(obj, 'adf4371-1');
            obj.iioDevADF4371_2 = getDev(obj, 'adf4371-2');
            obj.iioDevADF4371_3 = getDev(obj, 'adf4371-3');

            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipA,...
                'ChannelNCOFrequenciesChipA','channel_nco_frequency', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipB,...
                'ChannelNCOFrequenciesChipB','channel_nco_frequency', ...
                obj.iioDev1, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipC,...
                'ChannelNCOFrequenciesChipC','channel_nco_frequency', ...
                obj.iioDev2, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipD,...
                'ChannelNCOFrequenciesChipD','channel_nco_frequency', ...
                obj.iioDev3, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipA,...
                'MainNCOFrequenciesChipA','main_nco_frequency', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipB,...
                'MainNCOFrequenciesChipB','main_nco_frequency', ...
                obj.iioDev1, true);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipC,...
                'MainNCOFrequenciesChipC','main_nco_frequency', ...
                obj.iioDev2, true);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipD,...
                'MainNCOFrequenciesChipD','main_nco_frequency', ...
                obj.iioDev3, true);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipA,...
                'ChannelNCOPhasesChipA','channel_nco_phase', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipB,...
                'ChannelNCOPhasesChipB','channel_nco_phase', ...
                obj.iioDev1, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipC,...
                'ChannelNCOPhasesChipC','channel_nco_phase', ...
                obj.iioDev2, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipD,...
                'ChannelNCOPhasesChipD','channel_nco_phase', ...
                obj.iioDev3, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipA,...
                'MainNCOPhasesChipA','main_nco_phase', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipB,...
                'MainNCOPhasesChipB','main_nco_phase', ...
                obj.iioDev1, true);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipC,...
                'MainNCOPhasesChipC','main_nco_phase', ...
                obj.iioDev2, true);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipD,...
                'MainNCOPhasesChipD','main_nco_phase', ...
                obj.iioDev3, true);
            %%
            obj.CheckAndUpdateHWFloat(obj.ChannelNCOGainScalesChipA,...
                'ChannelNCOGainScalesChipA','channel_nco_gain_scale', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHWFloat(obj.ChannelNCOGainScalesChipB,...
                'ChannelNCOGainScalesChipB','channel_nco_gain_scale', ...
                obj.iioDev1, true);
            obj.CheckAndUpdateHWFloat(obj.ChannelNCOGainScalesChipC,...
                'ChannelNCOGainScalesChipC','channel_nco_gain_scale', ...
                obj.iioDev2, true);
            obj.CheckAndUpdateHWFloat(obj.ChannelNCOGainScalesChipD,...
                'ChannelNCOGainScalesChipD','channel_nco_gain_scale', ...
                obj.iioDev3, true);
            %%
            obj.CheckAndUpdateHWBool(obj.NCOEnablesChipA,...
                'NCOEnablesChipA','en', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHWBool(obj.NCOEnablesChipB,...
                'NCOEnablesChipB','en', ...
                obj.iioDev1, true);
            obj.CheckAndUpdateHWBool(obj.NCOEnablesChipC,...
                'NCOEnablesChipC','en', ...
                obj.iioDev2, true);
            obj.CheckAndUpdateHWBool(obj.NCOEnablesChipD,...
                'NCOEnablesChipD','en', ...
                obj.iioDev3, true);
            %% DDS
            obj.ToggleDDS(strcmp(obj.DataSource,'DDS'));
            if strcmp(obj.DataSource,'DDS')
                obj.DDSUpdate();
            end
        end

    end

end
