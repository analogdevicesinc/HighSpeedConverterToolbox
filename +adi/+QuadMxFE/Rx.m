classdef Rx < adi.QuadMxFE.Base & adi.common.Rx
    % adi.QuadMxFE.Rx Receive data from the QuadMxFE development board
    %   The adi.QuadMxFE.Rx System object is a signal source that can receive
    %   complex data from the QuadMxFE.
    %
    %   rx = adi.QuadMxFE.Rx;
    %   rx = adi.QuadMxFE.Rx('uri','ip:192.168.2.1');
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

    properties (Logical)
        %EnablePFIRsChipA Enable PFIRs Chip A
        %   Enable use of PFIR/PFILT filters for Chip A
        EnablePFIRsChipA = false;
        %EnablePFIRsChipB Enable PFIRs Chip B
        %   Enable use of PFIR/PFILT filters for Chip B
        EnablePFIRsChipB = false;
        %EnablePFIRsChipC Enable PFIRs Chip C
        %   Enable use of PFIR/PFILT filters for Chip C
        EnablePFIRsChipC = false;
        %EnablePFIRsChipD Enable PFIRs Chip D
        %   Enable use of PFIR/PFILT filters for Chip D
        EnablePFIRsChipD = false;
    end
    
    properties
        %PFIRFilenamesChipA PFIR File names Chip A
        %   Path(s) to FPIR/PFILT filter file(s). Input can be a string or
        %   cell array of strings. Files are loading in order for Chip A
        PFIRFilenamesChipA = '';
        %PFIRFilenamesChipB PFIR File names Chip B
        %   Path(s) to FPIR/PFILT filter file(s). Input can be a string or
        %   cell array of strings. Files are loading in order for Chip B
        PFIRFilenamesChipB = '';
        %PFIRFilenamesChipC PFIR File names Chip C
        %   Path(s) to FPIR/PFILT filter file(s). Input can be a string or
        %   cell array of strings. Files are loading in order for Chip C
        PFIRFilenamesChipC = '';
        %PFIRFilenamesChipD PFIR File names Chip D
        %   Path(s) to FPIR/PFILT filter file(s). Input can be a string or
        %   cell array of strings. Files are loading in order for Chip D
        PFIRFilenamesChipD = '';
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
        channel_names = {};
        num_data_channels = 16;
        num_coarse_attr_channels = 4;
        num_fine_attr_channels = 4;
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
            obj.uri = 'ip:analog';
            obj.channel_names = {};
            for k = 0:(obj.num_data_channels-1)
                obj.channel_names = [obj.channel_names(:)', ...
                    {sprintf('voltage%d_i',k)},{sprintf('voltage%d_q',k)}];
            end
            
            % Fill in place holders
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
        % Check EnablePFIRsChipA
        function set.EnablePFIRsChipA(obj, value)
            validateattributes( value, { 'logical' }, ...
                { }, ...
                '', 'EnablePFIRsChipA');
            obj.EnablePFIRsChipA = value;
        end
        % Check EnablePFIRsChipB
        function set.EnablePFIRsChipB(obj, value)
            validateattributes( value, { 'logical' }, ...
                { }, ...
                '', 'EnablePFIRsChipB');
            obj.EnablePFIRsChipB = value;
        end
        % Check EnablePFIRsChipC
        function set.EnablePFIRsChipC(obj, value)
            validateattributes( value, { 'logical' }, ...
                { }, ...
                '', 'EnablePFIRsChipC');
            obj.EnablePFIRsChipC = value;
        end
        % Check EnablePFIRsChipD
        function set.EnablePFIRsChipD(obj, value)
            validateattributes( value, { 'logical' }, ...
                { }, ...
                '', 'EnablePFIRsChipD');
            obj.EnablePFIRsChipD = value;
        end
        
        % Check PFIRFilenamesChipA
        function set.PFIRFilenamesChipA(obj, value)
            obj.PFIRFilenamesChipA = value;
            if obj.EnablePFIRsChipA && obj.ConnectedToDevice
                writeFilterFile(obj,obj.iioDev0,value);
            end
        end
        % Check PFIRFilenamesChipB
        function set.PFIRFilenamesChipB(obj, value)
            obj.PFIRFilenamesChipB = value;
            if obj.EnablePFIRsChipB && obj.ConnectedToDevice
                writeFilterFile(obj,obj.iioDev1,value);
            end
        end
        % Check PFIRFilenamesChipC
        function set.PFIRFilenamesChipC(obj, value)
            obj.PFIRFilenamesChipC = value;
            if obj.EnablePFIRsChipC && obj.ConnectedToDevice
                writeFilterFile(obj,obj.iioDev2,value);
            end
        end
        % Check PFIRFilenamesChipD
        function set.PFIRFilenamesChipD(obj, value)
            obj.PFIRFilenamesChipD = value;
            if obj.EnablePFIRsChipD && obj.ConnectedToDevice
                writeFilterFile(obj,obj.iioDev,value);
            end
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
                obj.setAttributeLongLong(id,'hardwaregain',value,true,0,obj.iioHMC425a);
            end
        end
    end
       
    %% API Functions
    methods (Hidden, Access = protected)
        
        function [data,valid] = stepImpl(obj)
            [data,valid] = stepImpl@adi.common.Rx(obj);
            if obj.EnableResampleFilters
                % Decimate
                data = resample(data,1,2);
            end
        end
        
        function writeFilterFile(obj, phy, fir_data_files)
            % Read in filter files and write them sequentially into the
            % attribute
            if ~iscell(fir_data_files)
                fir_data_files = {fir_data_files};
            end
            
            for fir_data_file = fir_data_files
                filename = fir_data_file{:};
                if ~exist(filename,'file')
                    error('Filter file %s does not exist',filename);
                end
                fir_data_str = fileread(filename);
                obj.setDeviceAttributeRAW('filter_fir_config',fir_data_str, phy);
            end
        end
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
                        
            % Get additional devices
            obj.iioDev0 = getDev(obj, obj.devName0);
            obj.iioDev1 = getDev(obj, obj.devName1);
            obj.iioDev2 = getDev(obj, obj.devName2);
            obj.iioHMC425a = getDev(obj, 'hmc425a');
            if obj.CalibrationBoardAttached
                obj.iioAD5592r = getDev(obj, 'ad5592r');
                obj.iioOneBitADCDAC = getDev(obj, 'one-bit-adc-dac');
            end
            
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
            if obj.EnablePFIRsChipA
                obj.writeFilterFile(obj.iioDev0,obj.PFIRFilenamesChipA);
            end
            if obj.EnablePFIRsChipB
                obj.writeFilterFile(obj.iioDev1,obj.PFIRFilenamesChipB);
            end
            if obj.EnablePFIRsChipC
                obj.writeFilterFile(obj.iioDev2,obj.PFIRFilenamesChipC);
            end
            if obj.EnablePFIRsChipD
                obj.writeFilterFile(obj.iioDev,obj.PFIRFilenamesChipD);
            end
            %%
            obj.setAttributeLongLong('voltage0','hardwaregain',...
                obj.ExternalAttenuation,true,0,obj.iioHMC425a);

        end

    end

end
