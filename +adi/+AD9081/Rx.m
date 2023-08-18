classdef Rx < adi.AD9081.Base & adi.common.Rx & adi.common.Attribute
    % adi.AD9081.Rx Receive data from the AD9081 high speed ADC
    %   The adi.AD9081.Rx System object is a signal source that can receive
    %   complex data from the AD9081.
    %
    %   rx = adi.AD9081.Rx;
    %   rx = adi.AD9081.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9081.pdf">AD9081 Datasheet</a>
    %
    %   See also adi.DAQ2.Rx
        
    properties
        %ChannelNCOFrequencies Channel NCO Frequencies 
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOFrequencies = [0,0,0,0];
        %MainNCOFrequencies Main NCO Frequencies 
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOFrequencies = [0,0,0,0];
        %ChannelNCOPhases Channel NCO Phases 
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOPhases = [0,0,0,0];
        %MainNCOPhases Main NCO Phases 
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOPhases = [0,0,0,0];
        %TestMode Test Mode 
        %   Test mode of receive path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale' 
        %   'checkerboard' 'pn9' 'pn32' 'one_zero_toggle' 'user' 'pn7'
        %   'pn15' 'pn31' 'ramp'
        TestMode = 'off';
        %JESD204FSMControl JESD204 FSM Control
        %   JESD204 FSM CTRL. Options are:
        %   '0' '1'
        %   When set to '0' the JESD links will be disabled. This property
        %   should be toggled to reset the JESD204 links
        JESD204FSMControl = '1';
    end
    
    properties (Nontunable, Logical)
        %EnablePFIRs Enable PFIRs
        %   Enable use of PFIR/PFILT filters
        EnablePFIRs = false;
    end
    
    properties (Nontunable)
        %PFIRFilenames PFIR File names
        %   Path(s) to FPIR/PFILT filter file(s). Input can be a string or
        %   cell array of strings. Files are loading in order
        PFIRFilenames = '';
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
    end
    
    properties (Hidden, Constant)
        ComplexData = true;
    end
    
    properties(Nontunable, Hidden)
        channel_names = {};
        num_data_channels = 4;
        num_coarse_attr_channels = 4;
        num_fine_attr_channels = 4;
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9081-rx-hpc';
    end
    
    properties(Constant, Hidden)
        TestModeSet = matlab.system.StringSet({ ...
            'off','midscale_short','pos_fullscale','neg_fullscale'...
            'checkerboard','pn9','pn32','one_zero_toggle','user','pn7'...
            'pn15','pn31','ramp'});
        JESD204FSMControlSet = matlab.system.StringSet({'0','1'});
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9081.Base(varargin{:});
            obj.channel_names = {};
            for k = 0:(obj.num_data_channels-1)
                obj.channel_names = [obj.channel_names(:)', ...
                    {sprintf('voltage%d_i',k)},{sprintf('voltage%d_q',k)}];
            end
            
            % Fill in place holders
            obj.ChannelNCOFrequencies = zeros(1,obj.num_fine_attr_channels);
            obj.MainNCOFrequencies = zeros(1,obj.num_coarse_attr_channels);
            obj.ChannelNCOPhases = zeros(1,obj.num_fine_attr_channels);
            obj.MainNCOPhases = zeros(1,obj.num_coarse_attr_channels);
        end
        
        % Check ChannelNCOFrequencies
        function set.ChannelNCOFrequencies(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequencies',...
                'channel_nco_frequency', obj.iioDev); %#ok<*MCSUP>
            obj.ChannelNCOFrequencies = value;
        end
        %%
        % Check MainNCOFrequencies
        function set.MainNCOFrequencies(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequencies',...
                'main_nco_frequency', obj.iioDev);
            obj.MainNCOFrequencies = value;
        end
        %%
        % Check ChannelNCOPhases
        function set.ChannelNCOPhases(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhases',...
                'channel_nco_phase', obj.iioDev);
            obj.ChannelNCOPhases = value;
        end
        %%
        % Check MainNCOPhases
        function set.MainNCOPhases(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhases',...
                'main_nco_phase', obj.iioDev);
            obj.MainNCOPhases = value;
        end
        %%
        % Check TestMode
        function set.TestMode(obj, value)
            if obj.ConnectedToDevice
                obj.setAttributeRAW('voltage0_i','test_mode',value,false,...
                    obj.iioDev);
            end
            obj.TestMode = value;
        end
        %% Check JESD204FSMControl
        function set.JESD204FSMControl(obj, value)
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('jesd204_fsm_ctrl',value);
            else
                if isequal(value,'0')
                    error(['JESD204FSMControl cannot be set to 0 before initialization, ',...
                        'This will disable the JESD links and prevent access to data']);
                end
            end
            obj.JESD204FSMControl = value;
        end
        %%
        % Check EnablePFIRs
        function set.EnablePFIRs(obj, value)
            validateattributes( value, { 'logical' }, ...
                { }, ...
                '', 'EnablePFIRs');
            obj.EnablePFIRs = value;
        end
        % Check PFIRFilenames
        function set.PFIRFilenames(obj, value)
            obj.PFIRFilenames = value;
            if obj.EnablePFIRs && obj.ConnectedToDevice
                writeFilterFile(obj);
            end
        end
    end 
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function writeFilterFile(obj)
            % Read in filter files and write them sequentially into the
            % attribute
            fir_data_files = obj.PFIRFilenames;
            if ~iscell(fir_data_files)
                fir_data_files = {fir_data_files};
            end
            
            for fir_data_file = fir_data_files
                filename = fir_data_file{:};
                if ~exist(filename,'file')
                    error('Filter file %s does not exist',filename);
                end
                fir_data_str = fileread(filename);
                obj.setDeviceAttributeRAW('filter_fir_config',fir_data_str);
            end
        end
                
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required since Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
                                    
            % Update attributes
            obj.setAttributeRAW('voltage0_i','test_mode',...
                obj.TestMode,false,obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequencies,...
                'ChannelNCOFrequencies','channel_nco_frequency', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFrequencies,...
                'MainNCOFrequencies','main_nco_frequency', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOPhases,...
                'ChannelNCOPhases','channel_nco_phase', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOPhases,...
                'MainNCOPhases','main_nco_phase', ...
                obj.iioDev);
            %%
            if obj.EnablePFIRs
                obj.writeFilterFile();
            end
            %%
            obj.setDeviceAttributeRAW('jesd204_fsm_ctrl',obj.JESD204FSMControl);
            %%
            obj.setAttributeRAW('voltage0_i','test_mode',obj.TestMode,...
                false,obj.iioDev);

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
            bName = 'AD9081';
        end
        
    end
end

