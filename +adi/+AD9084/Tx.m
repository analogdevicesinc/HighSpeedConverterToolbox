classdef Tx < adi.AD9084.Base & adi.common.Tx
    % adi.AD90084.Tx Transmit data from the AD90084 development board
    %   The adi.AD90084.Tx System object is a signal sink that can tranmsit
    %   complex data from the AD90084.
    %
    %   tx = adi.AD90084.Tx;
    %   tx = adi.AD90084.Tx('uri','ip:192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9084.pdf">AD9084 Datasheet</a>

    properties
        %ChannelNCOFrequencies Channel NCO Frequencies 
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOFrequencies = [0,0,0,0];
        %MainNCOFrequencies Main NCO Frequencies 
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOFrequencies = [0,0,0,0];
        %ChannelNCOPhases Channel NCO Phases 
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        ChannelNCOPhases = [0,0,0,0];
        %MainNCOPhases Main NCO Phases 
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        MainNCOPhases = [0,0,0,0];
        %ChannelNCOGainScales Channel NCO Gain Scales 
        %   Frequency of NCO in fine decimators in transmit path. Property
        %   must be a [1,N] vector where each value is the frequency of an
        %   NCO in hertz.
        % ChannelNCOGainScales = [1,1,1,1];
        %NCOEnables NCO Enables 
        %   Vector of logicals which enabled individual NCOs in channel
        %   interpolators
        NCOEnables = [false,false,false,false];
    end

    % =======================
    % PFIR SUPPORT
    % =======================
    properties (Nontunable, Logical)
        %EnablePFIRs Enable PFIRs
        %   Enable use of PFIR/PFILT filters on transmit path
        EnablePFIRs = false;
    end

    properties (Nontunable)
        %PFIRFilenames PFIR File names
        %   Path(s) to PFIR/PFILT filter file(s). Input can be a string or
        %   cell array of strings. Files are loaded in order
        PFIRFilenames = '';
    end

    % =======================
    % CFIR SUPPORT
    % =======================
    properties (Nontunable, Logical)
        %EnableCFIRs Enable CFIRs
        %   Enable use of CFIR filters on transmit path
        EnableCFIRs = false;
    end

    properties (Nontunable)
        %CFIRFilenames CFIR File names
        %   Path(s) to CFIR filter file(s). Input can be a string or
        %   cell array of strings. Files are loaded in order
        CFIRFilenames = '';
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
        num_data_channels = 4;
        num_coarse_attr_channels = 4;
        num_fine_attr_channels = 4;
        num_dds_channels = 16;
        devName = 'axi-ad9084-tx-hpc';
        phyDev       % axi-ad9084-tx-hpc (DDS/DMA)
        combinedDev  % axi-ad9084-rx-hpc (NCO/PHY attrs for both RX and TX)
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9084.Base(varargin{:});
            obj.phyDevName = 'axi-ad9084-tx-hpc';
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
            obj.NCOEnables = zeros(1,obj.num_fine_attr_channels) > 0;
        end
        % Check ChannelNCOFrequencies
        function set.ChannelNCOFrequencies(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOFrequencies',...
                'channel_nco_frequency', obj.combinedDev, false); %#ok<*MCSUP>
            obj.ChannelNCOFrequencies = value;
        end
        %%
        % Check MainNCOFrequencies
        function set.MainNCOFrequencies(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFrequencies',...
                'main_nco_frequency', obj.combinedDev, false);
            obj.MainNCOFrequencies = value;
        end
        %%
        % Check ChannelNCOPhases
        function set.ChannelNCOPhases(obj, value)
            obj.CheckAndUpdateHW(value,'ChannelNCOPhases',...
                'channel_nco_phase', obj.combinedDev, false);
            obj.ChannelNCOPhases = value;
        end
        %%
        % Check MainNCOPhases
        function set.MainNCOPhases(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOPhases',...
                'main_nco_phase', obj.combinedDev, false);
            obj.MainNCOPhases = value;
        end
        %%
        % Check NCOEnables
        function set.NCOEnables(obj, value)
            obj.CheckAndUpdateHWBool(value,'NCOEnables',...
                'en', obj.combinedDev, false);
            obj.NCOEnables = value;
        end
        % Check EnablePFIRs
        function set.EnablePFIRs(obj, value)
            validateattributes(value, {'logical'}, {}, '', 'EnablePFIRs');
            obj.EnablePFIRs = value;
        end
        % Check PFIRFilenames
        function set.PFIRFilenames(obj, value)
            obj.PFIRFilenames = value;
            if obj.EnablePFIRs && obj.ConnectedToDevice
                obj.writePFIRFile();
            end
        end
        % Check EnableCFIRs
        function set.EnableCFIRs(obj, value)
            validateattributes(value, {'logical'}, {});
            obj.EnableCFIRs = value;
        end
        % Check CFIRFilenames
        function set.CFIRFilenames(obj, value)
            obj.CFIRFilenames = value;
            if obj.EnableCFIRs && obj.ConnectedToDevice
                obj.writeCFIRFile();
            end
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)

        function writePFIRFile(obj)
            fir_data_files = obj.PFIRFilenames;
            if ~iscell(fir_data_files)
                fir_data_files = {fir_data_files};
            end
            for fir_data_file = fir_data_files
                filename = fir_data_file{:};
                if ~exist(filename,'file')
                    error('Filter file %s does not exist', filename);
                end
                fir_data_str = fileread(filename);
                obj.setDeviceAttributeRAW('pfilt_config', fir_data_str);
            end
        end

        function writeCFIRFile(obj)
            fir_data_files = obj.CFIRFilenames;
            if ~iscell(fir_data_files)
                fir_data_files = {fir_data_files};
            end
            for fir_data_file = fir_data_files
                filename = fir_data_file{:};
                if ~exist(filename,'file')
                    error('Filter file %s does not exist', filename);
                end
                fir_data_str = fileread(filename);
                obj.setDeviceAttributeRAW('cfir_config', fir_data_str);
            end
        end

        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl

            % Enable TX DMA offload
