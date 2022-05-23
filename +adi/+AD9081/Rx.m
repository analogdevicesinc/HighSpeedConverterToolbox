classdef Rx < adi.AD9081.Base & adi.common.Rx & adi.common.Attribute & ...
        adi.internal.MuxRxFFH & adi.internal.MuxRxNCO
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
    
    properties (Dependent)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value is only readable once
        %   connected to hardware
        SamplingRate
    end
    
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
    end

    properties (SetAccess = private, GetAccess = public)
       ChannelNCOFrequencyAvailable
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

    properties
        %NyquistZone Nyquist Zone
        %   Options:
        %   odd
        %   even
        NyquistZone
    end
    
    properties
        %MainFfhGpioModeEnableIn Main FFH GPIO Mode Enable In
        %   Enable FFH control through GPIO.
        MainFfhGpioModeEnableIn = [false,false,false,false];
        %MainFfhModeIn Main FFH Mode In
        %   Options:
        %   instantaneous_update
        %   synchronous_update_by_transfer_bit
        %   synchronous_update_by_gpio
        MainFfhModeIn = {'instantaneous_update', 'instantaneous_update', ...
            'instantaneous_update', 'instantaneous_update'};
        %MainFfhTrigHopEnableIn Main FFH Trigger Hop Enable In
        MainFfhTrigHopEnableIn = [false,false,false,false];
        %MainNCOFfhIndexIn Main NCO FFH Index In
        MainNCOFfhIndexIn = [0,0,0,0];
        %MainNCOFfhSelectIn Main NCO FFH Select In
        MainNCOFfhSelectIn = [0,0,0,0];

        %MainFfhGpioModeEnableOut Main FFH GPIO Mode Enable Out
        %   Enable FFH control through GPIO.
        MainFfhGpioModeEnableOut = [false,false,false,false];
        %MainFfhModeOut Main FFH Mode Out
        %   FFH Mode. Options:
        %   phase_continuous
        %   phase_incontinuous
        %   phase_coherent
        MainFfhModeOut = {'phase_continuous', 'phase_continuous', ...
            'phase_continuous', 'phase_continuous'};
        %MainNCOFfhFrequencyOut Main NCO FFH Frequency Out
        MainNCOFfhFrequencyOut = [0,0,0,0];
        %MainNCOFfhIndexOut Main NCO FFH Index Out
        MainNCOFfhIndexOut = [0,0,0,0];
        %MainNCOFfhSelectOut Main NCO FFH Select Out
        MainNCOFfhSelectOut = [0,0,0,0];
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
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9081.Base(varargin{:});
            obj.uri = 'ip:analog';
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

            obj.NyquistZone = cell(1,obj.num_coarse_attr_channels);
            obj.NyquistZone(:) = {'odd'};
            
            obj.MainFfhGpioModeEnableIn = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeIn = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeIn(:) = {'instantaneous_update'};
            obj.MainFfhTrigHopEnableIn = false(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhIndexIn = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhSelectIn = zeros(1,obj.num_coarse_attr_channels);

            obj.MainFfhGpioModeEnableOut = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeOut = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeOut(:) = {'phase_continuous'};
            obj.MainNCOFfhFrequencyOut = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhIndexOut = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhSelectOut = zeros(1,obj.num_coarse_attr_channels);
        end
        
        function value = get.SamplingRate(obj)
            if obj.ConnectedToDevice
                value= obj.getAttributeLongLong('voltage0_i','sampling_frequency',false);
            else
                value = NaN;
            end
        end
        
        % Get ChannelNCOFrequencyAvailable
        function value = get.ChannelNCOFrequencyAvailable(obj)
            if obj.ConnectedToDevice
                value= obj.getAttributeRAW('voltage0_i','channel_nco_frequency_available',false);
            else
                value = NaN;
            end
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
            obj.setAttributeRAW('voltage0_i','test_mode',value,false,...
                obj.iioDev);
            obj.TestMode = value;
        end
        %%
        % Check EnablePFIRs
        function set.EnablePFIRs(obj, value)
            validateattributes( value, { 'logical' }, ...
                { }, ...
                '', 'EnablePFIRs');
            obj.EnablePFIRs = value;
        end
        %%
        % Check PFIRFilenames
        function set.PFIRFilenames(obj, value)
            obj.PFIRFilenames = value;
            if obj.EnablePFIRs && obj.ConnectedToDevice
                writeFilterFile(obj);
            end
        end
        %%
        % Check NyquistZone
        function set.NyquistZone(obj, value)
            obj.CheckAndUpdateHWRaw(value,'NyquistZone',...
                'nyquist_zone', obj.iioDev);
            obj.NyquistZone = value;
        end
        %%
        % Check MainFfhGpioModeEnableIn
        function set.MainFfhGpioModeEnableIn(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableIn',...
                'main_ffh_gpio_mode_en', obj.iioDev);
            obj.MainFfhGpioModeEnableIn = value;
        end
        %%
        % Check MainFfhModeIn
        function set.MainFfhModeIn(obj, value)
            obj.CheckAndUpdateHWRaw(value,'MainFfhModeIn',...
                'main_ffh_mode', obj.iioDev);
            obj.MainFfhModeIn = value;
        end
        %%
        % Check MainFfhTrigHopEnableIn
        function set.MainFfhTrigHopEnableIn(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhTrigHopEnableIn',...
                'main_ffh_trig_hop_en', obj.iioDev);
            obj.MainFfhTrigHopEnableIn = value;
        end
        %%
        % Check MainNCOFfhIndexIn
        function set.MainNCOFfhIndexIn(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexIn',...
                'main_nco_ffh_index', obj.iioDev);
            obj.MainNCOFfhIndexIn = value;
        end
        %%
        % Check MainNCOFfhSelectIn
        function set.MainNCOFfhSelectIn(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectIn',...
                'main_nco_ffh_select', obj.iioDev);
            obj.MainNCOFfhSelectIn = value;
        end
        %%
        % Check MainFfhGpioModeEnableOut
        function set.MainFfhGpioModeEnableOut(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableOut',...
                'main_ffh_gpio_mode_en', obj.iioDev, true);
            obj.MainFfhGpioModeEnableOut = value;
        end
        %%
        % Check MainFfhModeOut
        function set.MainFfhModeOut(obj, value)
            obj.CheckAndUpdateHWRaw(value,'MainFfhModeOut',...
                'main_ffh_mode', obj.iioDev, true);
            obj.MainFfhModeOut = value;
        end
        %%
        % Check MainNCOFfhFrequencyOut
        function set.MainNCOFfhFrequencyOut(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhFrequencyOut',...
                'main_nco_ffh_frequency', obj.iioDev, true);
            obj.MainNCOFfhFrequencyOut = value;
        end
        %%
        % Check MainNCOFfhIndexOut
        function set.MainNCOFfhIndexOut(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexOut',...
                'main_nco_ffh_index', obj.iioDev, true);
            obj.MainNCOFfhIndexOut = value;
        end
        %%
        % Check MainNCOFfhSelectOut
        function set.MainNCOFfhSelectOut(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectOut',...
                'main_nco_ffh_select', obj.iioDev, true);
            obj.MainNCOFfhSelectOut = value;
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
            % This is required sine Simulink support doesn't support
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
            obj.CheckAndUpdateHWRaw(obj.NyquistZone,'NyquistZone',...
                'nyquist_zone', obj.iioDev);            
            %%
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableIn,...
                'MainFfhGpioModeEnableIn','main_ffh_gpio_mode_en', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeIn,'MainFfhModeIn',...
                'main_ffh_mode', obj.iioDev);
            %%
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableIn,...
                'MainFfhTrigHopEnableIn','main_ffh_trig_hop_en', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexIn,'MainNCOFfhIndexIn',...
                'main_nco_ffh_index', obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectIn,'MainNCOFfhSelectIn',...
                'main_nco_ffh_select', obj.iioDev);
            %%
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableOut,...
                'MainFfhGpioModeEnableOut','main_ffh_gpio_mode_en', ...
                obj.iioDev, true);
            %%
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeOut,'MainFfhModeOut',...
                'main_ffh_mode', obj.iioDev, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhFrequencyOut,...
                'MainNCOFfhFrequencyOut','main_nco_ffh_frequency', ...
                obj.iioDev, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexOut,'MainNCOFfhIndexOut',...
                'main_nco_ffh_index', obj.iioDev, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectOut,'MainNCOFfhSelectOut',...
                'main_nco_ffh_select', obj.iioDev, true);

            % MuxRxFFH Control
            setupInit@adi.internal.MuxRxFFH(obj);

            % MuxRxNCO Control
            setupInit@adi.internal.MuxRxNCO(obj);
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

