classdef Rx < adi.AD9088.Base & adi.common.Rx
    % adi.AD9088.Rx Receive data from the AD9088 high speed ADC
    %   The adi.AD9088.Rx System object is a signal source that can receive
    %   complex data from the AD9088.
    %
    %   rx = adi.AD9088.Rx;
    %   rx = adi.AD9088.Rx('uri','ip:192.168.2.1');
    %
    %   <a href="https://www.analog.com/media/en/technical-documentation/data-sheets/ad9088.pdf">AD9088 Datasheet</a>
    %
    %   See also adi.AD9088.Tx

    properties
        %ChannelNCOFrequencies Channel NCO Frequencies
        %   Frequency of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        ChannelNCOFrequencies = zeros(1,8);
        %MainNCOFrequencies Main NCO Frequencies
        %   Frequency of NCO in coarse decimators in receive path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz, and N is the number of channels available.
        MainNCOFrequencies = zeros(1,8);
        %ChannelNCOPhases Channel NCO Phases
        %   Phase of NCO in fine decimators in receive path. Property
        %   must be a [1,N] vector where each value is the phase of an
        %   NCO in millidegrees, and N is the number of channels available.
        ChannelNCOPhases = zeros(1,8);
        %MainNCOPhases Main NCO Phases
        %   Phase of NCO in coarse decimators in receive path. Property
        %   must be a [1,N] vector where each value is the phase of an
        %   NCO in millidegrees, and N is the number of channels available.
        MainNCOPhases = zeros(1,8);
        %TestMode Test Mode
        %   Test mode of receive path. Options are:
        %   'off' 'midscale_short' 'pos_fullscale' 'neg_fullscale'
        %   'checkerboard' 'pn9' 'pn23' 'one_zero_toggle' 'user' 'pn7'
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
        %   Enable use of programmable filters (PFILT) in receive path
        EnablePFIRs = false;
        %EnableCFIRs Enable CFIRs
        %   Enable use of complex FIR filters (CFIR) in receive path
        EnableCFIRs = false;
    end

    properties (Nontunable)
        %PFIRFilenames PFIR File names
        %   Path(s) to PFILT filter file(s). Input can be a string or
        %   cell array of strings. Files are loaded in order
        PFIRFilenames = '';
        %CFIRFilenames CFIR File names
        %   Path(s) to CFIR filter file(s). Input can be a string or
        %   cell array of strings. Files are loaded in order
        CFIRFilenames = '';
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
        % Data channels are the scan elements of devName (one side).
        % Attribute channels are on phyDevName and cover both sides.
        num_data_channels = 4;
        num_coarse_attr_channels = 8;
        num_fine_attr_channels = 8;
    end

    properties (Nontunable, Hidden)
        devName = 'axi-ad9084-rx-hpc';
    end

    properties(Constant, Hidden)
        TestModeSet = matlab.system.StringSet({ ...
            'off','midscale_short','pos_fullscale','neg_fullscale'...
            'checkerboard','pn9','pn23','one_zero_toggle','user','pn7'...
            'pn15','pn31','ramp'});
        JESD204FSMControlSet = matlab.system.StringSet({'0','1'});
    end

    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9088.Base(varargin{:});
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
                writeFilterFile(obj, obj.PFIRFilenames, 'pfilt_config');
            end
        end
        % Check EnableCFIRs
        function set.EnableCFIRs(obj, value)
            validateattributes( value, { 'logical' }, ...
                { }, ...
                '', 'EnableCFIRs');
            obj.EnableCFIRs = value;
        end
        % Check CFIRFilenames
        function set.CFIRFilenames(obj, value)
            obj.CFIRFilenames = value;
            if obj.EnableCFIRs && obj.ConnectedToDevice
                writeFilterFile(obj, obj.CFIRFilenames, 'cfir_config');
            end
        end
    end

    %% API Functions
    methods (Hidden, Access = protected)

        function writeFilterFile(obj, fir_data_files, attr)
            % Read in filter files and write them sequentially into the
            % device attribute (pfilt_config or cfir_config)
            if ~iscell(fir_data_files)
                fir_data_files = {fir_data_files};
            end

            for fir_data_file = fir_data_files
                filename = fir_data_file{:};
                if ~exist(filename,'file')
                    error('Filter file %s does not exist',filename);
                end
                fir_data_str = fileread(filename);
                obj.setDeviceAttributeRAW(attr,fir_data_str);
            end
        end

        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required since Simulink support doesn't support
            % modification to nontunable variables at SetupImpl

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
                obj.writeFilterFile(obj.PFIRFilenames, 'pfilt_config');
            end
            if obj.EnableCFIRs
                obj.writeFilterFile(obj.CFIRFilenames, 'cfir_config');
            end
            %%
            obj.setAttributeRAW('voltage0_i','test_mode',obj.TestMode,...
                false,obj.iioDev);

        end

    end

end