%             obj.setDebugAttributeBool('pl_ddr_fifo_enable', 1, getDev(obj, obj.devName));

            % NCO frequency/phase/gain/enable attributes all live on the
            % combined PHY device (axi-ad9084-rx-hpc), which hosts both
            % in_voltage* (RX) and out_voltage* (TX) channel attributes.
            % NOTE: iio_device_find_channel has inverted isOutput logic in
            % this binding (see %FIXME in Attribute.m), so pass false to
            % target output (TX) channels.
            combinedDev = getDev(obj, 'axi-ad9084-rx-hpc');
            obj.combinedDev = combinedDev;
            obj.phyDev  = getDev(obj, obj.phyDevName);  % tx-hpc (DDS/DMA)

            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOFrequencies,...
                'ChannelNCOFrequencies','channel_nco_frequency', ...
                combinedDev, false);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFrequencies,...
                'MainNCOFrequencies','main_nco_frequency', ...
                combinedDev, false);
            %%
            obj.CheckAndUpdateHW(obj.ChannelNCOPhases,...
                'ChannelNCOPhases','channel_nco_phase', ...
                combinedDev, false);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOPhases,...
                'MainNCOPhases','main_nco_phase', ...
                combinedDev, false);

            %%
            obj.CheckAndUpdateHWBool(obj.NCOEnables,...
                'NCOEnables','en', ...
                combinedDev, false);
            %% Program FIR Filters
            if obj.EnablePFIRs
                obj.writePFIRFile();
            end
            if obj.EnableCFIRs
                obj.writeCFIRFile();
            end
            %% DDS
            obj.ToggleDDS(strcmp(obj.DataSource,'DDS'));
            if strcmp(obj.DataSource,'DDS')
                obj.DDSUpdate();
            end
        end

    end

end
