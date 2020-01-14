classdef Tx < adi.QuadMxFE.Base & adi.common.Tx
    % adi.QuadMxFE.Tx Transmit data from the QuadMxFE development board
    %   The adi.QuadMxFE.Tx System object is a signal sink that can tranmsit
    %   complex data from the QuadMxFE.
    %
    %   tx = adi.QuadMxFE.Tx;
    %   tx = adi.QuadMxFE.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9081.pdf">AD9081 Datasheet</a>

    properties
        %ChannelNCOFrequenciesChipA Channel NCO Frequencies Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequenciesChipA = [0,0,0,0];
        %ChannelNCOFrequenciesChipB Channel NCO Frequencies Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequenciesChipB = [0,0,0,0];
        %ChannelNCOFrequenciesChipC Channel NCO Frequencies Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequenciesChipC = [0,0,0,0];
        %ChannelNCOFrequenciesChipD Channel NCO Frequencies Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequenciesChipD = [0,0,0,0];
    end
    
    properties
        %MainNCOFrequenciesChipA Main NCO Frequencies Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequenciesChipA = [0,0,0,0];
        %MainNCOFrequenciesChipB Main NCO Frequencies Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequenciesChipB = [0,0,0,0];
        %MainNCOFrequenciesChipC Main NCO Frequencies Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequenciesChipC = [0,0,0,0];
        %MainNCOFrequenciesChipD Main NCO Frequencies Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequenciesChipD = [0,0,0,0];
    end
    
    properties
        %ChannelNCOPhasesChipA Channel NCO Phases Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhasesChipA = [0,0,0,0];
        %ChannelNCOPhasesChipB Channel NCO Phases Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhasesChipB = [0,0,0,0];
        %ChannelNCOPhasesChipC Channel NCO Phases Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhasesChipC = [0,0,0,0];
        %ChannelNCOPhasesChipD Channel NCO Phases Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhasesChipD = [0,0,0,0];
    end
    
    properties
        %MainNCOPhasesChipA Main NCO Phases Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhasesChipA = [0,0,0,0];
        %MainNCOPhasesChipB Main NCO Phases Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhasesChipB = [0,0,0,0];
        %MainNCOPhasesChipC Main NCO Phases Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhasesChipC = [0,0,0,0];
        %MainNCOPhasesChipD Main NCO Phases Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhasesChipD = [0,0,0,0];
    end
    
    properties
        %ChannelNCOGainScalesChipA Channel NCO Gain Scales Chip A
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOGainScalesChipA = [0,0,0,0];
        %ChannelNCOGainScalesChipB Channel NCO Gain Scales Chip B
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOGainScalesChipB = [0,0,0,0];
        %ChannelNCOGainScalesChipC Channel NCO Gain Scales Chip C
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOGainScalesChipC = [0,0,0,0];
        %ChannelNCOGainScalesChipD Channel NCO Gain Scales Chip D
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,4] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOGainScalesChipD = [0,0,0,0];
    end
    
    properties
        %NCOEnablesChipA Test Mode Chip A
        %   Test mode of transmit path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        NCOEnablesChipA = [false,false,false,false];
        %NCOEnablesChipB Test Mode Chip B
        %   Test mode of transmit path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        NCOEnablesChipB = [false,false,false,false];
        %NCOEnablesChipC Test Mode Chip C
        %   Test mode of transmit path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        NCOEnablesChipC = [false,false,false,false];
        %NCOEnablesChipD Test Mode Chip D
        %   Test mode of transmit path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        NCOEnablesChipD = [false,false,false,false];
    end
    
    properties
       ExternalAttenuation = 0; 
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
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
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9081-tx-3';
    end
    
    properties (Hidden)
       iioDev0;
       iioHMC425a;
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.QuadMxFE.Base(varargin{:});
            obj.dds_channel_names = {};
            for k=0:63
                obj.dds_channel_names = [...
                    obj.dds_channel_names(:)',...
                    {sprintf('altvoltage%d',k)}];
            end
            l = length(obj.dds_channel_names)/2;
            obj.DDSFrequencies = zeros(2,l);
            obj.DDSPhases = zeros(2,l);
            obj.DDSScales = zeros(2,l);
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
                'channel_nco_frequency', obj.iioDev0, true);
            obj.ChannelNCOFrequenciesChipB = value;
        end
        % Check ChannelNCOFrequenciesChipC
        function set.ChannelNCOFrequenciesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipC',...
                'channel_nco_frequency', obj.iioDev0, true);
            obj.ChannelNCOFrequenciesChipC = value;
        end
        % Check ChannelNCOFrequenciesChipD
        function set.ChannelNCOFrequenciesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequenciesChipD',...
                'channel_nco_frequency', obj.iioDev0, true);
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
                'main_nco_frequency', obj.iioDev0, true);
            obj.MainNCOFrequenciesChipB = value;
        end
        % Check MainNCOFrequenciesChipC
        function set.MainNCOFrequenciesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipC',...
                'main_nco_frequency', obj.iioDev0, true);
            obj.MainNCOFrequenciesChipC = value;
        end
        % Check MainNCOFrequenciesChipD
        function set.MainNCOFrequenciesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequenciesChipD',...
                'main_nco_frequency', obj.iioDev0, true);
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
                'channel_nco_phase', obj.iioDev0, true);
            obj.ChannelNCOPhasesChipB = value;
        end
        % Check ChannelNCOPhasesChipC
        function set.ChannelNCOPhasesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipC',...
                'channel_nco_phase', obj.iioDev0, true);
            obj.ChannelNCOPhasesChipC = value;
        end
        % Check ChannelNCOPhasesChipD
        function set.ChannelNCOPhasesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhasesChipD',...
                'channel_nco_phase', obj.iioDev0, true);
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
                'main_nco_phase', obj.iioDev0, true);
            obj.MainNCOPhasesChipB = value;
        end
        % Check MainNCOPhasesChipC
        function set.MainNCOPhasesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipC',...
                'main_nco_phase', obj.iioDev0, true);
            obj.MainNCOPhasesChipC = value;
        end
        % Check MainNCOPhasesChipD
        function set.MainNCOPhasesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhasesChipD',...
                'main_nco_phase', obj.iioDev0, true);
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
                'channel_nco_gain_scale', obj.iioDev0, true);
            obj.ChannelNCOGainScalesChipB = value;
        end
        % Check ChannelNCOGainScalesChipC
        function set.ChannelNCOGainScalesChipC(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOGainScalesChipC',...
                'channel_nco_gain_scale', obj.iioDev0, true);
            obj.ChannelNCOGainScalesChipC = value;
        end
        % Check ChannelNCOGainScalesChipD
        function set.ChannelNCOGainScalesChipD(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOGainScalesChipD',...
                'channel_nco_gain_scale', obj.iioDev0, true);
            obj.ChannelNCOGainScalesChipD = value;
        end
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
                'en', obj.iioDev, true);
            obj.NCOEnablesChipD = value;
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
            
            % Get SPI connected dev
            obj.iioDev0 = getDev(obj, obj.phyDevName);
            obj.iioHMC425a = getDev(obj, 'hmc425a');
            
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipA,...
                'ChannelNCOFrequenciesChipA','channel_nco_frequency', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipB,...
                'ChannelNCOFrequenciesChipB','channel_nco_frequency', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipC,...
                'ChannelNCOFrequenciesChipC','channel_nco_frequency', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequenciesChipD,...
                'ChannelNCOFrequenciesChipD','channel_nco_frequency', ...
                obj.iioDev0, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipA,...
                'MainNCOFrequenciesChipA','main_nco_frequency', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipB,...
                'MainNCOFrequenciesChipB','main_nco_frequency', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipC,...
                'MainNCOFrequenciesChipC','main_nco_frequency', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOFrequenciesChipD,...
                'MainNCOFrequenciesChipD','main_nco_frequency', ...
                obj.iioDev0, true);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipA,...
                'ChannelNCOPhasesChipA','channel_nco_phase', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipB,...
                'ChannelNCOPhasesChipB','channel_nco_phase', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipC,...
                'ChannelNCOPhasesChipC','channel_nco_phase', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOPhasesChipD,...
                'ChannelNCOPhasesChipD','channel_nco_phase', ...
                obj.iioDev0, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipA,...
                'MainNCOPhasesChipA','main_nco_phase', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipB,...
                'MainNCOPhasesChipB','main_nco_phase', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipC,...
                'MainNCOPhasesChipC','main_nco_phase', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOPhasesChipD,...
                'MainNCOPhasesChipD','main_nco_phase', ...
                obj.iioDev0, true);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOGainScalesChipA,...
                'ChannelNCOGainScalesChipA','channel_nco_gain_scale', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOGainScalesChipB,...
                'ChannelNCOGainScalesChipB','channel_nco_gain_scale', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOGainScalesChipC,...
                'ChannelNCOGainScalesChipC','channel_nco_gain_scale', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.ChannelNCOGainScalesChipD,...
                'ChannelNCOGainScalesChipD','channel_nco_gain_scale', ...
                obj.iioDev0, true);
            %%
            obj.CheckAndUpdateHWBool(obj.NCOEnablesChipA,...
                'NCOEnablesChipA','en', ...
                obj.iioDev0);
            obj.CheckAndUpdateHWBool(obj.NCOEnablesChipB,...
                'NCOEnablesChipB','en', ...
                obj.iioDev1);
            obj.CheckAndUpdateHWBool(obj.NCOEnablesChipC,...
                'NCOEnablesChipC','en', ...
                obj.iioDev2);
            obj.CheckAndUpdateHWBool(obj.NCOEnablesChipD,...
                'NCOEnablesChipD','en', ...
                obj.iioDev);
            %%
            obj.setAttributeLongLong('voltage0','hardwaregain',...
                obj.ExternalAttenuation,true,obj.iioHMC425a);
            
            %% DDS
            
            obj.ToggleDDS(strcmp(obj.DataSource,'DDS'));
            if strcmp(obj.DataSource,'DDS')
                obj.DDSUpdate();
            end
        end
        
    end
    
end

