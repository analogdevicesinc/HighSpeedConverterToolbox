classdef Rx < adi.QuadMxFE.Base & adi.common.Rx
    % adi.QuadMxFE.Rx Receive data from the QuadMxFE development board
    %   The adi.QuadMxFE.Rx System object is a signal source that can receive
    %   complex data from the QuadMxFE.
    %
    %   rx = adi.QuadMxFE.Rx;
    %   rx = adi.QuadMxFE.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9081.pdf">AD9081 Datasheet</a>       
    properties
        %ChannelNCOFrequenciesChipA Channel NCO Frequencies Chip A
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOFrequenciesChipA = [0,0,0,0];
        %ChannelNCOFrequenciesChipB Channel NCO Frequencies Chip B
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOFrequenciesChipB = [0,0,0,0];
        %ChannelNCOFrequenciesChipC Channel NCO Frequencies Chip C
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOFrequenciesChipC = [0,0,0,0];
        %ChannelNCOFrequenciesChipD Channel NCO Frequencies Chip D
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOFrequenciesChipD = [0,0,0,0];
    end
    
    properties
        %MainNCOFrequenciesChipA Main NCO Frequencies Chip A
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOFrequenciesChipA = [0,0,0,0];
        %MainNCOFrequenciesChipB Main NCO Frequencies Chip B
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOFrequenciesChipB = [0,0,0,0];
        %MainNCOFrequenciesChipC Main NCO Frequencies Chip C
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOFrequenciesChipC = [0,0,0,0];
        %MainNCOFrequenciesChipD Main NCO Frequencies Chip D
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOFrequenciesChipD = [0,0,0,0];
    end
    
    properties
        %ChannelNCOPhasesChipA Channel NCO Phases Chip A
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOPhasesChipA = [0,0,0,0];
        %ChannelNCOPhasesChipB Channel NCO Phases Chip B
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOPhasesChipB = [0,0,0,0];
        %ChannelNCOPhasesChipC Channel NCO Phases Chip C
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOPhasesChipC = [0,0,0,0];
        %ChannelNCOPhasesChipD Channel NCO Phases Chip D
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOPhasesChipD = [0,0,0,0];
    end
    
    properties
        %MainNCOPhasesChipA Main NCO Phases Chip A
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOPhasesChipA = [0,0,0,0];
        %MainNCOPhasesChipB Main NCO Phases Chip B
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOPhasesChipB = [0,0,0,0];
        %MainNCOPhasesChipC Main NCO Phases Chip C
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOPhasesChipC = [0,0,0,0];
        %MainNCOPhasesChipD Main NCO Phases Chip D
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOPhasesChipD = [0,0,0,0];
    end
    
    properties
        %TestModeChipA Test Mode Chip A
        %   Test mode of receive path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        TestModeChipA = 'off';
        %TestModeChipB Test Mode Chip B
        %   Test mode of receive path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        TestModeChipB = 'off';
        %TestModeChipC Test Mode Chip C
        %   Test mode of receive path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        TestModeChipC = 'off';
        %TestModeChipD Test Mode Chip D
        %   Test mode of receive path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        TestModeChipD = 'off';
    end

    properties
        %ExternalAttenuation External Attenuation
        %   Attenuation value of external HMC425a
       ExternalAttenuation = 0; 
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Constant, Hidden)
        TestModeChipASet = matlab.system.StringSet({ ...
            'off','midscale_short','pos_fullscale','neg_fullscale'...
            'checkerboard','pn9','pn32','one_zero_toggle','user','pn7'...
            'pn15','pn31','ramp'});
        TestModeChipBSet = matlab.system.StringSet({ ...
            'off','midscale_short','pos_fullscale','neg_fullscale'...
            'checkerboard','pn9','pn32','one_zero_toggle','user','pn7'...
            'pn15','pn31','ramp'});
        TestModeChipCSet = matlab.system.StringSet({ ...
            'off','midscale_short','pos_fullscale','neg_fullscale'...
            'checkerboard','pn9','pn32','one_zero_toggle','user','pn7'...
            'pn15','pn31','ramp'});
        TestModeChipDSet = matlab.system.StringSet({ ...
            'off','midscale_short','pos_fullscale','neg_fullscale'...
            'checkerboard','pn9','pn32','one_zero_toggle','user','pn7'...
            'pn15','pn31','ramp'});
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
    end
    properties(Nontunable, Hidden)
        channel_names = {...
            'voltage0_i','voltage0_q',...
            'voltage1_i','voltage1_q',...
            'voltage2_i','voltage2_q',...
            'voltage3_i','voltage3_q',...
            'voltage4_i','voltage4_q',...
            'voltage5_i','voltage5_q',...
            'voltage6_i','voltage6_q',...
            'voltage7_i','voltage7_q',...
            'voltage8_i','voltage8_q',...
            'voltage9_i','voltage9_q',...
            'voltage10_i','voltage10_q',...
            'voltage11_i','voltage11_q',...
            'voltage12_i','voltage12_q',...
            'voltage13_i','voltage13_q',...
            'voltage14_i','voltage14_q',...
            'voltage15_i','voltage15_q'};
        num_data_channels = 16;
        num_attr_channels = 4;
        devName = 'axi-ad9081-rx-3';
        devName0 = 'axi-ad9081-rx-0';
        devName1 = 'axi-ad9081-rx-1';
        devName2 = 'axi-ad9081-rx-2';
    end
    
    properties (Hidden)
       iioDev0;
       iioDev1;
       iioDev2;
       iioHMC425a;
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.QuadMxFE.Base(varargin{:});
            obj.ChannelNCOFrequenciesChipA = zeros(1,obj.num_attr_channels);
            obj.ChannelNCOFrequenciesChipB = zeros(1,obj.num_attr_channels);
            obj.ChannelNCOFrequenciesChipC = zeros(1,obj.num_attr_channels);
            obj.ChannelNCOFrequenciesChipD = zeros(1,obj.num_attr_channels);
            obj.MainNCOFrequenciesChipA = zeros(1,obj.num_attr_channels);
            obj.MainNCOFrequenciesChipB = zeros(1,obj.num_attr_channels);
            obj.MainNCOFrequenciesChipC = zeros(1,obj.num_attr_channels);
            obj.MainNCOFrequenciesChipD = zeros(1,obj.num_attr_channels);
            obj.ChannelNCOPhasesChipA = zeros(1,obj.num_attr_channels);
            obj.ChannelNCOPhasesChipB = zeros(1,obj.num_attr_channels);
            obj.ChannelNCOPhasesChipC = zeros(1,obj.num_attr_channels);
            obj.ChannelNCOPhasesChipD = zeros(1,obj.num_attr_channels);
            obj.MainNCOPhasesChipA = zeros(1,obj.num_attr_channels);
            obj.MainNCOPhasesChipB = zeros(1,obj.num_attr_channels);
            obj.MainNCOPhasesChipC = zeros(1,obj.num_attr_channels);
            obj.MainNCOPhasesChipD = zeros(1,obj.num_attr_channels);
        end
        % Check ChannelNCOFrequenciesChipA
        function set.ChannelNCOFrequenciesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipA',...
                'channel_nco_frequency', obj.iioDev0); %#ok<*MCSUP>
            obj.ChannelNCOFrequenciesChipA = value;
        end
        % Check ChannelNCOFrequenciesChipB
        function set.ChannelNCOFrequenciesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipA',...
                'channel_nco_frequency', obj.iioDev1);
            obj.ChannelNCOFrequenciesChipB = value;
        end
        % Check ChannelNCOFrequenciesChipC
        function set.ChannelNCOFrequenciesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipC',...
                'channel_nco_frequency', obj.iioDev2);
            obj.ChannelNCOFrequenciesChipC = value;
        end
        % Check ChannelNCOFrequenciesChipD
        function set.ChannelNCOFrequenciesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipD',...
                'channel_nco_frequency', obj.iioDev);
            obj.ChannelNCOFrequenciesChipD = value;
        end
        %%
        % Check MainNCOFrequenciesChipA
        function set.MainNCOFrequenciesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipA',...
                'main_nco_frequency', obj.iioDev0);
            obj.MainNCOFrequenciesChipA = value;
        end
        % Check MainNCOFrequenciesChipB
        function set.MainNCOFrequenciesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipA',...
                'main_nco_frequency', obj.iioDev1);
            obj.MainNCOFrequenciesChipB = value;
        end
        % Check MainNCOFrequenciesChipC
        function set.MainNCOFrequenciesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipC',...
                'main_nco_frequency', obj.iioDev2);
            obj.MainNCOFrequenciesChipC = value;
        end
        % Check MainNCOFrequenciesChipD
        function set.MainNCOFrequenciesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipD',...
                'main_nco_frequency', obj.iioDev);
            obj.MainNCOFrequenciesChipD = value;
        end
        %%
        % Check ChannelNCOPhasesChipA
        function set.ChannelNCOPhasesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipA',...
                'channel_nco_phase', obj.iioDev0);
            obj.ChannelNCOPhasesChipA = value;
        end
        % Check ChannelNCOPhasesChipB
        function set.ChannelNCOPhasesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipA',...
                'channel_nco_phase', obj.iioDev1);
            obj.ChannelNCOPhasesChipB = value;
        end
        % Check ChannelNCOPhasesChipC
        function set.ChannelNCOPhasesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipC',...
                'channel_nco_phase', obj.iioDev2);
            obj.ChannelNCOPhasesChipC = value;
        end
        % Check ChannelNCOPhasesChipD
        function set.ChannelNCOPhasesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipD',...
                'channel_nco_phase', obj.iioDev);
            obj.ChannelNCOPhasesChipD = value;
        end
        %%
        % Check MainNCOPhasesChipA
        function set.MainNCOPhasesChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipA',...
                'main_nco_phase', obj.iioDev0);
            obj.MainNCOPhasesChipA = value;
        end
        % Check MainNCOPhasesChipB
        function set.MainNCOPhasesChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipA',...
                'main_nco_phase', obj.iioDev1);
            obj.MainNCOPhasesChipB = value;
        end
        % Check MainNCOPhasesChipC
        function set.MainNCOPhasesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipC',...
                'main_nco_phase', obj.iioDev2);
            obj.MainNCOPhasesChipC = value;
        end
        % Check MainNCOPhasesChipD
        function set.MainNCOPhasesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipD',...
                'main_nco_phase', obj.iioDev);
            obj.MainNCOPhasesChipD = value;
        end
        %%
        % Check TestModeChipA
        function set.TestModeChipA(obj, value)
            obj.setAttributeRAW('voltage0_i','test_mode',value,false,...
                obj.iioDev0);
            obj.TestModeChipA = value;
        end
        % Check TestModeChipB
        function set.TestModeChipB(obj, value)
            obj.setAttributeRAW('voltage0_i','test_mode',value,false,...
                obj.iioDev1);
            obj.TestModeChipB = value;
        end
        % Check TestModeChipC
        function set.TestModeChipC(obj, value)
            obj.setAttributeRAW('voltage0_i','test_mode',value,false,...
                obj.iioDev2);
            obj.TestModeChipC = value;
        end
        % Check TestModeChipD
        function set.TestModeChipD(obj, value)
            obj.setAttributeRAW('voltage0_i','test_mode',value,false,...
                obj.iioDev);
            obj.TestModeChipD = value;
        end
        %%
        % Check ExternalAttenuation
        function set.ExternalAttenuation(obj, value)
