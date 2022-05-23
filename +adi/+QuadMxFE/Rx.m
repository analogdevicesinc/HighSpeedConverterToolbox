classdef Rx < adi.QuadMxFE.Base & adi.common.Rx & ...
        adi.internal.MuxRxFFH & adi.internal.MuxRxNCO
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
        %NyquistZoneChipA Nyquist Zone Chip A
        %   Options:
        %   odd
        %   even
        NyquistZoneChipA
        %NyquistZoneChipB Nyquist Zone Chip B
        %   Options:
        %   odd
        %   even
        NyquistZoneChipB
        %NyquistZoneChipC Nyquist Zone Chip C
        %   Options:
        %   odd
        %   even
        NyquistZoneChipC
        %NyquistZoneChipD Nyquist Zone Chip D
        %   Options:
        %   odd
        %   even
        NyquistZoneChipD
    end
    
    properties
        %MainFfhGpioModeEnableInChipA Main FFH GPIO Mode Enable In Chip A
        %   Enable FFH control through GPIO for Chip A.
        MainFfhGpioModeEnableInChipA = [false,false,false,false];
        %MainFfhGpioModeEnableInChipB Main FFH GPIO Mode Enable In Chip B
        %   Enable FFH control through GPIO for Chip B.
        MainFfhGpioModeEnableInChipB = [false,false,false,false];
        %MainFfhGpioModeEnableInChipC Main FFH GPIO Mode Enable In Chip C
        %   Enable FFH control through GPIO for Chip C.
        MainFfhGpioModeEnableInChipC = [false,false,false,false];
        %MainFfhGpioModeEnableInChipD Main FFH GPIO Mode Enable In Chip D
        %   Enable FFH control through GPIO for Chip D.
        MainFfhGpioModeEnableInChipD = [false,false,false,false];
    end

    properties
        %MainFfhModeInChipA Main FFH Mode In Chip A
        %   Options:
        %   instantaneous_update
        %   synchronous_update_by_transfer_bit
        %   synchronous_update_by_gpio
        MainFfhModeInChipA = {'instantaneous_update', 'instantaneous_update', ...
            'instantaneous_update', 'instantaneous_update'};
        %MainFfhModeInChipB Main FFH Mode In Chip B
        %   Options:
        %   instantaneous_update
        %   synchronous_update_by_transfer_bit
        %   synchronous_update_by_gpio
        MainFfhModeInChipB = {'instantaneous_update', 'instantaneous_update', ...
            'instantaneous_update', 'instantaneous_update'};
        %MainFfhModeInChipC Main FFH Mode In Chip C
        %   Options:
        %   instantaneous_update
        %   synchronous_update_by_transfer_bit
        %   synchronous_update_by_gpio
        MainFfhModeInChipC = {'instantaneous_update', 'instantaneous_update', ...
            'instantaneous_update', 'instantaneous_update'};
        %MainFfhModeInChipD Main FFH Mode In Chip D
        %   Options:
        %   instantaneous_update
        %   synchronous_update_by_transfer_bit
        %   synchronous_update_by_gpio
        MainFfhModeInChipD = {'instantaneous_update', 'instantaneous_update', ...
            'instantaneous_update', 'instantaneous_update'};
    end

    properties
        %MainFfhTrigHopEnableInChipA Main NCO FFH Frequency In Chip A
        MainFfhTrigHopEnableInChipA = [0,0,0,0];
        %MainFfhTrigHopEnableInChipB Main NCO FFH Frequency In Chip B
        MainFfhTrigHopEnableInChipB = [0,0,0,0];
        %MainFfhTrigHopEnableInChipC Main NCO FFH Frequency In Chip C
        MainFfhTrigHopEnableInChipC = [0,0,0,0];
        %MainFfhTrigHopEnableInChipD Main NCO FFH Frequency In Chip D
        MainFfhTrigHopEnableInChipD = [0,0,0,0];
    end

    properties
        %MainNCOFfhIndexInChipA Main NCO FFH Index In Chip A
        MainNCOFfhIndexInChipA = [0,0,0,0];
        %MainNCOFfhIndexInChipB Main NCO FFH Index In Chip B
        MainNCOFfhIndexInChipB = [0,0,0,0];
        %MainNCOFfhIndexInChipC Main NCO FFH Index In Chip C
        MainNCOFfhIndexInChipC = [0,0,0,0];
        %MainNCOFfhIndexInChipD Main NCO FFH Index In Chip D
        MainNCOFfhIndexInChipD = [0,0,0,0];
    end

    properties
        %MainNCOFfhSelectInChipA Main NCO FFH Select In Chip A
        MainNCOFfhSelectInChipA = [0,0,0,0];
        %MainNCOFfhSelectInChipB Main NCO FFH Select In Chip B
        MainNCOFfhSelectInChipB = [0,0,0,0];
        %MainNCOFfhSelectInChipC Main NCO FFH Select In Chip C
        MainNCOFfhSelectInChipC = [0,0,0,0];
        %MainNCOFfhSelectInChipD Main NCO FFH Select In Chip D
        MainNCOFfhSelectInChipD = [0,0,0,0];
    end

    properties
        %MainFfhGpioModeEnableOutChipA Main FFH GPIO Mode Enable Out Chip A
        %   Enable FFH control through GPIO for Chip A.
        MainFfhGpioModeEnableOutChipA = [false,false,false,false];
        %MainFfhGpioModeEnableOutChipB Main FFH GPIO Mode Enable Out Chip B
        %   Enable FFH control through GPIO for Chip B.
        MainFfhGpioModeEnableOutChipB = [false,false,false,false];
        %MainFfhGpioModeEnableOutChipC Main FFH GPIO Mode Enable Out Chip C
        %   Enable FFH control through GPIO for Chip C.
        MainFfhGpioModeEnableOutChipC = [false,false,false,false];
        %MainFfhGpioModeEnableOutChipD Main FFH GPIO Mode Enable Out Chip D
        %   Enable FFH control through GPIO for Chip D.
        MainFfhGpioModeEnableOutChipD = [false,false,false,false];
    end

    properties
        %MainFfhModeOutChipA Main FFH Mode Out Chip A
        %   Options:
        %   phase_continuous
        %   phase_incontinuous
        %   phase_coherent
        MainFfhModeOutChipA = {'phase_continuous', 'phase_continuous', ...
            'phase_continuous', 'phase_continuous'};
        %MainFfhModeOutChipB Main FFH Mode Out Chip B
        %   Options:
        %   phase_continuous
        %   phase_incontinuous
        %   phase_coherent
        MainFfhModeOutChipB = {'phase_continuous', 'phase_continuous', ...
            'phase_continuous', 'phase_continuous'};
        %MainFfhModeOutChipC Main FFH Mode Out Chip C
        %   Options:
        %   phase_continuous
        %   phase_incontinuous
        %   phase_coherent
        MainFfhModeOutChipC = {'phase_continuous', 'phase_continuous', ...
            'phase_continuous', 'phase_continuous'};
        %MainFfhModeOutChipD Main FFH Mode Out Chip D
        %   Options:
        %   phase_continuous
        %   phase_incontinuous
        %   phase_coherent
        MainFfhModeOutChipD = {'phase_continuous', 'phase_continuous', ...
            'phase_continuous', 'phase_continuous'};
    end
    
    properties
        %MainNCOFfhFrequencyOutChipA Main NCO FFH Frequency Out Chip A
        MainNCOFfhFrequencyOutChipA = [0,0,0,0];
        %MainNCOFfhFrequencyOutChipB Main NCO FFH Frequency Out Chip B
        MainNCOFfhFrequencyOutChipB = [0,0,0,0];
        %MainNCOFfhFrequencyOutChipC Main NCO FFH Frequency Out Chip C
        MainNCOFfhFrequencyOutChipC = [0,0,0,0];
        %MainNCOFfhFrequencyOutChipD Main NCO FFH Frequency Out Chip D
        MainNCOFfhFrequencyOutChipD = [0,0,0,0];
    end

    properties
        %MainNCOFfhIndexOutChipA Main NCO FFH Index Out Chip A
        MainNCOFfhIndexOutChipA = [0,0,0,0];
        %MainNCOFfhIndexOutChipB Main NCO FFH Index Out Chip B
        MainNCOFfhIndexOutChipB = [0,0,0,0];
        %MainNCOFfhIndexOutChipC Main NCO FFH Index Out Chip C
        MainNCOFfhIndexOutChipC = [0,0,0,0];
        %MainNCOFfhIndexOutChipD Main NCO FFH Index Out Chip D
        MainNCOFfhIndexOutChipD = [0,0,0,0];
    end

    properties
        %MainNCOFfhSelectOutChipA Main NCO FFH Select Out Chip A
        MainNCOFfhSelectOutChipA = [0,0,0,0];
        %MainNCOFfhSelectOutChipB Main NCO FFH Select Out Chip B
        MainNCOFfhSelectOutChipB = [0,0,0,0];
        %MainNCOFfhSelectOutChipC Main NCO FFH Select Out Chip C
        MainNCOFfhSelectOutChipC = [0,0,0,0];
        %MainNCOFfhSelectOutChipD Main NCO FFH Select Out Chip D
        MainNCOFfhSelectOutChipD = [0,0,0,0];
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
    
    properties (SetAccess = private, GetAccess = public)
       ChannelNCOFrequencyAvailable
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
            
            obj.NyquistZoneChipA = cell(1,obj.num_coarse_attr_channels);
            obj.NyquistZoneChipA(:) = {'odd'};
            obj.NyquistZoneChipB = cell(1,obj.num_coarse_attr_channels);
            obj.NyquistZoneChipB(:) = {'odd'};
            obj.NyquistZoneChipC = cell(1,obj.num_coarse_attr_channels);
            obj.NyquistZoneChipC(:) = {'odd'};
            obj.NyquistZoneChipD = cell(1,obj.num_coarse_attr_channels);
            obj.NyquistZoneChipD(:) = {'odd'};
            
            obj.MainFfhGpioModeEnableInChipA = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhGpioModeEnableInChipB = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhGpioModeEnableInChipC = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhGpioModeEnableInChipD = false(1,obj.num_coarse_attr_channels);

            obj.MainFfhModeInChipA = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeInChipA(:) = {'instantaneous_update'};
            obj.MainFfhModeInChipB = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeInChipB(:) = {'instantaneous_update'};
            obj.MainFfhModeInChipC = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeInChipC(:) = {'instantaneous_update'};
            obj.MainFfhModeInChipD = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeInChipD(:) = {'instantaneous_update'};

            obj.MainFfhTrigHopEnableInChipA = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhTrigHopEnableInChipB = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhTrigHopEnableInChipC = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhTrigHopEnableInChipD = false(1,obj.num_coarse_attr_channels);

            obj.MainNCOFfhIndexInChipA = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhIndexInChipB = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhIndexInChipC = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhIndexInChipD = zeros(1,obj.num_coarse_attr_channels);

            obj.MainNCOFfhSelectInChipA = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhSelectInChipB = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhSelectInChipC = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhSelectInChipD = zeros(1,obj.num_coarse_attr_channels);

            obj.MainFfhGpioModeEnableOutChipA = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhGpioModeEnableOutChipB = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhGpioModeEnableOutChipC = false(1,obj.num_coarse_attr_channels);
            obj.MainFfhGpioModeEnableOutChipD = false(1,obj.num_coarse_attr_channels);

            obj.MainFfhModeOutChipA = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeOutChipA(:) = {'phase_continuous'};
            obj.MainFfhModeOutChipB = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeOutChipB(:) = {'phase_continuous'};
            obj.MainFfhModeOutChipC = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeOutChipC(:) = {'phase_continuous'};
            obj.MainFfhModeOutChipD = cell(1,obj.num_coarse_attr_channels);
            obj.MainFfhModeOutChipD(:) = {'phase_continuous'};

            obj.MainNCOFfhFrequencyOutChipA = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhFrequencyOutChipB = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhFrequencyOutChipC = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhFrequencyOutChipD = zeros(1,obj.num_coarse_attr_channels);
            
            obj.MainNCOFfhIndexOutChipA = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhIndexOutChipB = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhIndexOutChipC = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhIndexOutChipD = zeros(1,obj.num_coarse_attr_channels);

            obj.MainNCOFfhSelectOutChipA = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhSelectOutChipB = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhSelectOutChipC = zeros(1,obj.num_coarse_attr_channels);
            obj.MainNCOFfhSelectOutChipD = zeros(1,obj.num_coarse_attr_channels);
        end
        
        % Get ChannelNCOFrequencyAvailable
        function value = get.ChannelNCOFrequencyAvailable(obj)
            if obj.ConnectedToDevice
                value= obj.getAttributeRAW('voltage0_i','channel_nco_frequency_available',false);
            else
                value = NaN;
            end
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

        %%
        % Check NyquistZoneChipA
        function set.NyquistZoneChipA(obj, value)
            obj.CheckAndUpdateHWRaw(value,'NyquistZoneChipA',...
                'nyquist_zone', obj.iioDev0);
            obj.NyquistZoneChipA = value;
        end
        % Check NyquistZoneChipB
        function set.NyquistZoneChipB(obj, value)
            obj.CheckAndUpdateHWRaw(value,'NyquistZoneChipB',...
                'nyquist_zone', obj.iioDev1);
            obj.NyquistZoneChipB = value;
        end
        % Check NyquistZoneChipC
        function set.NyquistZoneChipC(obj, value)
            obj.CheckAndUpdateHWRaw(value,'NyquistZoneChipC',...
                'nyquist_zone', obj.iioDev2);
            obj.NyquistZoneChipC = value;
        end
        % Check NyquistZoneChipD
        function set.NyquistZoneChipD(obj, value)
            obj.CheckAndUpdateHWRaw(value,'NyquistZoneChipD',...
                'nyquist_zone', obj.iioDev);
            obj.NyquistZoneChipD = value;
        end
        %%
        % Check MainFfhGpioModeEnableInChipA
        function set.MainFfhGpioModeEnableInChipA(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableInChipA',...
                'main_ffh_gpio_mode_en', obj.iioDev0);
            obj.MainFfhGpioModeEnableInChipA = value;
        end
        % Check MainFfhGpioModeEnableInChipB
        function set.MainFfhGpioModeEnableInChipB(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableInChipB',...
                'main_ffh_gpio_mode_en', obj.iioDev1);
            obj.MainFfhGpioModeEnableInChipB = value;
        end
        % Check MainFfhGpioModeEnableInChipC
        function set.MainFfhGpioModeEnableInChipC(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableInChipC',...
                'main_ffh_gpio_mode_en', obj.iioDev2);
            obj.MainFfhGpioModeEnableInChipC = value;
        end
        % Check MainFfhGpioModeEnableInChipC
        function set.MainFfhGpioModeEnableInChipD(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableInChipD',...
                'main_ffh_gpio_mode_en', obj.iioDev);
            obj.MainFfhGpioModeEnableInChipD = value;
        end
        %%
        % Check MainFfhModeInChipA
        function set.MainFfhModeInChipA(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhModeInChipA',...
                'main_ffh_mode', obj.iioDev0);
            obj.MainFfhModeInChipA = value;
        end
        % Check MainFfhGpioModeEnableInChipB
        function set.MainFfhModeInChipB(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhModeInChipB',...
                'main_ffh_mode', obj.iioDev1);
            obj.MainFfhModeInChipB = value;
        end
        % Check MainFfhGpioModeEnableInChipC
        function set.MainFfhModeInChipC(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhModeInChipC',...
                'main_ffh_mode', obj.iioDev2);
            obj.MainFfhModeInChipC = value;
        end
        % Check MainFfhGpioModeEnableInChipC
        function set.MainFfhModeInChipD(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhModeInChipD',...
                'main_ffh_mode', obj.iioDev);
            obj.MainFfhModeInChipD = value;
        end
        %%
        % Check MainFfhTrigHopEnableInChipA
        function set.MainFfhTrigHopEnableInChipA(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhTrigHopEnableInChipA',...
                'main_ffh_trig_hop_en', obj.iioDev0);
            obj.MainFfhTrigHopEnableInChipA = value;
        end
        % Check MainFfhTrigHopEnableInChipB
        function set.MainFfhTrigHopEnableInChipB(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhTrigHopEnableInChipB',...
                'main_ffh_trig_hop_en', obj.iioDev1);
            obj.MainFfhTrigHopEnableInChipB = value;
        end
        % Check MainFfhTrigHopEnableInChipC
        function set.MainFfhTrigHopEnableInChipC(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhTrigHopEnableInChipC',...
                'main_ffh_trig_hop_en', obj.iioDev2);
            obj.MainFfhTrigHopEnableInChipC = value;
        end
        % Check MainFfhTrigHopEnableInChipD
        function set.MainFfhTrigHopEnableInChipD(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhTrigHopEnableInChipD',...
                'main_ffh_trig_hop_en', obj.iioDev);
            obj.MainFfhTrigHopEnableInChipD = value;
        end
        %%
        % Check MainNCOFfhIndexInChipA
        function set.MainNCOFfhIndexInChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexInChipA',...
                'main_nco_ffh_index', obj.iioDev0);
            obj.MainNCOFfhIndexInChipA = value;
        end
        % Check MainNCOFfhIndexInChipB
        function set.MainNCOFfhIndexInChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexInChipB',...
                'main_nco_ffh_index', obj.iioDev1);
            obj.MainNCOFfhIndexInChipB = value;
        end
        % Check MainNCOFfhIndexInChipC
        function set.MainNCOFfhIndexInChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexInChipC',...
                'main_nco_ffh_index', obj.iioDev2);
            obj.MainNCOFfhIndexInChipC = value;
        end
        % Check MainNCOFfhIndexInChipD
        function set.MainNCOFfhIndexInChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexInChipD',...
                'main_nco_ffh_index', obj.iioDev);
            obj.MainNCOFfhIndexInChipD = value;
        end
        %%
        % Check MainNCOFfhSelectInChipA
        function set.MainNCOFfhSelectInChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectInChipA',...
                'main_nco_ffh_select', obj.iioDev0);
            obj.MainNCOFfhSelectInChipA = value;
        end
        % Check MainNCOFfhSelectInChipB
        function set.MainNCOFfhSelectInChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectInChipB',...
                'main_nco_ffh_select', obj.iioDev1);
            obj.MainNCOFfhSelectInChipB = value;
        end
        % Check MainNCOFfhSelectInChipC
        function set.MainNCOFfhSelectInChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectInChipC',...
                'main_nco_ffh_select', obj.iioDev2);
            obj.MainNCOFfhSelectInChipC = value;
        end
        % Check MainNCOFfhSelectInChipD
        function set.MainNCOFfhSelectInChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectInChipD',...
                'main_nco_ffh_select', obj.iioDev);
            obj.MainNCOFfhSelectInChipD = value;
        end
        %%
        % Check MainFfhGpioModeEnableOutChipA
        function set.MainFfhGpioModeEnableOutChipA(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableOutChipA',...
                'main_ffh_gpio_mode_en', obj.iioDev0, true);
            obj.MainFfhGpioModeEnableOutChipA = value;
        end
        % Check MainFfhGpioModeEnableOutChipB
        function set.MainFfhGpioModeEnableOutChipB(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableOutChipB',...
                'main_ffh_gpio_mode_en', obj.iioDev1, true);
            obj.MainFfhGpioModeEnableOutChipB = value;
        end
        % Check MainFfhGpioModeEnableOutChipC
        function set.MainFfhGpioModeEnableOutChipC(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableOutChipC',...
                'main_ffh_gpio_mode_en', obj.iioDev2, true);
            obj.MainFfhGpioModeEnableOutChipC = value;
        end
        % Check MainFfhGpioModeEnableOutChipC
        function set.MainFfhGpioModeEnableOutChipD(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhGpioModeEnableOutChipD',...
                'main_ffh_gpio_mode_en', obj.iioDev, true);
            obj.MainFfhGpioModeEnableOutChipD = value;
        end
        %%
        % Check MainFfhModeOutChipA
        function set.MainFfhModeOutChipA(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhModeOutChipA',...
                'main_ffh_mode', obj.iioDev0, true);
            obj.MainFfhModeOutChipA = value;
        end
        % Check MainFfhGpioModeEnableOutChipB
        function set.MainFfhModeOutChipB(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhModeOutChipB',...
                'main_ffh_mode', obj.iioDev1, true);
            obj.MainFfhModeOutChipB = value;
        end
        % Check MainFfhGpioModeEnableOutChipC
        function set.MainFfhModeOutChipC(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhModeOutChipC',...
                'main_ffh_mode', obj.iioDev2, true);
            obj.MainFfhModeOutChipC = value;
        end
        % Check MainFfhGpioModeEnableOutChipC
        function set.MainFfhModeOutChipD(obj, value)
            obj.CheckAndUpdateHWBool(value,'MainFfhModeOutChipD',...
                'main_ffh_mode', obj.iioDev, true);
            obj.MainFfhModeOutChipD = value;
        end
        %%
        % Check MainNCOFfhFrequencyOutChipA
        function set.MainNCOFfhFrequencyOutChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhFrequencyOutChipA',...
                'main_nco_ffh_frequency', obj.iioDev0, true);
            obj.MainNCOFfhFrequencyOutChipA = value;
        end
        % Check MainNCOFfhFrequencyOutChipB
        function set.MainNCOFfhFrequencyOutChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhFrequencyOutChipB',...
                'main_nco_ffh_frequency', obj.iioDev1, true);
            obj.MainNCOFfhFrequencyOutChipB = value;
        end
        % Check MainNCOFfhFrequencyOutChipC
        function set.MainNCOFfhFrequencyOutChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhFrequencyOutChipC',...
                'main_nco_ffh_frequency', obj.iioDev2, true);
            obj.MainNCOFfhFrequencyOutChipC = value;
        end
        % Check MainNCOFfhFrequencyOutChipD
        function set.MainNCOFfhFrequencyOutChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhFrequencyOutChipD',...
                'main_nco_ffh_frequency', obj.iioDev, true);
            obj.MainNCOFfhFrequencyOutChipD = value;
        end
        %%
        % Check MainNCOFfhIndexOutChipA
        function set.MainNCOFfhIndexOutChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexOutChipA',...
                'main_nco_ffh_index', obj.iioDev0, true);
            obj.MainNCOFfhIndexOutChipA = value;
        end
        % Check MainNCOFfhIndexOutChipB
        function set.MainNCOFfhIndexOutChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexOutChipB',...
                'main_nco_ffh_index', obj.iioDev1, true);
            obj.MainNCOFfhIndexOutChipB = value;
        end
        % Check MainNCOFfhIndexOutChipC
        function set.MainNCOFfhIndexOutChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexOutChipC',...
                'main_nco_ffh_index', obj.iioDev2, true);
            obj.MainNCOFfhIndexOutChipC = value;
        end
        % Check MainNCOFfhIndexOutChipD
        function set.MainNCOFfhIndexOutChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhIndexOutChipD',...
                'main_nco_ffh_index', obj.iioDev, true);
            obj.MainNCOFfhIndexOutChipD = value;
        end
        %%
        % Check MainNCOFfhSelectOutChipA
        function set.MainNCOFfhSelectOutChipA(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectOutChipA',...
                'main_nco_ffh_select', obj.iioDev0, true);
            obj.MainNCOFfhSelectOutChipA = value;
        end
        % Check MainNCOFfhSelectOutChipB
        function set.MainNCOFfhSelectOutChipB(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectOutChipB',...
                'main_nco_ffh_select', obj.iioDev1, true);
            obj.MainNCOFfhSelectOutChipB = value;
        end
        % Check MainNCOFfhSelectOutChipC
        function set.MainNCOFfhSelectOutChipC(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectOutChipC',...
                'main_nco_ffh_select', obj.iioDev2, true);
            obj.MainNCOFfhSelectOutChipC = value;
        end
        % Check MainNCOFfhSelectOutChipD
        function set.MainNCOFfhSelectOutChipD(obj, value)
            obj.CheckAndUpdateHW(value,'MainNCOFfhSelectOutChipD',...
                'main_nco_ffh_select', obj.iioDev, true);
            obj.MainNCOFfhSelectOutChipD = value;
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
            
            % Rev C uses a different DSA
            obj.iioHMC425a = iio_context_find_device(obj, obj.iioCtx, 'hmc425a');
            status = cPtrCheck(obj,obj.iioHMC425a);
            if status < 0
                obj.iioHMC425a = getDev(obj, 'hmc540s');
            end

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
            %%
            obj.CheckAndUpdateHWRaw(obj.NyquistZoneChipA,'NyquistZoneChipA',...
                'nyquist_zone', obj.iioDev0); 
            obj.CheckAndUpdateHWRaw(obj.NyquistZoneChipB,'NyquistZoneChipB',...
                'nyquist_zone', obj.iioDev1); 
            obj.CheckAndUpdateHWRaw(obj.NyquistZoneChipC,'NyquistZoneChipC',...
                'nyquist_zone', obj.iioDev2); 
            obj.CheckAndUpdateHWRaw(obj.NyquistZoneChipD,'NyquistZoneChipD',...
                'nyquist_zone', obj.iioDev); 
            %%
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableInChipA,...
                'MainFfhGpioModeEnableInChipA','main_ffh_gpio_mode_en', ...
                obj.iioDev0);
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableInChipB,...
                'MainFfhGpioModeEnableInChipB','main_ffh_gpio_mode_en', ...
                obj.iioDev1);
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableInChipC,...
                'MainFfhGpioModeEnableInChipC','main_ffh_gpio_mode_en', ...
                obj.iioDev2);
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableInChipD,...
                'MainFfhGpioModeEnableInChipD','main_ffh_gpio_mode_en', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeInChipA,...
                'MainFfhModeInChipA','main_ffh_mode', obj.iioDev0);
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeInChipB,...
                'MainFfhModeInChipB','main_ffh_mode', obj.iioDev1);
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeInChipC,...
                'MainFfhModeInChipC','main_ffh_mode', obj.iioDev2);
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeInChipD,...
                'MainFfhModeInChipD','main_ffh_mode', obj.iioDev);
            %%
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableInChipA,...
                'MainFfhTrigHopEnableInChipA','main_ffh_trig_hop_en', ...
                obj.iioDev0);
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableInChipB,...
                'MainFfhTrigHopEnableInChipB','main_ffh_trig_hop_en', ...
                obj.iioDev1);
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableInChipC,...
                'MainFfhTrigHopEnableInChipC','main_ffh_trig_hop_en', ...
                obj.iioDev2);
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableInChipD,...
                'MainFfhTrigHopEnableInChipD','main_ffh_trig_hop_en', ...
                obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexInChipA,...
                'MainNCOFfhIndexInChipA','main_nco_ffh_index', obj.iioDev0);
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexInChipB,...
                'MainNCOFfhIndexInChipB','main_nco_ffh_index', obj.iioDev1);
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexInChipC,...
                'MainNCOFfhIndexInChipC','main_nco_ffh_index', obj.iioDev2);
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexInChipD,...
                'MainNCOFfhIndexInChipD','main_nco_ffh_index', obj.iioDev);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectInChipA,...
                'MainNCOFfhSelectInChipA','main_nco_ffh_select', obj.iioDev0);
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectInChipB,...
                'MainNCOFfhSelectInChipB','main_nco_ffh_select', obj.iioDev1);
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectInChipC,...
                'MainNCOFfhSelectInChipC','main_nco_ffh_select', obj.iioDev2);
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectInChipD,...
                'MainNCOFfhSelectInChipD','main_nco_ffh_select', obj.iioDev);
            %%
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableOutChipA,...
                'MainFfhGpioModeEnableOutChipA','main_ffh_gpio_mode_en', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableOutChipB,...
                'MainFfhGpioModeEnableOutChipB','main_ffh_gpio_mode_en', ...
                obj.iioDev1, true);
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableOutChipC,...
                'MainFfhGpioModeEnableOutChipC','main_ffh_gpio_mode_en', ...
                obj.iioDev2, true);
            obj.CheckAndUpdateHWBool(obj.MainFfhGpioModeEnableOutChipD,...
                'MainFfhGpioModeEnableOutChipD','main_ffh_gpio_mode_en', ...
                obj.iioDev, true);
            %%
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeOutChipA,...
                'MainFfhModeOutChipA','main_ffh_mode', obj.iioDev0, true);
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeOutChipB,...
                'MainFfhModeOutChipB','main_ffh_mode', obj.iioDev1, true);
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeOutChipC,...
                'MainFfhModeOutChipC','main_ffh_mode', obj.iioDev2, true);
            obj.CheckAndUpdateHWRaw(obj.MainFfhModeOutChipD,...
                'MainFfhModeOutChipD','main_ffh_mode', obj.iioDev, true);
            %%
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableOutChipA,...
                'MainFfhTrigHopEnableOutChipA','main_ffh_trig_hop_en', ...
                obj.iioDev0, true);
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableOutChipB,...
                'MainFfhTrigHopEnableOutChipB','main_ffh_trig_hop_en', ...
                obj.iioDev1, true);
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableOutChipC,...
                'MainFfhTrigHopEnableOutChipC','main_ffh_trig_hop_en', ...
                obj.iioDev2, true);
            obj.CheckAndUpdateHWBool(obj.MainFfhTrigHopEnableOutChipD,...
                'MainFfhTrigHopEnableOutChipD','main_ffh_trig_hop_en', ...
                obj.iioDev, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexOutChipA,...
                'MainNCOFfhIndexOutChipA','main_nco_ffh_index',...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexOutChipB,...
                'MainNCOFfhIndexOutChipB','main_nco_ffh_index',...
                obj.iioDev1, true);
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexOutChipC,...
                'MainNCOFfhIndexOutChipC','main_nco_ffh_index',...
                obj.iioDev2, true);
            obj.CheckAndUpdateHW(obj.MainNCOFfhIndexOutChipD,...
                'MainNCOFfhIndexOutChipD','main_nco_ffh_index',...
                obj.iioDev, true);
            %%
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectOutChipA,...
                'MainNCOFfhSelectOutChipA','main_nco_ffh_select',...
                obj.iioDev0, true);
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectOutChipB,...
                'MainNCOFfhSelectOutChipB','main_nco_ffh_select',...
                obj.iioDev1, true);
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectOutChipC,...
                'MainNCOFfhSelectOutChipC','main_nco_ffh_select',...
                obj.iioDev2, true);
            obj.CheckAndUpdateHW(obj.MainNCOFfhSelectOutChipD,...
                'MainNCOFfhSelectOutChipD','main_nco_ffh_select',...
                obj.iioDev, true);

            % MuxRxFFH Control
            setupInit@adi.internal.MuxRxFFH(obj);

            % MuxRxNCO Control
            setupInit@adi.internal.MuxRxNCO(obj);
        end

    end

end