%             validateattributes( value, { 'double','single' }, ...
%                 { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
%                 '', 'Gain');
%             assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.ExternalAttenuation = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'hardwaregain',value,true,obj.iioHMC425a);
            end
        end
    end
       
    %% API Functions
    methods (Hidden, Access = protected)
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            
            obj.channel_names = {};
            for k = 0:(obj.num_data_channels-1)
                obj.channel_names = [obj.channel_names(:)', ...
                    {sprintf('voltage%d_i',k)},{sprintf('voltage%d_q',k)}];
            end
            
            % Get additional devices
            obj.iioDev0 = getDev(obj, obj.devName0);
            obj.iioDev1 = getDev(obj, obj.devName1);
            obj.iioDev2 = getDev(obj, obj.devName2);
            obj.iioHMC425a = getDev(obj, 'hmc425a');
            
            % Update attributes
            obj.setAttributeRAW('voltage0_i','test_mode',...
                obj.TestModeChipA,false,obj.iioDev0);
            obj.setAttributeRAW('voltage0_i','test_mode',...
                obj.TestModeChipB,false,obj.iioDev1);
            obj.setAttributeRAW('voltage0_i','test_mode',...
                obj.TestModeChipC,false,obj.iioDev2);
            obj.setAttributeRAW('voltage0_i','test_mode',...
                obj.TestModeChipD,false,obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipA,...
                'ChannelNCOFrequenciesChipA','channel_nco_frequency', ...
                obj.iioDev0);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipB,...
                'ChannelNCOFrequenciesChipB','channel_nco_frequency', ...
                obj.iioDev1);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipC,...
                'ChannelNCOFrequenciesChipC','channel_nco_frequency', ...
                obj.iioDev2);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipD,...
                'ChannelNCOFrequenciesChipD','channel_nco_frequency', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipA,...
                'MainNCOFrequenciesChipA','main_nco_frequency', ...
                obj.iioDev0);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipB,...
                'MainNCOFrequenciesChipB','main_nco_frequency', ...
                obj.iioDev1);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipC,...
                'MainNCOFrequenciesChipC','main_nco_frequency', ...
                obj.iioDev2);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipD,...
                'MainNCOFrequenciesChipD','main_nco_frequency', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipA,...
                'ChannelNCOPhasesChipA','channel_nco_phase', ...
                obj.iioDev0);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipB,...
                'ChannelNCOPhasesChipB','channel_nco_phase', ...
                obj.iioDev1);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipC,...
                'ChannelNCOPhasesChipC','channel_nco_phase', ...
                obj.iioDev2);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipD,...
                'ChannelNCOPhasesChipD','channel_nco_phase', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipA,...
                'MainNCOPhasesChipA','main_nco_phase', ...
                obj.iioDev0);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipB,...
                'MainNCOPhasesChipB','main_nco_phase', ...
                obj.iioDev1);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipC,...
                'MainNCOPhasesChipC','main_nco_phase', ...
                obj.iioDev2);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipD,...
                'MainNCOPhasesChipD','main_nco_phase', ...
                obj.iioDev);
            %%
            obj.setAttributeLongLong('voltage0','hardwaregain',...
                obj.ExternalAttenuation,true,0,obj.iioHMC425a);

        end

    end

end
